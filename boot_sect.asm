;;;
;;;   Simple bootsector
;;;

org 0x7c00              ; Setup origin memory so everything is aligned acc to BIOS

mov bx, 0x1000
mov es, bx
mov bx, 0x0

mov dh, 0x0
mov dl, 0x0
mov ch, 0x0
mov cl, 0x02

read_disk:
    mov ah, 0x02
    mov al, 0x01
    int 0x13

    jc read_disk

    mov ax, 0x1000
    mov ds, ax    
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    jmp 0x1000:0x0

times 510-($-$$) db 0
dw 0xaa55


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ax, bx, cx, dx gen prp regs 16-bit real mode regs
; ah       al
; 00000000 11111111

; eax, ebx, ecx, edx 32-bit
; rax, rbx, rcx, rdx 63-bit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Using dx register for hexa decimal printing
;; using ax for printing strings
;; Using bx for storing strings

;; ax is primary accumulator used for I/O and math also printing alongside interrupts
;; bx is base register used for storing addresses
;; cx is count register basically for maining loop couts
;; dx is also used for I/O and math