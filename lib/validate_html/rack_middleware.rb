module ValidateHTML
  class RackMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      path = ::Rack::Request.new(env).fullpath
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
        response.body
      elsif response.is_a?(Array) # request specs
        response.first || ""
      else
        ""
      end
    rescue NoMethodError # sometimes things say they respond to body, then don't.
      ""
    end
  end
end
