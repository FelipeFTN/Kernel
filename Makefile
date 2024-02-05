.PHONY: all bootloader clean run

all: bootloader

build:
	mkdir -p ./bin
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

# Compile Bootloader
bootloader:
	mkdir -p ./bin
	nasm -f bin ./boot.asm -o ./bin/boot.bin
	
	# Write message into boot sector
	dd if=./message >> ./bin/boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./bin/boot.bin

# Qemu System
run: bootloader
	qemu-system-x86_64 -hda ./bin/boot.bin

# Clear Binary
clean:
	rm -rf ./bin/boot.bin
