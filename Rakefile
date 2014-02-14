require_relative ('lib/rad.rb')
require 'colorize'

namespace :rad do

  task :list_changes do |t|
    Rad.list_changes.each do |x|
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

  task :tracked_locations do |t|
    Rad::Settings.instance.get_tracked_locations.each do |tl|
      puts tl
    end
  end

  task :config do |t|
    puts 'Tracked locations:'

    Rad::Settings.instance.get_tracked_locations.each do |tl|
      puts tl
    end

    puts "Tracker #{Rad::Settings.instance.tracker['class']}"
    puts "Uploader #{Rad::Settings.instance.uploader['class']}"
  end

end
