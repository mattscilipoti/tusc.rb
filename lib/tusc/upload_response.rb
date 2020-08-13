require_relative 'responsorial'

# Parses the response from an UploadRequest
#
# Surfacing important info:
# - complete?
# - incomplete?
# - offset
# - success?
class TusClient::UploadResponse
  include TusClient::Responsorial
  attr_reader :file_size
  def initialize(response, file_size)
    @response = response
    @file_size = file_size
  end

  def complete?
    offset >= file_size
  end

  def incomplete?
    offset < file_size
  end

  def offset
    raw.header['Upload-Offset'].to_i
  end

  def successful_status_codes
    [200, 204]
  end

  def success?
    successful_status_codes.include?(status_code)
  end
end
