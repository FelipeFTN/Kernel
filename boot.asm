;   Set start address point
ORG 0x7C00
BITS 16

; Output to the screen (video services 'ah' register)
start:
  mov si, message
  call print
  jmp $

print: 
  mov bx, 0

.loop:
  lodsb ; Increments characters from 'ah' register to 'si'
  cmp al, 0
  je .done
  call print_char
  jmp .loop

.done:
  ret

print_char:
	mov ah, 0eh ; Display characters function ( 0eh )
	int 0x10 ; Interrupt video services
  ret

  jmp $

message: db 'Hello World', 0

; Fill exceding bits with zeros (510 bytes in total)
times 510-($ - $$) db 0

; Boot signature
dw 0xAA55
