# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Charlie Savage.
# Copyright, 2024, by Samuel Williams.

require_relative 'lib/printing_policy'

module FFI
	module Clang
		# Represents a printing policy that controls how declarations are formatted.
		class PrintingPolicy < AutoPointer
			# Initialize a printing policy for a cursor.
			# @parameter cursor [FFI::Pointer] The cursor to get the policy from.
			def initialize(cursor)
        policy = Lib.get_printing_policy(cursor)
				super(policy)
        @cursor = cursor
			end

			# Release the printing policy pointer.
			# @parameter pointer [FFI::Pointer] The pointer to release.
			def self.release(pointer)
				Lib.dispose_printing_policy(pointer)
			end

			# Get a printing policy property value.
			# @parameter property [Symbol] The property name.
			# @returns [Boolean] The property value.
      def get_property(property)
        result = Lib.printing_policy_get_property(self, property)
        result == 0 ? false : true
      end

			# Set a printing policy property value.
			# @parameter property [Symbol] The property name.
			# @parameter value [Boolean] The property value.
      def set_property(property, value)
        Lib.printing_policy_set_property(self, property, value ? 1 : 0)
      end

			# Pretty print the cursor using this policy.
			# @returns [String] The formatted cursor string.
      def pretty_print
        Lib.extract_string Lib.pretty_print(@cursor, self)
      end
		end
	end
end
