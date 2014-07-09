require 'base64'

class Insup::Insales::Asset < Insup::Insales::Base
  belongs_to :theme, class_name: 'Insup::Insales::Theme'

  self.prefix = '/admin/themes/:theme_id/'

  TYPE_MAP = {
    'media' => 'Asset::Media',
    'snippets' => 'Asset::Snippet',
    'templates' => 'Asset::Template',
    'config' => 'Asset::Configuration' 
  }.freeze

  def filename
    fname_rex = /\..*+$/
    if name.match(fname_rex)
      name
    elsif human_readable_name.match(fname_rex)
      human_readable_name
    else
      nil
    end
  end

  def self.get_type(path)
    Asset::TYPE_MAP.each do |k,v|
      if path.start_with?("#{k}/")
        res = v
        break
      end
    end  
  end

  def dirname
    TYPE_MAP.invert[type]
  end

  def path 
    "#{dirname}/#{filename}"
  end

  def data
    return content if respond_to?(:content)
    return Base64.decode64(attachment) if respond_to?(:attachment)
  end

  def theme_id
    prefix_options[:theme_id]
  end

  def get
    self.class.find(id, params: {theme_id: theme_id})
  end
end
