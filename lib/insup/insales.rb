require 'net/http'
require 'json'

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

  def download_theme(theme_id, dir)
    configure_api
    theme = Theme.find(theme_id)

    theme.assets.each do |asset|
      next if !asset.dirname
      path = File.join(dir, asset.path)
      exists = File.exist?(path)
      write = !exists
      write = yield(asset, exists) if block_given?
      
      if write
        File.delete(path) if exists
        w = asset.get
        Dir.mkdir(File.dirname(path)) if !Dir.exist?(File.dirname(path))
        File.open(path, 'wb'){|f| f.write(w.data)}
      end
    end
  end

  def download_theme_zip(theme_id)
    puts 'Requesting bundle'
    opts = request_bundle(theme_id)
    puts "Bundle requested, job ID is #{opts['job_id']}"
    begin
      puts 'Check Job'
      status = check_job_status(opts['job_id'], :export, opts['secret'], theme_id)
      if status['status'] != 'ok'
        puts 'Not ready'
      end
    end until status['status'] == 'ok'

    puts 'Obtaining ZIP'
    res = perform_request(status['zip'])
    puts res
  end

  def check_job_status(job_id, operation, secret, theme_id)
    res = perform_request("/admin/bundles/check_status?job_id=#{job_id}&operation=#{operation}&secret=#{secret}&theme_id=#{theme_id}")
    JSON.parse(res.body)
  end

  def request_bundle(theme_id)
    res = perform_request("/admin/bundles/#{theme_id}.json")
    JSON.parse(res.body)
  end

  protected

  def perform_request(path)
    req = Net::HTTP::Get.new(path)
    req.basic_auth(config['api_key'], config['password'])
    req['Accept'] = 'application/json'

    res = Net::HTTP.start(config['subdomain'], 80) do |http|
      http.request(req)
    end
  end
end

require 'active_resource'
require_relative 'insales/base'
require_relative 'insales/theme'
require_relative 'insales/asset'
