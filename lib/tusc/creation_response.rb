class TusClient::CreationResponse
  def initialize(response)
    @response = response
  end

  def body
    @response.body
  end

  def location
    @response.header.fetch('Location')
  end

  def raw
    @response
  end

  def status_code
    @response.code.to_i
  end

  def upload_uri
    URI.parse(location)
  end
end
