module FFI
  module Clang
    class SourceLocation
      def initialize(ptr)
        # no dispose function - should we keep a reference to TU / diagnostic?
        @ptr = ptr
      end

      def ==(other)
        return unless other.kind_of? self.class
        Lib.equal_locations(@ptr, other.ptr) != 0
      end

      alias_method :eql?, :==

        protected

      def ptr
        @ptr
      end

    end
  end
end
