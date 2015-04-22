# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sensu-run-check/version'

Gem::Specification.new do |spec|
  spec.name          = 'sensu-run-check'
  spec.version       = SensuRunCheck::VERSION
  spec.authors       = ['Rickard von Essen']
  spec.email         = ['rickard.von.essen@gmail.com']
  spec.summary       = 'Run Sensu checks localy on the command line.'
  spec.description   = 'Run Sensu checks localy on the command line.'
  spec.homepage      = 'https://github.com/rickard-von-essen/sensu-run-check'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sensu', '= 0.17.2'

  spec.add_development_dependency 'bundler', '~> 1.6'
end
