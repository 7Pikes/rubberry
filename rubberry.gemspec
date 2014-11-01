# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubberry/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubberry'
  spec.version       = Rubberry::VERSION
  spec.authors       = ['undr']
  spec.email         = ['undr@yandex.ru']
  spec.summary       = %q{The ODM functionality for ElasticSearch documents.}
  spec.description   = %q{It works with ElasticSearch like with primary database, without any external models, such as ActiveRecord or Mongoid.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'chewy_query'
  spec.add_dependency 'optionable'
  spec.add_dependency 'elasticsearch'
  spec.add_dependency 'activemodel'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
