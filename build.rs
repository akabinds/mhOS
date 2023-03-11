use std::{env, error::Error};

fn main() -> Result<(), Box<dyn Error>> {
    let manifest_dir = env::var("CARGO_MANIFEST_DIR")?;

    println!("cargo:rustc-link-arg-bin=mhos=--script={manifest_dir}/linker.ld");
    println!("cargo:rerun-if-changed={manifest_dir}/linker.ld");
    println!("cargo:rerun-if-changed=build.rs");

    Ok(())
}