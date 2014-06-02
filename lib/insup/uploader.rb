require 'observer'

class Insup::Uploader
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

  def self.uploader(uploader_alias)
    @@uploaders ||= {}
    @@uploaders[uploader_alias] = self
  end

  def self.find_uploader(uploader_alias)
    @@uploaders[uploader_alias.to_sym]
  end

  def initialize config = nil
    @config = config
  end

  def upload_file(file); end

  def delete_file(file); end

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
