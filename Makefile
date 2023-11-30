.PHONY: all bootloader clean run

all: bootloader

# Compile Bootloader
bootloader:
	mkdir ./bin
	nasm -f bin ./boot.asm -o ./bin/boot.bin

run:
	qemu-system-x86_64 -hda ./bin/boot.bin

clean:
	rm -r ./bin
