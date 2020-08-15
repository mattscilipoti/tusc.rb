# Shared interface for Response objects
#
# re·​spon·​so·​ri·​al | \ rə̇¦spän¦sōrēəl, (¦)rē¦s- \
# : relating to or consisting of responses
module TusClient::Responsorial
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
