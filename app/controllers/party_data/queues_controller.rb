# frozen_string_literal: true

module PartyData
  class QueuesController < ApplicationController
    before_action :party_exists?
    before_action :user_in_party?

    def add_song_to_queue
      party_owner = User.find(@party.user_id)
      song = Spotify::Api::TrackService.new(party_owner.access_token).call(spotify_song_id)
      parsed_song = SearchResultsPresenter.new(song).as_json

      song = Song.find_or_create_by!(spotify_song_id: parsed_song[:spotify_song_id]) do |s|
        s.name = parsed_song[:name].strip
        s.artists = parsed_song[:artists]
        s.image = parsed_song[:image]
        s.uri = parsed_song[:uri]
        s.duration = parsed_song[:duration]
      end

      PartySong.add_song_to_queue(party_id: @party.id, song_id: song.id)

      head :created
    rescue ActiveRecord::RecordInvalid, Spotify::ApiError => e
      report_error(e)
      render json: { error: "Invalid song" }, status: 404
    end

    private

    def spotify_song_id
      @spotify_song_id ||= params.require(:spotify_song_id)
    end

    def code
      @code ||= params.require(:code)
    end

    def query
      @query ||= params.require(:query)
    end

    def party_exists?
      @party = Party.find_by(code: code)
      render json: { error: "Party not found" }, status: :not_found unless @party
    end

    def user_in_party?
      # TODO:maybe this query can be optimized
      if current_user
        user = current_user
      elsif session[:temporal_session].present?
        user = TemporalUser.find(session[:temporal_session])
      else
        user = nil
      end

      return true if user.present? && @party.party_users.exists?(user: user)

      session[:temporal_session] = nil

      render json: { error: "User not in party" }, status: :not_found
    end
  end
end
