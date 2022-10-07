# frozen_string_literal: true

require 'bundler/setup'
require 'rails'
require 'spec_helper'
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
  end
end
