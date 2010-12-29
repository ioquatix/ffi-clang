module Clang
  module Lib
    extend FFI::Library

    ffi_lib "clang"

    enum :diagnostic_severity, [:ignored, :note, :warning, :error, :fatal]

    attach_function :create_index, :clang_createIndex, [:int, :int], :pointer
    attach_function :dispose_index, :clang_disposeIndex, [:pointer], :void
    attach_function :parse_translation_unit, :clang_parseTranslationUnit, [:pointer, :string, :pointer, :int, :pointer, :uint, :uint], :pointer
    attach_function :dispose_translation_unit, :clang_disposeTranslationUnit, [:pointer], :void
    attach_function :get_num_diagnostics, :clang_getNumDiagnostics, [:pointer], :uint
    attach_function :get_diagnostic, :clang_getDiagnostic, [:pointer, :uint], :pointer
    attach_function :dispose_diagnostic, :clang_disposeDiagnostic, [:pointer], :void
    attach_function :format_diagnostic, :clang_formatDiagnostic, [:pointer, :uint], :pointer
    attach_function :default_diagnostic_display_options, :clang_defaultDiagnosticDisplayOptions, [], :uint
    attach_function :get_c_string, :clang_getCString, [:pointer], :string
    attach_function :dispose_string, :clang_disposeString, [:pointer], :void
    attach_function :get_diagnostic_location, :clang_getDiagnosticLocation, [:pointer], :pointer
    attach_function :get_diagnostic_spelling, :clang_getDiagnosticSpelling, [:pointer], :pointer
    attach_function :get_diagnostic_severity, :clang_getDiagnosticSeverity, [:pointer], :diagnostic_severity
    attach_function :equal_locations, :clang_equalLocations, [:pointer, :pointer], :uint

    def self.extract_string(cxstring)
      result = get_c_string(cxstring)

      dispose_string cxstring
      result
    end
  end
end
