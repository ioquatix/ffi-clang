# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Masahiro Sano.
# Copyright, 2014-2022, by Samuel Williams.

require_relative 'lib/printing_policy'

module FFI
	module Clang
		class PrintingPolicy < AutoPointer
			def initialize(cursor)
        policy = Lib.get_printing_policy(cursor)
				super(policy)
        @cursor = cursor
			end

			def self.release(pointer)
				Lib.dispose_printing_policy(pointer)
			end

      def get_property(property)
        result = Lib.printing_policy_get_property(self, property)
        result == 0 ? false : true
      end

      def set_property(property, value)
        Lib.printing_policy_set_property(self, property, value ? 1 : 0)
      end

      def pretty_print
        Lib.extract_string Lib.pretty_print(@cursor, self)
      end
		end
	end
end
