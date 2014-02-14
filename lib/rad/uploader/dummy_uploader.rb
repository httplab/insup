class Rad::Uploader::DummyUploader < Rad::Uploader

  def upload_all files
    puts '---->Dummy Uploader<-----'
    files.each do |x|
      puts "Uploading #{x}... Done."
    end
  end

  def upload_one file

  end

end
