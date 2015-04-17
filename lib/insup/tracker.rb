require 'match_files'
class Insup
  # Base class for all trackers
  class Tracker
    def self.register_tracker(tracker_alias, tracker_class = self)
      unless self == Tracker
        return superclass.register_tracker(tracker_alias, tracker_class)
      end

      @trackers ||= {}
      @trackers[tracker_alias] = self
    end

    def self.find_tracker(tracker_alias)
      @trackers[tracker_alias.to_sym]
    end

    def initialize(base, config)
      @config = config
      @path = base
    end

    # Lists all files in the tracked locations whether they are ignored or not
    def all_files
      locations = tracked_locations
      locations.map do |loc|
        loc_pat = File.join(loc, '**/*')
        Dir.glob(loc_pat, File::FNM_DOTMATCH)
          .select { |e| File.file?(e) }
      end.flatten
    end

    # Lists all tracked files in the tracked locations
    # i. e. all files but ignored
    def tracked_files
      all_files.reject { |f| ignore_matcher.matched?(f) }
    end

    # Lists all tracked files in the tracked locations
    # i. e. all files but ignored
    def ignored_files
      all_files.select { |f| ignore_matcher.matched?(f) }
    end

    def changes
      raw_changes.select do |x|
        tracked_locations.any? do |loc|
          !ignore_matcher.matched?(x.path) &&
            File.fnmatch(File.join(loc, '/*'), x.path)
        end
      end
    end

    protected

    def raw_changes; end

    def ignore_matcher
      @ignore_matcher ||= ::MatchFiles.git(@path, ignore_patterns)
    end

    def tracked_locations
      @track = @config.tracked_locations
    end

    def ignore_patterns
      @ignore_patterns ||= @config.ignore_patterns
    end
  end
end
