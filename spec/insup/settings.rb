require_relative '../../lib/insup.rb'

describe 'Insup::Settings' do
  before(:each) do
    @settings = Insup::Settings.new('development', 'spec/support/.insup')
  end

  it 'should have correct tracked locations' do
    expect(['media', 'templates', 'snippets'] - @settings.tracked_locations).to be_empty
  end

  it 'should have correct tracker' do
    expect(@settings.tracker['class']).to eq ('Insup::Tracker::GitTracker')
  end

  it 'should have correct uploader' do
    expect(@settings.uploader['class']).to eq ('Insup::Uploader::InsalesUploader')
  end

  it 'should distinguish environments' do
    @settings = Insup::Settings.new('development', 'spec/support/.insup')
    dev_theme_id = @settings.uploader['theme_id']

    @settings = Insup::Settings.new('production', 'spec/support/.insup')
    prod_theme_id = @settings.uploader['theme_id']

    expect(dev_theme_id).to eq(1)
    expect(prod_theme_id).to eq(2)
  end

  it 'should have correct ignore paths' do
    @settings = Insup::Settings.new('development', 'spec/support/.insup')
    expect(@settings.ignore_patterns).to include('*.js')

    @settings = Insup::Settings.new('production', 'spec/support/.insup')
    expect(@settings.ignore_patterns.size).to eq(3)
  end

end
