# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Party, type: :model do
  describe 'destroy callbacks' do
    let(:party) { create(:party, user: creator) }
    let!(:party_user) { create(:party_user, party: party, user: user) }
    let(:creator) { create(:user) }

    context 'when user is a spotify user' do
      let(:user) { create(:user) }

      it 'deletes its party user, but not the user' do
        expect { party.destroy }.to not_change { User.count }
          .and change { PartyUser.count }.from(1).to(0)
      end
    end

    context 'when user is a temporal user' do
      let(:user) { create(:temporal_user) }

      it 'deletes its party user, and the user' do
        expect { party.destroy }.to change { TemporalUser.count }.from(1).to(0)
          .and change { PartyUser.count }.from(1).to(0)
      end
    end
  end

  describe 'creation' do
    let(:user) { create(:user) }
    let(:valid_attributes) { { name: 'Party1', code: 'ABCDEF', user: user } }

    it 'creates a valid party with correct attributes' do
      party = Party.new(valid_attributes)
      expect(party).to be_valid
    end

    it 'is invalid without a name' do
      invalid_attributes = valid_attributes.merge(name: '')
      party = Party.new(invalid_attributes)
      expect(party).not_to be_valid
      expect(party.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a non-unique name scoped to user' do
      create(:party, name: 'Party1', user: user)
      duplicate_party = Party.new(valid_attributes)
      expect(duplicate_party).not_to be_valid
      expect(duplicate_party.errors[:name]).to include("has already been taken")
    end

    it 'is invalid with a name longer than 15 characters' do
      invalid_attributes = valid_attributes.merge(name: 'ThisNameIsWayTooLong')
      party = Party.new(invalid_attributes)
      expect(party).not_to be_valid
      expect(party.errors[:name]).to include("is too long (maximum is 15 characters)")
    end

    it 'is invalid without a code' do
      invalid_attributes = valid_attributes.merge(code: '')
      party = Party.new(invalid_attributes)
      expect(party).not_to be_valid
      expect(party.errors[:code]).to include("can't be blank")
    end

    it 'is invalid with a non-unique code' do
      create(:party, code: 'ABCDEF', user: user)
      duplicate_party = Party.new(valid_attributes)
      expect(duplicate_party).not_to be_valid
      expect(duplicate_party.errors[:code]).to include("has already been taken")
    end

    it 'is invalid with a code that is not 6 characters long' do
      invalid_attributes = valid_attributes.merge(code: 'ABCDE')
      party = Party.new(invalid_attributes)
      expect(party).not_to be_valid
      expect(party.errors[:code]).to include("is the wrong length (should be 6 characters)")
    end
  end
end
