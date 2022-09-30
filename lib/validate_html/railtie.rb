module ValidateHTML
  class Railtie < ::Rails::Railtie
    initializer "html_validator.configure_rails_initialization" do |app|
      if ValidateHTML.configuration.environments.any? { |e| e.to_s == Rails.env }
        require_relative "rack_middleware"
        require_relative "mailer_observer"

        app.configure do
          config.middleware.use(ValidateHTML::RackMiddleware)

          # run first to run before premailer, which does a parse-then-output step
          # and will make assumptions with the output that we may want to correct
          config.action_mailer.interceptors = [
            ValidateHTML::MailerObserver,
            *config.action_mailer.interceptors
          ]

          # and run again after
          config.action_mailer.observers = [
            ValidateHTML::MailerObserver,
            *config.action_mailer.observers
          ]

        end


        ActiveSupport::Notifications.subscribe("transmit.action_cable") do |_name, _start, _finish, _id, payload|
          ValidateHTML.validate_html(payload[:data]) if payload[:channel_class] == "Turbo::StreamsChannel"
        end
      end
    end
  end
end
