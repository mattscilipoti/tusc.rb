class TusClient::UploadResponse
  attr_reader :file_size
  def initialize(response, file_size)
    @response = response
    @file_size = file_size
  end

  def incomplete?
    status_code == 200 && (offset < file_size)
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

  def success?
    status_code == 204 && (offset >= 0)
  end
end
