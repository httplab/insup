require 'listen'

class Listener
  def initialize(base, settings)
    @base = base
    @settings = settings
  end

  def listen(&block)
    return if @listener

    locations = tracked_locations.map{|tl| File.expand_path(tl, @base)}
    @listener = Listen.to(locations, force_polling: @settings.options['force_polling']) do |modified, added, removed|
      flags = {}

      added.each do |file|
        flags[file] = flags[file] ? flags[file] | 4 : 4
      end

      modified.each do |file|
        flags[file] = flags[file] ? flags[file] | 2 : 2
      end

      removed.each do |file|
        flags[file] = flags[file] ? flags[file] | 1 : 1
      end

      res = []

      flags.each do |f, flag|
        file = File.expand_path(f, @base)
        next if ignore_matcher.matched?(file)
        tracked_file = create_tracked_file(flag, file)
        res << tracked_file unless tracked_file.nil?
      end

      yield res
    end

    @listener.start
  end

  def stop
    @listener.stop if @listener
  end

  protected

  def create_tracked_file(flags, file)
    case flags
    when 1
      Insup::TrackedFile.new(file, Insup::TrackedFile::DELETED)
    when 2
      Insup::TrackedFile.new(file, Insup::TrackedFile::MODIFIED)
    when 3
      Insup::TrackedFile.new(file, Insup::TrackedFile::DELETED)
    when 4
      Insup::TrackedFile.new(file, Insup::TrackedFile::NEW)
    when 5
      if File.exist?(file)
        Insup::TrackedFile.new(file, Insup::TrackedFile::UNSURE)
      end
    when 6
      Insup::TrackedFile.new(file, Insup::TrackedFile::NEW)
    when 7
      if File.exist?(file)
        Insup::TrackedFile.new(file, Insup::TrackedFile::UNSURE)
      end
    end
  end

  def ignore_matcher
    @ignore_matcher ||= ::MatchFiles.git(@base, ignore_patterns)
  end

  def tracked_locations
    @track = @settings.tracked_locations
  end

  def ignore_patterns
    @ignore_patterns = @settings.ignore_patterns
  end
end
