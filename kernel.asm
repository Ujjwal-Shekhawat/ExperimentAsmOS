;;;
;;;    Load our kernel into memory from our boot_sect.asm file
;;;

;;; Set video mode
mov ah, 0x00            ; int 0x10/ 0x00 = Set video mode
mov al, 0x03            ; Setting video mode to regulair text mode of 80x25
int 0x10

;;; Set color
mov ah, 0x0B
mov bh, 0x00
mov bl, 0x01
int 0x10

;;; Teletype output

mov si, my_string
call print_string

; End program
hlt

;;; incluing assembly code in print_string.asm
include 'print_string.asm'
include 'print_hex.asm'

my_string: db 'Booted', 0xA, 0xD, 0 ; 0xD beggining of the line and 0xA new line 

;; Sector padding
times 512-($-$$) db 0