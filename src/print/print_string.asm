;;;----------------------------------------------------------------------------------------------------
;;;    Simple print string using SI register (START)
;;;----------------------------------------------------------------------------------------------------

print_string:
    pusha                       ; Store all regesters on the stack
    mov ah, 0x0e 
    mov bh, 0x00 
    mov bl, 0x07                ; Storing just in case we dont mess up with the vals in our code

print_character:
    mov al, [si]                
    cmp al, 0   
    je end_print_string
    int 0x10
    add si, 1
    jmp print_character

end_print_string:
    popa                        ; Restore all registers form the stack
    ret

;;;----------------------------------------------------------------------------------------------------
;;;    Simple print string using SI register (END)
;;;----------------------------------------------------------------------------------------------------