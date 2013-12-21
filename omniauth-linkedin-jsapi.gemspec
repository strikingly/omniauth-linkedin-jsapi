# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-linkedin-jsapi/version'

Gem::Specification.new do |gem|
  gem.name          = "omniauth-linkedin-jsapi"
  gem.version       = OmniAuth::LinkedInJsapi::VERSION
  gem.authors       = ["Daniel Gong"]
  gem.email         = ["daniel@strikingly.com"]
  gem.description   = %q{A LinkedIn JSAPI strategy for OmniAuth.}
  gem.summary       = %q{A LinkedIn JSAPI strategy for OmniAuth.}
  gem.homepage      = "https://github.com/strikingly/omniauth-linkedin-jsapi"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'omniauth', '~> 1.0'
  gem.add_runtime_dependency 'oauth', '~> 0.4'
  gem.add_runtime_dependency 'multi_json', '~> 1.3'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'

  gem.add_development_dependency 'rspec', '~> 2.13.0'
end
