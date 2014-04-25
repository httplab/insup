require_relative '../../spec_helper'

describe 'Insup::Tracker' do

  before(:each) do
    @tracker = Insup::Tracker.new()
  end

  it 'should have correct tracked locations' do
    puts @tracker.tracked_files
  end

end
