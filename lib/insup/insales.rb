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
end

require 'active_resource'
require_relative 'insales/base'
require_relative 'insales/theme'
require_relative 'insales/asset'
