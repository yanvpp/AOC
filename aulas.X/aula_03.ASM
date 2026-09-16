.DEF A = R0, B = R1, C = R2

start:
    // com endereçamento direto
    LDS A, 0x0001
    LDS B, 0x0010
    LDS C, 0x0011
    LDI R16, A
    SUBI R16, -B

    MOV C, R16

    // com endereçamento indireto (sem incrementar)
        


    // com endereçamento indireto com pós-incremento


    // com endereçamento indireto com deslocamento
    


    RJMP start