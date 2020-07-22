require 'spec_helper'
require 'webmock/rspec'
require_relative '../lib/tusc/uploader'

RSpec.describe TusClient::Uploader do
  describe '(class methods)' do
    describe '.from_file_path (factory method)' do
      it 'should raise error if filepath is empty' do
        expect{
          TusClient::Uploader.from_file_path(file_path: nil, upload_url: nil)
        }.to raise_error(ArgumentError, /file_path.*required/)
      end

      it 'should raise error if file does not exist' do
        expect{
          TusClient::Uploader.from_file_path(file_path: 'non_existent_file.jpg', upload_url: nil)
        }.to raise_error(ArgumentError, /file does NOT exist/)
      end
    end

    describe '.new' do
      let(:mock_file) { io = StringIO.new("abc") }
      let(:upload_url) { 'https://tus.io/uploads' }

      it 'io is required' do
        expect{
          TusClient::Uploader.new(io: nil, upload_url: upload_url)
        }.to raise_error(ArgumentError, /must respond to/)

        expect{
          TusClient::Uploader.new(io: '', upload_url: upload_url)
        }.to raise_error(ArgumentError, /must respond to/)
      end

      it 'upload_url is required' do
        expect{
          TusClient::Uploader.new(io: mock_file, upload_url: nil)
        }.to raise_error(ArgumentError, /upload_url is required/)

        expect{
          TusClient::Uploader.new(io: mock_file, upload_url: '')
        }.to raise_error(ArgumentError, /upload_url is required/)
      end

      it 'upload_url must be a valid URL' do
        expect{
          TusClient::Uploader.new(io: mock_file, upload_url: 'foo')
        }.to raise_error(ArgumentError, /upload_url must be a valid url/)
      end
    end
  end

  describe '(succcessful upload)' do
    subject(:uploader) { TusClient::Uploader.new(
      io: mock_file,
      upload_url: upload_url,
    )}

    let(:mock_file) { io = StringIO.new("abc") }
    let(:upload_url) { 'https://tus.io/uploads' }

    describe '#get_content_type' do
      it 'uses MimeMagic' do
        expect(MimeMagic).to receive(:by_magic).with(subject.io)
        subject.get_content_type
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

    describe '#perform (mocked)' do
      # Setup a mock file with 3 characters, chunk_size==1
      # Mock tus server responses

      before(:each) do
        # Mock the tus server
        # Increment the Upload-Offset on each request
        stub_request(:patch, upload_url).
          with(headers: { 'Upload-Offset' => '0' }).
          to_return(headers: {'Upload-Offset' => '1'})

        stub_request(:patch, upload_url).
          with(headers: { 'Upload-Offset' => '1' }).
          to_return(headers: {'Upload-Offset' => '2'})

        stub_request(:patch, upload_url).
          with(headers: { 'Upload-Offset' => '2' }).
          to_return(
            headers: {'Upload-Offset' => '3'},
            status: 204, # No Content
          )
      end

      let(:mock_chunk_size) { 1 }
      let(:mock_file_contents) { 'abc' }
      let(:mock_file_size) { mock_file_contents.size }

      let(:mock_file) do
        instance_double("File").tap do |io|
          allow(io).to receive(:rewind)
          allow(io).to receive(:size).and_return(3) # size of mock_file_contents
          # webmock returns an incrementing Upload-Offset
          allow(io).to receive(:read).with(1,0).and_return('a')
          allow(io).to receive(:read).with(1,1).and_return('b')
          allow(io).to receive(:read).with(1,2).and_return('c')
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
          allow(uploader).to receive(:offset).and_return(0)
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
end
