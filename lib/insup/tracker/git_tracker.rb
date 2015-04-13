require_relative('../git')

# Git tracker: tracks files by evaluating changes in Git repo
class Insup
  class Tracker
    class GitTracker < Insup::Tracker
      tracker :git

      def initialize(base, config)
        super
        @git = ::Insup::Git.new(@path)
      end

      protected

      STATUS_MAP = {
        'A' => Insup::TrackedFile::NEW,
        'M' => Insup::TrackedFile::MODIFIED,
        'D' => Insup::TrackedFile::DELETED
      }

      def raw_changes
        changed = @git.status.select do |_, v|
          v[:untracked] || (%w(A M D).include? v[:type])
        end

        changed.map do |_, v|
          if v[:untracked]
            Insup::TrackedFile.new v[:path], Insup::TrackedFile::NEW
          else
            Insup::TrackedFile.new v[:path], STATUS_MAP[v[:type]]
          end
        end
      end
    end
  end
end
