require 'singleton'
require 'yaml'

class Rad::Settings
  include Singleton

  def initialize
    radfile = IO.read('.rad')
    @settings = YAML.load(radfile)
  end


  def get_tracked_locations
    return @settings['track']
  end

end
