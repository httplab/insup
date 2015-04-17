describe Insup::Settings do
  subject { described_class.new('spec/support/.insup') }

  it 'has correct tracker' do
    expect(subject.tracker['class']).to eq('Insup::Tracker::GitTracker')
  end

  it 'has correct uploader' do
    expect(subject.uploader['class']).to eq('Insup::Uploader::InsalesUploader')
  end

  it 'has correct ignore paths' do
    expect(subject.ignore_patterns).to include('*.swp')
  end
end
