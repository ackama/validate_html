# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov' if ENV['COVERAGE']
require_relative '../lib/validate_html'

module SpecHelper
  def stub_config(**config)
    # we actually modify the config and set it back
    # with ValidateHTML.instance_variable_set(:@configuration, nil)
    # because this is easier
    config.each do |key, value|
      key = :"#{key.to_s.delete_suffix('?')}="

      ::ValidateHTML.configuration.send(key, value)
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SpecHelper
  config.before do
    ValidateHTML.instance_variable_set(:@configuration, nil)
    ValidateHTML.forget_messages
  end
end
