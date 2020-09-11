;;;
;;;   Simple bootsector
;;;

org 0x7c00              ; Setup origin memory so everything is aligned acc to BIOS

;;; READ FILE TABLE INTTO MEMORY
;;; Set up regs to load sectors into memory
mov bx, 0x1000          ; load sector memory address
mov es, bx              
mov bx, 0x0             ; ES:BX = 0x1000:0x0

;;; Setup disk read
mov dh, 0x0             ; head 0
mov dl, 0x0             ; drive 0
mov ch, 0x0             ; cylinder 0
mov cl, 0x02            ; Starting sector to read disk from (Here 2rd sector)

read_disk1:
    mov ah, 0x02
    mov al, 0x01
    int 0x13

    jc read_disk1

;;; READ KERNEL INTO MEMORY
    ;;; Set up regs to load sectors into memory
    mov bx, 0x2000          ; load sector memory address
    mov es, bx              
    mov bx, 0x0             ; ES:BX = 0x1000:0x0

    ;;; Setup disk read
    mov dh, 0x0             ; head 0
    mov dl, 0x0             ; drive 0
    mov ch, 0x0             ; cylinder 0
    mov cl, 0x03            ; Starting sector to read disk from (Here 2rd sector)

read_disk2:
    mov ah, 0x02
    mov al, 0x01
    int 0x13

    jc read_disk2

    mov ax, 0x2000      ; 0x1000 is for file table
    mov ds, ax    
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp 0x2000:0x0

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