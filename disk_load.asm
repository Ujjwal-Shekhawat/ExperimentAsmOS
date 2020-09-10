;;;
;;;    Disk read
;;;
disk_load:
    push dx
    mov ah, 0x02        ; Sets up int0x13/ah=02h, BIOS read sectors into memory
    mov al, dh          ; Number of sector we want to read
    mov ch, 0x00        ; cylinder 0
    mov dh, 0x00        ; head 0
    mov cl, 0x02        ; starting reading at cl sector 2 right after our boot src sector

    int 0x13            ; BIOS interupt for disk functions

    jc disk_error       ; jump if disk error

    pop dx
    cmp dh, al
    jne disk_error
    ret

disk_error:
    mov bx, DISK_ERROR_MESSAGE
    call print_string
    hlt

DISK_ERROR_MESSAGE db 'Disk read error', 0