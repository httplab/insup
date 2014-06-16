require_relative '../../spec_helper'

describe Insup::Git do
  it 'should get status' do
    expect{git = described_class.new(Dir.getwd)}.not_to raise_error
  end
end
