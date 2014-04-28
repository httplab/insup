require 'listen'
require 'colorize'

class Listener

  def initialize(tracked_locations, ignore_patterns)
    @tracked_locations = tracked_locations
    @ignore_patterns = ignore_patterns
  end

  def ignore_matcher
  end

  def listen(&block)
    return if @listener

    @listener = Listen.to(@tracked_locations) do |modified, added, removed|
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

      flags.each do |file,flags|
        case flags
        when 1
          res << Insup::TrackedFile.new(file, Insup::TrackedFile::DELETED)
        when 2
          res << Insup::TrackedFile.new(file, Insup::TrackedFile::MODIFIED)
        when 3
          res << Insup::TrackedFile.new(file, Insup::TrackedFile::DELETED)
        when 4
          res << Insup::TrackedFile.new(file, Insup::TrackedFile::NEW)
        when 5
          if File.exist?(file)
            res << Insup::TrackedFile.new(file, Insup::TrackedFile::UNSURE)
          end
        when 6
          res << Insup::TrackedFile.new(file, Insup::TrackedFile::NEW)
        when 7
          if File.exist?(file)
            res << Insup::TrackedFile.new(file, Insup::TrackedFile::UNSURE)
          end
        end
      end

      yield res
    end

    @listener.start
  end

  def stop
    if @listener
      @listener.stop
    end
  end

end
