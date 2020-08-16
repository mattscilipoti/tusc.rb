require 'spec_helper'
require_relative 'shared_examples/shared_examples_for_responses'

require_relative '../lib/tusc/options_response'

RSpec.describe TusClient::OptionsResponse do
  let(:expected_max_chunk_size) { '1073741824' }
  let(:expected_supported_extensions) { 'creation,expiration' }
  let(:expected_supported_versions) { '1.0.0,0.2.2,0.2.1' }
  let(:expected_supported_checksums) { 'sha512,md5' }

  let(:success_response) do
    OpenStruct.new(
      code: '204',
      header: {
        'Tus-Checksum-Algorithm' => expected_supported_checksums,
        'Tus-Extension' => expected_supported_extensions,
        'Tus-Max-Size' => expected_max_chunk_size,
        'Tus-Resumable' => '1.0.0',
        'Tus-Version' => expected_supported_versions,
      }
    )
  end

  subject(:response) { TusClient::OptionsResponse.new(success_response) }

  it_behaves_like 'all response objects'

  it "#max_chunk_size retrieves 'Tus-Max-Size' header" do
    expect(subject.max_chunk_size).to eql(expected_max_chunk_size)
  end

  it "#supported_checksums retrieves 'Tus-Checksum-Algorithm' header" do
    expect(subject.supported_checksums).to eql(expected_supported_checksums)
  end

  it "#supported_extensions retrieves 'Tus-Extension' header" do
    expect(subject.supported_extensions).to eql(expected_supported_extensions)
  end

  it "#supported_versions retrieves 'Tus-Version' header" do
    expect(subject.supported_versions).to eql(expected_supported_versions)
  end

  it 'should be #success?' do
    expect(subject).to be_success
  end
end
