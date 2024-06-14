module FFI
	module Clang
		module Types
			class TypeDef < Type
				def canonical
					Type.create Lib.get_canonical_type(@type), @translation_unit
				end

				def anonymous?
					self.canonical.kind == :type_record && self.canonical.anonymous?
				end
			end
		end
	end
end