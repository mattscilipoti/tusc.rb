require 'spec_helper'
require 'digest' # for checksums
require_relative '../lib/tusc'

RSpec.describe 'TusClient: uploading to a tus server' do
  tus_server_storage_dir = Pathname('./data') # default for tus-server gem
  tus_server_uri = URI.parse('http://localhost:9292/files') # started manually, via rackup

  before(:all) do
    response = Net::HTTP.start(tus_server_uri.host, tus_server_uri.port) do |http|
      http.options(tus_server_uri.path)
    end
    if response.code != '204'
      raise 'ACTION NEEDED: Please start the TEST tus server maually, via $`rackup`'
    end # No content
  rescue Errno::ECONNREFUSED => e
    raise "ACTION NEEDED: Please start the TEST tus server maually, via $`rackup`\n  #{e.message}"
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
  end
end
