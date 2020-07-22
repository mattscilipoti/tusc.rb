class TusClient::OffsetResponse
  def initialize(response)
    @response = response
  end

  def offset
    @response.header.fetch('Upload-Offset').to_i
  end
end
