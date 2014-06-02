require_relative '../uploader'
require 'colorize'

class Insup::Console::UploadObserver
  def update(event, *args)
    file = args[0]

    case event
    when Insup::Uploader::CREATING_FILE
      puts "Creating file #{file.path}...".green
    when Insup::Uploader::MODIFYING_FILE
      puts "Uploading file #{file.path}...".yellow
    when Insup::Uploader::DELETING_FILE
      puts "Deleting file #{file.path}...".red
    when Insup::Uploader::ERROR
      message = args[1]
      puts "Error in #{file.path}: #{message}".red
    end
  end
end
