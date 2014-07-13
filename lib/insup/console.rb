require 'colorize'
require 'fileutils'
require 'io/console'
require_relative '../insup'

module Insup::Console

  def self.start(settings_file = nil, verbose = false, debug = false)
    settings_file ||= '.insup'
    @settings = Insup::Settings.new(settings_file)
    @insup = Insup.new(Dir.getwd, @settings)
    @verbose = verbose
    @debug = debug
    self.init_log(@settings)
    true
  end

  def self.init_log(settings)
    if settings.log_file.nil? || settings.log_file.empty?
      @logger = Logger.new($stdout)
    else
      log_dir = File.dirname(settings.log_file)
      FileUtils.mkdir_p(log_dir) if !Dir.exist?(log_dir)
      @logger = Logger.new(settings.log_file)
    end

    @logger.level = @debug ? Logger::DEBUG : settings.log_level
    @logger.formatter = proc do |severity, datetime, progname, msg|

      format_string = settings.log_pattern
      values_hash = {
        level: severity,
        timestamp: datetime
      }

      if msg.is_a? Exception
        values_hash[:message] = msg.message
        values_hash[:backtrace] = "\n#{msg.backtrace.join("\n")}"
      else
        values_hash[:message] = msg.to_s
        values_hash[:backtrace] = nil
      end

      format_string % values_hash
    end

    Insup.logger = @logger
  end

  def self.init(directory = nil)
    directory ||= Dir.getwd
    Insup.create_insup_file(directory)
  end

  def self.list_locations
    @insup.tracked_locations.each do |loc|
      puts loc
    end
  end

  def self.list_files(options = {})
    @insup.files(options).each do |f|
      puts f
    end
  end

  def self.insales_list_themes
    theme_id = @settings.uploader['theme_id']
    @insup.insales.themes.each do |theme|
      prefix = theme.id == theme_id ? '=>' : '  '
      puts "#{prefix} #{theme.id}\t#{theme.title}"
    end
  end

  def self.insales_download_theme(force = false, theme_id = nil)
    theme_id ||= @settings.uploader['theme_id']
    puts "Downloading theme #{theme_id}"

    @insup.insales.download_theme(theme_id, Dir.getwd) do |asset, exists|
      if exists && !force
        puts "#{asset.path} already exists"
        false
      else
        if exists
          puts "Overwriting #{asset.path}"
        else
          puts "Downloading #{asset.path}"
        end
        true
      end
    end
  end

  def self.status
    @insup.changes.each do |x|
      case x.state
      when Insup::TrackedFile::NEW
        puts "New:      #{x.path}".green
      when Insup::TrackedFile::MODIFIED
        puts "Modified: #{x.path}".yellow
      when Insup::TrackedFile::DELETED
        puts "Deleted:  #{x.path}".red
      end
    end
  end

  def self.print_config
    puts "Tracker: #{@settings.tracker['class']}"
    puts "Uploader: #{@settings.uploader['class']}"
    puts 'Tracked locations:'
    puts @settings.tracked_locations.map{|loc| "\t#{loc}"}
    puts 'Ignore patterns:'
    puts @settings.ignore_patterns.map{|ip| "\t#{ip}"}
  end

  def self.listen
    @insup.uploader.add_observer(Insup::Console::UploadObserver.new)
    puts 'Listening...'
    @insup.listen
    exit_requested = false
    Kernel.trap( "INT" ) { exit_requested = true }

    while !exit_requested do
      sleep(0.1)
    end

    puts 'Stopping listener...'
    @insup.stop_listening
    puts 'Terminated by user'
  end

  def self.commit(args)
    @insup.uploader.add_observer(Insup::Console::UploadObserver.new)
    @insup.commit(args)
  end

  def self.process_error(exception)
    if exception.is_a? Insup::Exceptions::UploaderError
      $stderr.puts "UploaderError: #{exception.message}".red
    else
      $stderr.puts "Error: #{exception.message}".red
    end

    if @debug
      $stderr.puts exception.backtrace
    end

    begin
      @logger.error(exception) if @logger
    rescue
      $stderr.puts "Unable to log error because the logger is not properly configured"
    end
  end

end

require_relative 'console/upload_observer'
