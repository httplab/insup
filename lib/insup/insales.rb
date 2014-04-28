module Insup::Insales

  def self.configure_api
    @config = Insup::Settings.instance.insales;

    return false if @config.nil?

    if !@has_api
      active_resource_logger = Logger.new('log/active_resource.log', 'daily')
      active_resource_logger.level = Logger::DEBUG
      ActiveResource::Base.logger = active_resource_logger
      @has_api = ::Insup::Insales::Base.configure(@config['api_key'], @config['subdomain'], @config['password'])
    end
  end

  def self.list_themes
    configure_api
    themes = Theme.all
    themes.each do |theme|
      puts "#{theme.id}\t#{theme.title}"
    end
  end

  def print_config

  end

end

require 'active_resource'
require_relative 'insales/base'
require_relative 'insales/theme'
require_relative 'insales/asset'
