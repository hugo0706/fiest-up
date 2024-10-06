# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessTokenRefresherService do
  subject { described_class.new(user.id) }

  let(:user) { create(:user) }
  let(:user_scopes) { %w[user-read-private user-read-email user-read-playback-state] }
  let(:expires_in) { 3600 }
  let(:oauth_data) do
    {
      "access_token" => "mock_access_token",
      "token_type" => "Bearer",
      "expires_in" => expires_in,
      "refresh_token" => "mock_refresh_token",
      "scope" => "#{user_scopes.join(' ')}"
    }
  end


  describe '#call' do
    let(:refresh_token_service) { double('Spotify::Oauth::RefreshTokenService') }

    before do
      allow(Spotify::Oauth::RefreshTokenService).to receive(:new).with(user.refresh_token)
        .and_return(refresh_token_service)
      allow(refresh_token_service).to receive(:call)
        .and_return(oauth_data)
    end

    it 'creates the user and enqueues a RefreshAccessTokenJob' do
      result = nil
      refresh_in = (oauth_data["expires_in"].to_i * 0.9).seconds
      Timecop.freeze(Time.now) do
        expect { result = subject.call }.to change { user.reload.access_token }
                                        .and have_enqueued_job(RefreshAccessTokenJob).with(user.id).at(refresh_in.from_now)
      end
    end

    context 'when the user update fails'  do
      before { allow_any_instance_of(User).to receive(:update!).and_raise(ActiveRecord::RecordInvalid) }

      it 'raises RefreshTokenError' do
        expect { subject.call }.to raise_error(described_class::RefreshTokenError)
      end
    end
    
    context 'when the refresh token request to spotify fails' do
      before do
        allow(refresh_token_service).to receive(:call)
          .and_raise(Spotify::Oauth::RefreshTokenService::Error)
      end
      it 'raises RefreshTokenError' do
        expect { subject.call }.to raise_error(described_class::RefreshTokenError)
      end
    end
  end
end
