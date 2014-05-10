require 'yaml'

class Insup::Settings
  attr_reader :settings

  def initialize(filename = '.insup')
    insupfile = IO.read(filename)
    @settings = YAML.load(insupfile)
  end

  def tracked_locations
    return settings['track'] || []
  end

  def uploader
    return @settings['uploader']
  end

  def tracker
    return @settings['tracker']
  end

  def ignore_patterns
    return @settings['ignore'] || []
  end

  def insales
    return @settings['insales']
  end

  def save(filename)
    File.write(filename, @settings.to_yaml)
  end

  def log
    @settings['log'] || {}
  end

  def log_level
    level = log['level'] || 'info'
  end

  def save(filename)
    File.open(filename, 'w') do |f|
      f.write(@settings.to_yaml)
    end
  end

end
