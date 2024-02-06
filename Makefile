.PHONY: all bootloader clean run

linker_ld_file := ./src/linker.ld

kernel_obj_file := ./build/kernel.asm.o
kernel_file := ./src/kernel.asm
kernel_binary := ./bin/kernel.bin

kernelfull_obj_file := ./build/kernelfull.o

boot_binary := ./bin/boot.bin
boot_file := ./src/boot/boot.asm

all: build

build: $(boot_binary) $(kernel_binary)
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

$(kernel_binary): $(kernel_obj_file)
	i686-elf-ld -g -relocatable $^ -o $(kernelfull_obj_file)
	i686-elf-gcc -T $(linker_ld_file) -o $@ -ffreestanding -O0 -nostdlib $(kernelfull_obj_file)

$(boot_binary): $(boot_file)
	nasm -f bin $^ -o $@

$(kernel_obj_file): $(kernel_file)
	nasm -f elf -g $^ -o $@

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
	rm -rf **/*.asm.o
	rm -rf **/*.bin
	rm -rf **/*.o
