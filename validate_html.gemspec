# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'validate_html/version'

Gem::Specification.new do |spec|
  spec.name = 'validate_html'
  spec.version = ValidateHTML::VERSION
  spec.authors = ['Ackama']
  spec.email = ['opensource@ackama.com']

  spec.summary = 'Validate HTML files as they leave your app by rack or by mail or by turbo-stream'
  spec.homepage = 'https://github.com/ackama/validate_html'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
    spec.metadata['rubygems_mfa_required'] = 'true'
  end

  spec.files = Dir.glob('lib/**/{*,.*}') + %w[
    CHANGELOG.md
    Gemfile
    LICENSE.txt
    README.md
    validate_html.gemspec
  ]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'rake', '>= 12.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'yard'
  spec.add_dependency 'nokogiri'
  spec.add_development_dependency 'actionmailer'
  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'leftovers'
  spec.add_development_dependency 'mail'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'railties'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'spellr'
end
