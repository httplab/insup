describe Insup::Uploader do
  it 'fails if base directory path is not absolute' do
    expect { described_class.new('hamlet') }
      .to raise_error(Insup::Exceptions::InsupError)
  end

  it 'creates instance' do
    expect { described_class.new('/home/shakespeare/projects/hamlet') }
      .not_to raise_error
  end
end
