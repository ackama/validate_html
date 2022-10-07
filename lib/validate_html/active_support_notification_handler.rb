# frozen_string_literal: true

module ValidateHTML
  # Validate HTML from Turbo::StreamsChannel
  # as called by ActiveSupport::Notifications.instrument
  module ActiveSupportNotificationHandler
    # Validate HTML from Turbo::StreamsChannel
    # as called by ActiveSupport::Notifications.instrument
    #
    # @option payload :channel_class [String] if this is Turbo::StreamsChannel the validation will happen
    # @option payload :data [String] the html to validate
    # @return [Boolean] true if there are no validation errors
    # @raise {InvalidHTMLError} if the data of the payload is invalid
    #   and {Configuration#raise_on_invalid_html} is true
    # @see ValidateHTML.validate_html
    def self.call(_name, _start, _finish, _id, payload)
      return unless payload && payload[:channel_class] == 'Turbo::StreamsChannel'

      ValidateHTML.validate_html(payload[:data])
    end
  end
end
