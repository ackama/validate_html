require "bundler/setup"
require "validate_html"

module SpecHelper
  def stub_config(**config)
    config.each do |key, value|
      key = key.to_s.delete_suffix('?').to_sym

      allow(::ValidateHTML.configuration).to receive(key).and_return(value)
      next unless ValidateHTML.configuration.respond_to?(:"#{key}?")

      allow(::ValidateHTML.configuration).to receive(:"#{key}?").and_return(value)
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SpecHelper
  config.before do
    ValidateHTML.forget_messages
  end
end
