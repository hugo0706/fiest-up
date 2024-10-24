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

    before do 
      user_session = create(:session, user: user)
      session[:session_token] = user_session.session_token
    end

    it 'returns ok and redirects to the party' do
      post :party_device, params: params

      expect(party.reload.device_id).to eq(device_id)
      expect(response).to redirect_to(show_party_path(code: party.code))
    end

    context 'when party update raises an error' do
      before do
        allow_any_instance_of(Party).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'redirects to home_page' do
        post :party_device, params: params

        expect(response).to redirect_to(home_path)
      end
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
