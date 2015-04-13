describe Insup::Settings do
  before(:each) do
    @settings = described_class.new('spec/support/.insup')
  end

  it 'has correct tracked locations' do
    expect(%w('media', 'templates', 'snippets') - @settings.tracked_locations).to be_empty
  end

  it 'has correct tracker' do
    expect(@settings.tracker['class']).to eq('Insup::Tracker::GitTracker')
  end

  it 'has correct uploader' do
    expect(@settings.uploader['class']).to eq('Insup::Uploader::InsalesUploader')
  end

  it 'has correct ignore paths' do
    expect(@settings.ignore_patterns).to include('*.swp')
  end
end
