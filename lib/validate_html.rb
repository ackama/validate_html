# frozen_string_literals: true

require_relative "validate_html/version"
require_relative "validate_html/configuration"
require_relative "validate_html/rack_middleware"
require_relative "validate_html/mailer_observer"
require_relative "validate_html/active_support_notification_handler"
require_relative "validate_html/railtie" if defined?(::Rails::Railtie)
require "nokogiri"
require "digest"

module ValidateHTML
  class Error < StandardError; end
  # This error message will include the full html validation details,
  # with a path to the snapshot to assist resolving the invalid html
  #
  # @example
  #   ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Emphasized Fragment')
  #   # raises: ValidateHTML::InvalidHTMLError with this message:
  #   #
  #   #   Invalid html from My Emphasized Fragment (ValidateHTML::InvalidHTMLError)
  #   #   Parsed using Nokogiri::HTML5::DocumentFragment
  #   #   document saved at: [Configuration#snapshot_path]/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html
  #   #
  #   #   1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
  #   #   <strong><em>Very Emphasized</strong></em>
  #   #                              ^
  #   #   1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
  #   #   <strong><em>Very Emphasized</strong></em>
  #   #                                       ^
  # @see ValidateHTML.validate_html
  # @see ValidateHTML.raise_remembered_messages
  class InvalidHTMLError < Error; end

  # This error will be raised when calling {ValidateHTML.raise_remembered_messages} while {Configuration#remember_messages} is false
  # @see ValidateHTML.raise_remembered_messages
  # @see Configuration#remember_messages
  class NotRememberingMessagesError < Error; end

  class << self
    # Validate the HTML using by parsing it with nokogiri
    #
    # skip any errors matching patterns in {Configuration#ignored_errors}
    #
    # if there are any errors remaining:
    # remember the errors if {Configuration#remember_messages} is true,
    # save the invalid html into the {Configuration#snapshot_path} directory,
    # and raise {InvalidHTMLError} with the full messages if raise_on_invalid_html is true
    # or return false
    #
    # if there are no errors, return true
    #
    # @example
    #   ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Emphasized Fragment')
    #   # raises: ValidateHTML::InvalidHTMLError with this message:
    #   #
    #   #   Invalid html from My Emphasized Fragment (ValidateHTML::InvalidHTMLError)
    #   #   Parsed using Nokogiri::HTML5::DocumentFragment
    #   #   Document saved at: [Configuration#snapshot_path]/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html
    #   #
    #   #   1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
    #   #   <strong><em>Very Emphasized</strong></em>
    #   #                              ^
    #   #   1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
    #   #   <strong><em>Very Emphasized</strong></em>
    #   #                                       ^
    #
    # @param html [String]
    # @param name [String] filename or http path or email subject or etc to print in the error message
    # @param content_type [String] mime type of the document to assist determining encoding
    # @param raise_on_invalid_html [Boolean] override {Configuration#raise_on_invalid_html}
    # @return [Boolean] true if there are no validation errors
    # @raise [InvalidHTMLError] if the html is not valid and raise_on_invalid_html is true
    def validate_html(html, name: nil, content_type: nil, raise_on_invalid_html: configuration.raise_on_invalid_html?)
      return true if html.empty?

      doc = parse_html(html, find_encoding(content_type))

      errors = filter_errors(doc.errors)

      return true if errors.empty?

      handle_errors(name, doc, html, errors, raise_on_invalid_html)

      false
    end

    # Raise any remembered messages
    #
    # @return [void]
    # @raise [InvalidHTMLError] if there are remembered messages
    # @raise [NotRememberingMessagesError] if {Configuration#remember_messages} is false
    def raise_remembered_messages
      fail NotRememberingMessagesError unless configuration.remember_messages?
      return if remembered_messages.empty?

      messages = remembered_messages
      forget_messages
      fail InvalidHTMLError, messages.uniq.join("---\n")
    end

    # @!attribute [r] remembered_messages
    # @return [Array<String>]
    def remembered_messages
      @remembered_messages ||= []
    end

    # Clear any remembered messages
    # @return [void]
    def forget_messages
      @remembered_messages = []
    end

    # @!attribute [r] configuration
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure ValidateHTML
    #
    # @example
    #   ValidateHTML.configure do |c|
    #     c.remember_messages = true
    #     c.environments = ['test']
    #   end
    # @yieldparam config [Configuration]
    # @return [void]
    def configure
      yield configuration
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
        document saved at: #{path}

        #{errors.join("\n")}
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
