require 'colorize'

class Insup::Uploader::DummyUploader < Insup::Uploader

  def upload_file(file)
    case file.state
    when Insup::TrackedFile::NEW
      puts "Creating file #{file.path}".green
    when Insup::TrackedFile::MODIFIED, Insup::TrackedFile::UNSURE
      puts "Uploading file #{file.path}".yellow
    end
  end

  def remove_file file
    puts "Deleting file #{file.path}".red
  end

  def batch_upload(files)
    puts "Batch uploading #{files.count} files"
  end

end
