# mhOS

mhOS (Minimal Hobbyist Operating System) is a hobbyist operating system, made for fun and learning purposes, targeting the x86-64 ISA (instruction set architecture).
It was developed out of a desire to learn how operating systems work and how to make one. 

## Building mhOS

Please ensure that your host system is Unix-like. If you are on Windows, it is highly recommended to use WSL2 (Windows Subsystem for Linux 2). Follow the following steps to 
build mhOS on your system:

1. **Install Required Dependencies**
    ```
    $ sudo apt install qemu qemu-kvm kvm xorriso curl wget nasm make
    ```

2. **Getting the Source Code**

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

3. **Install Rust**

    ```
    $ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```

4. **Setup Proper Rust Toolchain**

    ```
    $ rustup install nightly
    $ rustup default nightly  
    ```

### Makefile

mhOS uses a `Makefile` to implement its build system. This build system provides a few simple commands that allow you to build, run, and test the OS.
There are also commands allowing you to clean build artifacts.

You can build and run the whole OS in one step by simply running `make`. Other options include `make build` to just build the OS, `make run` to run the OS,
and `make clean` to clean all build artifacts.

If running, there are a few options available that you might want to set:
- `KBD_LAYOUT` (supported values: **qwerty**, **azerty**, **dvorak**, default: **qwerty**)
- `CARGO_PROFILE` (supported values: **release**, **debug**, default: **release**)
- `CARGO_FEATURES` (view `Cargo.toml` for a list of available features)
- `KVM` (supported values: **yes**, **no**, default: **no**)
- `QEMU_LOG` (supported values: **yes**, **no**, default: **no**)

You can set these by doing:
```
$ make [CMD] OPT=val  
```