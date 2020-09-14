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
mov bl, 0x00
int 0x10

;;; BIOS Teletype output

mov si, boot_message
call print_string

main_menu:
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
    cmp al, 'G'
    je graphics_mode_switch
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
    call manual
    call new_line       ; Print a new line before printing the contents of file table

fileTableLoop:
    mov al, [ES:BX]
    cmp al, 0
    je get_program_name
    int 0x10
    cmp cx, 9
    je file_extension
    inc bx
    inc cx
    jmp fileTableLoop

file_extension:
    mov cx, 6

    call print_blank_space  ; Prints blank spce [cx] times

    inc bx
    mov al, [ES:BX]
    int 0x10
    inc bx
    mov al, [ES:BX]
    int 0x10
    inc bx
    mov al, [ES:BX]
    int 0x10

check_directory_number:
    mov cx, 16
    call print_blank_space  ; Prints blank spce [cx] times

    inc bx
    mov al, [ES:BX]
    call print_hex_as_ascii

start_sector_number:
    mov cx, 18
    call print_blank_space  ; Prints blank spce [cx] times

    inc bx
    mov al, [ES:BX]
    call print_hex_as_ascii

file_size:
    mov cx, 18
    call print_blank_space  ; Prints blank spce [cx] times

    inc bx
    mov al, [ES:BX]
    call print_hex_as_ascii
    mov al, 0xA
    int 0x10
    mov al, 0xD
    int 0x10

    inc bx
    xor cx, cx
    jmp fileTableLoop

get_program_name:
    mov si, program_menu
    call print_string
    mov di, command_string          ; di pointing to command string
    mov byte [command_length], 0    ; rester the length of stirng variable to 0 

program_name_loop:
    xor ax, ax                  ; BIOS interrupt to get user input, input goes in to al register ax = 0x00, al =0x00
    int 0x16

    mov ah, 0x0e
    cmp al, 0xD
    je start_search
    inc byte [command_length]   ; add to counter
    mov [di], al
    inc di                      ; Increment di
    int 0x10                    ; Put character to screen
    jmp program_name_loop

start_search:
    mov di, command_string      ; Reset di to start address of command stirng 
    xor bx, bx                  ; Zero out bx

check_next_character:
    mov al, [ES:BX]
    cmp al, 0
    je program_not_found
    cmp al, [di]
    je start_compare
    add bx, 16
    jmp check_next_character

start_compare:
    push bx
    mov byte cl, [command_length]

compare_loop:
    mov al, [ES:BX]
    inc bx
    cmp al, [di]
    jne restart_search
    dec cl
    jz found_program
    inc di
    jmp compare_loop

restart_search:
    mov di, command_string
    pop bx
    inc bx
    jmp check_next_character

program_not_found:
    mov si, pgm_not_found
    call print_string
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10
    cmp al, 'Y'
    je filetable
    jmp stop

found_program:
    add bx, 4
    mov cl, [ES:BX]
    inc bx
    mov bl, [ES:BX]

load_program:
    xor ax, ax
    mov dl, 0x00
    int 0x13
    mov ax, 0x8000
    mov es, ax
    mov al, bl
    xor bx, bx

    mov ah, 0x02
    mov ch, 0x00
    mov dh, 0x00
    mov dl, 0x00

    int 0x13
    jnc program_loaded
    
    mov si, program_not_loaded
    call print_string
    mov ah, 0x00
    int 0x16
    jmp main_menu

program_loaded:
    mov ax, 0x8000
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x8000:0x0000    ; Far jump to this memory address where we loaded our program 

stop:
    mov si, end_filebrowser
    call print_string
    mov ah, 0x00        ; Set ah to 0x00 for getting to take user input
    int 0x16            ; BIOS interrupt for user input
    jmp main_menu       ; Jumpnack to main_menu

new_line:
    ; Simply put a new line
    xor cx, cx
    mov al, 0x0A
    int 0x10
    mov al, 0x0D
    int 0x10
    jmp fileTableLoop

manual:
    mov si, filebrowser_manual
    call print_string
    ret

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

;;;----------------------------------------------------------------------------------------------------
;;;    Graphics Mode (START)
;;;----------------------------------------------------------------------------------------------------

graphics_mode_switch:
    call resetGraphicsMode
    mov ah, 0x0C
    mov al, 0x01
    mov bh, 0x00
    mov cx, 100
    mov dx, 100
