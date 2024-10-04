# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartyData::SettingsController, type: :controller do
  let(:device_id) { 'device_id' }
  let(:party) { create(:party, user: user) }
  let(:user) { create(:user) }

  describe "POST #party_device" do
    let(:params) do
      {
        code: party.code,
        device_id: device_id
      }
    end

    before { session[:user_id] = user.id }

    it 'returns ok and updates the party' do
      post :party_device, params: params
      expect(party.reload.device_id).to eq(device_id)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #device_list" do
    let(:params) do
      {
        code: party.code
      }
    end

    let(:device_list) { { 'devices': [] }.to_json }
    let(:available_devices_service) { double('Spotify::Api::AvailableDevicesService') }

    before do
      session[:user_id] = user.id
      allow(Spotify::Api::AvailableDevicesService).to receive(:new).with(user.access_token)
        .and_return(available_devices_service)
      allow(available_devices_service).to receive(:call).and_return(device_list)
    end

    it 'returns a json containing the devices' do
      get :device_list, params: params

      expect(response.status).to eq(200)
      expect(response.body).to eq(device_list)
    end
  end
  
  describe "callbacks" do
    context 'requires party to exist' do
      it 'returns 404 not found' do
        get :device_list, params: { code: 'fake' }
        
        expect(response.status).to eq(404)
      end
    end
    
    context 'requires user to be owner of the party' do
      it 'returns 401' do
        get :device_list, params: { code: party.code }
        
        expect(response.status).to eq(401)
      end
    end
  end
end
