#include "idt.h"
#include "config.h"
#include "../kernel.h"
// #include "../memory/memory.h"

#include <string.h>

struct idt_desc idt_descriptors[KERNEL_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* ptr);

void idt_zero() {
    print("Divide by zero error\n");
}

void idt_set(int interrupt_no, void* address) { // set the address of the interrupt handler
    struct idt_desc* desc = &idt_descriptors[interrupt_no]; // get the descriptor
    desc->offset_1 = (uint32_t) address & 0xFFFF; // offset bits 0..15
    desc->selector = KERNEL_CODE_SELECTOR; // code segment selector
    desc->zero = 0; // unused, set to 0
    desc->type_attr = 0xEE; // 11101110
    desc->offset_2 = ((uint32_t) address >> 16) & 0xFFFF; // offset bits 16..31
}

void idt_init() {
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t) idt_descriptors;

    idt_set(0, idt_zero);

    // Load the interrupt descriptor table
    idt_load(&idtr_descriptor);
}
