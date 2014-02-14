class Rad::Tracker

  def initialize path = nil
    @path = path || Dir.pwd
  end

  def tracked_locations
    track = ::Rad::Settings.instance.get_tracked_locations
  end

end
