require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/offset_request'

WebMock.disable_net_connect!

RSpec.describe 'TusClient::OffsetRequest (constructor)' do
  it 'converts upload_url to upload_uri (as URI)' do
    request = TusClient::OffsetRequest.new(upload_url: 'https://offset.example.com')
    expect(request.upload_uri).to be_a(URI)
    expect(request.upload_uri.to_s).to eql('https://offset.example.com')
  end

  it 'accepts a URI' do
    upload_uri = URI.parse('https://offset.example.com')
    request = TusClient::OffsetRequest.new(upload_url: upload_uri)
    expect(request.upload_uri).to be_a(URI)
    expect(request.upload_uri.to_s).to eql('https://offset.example.com')
  end

  it 'requires a valid upload_url' do
    expect do
      TusClient::OffsetRequest.new(upload_url: 'invalid_url')
    end.to raise_error(URI::InvalidURIError, /host/)
  end
end

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
      stub_request(:head, upload_url)
        .to_return(
          headers: {
            'Upload-Offset': expected_offset.to_s,
            'Tus-Resumable': '1.0.0'
          }
        )
    end

    it 'returns a OffsetResponse' do
      expect(subject.perform).to be_a(TusClient::OffsetResponse)
    end

    it 'returns a OffsetResponse with provided offset' do
      expect(subject.perform.offset).to eql(expected_offset)
    end

    context '(with passed headers)' do
      before(:each) do
        stub_request(:head, upload_url)
          .with(headers: headers)
          .to_return(headers: { 'Upload-Offset': 234 })
      end

      let(:headers) do
        { 'passed_header' => 'has been included' }
      end

      subject(:request) do
        TusClient::OffsetRequest.new(
          upload_url: upload_url,
          extra_headers: headers
        )
      end

      it 'passes the headers to http call' do
        # checked by the stub_request above
        response = subject.perform
        expect(response.offset).to eql(234)
      end
    end
  end
end
