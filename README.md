# FFI::Clang

A light-weight wrapper for Ruby exposing [libclang][1]. Works for libclang v3.4+.

[![Build Status](https://secure.travis-ci.org/ioquatix/ffi-clang.svg)](http://travis-ci.org/ioquatix/ffi-clang)
[![Code Climate](https://codeclimate.com/github/ioquatix/ffi-clang.svg)](https://codeclimate.com/github/ioquatix/ffi-clang)

[1]: http://llvm.org/devmtg/2010-11/Gregor-libclang.pdf

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

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright, 2010-2012, by Jari Bakken.  
Copyright, 2013, by Samuel G. D. Williams. <http://www.codeotaku.com>  
Copyright, 2013, by Garry C. Marshall. <http://www.meaningfulname.net>  
Copyright, 2014, by Masahiro Sano.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.