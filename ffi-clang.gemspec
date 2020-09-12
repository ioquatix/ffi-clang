
require_relative 'lib/ffi/clang/version'

Gem::Specification.new do |spec|
	spec.name          = "ffi-clang"
	spec.version       = FFI::Clang::VERSION
	spec.authors       = ["Jari Bakken", "Samuel Williams"]
	spec.summary = "Ruby FFI bindings for libclang C interface."
	
	spec.homepage      = "https://github.com/ioquatix/ffi-clang"
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency "ffi"

	spec.add_development_dependency "bundler", ">= 1.3"
	spec.add_development_dependency "rspec", ">= 3.4.0"
	spec.add_development_dependency "rake"
end
