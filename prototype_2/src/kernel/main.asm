org 0x0
bits 16

start:
    ; print message
    mov si, msg_hello
    call puts

.halt:
    cli
    hlt

;
; prints a string to the screen
;   --> ds:si points to string
;
puts:
    ; save registers that will be modified
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; if (next char == NULL)
    jz .done

    mov ah, 0x0E        ; BIOS tty mode
    mov bh, 0           ; page number = 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret

msg_hello: db "kernel loaded successfully!!", 0x0D, 0x0A, 0