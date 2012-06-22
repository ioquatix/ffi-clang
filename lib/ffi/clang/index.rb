module FFI
  module Clang
    class Index
      def initialize(opts = {})
        exclude_declarations_from_pch = opts[:exclude_declarations_from_pch] ? 1 : 0
        display_diagnostics = opts[:display_diagnostics] ? 1 : 0

        @ptr = AutoPointer.new Lib.create_index(exclude_declarations_from_pch, display_diagnostics),
          Lib.method(:dispose_index)

      end

      def parse_translation_unit(source_file, command_line_args = nil, opts = {})
        command_line_args = Array(command_line_args)

        tu = Lib.parse_translation_unit(@ptr,
                                        source_file,
                                        args_pointer_from(command_line_args),
                                        command_line_args.size, nil, 0, options_bitmask_from(opts))

        raise Error, "error parsing #{source_file.inspect}" if tu.nil? || tu.null?

        TranslationUnit.new tu
      end

      private

      def args_pointer_from(command_line_args)
        args_pointer = MemoryPointer.new(:pointer)

        strings = command_line_args.map do |arg|
          MemoryPointer.from_string(arg.to_s)
        end

        args_pointer.put_array_of_pointer(strings) unless strings.empty?
        args_pointer
      end

      def options_bitmask_from(opts)
        Lib.bitmask_from Lib::TranslationUnitFlags, opts
      end

    end
  end
end
