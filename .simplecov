# frozen_string_literal: true

SimpleCov.enable_coverage(:branch)
SimpleCov.root __dir__
SimpleCov.add_filter '/spec/'
SimpleCov.add_filter 'lib/validate_html/version.rb' # it's already loaded?
SimpleCov.track_files 'lib/**/*.rb'

if ENV.fetch('SIMPLECOV_COMMAND_NAME', false)
  SimpleCov.print_error_status = false
  SimpleCov.formatter SimpleCov::Formatter::SimpleFormatter
  SimpleCov.minimum_coverage 0

  SimpleCov.command_name ENV.fetch('SIMPLECOV_COMMAND_NAME', 'RSpec')
else
  SimpleCov.print_error_status = true
  SimpleCov.minimum_coverage line: 100, branch: 100

  require 'simplecov-console'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])

end

SimpleCov.start
