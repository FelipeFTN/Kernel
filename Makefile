.PHONY: all bootloader clean run

includes := -I./src
flags := -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

c_files := ./src/kernel.c
c_objs := ./build/kernel.o

rust_objs := ./build/kernel.a

linker_ld_file := ./src/linker.ld

kernel_obj_file := ./build/kernel.asm.o # $(c_objs)
kernel_file := ./src/kernel.asm
kernel_binary := ./bin/kernel.bin

kernelld_obj_file := ./build/kernelld.o

boot_binary := ./bin/boot.bin
boot_file := ./src/boot/boot.asm

all: build

build: $(boot_binary) $(kernel_binary) $(rust_objs) # $(c_objs)
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

$(boot_binary): $(boot_file)
	nasm -f bin $^ -o $@

$(kernel_binary): $(kernel_obj_file) $(rust_objs)
	i686-elf-ld -g -relocatable $(kernel_obj_file) -o $(kernelld_obj_file)
	i686-elf-gcc $(flags) -T $(linker_ld_file) -l./build/kernel.a -o $@ -ffreestanding -O0 -nostdlib $(kernelld_obj_file)

$(kernel_obj_file): $(kernel_file)
	nasm -f elf -g $^ -o $@

$(c_objs): $(c_files)
	i686-elf-gcc $(includes) $(flags) -std=gnu99 -c $^ -o $@

$(rust_objs):
	cargo build --target ./.cargo/x86_64-kernel.json
	cp ./target/x86_64-kernel/debug/libkernel.a ./build/kernel.a

run: clean build
	qemu-system-x86_64 -hda ./bin/os.bin

# Clear Binary
clean:
	rm -rf ./target/
	rm -rf **/*.asm.o
	rm -rf **/*.bin
	rm -rf **/*.o
	rm -rf **/*.a
