# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartySong, type: :model do
  let!(:party) { create(:party) }
  let!(:song) { create(:song) }

  describe 'validations' do
    it 'validates uniqueness of position scoped to party_id' do
      party_song1 = PartySong.create!(party_id: party.id, song_id: song.id, position: 1)
      expect {
        PartySong.create!(party_id: party.id, song_id: song.id, position: 1)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '.add_song_to_queue' do
    context 'when there are no existing songs in the queue' do
      it 'adds the song with position 1' do
        PartySong.add_song_to_queue(party_id: party.id, song_id: song.id)
        expect(PartySong.where(party_id: party.id).first.position).to eq(1)
      end
    end

    context 'when there are existing songs in the queue' do
      let!(:existing_song) { create(:party_song, party_id: party.id, song_id: song.id, position: 1) }

      it 'adds the song with the next position' do
        PartySong.add_song_to_queue(party_id: party.id, song_id: song.id)
        expect(PartySong.where(party_id: party.id).order(:position).last.position).to eq(2)
      end
    end

    context 'when a position collision occurs' do
      let!(:existing_song) { create(:party_song, party_id: party.id, song_id: song.id, position: 1) }

      before do
        allow(PartySong).to receive(:where).and_return([ double({ position: 0 }) ])
      end

      it 'retries adding the song up to the retry limit' do
        expect {
          PartySong.add_song_to_queue(party_id: party.id, song_id: song.id)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
