.PHONY: all bootloader clean run

binary_file := ./bin/boot.bin
nasm_file := ./src/boot/boot.asm

all: build

build: $(binary_file)
	dd if=./src/boot/message >> ./bin/boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./bin/boot.bin

$(binary_file): $(nasm_file)
	nasm -f bin $^ -o $@

# Compile Bootloader - MyKernel
bootloader:
	mkdir -p ./bin
	nasm -f bin ./src/boot/myKernel.asm -o ./bin/boot.bin
	
	# Write message into boot sector
	dd if=./src/boot/message >> ./bin/boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./bin/boot.bin

# Qemu System
run: bootloader
	qemu-system-x86_64 -hda ./bin/boot.bin

# Clear Binary
clean:
	rm -rf ./bin/boot.bin
