module FFI
  module Clang
    class Diagnostic
      def initialize(ptr)
        @ptr = AutoPointer.new(ptr, Lib.method(:dispose_diagnostic))
      end

      def format(opts = {})
        cxstring = Lib.format_diagnostic(@ptr, display_opts(opts))
        Lib.extract_string cxstring
      end

      def severity
        Lib.get_diagnostic_severity @ptr
      end

      def source_location
        sl = Lib.get_diagnostic_location @ptr
        SourceLocation.new(sl)
      end

      def spelling
        Lib.get_c_string Lib.get_diagnostic_spelling(@ptr)
      end

      def fixits
        raise NotImplementedError
        # unsigned clang_getDiagnosticNumFixIts(CXDiagnostic Diag);
        # – CXString clang_getDiagnosticFixIt(CXDiagnostic Diag,
        #                                     unsigned FixIt,
        #                                     CXSourceRange *ReplacementRange);

      end

      def ranges
        0.upto(range_count - 1).map { |idx|
          SourceRange.new Lib.get_diagnostic_range(@ptr, idx)
        }
      end

      private

      def range_count
        Lib.get_diagnostic_num_ranges @ptr
      end

      def display_opts(opts)
        if opts.empty?
          Lib.default_diagnostic_display_options
        else
          Lib.bitmask_from Lib::DiagnosticDisplayOptions, opts
        end
      end

    end
  end
end
