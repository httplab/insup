require('match_files')
class Insup::Tracker

  def initialize(config = nil, ignore_patterns = nil)
    @config = config
    @path = Dir.getwd
  end

  # Lists ALL files in the tracked locations whether they are ignored or not
  def all_files
    locations = tracked_locations
    locations.map do |loc|
      loc_pat = File.join(@path, loc, '**/*')
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

  def changes; end

  protected

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
