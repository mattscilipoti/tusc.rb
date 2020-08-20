require 'spec_helper'

RSpec.describe TusClient do
  it 'provides the current version number' do
    version_reg_exp = /\d{1,3}\.\d{1,3}.\d{1,3}/ # 1[23].1[23].1[23]
    expect(TusClient::VERSION).to match(version_reg_exp)
  end

  it 'provides the current log directory' do
    expect(TusClient.log_dir).to be_a(Pathname)
  end

  it '#log_info provides the source (current method from backtrace, filtered to methods in tusc dir)' do
    expect(TusClient.log_info).to include({source: ''}) # empty since this spec is NOT in tusc/
  end

  it 'default #log_level is DEBUG (changed from default:INFO by spec_helper.rb' do
    expect(TusClient.log_level).to eql(Logger::DEBUG)
    expect(TusClient.log_level).to eql(TusClient.logger.level)
  end

  it '#log_level can be assigned' do
    TusClient.log_level = Logger::ERROR
    expect(TusClient.log_level).to eql(Logger::ERROR)
  end
  end
end
