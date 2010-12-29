module Clang
  class Diagnostic
    def initialize(ptr)
      @ptr = FFI::AutoPointer.new(ptr, Lib.method(:dispose_diagnostic))
    end

    def format(opts = {})
      raise NotImplementedError, "#{self.class}#format options" unless opts.empty?

      cxstring = Lib.format_diagnostic(@ptr, Lib.default_diagnostic_display_options)
      result = Lib.get_c_string(cxstring)
      Lib.dispose_string(cxstring)

      result
    end

    def severity
      raise NotImplementedError
    end

    def source_location
      SourceLocation.new(Lib.get_diagnostic_location(@ptr))
    end

    def fixits
      raise NotImplementedError
      # unsigned clang_getDiagnosticNumFixIts(CXDiagnostic Diag);
      # – CXString clang_getDiagnosticFixIt(CXDiagnostic Diag,
      #                                     unsigned FixIt,
      #                                     CXSourceRange *ReplacementRange);

    end

    def spelling
      raise NotImplementedError
    end

  end
end
