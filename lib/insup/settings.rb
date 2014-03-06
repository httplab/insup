require 'yaml'

class Insup::Settings
  attr_reader :environment

  def initialize(environment = 'development', filename = '.insup')
    @environment = environment
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
    return settings['ignore']
  end

  def settings
    res = @settings.clone
    environments = res.delete('environment')
    merge_hashes_recursively(res, environments[@environment])
  end

  private

  def merge_hashes_recursively(hash1, hash2)
    res = hash1.clone

    if hash2.nil? || hash2.empty?
      return res
    end

    hash2.each do |k,v|
      res[k] = if !(res.has_key?(k) && v.is_a?(Hash))
        v
      else
        merge_hashes_recursively(res[k], v)
      end
    end

    res
  end

end
