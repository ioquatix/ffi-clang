
require_relative '../../../lib/ffi/clang'

include FFI::Clang

TMP_DIR = File.expand_path("../tmp/", __FILE__)

module ClangSpecHelper
	def fixture_path(path)
		File.join File.expand_path("fixtures", __dir__), path
	end

	def find_all(cursor, kind)
		ret = []

		cursor.visit_children do |cursor, parent|
			if (cursor.kind == kind)
				ret << cursor
			end
			:recurse
		end

		ret
	end

	def find_first(cursor, kind)
		find_all(cursor, kind).first
	end

	def find_all_matching(cursor, &term)
		ret = []

		cursor.visit_children do |child, parent|
			if term.call child, parent
				ret << child
			end

			:recurse
		end

		ret
	end

	def find_matching(cursor, &term)
		find_all_matching(cursor, &term).first
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
