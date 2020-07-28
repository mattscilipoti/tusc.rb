require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/upload_request'

WebMock.disable_net_connect!(allow_localhost: true) # tus-server is on localhost

RSpec.describe 'TusClient::UploadRequest (constructor)' do
  let(:valid_chunk) { 'abc' }
  let(:valid_file_size) { 1024 }
  let(:valid_offset) { 0 }
  let(:valid_upload_url) { 'https://upload.example.com' }

  it 'requires a valid :chunk_to_upload (a String)' do
    expect do
      TusClient::UploadRequest.new(
        upload_uri: valid_upload_url,
        chunk_to_upload: 123,
        offset: valid_offset,
        file_size: valid_file_size
      )
    end.to raise_error(ArgumentError, /chunk_to_upload must be a String/)
  end

  it 'requires a valid :file_size' do
    expect do
      TusClient::UploadRequest.new(
        upload_uri: valid_upload_url,
        chunk_to_upload: 'abc',
        offset: valid_offset,
        file_size: 'not an Integer'
      )
    end.to raise_error(ArgumentError, /file_size must be an Integer/)
  end

  it 'requires a valid :offset' do
    expect do
      TusClient::UploadRequest.new(
        upload_uri: valid_upload_url,
        chunk_to_upload: 'abc',
        offset: 'not an Integer',
        file_size: valid_file_size
      )
    end.to raise_error(ArgumentError, /offset must be an Integer/)
  end

  it 'converts upload_uri (as URL/String) to upload_uri (as URI)' do
    request = TusClient::UploadRequest.new(
      upload_uri: valid_upload_url,
      chunk_to_upload: valid_chunk,
      offset: valid_offset,
      file_size: valid_file_size
    )
    expect(request.upload_uri).to be_a(URI)
    expect(request.upload_uri.to_s).to eql(valid_upload_url)
  end

  it 'accepts an upload_uri (type: URI)' do
    request = TusClient::UploadRequest.new(
      upload_uri: URI.parse(valid_upload_url),
      chunk_to_upload: valid_chunk,
      offset: valid_offset,
      file_size: valid_file_size
    )
    expect(request.upload_uri).to be_a(URI)
    expect(request.upload_uri.to_s).to eql(valid_upload_url)
  end

  it 'requires a valid upload_url' do
    expect do
      TusClient::UploadRequest.new(
        upload_uri: 'invalid_url',
        chunk_to_upload: valid_chunk,
        offset: valid_offset,
        file_size: valid_file_size
      )
    end.to raise_error(URI::InvalidURIError, /host/)
  end
end

RSpec.describe TusClient::UploadRequest do
  let(:valid_chunk) { 'abc' }
  let(:valid_file_size) { 1024 }
  let(:valid_offset) { 0 }
  let(:valid_upload_url) { 'https://tus.example.com/upload' }
  let(:upload_uri) { URI.parse(valid_upload_url) }

  subject(:request) do
    TusClient::UploadRequest.new(
      upload_uri: upload_uri,
      chunk_to_upload: valid_chunk,
      offset: valid_offset,
      file_size: valid_file_size
    )
  end

  describe '#headers' do
    it 'includes Content-Type of octet-stream' do
      expect(subject.headers['Content-Type']).to eql('application/offset+octet-stream')
    end

    it 'includes Tus-Resumable' do
      expect(subject.headers['Tus-Resumable']).to eql('1.0.0')
    end

    it 'includes Upload-Offset' do
      expect(subject.headers['Upload-Offset']).to eql(valid_offset.to_s)
    end

    it 'includes passed extra_headers' do
      upload_request = TusClient::UploadRequest.new(
        upload_uri: upload_uri,
        chunk_to_upload: valid_chunk,
        offset: valid_offset,
        file_size: valid_file_size,
        extra_headers: { extra: 'header' }
      )
      expect(upload_request.headers).to include(extra: 'header')
    end
  end

  describe '#perform' do
    let(:expected_offset) { -1 }
    before(:each) do
      stub_request(:patch, upload_uri.to_s)
        .to_return(
          status: 201,
          headers: {
            'Upload-Offset': expected_offset.to_s,
            'Tus-Resumable': '1.0.0'
          }
        )
    end

    it 'returns a UploadResponse' do
      expect(subject.perform).to be_a(TusClient::UploadResponse)
    end

    it 'returns a UploadResponse with provided file_size' do
      expect(subject.perform.file_size).to eql(valid_file_size)
    end

    it 'returns a UploadResponse with provided offset' do
      expect(subject.perform.offset).to eql(expected_offset)
    end

    it 'returns a UploadResponse with provided status_code' do
      expect(subject.perform.status_code).to eql(201)
    end
  end
end
