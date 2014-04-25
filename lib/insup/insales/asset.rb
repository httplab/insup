class Insup::Insales::Asset < Insup::Insales::Base
  belongs_to :theme, class_name: 'Insup::Insales::Theme'

  self.prefix = '/admin/themes/:theme_id/'
end
