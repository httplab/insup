require('colorize')

class Rad::Uploader::DummyUploader < Rad::Uploader

  def upload_new_file file
    puts "Creating file #{file.path}...".green
  end


  def upload_modified_file file
    puts "Uploading file #{file.path}...".yellow
  end


  def remove_file file
    puts "Deleting file #{file.path}...".red
  end

end
