# This makefile serves as the build system for mhOS.

# If no targets were specified in the command line, just build the ISO iamge
.DEFAULT_GOAL := iso

# Configuration defaults
KBD_LAYOUT ?= qwerty
CARGO_PROFILE ?= release
CARGO_FEATURES ?=
KVM ?= no
QEMU_LOG ?= no

ifneq ($(KBD_LAYOUT),$(filter $(KBD_LAYOUT),qwerty azerty dvorak))
$(error Error: unsupported keyboard layout "$(KBD_LAYOUT)". Options are "qwerty", "azerty", or "dvorak")
endif

export MHOS_KBD_LAYOUT = $(KBD_LAYOUT)
export MHOS_VERSION = v0.1.0

# Determining Cargo arguments
cargo-args = --bin mhos --no-default-features

ifneq ($(CARGO_PROFILE),$(filter $(CARGO_PROFILE), debug release))
$(error Error: invalid Cargo profile "$(CARGO_PROFILE)". Options are "debug" and "release")
endif

ifeq ($(CARGO_PROFILE),release)
	cargo-args += --release
endif

ifneq ($(CARGO_FEATURES),)
	cargo-args += --features $(CARGO_FEATURES)
endif


# Determining QEMU arguments
qemu-args = -no-reboot -no-shutdown -M smm=off -machine q35 -drive file=$(ISO),format=raw -bios $(OVMF)

ifeq ($(CARGO_PROFILE),debug)
	qemu-args += -s -S
endif

ifeq ($(QEMU_LOG),yes)
	qemu-args += -D $(BUILD_DIR)/qemu-log.txt
endif

ifeq ($(KVM),yes)
	qemu-args += -cpu host -accel kvm
else
	qemu-args += -cpu max
endif

# Directory and file path definitions
BUILD_DIR 	 := build
BUILD_ROOT 	 := $(BUILD_DIR)/root
ISO       	 := $(BUILD_ROOT)/mhos-v0.1.0.iso
LIMINE_DIR 	 := $(BUILD_DIR)/limine
EFI_SYS_PART := $(BUILD_ROOT)/EFI/BOOT
OVMF         := $(BUILD_ROOT)/OVMF-pure-efi.fd
KERNEL_BIN 	 := target/x86_64-unknown-none/$(CARGO_PROFILE)/mhos


# Targets
.PHONY: all clean
all: run 

limine_update:
	@cd $(LIMINE_DIR)
	@git fetch
	$(MAKE)
	@cd -
	
$(ISO): build
	xorriso -as mkisofs --efi-boot limine-cd-efi.bin -efi-boot-part --efi-boot-image --protective-msdos-label $(BUILD_ROOT) -o $(ISO)

# Convenience target for building the ISO image
iso: $(ISO)

build:
	cargo build $(cargo-args)

ifneq ($(wildcard $(LIMINE_DIR)),)
	$(MAKE) limine_update
else
	@mkdir -p $(EFI_SYS_PART) $(LIMINE_DIR)
	@cp $(KERNEL_BIN) $(BUILD_ROOT)
	@git clone --depth 1 --branch v4.x-branch-binary https://github.com/limine-bootloader/limine.git $(LIMINE_DIR)
	@cp limine.cfg $(LIMINE_DIR)/limine.sys $(LIMINE_DIR)/limine-cd-efi.bin $(BUILD_ROOT)
	@cp $(LIMINE_DIR)/BOOTX64.EFI $(EFI_SYS_PART)	
	@wget -P $(BUILD_ROOT) https://github.com/rust-osdev/ovmf-prebuilt/releases/download/v0.20220719.209%2Bgf0064ac3af/OVMF-pure-efi.fd
endif

	$(MAKE) iso

run: build
	qemu-system-x86_64 $(qemu-args)

clean:
	rm -rf $(BUILD_DIR)
	cargo clean