;;;
;;;    Switch to 80 x 25 text mode
;;;

resetTextMode:
    ;;; Set text mode
    mov ah, 0x00            ; int 0x10/ 0x00 = Set video mode
    mov al, 0x01            ; Setting video mode to regulair text mode of 80x25
    int 0x10

    ;;; Set color
    mov ah, 0x0B
    mov bh, 0x00
    mov bl, 0x00
    int 0x10

    ret