module ValidateHTML
  module MailerObserver
    class << self
      # Validate the HTML of outgoing mail
      #
      # This can be used standalone or with ActionMailer as interceptor, or an observer, or a preview_interceptor
      #
      # @param email [Mail]
      # @return [Mail] unmodified from the passed in param
      # @raise {InvalidHTMLError} if the html_part of the email is invalid and {Configuration#raise_on_invalid_html} is true
      # @see ValidateHTML.validate_html
      def perform(email)
        html_part = email.html_part
        return email unless html_part

        ValidateHTML.validate_html(
          html_part.body.raw_source,
          content_type: html_part.content_type,
          name: "email #{email.subject}"
        )

        email
      end

      alias delivering_email perform
      alias delivered_email perform
      alias previewing_email perform
    end
  end
end
