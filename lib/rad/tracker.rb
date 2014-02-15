class Rad::Tracker

  def initialize config = nil
    @config = config

    if config.present?
      @path = config[:path]
    end

    @path ||= Dir.pwd
  end

  def tracked_locations
    track = ::Rad::Settings.instance.get_tracked_locations
  end

end
