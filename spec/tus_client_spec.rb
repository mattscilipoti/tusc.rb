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

  it 'provides the default chunk_size (10MB)' do
    expect(TusClient.chunk_size).to eql(10 * 1024 * 1024)
  end

  it '#chunk_size can be assigned' do
    new_chunk_size = 512 * TusClient::MEGABYTE
    expect(TusClient.chunk_size).not_to eql(new_chunk_size)
    TusClient.chunk_size = new_chunk_size
    expect(TusClient.chunk_size).to eql(new_chunk_size)
  end

  it '#chunk_size must be an integer' do
    expect{
      TusClient.chunk_size = 1.1
    }.to raise_error(ArgumentError, /must.*Integer/)

    expect{
      TusClient.chunk_size = 'abc'
    }.to raise_error(ArgumentError, /must.*Integer/)
  end
end
