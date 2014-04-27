# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'itunes_store_bot'
  s.version       = '0.1.3'
  s.date          = '2014-04-26'
  s.summary       = 'Get any iOS App Rating info'
  s.description   = '[Alpha version] Get your iOS App Rating, number of votes.. from the iTunes Store'
  s.authors       = ['Stefano Bortolotti']
  s.files         = `git ls-files`.split($/)
  s.require_paths = ['lib']
  s.homepage      = 'http://rubygems.org/gems/itunes_store_bot'
  s.license       = 'MIT'

  s.add_dependency('http', '>= 0.5.0')
  s.add_dependency('json', '>= 1.8.0')
end