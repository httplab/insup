require_relative '../../spec_helper'

describe 'Insup::Tracker' do

  before(:each) do
    @tracker = Insup::Tracker.new()
  end

  it 'should list all tracked files' do
    tracked_files = @tracker.tracked_files
    locations = Insup::Settings.instance.tracked_locations

    expect do
      tracked_files.all? do |file|
        locations.any? do |loc|
          file.include?("#{loc}/")
        end
      end
    end.to be_true
  end

end
