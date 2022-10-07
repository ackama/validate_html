require 'rails'
require_relative '../../lib/validate_html/railtie'
require 'action_mailer/railtie'

RSpec.describe ValidateHTML::Railtie do
  let(:app) do
    stub_const('MyApp', Class.new(Rails::Application))

    MyApp.instance
  end

  it 'can initialize with ActionMailer' do
    app.initialize!
    expect(app.middleware.to_a).to include(ValidateHTML::RackMiddleware)
    expect(app.config.action_mailer.interceptors.first).to be ValidateHTML::MailerObserver
    expect(app.config.action_mailer.observers.last).to be ValidateHTML::MailerObserver
    expect(app.config.action_mailer.preview_interceptors.last).to be ValidateHTML::MailerObserver

    expect(ActiveSupport::Notifications.notifier).to be_listening('transmit.action_cable')
    allow(::ValidateHTML::ActiveSupportNotificationHandler).to receive(:call)
    payload = { data: '<html>', channel_class: 'Turbo::StreamsChannel'}
    ActiveSupport::Notifications.instrument('transmit.action_cable', payload) { nil }
    expect(::ValidateHTML::ActiveSupportNotificationHandler).to have_received(:call)
      .with(*anything, *anything, *anything, *anything, payload)
  end
end
