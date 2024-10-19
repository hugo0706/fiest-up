# frozen_string_literal: true

module RetriableRequest
  extend ActiveSupport::Concern

  def with_retries(on: [], times: 3)
    response = nil
    
    times.times do
      response = yield
      break unless on.include?(response.status)
    end
    response
  end
end
