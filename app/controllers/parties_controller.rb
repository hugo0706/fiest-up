# frozen_string_literal: true

class PartiesController < ApplicationController
  before_action :authorize, only: [ :create, :index ]
  before_action :user_in_party?, only: :show

  # TODO: what happens if user is premium but changes to free?
  class RetriesDepleted < StandardError; end
  class PartyAlreadyExists < StandardError; end

  PARTY_CREATION_RETRIES = 3

  def create
    retries = 0
    code = nil
    party = nil
    name = create_party_params

    loop do
      raise RetriesDepleted if retries >= PARTY_CREATION_RETRIES
      code = SecureRandom.hex(3)

      party = Party.create(user: current_user, name: name, code: code)

      raise PartyAlreadyExists if party.errors[:name].present?

      break if party.valid?

      retries += 1
    end

    redirect_to show_party_path(code)
  rescue RetriesDepleted,
        PartyAlreadyExists => e

    report_error(e)
    redirect_to home_path
  end

  def join
    party = Party.find_by(code: code)

    if party.nil?
      flash[:error] = "That party does not exist"
      redirect_to start_path
      return
    end

    if logged_in?
      party.users << current_user
      redirect_to show_party_path(code: code)
    else
      session[:joining_party_code] = code
      @code = code
      render "non_logged_join"
    end
  end

  def show
  end

  def index
  end

  private

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

  def create_party_params
    params.require(:name)
  end

  def code
    params.require(:code)
  end
end
