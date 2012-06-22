# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ffi/clang/version"

Gem::Specification.new do |s|
  s.name        = "ffi-clang"
  s.version     = FFI::Clang::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken"]
  s.email       = ["jari.bakken@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby FFI bindings for libclang}
  s.description = %q{Ruby FFI bindings for libclang}

  s.rubyforge_project = "ffi-clang"

  s.add_dependency "ffi", ">= 0.6.3"
  s.add_development_dependency "rspec", ">= 2.3.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
