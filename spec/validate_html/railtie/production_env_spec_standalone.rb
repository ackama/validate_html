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

  it 'can initialize with ActionMailer and nothing happens' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    app.initialize!

    expect(app.middleware.to_a).not_to include(ValidateHTML::RackMiddleware)
    expect(app.config.action_mailer.interceptors).to be_nil
    expect(app.config.action_mailer.observers).to be_nil
    expect(app.config.action_mailer.preview_interceptors).to be_nil
    expect(ActiveSupport::Notifications.notifier).not_to be_listening('transmit.action_cable')
  end
end
