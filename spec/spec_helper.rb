$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'ffi/clang'

include FFI::Clang

module ClangSpecHelper
  def fixture_path(path)
    File.join File.expand_path("../fixtures", __FILE__), path
  end
end

RSpec.configure do |c|
  c.include ClangSpecHelper
end
