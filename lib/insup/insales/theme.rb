class Insup::Insales::Asset < Insup::Insales::Base; end

class Insup::Insales::Theme < Insup::Insales::Base
  has_many :assets, class_name: 'Insup::Insales::Asset'
end
