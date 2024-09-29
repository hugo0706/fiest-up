class PartyDataController < ApplicationController
  def update_current_song
    @song = 'cancion'
    
    @party.broadcast_replace_to "party_#{@party.id}_currently_playing", target: "currently_playing", partial: "party_data/current_song", locals: { song: @song }
    
    respond_to do |format|
      format.turbo_stream # Handles Turbo Stream requests
      format.html { render html: "This action requires a Turbo request." } # Fallback for HTML requests
    end
  end
end
