# FFI::Clang

A light-weight wrapper for Ruby exposing [libclang](http://llvm.org/devmtg/2010-11/Gregor-libclang.pdf). Works for libclang v3.4+.

[![Development Status](https://github.com/ioquatix/ffi-clang/workflows/Test/badge.svg)](https://github.com/ioquatix/ffi-clang/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

    gem 'ffi-clang'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffi-clang

## Usage

Traverse the AST in the given file:

    index = Index.new
    translation_unit = index.parse_translation_unit("list.c")
    cursor = translation_unit.cursor
    cursor.visit_children do |cursor, parent|
    	puts "#{cursor.kind} #{cursor.spelling.inspect}"
    	
    	next :recurse 
    end

### Library Version

Due to issues figuring out which library to use, we require you to manually specify it. For example, to run the tests, with MacPorts llvm/clang 3.4, use the following:

    LLVM_CONFIG=llvm-config-mp-3.4 rake

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
