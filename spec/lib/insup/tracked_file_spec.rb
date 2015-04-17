describe Insup::TrackedFile do
  it 'creates instance correctly' do
    expect { described_class.new('media/application.css') }.not_to raise_error
  end

  it 'fails if absolute path given' do
    expect { described_class.new('/a/b/c') }
      .to raise_error(Insup::Exceptions::InsupError)
  end

  describe '#file_name' do
    it 'works' do
      f = described_class.new('media/application.css')
      expect(f.file_name).to eq('application.css')

      f = described_class.new('media/mbon.js')
      expect(f.file_name).to eq('mbon.js')
    end
  end

  describe '#absolute_path' do
    subject(:subject) { described_class.new('characters/romeo.rb') }
    let(:romeo) { '/home/shakespeare/projets/hamlet/characters/romeo.rb' }

    it 'works with regular paths' do
      base = '/home/shakespeare/projets/hamlet'
      expect(subject.absolute_path(base)).to eq(romeo)
    end

    it 'works with double dotted paths' do
      base = '/home/shakespeare/projets/hamlet/../hamlet'
      expect(subject.absolute_path(base)).to eq(romeo)
    end

    it 'works with single dotted paths' do
      base = '/home/shakespeare/projets/./hamlet/.'
      expect(subject.absolute_path(base)).to eq(romeo)
    end

    it 'fails if base path is not absolute' do
      base = 'hamlet'
      expect { subject.absolute_path(base) }
        .to raise_error(Insup::Exceptions::InsupError)
    end
  end

  describe '#exist?' do
    it 'works when file exists' do
      base = Dir.mktmpdir
      File.write(File.join(base, 'a.txt'), 'hi')
      f = described_class.new('a.txt')
      expect(f).to exist(base)
    end

    it "works when file doesn't exist" do
      base = Dir.mktmpdir
      f = described_class.new('a.txt')
      expect(f).not_to exist(base)
    end
  end

  states_hash = {
    Insup::TrackedFile::NEW => 'new',
    Insup::TrackedFile::MODIFIED => 'modified',
    Insup::TrackedFile::DELETED => 'deleted',
    Insup::TrackedFile::UNSURE => 'unsure'
  }

  context 'states' do
    states_hash.each do |state, method|
      describe "##{method}?" do
        it 'works' do
          others = (states_hash.values - [method]).map do |s|
            described_class.new('a.txt', s)
          end

          current_state_file = described_class.new('a.txt', state)
          expect(current_state_file.send("#{method}?")).to be_truthy
          others.each do |other|
            expect(other.send("#{method}?")).to be_falsy
          end
        end
      end
    end
  end
end
