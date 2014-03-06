require 'singleton'
require 'yaml'

class Insup::Settings
  include Singleton

  attr_reader :settings

  def initialize
    insupfile = IO.read('.insup')
    @settings = YAML.load(insupfile)
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
