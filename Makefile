.PHONY: all run clean
all: build run

KBD_LAYOUT = qwerty # qwerty, dvorak, or azerty
CARGO_PROFILE = release
CARGO_FEATURES = 
CARGO_QUIET = false

export MHOS_KBD_LAYOUT = $(KBD_LAYOUT)

cargo-args = --no-default-features --bin mhos
qemu-args = -no-reboot -no-shutdown -machine q35 -M smm=off -drive file=build/root/mhos.iso,format=raw -bios build/root/OVMF-pure-efi.fd

ifeq ($(CARGO_PROFILE), release)
	cargo-args += --release
else
	qemu-args += -s -S
endif

ifeq ($(CARGO_QUIET), true)
	cargo-args += --quiet
endif

ifneq ($(CARGO_FEATURES),)
	cargo-args += $(CARGO_FEATURES)
endif

cargobuild:
	cargo build $(cargo-args)

build/root: cargobuild
	mkdir -p $@/EFI/BOOT $(@D)/limine
	cp target/x86_64-unknown-none/$(CARGO_PROFILE)/mhos $@
	git clone --depth 1 --branch v4.x-branch-binary https://github.com/limine-bootloader/limine.git $(@D)/limine
	cp limine.cfg $@
	cp $(@D)/limine/limine.sys $(@D)/limine/limine-cd-efi.bin $@
	cp $(@D)/limine/BOOTX64.EFI $@/EFI/BOOT
	wget -P $@ https://github.com/rust-osdev/ovmf-prebuilt/releases/download/v0.20220719.209%2Bgf0064ac3af/OVMF-pure-efi.fd
	
mhos.iso: build/root
	xorriso -as mkisofs --efi-boot limine-cd-efi.bin -efi-boot-part --efi-boot-image --protective-msdos-label $< -o $</$@

build: mhos.iso

run:
	qemu-system-x86_64 $(qemu-args)

clean:
	rm -rf build
	cargo $@