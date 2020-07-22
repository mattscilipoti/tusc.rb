require 'mimemagic'
require_relative '../core_ext/string/truncate'
require_relative 'upload_response'

# Uploads a file to a tus server
class TusClient::Uploader
  attr_reader :io, :upload_url

  def self.chunk_size
    10 * TusClient::MEGABYTE
  end

  def self.from_file_path(file_path:, upload_url:)
    raise ArgumentError, "file_path is required (#{file_path})" if file_path.blank?

    file_pathname = Pathname.new(file_path)
    raise ArgumentError, "Passed file does NOT exist: #{file_pathname.inspect}" unless file_pathname.exist?

    new(io: file_pathname.open, upload_url: upload_url)
  end

  def initialize(io:, upload_url:)
    # fail ArgumentError.new("io must be an IO object") unless io.is_a?(IO) || io.is_a?(StringIO)
    %i[rewind size read close].each do |required_method|
      raise ArgumentError, "io must respond to ##{required_method}" unless io.respond_to?(required_method)
    end
    raise ArgumentError, "upload_url is required (#{upload_url})" if upload_url.blank?
    raise ArgumentError, "upload_url must be a valid url (#{upload_url})" unless upload_url =~ URI::ABS_URI

    @io = io
    @upload_url = upload_url
  end

  # Optionally, if the client wants to delete an upload because it won’t be needed anymore,
  #   a DELETE request can be sent to the upload URL.
  #   After this, the upload can be cleaned up by the server and resuming the upload is not possible anymore.
  def cancel_upload
    delete upload_url
  end

  def chunk_size
    @chunk_size ||= TusClient::Uploader.chunk_size
  end

  def content_type
    @content_type ||= get_content_type
  end

  def default_content_type
    'application/offset+octet-stream'
  end

  def get_content_type
    @content_type ||= begin
      MimeMagic.by_magic(io) || default_content_type
    end
  end

  def headers
    headers = {
      'Content-Type' => content_type,
      'Tus-Resumable' => tus_resumable_version,
      'Upload-Offset' => 0.to_s,
      'Upload-Length' => size.to_s
    }
  end

  def logger
    @logger ||= TusClient.logger.child(library: [self.class.name])
  end

  def offset
    offset_requester.perform.offset
  end

  def offset_requester
    @offset_requester ||= TusClient::OffsetRequester.new(upload_uri)
  end

  def size
    @size ||= io.size
  end

  # Performs the upload, one chunk at a time
  # Starts by asking for the currnet offset
  # Each follow-on request, returns the current offset.
  def perform
    # TODO: asynch?
    logger.debug { 'Starting upload...' }
    io.rewind

    offset = self.offset
    begin
      logger.debug { ['Reading io...', { size: size, offset: offset, chunk_size: chunk_size }] }

      chunk = io.read(chunk_size, offset)
      upload_response = push_chunk(chunk, offset)
      offset = upload_response.offset
    end while offset < size && upload_response.status_code == 200
    io.close
    upload_response
  end

  def push_chunk(chunk, offset)
    push_headers = { 'Upload-Offset' => offset.to_s }
    headers = self.headers.merge(push_headers)

    logger.debug do
      ['TUS PATCH',
       sending: {
         body: chunk.to_s.truncate_middle(50),
         header: headers,
         url: upload_url.to_s
       }]
    end

    response = Net::HTTP.start(
      upload_uri.host,
      upload_uri.port,
      use_ssl: upload_uri.scheme == 'https'
    ) do |http|
      http.patch(upload_uri.path, chunk, headers)
    end

    received_header = response.each_key.collect { |k| { k => response.header[k] } }
    logger.debug do
      ['TUS PATCH',
       received: {
         status: response.code,
         header: received_header,
         body: response.body.to_s.truncate_middle(60)
       }]
    end

    TusClient::UploadResponse.new(response)
  end

  def tus_resumable_version
    '1.0.0'
  end

  def upload_incomplete
    offset < size
  end

  def upload_uri
    URI.parse(upload_url)
  end

  def video_url
    upload_response.fetch('uri')
  end
end
