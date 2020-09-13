;;;----------------------------------------------------------------------------------------------------
;;;    Calcualtor program in assembly
;;;----------------------------------------------------------------------------------------------------

call resetTextMode

mov si, test_string
call print_string

jmp $
;;; Includes (START)

include "../print/print_string.asm"
include "../screen/resetTextMode.asm"

;;; Includes (END)

;;; Variabels (START)

test_string: db 'Calcualtor successfully loaded', 0xA, 0xD, 0

;;; Variabels (END)

;;; Sector padding
times 512-($-$$) db 0