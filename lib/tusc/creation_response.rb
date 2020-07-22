class TusClient::CreationResponse
  def initialize(response)
    @response = response
  end

  def location
    @response.header.fetch('Location')
  end

  def upload_uri
    URI.parse(location)
  end
end
