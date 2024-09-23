# frozen_string_literal: true

class PartiesController < ApplicationController
  before_action :authorize, only: [ :create, :index ]
  
  class RetriesDepleted < StandardError; end
  class PartyAlreadyExists < StandardError; end
  
  PARTY_CREATION_RETRIES = 3

  def create
    retries = 1
    code = nil
    party = nil
    name = create_party_params

    loop do
      raise RetriesDepleted if retries > PARTY_CREATION_RETRIES
      code = SecureRandom.hex(3)

      party = Party.create(user: current_user, name: name, code: code)

      break if party.present?
      retries += 1
    end

    raise PartyAlreadyExists, party.errors.to_a if party.errors.present?

    redirect_to show_party_path(code)
  rescue RetriesDepleted,
        PartyAlreadyExists => e
    report_error(e)
    redirect_to home_path
  end

  def join
  end

  def show
    @party = Party.find_by(code: params[:code])
  end

  def index
  end

  private

  def create_party_params
    params.require(:name)
  end
end
