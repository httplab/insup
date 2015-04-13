require 'base64'
require_relative '../insales'

class Insup
  class Uploader
    class InsalesUploader < Insup::Uploader
      uploader :insales

      def initialize(settings)
        super
        @insales = Insup::Insales.new(settings)
        @insales.configure_api

        unless theme
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

        unless asset.nil?
          upload_modified_file(file)
          return
        end

        changed
        notify_observers(CREATING_FILE, file)
        asset_type = ::Insup::Insales::Asset.get_type(file.path)

        unless asset_type
          msg = "Cannot determine asset type for file #{file.path}"
          changed
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

        begin
          asset = ::Insup::Insales::Asset.create(hash)
          assets_list << asset
          changed
          notify_observers(CREATED_FILE, file)
        rescue ActiveResource::ServerError => ex
          changed
          notify_observers(ERROR, file, ex.message)
          raise Insup::Exceptions::RecoverableUploaderError, "Server error occured when creating file #{file.path}"
        end
      end

      def upload_modified_file(file)
        asset = find_asset(file)

        unless asset
          upload_new_file(file)
          return
        end

        changed
        notify_observers(MODIFYING_FILE, file)
        file_contents = File.read(file.path)

        if asset.content_type.start_with? 'text/'
          begin
            res = asset.update_attribute(:content, file_contents)

            unless res
              process_error(asset, file)
              return
            end

            changed
            notify_observers(MODIFIED_FILE, file)
          rescue ActiveResource::ServerError => ex
            changed
            notify_observers(ERROR, file, ex.message)
            raise Insup::Exceptions::RecoverableUploaderError, "Server error occured when updating file #{file.path}"
          end
        else
          remove_file(file)
          upload_new_file(file)
        end
      end

      def remove_file(file)
        asset = find_asset(file)

        unless asset
          msg = "Cannot find remote counterpart for file #{file.path}"
          changed
          notify_observers(ERROR, file, msg)
          raise Insup::Exceptions::RecoverableUploaderError, "Cannot find remote counterpart for file #{file.path}"
        end

        changed
        notify_observers(DELETING_FILE, file)

        begin
          if asset.destroy
            assets_list.delete(asset)
            changed
            notify_observers(DELETED_FILE, file)
          end
        rescue ActiveResource::ServerError => ex
          changed
          notify_observers(ERROR, file, ex.message)
          raise Insup::Exceptions::RecoverableUploaderError, "Server error occured when deleting file #{file.path}"
        end
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
        asset_type = ::Insup::Insales::Asset.get_type(file.path)

        unless asset_type
          msg = "Cannot determine asset type for file #{file.path}"
          changed
          notify_observers(ERROR, file, msg)
          raise Insup::Exceptions::RecoverableUploaderError, "Cannot determine asset type for file #{file.path}"
        end

        files = assets_list.select do |el|
          el.type == asset_type && el.filename == file.file_name
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
  end
end
