class RefreshAccessTokenJob < ApplicationJob
  def perform(user_id)
    AccessTokenRefresherService.new(user_id).call
  rescue => e
    report_error(e)
  end
end