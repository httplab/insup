# Simple tracker: will list all tracked files as changed
class Insup
  class Tracker
    class SimpleTracker < Insup::Tracker
      register_tracker :simple

      def raw_changes
        tracked_files.map do |p|
          Insup::TrackedFile.new(p, Insup::TrackedFile::MODIFIED)
        end
      end
    end
  end
end
