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
%define _cat	  	0x20544143
%define _ls		0x0000534C
%define _cd		0x00204443
%define _quit	0x54495551
%define _cout	0x54554F43
%define _cint	0x544E4943
%define _mkdr	0x52444B4D
%define _cede	0x45444543
%define _dele	0x454C4544


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
	
	jumpLine : db 10, 0 
	
	limpaTerminal       : db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
	limpaTerminalL      : equ  $-limpaTerminal         ; tamanho da string para limpar terminal
	
	caracterPonto : db 0x2e, 0

	tabChar	: db 0x09, 0
	
	trintaDois	: dq 32
	
	; moldura para print
	
	primeiraLinha	: db "|", 0x20, "Número", 0x20, "|", 0x20, "Nome", 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, "|", " Extensão ", "|", 0x20, "Tamanho",  10, 0
	primeiraLinhaL	: equ $-primeiraLinha
	
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


    testesaida      : db "/home/gustavo/Documentos/jamanta.txt", 0
	beep			: db 0x07, 0

    finalBlocos     : dq 0xffffffffffffffff, 0

section .bss
    

    tamanhoBloco                        : resq 1 
    ponteiroRaiz                        : resq 1
    ponteiroBlocosLimpos                : resq 1
    tamanhoArmazenamento                : resq 1
    quantidadeBlocos                    : resb 6

	ponteiroDiretorioAtualNoDispositivo	: resq 1
    ponteiroDiretorioAtual  		    : resq 1
    tamanhoDiretorioAtual   		    : resq 1

    ponteiroDispositivo                 : resq 1
    argv                                : resq 1
    argc                                : resq 1
    buffer                              : resq 1  
    ponteiroDispositivoNoSistema        : resq 1
    ponteiroPilhaAntigo                 : resq 1

	bufferCaracteres                    : resb 512
    bufferTeclado                       : resb 512

section .text

    global _start

_start:
	
	mov rax, _write
	mov rdi, 1
	lea rsi, [beep]
	mov rdx, 1
	syscall


	mov rax, _exit
	mov rdi, 0
	syscall
