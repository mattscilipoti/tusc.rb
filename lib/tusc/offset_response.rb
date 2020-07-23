class TusClient::OffsetResponse
  def initialize(response)
    @response = response
  end

  def offset
    @response.header['Upload-Offset'].to_i # nil.to_i == 0
  end
end
