require 'colorize'

module Insup

  def self.get_uploader
    if uploader_conf = Settings.instance.uploader
      Object::const_get(uploader_conf['class']).new uploader_conf
    else
      Uploader::Dummy.new uploader_conf
    end
  end

  def self.get_tracker
    if tracker_conf = Settings.instance.tracker
      Object::const_get(tracker_conf['class']).new tracker_conf
    else
      Tracker::SimpleTracker.new tracker_conf
    end
  end

  def self.list_files
    tracker = get_tracker
    tracker.tracked_files
  end

  def self.status
    begin
      tracker = get_tracker
      tracker.get_changes
    rescue => ex
      puts ex
    end
  end

  def self.commit changed_files = nil
    begin
      changed_files ||= get_changes
      uploader = get_uploader
      uploader.process_all changed_files
    rescue => ex
      puts ex
    end
  end

  def self.status
    get_changes.each do |x|
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
    puts 'Tracked locations:'

    Insup::Settings.instance.get_tracked_locations.each do |tl|
      puts tl
    end

    puts "Tracker #{Insup::Settings.instance.tracker['class']}"
    puts "Uploader #{Insup::Settings.instance.uploader['class']}"
  end

  def self.listen
    tracker = get_tracker
    if tracker.respond_to? :listen
      tracker.listen do |changes|
        # upload_changes changes
      end

      exit_requested = false
      Kernel.trap( "INT" ) { exit_requested = true }

      while !exit_requested do
        sleep 0.1
      end

      puts 'Stopping listener...'
      tracker.stop
      puts 'Terminated by user'
    else
      puts "#{tracker.class.name} does not support listening"
    end
  end

end

require_relative 'insup/exceptions.rb'
require_relative 'insup/settings.rb'
require_relative 'insup/tracked_file.rb'
require_relative 'insup/tracker.rb'
require_relative 'insup/tracker/git_tracker.rb'
require_relative 'insup/tracker/simple_tracker.rb'
require_relative 'insup/tracker/listen_tracker.rb'
require_relative 'insup/uploader.rb'
require_relative 'insup/uploader/dummy_uploader.rb'
require_relative 'insup/uploader/insales_uploader.rb'
