require 'spec_helper'
require_relative '../lib/tusc/offset_response'

RSpec.describe TusClient::OffsetResponse do
  let(:success_response) do
    OpenStruct.new(header: {'Upload-Offset' => '-1'})
  end

  subject(:response) { TusClient::OffsetResponse.new(success_response) }

  it "#offset retrieves 'Upload-Offset' header" do
    expect(subject.offset).to eql(-1)
  end
end
