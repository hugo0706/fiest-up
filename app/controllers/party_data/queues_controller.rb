# frozen_string_literal: true

module PartyData
  class QueuesController < ApplicationController
    before_action :party_exists?
    before_action :user_in_party?

    def add_song_to_queue
      song = FindOrCreateSongService.new(party_owner: @party.user, spotify_song_id: spotify_song_id).call

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
        user = TemporalUser.find_by(id: session[:temporal_session])
      else
        user = nil
      end

      return true if user.present? && @party.party_users.exists?(user: user)

      session[:temporal_session] = nil

      render json: { error: "User not in party" }, status: :not_found
    end
  end
end
