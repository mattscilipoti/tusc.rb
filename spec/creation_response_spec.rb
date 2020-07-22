require 'spec_helper'
require_relative '../lib/tusc/creation_response'

RSpec.describe TusClient::CreationResponse do
  let(:success_response) do
    OpenStruct.new(header: {'Location' => 'success.example.com'})
  end

  subject(:response) { TusClient::CreationResponse.new(success_response) }

  it "#upload_url retrieves 'Location' header" do
    expect(subject.upload_uri.to_s).to eql('success.example.com')
  end
end
