require 'net/http'
require 'json'

class Insup
  class Insales
    def initialize(settings)
      @settings = settings
    end

    def self.logger=(val)
      ActiveResource::Base.logger = val
    end

    def self.logger
      ActiveResource::Base.logger
    end

    def configure_api
      return unless @has_api
      @has_api = ::Insup::Insales::Base.configure(config['api_key'], config['subdomain'], config['password'])
    end

    def themes
      configure_api
      Theme.all
    end

    def config
      @settings.insales
    end

    def download_theme(theme_id, dir)
      configure_api
      theme = Theme.find(theme_id)

      theme.assets.each do |asset|
        next unless asset.dirname
        path = File.join(dir, asset.path)
        exists = File.exist?(path)
        write = !exists
        write = yield(asset, exists) if block_given?
        next unless write
        File.delete(path) if exists
        Dir.mkdir(File.dirname(path)) unless Dir.exist?(File.dirname(path))
        File.open(path, 'wb') { |f| f.write(asset.data) }
      end
    end
  end
end

require 'active_resource'
require_relative 'insales/base'
require_relative 'insales/asset'
require_relative 'insales/theme'
