_start:
    mov ax, 0x0013
    int 0x10                ; set video 320x200x256 mode

    mov ax, 0xa000          ; 0xa000 video segment
    mov es, ax              ; setup extended segment

    ; initialize vars
    mov word [score_w], 0   ; zeroing the score
    mov byte [e_t_set_b], enemy_timer_max   ; enemy timer

    ; clearing enemy memory
    clear_enemies:
        mov cx, max_enemies*enemy_size
        mov di, enemies_start
    _ce_l:
        mov byte [di], 0
        inc di
        loop _ce_l
    ; end clear_enemies

    ; init screen
    mov al, 0xf            ; Border color
    mov cx, screen_width*screen_height
    xor di, di
    rep stosb

    ; draw ground line
    xor ax, ax
    mov di, ground_start
    mov cx, screen_width/2
    rep stosw

    ; init_dirt generates random dirt
    init_dirt:
        mov cx, dirt_rows
    _id_l:
        call random_pixel
        loop _id_l
    ; end init_dirt


_game_loop:
    dec byte [enemy_timer_b]    ; decreasing the enemy timer


    ; clear playarea
    mov al, 0xf                ; sky color
    mov di, playarea_start
    mov cx, playarea_lines*screen_width
    rep stosb


    print_score:
        mov bh, 0x27        ; set initial column
        mov ax, [score_w]   ; get score

    _ps_div:
        xor dx, dx          ; clear dx
        mov cx, 10          ; set divisor to 10
        div cx              ; divide ax by 10
        add dl, 0x30        ; convert number to ascii

        pusha               ; save registers so that interrupts don't interfere
        mov al, dl          ; get char from dl
        mov dl, bh          ; get column from bh

        mov bx, 0x000f      ; bh (page) = 0x00; bl (colour) = 0x0f (used later)

        mov ah, 0x02        ; set cursor
        int 0x10

        mov ah, 0x0e        ; printin chars bby
        int 0x10
        popa                ; recover the registers

        dec bh              ; decrement column

        or ax, ax
        jnz _ps_div
    ; end print_score


    mov dh, enemy_speed         ; setting enemy speed
    ; dh = amount to advance the enemies
    ; handle_draw_enemies loops through all the enemies
    handle_draw_enemies:
        ; setting vars for draw_sprite
        mov dl, 2               ; scaling

        mov cx, max_enemies
        mov di, enemies_start
    _dhe_l:
        xor bx, bx
        mov byte bl, [di]       ; get x coord
        or bl, bl               ; checking if the enemy is outside the screen
        jz _dhe_re              ; if so, try creating a new one

        mov si, [di+2]          ; get sprite address
        xor ax, ax
        mov al, [di+1]          ; y position
        call draw_sprite

        sub byte [di], dh       ; subtract from x position
        jnb _dhe_after_point
        inc word [score_w]
        mov byte [di], 0        ; just so it doesn't overflow on me

        mov ax, [score_w]       ; get score
        mov bl, score_divisor
        div bl                  ; divide score by score_divisor
        or ah, ah
        jnz _dhe_after_point    ; if score%score_divisor != 0

        ; decreasing the timer
        mov bx, e_t_set_b
        cmp byte [bx], enemy_timer_min
        jng _dhe_after_point    ; if e_t_set_b <= enemy_timer_min
        dec byte [bx]
    _dhe_after_point:

        jmp _dhe_i_end          ; jump to the end

    _dhe_re:
        ; random_enemy assumes di is set by handle_draw_enemies
        random_enemy:
            ; checking the timer
            mov bx, enemy_timer_b
            cmp byte [bx], 0
            jg _re_end

            mov al, [e_t_set_b]
            mov byte [bx], al       ; setting the enemy timer

            ; preparing enemy
            mov byte [di], 255      ; set horizontal position
            mov byte [di+1], 139    ; set vertical position

            mov word [di+2], cactus+7   ; setting sprite to cactus

            ; randomizing enemy
            in ax, 0x40             ; get 'random' number

            shr al, 1
            jnc _re_end

            add word [di+2], 8      ; changing sprite from cactus to bomber
            sub byte [di+1], 18     ; changing bomber's vertical position

            shr al, 1
            jc _re_end

            sub byte [di+1], 25     ; once again lifting bomber
        _re_end:
        ; end random_enemy

    _dhe_i_end:
        add di, enemy_size      ; advance by enemy_size
        loop _dhe_l
    ; end handle_draw_enemies


    handle_jump:
        mov si, rows_jump_b
        mov bx, rows_up_b
        cmp byte [bx], 0        ; check if dino is in the air
        jng _hj_no_rows
        sub byte [bx], gravity  ; if so, subtract gravity from it's displacement
        jmp _hj_no_keystroke    ; and don't check for a keystroke

    _hj_no_rows:
        mov ah, 0x02            ; get shift flags
        int 0x16
        test al, 0b11           ; testing for shift keys
        jz _hj_no_keystroke
        mov byte [si], jump
    _hj_no_keystroke:

        mov al, [si]
        cmp al, 0               ; check if jump force is greater than 0
        jng _hj_no_jump
        add byte [bx], al       ; if it is - add it to the displacement
        sub byte [si], gravity  ; subtract gravity from the jump force
    _hj_no_jump:
    ; end handle_jump


    ; draw_dino draws dino accounting for the jump value
    draw_dino:
        mov ax, dino_initial_y
        mov bx, dino_initial_x

        ; check if to subtract the jump value
        xor cx, cx
        mov cl, [rows_up_b]
        cmp cl, 0
        jng _dd_no_jump
        sub ax, cx

    _dd_no_jump:
        ; check for collisions
        push ax
        mov dx, screen_width
        mul dx
        add ax, bx
        mov di, ax
        add di, 5*dino_scaling
        mov byte cl, [es:di]

        ; check for crouch
        mov ah, 0x02
        int 0x16
        xor al, 0b100               ; check for ctrl key
        jnz _dd_no_crouch

        mov dl, 2
        mov byte [rows_up_b], bh    ; bh is 0, thanks to previous mov

        jmp _dd_crouch_end
    _dd_no_crouch:
        mov dl, dino_scaling

        sub di, 7*dino_scaling*screen_width-2*dino_scaling
        and byte cl, [es:di]

    _dd_crouch_end:
        pop ax

        ; draw dino!
        mov si, dino+7
        call draw_sprite

        ; finalize collision check
        or cl, cl
        jz game_over
    ; end draw_dino


    ; scrolls the ground at ground_start
    ; I'm not setting the ds in this subroutine
    ; because it was more space-efficient to load effective address [es:si]
    ; manually rather than setting and clearing ds
    scroll_ground:
        mov si, ground_start+screen_width+1
        mov di, ground_start+screen_width

        mov cx, dirt_rows-1
    _sg_l:
        mov al, [es:si]         ; load byte at si
        stosb                   ; move it to di
        lodsb                   ; advance si
        loop _sg_l

        call random_pixel       ; generate random pixel at the end
    ; end scroll_ground


    ; waits for 1 system clock tick
    frame:
        mov ah, 0
        int 0x1a
    _f_l:
        mov bl, dl
        int 0x1a
        xor bl, dl
        jz _f_l
    ; end frame

    jmp _game_loop



