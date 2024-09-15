# frozen_string_literal: true

class ErrorReporter
  def report(error, handled:, severity:, context:, source: nil)
    puts "Reporting #{error} - #{error.cause} - #{context}"
    Rails.logger.error(build_log_message(error, handled, severity, context, source))
  end

  private

  def build_log_message(error, handled, severity, context, source)
    <<~MESSAGE
      [#{Time.now}] #{severity.upcase}: #{error.message}
        Error: #{error.class}
        Handled: #{handled}
        Context: #{context}
        Source: #{source || 'Unknown'}
        Cause: [#{error.cause.class}] #{error.cause}
        Backtrace:
          | #{error.backtrace&.take(8)&.join("\n\t| ") || '| No backtrace available'}
    MESSAGE
  end
end
Rails.error.subscribe(ErrorReporter.new)
