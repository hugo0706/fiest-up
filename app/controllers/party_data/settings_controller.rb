# frozen_string_literal: true

module PartyData
  class SettingsController < ApplicationController
    before_action :party_exists?
    before_action :user_owns_party?

    def party_device
      @party.update!(device_id: device_id)

      flash[:notice] = "Party created succesfully!"
      redirect_to show_party_path(code: @party.code)
    rescue ActiveRecord::RecordInvalid => e
      report_error e
      flash[:error] = "There was an error creating the party"
      redirect_to home_path
    end

    def device_list
      devices = Spotify::Api::Playback::AvailableDevicesService.new(current_user.access_token).call
      devices = devices["devices"]&.map { |device| DevicePresenter.new(device) }
      render partial: "parties/device_list", locals: { devices: devices }
    rescue Spotify::ApiError => e
      report_error(e)
      render plain: "There was an error loading your devices, we are working on it"
    end

    private

    def user_owns_party?
      render json: {}, status: 401 unless @party.user_id == current_user&.id
    end

    def party_exists?
      @party = Party.find_by(code: party_code)
      render json: { error: "Party not found" }, status: :not_found unless @party
    end

    def party_code
      params.require(:code)
    end

    def device_id
      params.require(:device_id)
    end
  end
end
