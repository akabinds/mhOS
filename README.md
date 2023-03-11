# mhOS

mhOS (Minimal Hobbyist Operating System) is a hobbyist operating system, made for fun and learning purposes, targeting the x86-64 ISA (instruction set architecture).
It was developed out of a desire to learn how operating systems work and how to make one. 

## Building mhOS

Please ensure that your host system is Unix-like. If you are on Windows, it is highly recommended to use WSL (Windows Subsystem for Linux).

### Getting the Source Code

To build mhOS on your system, first clone the repository:

**using git**:
```
$ git clone https://github.com/akabinds/mhOS.git  
```

**using git ssh**:
```
$ git clone git@github.com:akabinds/mhOS.git
```

**using github cli**:
```
$ gh repo clone akabinds/mhOS
```

### Dependencies

Next, install the required dependencies:

- `rust` (latest nightly)
- `qemu`
- `nasm`
- `xorriso`

### Makefile

mhOS uses a `Makefile` to implement its build system. This build system provides a few simple commands that allow you to build, run, and test the OS.
There are also commands allowing you to clean build artifacts.

You can build and run the whole OS in one step by simply running `make`. Other options include `make build` to just build the OS, `make run` to run the OS,
and `make clean` to clean all build artifacts.

If running, there are a few options available that you might want to set:
- `KBD_LAYOUT` (supported values: **qwerty**, **azerty**, **dvorak**, default: **qwerty**)
- `CARGO_PROFILE` (supported values: **release**, **debug**, default: **release**)
- `CARGO_FEATURES` (view `Cargo.toml` for a list of available features)
- `CARGO_QUIET` (supported values: **true**, **false**, default: **false**)

You can set these by doing:
```
$ make run OPT=val  
```