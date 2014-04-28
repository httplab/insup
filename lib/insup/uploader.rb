class Insup::Uploader

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

end
