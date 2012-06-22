require 'ffi'
require "rbconfig"

module FFI::Clang
  class Error < StandardError
  end

  def self.platform
    os = RbConfig::CONFIG["host_os"]

    case os
    when /darwin/
      :osx
    when /linux/
      :linux
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    else
      os
    end
  end
end

require 'ffi/clang/lib'
require 'ffi/clang/index'
require 'ffi/clang/translation_unit'
require 'ffi/clang/diagnostic'
require 'ffi/clang/source_location'
require 'ffi/clang/source_range'

