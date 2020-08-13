require_relative 'responsorial'

# Parses the response from a CreationRequest
#
# Surfacing important info:
# - location -> upload_uri
class TusClient::CreationResponse
  include TusClient::Responsorial
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
