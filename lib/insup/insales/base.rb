class Insup::Insales::Base < ActiveResource::Base
  self.headers['User-Agent'] = %W(
    insup/#{Insup::VERSION}
    ActiveResource/#{ActiveResource::VERSION::STRING}
    Ruby/#{RUBY_VERSION}
  ).join(' ')

  self.format = :xml
  self.prefix = '/admin/'

  def self.configure(api_key, domain, password)
    self.user = api_key
    self.site = "http://#{domain}"
    self.password = password
    self
  end
end
