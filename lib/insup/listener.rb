require 'listen'

# Listens to directory changes and executes callback each time something changes
class Listener
  attr_reader :tracked_locations, :ignore_patterns, :force_polling

  FLAGS_MAP = {
    1 => Insup::TrackedFile::DELETED,
    2 => Insup::TrackedFile::MODIFIED,
    3 => Insup::TrackedFile::DELETED,
    4 => Insup::TrackedFile::NEW,
    5 => Insup::TrackedFile::UNSURE,
    6 => Insup::TrackedFile::NEW,
    7 => Insup::TrackedFile::UNSURE
  }.freeze

  def initialize(base, settings = {})
    defaults = {
      force_polling: false,
      tracked_locations: [],
      ignore_patterns: []
    }

    @base = base
    settings = defaults.merge(settings)

    @tracked_locations = settings[:tracked_locations]
    @ignore_patterns = settings[:ignore_patterns]
    @force_polling = settings[:force_polling]
  end

  def listen
    return if @listener

    locations = tracked_locations.map { |tl| File.expand_path(tl, @base) }

    @listener =
      Listen.to(locations, force_polling) do |modified, added, removed|
        flags = prepare_flags(modified, added, removed)
        changes = prepare_changes(flags)
        yield changes if block_given?
      end

    @listener.start
  end

  def stop
    @listener.stop if @listener
    @listener = nil
  end

  protected

  def prepare_flags(modified, added, removed)
    flags = Hash.new(0)

    added.each    { |f| flags[f] |= 4 }
    modified.each { |f| flags[f] |= 2 }
    removed.each  { |f| flags[f] |= 1 }

    flags
  end

  def prepare_changes(flags)
    flags.map do |f, flag|
      file = File.expand_path(f, @base)
      next if ignore_matcher.matched?(file)
      create_tracked_file(flag, file)
    end.compact
  end

  def create_tracked_file(flags, file)
    state = FLAGS_MAP[flags]
    return nil unless state == Insup::TrackedFile::UNSURE && !File.exist?(file)
    Insup::TrackedFile.new(file, state) if state
  end

  def ignore_matcher
    @ignore_matcher ||= ::MatchFiles.git(@base, ignore_patterns)
  end
end
