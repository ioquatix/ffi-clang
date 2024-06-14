module FFI
	module Clang
		module Types
			class Record < Type
				def offsetof(field)
					Lib.type_get_offset_of(@type, field)
				end

				def anonymous?
					self.spelling.match(/unnamed/)
				end

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
