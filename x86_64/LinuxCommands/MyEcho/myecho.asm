global _start
default rel

section .data
    newline_flag: db "-n", 0
    escape_flag: db "-e", 0    
    space_char: db " "          ; NEW
    newline_char: db 10         ; NEW
section .text 
_start:


    mov rdi, [rsp] ; Argc 
    lea rsi , [rsp + 16] ; ArgV
    dec rdi
    call main 
    jmp Done


;==========Strcmp()==========
strcmp:
    .loop:
        movzx eax, byte [rdi]   ; load byte from s1
        movzx edx, byte [rsi]   ; load byte from s2
        cmp eax, edx
        jne .not_equal          ; different bytes -> -1

        test eax, eax
        je .equal               ; both are '\0' -> 0

        inc rdi
        inc rsi
        jmp .loop

    .not_equal:
        mov eax, -1
        ret

    .equal:
        xor eax, eax
        ret


;==========Strlen()==========  NEW
strlen:
    xor rax, rax
    .strlen_loop:
        cmp byte [rdi + rax], 0
        je .strlen_done
        inc rax
        jmp .strlen_loop
    .strlen_done:
        ret


; ===============CheckFlag()==========
CheckFlag_Func:
    push rbp
    mov rbp, rsp
    sub rsp, 64                 ; FIX: was 40 (alignment + room for r12/r14)

    ; FIX: save callee-saved registers we clobber
    mov [rbp - 40], r12
    mov [rbp - 48], r14

    ; Save Parameters in Stack Frame
    mov [rbp - 8], rdi ; Saving ArgC
    mov [rbp - 16], rsi ; Saving AgV

    mov [rbp - 24], rdx ; saving newline_flag variable
    mov [rbp - 32], rcx ; saving escape_flag variable

    ;Setting some Registers.
    mov r8 , 0x0
    mov r9 , r8
    mov r14 , [rbp - 8] ; r14 <= ArgC
    mov r12 , [rbp - 16] ; r12 <= base pointer.

    CheckArgc_Loop:
        cmp r9, r14 ; if argc ==? 0  
        je Exit_CheckFlag_Func ; if? no string provided to print. => exit 
        
        ; else , may be flag provided:: but which is it :?
            mov rdi, [r12 + r9*8]
            mov rsi, newline_flag 
            call strcmp ; Check
                cmp rax, 0 ;if [+] '-n' ?
                je set_newLine_Flag ; if true

            ;else [x] may be '-e'?
            mov rdi, [r12 + r9 * 8]
            mov rsi, escape_flag 
            call strcmp ; Check 
                cmp rax, 0 
                je set_escape_Flag ; in true 
        jmp Exit_CheckFlag_Func


        set_newLine_Flag:
            mov r10, [rbp - 24] ; r10 <= Neline Flag variable
            mov [r10], 1
            inc r9 ; Increment Counter
            jmp CheckArgc_Loop

        set_escape_Flag:
            mov r10, [rbp - 32] ; r10 <= Escape Flag variable
            mov [r10], 1
            inc r9 ; Increment Counter
            jmp CheckArgc_Loop           

    Exit_CheckFlag_Func:
        mov rax, r9 ; savibg where the index stop to not to print the flags.
        mov r12, [rbp - 40]     ; FIX: restore callee-saved
        mov r14, [rbp - 48]     ; FIX: restore callee-saved
        leave
        ret
;==============Main Function============== 
main:
    push rbp
    mov rbp, rsp
    sub rsp, 0x40

    ; Store the Argument which were passed down.
    mov [rbp - 8], rdi ; ArgC 
    mov [rbp - 16], rsi ; ArgV 

    ; FIX: initialize flag slots to 0
    mov qword [rbp - 24], 0
    mov qword [rbp - 32], 0

    ; Set Argument for the "Check_Flag" Function 
    mov rdi, [rbp - 8] ; Sending ArgC 
    mov rsi, [rbp - 16] ; Sending ArgV

    lea rdx, [rbp - 24] ; Newline_flag Address  
    lea rcx, [rbp - 32] ; Escape_Flag Address

    Call CheckFlag_Func
    mov [rbp - 40], rax     ; FIX: save start index returned by CheckFlag_Func

    ; ============ Print Loop ============  NEW
    mov r9, [rbp - 40]      ; current argument index

    Print_Loop:
        cmp r9, [rbp - 8]   ; reached argc?
        jge After_Print_Loop

        mov r10, [rbp - 16]         ; argv base
        mov r10, [r10 + r9*8]       ; pointer to current arg string

        mov rdi, r10
        call strlen                 ; rax = length
        mov rdx, rax                ; count
        mov rsi, r10                ; buffer
        mov rdi, 1                  ; stdout
        mov rax, 1                  ; sys_write
        syscall

        inc r9
        cmp r9, [rbp - 8]           ; last arg?
        jge After_Print_Loop

        lea rsi, [space_char]       ; write " "
        mov rdx, 1
        mov rdi, 1
        mov rax, 1
        syscall
        jmp Print_Loop

    After_Print_Loop:
        cmp qword [rbp - 24], 0     ; newline_flag set?
        je Done

        lea rsi, [newline_char]     ; write "\n"
        mov rdx, 1
        mov rdi, 1
        mov rax, 1
        syscall

Done:
    mov rax, 60
    xor rdi, rdi 
    syscall