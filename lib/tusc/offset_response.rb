class TusClient::OffsetResponse
  def initialize(response)
    @response = response
  end

  def offset
    @response.header['Upload-Offset'].to_i # nil.to_i == 0
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
