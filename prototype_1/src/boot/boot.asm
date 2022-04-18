[ORG 0x7c00]
[BITS 16]

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; BPB = BIOS Parameter Block
BPB_required_short_jmp:
    jmp short step1
    nop
; reserve 33 bytes for BPB 
;    so in case BIOS overwrites this area, our code doesn't get corrupted
times 33 db 0

step1:
    jmp 0:main

main:
    ; this is meant to garantee that our data segment origin is at 0x7c00
    ;     this operation can't be interfered by hardware/software, so we clear the 
    ;     interrupt flag during this process and enable it right after
    cli
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32
    jmp $

; GDT
gdt_start:
    gdt_null:
        dd 0x0
        dd 0x0

    ; offset 0x8
    gdt_code: ; CS should point to this
        dw 0xffff    ; segment limit (first 0-15 bits)
        dw 0         ; base: first 0-15 bits
        db 0         ; base 16-23 bits
        db 0x9a      ; access bytes (bitmasks)
        db 11001111b ; high 4 bit flags and low 4 bit flags
        db 0         ; base 24-31 bits

    ; offset 0x10
    gdt_data: ; DS, SS, ES, FS, GS
        dw 0xffff    ; segment limit (first 0-15 bits)
        dw 0         ; base: first 0-15 bits
        db 0         ; base 16-23 bits
        db 0x92      ; access bytes (bitmasks)
        db 11001111b ; high 4 bit flags and low 4 bit flags
        db 0         ; base 24-31 bits

gdt_end:
    gdt_descriptor: 
        dw gdt_end - gdt_start - 1
        dd gdt_start

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax    ; backup LBA
    ; send the highest 8 bits of the LBA to hard disk controller
    shr eax, 24
    or eax, 0xE0    ; select the master drive
    mov dx, 0x1F6
    out dx, al

    ; send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    ; send more bits of the LBA
    mov eax, ebx    ; restore the backup LBA
    mov dx, 0x1F3
    out dx, al

    ; send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx    ; sestore the backup LBA
    shr eax, 8
    out dx, al

    ; send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx    ; sestore the backup LBA
    shr eax, 16
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; read all sectors into memory
    .next_sector:
        push ecx

    ; checking if we need to read
    .try_again:
        mov dx, 0x1f7
        in al, dx
        test al, 8
        jz .try_again

    ; read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ret

times 510- ($-$$) db 0
dw 0xAA55