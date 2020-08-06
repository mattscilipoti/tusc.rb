require 'net/http'
require_relative '../core_ext/string/truncate'
require_relative 'upload_request'
require_relative 'upload_response'
require_relative 'offset_request'

# Uploads a file to a tus server
class TusClient::Uploader
  attr_reader :extra_headers, :io, :upload_url

  def self.chunk_size
    10 * TusClient::MEGABYTE
  end

  def self.default_content_type
    'application/offset+octet-stream'
  end

  def self.from_file_path(file_path:, upload_url:, extra_headers: {})
    raise ArgumentError, "file_path is required (#{file_path})" if file_path.blank?

    file_pathname = Pathname.new(file_path)
    raise ArgumentError, "Passed file does NOT exist: #{file_pathname.inspect}" unless file_pathname.exist?

    new(io: file_pathname.open, upload_url: upload_url, extra_headers: extra_headers)
  end

  def initialize(io:, upload_url:, extra_headers: {})
    # fail ArgumentError.new("io must be an IO object") unless io.is_a?(IO) || io.is_a?(StringIO)
    %i[size read close].each do |required_method|
      raise ArgumentError, "io must respond to ##{required_method}" unless io.respond_to?(required_method)
    end
    raise ArgumentError, "upload_url is required (#{upload_url})" if upload_url.blank?
    raise ArgumentError, "upload_url must be a valid url (#{upload_url})" unless upload_url =~ URI::ABS_URI

    @io = io
    @upload_url = upload_url
    @extra_headers = extra_headers
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
    # We used to detect content type, using MimeMagic,
    #  but the videos only uploaded if we used the default (octet-stream)
    #  So... we just use the default
    default_content_type
  end

  def default_content_type
    self.class.default_content_type
  end

  def headers
    {
      'Content-Type' => content_type,
      'Tus-Resumable' => tus_resumable_version,
      'Upload-Offset' => 0.to_s
    }.merge(extra_headers)
  end

  def logger
    @logger ||= TusClient.logger.child(library: [self.class.name])
  end

  def offset_requester
    @offset_requester ||= TusClient::OffsetRequest.new(upload_url: upload_uri, extra_headers: extra_headers)
  end

  # Performs the upload, one chunk at a time
  # Starts by asking for the currnet offset
  # Each follow-on request, returns the current offset.
  def perform
    # TODO: asynch?
    logger.debug { 'Starting upload...' }

    offset = retrieve_offset
    begin
      logger.debug { ['Reading io...', { size: size, offset: offset, chunk_size: chunk_size }] }
      io.pos = offset
      chunk = io.read(chunk_size)
      upload_response = push_chunk(chunk, offset)
      unless upload_response.success?
        raise "Issue uploading file: #{{ code: upload_response.status_code, message: upload_response.body }}."
      end

      offset = upload_response.offset
    end while upload_response.success? && upload_response.incomplete?

    io.close
    upload_response
  end

  def push_chunk(chunk, offset)
    push_chunk_via_upload_request(chunk, offset)
  end

  def push_chunk_via_upload_request(chunk, offset)
    upload_request = TusClient::UploadRequest.new(
      upload_uri: upload_url,
      chunk_to_upload: chunk,
      offset: offset,
      file_size: size,
      extra_headers: extra_headers
    )
    upload_request.perform
  end

  def retrieve_offset
    offset_requester.perform.offset
  end

  def size
    @size ||= io.size
  end

  def tus_resumable_version
    '1.0.0'
  end

  def upload_incomplete
    retrieve_offset < size
  end

  def upload_uri
    @upload_uri ||= URI.parse(upload_url)
  end

  def video_url
    upload_response.fetch('uri')
  end
end
