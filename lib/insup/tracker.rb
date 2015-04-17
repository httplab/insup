require 'match_files'
require 'pathname'

class Insup
  # Base class for all trackers
  class Tracker
    def self.register_tracker(tracker_alias, tracker_class = self)
      unless self == Tracker
        return superclass.register_tracker(tracker_alias, tracker_class)
      end

      @trackers ||= {}
      @trackers[tracker_alias] = tracker_class
    end

    def self.find_tracker(tracker_alias)
      @trackers[tracker_alias.to_sym]
    end

    def self.build(insup)
      new(insup.working_directory, insup.settings.tracker)
    end

    def initialize(base, config = {})
      @config = config
      @base = base
      @base_pathname = Pathname.new(@base)
    end

    # Lists all files in the working directory whether they are ignored or not
    def all_files
      loc_pat = File.join(@base, '**/*')
      Dir.glob(loc_pat, File::FNM_DOTMATCH)
        .select { |e| File.file?(e) }
        .map { |f| f[@base.size + 1..-1] }
    end

    # Lists all tracked files in the working directory
    # i. e. all files but ignored
    def tracked_files
      all_files.reject { |f| ignore_matcher.matched?(f) }
    end

    # Lists all ignored files in the working directory
    def ignored_files
      all_files.select { |f| ignore_matcher.matched?(f) }
    end

    def changes
      raw_changes.reject { |x| ignore_matcher.matched?(x.path) }
    end

    protected

    def raw_changes; end

    def ignore_matcher
      @ignore_matcher ||= ::MatchFiles.git(@base, ignore_patterns)
    end

    def ignore_patterns
      @ignore_patterns ||= @config.ignore_patterns
    end
  end
end
