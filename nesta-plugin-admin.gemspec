# -*- encoding: utf-8 -*-
$: << File.expand_path("../lib", __FILE__)
require "nesta-plugin-admin/version"

Gem::Specification.new do |s|
  s.name        = "nesta-plugin-admin"
  s.version     = Nesta::Plugin::Admin::VERSION
  s.authors     = ["David Vass", "Daniel Mrozek"]
  s.email       = ["dvd.vass@gmail.com", "me@mrazi.cz"]
  s.homepage    = ""
  s.summary     = %q{NestaCMS administration interface}
  s.description = %q{Awesome administration for nesta CMS}

  s.rubyforge_project = "nesta-plugin-admin"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_dependency("nesta", ">= 0.9.11")
  s.add_dependency("sinatra-contrib")
  s.add_dependency("slim")
  s.add_dependency("therubyracer")
  s.add_dependency("coffee-script")
  s.add_dependency("compass")
  s.add_development_dependency("rake")
end
