
require_relative '../../../lib/ffi/clang'

include FFI::Clang

TMP_DIR = File.expand_path("../tmp/", __FILE__)

module ClangSpecHelper
	def fixture_path(path)
		File.join File.expand_path("fixtures", __dir__), path
	end

	def find_all(cursor, kind)
		cursor.find_all(kind)
	end

	def find_first(cursor, kind)
		cursor.find_first(kind)
	end

	def find_all_matching(cursor, &term)
		cursor.find_all_matching(&term)
	end

	def find_matching(cursor, &term)
		cursor.find_matching(&term)
	end
end

RSpec.configure do |c|
	c.include ClangSpecHelper
	supported_versions = ['3.2', '3.3', '3.4', '3.5']
	current_version = ENV['LLVM_VERSION'] || supported_versions.last
	supported_versions.reverse_each { |version|
		break if version == current_version
		sym = ('from_' + version.tr('.', '_')).to_sym
		c.filter_run_excluding sym => true
	}

	supported_versions.each { |version|
		break if version == current_version
		sym = ('upto_' + version.tr('.', '_')).to_sym
		c.filter_run_excluding sym => true
	}
end
