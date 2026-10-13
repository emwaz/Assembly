global _start
%include "util.asm"

section .data
    RunMsg: db "Enter a Number ", 0
    LowMsg: db "Too Low", 0
    HighMsg: db "Too High", 0
    WinMsg: db "You Guessed It Right", 0
section .bss
    UserInput: resb 10
    CompGuessed: resb 10


section .text
    _start:
        call Rand 
        mov [CompGuessed], rax
    Back:
        mov rdi, RunMsg ; "Enter a Number"
        call printstr
        call readint
        mov [UserInput], rax


        cmp rax, [CompGuessed]
        jz RightGuess
        jc TooLow
        jmp TooHigh
    
    RightGuess:
        mov rdi, WinMsg
        call printstr
        call endl
        call exit0
    TooHigh:
        mov rdi, HighMsg
        call printstr
        call endl
        jmp Back
    TooLow:
        mov rdi, LowMsg
        call printstr
        call endl
        jmp Back

Rand:
    retry:
        rdrand rax              ; try to generate random 64-bit value
        jc ok                  ; CF=1 if successful
        jmp retry              ; retry if failed

    ok:
        xor rdx, rdx            ; clear RDX for division
        mov rcx, 100
        div rcx                 ; RAX = quotient, RDX = remainder

        ; remainder is 0–99
        mov rax, rdx
        add rax, 1              ; shift to 1–100
ret


