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

  def self.list_changes
    tracker = get_tracker
    tracker.get_changes
  end

end


require_relative 'rad/settings.rb'
require_relative 'rad/tracked_file.rb'
require_relative 'rad/tracker.rb'
require_relative 'rad/tracker/git_tracker.rb'
require_relative 'rad/tracker/simple_tracker.rb'
require_relative 'rad/uploader.rb'
require_relative 'rad/uploader/dummy_uploader.rb'
