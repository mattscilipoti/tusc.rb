require_relative 'offset_response'

# Asks tus server for appriopriate offset
#  for specific file, via upload_url
class TusClient::OffsetRequest
  attr_reader :upload_url
  def initialize(upload_url:)
    @upload_url = upload_url
  end

  def headers
    {
      'Tus-Resumable' => supported_tus_resumable_version,
    }
  end

  def logger
    @logger ||= TusClient.logger.child(library: [self.class.name])
  end

  # Retrieves offset via a HEAD request to the tus server
  # Returns the offset (in a OffsetResponse)
  def perform
    logger.debug do
      [ 'TUS HEAD',
        sending: { upload_url: upload_uri, header: headers }
      ]
    end

    response = Net::HTTP.start(
      upload_uri.host,
      upload_uri.port,
      use_ssl: upload_uri.scheme == 'https'
    ) do |http|
      http.head(upload_uri.path, headers)
    end
    received_header = response.each_key.collect{|k| {k => response.header[k]} }

    logger.debug do
      [ "TUS HEAD",
        received: {
          status: response.code,
          header: received_header,
          body: response.body.to_s.truncate_middle(60)
        }
      ]
    end

    TusClient::OffsetResponse.new(response)
  end

  def success?
    # @upload_response.
  end

  def supported_tus_resumable_version
    '1.0.0'
  end

  def upload_uri
    URI.parse(upload_url)
  end
end
