.INCLUDE <m328Pdef.INC>

.DSEG ; segmento de memória RAM
.ORG SRAM_START ; 0x0100 para o ATmega328p
    A1: .BYTE 10 ; .BYTE == vetor com 8 bits (1 byte) em cada posição (10 posições)
    A2: .BYTE 10
    A3: .BYTE 10

    A4: .BYTE 3 ; 1 byte em cada uma das 3 posições

.CSEG ; segmento da memória de flash (programa)
.ORG 0x0000

START:
    LDI XH, HIGH(A1)
    LDI XL, LOW(A1) ; X -> A1[0]
    LDI YH, HIGH(A2)
    LDI YL, LOW(A2) ; Y -> A2[0]

    LDI R17, 10 ; contador para o loop
    LDI R16, 1  ; valor inicial para armazenar

FILL_VECTOR_LOOP:
    // adicionar os valores de 1 a 10 nos vetores A1 e A2
    ST X+, R16 ; A1[X] <- R16, depois X++
    ST Y+, R16 ; A2[X] <- R16, depois X++

    INC R16 ; R16++
    DEC R17 ; R17--

    BRNE FILL_VECTOR_LOOP ; repete o loop ("Branch if Not Equal") se != 0

    LDI XH, HIGH(A1)
    LDI XL, LOW(A1) ; X -> A1[0]
    LDI YH, HIGH(A2 + 10)
    LDI YL, LOW(A2 + 10)
    LDI ZH, HIGH(A3)
    LDI ZL, LOW(A3) ; Z -> A3[0]

    LDI R17, 10
    
SUM_VECTOR_LOOP:
    // soma o primeiro valor de A1 com o último de A2 e armazena em A3
    LD R16, X+ ; R16 <- A1[X]
    LD R18, -Y ; R16 <- A2[--Y]
    ADD R16, R18 ; R16 <- R16 + R18
    ST Z+, R16

    DEC R17 ; decrementa o loop
    BRNE SUM_VECTOR_LOOP


    // soma A2(1) e A3(3), A2(3) e A3(4), A2(5) e A3(7) e salva consecutivamente no A4
    LDI XH, HIGH(A4)
    LDI XL, LOW(A4) ; X -> A1[0]
    LDI YH, HIGH(A2)
    LDI YL, LOW(A2) ; Y -> A2[0]
    LDI ZH, HIGH(A3)
    LDI ZL, LOW(A3) ; Z -> A3[0]

    LDD R16, Y+1 ; R16 <- A2[1]
    LDD R17, Z+3 ; R17 <- A3[3]
    ADD R16, R17 ; R16 <- R16 + R17
    ST X+, R16   ; A4[X] <- R16, depois X++

    LDD R16, Y+3 ; R16 <- A2[3]
    LDD R17, Z+4 ; R17 <- A3[4]
    ADD R16, R17 ; R16 <- R16 + R17
    ST X+, R16   ; A4[X] <- R16, depois X++

    LDD R16, Y+5 ; R16 <- A2[5]
    LDD R17, Z+7 ; R17 <- A3[7]
    ADD R16, R17 ; R16 <- R16 + R17
    ST X+, R16   ; A4[X] <- R16, depois X++
    
END:
    RJMP END