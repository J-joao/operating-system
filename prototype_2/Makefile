ASM=nasm
CC=gcc

SRC_DIR=src
BUILD_DIR=build
TOOLS_DIR=tools

.PHONY: all floppy_img kernel bootloader clean always

#
# floppy_img
#
floppy_img: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero bs=512 count=2880 of=$(BUILD_DIR)/main_floppy.img
	mkfs.fat -F 12 -n "OS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

#
# bootloader
#
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) -f bin $(SRC_DIR)/bootloader/boot.asm -o $(BUILD_DIR)/bootloader.bin

#
# kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) -f bin $(SRC_DIR)/kernel/main.asm -o $(BUILD_DIR)/kernel.bin

#
# tools
#
tools_fat: $(BUILD_DIR)/$(TOOLS_DIR)/fat

$(BUILD_DIR)/$(TOOLS_DIR)/fat: always $(TOOLS_DIR)/fat/fat.c
	mkdir -p $(BUILD_DIR)/tools
	$(CC) -g -o $(BUILD_DIR)/$(TOOLS_DIR)/fat $(TOOLS_DIR)/fat/fat.c

#
# always
#
always:
	mkdir -p $(BUILD_DIR)

#
# clean
#
clean:
	rm -rf $(BUILD_DIR)/*