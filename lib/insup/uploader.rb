class Insup::Uploader

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

end
