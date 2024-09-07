# frozen_string_literal: true

class LightwardRedirectMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    # Check if the status is 404
    if status == 404
      # Extract the request path
      path = env["PATH_INFO"]

      # Check if the resource exists at lightward.inc
      if resource_exists_at_lightward_inc?(path)
        # If it exists, redirect the user permanently
        return [
          301,
          { "Location" => "https://lightward.inc#{path}", "Content-Type" => "text/html" },
          ["You are being redirected to https://lightward.inc#{path}"],
        ]
      end
    end

    # If not 404 or no resource found, return the original response
    [status, headers, response]
  end

  private

  # Helper method to check if the resource exists at lightward.inc
  def resource_exists_at_lightward_inc?(path)
    url = URI("https://lightward.inc#{path}")
    response = Net::HTTP.get_response(url)

    # Return true if the response is 2xx or 3xx
    response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
  rescue
    false # Fail silently if there's an issue with the request
  end
end
