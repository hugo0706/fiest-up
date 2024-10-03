# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserCreatorService do
  subject { described_class.new(user_info) }

  let(:spotify_id) { "spotify_id" }
  let(:user_info) do
    {
     spotify_id: spotify_id,
     email: "user@mail.com",
     username: "user",
     profile_url: "https://open.spotify.com/user/username",
     product: "premium",
     access_token: "mock_access_token",
     refresh_token: "mock_refresh_token",
     access_token_expires_at: Time.now
    }
  end

  describe '#call' do
    it 'creates the user and returns it' do
      result = nil
      expect { result = subject.call }.to change { User.count }.from(0).to(1)
      expect(result).to eq(User.find_by(spotify_id: spotify_id))
    end

    context 'when the user created is invalid'  do
      before { allow(User).to receive(:create!).and_raise(ActiveRecord::RecordInvalid) }

      it 'raises InvalidUserError' do
        expect { subject.call }.to raise_error(described_class::InvalidUserError)
      end
    end
  end
end
