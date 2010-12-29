module Clang
  class Index
    def initialize(opts = {})
      exclude_declarations_from_pch = opts[:exclude_declarations_from_pch] ? 1 : 0
      display_diagnostics = opts[:display_diagnostics] ? 1 : 0

      @ptr = FFI::AutoPointer.new Lib.create_index(exclude_declarations_from_pch, display_diagnostics),
                                  Lib.method(:dispose_index)

    end

    def parse_translation_unit(source_file, command_line_args = nil, opts = {})
      command_line_args = Array(command_line_args)
      args_pointer = FFI::MemoryPointer.new(:pointer)

      strings = command_line_args.map do |arg|
        FFI::MemoryPointer.from_string(arg.to_s)
      end

      args_pointer.put_array_of_pointer(strings) unless strings.empty?

      raise NotImplementedError, "options for #{self.class}#parse_translation_unit" unless opts.empty?
      tu = Lib.parse_translation_unit(@ptr, source_file, args_pointer, command_line_args.size, nil, 0, 0)

      raise Error, "error parsing #{source_file.inspect}" if tu.nil? || tu.null?

      TranslationUnit.new tu
    end

  end
end
