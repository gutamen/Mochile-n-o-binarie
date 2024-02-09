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
	
	typeDir		: db "DIR", 0x20, 0
	typeArch	: db "ARCH", 0
	typeSize	: db 4
	
	typeFinish		: db 0x20, "|", 0x09, 0
	typeFinishL		: equ $-typeFinish
	
	dirSizeChar	: db "-------", 0x09, 0x09, "|", 10, 0
	dirSizeCharL	: equ $-dirSizeChar
	
	archFinish		: db 0x09, "|", 10, 0
	archFinishL		: equ $-archFinish

    testeArquivo    : db "./teste.txt", 0
    testeArquivoL   : equ $-testeArquivo 
	
	testeChars		: db "test.txt",0

	beep			: db 0x07, 0


section .bss
    
    dataPointer : resq 1
    readBuffer : resq 32
    bagSize  : resq 1

section .text

    global _start

_start:
	
    mov rax, _open
    mov rdi, [rsp+16]
    mov rsi, readwrite
    mov rdx, userWR
    syscall

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
    

    xor r8, r8
    xor r9, r9
    xor r10, r10
    mov r15, 32
    firstNumbers:


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
        ola:
        jecxz convertEnd
        jmp converterLoop
    
        convertEnd:


   mov rax, r10 
    


    mov rsp, rbp
    pop rbp
    ret
