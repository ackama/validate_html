module ValidateHTML
  # Rack Middleware to validate the HTML of outgoing responses
  #
  # This can be used with any rack app
  class RackMiddleware
    def initialize(app)
      @app = app
    end

    # @param env
    # @return [Array<(status, headers, response)>]
    # @raise {InvalidHTMLError} if the response has an HTML content type and the html is invalid and {Configuration#raise_on_invalid_html} is true and the request path isn't ignored by {Configuration#ignored_paths}
    # @see ValidateHTML.validate_html
    def call(env)
      status, headers, response = @app.call(env)
      path = ::Rack::Request.new(env).path
      return [status, headers, response] unless checkable_path?(path)

      body = find_body(response)

      return [status, headers, response] unless html_content_type?(headers)
      ValidateHTML.validate_html(body, content_type: headers["Content-Type"], name: path)

      [status, headers, response]
    end

    private

    def checkable_path?(path)
      ValidateHTML.configuration.ignored_paths.all? do |path_pattern|
        !(path_pattern === path)
      end
    end

    def html_content_type?(headers)
      headers["Content-Type"]&.match?(%r{\Atext/(?:vnd\.turbo-stream\.html|html)\b})
    end

    def find_body(response)
      if response.respond_to?(:body)
        find_body(response.body)
      elsif response.respond_to?(:each) # request specs
        response.each.to_a.join
      elsif response.respond_to?(:to_str)
        response.to_str
      else
        ""
      end
    rescue NoMethodError # sometimes things say they respond to body, then don't.
      ""
    end
  end
end
