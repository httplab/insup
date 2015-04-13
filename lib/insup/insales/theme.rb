class Insup
  class Insales
    class Theme < Insup::Insales::Base
      has_many :assets, class_name: 'Insup::Insales::Asset'
    end
  end
end
