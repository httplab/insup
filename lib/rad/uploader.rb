class Rad::Uploader

  def initialize config = nil
    @config = config
  end

  def batch_upload files
    process_all files
  end


  def process_all files
    files.each do |file|
      case file.state
      when Rad::TrackedFile.NEW
        upload_new_file file
      when Rad::TrackedFile::MODIFY
        upload_modified_file file
      when Rad::TrackedFile::DELETED
        delete_file file
      end
    end
  end

end
