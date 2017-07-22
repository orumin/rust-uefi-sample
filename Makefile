ARCH		= x86_64
TARGET_ARCH		= $(ARCH)-unknown-efi
BUILD_ROOT	= build
LOADER		= bootx64.efi
HD_IMG		= boot.img

OBJS	    = target/$(TARGET_ARCH)/debug/libuefi-sample.a

FORMAT		= efi-app-$(ARCH)
LDFLAGS		= --gc-sections --oformat pei-x86-64 --subsystem 10 -pie -e efi_main

prefix		= x86_64-efi-pe-
CC			= gcc
CXX			= g++
#CC			= $(prefix)gcc
#CXX			= $(prefix)g++
LD			= $(prefix)ld
AS			= $(prefix)as
AR			= $(prefix)ar
OBJCOPY		= $(prefix)objcopy
MFORMAT		= mformat
MMD			= mmd
MCOPY		= mcopy
RUSTC		= rustc
CARGO		= xargo

SRC	= $(wildcard src/*.rs)

TARGET = $(BUILD_ROOT)/$(LOADER)

.PHONY: all clean iso cargo

all: $(TARGET)

$(OBJS): $(SRC)
	$(CARGO) build --target $(TARGET_ARCH)
	cd target/$(TARGET_ARCH)/debug && $(AR) x *.a

$(TARGET): $(OBJS)
	@mkdir -p $(BUILD_ROOT)
	$(LD) $(LDFLAGS) -o $@ $(dir $(OBJS))*.o

img: $(BUILD_ROOT)/$(HD_IMG)

$(BUILD_ROOT)/$(HD_IMG): $(TARGET)
	@dd if=/dev/zero of=fat.img bs=1k count=1440
	@$(MFORMAT) -i fat.img -f 1440 ::
	@$(MMD) -i fat.img ::/EFI
	@$(MMD) -i fat.img ::/EFI/BOOT
	@$(MCOPY) -i fat.img $(TARGET) ::/EFI/BOOT
	@mv fat.img $(BUILD_ROOT)/$(HD_IMG)

run: img
	qemu-system-x86_64 -enable-kvm -net none -m 1024 -bios ovmf.fd -usb -usbdevice disk::$(BUILD_ROOT)/$(HD_IMG)

clean:
	@$(CARGO) clean
	@rm -rf build fat.img