squareLoop:
    inc cx
    int 0x10
    cmp cx, 150
    jne squareLoop
    inc dx
    int 0x10
    mov cx, 99
    cmp dx, 150
    jne squareLoop

    int 0x10

    ;;; Return to the main menu
    mov si, end_filebrowser     ; Variable contaning a message
    call print_string
    mov ah, 0x00
    int 0x16
    call resetTextMode          ; Restore
    jmp main_menu

    hlt

;;;----------------------------------------------------------------------------------------------------
;;;    Graphics Mode (END)
;;;----------------------------------------------------------------------------------------------------

end_program:
    ; End program
    jmp $
    ;; Another way to do it but cli is omportant else it will brek
    ; cli
    ; hlt

;;;----------------------------------------------------------------------------------------------------
;;;    Converts and prints hex value to ascii value (START)
;;;----------------------------------------------------------------------------------------------------
print_hex_as_ascii:
    mov ah, 0x0e
    add al, 0x30
    cmp al, 0x39
    jle hex_num
    add al, 0x7

hex_num:
    int 0x10
    ret

;;;----------------------------------------------------------------------------------------------------
;;;    Converts and prints hex value to ascii value (END)
;;;----------------------------------------------------------------------------------------------------

;;;----------------------------------------------------------------------------------------------------
;;;    Prints blank space [cx] times (START)
;;;----------------------------------------------------------------------------------------------------
print_blank_space:
    cmp cx, 0
    je end_print_blank_space
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    dec cx
    jmp print_blank_space

end_print_blank_space:
    ret 
;;;----------------------------------------------------------------------------------------------------
;;;    Prints blank space [cx] times (END)
;;;----------------------------------------------------------------------------------------------------

;;;----------------------------------------------------------------------------------------------------
;;;    Includes (START)
;;;----------------------------------------------------------------------------------------------------

include "../print/print_string.asm"
include "../screen/resetTextMode.asm"
include "../screen/resetGraphicsMode.asm"

;;;----------------------------------------------------------------------------------------------------
;;;    Includes (END)
;;;----------------------------------------------------------------------------------------------------
;;; incluing assembly code in print_string.asm
; include 'print_string.asm'
; include 'print_hex.asm'

;;;----------------------------------------------------------------------------------------------------
;;;    Declared Stirngs (START)
;;;----------------------------------------------------------------------------------------------------

boot_message: db 'Booted into FRANXX', 0xA, 0xD, 0 ; 0xD beggining of the line and 0xA new line 
menu: db 'MAIN MENU-----------------------------------------------------------------------',\
'F: File browser', 0xA, 0xD,\
'N: Halt system', 0xA, 0xD,\
'R: Reboot',0xA, 0xD,\
'G: Graphcis Mode', 0xA, 0xD,\
'--------------------------------------------------------------------------------', 0
user_input_1: db 0xA, 0xD, 'Command present', 0xA, 0xD, 0
command_not_found: db 0xA, 0xD, 'Command not found', 0xA, 0xD, 0
filebrowser_manual: db 0xA, 0xD, '--------------------------------------------------------------------------------', \
                       'File name    ', 'File extension', '    Directory entry    ', 'Starting sector', '    File size', \
                       0xA, 0xD, '--------------------------------------------------------------------------------', 0xA, 0xD, 0
program_menu: db 0xA, 0xD, 0xA, 0xD, 'Enter the name of the program :', 0xA, 0xD, 0
program_found_string: db 0xA, 0xD, 'Program found', 0xA, 0xD, 0xA, 0xD, 0xA, 0xD, 0
pgm_not_found: db 0xA, 0xD, 'Program not found Again (Y) : ', 0
sec_not_found: db 0xA, 0xD, 'Sector not found try again (Y) : ', 0
program_not_loaded: db 0xA, 0xD, 'Program not loaded', 0xA, 0xD, 'Press any key to return ...', 0xA, 0xD, 0
command_length: db 0
end_filebrowser: db 0xA, 0xD, 'Press any key to return...', 0xA, 0xD, 0

loading_message: db 0xA, 0xD, 'Press any key to load program ...', 0xD, 0xA
command_string: db ''

;;;----------------------------------------------------------------------------------------------------
;;;    Declared Strings (END)
;;;----------------------------------------------------------------------------------------------------

;; Sector padding
times 1536-($-$$) db 0
