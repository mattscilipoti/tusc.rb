require 'logger'
require 'tusc/version'
require_relative 'core_ext/object/blank'
require_relative 'tusc/creation_request'
require_relative 'tusc/options_request'
require_relative 'tusc/uploader'

class Logger::LogDevice
  # MonkeyPatch: to disable log header
  def add_log_header(file); end
end

module TusClient
  KILOBYTE = 1024
  MEGABYTE = KILOBYTE * 1024

  class Error < StandardError; end

  def self.log_dir
    log_dir = Pathname.new(File.expand_path('./log'))
    Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
    log_dir
  end

  def self.log_info
    # find first entry in under the tusc dir
    # source should be tus code, not support code
    source = caller_locations.find { |entry| entry.to_s =~ %r{/tusc/} }.to_s
    # method_name = (source =~ /`([^']*)'/ and Regexp.last_match(1)).to_s
    {
      source: source,
      # method: method_name,
    }
  end

  def self.log_level
    @log_level ||= Logger::INFO
  end

  def self.log_level=(value)
    @logger = nil # invalidate cache
    @log_level = value
  end

  def self.logger
    @logger ||= begin
      # logger = Logger.new(STDOUT)
      Logger.new(log_dir.join('tusc.log'), 1, 1 * MEGABYTE).tap do |logger|
        logger.level = log_level
      end
    end
  end

  def self.logger=(value)
    @logger = value
  end
end
