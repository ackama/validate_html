module ValidateHTML
  class Railtie < ::Rails::Railtie
    initializer "html_validator.configure_rails_initialization" do |app|
      next unless ::ValidateHTML.configuration.environments.any? { |e| e.to_s == Rails.env }

      app.configure do
        config.middleware.use(::ValidateHTML::RackMiddleware)

        next unless config.respond_to?(:action_mailer)

        # run first to run before e.g. premailer, which does a parse-then-output step
        # and will make assumptions with the output that we may want to correct
        config.action_mailer.interceptors = [
          ::ValidateHTML::MailerObserver,
          *config.action_mailer.interceptors
        ]

        # and run again after
        config.action_mailer.observers = [
          *config.action_mailer.observers,
          ::ValidateHTML::MailerObserver
        ]

        # for completeness, this might be overkill
        config.action_mailer.preview_interceptors = [
          *config.action_mailer.preview_interceptors,
          ::ValidateHTML::MailerObserver
        ]
      end

      ::ActiveSupport::Notifications.subscribe(
        "transmit.action_cable",
        ::ValidateHTML::ActiveSupportNotificationHandler
      )
    end
  end
end
