require 'spec_helper'
require_relative '../lib/tusc/creation_response'

RSpec.describe TusClient::CreationResponse do
  context '(response is success: 201 & "Location" header)' do
    let(:success_response) do
      OpenStruct.new(code: 201, header: { 'Location' => 'https://success.example.com' })
    end

    subject(:response) { TusClient::CreationResponse.new(success_response) }

    it "#upload_url retrieves 'Location' header" do
      expect(subject.upload_uri.to_s).to eql('https://success.example.com')
    end

    it 'should be #success?' do
      expect(subject).to be_success
    end
  end

  context '(response does NOT contain "Location" header)' do
    # e.g. vimeo tus server does NOT return Location header
    let(:partial_success) do
      OpenStruct.new(code: 201)
    end
    subject(:response) { TusClient::CreationResponse.new(partial_success) }

    it 'should be #success?' do
      expect(subject).to be_success
    end

    it '#upload_uri is nil' do
      expect(subject.upload_uri).to be_nil
    end
  end

  context '(response code is not 201:created)' do
    let(:failure_response) do
      OpenStruct.new(code: 500)
    end
    subject(:response) { TusClient::CreationResponse.new(failure_response) }

    it 'should NOT be a #success?' do
      expect(subject).to_not be_success
    end

    it '#upload_uri is nil' do
      expect(subject.upload_uri).to be_nil
    end
  end
end
