require 'base64'

class Insup::Insales::Asset < Insup::Insales::Base
  belongs_to :theme, class_name: 'Insup::Insales::Theme'

  self.prefix = '/admin/themes/:theme_id/'

  TYPE_MAP = {
    'media' => 'Asset::Media',
    'snippets' => 'Asset::Snippet',
    'templates' => 'Asset::Template'
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

  def dirname
    TYPE_MAP.invert[type]
  end

  def path 
    "#{dirname}/#{filename}"
  end

  def data
    content || Base64.decode64(attachment)
  end

  def theme_id
    prefix_options[:theme_id]
  end

  def get
    self.class.find(id, params: {theme_id: theme_id})
  end
end
