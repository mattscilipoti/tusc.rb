require 'digest'
require 'net/http'
require_relative '../core_ext/string/truncate'

class HttpService
  def self.head(uri:, headers:, logger:)
    request = Net::HTTP::Head.new(uri, headers)
    _perform(http_request: request, logger: logger)
  end

  def self.patch(uri:, headers:, body:, logger:)
    request = Net::HTTP::Patch.new(uri, headers)
    request.body = body
    _perform(http_request: request, logger: logger)
  end

  def self.post(uri:, headers:, body: nil, logger:)
    request = Net::HTTP::Post.new(uri, headers)
    request.body = body
    _perform(http_request: request, logger: logger)
  end

  def self._perform(http_request:, logger:)
    uri = http_request.uri

    logger.debug do
      header_info = {}
      http_request.each_header do |key, value|
        header_info[key] = value
      end
      request_info = { uri: uri.to_s, header: header_info }

      request_body = http_request.body.to_s
      request_info[:body_md5] = Digest::MD5.hexdigest(request_body) unless request_body.blank?

      formatted_body =  case request_body.encoding
                        when Encoding::ASCII_8BIT
                          request_body.encoding.inspect
                        else
                          request_body.truncate_middle(60)
                        end
      request_info[:body] = formatted_body

      ["TUS #{http_request.method}",
       request: request_info]
    end

    http_response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https'
    ) do |http|
      http.request http_request
    end

    http_response.tap do |response|
      received_header = response.each_key.collect { |k| { k => response.header[k] } }

      logger.debug do
        ["TUS #{http_request.method}",
         response: {
           status: response.code,
           header: received_header,
           body: response.body.to_s.truncate_middle(60)
         }]
      end
    end
  end
end
