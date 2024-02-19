; Mochila binária e fracionária
; arquivo: mochile.asm
; objetivo: Gerenciar arquivos
; nasm -f elf64 mochile.asm ; ld mochile.o -o mochile.x

%define _exit       60
%define _write      1
%define _open       2
%define _read       0
%define _seek       8
%define _close      3
%define _fstat      4
%define readOnly    0o    		; flag open()
%define writeOnly   1o    			; flag open()
%define readwrite   2o    			; flag open()
%define openrw      102o  		; flag open()
%define userWR      644o  		; Read+Write+Execute
%define allWRE      666o
%define _newLine    10
%define _return     13


section .data
    
	argErrorS : db "Erro: Quantidade de Parâmetros incorreta", 10, 0
	argErrorSL: equ $-argErrorS 

    arqErrorS : db "Erro: Arquivo não foi aberto", 10, 0
    arqErrorSL: equ $-arqErrorS
	
	argErrorC : db "Erro: Comando incorreto", 10, 0
    argErrorCL: equ $-argErrorC
	
	argErrorCAT: db "Erro: não é possível fazer CAT neste tipo", 10, 0
    argErrorCATL: equ $-argErrorCAT
	
	argErrorDIR: db "Erro: não é possível abrir diretório", 10, 0
    argErrorDIRL: equ $-argErrorDIR

    erroAberturaSistema     : db "Erro: não foi possível abrir o dispositivo", 10, 0
    erroAberturaSistemaL    : equ $-erroAberturaSistema
    
	avisoParaEspera         : db 10, 10, "Pressione [Enter] para continuar", 10, 0
    avisoParaEsperaL        : equ $-avisoParaEspera
	
    strOla  : db "Testi", 10, 0
    strOlaL : equ $-strOla
	
	
	limpaTerminal       : db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
	limpaTerminalL      : equ  $-limpaTerminal         ; tamanho da string para limpar terminal
	
	caracterPonto : db 0x2e, 0

	tabChar	: db 0x09, 0
	
	trintaDois	: dq 32
	
	; moldura para print
	
	
	inicioLinha		: db "|", 0x20, 0
	inicioLinhaL	: equ $-inicioLinha
	
	finalLinha		: db 0x0a, 0
	finalLinhaL		: equ $-finalLinha
	
	espacoDivisor	: db 0x20, "|", 0x20, 0
	espacoDivisorL	: equ $-espacoDivisor

    espacamento     : db 0x20, 0x20, 0x20, 0x20, 0x20, 0
    espacamentoL    : equ $-espacamento
	
	beep			: db 0x07, 0


section .bss
    
    fracionaryOrBinary  : resq 1
    stackPointer        : resq 1
    firstNumberPointer  : resq 1
    secondNumberPointer : resq 1
    dataPointer         : resq 1
    readBuffer          : resq 32
    bagSize             : resq 1
    itemCount           : resq 1
    trashBuffer         : resq 1
    weightPointer       : resq 1
    gainPointer         : resq 1
    advantagePointer    : resq 1
    tempAdvantage       : resq 1
    tempWeight          : resq 1
    tempGain            : resq 1
    bagGain             : resq 1

section .text

    global _start

