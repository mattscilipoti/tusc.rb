require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/uploader'

RSpec.describe 'TusClient::Uploader (class methods)' do
  describe '.from_file_path (factory method)' do
    it 'creates new Uploader with File object' do
      expect(
        TusClient::Uploader.from_file_path(
          file_path: __FILE__,
          upload_url: 'https://example.com'
        )
      ).to be_a(TusClient::Uploader)
    end

    it 'should raise error if filepath is empty' do
      expect do
        TusClient::Uploader.from_file_path(file_path: nil, upload_url: nil)
      end.to raise_error(ArgumentError, /file_path.*required/)
    end

    it 'should raise error if file does not exist' do
      expect do
        TusClient::Uploader.from_file_path(file_path: 'non_existent_file.jpg', upload_url: nil)
      end.to raise_error(ArgumentError, /file does NOT exist/)
    end
  end

  describe '.new' do
    let(:mock_file) { io = StringIO.new('abc') }
    let(:upload_url) { 'https://tus.io/uploads' }

    it 'io is required' do
      expect do
        TusClient::Uploader.new(io: nil, upload_url: upload_url)
      end.to raise_error(ArgumentError, /must respond to/)

      expect do
        TusClient::Uploader.new(io: '', upload_url: upload_url)
      end.to raise_error(ArgumentError, /must respond to/)
    end

    it 'upload_url is required' do
      expect do
        TusClient::Uploader.new(io: mock_file, upload_url: nil)
      end.to raise_error(ArgumentError, /upload_url is required/)

      expect do
        TusClient::Uploader.new(io: mock_file, upload_url: '')
      end.to raise_error(ArgumentError, /upload_url is required/)
    end

    it 'upload_url must be a valid URL' do
      expect do
        TusClient::Uploader.new(io: mock_file, upload_url: 'foo')
      end.to raise_error(ArgumentError, /upload_url must be a valid url/)
    end
  end
end

