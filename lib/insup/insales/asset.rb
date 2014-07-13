require 'base64'
require 'net/http'
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

  def is_image?
    content_type =~ /image/ || content_type =~ /octet-stream/ || content_type =~ /flash/
  end

  def self.get_type(path)
    TYPE_MAP.each do |k,v|
      return v if path.start_with?("#{k}/")
    end
  end

  def dirname
    TYPE_MAP.invert[type]
  end

  def path 
    "#{dirname}/#{filename}"
  end

  def data
    if respond_to? (:asset_url)
      download_data_from_url
    elsif ['Asset::Snippet', 'Asset::Template'].include?(type)
      w = get_full
      w.content if w.respond_to?(:content)
    end
  end

  def theme_id
    prefix_options[:theme_id]
  end

  def get_full
    self.class.find(id, params: {theme_id: theme_id})
  end

  def url
    "#{self.class.site}#{self.asset_url}"
  end

  def download_data_from_url
    Net::HTTP.get(URI(self.url))
  end
end
