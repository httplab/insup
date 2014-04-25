require_relative '../../spec_helper'

describe 'Insup::Settings' do
  before(:each) do
    @settings = Insup::Settings.new('spec/support/.insup')
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

  it 'should have correct ignore paths' do
    expect(@settings.ignore_patterns).to include('*.swp')
  end

end
