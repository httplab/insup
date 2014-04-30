require 'colorize'
require 'fileutils'

module Insup

  # Initializes a directory with a default .insup file
  def self.init(dir = nil)
    dir ||= Dir.getwd

    template_file = File.join(File.dirname(File.expand_path(__FILE__)), '../.insup.template')
    FileUtils.cp(template_file, File.join(dir, '.insup'))
  end

  def self.list_locations
    puts Insup::Settings.instance.tracked_locations
  end

  def self.list_files(options = {})
    files = case options[:mode]
    when nil
      tracker.tracked_files
    when :all
      tracker.all_files
    when :ignored
      tracker.ignored_files
    end

    puts files
  end

  def self.uploader
    @uploader ||= if uploader_conf = Settings.instance.uploader
      Object::const_get(uploader_conf['class']).new(uploader_conf)
    else
      Uploader::Dummy.new(uploader_conf)
    end
  end

  def self.tracker
    @tracker ||= if tracker_conf = Settings.instance.tracker
      Object::const_get(tracker_conf['class']).new(tracker_conf)
    else
      Tracker::SimpleTracker.new(tracker_conf)
    end
  end

  def self.commit(changed_files = nil)
    begin
      changed_files ||= get_changes
      uploader = get_uploader
      uploader.process_all changed_files
    rescue => ex
      puts ex
    end
  end

  def self.status
    tracker.changes.each do |x|
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
    puts "Tracker: #{Insup::Settings.instance.tracker['class']}"
    puts "Uploader: #{Insup::Settings.instance.uploader['class']}"
    puts 'Tracked locations:'
    puts Settings.instance.tracked_locations.map{|loc| "\t#{loc}"}
    puts 'Ignore patterns:'
    puts Settings.instance.ignore_patterns.map{|ip| "\t#{ip}"}
  end

  def self.listen
    listener = Listener.new(Dir.getwd, Settings.instance.tracked_locations,
      Settings.instance.ignore_patterns)

    listener.listen do |changes|
      changes.each do |change|
        case change.state
        when Insup::TrackedFile::DELETED
          uploader.remove_file(change)
        else
          uploader.upload_file(change)
        end
      end
    end

    exit_requested = false
    Kernel.trap( "INT" ) { exit_requested = true }

    while !exit_requested do
      sleep 0.1
    end

    puts 'Stopping listener...'
    listener.stop
    puts 'Terminated by user'
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
