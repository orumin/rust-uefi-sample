ARCH		= x86_64
TARGET_ARCH		= $(ARCH)-unknown-uefi
BUILD_ROOT	= build
LOADER		= bootx64.efi
HD_IMG		= boot.img

OBJS	    = target/$(TARGET_ARCH)/debug/uefi-sample.efi

MFORMAT		= mformat
MMD			= mmd
MCOPY		= mcopy
RUSTC		= rustc
CARGO		= cargo

SRC	= $(wildcard src/*.rs)

TARGET = $(BUILD_ROOT)/$(LOADER)

.PHONY: all clean iso cargo

all: $(TARGET)

$(OBJS): $(SRC)
	$(CARGO) xbuild --target $(TARGET_ARCH)

$(TARGET): $(OBJS)
	@mkdir -p $(BUILD_ROOT)
	cp $^ $@

img: $(BUILD_ROOT)/$(HD_IMG)

$(BUILD_ROOT)/$(HD_IMG): $(TARGET)
	@dd if=/dev/zero of=fat.img bs=1k count=1440
	@$(MFORMAT) -i fat.img -f 1440 ::
	@$(MMD) -i fat.img ::/EFI
	@$(MMD) -i fat.img ::/EFI/BOOT
	@$(MCOPY) -i fat.img $(TARGET) ::/EFI/BOOT
	@mv fat.img $(BUILD_ROOT)/$(HD_IMG)

run: img
	qemu-system-x86_64 -net none -m 1024 -bios ovmf.fd $(BUILD_ROOT)/$(HD_IMG)
#	qemu-system-x86_64 -enable-kvm -net none -m 1024 -bios ovmf.fd -usb -usbdevice disk::$(BUILD_ROOT)/$(HD_IMG)

clean:
	@$(CARGO) clean
	@rm -rf build fat.img
