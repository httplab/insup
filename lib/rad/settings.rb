require 'singleton'
require 'yaml'

class Rad::Settings
  include Singleton

  attr_reader :settings

  def initialize
    radfile = IO.read('.rad')
    @settings = YAML.load(radfile)
  end

  def get_tracked_locations
    return @settings['track'] || []
  end


  def uploader
    return @settings['uploader']
  end

  def tracker
    return @settings['tracker']
  end

end
