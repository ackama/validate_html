# frozen_string_literal: true

module ValidateHTML
  # Rack Middleware to validate the HTML of outgoing responses
  #
  # This can be used with any rack app
  class RackMiddleware
    ANNOTATE_RENDERED_VIEW_WITH_FILENAMES_PREFIX_COMMENT_REGEX = /\A<!-- BEGIN .+?-->/.freeze

    def initialize(app)
      @app = app
    end

    # @param env
    # @return [Array<(status, headers, response)>]
    # @raise {InvalidHTMLError} if the response has an HTML content type
    #   and the html is invalid
    #   and {Configuration#raise_on_invalid_html} is true
    #   and the request path isn't ignored by {Configuration#ignored_paths}
    # @see ValidateHTML.validate_html
    def call(env)
      status, headers, response = @app.call(env)
      path = ::Rack::Request.new(env).path
      return [status, headers, response] unless checkable_path?(path)

      body = find_body(response)

      return [status, headers, response] unless html_content_type?(headers)

      body_for_validation = remove_annotate_rendered_view_with_filenames_prefix_comment(body)
      ValidateHTML.validate_html(body_for_validation, content_type: headers['Content-Type'], name: path)

      [status, headers, response]
    end

    private

    # If:
    #
    #    config.action_view.annotate_rendered_view_with_filenames = true
    #
    # is set in Rails then each rendered view and partial will have a comment
    # at the top like:
    #
    #    <!-- BEGIN app/views/thing/index.html.erb -->
    #
    # When this comment is present before the doctype, it causes the HTML to be
    # invalid in a way that is not useful so we remove it.
    def remove_annotate_rendered_view_with_filenames_prefix_comment(body)
      body.sub(ANNOTATE_RENDERED_VIEW_WITH_FILENAMES_PREFIX_COMMENT_REGEX, '')
    end

    def checkable_path?(path)
      !ValidateHTML.configuration.ignored_paths_re.match?(path)
    end

    def html_content_type?(headers)
      headers['Content-Type']&.match?(%r{\Atext/(?:vnd\.turbo-stream\.html|html)\b})
    end

    def find_body(response)
      if response.respond_to?(:body)
        find_body(response.body)
      elsif response.respond_to?(:each) # request specs
        response.each.to_a.join
      elsif response.respond_to?(:to_str)
        response.to_str
      else
        ''
      end
    rescue NoMethodError # sometimes things say they respond to body, then don't.
      ''
    end
  end
end
