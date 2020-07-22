class TusClient::UploadResponse
  def initialize(response)
    @response = response
  end

  def offset
    @response.header.fetch('Upload-Offset').to_i
  end

  def status_code
    @response.code.to_i
  end
end
