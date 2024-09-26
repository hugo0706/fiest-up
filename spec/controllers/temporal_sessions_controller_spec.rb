# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TemporalSessionsController, type: :controller do
  describe 'POST #create' do
    let(:params) do
      {
        name: name,
        code: code
      }
    end
    let(:code) { 'party_code' }
    let(:name) { 'party' }
    context 'when the party exists' do
      let!(:party) { create(:party, code: code) }

      it 'creates a temporal user associated to the party and stores the session' do
        expect { post :create, params: params }.to change { TemporalUser.count }.from(0).to(1)

        expect(party.party_users.exists?(user: TemporalUser.last)).to eq(true)
        expect(session[:temporal_session]).to eq(TemporalUser.last.id)
      end
    end

    context 'when the party does not exist' do
      it 'reports the error and returns 422' do
        expect(controller).to receive(:report_error)

        post :create, params: params

        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE #destroy' do
  end
end
