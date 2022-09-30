module ValidateHTML
  module MailerObserver
    class << self
      def perform(message)
        html_part = message.html_part
        return message unless html_part

        HTMLValidator.validate_html(
          html_part.body.raw_source,
          content_type: html_part.content_type,
          name: message.subject
        )

        message
      end

      alias delivering_email perform
      alias delivered_email perform
      alias previewing_email perform
    end
  end
end
