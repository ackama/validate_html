# frozen_string_literal: true

require 'tmpdir'
require 'pathname'

module ValidateHTML
  class Configuration

    attr_accessor :raise_on_invalid_html
    alias raise_on_invalid_html? raise_on_invalid_html
    undef raise_on_invalid_html

    attr_accessor :remember_messages
    alias remember_messages? remember_messages
    undef remember_messages

    attr_accessor :ignored_errors
    attr_accessor :ignored_paths
    attr_accessor :environments

    def initialize
      @raise_on_invalid_html = true
      @ignored_errors = []
      @ignored_paths = []
      @environments = %w[development test]
      @remember_messages = false
      @snapshot_path = nil
    end

    def snapshot_path
      @snapshot_path ||= defined?(::Rails) ? ::Rails.root.join('tmp/invalid_html') : ::Pathname.new(::Dir.mktmpdir)
    end

    def snapshot_path=(path)
      @snapshot_path = path.is_a?(Pathname) ? path : ::Pathname.new(path)
    end
  end
end
