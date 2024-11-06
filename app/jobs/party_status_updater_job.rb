# frozen_string_literal: true

class PartyStatusUpdaterJob < ApplicationJob
  def perform(party_id:)
    @party = Party.find(party_id)
    unless @party.ended?
      if @party.stopped?
        if status["is_playing"]
          @party.update(stopped: false)
          reconcile_spotify_state
          UpdateCurrentlyPlayingService.new(party: @party).call
        end
      else
        if status["is_playing"]
          reconcile_spotify_state
        else
          @party.update(stopped: true) if status.present?
          @party.currently_playing_party_song.update(is_playing: false) if status["progress_ms"] == 0
          next_song_job.destroy
        end
        UpdateCurrentlyPlayingService.new(party: @party).call
      end

      PartyStatusUpdaterJob.set(wait: 5.seconds).perform_later(party_id: @party.id)
    end
  rescue => e
    report_error(e)
  end

  private
  
  def reconcile_spotify_state
    if next_song_job.present?
      handle_unexpected_user_action
    else
      job = PlayNextSongJob.set(wait: pending_song_time - next_song_margin).perform_later(current_party_song: current_party_song)
      @party.update(next_song_job_id: job.provider_job_id)
    end
  end

  def handle_unexpected_user_action
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

  def time_gap
    estimated_schedule = Time.now + pending_song_time - next_song_margin
    @time_gap ||= (estimated_schedule - next_song_job.scheduled_at).abs
  end
  
  def pending_song_time
    @pending_song_time ||= ((status["item"]["duration_ms"] - status["progress_ms"])/ 1000).seconds
  end

  def reenqueue_job_with_song(party_song, wait)
    next_song_job.destroy
    job = PlayNextSongJob.set(wait: wait - next_song_margin).perform_later(current_party_song: party_song)
    @party.update(next_song_job_id: job.provider_job_id)
  end

  def current_party_song
    @party.currently_playing_party_song
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
