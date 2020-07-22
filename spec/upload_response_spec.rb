require 'spec_helper'
require_relative '../lib/tusc/upload_response'

RSpec.describe TusClient::UploadResponse do
  let(:complete_response) do
    OpenStruct.new(code: 204, header: {'Upload-Offset' => '-100'})
  end

  let(:incomplete_response) do
    OpenStruct.new(code: 200, header: {'Upload-Offset' => '-1'})
  end

  context '(incomplete upload)' do
    subject(:response) { TusClient::UploadResponse.new(incomplete_response) }

    it "#offset retrieves 'Upload-Offset' header" do
      expect(subject.offset).to eql(-1)
    end

    it "#status_code retrieves 'success' http code (200)" do
      expect(subject.status_code).to eql(200)
    end
  end

  context '(complete upload)' do
    subject(:response) { TusClient::UploadResponse.new(complete_response) }

    it "#offset retrieves 'Upload-Offset' header" do
      expect(subject.offset).to eql(-100)
    end

    it "#status_code retrieves 'No Content' http code (204)" do
      expect(subject.status_code).to eql(204) # No content
    end
  end
end
