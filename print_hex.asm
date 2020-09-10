;;;
;;;    Print hexadecimal vals using print_string.asm
;;;

;;; From 0 to 09 to A to F
;;; Ascii '0'-'9' = hex 0x30 to 0x39
;;; Ascii 'a'-'f' = hex 0x61 to 0x66
;;; Ascii 'A'-'F' = hex 0x41 to 0x46
print_hex:
    pusha
    mov bx, hex_define
    call print_string
    mov cx, 0           ; init loop counter
hex_loop:
    cmp cx, 4
    je end_hex_loop

    ;;convert dx vals to ascii
    mov ax, dx
    and ax, 0x00F       ; first three hex are now zero and last hex is and with 0x000F (0000 0000 0000 1111)
    add al, 0x30
    cmp al, 0x39        ; hex ? 0 - 9
    jle move_into_bx
    add al, 0x07       ; Get ASCII letter 'A'-'F'
    
move_into_bx:
    mov bx, hex_value + 5
    sub bx, cx
    mov [bx], al
    ror dx, 4           ; Roate right by 4 bits for eg: 0x12AB -> 0xB12A
    add cx, 1
    jmp hex_loop
end_hex_loop:
    mov bx, hex_value
    call print_string

    popa
    ret

hex_value: db '0x0000', 0
hex_define: db 'Hex Value : ', 0

;;; Remove hex_define and its call by string it in bx if a problem arises in future