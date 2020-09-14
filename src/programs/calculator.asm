;;;----------------------------------------------------------------------------------------------------
;;;    Calcualtor program in assembly
;;;----------------------------------------------------------------------------------------------------

call resetTextMode

mov si, test_string
call print_string

mov ah, 0x00
int 0x16

backTo_kernel:
    mov ah, 0x02
    mov al, 0x03            ; Read three sectors
    int 0x13

    jc backTo_kernel

    mov ax, 0x2000      ; 0x1000 is for file table
    mov ds, ax          ; Data segment  
    mov es, ax          ; Extra segment
    mov fs, ax          ; Extra segment
    mov gs, ax          ; Extra segment
    mov ss, ax          ; Stack Segment

    jmp 0x2000:0x0      ; Far jump to sector adress 0x2000:0x0 (Where kernel is loaded into memory ...)
;;; Includes (START)

include "../print/print_string.asm"
include "../screen/resetTextMode.asm"

;;; Includes (END)

;;; Variabels (START)

test_string: db 'Calcualtor successfully loaded', 0xA, 0xD, 0xA, 0xD, 0xA, 0xD, 'Currently in development press any key to return ...', 0xA, 0xD, 0

;;; Variabels (END)

;;; Sector padding
times 512-($-$$) db 0