; prints game over string, waits for input, and then resets the game
game_over:
    mov bx, 0x000f          ; page 0, white colour
    mov dx, 0x0c03          ; cursor row and col
    mov ah, 0x02            ; set cursor
    int 0x10

    mov ah, 0x0e            ; print char interrupt
    mov cx, 10              ; 10 chars
    mov si, str_go          ; point to game_over string
    call print_string
; _go_l:
;     lodsb                   ; get char
;     int 0x10                ; print it
;     loop _go_l

    mov ah, 0x00            ; wait for an input
    int 0x16

;;;
;;;    My code
;;;
    mov bx, 0x2000          ; load sector into memory address
    mov es, bx              
    mov bx, 0x0             ; ES:BX = 0x2000:0x0

    ;;; Setup disk read
    mov dh, 0x0             ; head 0
    mov dl, 0x0             ; drive 0
    mov ch, 0x0             ; cylinder 0
    mov cl, 0x03            ; Starting sector to read disk from (Here 3rd sector)

backTo_kernel:
    mov ah, 0x02
    mov al, 0x03            ; Read two sectors
    int 0x13

    jc backTo_kernel

    mov ax, 0x2000      ; 0x1000 is for file table
    mov ds, ax          ; Data segment  
    mov es, ax          ; Extra segment
    mov fs, ax          ; Extra segment
    mov gs, ax          ; Extra segment
    mov ss, ax          ; Stack Segment

    jmp 0x2000:0x0      ; Far jump to sector adress 0x2000:0x0 (Where kernel is loaded into memory ...)

    jmp _start          ; Technicall dead code


