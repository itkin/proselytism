# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'proselytism/version'

Gem::Specification.new do |gem|
  gem.name          = "proselytism"
  gem.version       = Proselytism::VERSION
  gem.authors       = ["Itkin"]
  gem.email         = ["nicolas.papon@webflows.fr"]
  gem.description   = %q{TODO: document converter and plain text extractor}
  gem.summary       = %q{TODO: document converter and plain text extractor}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport", ">= 3.0.0"
  gem.add_dependency 'system_timer'
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pry"

end
