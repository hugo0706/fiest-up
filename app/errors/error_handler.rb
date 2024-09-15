# frozen_string_literal: true

module ErrorHandler
  def report_error(error)
    Rails.error.report(error)
  end
end
