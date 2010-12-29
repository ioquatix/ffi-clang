require 'ffi'

module Clang
  class Error < StandardError
  end
end

require 'ffi-clang/lib'
require 'ffi-clang/index'
require 'ffi-clang/translation_unit'
require 'ffi-clang/diagnostic'
require 'ffi-clang/source_location'
require 'ffi-clang/source_range'

