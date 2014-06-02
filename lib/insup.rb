require 'fileutils'

class Insup

  def self.logger=(val)
    @logger = val
    Insup::Insales.logger = @logger
  end

  def self.logger
    @logger
  end

  def initialize(base, settings)
    @settings = settings
    @base = base
  end

  # Initializes a directory with a default .insup file
  def self.create_insup_file(dir = nil)
    dir ||= Dir.getwd
    template_file = File.join(File.dirname(File.expand_path(__FILE__)), '../insup.template')
    FileUtils.cp(template_file, File.join(dir, '.insup'))
  end

  def tracked_locations
    @settings.tracked_locations
  end

  def files(options = {})
    files = case options[:mode]
    when nil
      tracker.tracked_files
    when :all
      tracker.all_files
    when :ignored
      tracker.ignored_files
    end
  end

  def commit(files = nil)
    if files.nil? || files.empty?
      list = changes
    else
      list = files.map do |f|
        mode = File.exist?(f) ? TrackedFile::MODIFIED : TrackedFile::DELETED
        TrackedFile.new(f, mode)
      end
    end

    list.each do |file|
      uploader.process_file(file)
    end
  end

  def uploader
    @uploader ||= if uploader_conf = @settings.uploader
      klass = Insup::Uploader.find_uploader(uploader_conf['class']) || Object::const_get(uploader_conf['class'])
      klass.new(@settings)
    else
      Uploader::Dummy.new(@settings)
    end
  end

  def tracker
    @tracker ||= if tracker_conf = @settings.tracker
      klass = Insup::Tracker.find_tracker(tracker_conf['class']) || Object::const_get(tracker_conf['class'])
      klass.new(@base, @settings)
    else
      Tracker::SimpleTracker.new(@settings)
    end
  end

  def insales
    @insales ||= Insales.new(@settings)
  end

  def changes
    tracker.changes
  end

  def listen
    @listener = Listener.new(@base, @settings)

    @listener.listen do |changes|
      changes.each do |change|
        uploader.process_file(change)
      end
    end
  end

  def stop_listening
    @listener.stop
  end

end

require_relative 'insup/exceptions.rb'
require_relative 'insup/settings.rb'
require_relative 'insup/tracked_file.rb'
require_relative 'insup/tracker.rb'
require_relative 'insup/tracker/git_tracker.rb'
require_relative 'insup/tracker/simple_tracker.rb'
require_relative 'insup/listener.rb'
require_relative 'insup/uploader.rb'
require_relative 'insup/uploader/dummy_uploader.rb'
require_relative 'insup/uploader/insales_uploader.rb'
