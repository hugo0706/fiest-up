# frozen_string_literal: true

class PartyStatusUpdaterJob < ApplicationJob  
  def perform(party_id:)
    @party = Party.find(party_id)
    if @party.stopped?
      if status["is_playing"]
        @party.update(stopped: false)
        handle_unexpected_user_action
        UpdateCurrentlyPlayingService.new(party: @party).call
      end
    else
      if status["is_playing"]
        handle_unexpected_user_action
      else
        @party.update(stopped: true) if status.present?
      end
      UpdateCurrentlyPlayingService.new(party: @party).call
    end
    
    PartyStatusUpdaterJob.set(wait: 5.seconds).perform_later(party_id: @party.id)
  rescue => e
    report_error(e)
  end
  
  private
  
  def handle_unexpected_user_action
    pending_song_time, time_gap  = calculate_times
    
    if song_changed_by_user?
      song = FindOrCreateSongService.new(party_owner: @party.user, spotify_song_id: status["item"]["id"]).call
      user_song = nil
      ActiveRecord::Base.transaction do
        current_party_song.update(is_playing: false)
        user_song = PartySong.create(party: @party, song: song, is_playing: true, played: true, position: @party.party_songs.count + 1)
      end
      reenqueue_job_with_song(user_song, pending_song_time) if user_song
    elsif time_gap > 3
      reenqueue_job_with_song(current_party_song, pending_song_time)
    end
  end
  
  def calculate_times
    scheduled = next_song_job.scheduled_at
    pending_song_time = ((status["item"]["duration_ms"] - status["progress_ms"])/ 1000).seconds
    estimated_schedule = Time.now + pending_song_time - next_song_margin
    time_gap = (estimated_schedule - scheduled).abs
    [pending_song_time, time_gap]
  end
  
  def reenqueue_job_with_song(party_song, wait)
    next_song_job.destroy
    job = PlayNextSongJob.set(wait: wait - next_song_margin ).perform_later(current_party_song: party_song)
    @party.update(next_song_job_id: job.provider_job_id)
  end
  
  def current_party_song
    global_id_string ||= next_song_job.arguments["arguments"].first["current_party_song"]["_aj_globalid"]
    @current_party_song ||= GlobalID::Locator.locate(global_id_string)
  end
  
  def song_changed_by_user?
    status["item"]["id"] != current_party_song.song.spotify_song_id
  end
  
  def status
    @status ||= Spotify::Api::Playback::CurrentlyPlayingService.new(@party.user.access_token).call
  end
  
  def next_song_job
    @next_song_job ||= SolidQueue::Job.find_by(id: @party.next_song_job_id)
  end
  
  def next_song_margin
    PlaySongAndEnqueueNextService::NEXT_SONG_MARGIN
  end
  
end
