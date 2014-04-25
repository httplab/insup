require_relative '../../spec_helper'

describe 'Insup::Git' do
  it 'should get status' do
    git = Insup::Git.new(Dir.getwd)
    puts git.status
  end
end
