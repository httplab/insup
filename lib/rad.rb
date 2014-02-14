require 'colorize'

module Rad

  def self.get_uploader
    if uploader_conf = Settings.instance.uploader
      Object::const_get(uploader_conf['class']).new
    else
      Uploader::Dummy.new
    end
  end

  def self.get_tracker
    if tracker_conf = Settings.instance.tracker
      Object::const_get(tracker_conf['class']).new
    else
      Tracker::SimpleTracker.new
    end
  end

  def self.get_changes
    tracker = get_tracker
    tracker.get_changes
  end

  def self.upload_file file

  end

  def self.upload_all
    uploader = get_uploader
    changed_files = get_changes
    uploader.upload_all changed_files
  end

  def self.list_changes
    get_changes.each do |x|
      case x.state
      when Rad::TrackedFile::NEW
        puts x.path.green
      when Rad::TrackedFile::MODIFIED
        puts x.path.yellow
      when Rad::TrackedFile::DELETED
        puts x.path.red
      end
    end
  end

  def config
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
