require 'base64'
require_relative '../insales'

class Insup::Uploader::InsalesUploader < Insup::Uploader

  InsalesUploaderError = Class.new(Insup::Exceptions::UploaderError)

  def initialize(config)
    super
    Insup::Insales.configure_api
    assets_list(true)
  end

  def upload_file(file)
    case file.state
    when Insup::TrackedFile::NEW
      upload_new_file(file)
    when Insup::TrackedFile::MODIFIED
      upload_modified_file(file)
    when Insup::TrackedFile::UNSURE
      upload_modified_file(file)
    end
  end

  def upload_new_file(file)
    asset = find_asset(file)

    if !asset.nil?
      upload_modified_file(file)
      return
    end

    puts "Creating #{file.path}".green
    asset_type = get_asset_type(file.path)

    if(!asset_type)
      raise InsalesUploaderError, "Cannot determine asset type for file #{file.path}"
    end

    file_contents = File.read(file.path)

    asset = ::Insup::Insales::Asset.create({
      name: file.file_name,
      attachment: Base64.encode64(file_contents),
      theme_id: @config['theme_id'],
      type: asset_type
    })

    assets_list << asset
  end

  def upload_modified_file(file)
    asset = find_asset(file)

    if !asset
      upload_new_file(file)
    end

    puts "Updating #{file.path}".yellow

    file_contents = File.read(file.path)

    if asset.content_type.start_with? 'text/'
      asset.update_attribute(:content, file_contents)
    else
      remove_file(file)
      upload_new_file(file)
    end
  end

  def remove_file(file)
    asset = find_asset(file)

    if !asset
      raise InsalesUploaderError, "Cannot find remote counterpart for file #{file.path}"
    end

    puts "Deleting #{file.path}".red
    asset.destroy
    assets_list.delete(asset)
  end

private
  ASSET_TYPE_MAP = {
    'media/' => 'Asset::Media',
    'snippets/' => 'Asset::Snippet',
    'templates/' => 'Asset::Template'
  }.freeze

  def get_asset_type path
    res = nil

    ASSET_TYPE_MAP.each do |k,v|
      if path.start_with? k
        res = v
        break
      end
    end

    res
  end

  def theme
    @theme ||= ::Insup::Insales::Theme.find(@config['theme_id'])
  end

  def find_asset file
    asset_type = get_asset_type(file.path)

    if(!asset_type)
      raise InsalesUploaderError, "Cannot determine asset type for file #{file.path}"
    end

    files = assets_list.select  do |el|
      el.type == asset_type && (el.human_readable_name == file.file_name || el.name == file.file_name)
    end

    if files && !files.empty?
      return files.first
    else
      return nil
    end
  end

  def assets_list(reload = false)
    if !@assets_list || reload
      @assets_list ||= theme.assets.to_a
    else
      @assets_list
    end
  end

end
