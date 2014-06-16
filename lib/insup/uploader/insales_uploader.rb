require 'base64'
require_relative '../insales'

class Insup::Uploader::InsalesUploader < Insup::Uploader

  uploader :insales

  def initialize(settings)
    super
    @insales = Insup::Insales.new(settings)
    @insales.configure_api

    if !theme
      fail Insup::Exceptions::FatalUploaderError, "Theme #{theme_id} is not found in the Insales shop"
    end

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

    changed
    notify_observers(CREATING_FILE, file)
    asset_type = get_asset_type(file.path)

    if !asset_type
      msg = "Cannot determine asset type for file #{file.path}"
      notify_observers(ERROR, file, msg)
      raise Insup::Exceptions::RecoverableUploaderError, msg
    end

    file_contents = File.read(file.path)

    hash = {
      name: file.file_name,
      theme_id: @config.uploader['theme_id'],
      type: asset_type
    }

    if ['Asset::Snippet', 'Asset::Template'].include?(asset_type)
      hash[:content] = file_contents
    else
      hash[:attachment] = Base64.encode64(file_contents)
    end

    asset = ::Insup::Insales::Asset.new(hash)
    assets_list << asset
    changed
    notify_observers(CREATED_FILE, file)
  end

  def upload_modified_file(file)
    asset = find_asset(file)

    if !asset
      upload_new_file(file)
      return
    end

    changed
    notify_observers(MODIFYING_FILE, file)

    file_contents = File.read(file.path)

    if asset.content_type.start_with? 'text/'
      res = asset.update_attribute(:content, file_contents)
      if !res
        process_error(asset, file)
      end
    else
      remove_file(file)
      upload_new_file(file)
    end

    changed
    notify_observers(MODIFIED_FILE, file)
  end

  def remove_file(file)
    asset = find_asset(file)

    if !asset
      msg = "Cannot find remote counterpart for file #{file.path}"
      notify_observers(ERROR, file, msg)
      raise Insup::Exceptions::RecoverableUploaderError, "Cannot find remote counterpart for file #{file.path}"
    end

    changed
    notify_observers(DELETING_FILE, file)

    if pd=asset.destroy
      assets_list.delete(asset)
    end

    changed
    notify_observers(DELETED_FILE, file)
  end

private
  def process_error(entity, file)
    changed
    entity.errors.full_messages.each do |err|
      Insup.logger.error(err)
      notify_observers(ERROR, file, err)
    end
  end

  def theme
    @theme ||= themes[theme_id]
  end

  def theme_id
    @config.uploader['theme_id']
  end

  def themes
    @themes ||= Hash[@insales.themes.map{|t| [t.id, t]}]
  end

  def find_asset(file)
    asset_type = ::Insup::Insales.get_asset_type(file.path)

    if !asset_type
      msg = "Cannot determine asset type for file #{file.path}"
      notify_observers(ERROR, file, msg)
      raise Insup::Exceptions::RecoverableUploaderError, "Cannot determine asset type for file #{file.path}"
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
