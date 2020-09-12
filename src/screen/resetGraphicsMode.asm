;;;
;;;    Graphics mode switching
;;;

resetGraphicsMode:
    ;;; Set video mode to graphics mode
    mov ah, 0x00            ; int 0x10/ 0x00 = Set video mode
    mov al, 0x13            ; Setting video mode to 360 x 120 255 col depth
    int 0x10

    ret
