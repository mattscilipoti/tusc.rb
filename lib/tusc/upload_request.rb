require 'digest'
require 'net/http'
require_relative 'upload_response'
require_relative '../core_ext/string/truncate'

module TusClient
  # Asks tus server to upload a chunk of a file, from a specific offset
  class UploadRequest
    attr_reader :chunk_to_upload, :extra_headers, :file_size, :offset, :upload_uri

    def initialize(upload_uri:, chunk_to_upload:, offset:, file_size:, extra_headers: {})
      upload_uri = upload_uri.is_a?(URI) ? upload_uri : URI.parse(upload_uri)
      unless upload_uri.is_a?(URI::HTTP) && !upload_uri.host.nil?
        raise URI::InvalidURIError, "Could NOT parse host from #{upload_uri.inspect}"
      end

      unless chunk_to_upload.is_a?(String)
        raise ArgumentError, "chunk_to_upload must be a String, found (#{chunk_to_upload}:#{chunk_to_upload.class.name})"
      end

      unless file_size.is_a?(Integer)
        raise ArgumentError, "file_size must be an Integer, found (#{file_size}:#{file_size.class.name})"
      end

      unless offset.is_a?(Integer)
        raise ArgumentError, "offset must be an Integer, found (#{offset}:#{offset.class.name})"
      end

      @chunk_to_upload = chunk_to_upload
      @extra_headers = extra_headers
      @file_size = file_size
      @offset = offset
      @upload_uri = upload_uri
    end

    def default_content_type
      'application/offset+octet-stream'
    end

    def headers
      {
        'Content-Type' => default_content_type,
        'Tus-Resumable' => supported_tus_resumable_version,
        'Upload-Offset' => offset.to_s
      }.merge(extra_headers)
    end

    def logger
      @logger ||= TusClient.logger.child(library: [self.class.name])
    end

    def perform
      logger.debug do
        ['TUS PATCH',
         request: {
           # WORKAROUND: receiving error truncating body
           # *** Encoding::CompatibilityError Exception: incompatible character encodings: UTF-8 and ASCII-8BIT
           # For the test file, it works for truncate_middle(12)
           #  but not truncate_middle(13)
           # body: chunk.to_s.truncate_middle(50),
           body_md5: Digest::MD5.hexdigest(chunk_to_upload),
           header: headers,
           url: upload_uri.to_s
         }]
      end

      response = Net::HTTP.start(
        upload_uri.host,
        upload_uri.port,
        use_ssl: upload_uri.scheme == 'https'
      ) do |http|
        http.patch(upload_uri.path, chunk_to_upload, headers)
      end

      received_header = response.each_key.collect { |k| { k => response.header[k] } }
      logger.debug do
        ['TUS PATCH',
         response: {
           status: response.code,
           header: received_header,
           body: response.body.to_s.truncate_middle(60)
         }]
      end

      TusClient::UploadResponse.new(response, file_size)
    end

    def supported_tus_resumable_version
      '1.0.0'
    end
  end
end
