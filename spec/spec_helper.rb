# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2010, by Jari Bakken.
# Copyright, 2012, by Hal Brodigan.
# Copyright, 2013-2022, by Samuel Williams.
# Copyright, 2013, by Carlos Martín Nieto.
# Copyright, 2013, by Takeshi Watanabe.
# Copyright, 2014, by Masahiro Sano.

require_relative '../lib/ffi/clang'

include FFI::Clang

TMP_DIR = File.expand_path("tmp", __dir__)

module ClangSpecHelper
	def fixture_path(path)
		File.join File.expand_path("ffi/clang/fixtures", __dir__), path
	end

	def find_all_by_kind(cursor, kind)
		cursor.find_by_kind(true, kind)
	end

	def find_by_kind(cursor, kind)
		cursor.find_by_kind(true, kind).first
	end

	def find_matching(cursor, &term)
		child, parent = cursor.find(&term)
		child
	end
end

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"
	
	config.include ClangSpecHelper
	
	supported_versions = ['3.4', '3.5', '3.6', '3.7', '3.8', '3.9', '4.0']
	current_version = ENV['LLVM_VERSION'] || supported_versions.last
	supported_versions.reverse_each { |version|
		break if version == current_version
		sym = ('from_' + version.tr('.', '_')).to_sym
		config.filter_run_excluding sym => true
	}

	supported_versions.each { |version|
		break if version == current_version
		sym = ('upto_' + version.tr('.', '_')).to_sym
		config.filter_run_excluding sym => true
	}
end
