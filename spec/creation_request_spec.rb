require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/creation_request'

WebMock.disable_net_connect!

RSpec.describe TusClient::CreationRequest do
  subject(:request) do
    TusClient::CreationRequest.new(
      file_size: mock_file.size,
      tus_creation_url: tus_creation_url
    )
  end

  let(:tus_creation_url) { 'https://tus.exmaple.com/uploads' }
  let(:mock_file) { StringIO.new('abc') }

  describe '#headers' do
    it 'includes Content-Length' do
      expect(subject.headers['Content-Length']).to eql(0.to_s)
    end

    it 'includes Tus-Resumable' do
      expect(subject.headers['Tus-Resumable']).to eql('1.0.0')
    end

    it 'includes Upload-Length (file size)' do
      expect(subject.headers['Upload-Length']).to eql(3.to_s)
    end
  end

  describe '#perform' do
    let(:expected_uploading_url) { 'tus.example.com/uploading/-1' }
    before(:each) do
      stub_request(:post, tus_creation_url)
        .to_return(headers: { 'Location': expected_uploading_url })
    end

    it 'returns a CreationResponse' do
      expect(subject.perform).to be_a(TusClient::CreationResponse)
    end

    it 'returns a CreationResponse with provided upload_uri' do
      response = subject.perform
      expect(response.upload_uri.to_s).to eql(expected_uploading_url)
    end

    it 'derives #status_code from response.code' do
      response = subject.perform
      expect(response.status_code).to eql(200)
    end
  end
end
