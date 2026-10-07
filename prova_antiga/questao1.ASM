; Parte 1 – Manipulação de vetores

; Declare dois vetores com 8 posições de 8 bits (V0, V1) e um vetor com 4 posições (V2).

; Inicialize o V0 com os valores de 8 até 15.

; Copie de trás para frente o V0 para V1.

; Some as posições pares do V0 com as ímpares do V1, colocando o resultado no V2. Exemplo: V2(0) = V0(0) + V1(1), etc.

; Obs.: Utilize as diretivas do montador e os modos de endereçamento adequados.


.INCLUDE <m328Pdef.INC>

.DSEG ; segmento de memória RAM
.ORG SRAM_START ; 0x0100 para o ATmega328p
    V0: .BYTE 8
    V1: .BYTE 8
    V2: .BYTE 4

.CSEG ; segmento da memória de flash (programa)
.ORG 0x0000

START:
    LDI XH, HIGH(V0)
    LDI XL, LOW(V0) ; X -> V0[0]
    LDI YH, HIGH(V1+8)
    LDI YL, LOW(V1+8) ; Y -> V1[7]

    LDI R17, 8 ; contador para o loop
    LDI R16, 8 ; valor inicial para armazenar no vetor

FILL_VECTOR_LOOP:
    ST X+, R16
    ; ST -Y, R16

    INC R16
    DEC R17

    BRNE FILL_VECTOR_LOOP

    LDI XH, HIGH(V0+8)
    LDI XL, LOW(V0+8) ; X -> V0[7]
    LDI YH, HIGH(V1)
    LDI YL, LOW(V1) ; Y -> V1[0]
    LDI ZH, HIGH(V2)
    LDI ZL, LOW(V2) ; Z -> V2[0]

    LDI R17, 8

COPY_VECTOR_LOOP:
    LD R16, -X
    ST Y+, R16

    DEC R17
    
    BRNE COPY_VECTOR_LOOP

    LDI XH, HIGH(V0)
    LDI XL, LOW(V0) ; X -> V0[0]
    LDI YH, HIGH(V1)
    LDI YL, LOW(V1) ; Y -> V1[0]

    LDI R17, 4

SUM_VECTOR_LOOP:
    LD R16, X+
    LD R19, X+
    LD R19, Y+
    LD R18, Y+

    ADD R16, R18
    ST Z+, R16

    DEC R17
    BRNE SUM_VECTOR_LOOP

END:
    RJMP END
