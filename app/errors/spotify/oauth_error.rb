# frozen_string_literal: true

class Spotify::OauthError < StandardError
  attr_reader :status, :body, :message

  def initialize(message: "Spotify OAuth Error", body: nil, status: nil)
    @status = status
    @body = body
    super(message)
  end
end
