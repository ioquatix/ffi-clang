module FFI
	module Clang
		module Types
			class Array < Type
				def element_type
					Type.create Lib.get_array_element_type(@type), @translation_unit
				end

				def size
					Lib.get_array_size(@type)
				end
			end
		end
	end
end
