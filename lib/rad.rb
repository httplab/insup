require 'colorize'

module Rad

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


  def self.tracked_files
    tracker = get_tracker
    tracker.tracked_files
  end


  def self.get_changes
    begin
      tracker = get_tracker
      tracker.get_changes
    rescue => ex
      puts ex
    end
  end


  def self.upload_changes
    begin
      uploader = get_uploader
      changed_files = get_changes
      uploader.process_all changed_files
    rescue => ex
      puts ex
    end
  end


  def self.list_changes
    get_changes.each do |x|
      case x.state
      when Rad::TrackedFile::NEW
        puts "New:      #{x.path}".green
      when Rad::TrackedFile::MODIFIED
        puts "Modified: #{x.path}".yellow
      when Rad::TrackedFile::DELETED
        puts "Deleted:  #{x.path}".red
      end
    end
  end


  def self.print_config
    puts 'Tracked locations:'

    Rad::Settings.instance.get_tracked_locations.each do |tl|
      puts tl
    end

    puts "Tracker #{Rad::Settings.instance.tracker['class']}"
    puts "Uploader #{Rad::Settings.instance.uploader['class']}"
  end

end


require_relative 'rad/settings.rb'
require_relative 'rad/tracked_file.rb'
require_relative 'rad/tracker.rb'
require_relative 'rad/tracker/git_tracker.rb'
require_relative 'rad/tracker/simple_tracker.rb'
require_relative 'rad/uploader.rb'
require_relative 'rad/uploader/dummy_uploader.rb'
require_relative 'rad/uploader/insales_uploader.rb'
