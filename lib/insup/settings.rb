require 'yaml'

class Insup::Settings
  attr_reader :settings

  def self.instance
    @instance ||= new()
  end

  def initialize(filename = '.insup')
    insupfile = IO.read(filename)
    @settings = YAML.load(insupfile)
  end

  def tracked_locations
    return settings['track'] || []
  end

  def uploader
    return settings['uploader']
  end

  def tracker
    return settings['tracker']
  end

  def ignore_patterns
    return settings['ignore'] || []
  end

  def insales
    return settings['insales']
  end

  def settings
    @settings
  end

end
