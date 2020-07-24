require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/creation_request'

WebMock.disable_net_connect!(allow_localhost: true) # tus-server is on localhost

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

    it 'includes passed extra_headers' do
      allow(subject).to receive(:extra_headers).and_return({ test1: 'a', test2: 'b' })
      expect(subject.headers[:test1]).to eql('a')
      expect(subject.headers[:test2]).to eql('b')
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

    context '(with passed body)' do
      before(:each) do
        stub_request(:post, tus_creation_url)
          .with(body: body)
          .to_return(headers: { 'Location': 'body_was_passed' })
      end

      let(:body) { 'passed_to_initialize' }
      subject(:request) do
        TusClient::CreationRequest.new(
          file_size: mock_file.size,
          tus_creation_url: tus_creation_url,
          body: body
        )
      end

      it 'passes the body to http call' do
        # checked by the stub_request above
        response = subject.perform
        expect(response.location).to eql('body_was_passed')
      end
    end

    context '(with passed headers)' do
      before(:each) do
        stub_request(:post, tus_creation_url)
          .with(headers: headers)
          .to_return(headers: { 'Location': 'headers were passed' })
      end

      let(:headers) do
        { 'passed_header' => 'has been included' }
      end

      subject(:request) do
        TusClient::CreationRequest.new(
          file_size: mock_file.size,
          tus_creation_url: tus_creation_url,
          extra_headers: headers
        )
      end

      it 'passes the headers to http call' do
        # checked by the stub_request above
        response = subject.perform
        expect(response.location).to eql('headers were passed')
      end
    end
  end
end
