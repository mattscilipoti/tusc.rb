RSpec.shared_examples 'all response objects' do
  describe '#body' do
    it 'provides the response body as string' do
      expect(subject).to receive(:raw).and_return(OpenStruct.new(body: 'abcd'.to_json))
      expect(subject.body).to eql('abcd')
    end

    it 'returns empty string, rather than JSON error, when body is nil' do
      expect(subject).to receive(:raw).and_return(OpenStruct.new(body: nil))
      expect(subject.body).to eql('')
    end

    it 'returns empty string, rather than JSON error, when body is blank' do
      expect(subject).to receive(:raw).and_return(OpenStruct.new(body: ''))
      expect(subject.body).to eql('')
    end
  end

  it 'provides the #status_code, as Integer' do
    expect(subject).to respond_to(:status_code)
    expect(subject.status_code).to be_an(Integer)
  end

  it 'provides the underlying response (via #raw)' do
    expect(subject).to respond_to(:raw)
    expect(subject.raw).to respond_to(:code)
    expect(subject.raw).to respond_to(:header)
  end

  it 'responds to #success?' do
    expect(subject).to respond_to(:success?)
  end
end
