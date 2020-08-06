require_relative '../http_service'
require_relative 'offset_response'

# Asks tus server for appriopriate offset
#  for specific file, via upload_url
class TusClient::OffsetRequest
  attr_reader :extra_headers, :upload_uri
  def initialize(upload_url:, extra_headers: {})
    upload_uri = upload_url.is_a?(URI) ? upload_url : URI.parse(upload_url)
    unless upload_uri.is_a?(URI::HTTP) && !upload_uri.host.nil?
      raise URI::InvalidURIError, "Could NOT parse host from #{upload_url.inspect}"
    end

    @upload_uri = upload_uri
    @extra_headers = extra_headers
  end

  def headers
    {
      'Tus-Resumable' => supported_tus_resumable_version
    }.merge(extra_headers)
  end

  def logger
    @logger ||= TusClient.logger.child(library: [self.class.name])
  end

  # Retrieves offset via a HEAD request to the tus server
  # Returns the offset (in a OffsetResponse)
  def perform
    response = HttpService.head(
      uri: upload_uri,
      headers: headers,
      logger: logger
    )
    TusClient::OffsetResponse.new(response)
  end

  def supported_tus_resumable_version
    '1.0.0'
  end
end
