require 'yaml'
require 'logger'

class Insup
  class Settings
    attr_reader :settings

    def initialize(filename = '.insup')
      if File.exist?(filename)
        insupfile = IO.read(filename)
        @settings = YAML.load(insupfile)
      else
        @settings = {}
      end
    end

    def listener_settings
      {
        tracked_locations: tracked_locations,
        ignore_patterns: ignore_patterns,
        wait_for_delay: settings['listen']['wait_for_delay'],
        latency: settings['listen']['latency'],
        force_polling: settings['listen']['latency']
      }
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
  end
end
