#ifndef IDT_H
#define IDT_H

#include <stdint.h>

struct idt_desc { // IDT descriptor
    uint16_t offset_1; // offset bits 0..15
    uint16_t selector; // a code segment selector in GDT or LDT
    uint8_t zero;      // unused, set to 0
    uint8_t type_attr; // type and attributes
    uint16_t offset_2; // offset bits 16..31
} __attribute__((packed)); // packed attribute tells GCC not to change any of the alignment in the structure

struct idtr_desc { // IDT register
    uint16_t limit; // size of IDT
    uint32_t base;  // base address of IDT
} __attribute__((packed)); // packed attribute tells GCC not to change any of the alignment in the structure

void idt_init();

#endif
