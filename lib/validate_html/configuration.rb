# frozen_string_literal: true

require 'tmpdir'
require 'pathname'

module ValidateHTML
  # Configuration attributes for ValidateHTML
  #
  # @see ValidateHTML.configure
  class Configuration
    # Set to false to not raise {InvalidHTMLError} by default
    #
    # Defaults to true
    #
    # @return [Boolean]
    # @see ValidateHTML.validate_html
    # @see ValidateHTML.raise_remembered_messages
    # @see #remember_messages
    attr_accessor :raise_on_invalid_html
    alias_method :raise_on_invalid_html?, :raise_on_invalid_html

    # Set to true to allow using {ValidateHTML.raise_remembered_messages}
    #
    # Defaults to false
    #
    # @return [Boolean]
    # @see ValidateHTML.raise_remembered_messages
    attr_accessor :remember_messages
    alias_method :remember_messages?, :remember_messages

    # Error messages to ignore
    # @return [Array<String, Regexp>]
    attr_reader :ignored_errors

    # App-relative paths to skip automatic validation
    # @return [Array<String, Regexp>]
    attr_reader :ignored_paths

    # The rails environments to initialize automatic validation
    #
    # Defaults to ["development", "test"]
    #
    # This won't take any effect if changed after the app is initialized
    #
    # @return [Array<String>]
    attr_accessor :environments

    def initialize
      @raise_on_invalid_html = true
      @ignored_errors = []
      @ignored_paths = []
      @environments = %w[development test]
      @remember_messages = false
      @snapshot_path = nil
    end

    # The directory to use for snapshots with invalid HTML
    #
    # @default
    #   if Rails is present, this will default to "tmp/invalid_html"
    #   otherwise it will default to a new directory created with Dir.mktmpdir
    #
    # @!attribute snapshot_path [rw]
    # @return [Pathname]
    # @param [Pathname, String] path
    def snapshot_path
      @snapshot_path ||= defined?(::Rails) ? ::Rails.root.join('tmp/invalid_html') : ::Pathname.new(::Dir.mktmpdir)
    end

    def snapshot_path=(path)
      @snapshot_path = path.is_a?(Pathname) ? path : ::Pathname.new(path)
    end

    def ignored_errors=(errors)
      @ignored_errors = errors
      @ignored_errors_re = nil
    end

    def ignored_paths=(paths)
      @ignored_paths = paths
      @ignored_paths_re = nil
    end

    # @!visibility private
    def ignored_errors_re
      @ignored_errors_re ||= list_to_re(ignored_errors)
    end

    # @!visibility private
    def ignored_paths_re
      @ignored_paths_re ||= list_to_re(ignored_paths)
    end

    private

    def list_to_re(list)
      Regexp.union(list.map { |i| i.is_a?(Regexp) ? i : /\A#{Regexp.escape(i)}\z/ })
    end
  end
end
