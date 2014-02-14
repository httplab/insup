require 'git'

# Git tracker: tracks files by evaluating changes in Git repo
class Rad::Tracker::GitTracker < Rad::Tracker

  def initialize path = nil
    super
    @git = Git.open(@path)
  end

  def get_changes
    track = tracked_locations
    res = status.select do |x|
      track.any? {|t| x.path.start_with? t}
    end
  end

  private

  STATUS_MAP = {
    'A' => Rad::TrackedFile::NEW,
    'M' => Rad::TrackedFile::MODIFIED,
    'D' => Rad::TrackedFile::DELETED
  }

  def status
    changed = @git.status.select do |x|
      x.untracked || (['A','M','D'].include? x.type)
    end

    changed.map do |x|
      if x.untracked
        Rad::TrackedFile.new x.path, Rad::TrackedFile::NEW
      else
        Rad::TrackedFile.new x.path, STATUS_MAP[x.type]
      end
    end
  end

end
