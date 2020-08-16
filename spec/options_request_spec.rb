require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/options_request'

WebMock.disable_net_connect!(allow_localhost: true) # tus-server is on localhost

RSpec.describe 'TusClient::OptionsRequest (constructor)' do
  it 'converts tus_server_url to tus_server_uri (as URI)' do
    request = TusClient::OptionsRequest.new(tus_server_url: 'https://tus.example.com/files')
    expect(request.tus_server_uri).to be_a(URI)
    expect(request.tus_server_uri.to_s).to eql('https://tus.example.com/files')
  end

  it 'accepts an tus_server_uri (type: URI)' do
    tus_server_uri = URI.parse('https://tus.example.com/files')
    request = TusClient::OptionsRequest.new(tus_server_url: tus_server_uri)
    expect(request.tus_server_uri).to be_a(URI)
    expect(request.tus_server_uri.to_s).to eql('https://tus.example.com/files')
  end

  it 'requires a valid tus_server_url' do
    expect do
      TusClient::OptionsRequest.new(tus_server_url: 'invalid_url')
    end.to raise_error(URI::InvalidURIError, /host/)
  end
end

RSpec.describe TusClient::OptionsRequest do
  subject(:request) do
    TusClient::OptionsRequest.new(
      tus_server_url: tus_server_url
    )
  end

  let(:tus_server_url) { 'https://tus.example.com/files' }

  describe '#headers' do
    it 'does NOT include Tus-Resumable' do
      expect(subject.headers.keys).not_to include('Tus-Resumable')
    end
  end

  describe '#perform' do
    let(:expected_max_chunk_size) { '1073741824' }
    let(:expected_supported_versions) { '1.0.0,0.2.2,0.2.1' }

    before(:each) do
      stub_request(:options, tus_server_url)
        .to_return(
          headers: {
            'Tus-Resumable': '1.0.0',
            'Tus-Version': expected_supported_versions,
          }
        )
    end

    it 'returns a OptionsResponse' do
      expect(subject.perform).to be_a(TusClient::OptionsResponse)
    end

    it 'returns a OptionsResponse with supported versions (randomly chosen property)' do
      expect(subject.perform.supported_versions).to eql(expected_supported_versions)
    end

    context '(with passed headers)' do
      before(:each) do
        stub_request(:options, tus_server_url)
          .with(headers: headers)
          .to_return(headers: { 'Tus-Max-Size': expected_max_chunk_size, })
      end

      let(:headers) do
        { 'passed_header' => 'has been included' }
      end

      subject(:request) do
        TusClient::OptionsRequest.new(
          tus_server_url: tus_server_url,
          extra_headers: headers
        )
      end

      it 'passes the headers to http call' do
        # headers checked by the stub_request above
        response = subject.perform
      end
    end
  end
end
