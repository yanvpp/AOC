; Parte 2 – Crie as seguintes sub-rotinas:

;     inc_32bits

;         Incremente uma variável de 32 bits apontada por X.

;         Parâmetros:
;             Registrador X: Ponteiro para a posição inicial da variável.

;     dec_32bits

;         Decremente uma variável de 32 bits apontada por X.

;         Parâmetros:
;             Registrador X: Ponteiro para a posição inicial da variável.

;     mov_32bits

;         Copie uma variável de 32 bits apontada por X para outra variável apontada por Y.

;         Parâmetros:
;             Registrador X: Ponteiro para a posição inicial da variável a ser copiada.
;             Registrador Y: Ponteiro para a posição inicial da variável que receberá o valor.

;     OBS.:
;         Para todos os casos, considere o byte menos significativo armazenado no menor endereço.
;         Implemente as sub-rotinas sem chamada de sub-rotinas intermediárias.
;         Implemente testes para cada uma das sub-rotinas.

;===============================================================
; AI2_1 - Parte 2: testes das sub-rotinas de 32 bits
;===============================================================
.INCLUDE <m328Pdef.inc>

.DSEG
.ORG 0x0100

    A: .BYTE 4
    B: .BYTE 4

.CSEG
.ORG 0x0000

main:
    ; TESTE 1: Inicializar a variável A
    LDI XL, LOW(A)
    LDI XH, HIGH(A)
    RCALL init_var
    
    ; TESTE 2: Incrementar a variável A (passando A como parâmetro em X)
    LDI XL, LOW(A)
    LDI XH, HIGH(A)
    RCALL inc_32bits
    
    ; TESTE 3: Decrementar a variável A (passando A como parâmetro em X)
    LDI XL, LOW(A)
    LDI XH, HIGH(A)
    RCALL dec_32bits
    
    ; TESTE 4: Copiar de A para B (passando A em X e B em Y)
    LDI XL, LOW(A)
    LDI XH, HIGH(A)
    LDI YL, LOW(B)
    LDI YH, HIGH(B)
    RCALL mov_32bits
    
    RJMP fim
    

; --------------------------------------
; SUB-ROTINAS 
; --------------------------------------

init_var:
    LDI R16, 1
    ST X+, R16
    ST X+, R16
    ST X+, R16
    ST X+, R16
    RET
    
inc_32bits:
    ; O ponteiro X já vem configurado pelo chamador
    CLR R19         ; Elemento neutro para o Carry
    LDI R18, 1      ; Valor a ser incrementado
    
    LD R16, X
    ADD R16, R18
    ST X+, R16
    
    LD R16, X
    ADC R16, R19
    ST X+, R16
    
    LD R16, X
    ADC R16, R19
    ST X+, R16
    
    LD R16, X
    ADC R16, R19
    ST X+, R16
    RET
    
dec_32bits:
    ; O ponteiro X já vem configurado pelo chamador
    CLR R19         ; Elemento neutro para o Borrow
    LDI R18, 1      ; Valor a ser decrementado
    
    LD R16, X
    SUB R16, R18
    ST X+, R16
    
    LD R16, X
    SBC R16, R19
    ST X+, R16
    
    LD R16, X
    SBC R16, R19
    ST X+, R16
    
    LD R16, X
    SBC R16, R19
    ST X+, R16
    RET
    
mov_32bits:
    ; Os ponteiros X (origem) e Y (destino) já vêm configurados
    LD R16, X+
    ST Y+, R16
    
    LD R16, X+
    ST Y+, R16
    
    LD R16, X+
    ST Y+, R16
    
    LD R16, X+
    ST Y+, R16
    RET
        
fim:
    RJMP fim