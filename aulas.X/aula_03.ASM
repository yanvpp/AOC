.DSEG
.ORG SRAM_START
    A: .BYTE 1
    B: .BYTE 1
    C: .BYTE 1

.CSEG

start:
    // com endereçamento direto
    LDS R16, A
    LDS R17, B
    ADD R16, R17
    STS C, R16

    // com endereçamento indireto (sem incrementar)
    LDI R27, HIGH(A) ; XH
    LDI R26, LOW(A)  ; XL
    LD R16, X        ; R16 <- A
    LDI R27, HIGH(B) ; XH
    LDI R26, LOW(B)  ; XL
    LD R17, X        ; R17 <- B
    ADD R16, R17     ; R16 <- R16 + R17
    LDI R27, HIGH(C) ; XH
    LDI R26, LOW(C)  ; XL
    ST X, R16        ; C <- R16

    // com endereçamento indireto com pós-incremento
    LDI R27, HIGH(A)
    LDI R26, LOW(A)
    LD R16, X+ ; R16 <- X++ (B <- A; depois X++(aponta para R16+1))
    LD R17, X+ ; R17 <- X++ (C <- B; depois X++(aponta para R17+1))
    ADD R16, R17
    ST X, R16 ; C <- R16

    // com endereçamento indireto com deslocamento
    LDI R29, HIGH(A) ; YH
    LDI R28, LOW(B)  ; YL
    LDD R16, Y+0 ; R16 <- A
    LDD R17, Y+1 ; R17 <- B
    ADD R16, R17
    STD Y+2, R16 ; C <- R16

    RJMP start