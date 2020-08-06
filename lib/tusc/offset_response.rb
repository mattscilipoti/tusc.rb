require_relative 'responsorial'

class TusClient::OffsetResponse
  include TusClient::Responsorial
  def initialize(response)
    @response = response
  end

  def offset
    raw.header['Upload-Offset'].to_i # nil.to_i == 0
  end

  def success?
    status_code == 204 && (offset >= 0)
  end
end
