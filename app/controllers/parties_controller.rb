# frozen_string_literal: true

class PartiesController < ApplicationController
  before_action :authorize, except: [ :index, :join, :show ]
  before_action :party_exists?, except: [ :index, :create ]
  before_action :party_has_device?, except: [ :create, :settings, :select_device, :index ]
  before_action :user_in_party?, only: :show
  before_action :user_owns_party?, only: [ :settings, :select_device, :start, :end, :resume, :stop ]
  before_action :user_is_premium?, only: :create
  before_action :owner_is_premium?, only: [ :join, :show ]

  rate_limit to: 7, within: 3.minutes,
    by: -> { request.remote_ip },
    with: -> { rate_limit_exceeded },
    only: [ :create, :join ]

  # TODO: what happens if user is premium but changes to free?
  class RetriesDepleted < StandardError; end
  class PartyAlreadyExists < StandardError; end
  class RateLimitExceeded < StandardError
    def initialize(remote_ip)
      super("Rate Limit Exceeded - remote_ip: #{remote_ip}")
    end
  end

  PARTY_CREATION_RETRIES = 3

  def create
    party = create_party_with_random_code

    party.users << current_user

    redirect_to select_device_path(code: party.code)
  rescue RetriesDepleted,
    PartyAlreadyExists => e

    report_error(e)
    if e.class == PartyAlreadyExists
      flash[:error] = "You already have a party with that name"
    else
      flash[:error] = "There was an error creating the party"
    end
    redirect_to home_path
  end

  def join
    if logged_with_spotify?
      session[:temporal_session] = nil
      party.users << current_user
      flash[:notice] = "Party joined!"
      redirect_to show_party_path(code: code)
    elsif session[:temporal_session].present?
      redirect_to show_party_path(code: code)
    else
      session[:joining_party_code] = code
      @code = code
      render "non_logged_join"
    end
  rescue ActiveRecord::RecordInvalid,
    ActiveRecord::RecordNotUnique => e
    report_error(e)
    flash[:notice] = "You have already joined!"
    redirect_to show_party_path(code: code)
  end

  def show
    @user_is_owner = current_user == party.user
    @party_songs = party.party_songs.includes(:song).where(played: false).load
  end

  def start
    Spotify::Api::Playback::TransferPlaybackService.new(party.user.access_token, party.device_id, play: false).call
    party_song_to_play = party.party_songs.where(next_song: true).first

    PlaySongAndEnqueueNextService.new(party_song: party_song_to_play, party: party).call
    PartyStatusUpdaterJob.set(wait: 3.seconds).perform_later(party_id: party.id)

    party.update(started: true)
    UpdateCurrentlyPlayingService.new(party: party).call
    head :ok
  rescue Spotify::ApiError => e
    report_error(e)
    head 500
  end

  def stop
    Spotify::Api::Playback::TransferPlaybackService.new(party.user.access_token, party.device_id, play: false).call

    Spotify::Api::Playback::StopService.new(party.user.access_token, party.device_id).call
    party.update(stopped: true)
    UpdateCurrentlyPlayingService.new(party: party).call
    head :ok
  rescue Spotify::ApiError => e
    report_error(e)
    head 500
  end

  def resume
    Spotify::Api::Playback::TransferPlaybackService.new(party.user.access_token, party.device_id, play: false).call
    next_party_song = party.party_songs.where(next_song: true).first

    if party.currently_playing_song
      Spotify::Api::Playback::StartService.new(party.user.access_token, party.device_id).call
    elsif next_party_song.present?
      PlaySongAndEnqueueNextService.new(party_song: next_party_song, party: party).call
    end
    party.update(stopped: false)

    UpdateCurrentlyPlayingService.new(party: party).call
    head :ok
  rescue Spotify::ApiError => e
    report_error(e)
    head 500
  end

  def settings
    @devices = Spotify::Api::Playback::AvailableDevicesService.new(current_user.access_token).call
    @devices = @devices["devices"]&.map { |device| DevicePresenter.new(device) }
  end

  def select_device
    if party.device_id.present?
      redirect_to home_path
    else
      @devices = Spotify::Api::Playback::AvailableDevicesService.new(current_user.access_token).call
      @devices = @devices["devices"]&.map { |device| DevicePresenter.new(device) }
    end
  rescue Spotify::ApiError => e
    report_error(e)
    flash[:error] = "There was an error, try again"
    redirect_to home_path
  end

  def index
    if current_user
      @currently_joined = current_user.joined_parties.where.not(user_id: current_user.id).where(ended_at: nil)
      @my_parties = current_user.parties.where(ended_at: nil)
    elsif
      @currently_joined = TemporalUser.find_by(id: session[:temporal_session]).party
      render 'temporal_user_party_index'
    end
  end

  def end
    party.update(ended_at: Time.now)
    flash[:notice] = "Party ended!"
    redirect_back(fallback_location: home_path)
  end

  private

  def create_party_with_random_code
    retries = 0
    random_code = nil
    party = nil

    loop do
      raise RetriesDepleted if retries >= PARTY_CREATION_RETRIES
      random_code = SecureRandom.hex(3)

      party = Party.create(user: current_user, name: name, code: random_code, ends_at: Time.now + Party::MAX_DURATION)

      raise PartyAlreadyExists if party.errors[:name].present?

      break if party.valid?

      retries += 1
    end

    PartyEnderJob.set(wait_until: party.ends_at).perform_later(party.id)
    party
  end

  def party_exists?
    if party.nil? || party.ended?
      flash[:error] = "That party does not exist"

      redirect_to(start_path)
      return
    end

    true
  end

  def party_has_device?
    if party.device_id.nil?
      if party.user_id == current_user&.id
        flash[:error] = "You have to add a device to the party"
        redirect_to select_device_path(code: code)
      else
        flash[:error] = "The party is being created. Try again"
        redirect_back(fallback_location: start_path)
      end
    end
  end

  def user_owns_party?
    redirect_to show_party_path(code: code) unless party.user_id == current_user&.id
  end

  def user_in_party?
    # TODO:maybe this query can be optimized
    if current_user
      user = current_user
    elsif session[:temporal_session].present?
      user = TemporalUser.find_by(id: session[:temporal_session])
    else
      user = nil
    end

    return true if user.present? && party.party_users.exists?(user: user)

    session[:temporal_session] = nil
    flash[:error] = "You have to join the party first"
    redirect_to join_party_path(code: code)
  end

  def rate_limit_exceeded
    report_error(RateLimitExceeded.new(request.remote_ip))
    flash[:error] = "Too many party creation requests. Please wait some minutes"
    redirect_to home_path
  end

  def user_is_premium?
    unless current_user.is_premium?
      flash[:error] = 'You need a premium Spotify account to create a party'
      redirect_to home_path
    end
  end

  def owner_is_premium?
    unless party.user.is_premium?
      flash[:error] = 'The party owner needs a premium Spotify account'
      redirect_to home_path
    end
  end

  def code
    @code ||= params.require(:code)
  end

  def party
    @party ||= Party.find_by(code: code)
  end

  def name
    @name ||= params.require(:name)
  end
end
