class Insup::Tracker

  def initialize(config = nil)
    @config = config
    @path = Dir.getwd
  end

  def tracked_files
    locations = tracked_locations
    locations.map do |loc|
      Dir.glob(File.join(@path, loc,'**/*'), File::FNM_DOTMATCH)
        .select{|e| File::file?(e)}
    end.flatten
  end

  protected

  def tracked_locations
    track = ::Insup::Settings.instance.tracked_locations
  end

end
