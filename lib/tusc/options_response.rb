require_relative 'responsorial'

# Parses the response from an OptionsRequest
#
# Surfacing important info:
# - max_chunk_size
# - supported_checksums
# - supported_extensions
# - supported_versions
class TusClient::OptionsResponse
  include TusClient::Responsorial
  def initialize(response)
    @response = response
  end

  def max_chunk_size
    raw.header['Tus-Max-Size']
  end

  def success?
    success_codes = [200, 204]
    success_codes.include?(status_code)
  end

  def supported_checksums
    raw.header['Tus-Checksum-Algorithm']
  end

  def supported_extensions
    raw.header['Tus-Extension']
  end

  def supported_versions
    raw.header['Tus-Version']
  end
end
