class Insup::Tracker

  def initialize config = nil
    @config = config

    if config.present?
      @path = config[:path]
    end

    @path ||= Dir.pwd
  end


  def tracked_files
    track = tracked_locations

    res = []

    Dir.chdir(@path) do

      track.each do |loc|
        res << (get_files loc)
      end

    end

    res.flatten
  end

  protected

  def tracked_locations
    track = ::Insup::Settings.instance.get_tracked_locations
  end


  private

  def get_files path
    if File.directory? path
      res = []

      Dir.foreach(path) do |entry|
        next if ['..','.'].include? entry
        res << (get_files "#{path}/#{entry}")
      end

      res.flatten
    else
      [path]
    end
  end
end
