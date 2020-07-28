class TusClient::UploadResponse
  attr_reader :file_size
  def initialize(response, file_size)
    @response = response
    @file_size = file_size
  end

  def body
    @response.body
  end

  def complete?
    offset >= file_size
  end

  def incomplete?
    offset < file_size
  end

  def offset
    @response.header['Upload-Offset'].to_i
  end

  def raw
    @response
  end

  def status_code
    @response.code.to_i
  end

  def successful_status_codes
    [200, 204]
  end

  def success?
    successful_status_codes.include?(status_code)
  end
end
