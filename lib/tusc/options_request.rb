require_relative '../http_service'
require_relative 'options_response'

# Asks tus server for the provided options (aka server configuration)
class TusClient::OptionsRequest
  attr_reader :extra_headers, :tus_server_uri
  def initialize(tus_server_url:, extra_headers: {})
    tus_server_uri = tus_server_url.is_a?(URI) ? tus_server_url : URI.parse(tus_server_url)
    unless tus_server_uri.is_a?(URI::HTTP) && !tus_server_uri.host.nil?
      raise URI::InvalidURIError, "Could NOT parse host from #{tus_server_url.inspect}"
    end

    @tus_server_uri = tus_server_uri
    @extra_headers = extra_headers
  end

  def headers
    extra_headers
  end

  def logger
    @logger ||= TusClient.logger
  end

  # Retrieves server config via a OPTIONS request to the tus server
  # Returns an OptionsResponse)
  def perform
    response = TusClient::HttpService.options(
      uri: tus_server_uri,
      headers: headers,
      logger: logger
    )
    TusClient::OptionsResponse.new(response)
  end
end
