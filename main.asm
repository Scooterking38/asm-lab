section .data
    msg db "Hello from Arch Linux raw ASM!", 10    ; 10 is the newline character (\n)
    len equ $ - msg                                ; Computes the length of the string

section .text
    global _start                                  ; The linker looks for this entry point

_start:
    ; Write string to stdout
    mov rax, 1          ; Linux sys_write syscall number
    mov rdi, 1          ; File descriptor 1 (stdout)
    mov rsi, msg        ; Pointer to our message string
    mov rdx, len        ; Number of bytes to write
    syscall             ; Trigger the Linux kernel interrupt

    ; Exit program cleanly
    mov rax, 60         ; Linux sys_exit syscall number
    xor rdi, rdi        ; Status code 0 (success)
    syscall             ; Trigger the Linux kernel interrupt
