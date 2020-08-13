require 'spec_helper'
require 'digest' # for checksums
require_relative '../lib/tusc'

RSpec.describe 'TusClient: uploading to a local tus server', :requires_tus_server do
  tus_server_storage_dir = Pathname('./data') # default for tus-server gem
  tus_server_uri = URI.parse('http://localhost:9292/files') # started manually, via bin/rackup

  before(:all) do
    response = Net::HTTP.start(tus_server_uri.host, tus_server_uri.port) do |http|
      http.options(tus_server_uri.path)
    end
    if response.code != '204'
      raise 'ACTION NEEDED: Please start the TEST tus server maually, via $`bin/rackup`'
    end # No content
  rescue Errno::ECONNREFUSED => e
    raise "ACTION NEEDED: Please start the TEST tus server maually, via $`bin/rackup`\n  #{e.message}"
  end

  before(:all) do
    FileUtils.rm_r(tus_server_storage_dir) if tus_server_storage_dir.exist?
  end

  after(:all) do
    FileUtils.rm_r(tus_server_storage_dir) if tus_server_storage_dir.exist?
  end

  describe TusClient::CreationRequest do
    let(:upload_id_regex) { /[a-z0-9]{32}/ } # for file id provided by tus-server

    subject(:request) do
      test_file_name_and_path = File.expand_path(File.join('spec', 'fixtures', 'test_file.txt'))
      TusClient::CreationRequest.new(
        file_size: File.size(test_file_name_and_path),
        tus_creation_url: tus_server_uri.to_s
      )
    end

    it 'returns 201 & upload_url' do
      response = subject.perform
      expect(response.status_code).to eql(201) # Created
      expect(response.upload_uri.path).to match(%r{files/#{upload_id_regex}})
    end
  end

  RSpec.shared_examples 'uploading a file' do
    it 'returns 204 and final offset' do
      response = uploader.perform

      expect(response.status_code).to eql(204) # No content
      expect(response.offset).to eql(File.size(test_file_name_and_path))
    end

    it 'has uploaded the file to the tus server' do
      uploader.perform

      uploaded_filename = uploader.upload_uri.path.split('/').last
      uploaded_file_name_and_path = tus_server_storage_dir.join(uploaded_filename)
      expect(uploaded_file_name_and_path).to exist
      expect(File.size(uploaded_file_name_and_path)).to be_positive

      uploaded_file_hash = Digest::MD5.file(uploaded_file_name_and_path)
      mock_file_hash = Digest::MD5.file(test_file_name_and_path)
      expect(uploaded_file_hash).to eq(mock_file_hash)
    end
  end

  describe TusClient::Uploader do
    context '(text file, via File.open block)' do
      let(:test_file_name_and_path) do
        File.expand_path(File.join('spec', 'fixtures', 'test_file.txt'))
      end

      subject(:uploader) do
        File.open(test_file_name_and_path) do |file|
          creator = TusClient::CreationRequest.new(
            file_size: file.size,
            tus_creation_url: tus_server_uri.to_s
          )

          creation_response = creator.perform

          new_file_uri = creation_response.upload_uri

          TusClient::Uploader.from_file_path(
            file_path: test_file_name_and_path,
            upload_url: new_file_uri.to_s
          )
        end
      end

      it_behaves_like 'uploading a file'
    end

    context '(video file, via Uploader.from_file_path)' do
      let(:test_file_name_and_path) do
        File.expand_path(File.join('spec', 'fixtures', 'test_video.m4v'))
      end

      subject(:uploader) do
        creator = TusClient::CreationRequest.new(
          file_size: File.size(test_file_name_and_path),
          tus_creation_url: tus_server_uri.to_s
        )

        creation_response = creator.perform

        new_file_uri = creation_response.upload_uri

        TusClient::Uploader.from_file_path(
          file_path: test_file_name_and_path,
          upload_url: new_file_uri.to_s
        )
      end

      it_behaves_like 'uploading a file'
    end

    context '(video file, chunk size is much smaller than video)' do
      let(:test_file_name_and_path) do
        File.expand_path(File.join('spec', 'fixtures', 'test_video.m4v'))
      end

      subject(:uploader) do
        file_size = File.size(test_file_name_and_path)
        allow(TusClient::Uploader).to receive(:chunk_size).and_return((file_size / 10).floor)
        creator = TusClient::CreationRequest.new(
          file_size: file_size,
          tus_creation_url: tus_server_uri.to_s
        )

        creation_response = creator.perform

        new_file_uri = creation_response.upload_uri

        TusClient::Uploader.from_file_path(
          file_path: test_file_name_and_path,
          upload_url: new_file_uri.to_s
        ).tap do |uploader|
          # verify we upload 10 chunks + 1 partial
          expect(uploader).to receive(:push_chunk).exactly(10 + 1).times.and_call_original
        end
      end

      it_behaves_like 'uploading a file'
    end
  end
end
