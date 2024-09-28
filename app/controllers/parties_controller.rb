# frozen_string_literal: true

class PartiesController < ApplicationController
  before_action :authorize, only: [ :create, :index ]
  before_action :user_in_party?, only: :show

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

    flash[:notice] = "Party created succesfully"
    redirect_to show_party_path(party.code)
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
    party = Party.find_by(code: code)

    if party.nil?
      flash[:error] = "That party does not exist"

      redirect_back(fallback_location: start_path)
      return
    end

    if logged_with_spotify?
      session[:joining_party_code] = nil
      party.users << current_user
      flash[:notice] = "Party joined!"
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

  def code
    @code ||= params.require(:code)
  end

  def party
    @party ||= Party.find_by(code: code)
  end

  def user_in_party?
    if current_user
      user = current_user
    elsif session[:temporal_session].present?
      user = TemporalUser.find(session[:temporal_session])
    else
      user = nil
    end

    return true if user.present? && party.party_users.exists?(user: user)

    flash[:error] = "You have to join the party first"
    redirect_to join_party_path(code: code)
  end

  def rate_limit_exceeded
    report_error(RateLimitExceeded.new(request.remote_ip))
    flash[:error] = "Too many party creation requests. Please wait some minutes"
    redirect_to home_path
  end

  def name
    @name ||= params.require(:name)
  end
end
