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

Please see the [project documentation](https://ioquatix.github.io/ffi-clang/) for more details.

### Library Version

Due to issues figuring out which library to use, we require you to manually specify it. For example, to run the tests, with MacPorts llvm/clang 3.4, use the following:

    LLVM_CONFIG=llvm-config-mp-3.4 rake

## Releases

Please see the [project releases](https://ioquatix.github.io/ffi-clang/releases/index) for all releases.

### v0.14.0

  - Helper method that returns a curors's <code class="language-ruby">FFI::Clang::Cursor\#qualified\_display\_name</code>.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
