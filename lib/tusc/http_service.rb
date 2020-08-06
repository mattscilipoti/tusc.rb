require 'digest'
require 'net/http'
require_relative '../core_ext/string/truncate'

class HttpService
  def self.head(uri:, headers:, logger:)
    logger.debug do
      ['TUS HEAD',
       request: { upload_url: uri.to_s, header: headers }]
    end

    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https'
    ) do |http|
      http.head(uri.path, headers)
    end.tap do |response|
      received_header = response.each_key.collect { |k| { k => response.header[k] } }

      logger.debug do
        ['TUS HEAD',
         response: {
           status: response.code,
           header: received_header,
           body: response.body.to_s.truncate_middle(60)
         }]
      end
    end
  end

  def self.patch(uri:, headers:, body:, logger:)
    logger.debug do
      ['TUS PATCH',
       request: {
         # WORKAROUND: receiving error truncating body
         # *** Encoding::CompatibilityError Exception: incompatible character encodings: UTF-8 and ASCII-8BIT
         # For the test file, it works for truncate_middle(12)
         #  but not truncate_middle(13)
         # body: chunk.to_s.truncate_middle(50),
         body_md5: Digest::MD5.hexdigest(body),
         header: headers,
         url: uri.to_s
       }]
    end

    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https'
    ) do |http|
      http.patch(uri.path, body, headers)
    end.tap do |response|
      received_header = response.each_key.collect { |k| { k => response.header[k] } }
      logger.debug do
        ['TUS PATCH',
         response: {
           status: response.code,
           header: received_header,
           body: response.body.to_s.truncate_middle(60)
         }]
      end
    end
  end

  def self.post(uri:, headers:, body: nil, logger:)
    logger.debug do
      ['TUS POST',
       request: {
         tus_creation_url: uri.to_s,
         header: headers,
         body: body.to_s.truncate_middle(80) # body is usually small hash of config items
       }]
    end

    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == 'https'
    ) do |http|
      http.post(uri.path, body, headers)
    end.tap do |response|
      received_header = response.each_key.collect { |k| { k => response.header[k] } }
      logger.debug do
        ['TUS POST',
         response: {
           status: response.code,
           header: received_header,
           body: response.body.to_s.truncate_middle(60)
         }]
      end
    end
  end
end
