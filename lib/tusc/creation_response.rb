require 'json'
require_relative 'responsorial'

class TusClient::CreationResponse
  include Responsorial
  def initialize(response)
    @response = response
  end

  def location
    raw.header && raw.header['Location']
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
