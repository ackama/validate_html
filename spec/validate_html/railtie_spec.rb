require 'rails'
require_relative '../../lib/validate_html/railtie'

RSpec.describe ValidateHTML::Railtie do
  it 'can initialize without ActionMailer' do
    system("rspec #{__dir__}/railtie_without_action_mailer_spec_standalone.rb")
  end

  it 'can initialize with ActionMailer' do
    system("rspec #{__dir__}/railtie_with_action_mailer_spec_standalone.rb")
  end

  it 'can notify the notifier handler' do
    system("rspec #{__dir__}/railtie_active_support_notification_spec_standalone.rb")
  end
end
