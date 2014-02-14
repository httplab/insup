require 'git'
require 'singleton'

class Rad::GitTracker
  include Singleton

  def initialize
    path ||='.'

    @git = Git.open(path)
  end


  def status
    @git.status.map {|x| GitFile.new x}
  end

  def get_changed_files
    track = ::Rad::Settings.instance.get_tracked_locations
    res = status.select do |x|
      track.any? {|t| x.path.start_with? t} &&
      [GitFile::UNTRACKED, GitFile::ADDED, GitFile::MODIFIED, GitFile::DELETED].include?(x.state)
    end
  end

  class GitFile
    UNTRACKED = 0
    ADDED = 1
    MODIFIED = 2
    DELETED = 3

    attr_reader :path, :state

    def initialize file
      @path = file.path

      if file.untracked
        @state = UNTRACKED
      else
        case file.type
        when 'A'
          @state = ADDED
        when 'M'
          @state = MODIFIED
        when 'D'
          @state = DELETED
        end
      end

    end
  end
end
