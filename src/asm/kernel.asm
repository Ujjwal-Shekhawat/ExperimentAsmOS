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

;;; BIOS Teletype output

mov si, my_string
call print_string

mov si, menu
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
    je filetable
    cmp al, 'N'
    je end_program
    cmp al, 'R'
    je warm_reboot
    mov si, command_not_found
    call print_string
    jmp get_input

found:
    mov si, user_input_1
    call print_string
    jmp get_input

;;;----------------------------------------------------------------------------------------------------
;;;    Printing the filetable from file_table.asm (START)
;;;----------------------------------------------------------------------------------------------------

filetable:
    ;;; Load file table string from it memory location 0x1000:0 in binary
    xor cx, cx          ; Reset counter for chars in file name
    mov ax, 0x1000      ; file table location
    mov es, ax          ; ES = 0x1000
    xor bx, bx          ; ES:BX = 0x1000:0 als BX = 0
    mov ah, 0x0e        ; getting ready to print

fileTableLoop:
    inc bx
    mov al, [ES:BX]
    cmp al, '}'         ; End of file table ?
    je end_program
    cmp al, ','         ; Next table element ?
    je new_line
    inc cx              ; increment counter
    int 0x10
    jmp fileTableLoop

new_line:
    ; Simply put a new line
    xor cx, cx
    mov al, 0x0A
    int 0x10
    mov al, 0x0D
    int 0x10
    jmp fileTableLoop

;;;----------------------------------------------------------------------------------------------------
;;;    Printing the filetable from file_table.asm (END)
;;;----------------------------------------------------------------------------------------------------

;;;----------------------------------------------------------------------------------------------------
;;;    Warm reboot for x86 (START)
;;;----------------------------------------------------------------------------------------------------

warm_reboot:
    jmp 0xFFFF:0x0000

;;;----------------------------------------------------------------------------------------------------
;;;    Warm reboot for x86 (END)
;;;----------------------------------------------------------------------------------------------------

end_program:
    ; End program
    jmp $
    ;; Another way to do it but cli is omportant else it will brek
    ; cli
    ; hlt

;;;----------------------------------------------------------------------------------------------------
;;;    Includes (START)
;;;----------------------------------------------------------------------------------------------------

include "../print/print_string.asm"

;;;----------------------------------------------------------------------------------------------------
;;;    Includes (END)
;;;----------------------------------------------------------------------------------------------------
;;; incluing assembly code in print_string.asm
; include 'print_string.asm'
; include 'print_hex.asm'

;;;----------------------------------------------------------------------------------------------------
;;;    Declared Stirngs (START)
;;;----------------------------------------------------------------------------------------------------

my_string: db 'Booted into FRANXX', 0xA, 0xD, 0 ; 0xD beggining of the line and 0xA new line 
menu: db '--------------------------------------------------------------------------------',\
'F: File browser', 0xA, 0xD,\
'N: Halt system', 0xA, 0xD,\
'R: Reboot',0xA, 0xD,\
'--------------------------------------------------------------------------------', 0
user_input_1: db 0xA, 0xD, 'Command present', 0xA, 0xD, 0
command_not_found: db 0xA, 0xD, 'Command not found', 0xA, 0xD, 0

command_string: db ''

;;;----------------------------------------------------------------------------------------------------
;;;    Declared Strings (END)
;;;----------------------------------------------------------------------------------------------------

;; Sector padding
times 512-($-$$) db 0