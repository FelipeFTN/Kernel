.PHONY: all bootloader clean

all: bootloader

# Compile Bootloader
bootloader:
	mkdir ./bin
	nasm -f bin ./boot.asm -o ./bin/boot.bin

clean:
	rm -r ./bin
