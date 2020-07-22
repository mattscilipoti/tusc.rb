require_relative 'creation_response'

# Sends the creation request to the tus server
class TusClient::CreationRequest
  attr_reader :file_size, :tus_creation_url
  def initialize(tus_creation_url:, file_size:)
    @tus_creation_url = tus_creation_url
    @file_size = file_size
  end

  def headers
    {
      'Content-Length' => 0.to_s,
      'Tus-Resumable' => supported_tus_resumable_versions.first,
      'Upload-Length' => file_size.to_s
    }
  end

  def logger
    @logger ||= TusClient.logger.child(library: [self.class.name])
  end

  # Sends the creation request to the tus server
  # returns an upload_url (in CreationResponse)
  def perform
    logger.debug do
      [ 'TUS POST',
        sending: { tus_creation_url: tus_creation_uri.to_s, header: headers }
      ]
    end

    response = Net::HTTP.start(
      tus_creation_uri.host,
      tus_creation_uri.port,
      use_ssl: tus_creation_uri.scheme == 'https'
    ) do |http|
      http.post(tus_creation_uri.path, headers)
    end

    received_header = response.each_key.collect{|k| {k => response.header[k]} }
    logger.debug do
      [ "TUS POST",
        received: {
          status: response.code,
          header: received_header,
          body: response.body.to_s.truncate_middle(60)
        }
      ]
    end

    TusClient::CreationResponse.new(response)
  end

  def success?
    # @upload_response.
  end

  def supported_tus_resumable_versions
    ['1.0.0']
  end

  def tus_creation_uri
    URI.parse(tus_creation_url)
  end
end
