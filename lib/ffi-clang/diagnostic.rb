module Clang
  class Diagnostic
    def initialize(ptr)
      @ptr = FFI::AutoPointer.new(ptr, Lib.method(:dispose_diagnostic))
    end

    def format(opts = {})
      raise NotImplementedError, "#{self.class}#format options" unless opts.empty?

      cxstring = Lib.format_diagnostic(@ptr, Lib.default_diagnostic_display_options)

      Lib.extract_string cxstring
    end

    def severity
      Lib.get_diagnostic_severity(@ptr)
    end

    def source_location
      SourceLocation.new(Lib.get_diagnostic_location(@ptr))
    end

    def spelling
      Lib.get_c_string(Lib.get_diagnostic_spelling(@ptr))
    end

    def fixits
      raise NotImplementedError
      # unsigned clang_getDiagnosticNumFixIts(CXDiagnostic Diag);
      # – CXString clang_getDiagnosticFixIt(CXDiagnostic Diag,
      #                                     unsigned FixIt,
      #                                     CXSourceRange *ReplacementRange);

    end

  end
end
