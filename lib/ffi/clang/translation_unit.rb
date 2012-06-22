module FFI
  module Clang
    class TranslationUnit
      def initialize(ptr)
        @ptr = AutoPointer.new(ptr, Lib.method(:dispose_translation_unit))
      end

      def diagnostics
        n = Lib.get_num_diagnostics(@ptr)
        0.upto(n - 1).map do |idx|
          Diagnostic.new(Lib.get_diagnostic(@ptr, idx))
        end
      end

    end
  end
end
