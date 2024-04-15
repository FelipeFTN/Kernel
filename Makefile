.PHONY: all bootloader clean run

includes := -I./src -I./src/idt -I./src/memory
asm_files := ./src/idt/idt.asm
asm_objs := ./build/idt/idt.asm.o
c_files := ./src/kernel.c ./src/idt/idt.c ./src/memory/memory.c
c_objs := ./build/kernel.o ./build/idt/idt.o ./build/memory/memory.o
flags := -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

linker_ld_file := ./src/linker.ld

kernel_asm_obj_file := ./build/kernel.asm.o
kernel_file := ./src/kernel.asm
kernel_binary := ./bin/kernel.bin

kernelfull_obj_file := ./build/kernelfull.o

boot_binary := ./bin/boot.bin
boot_file := ./src/boot/boot.asm

all: clean build

build: $(boot_binary) $(kernel_binary)
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

$(kernel_binary): $(c_objs) $(asm_objs) $(kernel_asm_obj_file)
	i686-elf-ld -g -relocatable $^ -o $(kernelfull_obj_file)
	i686-elf-gcc $(flags) -T $(linker_ld_file) -o $@ -ffreestanding -O0 -nostdlib $(kernelfull_obj_file)

$(boot_binary): $(boot_file)
	nasm -f bin $^ -o $@

$(kernel_asm_obj_file): $(kernel_file)
	nasm -f elf -g $^ -o $@

# This might break if I add many files to $@
$(asm_objs): $(asm_files)
	nasm -f elf -g $< -o $@

$(c_objs): ./build/%.o: ./src/%.c
	i686-elf-gcc $(includes) $(flags) -std=gnu99 -c -o $@ $<

run: clean build
	qemu-system-x86_64 -hda ./bin/os.bin

# Clear Binary
clean:
	rm -rf **/*.asm.o
	rm -rf **/*.bin
	rm -rf **/*.o
