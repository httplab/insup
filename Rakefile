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


task :upload do |t|
  u = Rad.get_uploader
  f = Rad::TrackedFile.new 'media/mbon.css', 1
  u.upload_new_file f
end

task :remove do |t|
  u = Rad.get_uploader
  f = Rad::TrackedFile.new 'media/mbon.css', 1
  u.remove_file f
end

task :modify do |t|
  u = Rad.get_uploader
  f = Rad::TrackedFile.new 'media/mbon.css', 1
  u.upload_modified_file f
end

task :get do |t|
  u = Rad.get_uploader
  f = Rad::TrackedFile.new 'media/mbon.css', 1
  puts u.get_asset(f).attachment
end
