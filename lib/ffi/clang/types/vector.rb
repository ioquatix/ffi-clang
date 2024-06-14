module FFI
	module Clang
		module Types
			class Vector < Type
				def element_type
					Type.create Lib.get_element_type(@type), @translation_unit
				end

				def size
					Lib.get_num_elements(@type)
				end
			end
		end
	end
end
