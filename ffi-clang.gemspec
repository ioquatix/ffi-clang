# frozen_string_literal: true

require_relative "lib/ffi/clang/version"

Gem::Specification.new do |spec|
	spec.name = "ffi-clang"
	spec.version = FFI::Clang::VERSION
	
	spec.summary = "Ruby FFI bindings for libclang C interface."
	spec.authors = ["Samuel Williams", "Masahiro Sano", "Carlos Martín Nieto", "Jari Bakken", "Takeshi Watanabe", "Garry Marshall", "George Pimm", "Greg Hazel", "Luikore", "Michael Metivier", "Dave Wilkinson", "Hayden Purdy", "Mike Dalessio", "Motonori Iwamuro", "Niklas Therning", "Cameron Dutro", "Dominic Sisnero", "Hal Brodigan"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/ffi-clang"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob(['{ext,lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "ffi"
	
	spec.add_development_dependency "bake-test"
	spec.add_development_dependency "bundler", ">= 1.3"
	spec.add_development_dependency "rspec", ">= 3.4.0"
	spec.add_development_dependency "rake"
end
