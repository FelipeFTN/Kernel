;   Set start address point
ORG 0x7C00
BITS 16

; offset segments
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_data

; Avoid BIOS overwitten stuff
_start:
  jmp short start
  nop

times 33 db 0

; Output to the screen (video services 'ah' register)
start:
  jmp 0:process

process:
  cli ; Clear Interrupts
  mov ax, 0x00
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00
  sti ; Enables Interrupts

.load_protected:
  cli
  lgdt[gdt_descriptor]
  mov eax, cr0
  or eax, 0x1
  mov cr0, eax
  jmp CODE_SEG:load32
  jmp $

; GDT - Global Descriptor Table
gdt_start:
gdt_null:
  dd 0x0
  dd 0x0

; offset 0x8
gdt_code:      ; CS Should point to this
  dw 0xffff    ; Segment limit first 0-15 bits
  dw 0         ; Base first 0-15 bits
  db 0         ; Base 16-32 bits
  db 0x9a      ; Access byte
  db 11001111b ; High 4 bit flags and the low 4 bit flags
  db 0         ; Base 24-31 bits

; offset 0x10
gdt_data:      ; DS, SS, ES, FS, GS
  dw 0xffff    ; Segment limit first 0-15 bits
  dw 0         ; Base first 0-15 bits
  db 0         ; Base 16-32 bits
  db 0x92      ; Access byte
  db 11001111b ; High 4 bit flags and the low 4 bit flags
  db 0         ; Base 24-31 bits

gdt_end:
gdt_descriptor:
  dw gdt_end - gdt_start-1
  dd gdt_start

[BITS 32]
load32:
  mov eax, 1
  mov ecx, 100
  mov edi, 0x0100000 ; 1 MB in hex
  call ata_lba_read
  jmp CODE_SEG:0x0100000

; Dummy little driver before writing a better one with C
ata_lba_read:
  mov ebx, eax ; Backup the LBA

  ; Send the highest 8 bits of the lba to hard disk controller
  shr eax, 24 ; Shift eax register 24 bits to right
  or eax, 0xE0 ; Selects the master drive
  mov dx, 0x1F6

  ; Send the total sectors to read
  mov eax, ecx
  mov dx, 0x1F2
  out dx, al

  ; Send more bits of the LBA
  mov eax, ebx ; Restore the backup LBA
  mov dx, 0x1F3
  out dx, al

  ; Send more bits  of the LBA
  mov dx, 0x1F4
  mov eax, ebx ; Restore the backup LBA
  shr eax, 8
  out dx, al

  ; Send upper 16 bits of the LBA
  mov dx, 0x1F5
  mov eax, ebx ; Restore the backup LBA
  shr eax, 16
  out dx, al

  mov dx, 0x1F7
  mov al, 0x20
  out dx, al

; Read all sectors into memory
.next_sector:
  push ecx

; Checking if we need to read - delay
.try_again:
  mov dx, 0x1F7
  in al, dx
  test al, 8
  jz .try_again

  ; We need to read 256 words at a time
  mov ecx, 256 ; repeats 256 times - one sector
  mov dx, 0x1F0
  rep insw ; Read a word for the port 0x1F0
  pop ecx
  loop .next_sector
  ; End of reading sectors into memory
  ret

; Fill exceding bits with zeros (510 bytes in total)
times 510-($ - $$) db 0

; Boot signature
dw 0xAA55
