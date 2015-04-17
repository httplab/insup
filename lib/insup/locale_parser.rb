class Insup
  module LocaleParser
    def self.locale(locale = nil)
      locale = locale || ENV['LANG'] || ENV['LANGUAGE']
      rex = /^(?<primary>[a-z]{2})
            (?:[\-_](?<region>[A-Z]{2})
            (?:\.[a-zA-Z0-9\-_]+)?)?$/x

      m = locale.match(rex)

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
