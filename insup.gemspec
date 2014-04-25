require File.expand_path("../lib/insup/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'insup'
  s.version     = Insup::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Date.today.to_s

  s.summary     = 'InSales theme uploader.'
  s.description = 'Utility for automatic upload of InSales theme files.'
  s.authors     = ['HttpLab', 'Nikita Chernuhin']
  s.email       = 'nuinuhin@gmail.com'
  s.homepage    = 'https://github.com/httplab/insup'
  s.license     = 'MIT'

  s.add_dependency 'colorize'
  s.add_dependency 'trollop'
  s.add_dependency 'listen', '~> 2.7.1'
  s.add_dependency 'gli'
  s.add_dependency 'activeresource', '~> 4.0.0'

  s.add_development_dependency 'rspec', '~> 2.0'
  s.files = `git ls-files`.split("\n")
  s.bindir = 'bin'
  s.test_files = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]
  s.executables << 'insup'
end
