require_relative ('lib/rad.rb')
require 'colorize'

namespace :rad do

  task :list_changes do |t|
    Rad.list_changes
  end

  task :tracked_locations do |t|
    Rad::Settings.instance.get_tracked_locations.each do |tl|
      puts tl
    end
  end

  task :upload_all do |t|
    Rad.upload_all
  end

  task :config do |t|
    Rad.config
  end

end
