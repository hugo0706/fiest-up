# frozen_string_literal: true

module PartyData
  class SettingsController < ApplicationController
    before_action :party_exists?
    before_action :user_owns_party?

    def party_device
      @party.update!(device_id: device_id)
      
      render json: {}, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      report_error e
      render json: {}, status: 400
    end

    def device_list
      devices = Spotify::Api::AvailableDevicesService.new(current_user.access_token).call
      
      render json: devices, status: :ok
    end

    private

    def user_owns_party?
      render json: {}, status: 401 unless @party.user_id == current_user&.id
    end

    def party_exists?
      @party = Party.find_by(code: party_code)
      render json: { error: 'Party not found' }, status: :not_found unless @party
    end

    def party_code
      params.require(:code)
    end
    
    def device_id
      params.require(:device_id)
    end
  end
end
