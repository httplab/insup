require File.expand_path("../lib/insup/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'insup'
  s.version     = Insup::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Date.today.to_s

  s.summary     = 'InSales theme uploader.'
  s.description = 'Utility for automatic upload of InSales theme files.'
  s.authors     = ['HttpLab', 'Nu-hin']
  s.email       = 'nuinuhin@gmail.com'
  s.homepage    = 'https://github.com/httplab/insup'
  s.license     = 'MIT'

  s.add_dependency 'colorize', '~> 0.7'
  s.add_dependency 'gli', '~> 2.11'
  s.add_dependency 'listen', '~> 2.7'
  s.add_dependency 'match_files', '~> 0.2'
  s.add_dependency 'activeresource', '~> 4.0'

  s.files = `git ls-files`.split("\n")
  s.bindir = 'bin'
  s.test_files = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]
  s.executables << 'insup'

  s.post_install_message = "type 'insup help' for help"
end
