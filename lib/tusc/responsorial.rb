# shared interface for Response objects
module Responsorial
  def body
    body = raw.body
    body.blank? ? '' : JSON.parse(body)
  end

  def raw
    @response
  end

  def status_code
    raw.code.to_i
  end
end
