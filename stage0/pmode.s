[bits 16]
enter_pmode:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1h
    mov cr0, eax
    jmp CODE_SEG:init_32bit

[bits 32]
init_32bit:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 90000h
    mov esp, ebp

    call load_32bit