_start:
	
    mov rdi, [rsp]
    xor rsi, rsi
    inc rsi
    inc rsi
    inc rsi
    cmp rdi, rsi
    jne endProgram

    mov rsi, [rsp+24]
    mov dil, [rsi]
    cmp dil, 102
    jne notFracionary
    inc QWORD[fracionaryOrBinary]
    notFracionary:

    mov rax, _open
    mov rdi, [rsp+16]
    mov rsi, readwrite
    mov rdx, userWR
    syscall

    
    teste:

    mov [dataPointer], rax

    xor r8, r8
    readSize:
        mov rax, _read
        mov rdi, [dataPointer]
        lea rsi, [readBuffer+r8]
        xor rdx, rdx
        inc rdx
        syscall
       
        xor rax, rax
        mov al, BYTE[readBuffer+r8]
        cmp al, 10
        je readSizeReaded
        inc r8
        jmp readSize
        readSizeReaded:

    %include "pushall.asm"
    lea rdi, [readBuffer]
    call char2Long
    mov [bagSize], rax
    %include "popall.asm"
    
    sub rsp, 8
    mov [firstNumberPointer], rsp
    xor r8, r8
    xor r9, r9
    xor r10, r10
    firstNumbers:
        mov rax, _read
        mov rdi, [dataPointer]
        lea rsi, [readBuffer+r8]
        xor rdx, rdx
        inc rdx
        syscall
       
        xor rax, rax
        mov al, BYTE[readBuffer+r8]
        cmp al, 10
        je endFirstNumber
        cmp al, 48
        jl newFirstNumber
        cmp al, 57
        jg newFirstNumber
        inc r8
        jmp firstNumbers
        
        newFirstNumber:
            checkFirstNumber:
            mov rax, _read
            mov rdi, [dataPointer]
            lea rsi, [trashBuffer]
            xor rdx, rdx
            inc rdx
            syscall

            xor rax, rax
            mov al, [trashBuffer]
            cmp al, 10
            je endFirstNumber
            cmp al, 48
            jge preResetFirst
            

            preResetFirst: 
                cmp al, 57
                jle resetFirst
                jmp checkFirstNumber

                resetFirst:
                    mov rax, _seek
                    mov rdi, [dataPointer]
                    xor rsi, rsi
                    dec rsi
                    xor rdx, rdx
                    inc rdx
                    syscall
                

            ;sub rsp, 8
            ;mov [stackPointer], rsp
            ;inc r10
            ;xor r8, r8
            
            ;mov [rsp], r8

            %include "pushall.asm"
            lea rdi, [readBuffer]
            call char2Long
            ;mov r8, [stackPointer]
            ;mov [r8], rax
            mov [stackPointer], rax
            %include "popall.asm"
            
            mov r8, [firstNumberPointer]
            mov r15, [stackPointer]
            neg r10
            mov [r8 + r10 * 8], r15
            neg r10
            sub rsp, 8
            inc r10
            xor r8, r8
            jmp firstNumbers

    endFirstNumber:

    mov [itemCount], r10

    sub rsp, 8
    mov [secondNumberPointer], rsp
    xor r8, r8
    xor r9, r9
    xor r10, r10
    secondNumbers:
        mov rax, _read
        mov rdi, [dataPointer]
        lea rsi, [readBuffer+r8]
        xor rdx, rdx
        inc rdx
        syscall
       
        xor rax, rax
        mov al, BYTE[readBuffer+r8]
        cmp al, 10
        je endSecondNumber
        cmp al, 48
        jl newSecondNumber
        cmp al, 57
        jg newSecondNumber
        inc r8
        jmp secondNumbers
        
        newSecondNumber:
            checkSecondNumber:
            mov rax, _read
            mov rdi, [dataPointer]
            lea rsi, [trashBuffer]
            xor rdx, rdx
            inc rdx
            syscall

            xor rax, rax
            mov al, [trashBuffer]
            cmp al, 10
            je endSecondNumber
            cmp al, 48
            jge preResetSecond
            

            preResetSecond: 
                cmp al, 57
                jle resetSecond
                jmp checkFirstNumber

                resetSecond:
                    mov rax, _seek
                    mov rdi, [dataPointer]
                    xor rsi, rsi
                    dec rsi
                    xor rdx, rdx
                    inc rdx
                    syscall
                

            ;sub rsp, 8
            ;mov [stackPointer], rsp
            ;inc r10
            ;xor r8, r8
            
            ;mov [rsp], r8

            %include "pushall.asm"
            lea rdi, [readBuffer]
            call char2Long
            ;mov r8, [stackPointer]
            ;mov [r8], rax
            mov [stackPointer], rax
            %include "popall.asm"
            
            mov r8, [secondNumberPointer]
            mov r15, [stackPointer]
            neg r10
            mov [r8 + r10 * 8], r15
            neg r10
            sub rsp, 8
            inc r10
            cmp r10, [itemCount]
            je endSecondNumber
            xor r8, r8
            jmp secondNumbers

    endSecondNumber:
   
    bagInit:
    xor rbx, rbx
    mov rbx, 8
    imul rbx, [itemCount]
    
    sub rsp, rbx
    mov [gainPointer], rsp
    sub rsp, rbx
    mov [weightPointer], rsp
    sub rsp, rbx
    mov [advantagePointer], rsp

    xor r8, r8
    xor r9, r9
    xor r15, r15
    mov r10, [firstNumberPointer]       ; Considerando primeira linha como ganho
    mov r11, [secondNumberPointer]      ; Considerando segunda linha como peso
    mov rbx, [weightPointer]
    mov rcx, [gainPointer]
    mov rdx, [advantagePointer]
    itemOrganize:
        neg r8 
        cvtsi2sd xmm0, [r10 + r8 * 8]
        cvtsi2sd xmm1, [r11 + r8 * 8]
        neg r8

        xor rdi, rdi
        mov [rbx + r8 * 8], rdi
        mov [rcx + r8 * 8], rdi
        mov [rdx + r8 * 8], rdi
       
        divsd xmm0, xmm1

        xor r15, r15
        dec r15
        insertionSort:
            inc r15
            movsd xmm3, [rdx + r15 * 8]
            comisd xmm0, xmm3
            jb insertionSort
            je insertionSort
            
            mov rsi, [rbx + r15 * 8]
            mov [tempWeight], rsi
            mov rsi, [rcx + r15 * 8]
            mov [tempGain], rsi
            mov rsi, [rdx + r15 * 8]
            mov [tempAdvantage], rsi

            neg r8
            mov rsi, [r11 + r8 * 8]
            mov [rbx + r15 * 8], rsi
            mov rsi, [r10 + r8 * 8]
            neg r8
            mov [rcx + r15 * 8], rsi
            movsd [rdx + r15 * 8], xmm0
             
            cmp r8, r15
            je pushStackEnd

            inc r15
            pushStack:
                mov rsi, [tempWeight]
                mov r12, [rbx + r15 * 8]
                mov [rbx + r15 * 8], rsi
                mov [tempWeight], r12
    
                mov rsi, [tempGain]
                mov r12, [rcx + r15 * 8]
                mov [rcx + r15 * 8], rsi
                mov [tempGain], r12

                mov rsi, [tempAdvantage]
                mov r12, [rdx + r15 * 8]
                mov [rdx + r15 * 8], rsi
                mov [tempAdvantage], r12

                inc r15
                cmp r8, r15
                jge pushStack
                
            pushStackEnd: 



        inc r8
        cmp r8, [itemCount]
        je endOrganize
        jmp itemOrganize
    
    endOrganize:
        
        xor r8, r8
        mov r9, [itemCount]
        dec r9
        dec r8
        mov rsi, [bagSize]
        putInBag:
            inc r8
            sub rsi, [rbx + r8 * 8]
            cmp rsi, 0
            je fullbag
            jl overflowBag
            cmp r8, r9
            je fullbag
            jmp putInBag

        overflowBag:
            dec r8
        fullbag:
            
            xor r9, r9
            xor rax, rax
            gainSum:
                add rax, [rcx + r9 * 8]
                inc r9
                cmp r8, r9
                jge gainSum


endProgram:
	mov rax, _exit
	mov rdi, 0
	syscall

char2Long:   ; long char2Int(char *number[rdi])
    push rbp
    mov rbp, rsp

    xor r8, r8
    xor r9, r9
    countLoop:
        mov r9b, [rdi+r8]

        cmp r9b, 57
        jg countEnd
        cmp r9b, 48
        jl countEnd
        inc r8
        jmp countLoop

        countEnd:
    
    mov rcx, r8
    xor r8, r8
    inc r8
    xor r10, r10
    converterLoop:
        xor rax, rax
        mov al, [rdi+rcx-1]
        sub rax, 48
        imul rax, r8
        imul r8, 10
        dec rcx
        add r10, rax
        jecxz convertEnd
        jmp converterLoop
    
        convertEnd:


    mov rax, r10 
    


    mov rsp, rbp
    pop rbp
    ret




