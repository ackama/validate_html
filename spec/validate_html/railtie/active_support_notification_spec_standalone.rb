require "bundler/setup"
require 'rails'
require 'spec_helper'

RSpec.describe ValidateHTML::Railtie do
  let(:app) { Class.new(Rails::Application).instance }

  it 'can initialize with ActionMailer' do
    app.initialize!

    expect(ActiveSupport::Notifications.notifier).to be_listening('transmit.action_cable')
    allow(::ValidateHTML::ActiveSupportNotificationHandler).to receive(:call)
    payload = { data: '<html>', channel_class: 'Turbo::StreamsChannel'}
    ActiveSupport::Notifications.instrument('transmit.action_cable', payload) { nil }
    expect(::ValidateHTML::ActiveSupportNotificationHandler).to have_received(:call)
      .with(*anything, *anything, *anything, *anything, payload)
  end
end
