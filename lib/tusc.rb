require 'tusc/version'
require 'active_support/core_ext/string/filters' # for truncate
require 'ougai'

module TusClient
  KILOBYTE = 1024
  MEGABYTE = KILOBYTE * 1024

  class Error < StandardError; end
  def self.logger
    @logger ||= begin
      log_dir = Pathname.new(File.expand_path('./log'))
      Dir.mkdir(log_dir) unless Dir.exists?(log_dir)
      Ougai::Logger.new(log_dir.join('tusc.log'), 100 * MEGABYTE)
    end
  end
end
