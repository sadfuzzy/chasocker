# -*- encoding: utf-8 -*-
require File.expand_path('../lib/chasocker/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "chasocker"
  gem.version       = Chasocker::VERSION
  gem.authors       = ["Denis Savitsky"]
  gem.email         = ["sadfuzzy@yandex.ru"]
  gem.homepage      = ""
  gem.summary       = %q{Tcp chat server}
  gem.description   = %q{Simple tcp socket chat server.}

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "guard-livereload"
end
