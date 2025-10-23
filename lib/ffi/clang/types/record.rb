module FFI
	module Clang
		module Types
			# Represents a record type (struct or union).
			class Record < Type
				# Get the byte offset of a field within this record.
				# @parameter field [String] The name of the field.
				# @returns [Integer] The byte offset of the field, or -1 if not found.
				def offsetof(field)
					Lib.type_get_offset_of(@type, field)
				end

				# Check if this is an anonymous record.
				# @returns [Boolean] True if this record is unnamed/anonymous.
				def anonymous?
					self.spelling.match(/unnamed/)
				end

				# Get the kind of record (struct or union).
				# @returns [Symbol] Either :struct or :union.
				# @raises [RuntimeError] If the record type cannot be determined.
				def record_type
					case self.spelling
						when /struct/
							:struct
						when /union/
							:union
						else
							raise("Unknown record type: #{self.spelling}")
					end
				end
			end
		end
	end
end
