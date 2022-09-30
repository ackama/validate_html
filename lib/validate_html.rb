# frozen_string_literals: true

require_relative "validate_html/version"
require_relative "validate_html/configuration"
require "nokogiri"

module ValidateHTML
  class Error < StandardError; end
  class InvalidHTMLError < Error; end
  class NotRememberingMessagesError < Error; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration if block_given?
    end

    def validate_html(body, content_type: nil, name: nil, raise_on_invalid_html: configuration.raise_on_invalid_html?)
      return true if body.empty?

      doc = parse_html(body, find_encoding(content_type))

      errors = filter_errors(doc.errors)

      return true if errors.empty?

      handle_errors(name, doc, body, errors, raise_on_invalid_html)

      false
    end

    def remembered_messages
      @remembered_messages ||= []
    end

    def forget_messages
      @remembered_messages = []
    end

    def raise_remembered_messages
      fail NotRememberingMessagesError unless configuration.remember_messages?
      return if remembered_messages.blank?

      messages = remembered_messages
      forget_messages
      fail InvalidHTMLError, messages.join("\n---\n")
    end

    private

    def filter_errors(errors)
      errors.reject do |error|
        error = error.to_s
        configuration.ignored_errors.any? do |permitted|
          permitted === error
        end
      end
    end

    def handle_errors(name, doc, body, errors, raise_on_invalid_html)
      configuration.snapshot_path.mkpath
      path = configuration.snapshot_path.join("#{::Digest::SHA1.hexdigest(body)}.html")
      path.write(body)

      message = <<~ERROR
        Invalid html#{" from #{name}" if name}
        Parsed using #{doc.class}

        #{errors.join("\n")}

        document saved at: #{path}"
      ERROR

      remembered_messages << message if configuration.remember_messages?

      fail InvalidHTMLError, message if raise_on_invalid_html

      warn message
    end

    def parse_html(body, encoding)
      case body
      when /\A\s*<!doctype html>/i
        ::Nokogiri::HTML5.parse(body, nil, encoding, max_errors: -1)
      when /\A\s*<(!doctype|html)/i
        ::Nokogiri::HTML4.parse(
          body,
          nil,
          encoding,
          ::Nokogiri::XML::ParseOptions::DEFAULT_HTML | ::Nokogiri::XML::ParseOptions::STRICT
        )
      else
        ::Nokogiri::HTML5.fragment(body, encoding, max_errors: -1)
      end
    end

    def find_encoding(content_type)
      return unless content_type

      parts = content_type.split(/;\s*/)
      parts.find { |part| part.start_with?("charset=") }&.delete_prefix("charset=")
    end
  end
end

require_relative "validate_html/railtie" if defined?(::Rails::Railtie)
