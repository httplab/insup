class Insup::Insales

  def initialize(settings)
    @settings = settings
  end

  def configure_api
    if !@has_api
      # active_resource_logger = Logger.new('log/active_resource.log', 'daily')
      # active_resource_logger.level = Logger::DEBUG
      # ActiveResource::Base.logger = active_resource_logger
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
