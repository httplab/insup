# Simple tracker: will list all tracked files as changed
class Rad::Tracker::SimpleTracker < Rad::Tracker

  def get_changes
    track = tracked_locations

    res = []

    Dir.chdir(@path) do

      track.each do |loc|
        res << (get_files loc)
      end

    end

    res.flatten.map do |p|
      Rad::TrackedFile.new p, Rad::TrackedFile::NEW
    end
  end

  private

  def get_files path
    if File.directory? path
      res = []

      Dir.foreach(path) do |entry|
        next if ['..','.'].include? entry
        res << (get_files "#{path}/#{entry}")
      end

      res.flatten
    else
      [path]
    end
  end
end
