What's this?
------------

This is sample program for UEFI apps written by Rust lang!

How to build
------------

- First, prepare GNU binutils, its target for x86_64-efi-pe
- Second, you have to use Rust nightly compiler.

```sh
$ rustup install nightly
$ rustup default nightly
$ cargo install xargo
$ export PATH="$HOME/.cargo/bin:$PATH"
```

and introduce x86\_64-efi-pe binutils

```sh
$ curl -O https://orum.in/distfiles/x86_64-efi-pe-binutils.tar.xz
$ mkdir $PWD/toolchain
$ tar xf x86_64-efi-pe-binutils.tar.xz -C $PWD/toolchain
$ export PATH=$PATH:$PWD/toolchain/usr/bin/
```

Then, only you run `make` on root directory.

How to run
-------------

- install mtools on your system
- then, kick `make run` command.
