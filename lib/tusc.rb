require 'tusc/version'
require 'ougai'


class Logger::LogDevice
  # MonkeyPatch: to disable log header
  def add_log_header(file)
  end
end

module TusClient
  KILOBYTE = 1024
  MEGABYTE = KILOBYTE * 1024

  class Error < StandardError; end

  def self.log_dir
    log_dir = Pathname.new(File.expand_path('./log'))
    Dir.mkdir(log_dir) unless Dir.exists?(log_dir)
    log_dir
  end

  def self.logger
    @logger ||= begin

      logger = Ougai::Logger.new(STDOUT)
      # logger = Ougai::Logger.new(log_dir.join('tusc.log'), 50 * MEGABYTE)
      logger.level = Logger::INFO

      error_logger = Ougai::Logger.new(log_dir.join('tusc_error.log'), 10 * MEGABYTE)
      error_logger.level = Logger::ERROR
      error_logger.before_log = lambda do |data|
        # find first entry in this library
        source = caller_locations.find{|entry| entry.to_s =~ /tusc/}.to_s
        method_name = (source =~ /`([^']*)'/ and $1).to_s
        data[:source] = source
        data[:method] = method_name
      end
      logger.extend Ougai::Logger.broadcast(error_logger)
      logger
    end
  end

  def self.logger=(value)
    @logger = value
  end
end