RSpec.describe TusClient::Uploader do
  subject(:uploader) do
    TusClient::Uploader.new(
      io: mock_file,
      upload_url: upload_url
    )
  end

  let(:mock_file) { io = StringIO.new('abc') }
  let(:upload_url) { 'https://tus.io/uploads' }

  describe '#content_type' do
    it 'detects type from io' do
      expect(subject).to receive(:detect_content_type).and_return('detected_type')

      expect(subject.content_type).to eql('detected_type')
    end

    it 'falls back to default (octet-stream)' do
      expect(subject).to receive(:detect_content_type).and_return(nil)

      expect(subject.content_type).to eql(subject.default_content_type)
    end
  end

  describe '#detect_content_type' do
    it 'uses MimeMagic' do
      expect(MimeMagic).to receive(:by_magic).with(subject.io)
      subject.detect_content_type
    end

    it 'retrieves appropriate content_type, using MimeMagic' do
      uploader = TusClient::Uploader.from_file_path(
        file_path: File.expand_path('bin/console'), # ruby file
        upload_url: 'https://example.com'
      )
      expect(uploader.detect_content_type).to eql('application/x-ruby')
    end

    it 'returns nil, if MimeMagic cannot identify' do
      uploader = TusClient::Uploader.new(
        io: StringIO.new('unknown type'),
        upload_url: 'https://example.com'
      )
      expect(uploader.detect_content_type).to be_nil
    end
  end

  describe '#headers' do
    it 'includes Content-Type: octet-stream' do
      expect(subject.headers).to include('Content-Type' => 'application/offset+octet-stream')
    end

    it 'includes Tus-Resumable: 1.0' do
      expect(subject.headers).to include('Tus-Resumable' => '1.0.0')
    end

    it 'includes Upload-Offset: 0' do
      expect(subject.headers).to include('Upload-Offset' => '0')
    end
  end

  describe '#offset_requester' do
    it 'returns an new OffsetRequester' do
      expect(uploader.offset_requester).to be_a(TusClient::OffsetRequest)
    end

    it 'returns an new OffsetRequester, using upload_url' do
      request = uploader.offset_requester
      expect(request.upload_uri.to_s).to eql(uploader.upload_url)
    end
  end

  describe '#retrieve_offset' do
    before(:each) do
      # Mock the tus server
      stub_request(:head, upload_url)
        .to_return(headers: { 'Upload-Offset' => '123' })
    end

    it 'requests offset from tus server' do
      expect(subject.retrieve_offset).to eql(123)
    end
  end

  describe '#perform (mocked)' do
    context '(succcessful upload)' do
      # Setup a mock file with 3 characters, chunk_size==1
      # Mock tus server responses

      before(:each) do
        # Mock the tus server
        # Increment the Upload-Offset on each request
        stub_request(:patch, upload_url)
          .with(headers: { 'Upload-Offset' => '0' })
          .to_return(headers: { 'Upload-Offset' => '1' })

        stub_request(:patch, upload_url)
          .with(headers: { 'Upload-Offset' => '1' })
          .to_return(headers: { 'Upload-Offset' => '2' })

        stub_request(:patch, upload_url)
          .with(headers: { 'Upload-Offset' => '2' })
          .to_return(
            headers: { 'Upload-Offset' => '3' },
            status: 204 # No Content
          )
      end

      let(:mock_chunk_size) { 1 }
      let(:mock_file_contents) { 'abc' }
      let(:mock_file_size) { mock_file_contents.size }

      let(:mock_file) do
        instance_double('File').tap do |io|
          allow(io).to receive(:rewind)
          allow(io).to receive(:size).and_return(3) # size of mock_file_contents
          # webmock returns an incrementing Upload-Offset
          allow(io).to receive(:read).with(1, 0).and_return('a')
          allow(io).to receive(:read).with(1, 1).and_return('b')
          allow(io).to receive(:read).with(1, 2).and_return('c')
          expect(io).to receive(:close)
        end
      end

      let(:upload_url) { 'https://tus.example.com/uploads' }

      subject(:uploader) do
        TusClient::Uploader.new(
          io: mock_file,
          upload_url: upload_url
        ).tap do |uploader|
          allow(uploader).to receive(:chunk_size).and_return(mock_chunk_size)
          allow(uploader).to receive(:content_type).and_return(uploader.default_content_type)
          allow(uploader).to receive(:retrieve_offset).and_return(0)
        end
      end

      it 'returns the last UploadResponse' do
        response = uploader.perform
        expect(response).to be_a(TusClient::UploadResponse)
        expect(response.status_code).to eql(204) # No Content
        expect(response.offset).to eql(mock_file_size)
      end

      it 'rewinds the file' do
        expect(mock_file).to receive(:rewind)
        uploader.perform
      end

      it 'uploads the file one chunk at a time' do
        expect(subject).to receive(:push_chunk).exactly(3).times.and_call_original
        uploader.perform
      end
    end
  end

  context '(with passed headers)' do
    before(:each) do
      # Mock the tus server
      stub_request(:head, upload_url)
        .with(headers: headers)
        .to_return(headers: { 'Upload-Offset' => '234' })

      stub_request(:patch, upload_url)
        .with(headers: headers)
        .to_return(headers: { 'Upload-Offset' => '345' })
    end

    let(:headers) do
      { 'Passed-Header' => 'has been included' }
    end

    let(:mock_file) do
      instance_double('File', size: 3, read: 'abc').tap do |mock_file|
        allow(mock_file).to receive(:rewind)
        allow(mock_file).to receive(:close)
      end
    end

    subject(:uploader) do
      TusClient::Uploader.new(
        io: mock_file,
        upload_url: upload_url,
        extra_headers: headers
      ).tap do |uploader|
        allow(uploader).to receive(:chunk_size).and_return(3)
        allow(uploader).to receive(:content_type).and_return(uploader.default_content_type)
      end
    end

    it '#perform passes the headers to http call' do
      # checked by the stub_request above
      response = subject.perform
      expect(response.offset).to eql(345)
    end

    it '#retrieve_offset passes the headers to http call' do
      # checked by the stub_request above
      response = subject.retrieve_offset
      expect(response).to eql(234)
    end
  end
end
