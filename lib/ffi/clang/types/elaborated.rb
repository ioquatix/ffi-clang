module FFI
	module Clang
		module Types
			class Elaborated < Type
				def named_type
					Type.create Lib.get_named_type(@type), @translation_unit
				end

				# Example anonymous union where `u` is an elaborated type
				#
				#	 typedef struct {
				#		 union {
				#			 int idata;
				#		 } u;
				#	 } SomeStruct;
				def anonymous?
					self.declaration.anonymous?
				end

				def pointer?
					self.canonical.is_a?(Pointer)
				end
			end
		end
	end
end