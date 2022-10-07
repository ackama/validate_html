require "bundler/setup"
require 'rails'
require 'spec_helper'

RSpec.describe ValidateHTML::Railtie do
  let(:app) do
    Class.new(Rails::Application).instance
  end

  it 'can initialize without ActionMailer' do
    expect(defined?(ActionMailer)).to be nil

    app.initialize!
    expect(app.middleware.to_a).to include(ValidateHTML::RackMiddleware)
    expect(ActiveSupport::Notifications.notifier).to be_listening('transmit.action_cable')
  end
end
