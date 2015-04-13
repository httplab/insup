require 'fileutils'

# Main class for Insup. Encapsulates all essential insup abilities.
class Insup
  def self.logger=(val)
    @logger = val
    Insup::Insales.logger = @logger
  end

  def self.logger
    @logger
  end

  def initialize(settings)
    @settings = settings
    @base = @settings.working_directory
  end

  # Initializes a directory with a default .insup file
  def self.create_insup_file(dir = nil)
    path = File.join(dir, '.insup')
    return if File.exist?(path)
    lib_dir = File.dirname(File.expand_path(__FILE__))
    template_file = File.join(lib_dir, 'templates/insup.template')
    FileUtils.cp(template_file, path)
  end

  def tracked_locations
    @settings.tracked_locations
  end

  def working_dir
    @settings.working_directory
  end

  def files(options = {})
    case options[:mode]
    when nil
      tracker.tracked_files
    when :all
      tracker.all_files
    when :ignored
      tracker.ignored_files
    end
  end

  def get_file_path(file)
    File.expand_path(file, @base)
  end

  def commit(files = nil)
    list =
      if files.nil? || files.empty?
        changes
      else
        files.map do |file|
          f = get_file_path(file)
          mode = File.exist?(f) ? TrackedFile::MODIFIED : TrackedFile::DELETED
          TrackedFile.new(file, mode)
        end
      end

    process_all_files(list)
  end

  def uploader
    @uploader ||=
      if @settings.uploader
        klass = Insup::Uploader.find_uploader(@settings.uploader['class']) ||
                Object.const_get(@settings.uploader['class'])
        klass.new(@settings)
      else
        Uploader::DummyUploader.new(@settings)
      end
  end

  def tracker
    @tracker ||=
      if @settings.tracker
        klass = Insup::Tracker.find_tracker(@settings.tracker['class']) ||
                Object.const_get(@settings.tracker['class'])
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
      begin
        changes.each do |change|
          uploader.process_file(change)
        end
      rescue Exceptions::RecoverableUploaderError => ex
        logger.error(ex)
      end
    end
  end

  def stop_listening
    @listener.stop
  end

  protected

  def process_all_files(files)
    files.each do |file|
      uploader.process_file(file)
    end
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
