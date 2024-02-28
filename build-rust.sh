#!/bin/bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
	
echo "Checking Rust version..."
echo "Rust version: $(rustc --version)"

nasm -f bin ./rust/boot/bootloader.asm -o ./bin/bootloader.bin
rustc --target x86_64-unknown-none -Z no-landing-pads --crate-type=lib ./rust/kernel.rs -o ./build/kernel.o
i686-elf-ld -m elf_i386 -T ./rust/linker.ld ./build/kernel.o -o ./bin/kernel.bin
