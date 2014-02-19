# Simple tracker: will list all tracked files as changed
class Rad::Tracker::SimpleTracker < Rad::Tracker

  def get_changes
    tracked_files.map do |p|
      Rad::TrackedFile.new p, Rad::TrackedFile::MODIFIED
    end
  end

end
