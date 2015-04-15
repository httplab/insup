describe Insup::Git do
  it 'gets status' do
    expect { described_class.new(Dir.getwd) }.not_to raise_error
  end

  it 'fails if not a git repository' do
    dir = Dir.mktmpdir('insup_specs')
    expect { described_class.new(dir) }.to raise_error(Insup::Exceptions::NotAGitRepositoryError)
  end
end
