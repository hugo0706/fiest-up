# frozen_string_literal: true

class SessionExpirerJob < ApplicationJob
  def perform()
    Session.where('expires_at < ?', Time.now).destroy_all
  rescue => e
    report_error(e)
  end
end
