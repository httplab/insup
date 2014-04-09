$:.push File.expand_path('../lib', __FILE__)
require 'insup/version'

Gem::Specification.new do |s|
  s.name        = 'insup'
  s.version     = Insup::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Date.today.to_s

  s.summary     = 'InSales theme uploader.'
  s.description = 'Utility for automatic upload of InSales theme files.'
  s.authors     = 'Nikita Chernuhin'
  s.email       = 'n@httplab.ru'
  s.homepage    = 'https://github.com/httplab/insup'
  s.license     = 'MIT'

  s.add_dependency 'rake'
  s.add_dependency 'awesome_print'
  s.add_dependency 'colorize'
  s.add_dependency 'trollop'
  s.add_dependency 'listen', '~> 1.5.7'

  s.add_development_dependency 'rspec', '~> 2.0'

  s.files = `git ls-files`.split("\n")

  s.bindir = 'bin'
  s.executables << 'insup'
end
