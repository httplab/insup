describe Insup::TrackedFile do
  it 'creates instance correctly' do
    expect { described_class.new('media/application.css', Insup::TrackedFile::NEW) }.not_to raise_error
  end

  it 'fails if absolute path given' do
    expect { described_class.new('/a/b/c', Insup::TrackedFile::NEW) }.to raise_error(Insup::Exceptions::InsupError)
  end

  describe '#file_name' do
    it 'works' do
      f = described_class.new('media/application.css', Insup::TrackedFile::NEW)
      expect(f.file_name).to eq('application.css')

      f = described_class.new('media/mbon.js', Insup::TrackedFile::NEW)
      expect(f.file_name).to eq('mbon.js')
    end
  end

  describe '#absolute_path' do
    it 'works with regular paths' do
      base = '/home/shakespeare/projets/hamlet'
      f = described_class.new('characters/romeo.rb', Insup::TrackedFile::NEW)
      expect(f.absolute_path(base)).to eq('/home/shakespeare/projets/hamlet/characters/romeo.rb')
    end

    it 'works with double dotted paths' do
      base = '/home/shakespeare/projets/hamlet/../hamlet'
      f = described_class.new('characters/romeo.rb', Insup::TrackedFile::NEW)
      expect(f.absolute_path(base)).to eq('/home/shakespeare/projets/hamlet/characters/romeo.rb')
    end

    it 'works with single dotted paths' do
      base = '/home/shakespeare/projets/./hamlet/.'
      f = described_class.new('characters/romeo.rb', Insup::TrackedFile::NEW)
      expect(f.absolute_path(base)).to eq('/home/shakespeare/projets/hamlet/characters/romeo.rb')
    end

    it 'fails if base path is not absolute' do
      base = 'hamlet'
      f = described_class.new('characters/romeo.rb', Insup::TrackedFile::NEW)
      expect { f.absolute_path(base) }.to raise_error(Insup::Exceptions::InsupError)
    end
  end
end
