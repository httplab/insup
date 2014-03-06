# Simple tracker: will list all tracked files as changed
class Insup::Tracker::SimpleTracker < Insup::Tracker

  def get_changes
    tracked_files.map do |p|
      Insup::TrackedFile.new p, Insup::TrackedFile::MODIFIED
    end
  end

end
