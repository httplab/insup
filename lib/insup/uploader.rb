require 'observer'
require 'pathname'

class Insup
  class Uploader
    include Observable

    CREATING_FILE = 0
    CREATED_FILE = 1
    MODIFYING_FILE = 2
    MODIFIED_FILE = 3
    DELETING_FILE = 4
    DELETED_FILE = 5
    BATCH_UPLOADING_FILES = 6
    BATCH_UPLOADED_FILES = 7
    ERROR = 8

    attr_reader :base

    def self.register_uploader(uploader_alias, uploader_class = self)
      return superclass.register_uploader(uploader_alias, uploader_class) if self != Uploader
      @uploaders ||= {}
      @uploaders[uploader_alias] = uploader_class
    end

    def self.find_uploader(uploader_alias)
      @uploaders[uploader_alias.to_sym]
    end

    def self.build(insup)
      new(insup.settings.working_directory, insup.settings.uploader)
    end

    def initialize(base, _settings = {})
      unless Pathname.new(base).absolute?
        fail Insup::Exceptions::InsupError, "Uploader base requires absolute base path. #{base} given."
      end

      @base = base
    end

    def upload_file(_file); end

    def delete_file(_file); end

    def batch_upload(files)
      files.each do |file|
        upload_file(file)
      end
    end

    def process_file(file)
      case file.state
      when Insup::TrackedFile::DELETED
        remove_file(file)
      else
        upload_file(file)
      end
    end
  end
end
