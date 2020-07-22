class TusClient::CreationResponse
  def initialize(response)
    @response = response
  end

  def body
    JSON.parse(@response.body)
  end

  def location
    @response.header && @response.header['Location']
  end

  def raw
    @response
  end

  def status_code
    @response.code.to_i
  end

  def success?
    result = status_code == 201
    result &= (location =~ URI::ABS_URI) unless location.blank?
    result
  end

  def upload_uri
    URI.parse(location) unless location.blank?
  end
end
