# frozen_string_literal: true

module PartyData
  class SearchController < ApplicationController
    before_action :party_exists?
    before_action :user_in_party?

    def search
      party_owner = User.find(@party.user_id)
      songs = Spotify::Api::SearchService.new(party_owner.access_token).call(query)
      parsed_songs = songs.map { |song| SearchResultsPresenter.new(song).as_json }
      
      respond_to do |format|
        format.html { render partial: "party_data/search_results", locals: { songs: parsed_songs, party_code: @party.code } }
        format.json { render json: parsed_songs, status: :ok } 
      end
      
    rescue Spotify::ApiError => e
      report_error(e)
      head 500
    end

    private

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
