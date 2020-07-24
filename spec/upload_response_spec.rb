require 'spec_helper'
require_relative 'shared_examples/shared_examples_for_responses'

require_relative '../lib/tusc/upload_response'

RSpec.describe TusClient::UploadResponse do
  let(:file_size) { 10 }

  context '(incomplete upload)' do
    let(:incomplete_response) do
      OpenStruct.new(code: 200, header: { 'Upload-Offset' => '1' })
    end

    subject(:response) do
      TusClient::UploadResponse.new(incomplete_response, file_size)
    end

    it "#offset retrieves 'Upload-Offset' header" do
      expect(subject.offset).to eql(1)
    end

    it "#status_code retrieves 'success' http code (200)" do
      expect(subject.status_code).to eql(200)
    end

    it 'indicates incomplete' do
      expect(subject).to be_incomplete
    end

    it 'does NOT indicate success' do
      expect(subject).to_not be_success
    end
  end

  context '(complete upload)' do
    let(:complete_response) do
      OpenStruct.new(code: 204, header: { 'Upload-Offset' => file_size.to_s })
    end

    subject(:response) do
      TusClient::UploadResponse.new(complete_response, file_size)
    end

    it_behaves_like 'all response objects'

    it "#offset retrieves 'Upload-Offset' header" do
      expect(subject.offset).to eql(file_size)
    end

    it "#status_code retrieves 'No Content' http code (204)" do
      expect(subject.status_code).to eql(204) # No content
    end

    it 'indicates success' do
      expect(subject).to be_success
    end
  end
end
