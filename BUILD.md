# Building GNU Smalltalk

These instructions cover building from a git checkout. A release tarball
already contains `configure`, so skip the `autoreconf` step there.

## Prerequisites

Required tools:

- C compiler (gcc or clang), make
- autoconf (>= 2.63), automake, libtool, pkg-config
- flex, bison, gperf, gawk
- texinfo (for the documentation)

Required libraries:

- libsigsegv (required by default; see `--with-system-libsigsegv`)
- libffi
- libltdl (libtool's dynamic loader)

Optional libraries (enable the matching packages when found):

- gmp, readline, ncurses, zlib
- expat, gdbm, sqlite3, libpq (PostgreSQL), MySQL client
- gnutls, cairo, gtk2 / glib, SDL 1.2, freeglut

### Fedora

```sh
sudo dnf install gcc make autoconf automake libtool pkgconf-pkg-config \
    flex bison gperf gawk texinfo \
    libsigsegv-devel libffi-devel libtool-ltdl-devel \
    gmp-devel readline-devel ncurses-devel zlib-devel \
    expat-devel gdbm-devel sqlite-devel libpq-devel gnutls-devel
```

### Debian / Ubuntu

```sh
sudo apt-get install build-essential autoconf automake libtool pkg-config \
    flex bison gperf gawk texinfo \
    libsigsegv-dev libffi-dev libltdl-dev \
    libgmp-dev libreadline-dev libncurses-dev zlib1g-dev \
    libexpat1-dev libgdbm-dev libsqlite3-dev libpq-dev libgnutls28-dev
```

## Build

```sh
AUTOPOINT=true autoreconf -vi   # git checkout only; generates ./configure
./configure             # add --prefix=/path to change install location
make
```

`configure` automatically adds the flags modern GCC needs for this old
K&R-style code (`-std=gnu17` and a few `-Wno-error=...`), and skips the
Emacs modes if `emacs` cannot run in batch mode.

Tested on Fedora 44, GCC 16.2: build succeeds and `make check` reports
133 tests as expected, 2 skipped.

Building out of tree also works:

```sh
mkdir build && cd build
../configure
make
```

## Test

```sh
make check
```

Database tests are off by default; enable them with
`--enable-mysql-tests=USER:PASSWORD:DB` and/or
`--enable-postgres-tests=USER:PASSWORD:DB` at configure time.

## Install

```sh
sudo make install
```

## Run without installing

From the build directory:

```sh
./gst
```

## Useful configure options

| Option | Purpose |
| --- | --- |
| `--prefix=DIR` | Install location (default `/usr/local`) |
| `--enable-jit` | Dynamic translation to machine code |
| `--disable-generational-gc` | Turn off generational garbage collection (on by default on most hosts) |
| `--enable-checking` | Runtime assertions (debugging) |
| `--enable-preemption` | Preemptive multitasking |
| `--disable-dld` | Disable loading external modules at runtime |
| `--disable-gtk` | Skip the GTK bindings |
| `--without-emacs` | Skip the Emacs modes |
| `--with-system-libffi[=PATH]` | Use a specific system libffi |
| `--with-system-libltdl[=PATH]` | Use a specific system libltdl |
| `--with-system-libsigsegv[=PATH]` | Use a specific system libsigsegv |
| `--with-imagedir=DIR` | Where to put the kernel image |
| `--with-moduledir=DIR` | Where to put dynamically loaded modules |

Run `./configure --help` for the full list.
