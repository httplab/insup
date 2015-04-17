class Insup
  module LocaleParser
    def self.locale(locale = nil)
      locale = locale || ENV['LANG'] || ENV['LANGUAGE']
      m = locale.match(/^(?<primary>[a-z]{2})(?:[\-_](?<region>[A-Z]{2})(?:\.[a-zA-Z0-9\-_]+)?)?$/)

      if m
        if m[:region]
          "#{m[:primary]}-#{m[:region]}"
        else
          m[:primary]
        end
      else
        'en'
      end
    end
  end
end
