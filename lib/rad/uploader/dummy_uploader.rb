class Rad::Uploader::DummyUploader < Rad::Uploader

  def upload_all files
    puts '---->Dummy Uploader<-----'
    files.each do |x|
      case x.state
      when Rad::TrackedFile::NEW, Rad::TrackedFile::MODIFIED
        puts "Uploading #{x.path}... Done.".green
      when Rad::TrackedFile::DELETED
        puts "Deleting #{x.path}... Done.".red
      end
    end
  end

  def upload_one file

  end

end
