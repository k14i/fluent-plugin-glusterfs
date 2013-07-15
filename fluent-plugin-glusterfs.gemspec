# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-glusterfs"
  gem.authors       = ["Keisuke Takahashi"]
  gem.email         = ["keithseahus@gmail.com"]
  gem.description   = %q{Fluentd plugin for GlusterFS}
  gem.summary       = %q{Fluentd plugin for GlusterFS}
  gem.homepage      = "https://github.com/keithseahus/fluent-plugin-glusterfs"
  gem.version       = "1.0.0"
  gem.license       = "Apache 2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  requires = ['fluentd']
  requires.each {|name| gem.add_runtime_dependency name}
  requires += ['rake']
  requires.each {|name| gem.add_development_dependency name}
end
