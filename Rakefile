require_relative ('lib/rad.rb')
require 'colorize'

namespace :rad do

  task :list_changes do |t|
    Rad::GitTracker.instance.get_changed_files.each do |x|
      puts x.path
    end
  end

  task :git_status do |t|
    Rad::GitTracker.instance.status.each do |x|
      case x.state
      when Rad::GitTracker::GitFile::ADDED
        puts x.path.green
      when Rad::GitTracker::GitFile::MODIFIED
        puts x.path.yellow
      when Rad::GitTracker::GitFile::DELETED
        puts x.path.red
      when Rad::GitTracker::GitFile::UNTRACKED
        puts x.path.light_white
      end
    end
  end

  task :track_list do |t|
    Rad::Settings.instance.get_tracked_locations.each do |x|
      puts x
    end
  end

end
