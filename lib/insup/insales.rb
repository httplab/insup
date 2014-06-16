class Insup::Insales



  def initialize(settings)
    @settings = settings
  end

  def self.logger=(val)
    ActiveResource::Base.logger = val
  end

  def self.logger
    ActiveResource::Base.logger
  end

  def self.get_asset_type(path)
    res = nil

    Asset::TYPE_MAP.each do |k,v|
      if path.start_with? k
        res = v
        break
      end
    end

    res
  end

  def configure_api
    if !@has_api
      @has_api = ::Insup::Insales::Base.configure(config['api_key'], config['subdomain'], config['password'])
    end
  end

  def themes
    configure_api
    Theme.all
  end

  def config
    @settings.insales
  end

  def print_config

  end

  def download_theme(theme_id, dir, force, &blck)
    configure_api
    theme = Theme.find(theme_id)

    theme.assets.each do |asset|
      next if !asset.dirname
      puts asset.path
      path = File.join(dir, asset.path)

      if !File.exist?(path)
        w = asset.get
        File.open(path, 'wb') do |f|
          f.write(asset.data)
        end
      else
        if force || (block_given? && blck.call(asset))
          File.delete(path)
          w = asset.get
          File.open(path, 'wb') do |f|
            f.write(asset.data)
          end
        end
      end
    end

  end
end

require 'active_resource'
require_relative 'insales/base'
require_relative 'insales/theme'
require_relative 'insales/asset'
