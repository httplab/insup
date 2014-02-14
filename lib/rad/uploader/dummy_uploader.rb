class Rad::Uploader::DummyUploader < Rad::Uploader

  def upload files
    puts '---->Dummy Uploader<-----'
    files.each do |x|
      puts "Uploading #{x}"
    end
  end

end
