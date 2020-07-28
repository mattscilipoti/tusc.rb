require 'spec_helper'
require_relative 'shared_examples/shared_examples_for_responses'

require_relative '../lib/tusc/upload_response'

RSpec.describe TusClient::UploadResponse do
  let(:file_size) { 10 }
  let(:complete_response) do
    OpenStruct.new(code: 204, header: { 'Upload-Offset' => file_size.to_s })
  end

  subject(:response) do
    TusClient::UploadResponse.new(complete_response, file_size)
  end

  describe '#complete?' do
    it 'returns true when offset > file_size' do
      allow(subject).to receive(:file_size).and_return(10)
      allow(subject).to receive(:offset).and_return(11)
      expect(subject).to be_complete
    end

    it 'returns true when offset == file_size' do
      allow(subject).to receive(:file_size).and_return(20)
      allow(subject).to receive(:offset).and_return(20)
      expect(subject).to be_complete
    end

    it 'returns false when offset < file_size' do
      allow(subject).to receive(:file_size).and_return(10)
      allow(subject).to receive(:offset).and_return(9)
      expect(subject).to_not be_complete
    end
  end

  describe '#incomplete?' do
    it 'returns true when offset < file_size' do
      allow(subject).to receive(:file_size).and_return(10)
      allow(subject).to receive(:offset).and_return(9)
      expect(subject).to be_incomplete
    end

    it 'returns false when offset == file_size' do
      allow(subject).to receive(:file_size).and_return(20)
      allow(subject).to receive(:offset).and_return(20)
      expect(subject).to_not be_incomplete
    end

    it 'returns false when offset > file_size' do
      allow(subject).to receive(:file_size).and_return(10)
      allow(subject).to receive(:offset).and_return(11)
      expect(subject).to_not be_incomplete
    end
  end

  describe '#success?' do
    it 'returns true when status_code == 200' do
      allow(subject).to receive(:status_code).and_return(200)
      expect(subject).to be_success
    end

    it 'returns true when status_code == 204' do
      allow(subject).to receive(:status_code).and_return(204)
      expect(subject).to be_success
    end

    it 'returns false when status_code not in [200, 204]' do
      allow(subject).to receive(:status_code).and_return(500)
      expect(subject).to_not be_success
    end
  end

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

    it 'does NOT indicate complete' do
      expect(subject).to_not be_complete
    end

    it 'indicates success' do
      expect(subject).to be_success
    end
  end

  context '(complete upload)' do
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
