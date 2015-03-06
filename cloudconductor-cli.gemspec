# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloud_conductor_cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'cloud_conductor_cli'
  spec.version       = CloudConductorCli::VERSION
  spec.authors       = ['TIS Inc.']
  spec.email         = ['ccndctr@gmail.com']
  spec.summary       = 'Command line tool for CloudConductor'
  spec.description   = 'Command line tool for CloudConductor that manage clouds, systems, and applications.'
  spec.homepage      = 'http://cloudconductor.org/'
  spec.license       = 'Apache License, Version v2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'activesupport', '~> 4.1'
  spec.add_dependency 'thor'
  spec.add_dependency 'formatador'
  spec.add_dependency 'rb-readline'
  spec.add_dependency 'faraday'
  spec.add_dependency 'rack'
end
