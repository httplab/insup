require 'git'

# Git tracker: tracks files by evaluating changes in Git repo
class Insup::Tracker::GitTracker < Insup::Tracker

  def initialize config = nil
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
    'A' => Insup::TrackedFile::NEW,
    'M' => Insup::TrackedFile::MODIFIED,
    'D' => Insup::TrackedFile::DELETED
  }

  def status
    changed = @git.status.select do |x|
      x.untracked || (['A','M','D'].include? x.type)
    end

    changed.map do |x|
      if x.untracked
        Insup::TrackedFile.new x.path, Insup::TrackedFile::NEW
      else
        Insup::TrackedFile.new x.path, STATUS_MAP[x.type]
      end
    end
  end

end
