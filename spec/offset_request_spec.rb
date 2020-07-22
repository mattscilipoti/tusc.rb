require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/offset_request'

WebMock.disable_net_connect!

RSpec.describe TusClient::OffsetRequest do
  subject(:request) do
    TusClient::OffsetRequest.new(
      upload_url: upload_url
    )
  end

  let(:upload_url) { 'https://tus.exmaple.com/file/-1' }

  describe '#headers' do
    it 'includes Tus-Resumable' do
      expect(subject.headers['Tus-Resumable']).to eql('1.0.0')
    end
  end

  describe '#perform' do
    let(:expected_offset) { -1 }
    before(:each) do

      stub_request(:head, upload_url).
        to_return(
          headers: {
            'Upload-Offset': expected_offset.to_s,
            'Tus-Resumable': '1.0.0',
          }
        )
    end

    it 'returns a OffsetResponse' do
      expect(subject.perform).to be_a(TusClient::OffsetResponse)
    end

    it 'returns a OffsetResponse with provided offset' do
      expect(subject.perform.offset).to eql(expected_offset)
    end
  end
end
