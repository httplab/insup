require 'fileutils'

# Main class for Insup. Encapsulates all essential insup abilities.
class Insup
  attr_reader :settings

  class << self
    attr_accessor :logger
  end

  def logger
    self.class.logger
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

  def commit(files = nil)
    list =
      if files.nil? || files.empty?
        changes
      else
        files.map do |file|
          mode =
            if File.exist?(file)
              TrackedFile::MODIFIED
            else
              TrackedFile::DELETED
            end

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
        klass.build(self)
      else
        Uploader::DummyUploader.build(self)
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
    @insales ||= Insales.new(@settings.insales)
  end

  def changes
    tracker.changes
  end

  def listen
    @listener = Listener.new(@base, @settings.listener_settings)

    logger.info(I18n.t('insup.log.starting_listener'))

    @listener.listen do |changes|
      begin
        changes.each { |change| uploader.process_file(change) }
      rescue Exceptions::RecoverableUploaderError => ex
        logger.error(ex)
      end
    end

    logger.info(I18n.t('insup.log.listener_started'))
  end

  def stop_listening
    logger.info(I18n.t('insup.log.stopping_listener'))
    @listener.stop
    logger.info(I18n.t('insup.log.listener_stopped'))
  end

  protected

  def process_all_files(files)
    files.each { |file| uploader.process_file(file) }
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
