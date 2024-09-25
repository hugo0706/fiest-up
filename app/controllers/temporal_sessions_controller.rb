# frozen_string_literal: true

class TemporalSessionsController < ApplicationController

  def create
    temporal_user = TemporalUser.create!(name: name)
    party = Party.find_by!(code: party_code)
    party.temporal_users << temporal_user
    session[:temporal_session] = temporal_user.id

    render json: {}, status: :created

  rescue ActiveRecord::RecordNotFound,
        ActiveRecord::RecordInvalid => e
    report_error(e)
    render json: {}, status: 422
  end

  def destroy
    session[:temporal_session] = nil

    render json: {}, status: :created
  end

  private

  def name
    params.require(:name)
  end

  def party_code
    params.require(:code)
  end
end
