# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'version'

Gem::Specification.new do |spec|
	spec.name          = "ffi-clang"
	spec.version       = FFI::Clang::VERSION
	spec.authors       = ["Jari Bakken", "Samuel Williams"]
	spec.email         = ["Jari Bakken", "samuel.williams@oriontransfer.co.nz"]
	spec.description   = %q{Ruby FFI bindings for libclang C interface.}
	spec.summary       = %q{Ruby FFI bindings for libclang C interface.}
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency "ffi"

	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rspec", "~> 3.4.0"
	spec.add_development_dependency "rake"
end
