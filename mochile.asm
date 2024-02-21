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
    lastItemsPointer    : resq 1

section .text

    global _start

_start:
	
    mov rdi, [rsp]
    xor rsi, rsi
    inc rsi
    inc rsi
    inc rsi
    cmp rdi, rsi                    ; Teste para verificar a quantidade de argumentos
    jne endProgram

    mov rsi, [rsp+24]               ; Pegando o argumento de tipo de Mochila
    mov dil, [rsi]
    cmp dil, 70                     ; F
    jne notFracionary
    inc QWORD[fracionaryOrBinary]   ; Marcação de mochila fracionária
    cmp dil, 70
    je modeDefined

    notFracionary:
    
    cmp dil, 66                     ; B
    jne modeError                   ; Caso nenhum dos modos seja utilizado é considerado erro

    

    
    modeDefined:
    mov rax, _open
    mov rdi, [rsp+16]
    mov rsi, readwrite
    mov rdx, userWR
    syscall                         ; Abre o arquivo para leitura

    mov [dataPointer], rax          ; Armazena o ponteiro *FILE
    xor r8, r8
    readSize:                       ; Laço para leitura do tamanho da mochila
        mov rax, _read
        mov rdi, [dataPointer]
        lea rsi, [readBuffer+r8]
        xor rdx, rdx
        inc rdx
        syscall
       
        xor rax, rax
        mov al, BYTE[readBuffer+r8]
        cmp al, 10                  ; Parada quando econtrar caractere de nova linha
        je readSizeReaded
        inc r8
        jmp readSize
        readSizeReaded:

    %include "pushall.asm"
    lea rdi, [readBuffer]
    call char2Long                  ; Converte os caracteres para long
    mov [bagSize], rax
    %include "popall.asm"
    
    sub rsp, 8
    mov [firstNumberPointer], rsp   ; Armazena o ponteiro para primeira linha de números 
    xor r8, r8
    xor r9, r9
    xor r10, r10
    firstNumbers:                   ; Leitura da primeira linha de números
        mov rax, _read
        mov rdi, [dataPointer]
        lea rsi, [readBuffer+r8]
        xor rdx, rdx
        inc rdx
        syscall
       
        xor rax, rax
        mov al, BYTE[readBuffer+r8]
        cmp al, 10                  ; Parada em caso de nova linha
        je endFirstNumber   
        cmp al, 48                  ; Verifica se é um caractere número para considerar parada para próximo número
        jl newFirstNumber
        cmp al, 57
        jg newFirstNumber
        inc r8
        jmp firstNumbers            ; Continua lendo o número
        
        newFirstNumber:
            checkFirstNumber:
                mov rax, _read
                mov rdi, [dataPointer]
                lea rsi, [trashBuffer]
                xor rdx, rdx
                inc rdx
                syscall             ; Lê o próximo caractere do arquivo

                xor rax, rax
                mov al, [trashBuffer]
                cmp al, 10          ; Verifica se é a próxima linha
                je insertFirst
                cmp al, 48          ; Verifica se é um caractere número
                jge preResetFirst
                jl checkFirstNumber      

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
                    syscall         ; Retorna em um o ponteiro no arquivo
            

            insertFirst:
            %include "pushall.asm"
            lea rdi, [readBuffer]
            call char2Long          ; Converte um número lido
            mov [stackPointer], rax
            %include "popall.asm"
            
            mov r8, [firstNumberPointer]
            mov r15, [stackPointer] 
            neg r10
            mov [r8 + r10 * 8], r15 ; Armazena o número convertido na pilha
            neg r10
            sub rsp, 8              ; Abre espaço para mais um número
            inc r10
            xor r8, r8
            cmp BYTE[trashBuffer], 10
            jne firstNumbers

    endFirstNumber:

    mov [itemCount], r10            ; Armazena a quantidade de itens disponíveis

    sub rsp, 8                      
    mov [secondNumberPointer], rsp  ; Guarda o ponteiro para próxima linha de itens
    xor r8, r8
    xor r9, r9
    xor r10, r10
    secondNumbers:                  ; Exatamente igual à primeira linha só altera onde guarda os números
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
            je insertSecond
            cmp al, 48
            jge preResetSecond
            jl checkSecondNumber

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
                
            insertSecond:
            %include "pushall.asm"
            lea rdi, [readBuffer]
            call char2Long
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
            cmp BYTE[trashBuffer], 10
            jne secondNumbers

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
    itemOrganize:                       ; Organiza os itens em ordem que prioriza o peso/beníficio
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
        insertionSort:                      ; Faz um insertionSort nas pilhas reservadas conforme itens com valores melhores aparecem
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
            pushStack:                  ; Quando o item é colocado no meio da pilha é avançado todos os próximos
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
        xor r10, r10
        mov r9, [itemCount]
        dec r9
        dec r8
        mov rsi, [bagSize]
        putInBag:                   ; Coloca os itens na mochila até o espaço acabar
            inc r8
            sub rsi, [rbx + r8 * 8] ; Subtraindo os peso dos itens
            cmp rsi, r10
            je zeroBag
            jl overflowBag
            cmp r8, r9
            je zeroBag
            jmp putInBag

        overflowBag:
            add rsi, [rbx + r8 * 8] ; Caso ocorra da capacidade da mochila estourar remove o item
            dec r8
            cmp BYTE[fracionaryOrBinary], 0
            jne zeroBag             ; Comparação entre mochila binária e fracionária
            xor r13, r13
            mov rdi, r8 
            inc rdi
    
            sub rsp, 8
            mov [lastItemsPointer], rsp ; Guarda na pilha um ponteiro para armazenar os itens que serão incluídos
            mov r14, rsp
            mov [r14], r10
            xor r11, r11
            filingBag:
                sub rsi, [rbx + rdi * 8]; Teste dos próximos itens
                xor r10, r10
                mov [r14 + r11 * 8], rdi        
                cmp rsi, r10
                je zeroBag              ; Enquanto houver espaço os testes continuam ou acabar os itens para teste
                jg nextItem
                jl overflowItem
                
                overflowItem:
                    add rsi, [rbx + rdi * 8]
                    inc rdi
                    mov [r14 + r11 * 8], r10    ; item inserido continua grande para mochila, pula para o próximo ou para em caso de fim da lista de itens
                    cmp rdi, r9
                    je zeroBag
                    jmp filingBag

                nextItem:
                    inc rdi
                    inc r11
                    sub rsp, 8
                    cmp rdi, r9
                    jne filingBag
                

            zeroBag:
                cmp BYTE[fracionaryOrBinary], 0
                jne fracionayItemEvalue
                fracionaryItemAdd:
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

modeError:

    jmp endProgram

fracionayItemEvalue:

    jmp fracionayItemEvalue

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




