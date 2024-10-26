# frozen_string_literal: true

module PartyData
  class SettingsController < ApplicationController
    before_action :party_exists?
    before_action :user_owns_party?

    def party_device
      Spotify::Api::Playback::TransferPlaybackService.new(@party.user.access_token, device_id, play: false).call
      @party.update!(device_id: device_id)

      flash[:notice] = "Party created succesfully!"
      render json: { redirect_url: show_party_path(code: @party.code) }, status: :ok
    rescue Spotify::ApiError, ActiveRecord::RecordInvalid => e
      report_error e
      flash[:error] = "There was an error creating the party"
      render json: { redirect_url: home_path }, status: :unprocessable_entity
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
