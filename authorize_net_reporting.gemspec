# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "authorize_net_reporting/version"

Gem::Specification.new do |s|
  s.name        = "authorize_net_reporting"
  s.version     = AuthorizeNetReporting::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jazmin Schroeder"]
  s.email       = ["jazminschroeder@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Authorize.net Transaction Details API }
  s.description = %q{Retrieve transaction details through the Authorize.net Transaction Details API }

  s.rubyforge_project = "authorize_net_reporting"
  s.add_dependency 'httparty'
  s.add_dependency 'builder'
  s.add_development_dependency "rspec"  
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
