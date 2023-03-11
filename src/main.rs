#![no_std]
#![no_main]
#![feature(decl_macro, abi_x86_interrupt)]

#[cfg(not(target_pointer_width = "64"))]
compile_error!("mhOS is only designed for 64-bit architectures");

#[cfg(not(target_arch = "x86_64"))]
compile_error!("mhOS only supports the x86_64 architecture");

use core::fmt::{self, Write};
use limine::LimineTerminalRequest;
use spin::Mutex;

static TERMINAL_REQUEST: LimineTerminalRequest = LimineTerminalRequest::new(0);

struct Writer {
    terminals: Option<&'static limine::LimineTerminalResponse>,
}

unsafe impl Send for Writer {}

impl fmt::Write for Writer {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        // Get the Terminal response and cache it.
        let response = match self.terminals {
            None => {
                let response = TERMINAL_REQUEST.get_response().get().ok_or(fmt::Error)?;
                self.terminals = Some(response);
                response
            }
            Some(resp) => resp,
        };

        let write = response.write().ok_or(fmt::Error)?;

        // Output the string onto each terminal.
        for terminal in response.terminals() {
            write(terminal, s);
        }

        Ok(())
    }
}

static WRITER: Mutex<Writer> = Mutex::new(Writer { terminals: None });

pub fn _print(args: fmt::Arguments) {
    WRITER
        .lock()
        .write_fmt(args)
        .expect("failed to write to terminal");
}

pub macro print($($t:tt)*) {
    _print(format_args!($($t)*))
}

pub macro println {
    ()          => (print!("\n")),
    ($($t:tt)*) => (print!("{}\n", format_args!($($t)*)))
}

#[no_mangle]
fn kmain() -> ! {
    println!("Hello World");
    
    loop {}
}

#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    println!("panic occurred");
    
    loop {}
}
