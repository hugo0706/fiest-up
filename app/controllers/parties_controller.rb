# frozen_string_literal: true

class PartiesController < ApplicationController
  before_action :authorize, only: [ :create, :index, :select_device, :settings, :start ]
  before_action :party_exists?, only: [ :show, :join, :select_device, :settings, :start ]
  before_action :party_has_device?, only: [ :show, :join, :settings, :start ]
  before_action :user_in_party?, only: :show
  before_action :user_owns_party?, only: [ :settings, :select_device, :start ]

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
    PartyStatusUpdaterJob.set(wait: 15.seconds).perform_later(party_id: party.id)

    party.update(started: true)
    UpdateCurrentlyPlayingService.new(party: party).call
    head :ok
  end

  def resume
    Spotify::Api::Playback::TransferPlaybackService.new(party.user.access_token, party.device_id, play: false).call
    if party.currently_playing_song
      Spotify::Api::Playback::StartService.new(party.user.access_token, party.device_id).call
    elsif party.queue_count > 0
      party_song_to_play = party.party_songs.where(next_song: true).first
      PlaySongAndEnqueueNextService.new(party_song: party_song_to_play, party: party).call
    end

    party.update(stopped: false)
    UpdateCurrentlyPlayingService.new(party: party).call
    head :ok
  end

  def settings
  end

  def select_device
    @devices = Spotify::Api::Playback::AvailableDevicesService.new(current_user.access_token).call
    @devices = @devices["devices"]&.map { |device| DevicePresenter.new(device) }
  rescue Spotify::ApiError => e
    report_error(e)
    flash[:error] = "There was an error, try again"
    redirect_to home_path
  end

  def index
  end

  private

  def create_party_with_random_code
    retries = 0
    random_code = nil
    party = nil

    loop do
      raise RetriesDepleted if retries >= PARTY_CREATION_RETRIES
      random_code = SecureRandom.hex(3)

      party = Party.create(user: current_user, name: name, code: random_code)

      raise PartyAlreadyExists if party.errors[:name].present?

      break if party.valid?

      retries += 1
    end

    party
  end

  def party_exists?
    if party.nil?
      flash[:error] = "That party does not exist"

      redirect_back(fallback_location: start_path)
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
      user = TemporalUser.find(session[:temporal_session])
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
