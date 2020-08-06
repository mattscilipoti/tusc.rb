require_relative '../http_service'
require_relative 'creation_response'

# Sends the creation request to the tus server
class TusClient::CreationRequest
  attr_reader :body, :extra_headers, :file_size, :tus_creation_url
  def initialize(tus_creation_url:, file_size:, extra_headers: {}, body: nil)
    @tus_creation_url = tus_creation_url
    @file_size = file_size
    @extra_headers = extra_headers
    @body = body
  end

  def headers
    {
      'Content-Length' => 0.to_s,
      'Tus-Resumable' => supported_tus_resumable_versions.first,
      'Upload-Length' => file_size.to_s
    }.merge(extra_headers)
  end

  def logger
    @logger ||= TusClient.logger.child(library: [self.class.name])
  end

  # Sends the creation request to the tus server
  # returns an upload_url (in CreationResponse)
  def perform
    response = HttpService.post(
      uri: tus_creation_uri,
      headers: headers,
      body: body,
      logger: logger
    )
    TusClient::CreationResponse.new(response)
  end

  def supported_tus_resumable_versions
    ['1.0.0']
  end

  def tus_creation_uri
    @tus_creation_uri ||= URI.parse(tus_creation_url)
  end
end
