RSpec.shared_examples 'all response objects' do
  it 'responds to #status_code' do
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
