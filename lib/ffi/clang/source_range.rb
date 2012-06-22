module FFI
  module Clang
    class SourceRange
      def initialize(ptr)
        @ptr = ptr
      end

      def start
        Lib.get_range_start @ptr
      end

      def end
        Lib.get_range_end @ptr
      end

      # act like a Ruby Range

      alias_method :begin, :start
      alias_method :last, :end

      def cover?(other)
        start <= other && last >= other
      end
    end
  end
end
