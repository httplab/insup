require('match_files')
class Insup::Tracker

  def self.tracker(tracker_alias)
    @@trackers ||= {}
    @@trackers[tracker_alias] = self
  end

  def self.find_tracker(tracker_alias)
    @@trackers[tracker_alias.to_sym]
  end

  def initialize(config = nil)
    @config = config
    @path = Dir.getwd
  end

  # Lists ALL files in the tracked locations whether they are ignored or not
  def all_files
    locations = tracked_locations
    locations.map do |loc|
      loc_pat = File.join(loc, '**/*')
      Dir.glob(loc_pat, File::FNM_DOTMATCH)
        .select{|e| File.file?(e)}
    end.flatten
  end

  # Lists ALL tracked files in the tracked locations i. e. all files but ignored
  def tracked_files
    all_files.reject{|f| ignore_matcher.matched?(f)}
  end

  # Lists ALL tracked files in the tracked locations i. e. all files but ignored
  def ignored_files
    all_files.select{|f| ignore_matcher.matched?(f)}
  end

  def changes
    res = raw_changes.select do |x|
      tracked_locations.any? do |loc|
        !ignore_matcher.matched?(x.path) && File.fnmatch(File.join(loc,'/*'), x.path)
      end
    end
  end

  protected

  def raw_changes; end;

  def ignore_matcher
    @ignore_matcher ||= ::MatchFiles.git(@path, ignore_patterns)
  end

  def tracked_locations
    @track = ::Insup::Settings.instance.tracked_locations
  end

  def ignore_patterns
    @ignore_patterns ||= ::Insup::Settings.instance.ignore_patterns
  end

end
