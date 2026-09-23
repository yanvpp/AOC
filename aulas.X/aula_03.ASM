.INCLUDE <m328Pdef.inc>

.DSEG ; segmento de memória RAM
.ORG SRAM_START ; 0x0100 para o ATmega328p
    A: .BYTE 4
    B: .BYTE 4
    C: .BYTE 4

.CSEG ; segmento da memória de flash (programa)

START:
    // com endereçamento direto
    // processo byte a byte

    LDS R16, A
    LDS R17, B
    ADD R16, R17 ; primeira soma gera o carry
    STS C, R16

    LDS R16, A+1
    LDS R17, B+1
    ADC R16, R17 ; soma incluindo o carry
    STS C+1, R16

    LDS R16, A+2
    LDS R17, B+2
    ADC R16, R17
    STS C+2, R16

    LDS R16, A+3
    LDS R17, B+3
    ADC R16, R17
    STS C+3, R16

    // com endereçamento indireto (sem incrementar)
    // processo byte a byte

    LDI R27, HIGH(A) ; XH
    LDI R26, LOW(A)  ; XL
    LD R16, X        ; R16 <- A[0]
    LDI R27, HIGH(B) ; XH
    LDI R26, LOW(B)  ; XL
    LD R17, X        ; R17 <- B[0]
    ADD R16, R17     ; R16 <- R16 + R17
    LDI R27, HIGH(C) ; XH
    LDI R26, LOW(C)  ; XL
    ST X, R16        ; C[0] <- R16

    LDI R27, HIGH(A+1) ; XH
    LDI R26, LOW(A+1)  ; XL
    LD R16, X          ; R16 <- A[1]
    LDI R27, HIGH(B+1) ; XH
    LDI R26, LOW(B+1)  ; XL
    LD R17, X          ; R17 <- B[1]
    ADC R16, R17       ; R16 <- R16 + R17
    LDI R27, HIGH(C+1) ; XH
    LDI R26, LOW(C+1)  ; XL
    ST X, R16          ; C[1] <- R16
    
    LDI R27, HIGH(A+2) ; XH
    LDI R26, LOW(A+2)  ; XL
    LD R16, X          ; R16 <- A[2]
    LDI R27, HIGH(B+2) ; XH
    LDI R26, LOW(B+2)  ; XL
    LD R17, X          ; R17 <- B[2]
    ADC R16, R17       ; R16 <- R16 + R17
    LDI R27, HIGH(C+2) ; XH
    LDI R26, LOW(C+2)  ; XL
    ST X, R16          ; C[2] <- R16

    LDI R27, HIGH(A+3) ; XH
    LDI R26, LOW(A+3)  ; XL
    LD R16, X          ; R16 <- A[3]
    LDI R27, HIGH(B+3) ; XH
    LDI R26, LOW(B+3)  ; XL
    LD R17, X          ; R17 <- B[3]
    ADC R16, R17       ; R16 <- R16 + R17
    LDI R27, HIGH(C+3) ; XH
    LDI R26, LOW(C+3)  ; XL
    ST X, R16          ; C[3] <- R16

    // com endereçamento indireto com pós-incremento
    // processo byte a byte

    LDI R27, HIGH(A)
    LDI R26, LOW(A) ; X -> A[0]
    LDI R29, HIGH(B)
    LDI R28, LOW(B) ; Y -> B[0]
    LDI R31, HIGH(C)
    LDI R30, LOW(C) ; Z -> C[0]

    LD R16, X+ ; R16 <- A[0]; depois X++(aponta para R16+1)
    LD R17, Y+ ; R17 <- B[0]; depois X++(aponta para R17+1))
    ADD R16, R17 ; R16 <- R16 + R17
    ST Z+, R16 ; C[0] <- R16

    LD R16, X+ ; R16 <- A[1]; depois X++(aponta para R16+1)
    LD R17, Y+ ; R17 <- B[1]; depois X++(aponta para R17+1))
    ADC R16, R17 ; soma incluindo o carry 
    ST Z+, R16 ; C[1] <- R16
    
    LD R16, X+ ; R16 <- A[2]; depois X++(aponta para R16+1)
    LD R17, Y+ ; R17 <- B[2]; depois X++(aponta para R17+1))
    ADC R16, R17 ; soma incluindo o carry 
    ST Z+, R16 ; C[2] <- R16

    LD R16, X+ ; R16 <- A[3]; depois X++(aponta para R16+1)
    LD R17, Y+ ; R17 <- B[3]; depois X++(aponta para R17+1))
    ADC R16, R17 ; soma incluindo o carry 
    ST Z+, R16 ; C[3] <- R16

    // com endereçamento indireto com deslocamento
    // processo byte a byte

    LDI R29, HIGH(A) ; YH
    LDI R28, LOW(A)  ; YL

    LDD R16, Y+0 ; R16 <- A[0]
    LDD R17, Y+4 ; R17 <- B[0]
    ADD R16, R17 ; R16 <- R16 + R17
    STD Y+8, R16 ; C[0] <- R16

    LDD R16, Y+1 ; R16 <- A[1]
    LDD R17, Y+5 ; R17 <- B[1]
    ADD R16, R17 ; R16 <- R16 + R17
    STD Y+9, R16 ; C[1] <- R16

    LDD R16, Y+2 ; R16 <- A[2]
    LDD R17, Y+6 ; R17 <- B[2]
    ADD R16, R17 ; R16 <- R16 + R17
    STD Y+9, R16 ; C[2] <- R16

    LDD R16, Y+3  ; R16 <- A[3]
    LDD R17, Y+7  ; R17 <- B[3]
    ADD R16, R17  ; R16 <- R16 + R17
    STD Y+11, R16 ; C[3] <- R16

    RJMP START