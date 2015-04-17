describe Insup::Listener do
  let(:base) { Dir.mktmpdir }
  let(:tracked_dir) do
    fname = File.join(base, 'tracked_dir')
    Dir.mkdir(fname)
    fname
  end

  subject(:subject) do
    described_class.new(base, tracked_locations: ['tracked_dir'])
  end

  describe '#prepare_flags' do
    it 'works correctly' do
      cases = {
        [%w(b), %w(a), %w(c)] => { 'a' => 4, 'b' => 2, 'c' => 1 },
        [%w(a), %w(a), %w(a)] => { 'a' => 7 },
        [[], [], []] => {},
        [%w(a), %w(b), %w(a)] => { 'a' => 3, 'b' => 4 },
        [%w(a), %w(b), %w(a)] => { 'a' => 3, 'b' => 4 }
      }

      cases.each do |c, result|
        expect(subject.send(:prepare_flags, *c)).to eq(result)
      end
    end
  end

  describe '#create_tracked_file' do
    it 'works correctly' do
      expect(subject.send(:create_tracked_file, 1, 'a')).to be_deleted
      expect(subject.send(:create_tracked_file, 2, 'a')).to be_modified
      expect(subject.send(:create_tracked_file, 3, 'a')).to be_deleted
      expect(subject.send(:create_tracked_file, 4, 'a')).to be_new
      expect(subject.send(:create_tracked_file, 5, 'a')).to be_nil
      expect(subject.send(:create_tracked_file, 6, 'a')).to be_new
      expect(subject.send(:create_tracked_file, 7, 'a')).to be_nil
    end

    it 'returns unsure if file exists' do
      File.write(File.join(base, 'a'), 'Hi')
      expect(subject.send(:create_tracked_file, 5, 'a')).to be_unsure
      expect(subject.send(:create_tracked_file, 7, 'a')).to be_unsure
    end
  end

  describe '#prepare_changes' do
    it 'works correctly' do
      expect(subject.send(:prepare_changes, 'a' => 1)).to have_exactly(1).item
      expect(subject.send(:prepare_changes, 'a' => 2)).to have_exactly(1).item
      expect(subject.send(:prepare_changes, 'a' => 3)).to have_exactly(1).item
      expect(subject.send(:prepare_changes, 'a' => 4)).to have_exactly(1).item
      expect(subject.send(:prepare_changes, 'a' => 5)).to be_empty
      expect(subject.send(:prepare_changes, 'a' => 6)).to have_exactly(1).item
      expect(subject.send(:prepare_changes, 'a' => 7)).to be_empty
    end

    it 'returns unsure if file exists' do
      File.write(File.join(base, 'unsure1'), 'Hi')
      expect(subject.send(:prepare_changes, 'unsure1' => 5))
        .to have_exactly(1).item
      expect(subject.send(:prepare_changes, 'unsure1' => 7))
        .to have_exactly(1).item
    end
  end

  context 'listen', listen: true do
    let(:handler) { Object.new }
    let(:delay) { 0.2 }

    before(:each) do
      tracked_dir
      subject.listen { |changes| handler.handle(changes) }
    end

    after(:each) do
      subject.stop
    end

    it 'listens to file changes' do
      expect(handler).to receive(:handle)

      fname = File.join(tracked_dir, 'a')
      File.write(fname, '')
      sleep(delay)

      expect(handler).to receive(:handle)

      open(fname, 'a') do |f|
        f << "some changes...\n"
      end
      sleep(delay)

      expect(handler).to receive(:handle)

      File.unlink(fname)
      sleep(delay)
    end
  end

  context 'polling', listen: true do
    let(:handler) { Object.new }
    let(:delay) { 1 }

    subject(:subject) do
      described_class.new(
        base,
        tracked_locations: ['tracked_dir'],
        force_polling: true
      )
    end

    before(:each) do
      tracked_dir
      subject.listen { |changes| handler.handle(changes) }
    end

    after(:each) do
      subject.stop
    end

    it 'listens to file changes' do
      expect(handler).to receive(:handle)

      fname = File.join(tracked_dir, 'a')
      File.write(fname, '')
      sleep(delay)

      expect(handler).to receive(:handle)

      open(fname, 'a') do |f|
        f << "some changes...\n"
      end
      sleep(delay)

      expect(handler).to receive(:handle)

      File.unlink(fname)
      sleep(delay)
    end
  end
end
