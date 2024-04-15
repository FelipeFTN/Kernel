section .asm

global idt_load
idt_load:
    push ebp
    mov ebp, esp

    ; Load the IDT
    mov ebx, [ebp + 8]
    lidt [ebx]

    pop ebp
    ret
