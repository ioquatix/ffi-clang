module FFI
	module Clang
		module Types
			class Pointer < Type
				def pointee
					Type.create Lib.get_pointee_type(@type), @translation_unit
				end

				def function?
					self.pointee.is_a?(Types::Function)
				end

				def class_type
					if self.kind == :type_member_pointer
						Type.create Lib.type_get_class_type(@type), @translation_unit
					else
						nil
					end
				end

				def forward_declaration?
					# Is this a pointer to a record (struct or union) that referenced
					# a forward declaration at the point of its inclusion in the translation unit?
					if !self.function? && self.pointee.is_a?(Types::Elaborated) &&
						 self.pointee.canonical.is_a?(Types::Record)

						# Get the universal symbol reference
						usr = self.pointee.canonical.declaration.usr

						# Now does that same usr occur earlier in the file?
						first_declaration, _ = self.translation_unit.cursor.find do |child, parent|
							child.usr == usr
						end
						# NOTE - Maybe should also check that the line number of
						# is less than the line number of the declaration this type references
						first_declaration.forward_declaration?
					end
				end
			end
		end
	end
end