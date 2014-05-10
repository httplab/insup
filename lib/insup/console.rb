require 'colorize'
require_relative '../insup'

module Insup::Console

  def self.start(settings_file = nil)
    settings_file ||= '.insup'
    @settings = Insup::Settings.new(settings_file)
    @insup = Insup.new(Dir.getwd, @settings)
    @insup.uploader.add_observer(Insup::Console::UploadObserver.new)
  end

  def self.init(directory = nil)
    directory ||= Dir.getwd
    @insup.create_insup_file(directory)
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
      prefix = theme.id == theme_id ? '*' : ' '
      puts "#{prefix} #{theme.id}\t#{theme.title}"
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
    puts 'Listening...'
    @insup.listen
    exit_requested = false
    Kernel.trap( "INT" ) { exit_requested = true }

    while !exit_requested do
      sleep 0.1
    end

    puts 'Stopping listener...'
    @insup.stop_listening
    puts 'Terminated by user'
  end

end

require_relative 'console/upload_observer'
