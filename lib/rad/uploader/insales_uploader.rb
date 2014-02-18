require 'insales_api'
require 'base64'


class ActiveResource::Connection
  # Creates new Net::HTTP instance for communication with
  # remote service and resources.
  def http
    http = Net::HTTP.new(@site.host, @site.port)
    # http.use_ssl = @site.is_a?(URI::HTTPS)
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl
    http.read_timeout = @timeout if @timeout
    # Here's the addition that allows you to see the output
    http.set_debug_output $stdout
    return http
  end
end



class Rad::Uploader::InsalesUploader < Rad::Uploader

  def upload_new_file file
    configure_api
    asset_type = get_asset_type file.path

    if(!asset_type)
      raise "Cannot determine asset type for file #{file.path}"
    end

    file_contents = File.read(file.path)

    asset = InsalesApi::Asset.create({
      name: file.file_name,
      attachment: Base64.encode64(file_contents),
      theme_id: @config['theme_id'],
      type: asset_type
    })
  end


  def upload_modified_file file

  end


  def remove_file file
    asset = find_asset file
    if !asset
      raise "Cannot find remote counterpart for file #{file.path}"
    end

    asset.delete
  end


private
  ASSET_TYPE_MAP = {
    'media/' => 'Asset::Media',
    'snippets/' => 'Asset::Snippets',
    'templates/' => 'Asset::Templates'
  }.freeze


  def find_asset file
    asset_type = get_asset_type file.path

    if(!asset_type)
      raise "Cannot determine asset type for file #{file.path}"
    end

    assets = assets_list

    files = assets.select  do |el|
      el.type == asset_type && el.name == file.file_name
    end

    if files && !files.empty?
      return files.first
    else
      return nil
    end
  end


  def get_asset_type path
    res = nil
    ASSET_TYPE_MAP.each do |k,v|
      if path.start_with? k
        res = v
        break
      end
    end

    return res
  end

  def configure_api
    if !@has_api
      active_resource_logger = Logger.new('log/active_resource.log', 'daily')
      active_resource_logger.level = Logger::DEBUG
      ActiveResource::Base.logger = active_resource_logger

      @has_api = InsalesApi::Base.configure @config['api_key'], @config['subdomain'], @config['password']
    end
  end

  def theme
    configure_api
    @theme ||= InsalesApi::Theme.find(@config['theme_id'])
  end

  def assets_list
    configure_api
    @assets_list ||= theme.assets.to_a
  end

end
