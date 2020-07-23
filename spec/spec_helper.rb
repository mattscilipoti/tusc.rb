require 'bundler/setup'
require 'tusc'
require 'ougai' # logger

test_logger = Ougai::Logger.new(TusClient.log_dir.join('tusc_test.log'), 1, 200 * TusClient::KILOBYTE)
# pretty formatting
# test_logger.formatter = Ougai::Formatters::Readable.new
test_logger.level = Logger::DEBUG
test_logger.before_log = lambda do |data|
  # find first entry in this library
  source = caller_locations.find { |entry| entry.to_s =~ /tusc/ }.to_s
  method_name = (source =~ /`([^']*)'/ and Regexp.last_match(1)).to_s
  data[:source] = source
  data[:method] = method_name
end

TusClient.logger = test_logger

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
end
