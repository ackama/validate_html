require "bundler/setup"
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

    expect(app.middleware.to_a).to_not include(ValidateHTML::RackMiddleware)
    expect(app.config.action_mailer.interceptors).to be nil
    expect(app.config.action_mailer.observers).to be nil
    expect(app.config.action_mailer.preview_interceptors).to be nil
    expect(ActiveSupport::Notifications.notifier).to_not be_listening('transmit.action_cable')
  end
end
