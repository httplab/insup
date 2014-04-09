class Insup::Uploader

  def initialize config = nil
    @config = config
  end

  def batch_upload files
    process_all files
  end


  def process_all files
    files.each do |file|
      case file.state
      when Insup::TrackedFile::NEW
        upload_new_file file
      when Insup::TrackedFile::MODIFIED
        upload_modified_file file
      when Insup::TrackedFile::DELETED
        remove_file file
      end
    end
  end

end