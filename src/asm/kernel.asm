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

;;; User input
get_input:
    mov di, command_string
key_loop:
    mov ax, 0x00            ; BISO interrupt to get user input, input goes in to al register ax = 0x00, al =0x00
    int 0x16

    mov ah, 0x0e
    cmp al, 0xD
    je run_command
    int 0x10                  ; Put character to screen
    mov [di], al
    inc di                  ; Increment di
    jmp key_loop

run_command:
    mov byte [di], 0
    mov al, [command_string]
    cmp al, 'F'
    je found
    cmp al, 'N'
    je end_program
    mov si, command_not_found
    call print_string
    jmp get_input

found:
    mov si, user_input_1
    call print_string
    jmp get_input

end_program:
    ; End program
    jmp $
    ;; Another way to do it but cli is omportant else it will brek
    ; cli
    ; hlt

print_string:
    mov ah, 0x0e 
    mov bh, 0x0
    mov bl, 0x07
print_character:
    mov al, [si]                
    cmp al, 0   
    je end_print_string
    int 0x10
    add si, 1
    jmp print_character
end_print_string:
    ret

;;; incluing assembly code in print_string.asm
; include 'print_string.asm'
; include 'print_hex.asm'

my_string: db 'Booted into FRANXX', 0xA, 0xD, 0 ; 0xD beggining of the line and 0xA new line 
user_input_1: db 0xA, 0xD, 'Command present', 0xA, 0xD, 0
command_not_found: db 0xA, 0xD, 'Command not found', 0xA, 0xD, 0

command_string: db ''

;; Sector padding
times 512-($-$$) db 0