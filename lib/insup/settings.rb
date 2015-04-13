require 'yaml'
require 'logger'

class Insup::Settings
  attr_reader :settings

  def initialize(filename = '.insup')
    if File.exist?(filename)
      insupfile = IO.read(filename)
      @settings = YAML.load(insupfile)
    else
      @settings = {}
    end
  end

  def working_directory
    settings['working_dir'] ? File.expand_path(settings['working_dir']) : Dir.getwd
  end

  def tracked_locations
    settings['track'] || []
  end

  def uploader
    @settings['uploader']
  end

  def tracker
    @settings['tracker']
  end

  def ignore_patterns
    @settings['ignore'] || []
  end

  def insales
    @settings['insales']
  end

  def save(filename)
    File.write(filename, @settings.to_yaml)
  end

  def log
    @settings['log'] || {}
  end

  def log_level
    level = log['level'] || 'info'
    level = "Logger::#{level.upcase}"
    Kernel.const_get(level)
  end

  def options
    @settings['options'] || {}
  end

  def log_pattern
    log['pattern'] || "%{message}\n"
  end

  def log_file
    log['file']
  end

  def save(filename)
    File.open(filename, 'w') do |f|
      f.write(@settings.to_yaml)
    end
  end
end
