class Spotify::ApiError < StandardError
  attr_reader :status, :body

  def initialize(message: "Spotify Api Error", body: nil, status: nil)
    @status = status
    @body = body
    super(message)
  end
end