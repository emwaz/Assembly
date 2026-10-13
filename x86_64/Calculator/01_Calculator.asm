;basic feature. add, subtract, multiplication, division
global _start
default rel
%include "util.asm"

section .data
    num1: db "Enter Number 1: ", 0
    num2: db "Enter Number 2: ", 0

    Operator: db "Choose An Operation {+, -, *, /}--> ", 0
    Operator_Err: db "Operator Doesn't Match! :(", 0

    AddMsg: db "The Addition Is: ", 0
    SubMsg: db "The Subtraction Is: ", 0
    MultiMsg: db "The Multiplication Is: ", 0
    DivMsg: db "The Division Is: ", 0

    ZeroErr: db "Devide By Zero Error :(", 0
section .bss
    UserNum1: resb 8
    UserNum2: resb 8
    
    User_Operator: resb 2
    
    Result: resb 8

section .text
_start:
    mov rdi, num1
    call printstr
    call readint
    mov [UserNum1], rax ; Take 1st Number

    mov rdi, num2
    call printstr
    call readint
    mov [UserNum2], rax ; Take 2nd Number
    
    mov rdi, Operator
    call printstr
    mov rdi, User_Operator
    mov rsi, 2
    call readstr ; Take Operaor to Perform Operation.

    ;Operator Handling
    
    ; '+' Case
    mov rdi, [User_Operator]
    cmp rdi, 43 ; 43 -> Ascii of '+'
    je Addition_Label
        cmp rdi, 45 ; 54 -> Ascii of '-'
        je Subtraction_Label
            cmp rdi, 42 ; 42 Ascii of '*'
            je Multiplication_Label
                cmp rdi, 47 ; 47 Ascii of '/'
                je Division_Lebel

    mov rdi, Operator_Err
    call printstr
    call endl
    call exit0

Addition_Label:
    mov rdi, AddMsg
    call printstr

    mov rdi, [UserNum1]
    add rdi, [UserNum2]
    call Result_Print

Subtraction_Label:
    mov rdi, SubMsg
    call printstr

    mov rdi, [UserNum1]
    sub rdi, [UserNum2]
    call Result_Print

Multiplication_Label:
    mov rdi, MultiMsg
    call printstr

    mov rdi, [UserNum1]
    imul rdi, [UserNum2]
    call Result_Print

Division_Lebel:
    mov rdx, 0
    mov rax, [UserNum1]
    mov rbx, [UserNum2]
    
    cmp rbx, 0
    je ZeroError
    
    mov rdi, DivMsg
    call printstr
    
    idiv rbx
    mov rdi, rax
    call Result_Print

ZeroError:
    mov rdi, ZeroErr
    call printstr
    call endl
    call exit0

Result_Print:
    call printint
    call endl
    call exit0