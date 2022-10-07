module ValidateHTML
  module ActiveSupportNotificationHandler
    def self.call(_name, _start, _finish, _id, payload)
      return unless payload && payload[:channel_class] == "Turbo::StreamsChannel"

      ValidateHTML.validate_html(payload[:data])
    end
  end
end