random_pixel:
    in al, 0x40
    and al, 0x55
    jz _dd_black
    mov al, 0xf       ; Dirt color
_dd_black:
    stosb
    ret


; ax = y coord, bx = x coord, dl = scaling;
; modify coords and scaling; scaling - 1 for 8x8 pixels;
; mov the address of the sprite's last byte to the si register (addr+7);
draw_sprite:
    pusha
    mov [y_coord_w], ax
    mov [x_coord_w], bx
    mov bl, 8               ; bl will act as the sprite's byte counter
    mov bh, dl              ; bh will act as the row scaling counter

_ds_coords:
    ; prepare starting coords
    push dx
    mov ax, [y_coord_w]     ; get y coord
    mov dx, screen_width    ; size of pixel row
    mul dx                  ; multiply ax by screen_width
    pop dx

    add ax, [x_coord_w]     ; add x coord
    xchg ax, di

    mov cl, 8               ; cl will act as the sprite's pixel counter
_ds_row_pixel:
    mov byte al, [si]       ; load sprite's byte
    shr al, cl
    mov al, 0               ; set colour to black

    push cx
    mov cl, dl              ; horizontal scaling

    jc _ds_draw_pixel       ; perform a jump if carry is set because of shr
    add di, cx              ; advance di
    jmp _ds_trans_done
_ds_draw_pixel:
    rep stosb               ; draw picked colour
_ds_trans_done:
    pop cx

    loop _ds_row_pixel      ; loop for 8 pixels
    ; decrement the pixel counter
    ; jnz _ds_row_pixel       ; jump if not all 8 pixels drawn


    dec word [y_coord_w]    ; increase the y coord

    dec byte bh             ; decrement the row counter
    jnz _ds_coords          ; repeat row

    mov byte bh, dl         ; reset row counter

    dec si                  ; increase sprite address
    dec bl                  ; decrease the byte counter
    jnz _ds_coords

    popa
    ret


; general consts
screen_width    equ 320
screen_height   equ 200

; draw_dino consts
dino_initial_y  equ 139
dino_initial_x  equ 35
dino_scaling    equ 3

; ground consts
ground_start    equ 140*screen_width
dirt_rows       equ 10*screen_width

; clear_playarea consts
playarea_start  equ 26*screen_width
playarea_lines  equ 114

; handle_jump consts
gravity         equ 7
jump            equ 30

; handle_draw_enemies consts
max_enemies     equ 40
enemy_size      equ 1+1+2   ; (byte, byte, word)
enemy_speed     equ 7

; enemy_timer_consts
enemy_timer_max equ 20
enemy_timer_min equ 10

; score will be divided by this value when checking if to increase difficulty
score_divisor   equ 10

; draw_sprite variables
y_coord_w       equ 0xfa00      ; word
x_coord_w       equ 0xfa02      ; word

; score variable
score_w         equ 0xfa06

; handle_jump variables
rows_jump_b     equ 0xfa0a
rows_up_b       equ 0xfa09

; random_enemy variable
enemy_timer_b   equ 0xfa10

; variable that the enemy_timer_b will be set to after overflowing
e_t_set_b       equ 0xfa11

; handle_draw_enemies variable
enemies_start   equ 0xfa20  ; x_pos, y_pos, sprite_addr (byte, byte, word)


; game_over string const
str_go  db  "GAME OVER PRESS ANY KEY TO RETURN", 0

; sprite data
dino    db  0b00000110, \
            0b00001101, \
            0b00001111, \
            0b00011110, \
            0b10111100, \
            0b01111010, \
            0b00010000, \
            0b00011000

cactus  db  0b00011100, \
            0b00100010, \
            0b01110011, \
            0b00100110, \
            0b01101011, \
            0b00100010, \
            0b01100111, \
            0b00110010

bomber  db  0b00000011, \
            0b00000111, \
            0b01101110, \
            0b10111111, \
            0b11111111, \
            0b00001110, \
            0b00000111, \
            0b00000001

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

; sector padding
times 1024-($-$$) db 0
