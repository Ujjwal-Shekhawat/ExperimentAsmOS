;;;
;;;   Simple bootsector
;;;

org 0x7c00              ; Setup origin memory so everything is aligned acc to BIOS

;;; READ FILE TABLE IN TO MEMORY FIRST
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
    mov ah, 0x02        ; BIOS int 13 ah = 2 read disk sectors
    mov al, 0x01        ; Read one sector (n number of sectors can be read 0x0n)
    int 0x13            ; BIOS interrupt for disks

    jc read_disk1       ; Try again if the carry flag = 1

;;; READ KERNEL INTO MEMORY SECOND
    ;;; Set up regs to load sectors into memory
    mov bx, 0x2000          ; load sector into memory address
    mov es, bx              
    mov bx, 0x0             ; ES:BX = 0x2000:0x0

    ;;; Setup disk read
    mov dh, 0x0             ; head 0
    mov dl, 0x0             ; drive 0
    mov ch, 0x0             ; cylinder 0
    mov cl, 0x03            ; Starting sector to read disk from (Here 3rd sector)

read_disk2:
    mov ah, 0x02
    mov al, 0x03            ; Read three sectors (as kernel occupies 3 sectors now)
    int 0x13

    jc read_disk2

    mov ax, 0x2000      ; 0x1000 is for file table
    mov ds, ax          ; Data segment  
    mov es, ax          ; Extra segment
    mov fs, ax          ; Extra segment
    mov gs, ax          ; Extra segment
    mov ss, ax          ; Stack Segment

    jmp 0x2000:0x0      ; Far jump to sector adress 0x2000:0x0 (Where kernel is loaded into memory ...)

;;; Boot sector padding
times 510-($-$$) db 0
dw 0xaa55               ; BIOS x86 magic number

;;; Later I will shift these comments to the kernel.asm 
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
