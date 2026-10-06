.INCLUDE <m328Pdef.inc>

.DSEG
.ORG SRAM_START
    A: .BYTE 4
    B: .BYTE 4
    C: .BYTE 4

.CSEG
.ORG 0x0000

start:
    LDI XH, HIGH(A)
    LDI XL, LOW(A)
    LDI R16, 0x78     ; LSB
    LDI R17, 0x56
    LDI R18, 0x34
    LDI R19, 0x12     ; MSB
    RCALL init_32bits

    LDI XH, HIGH(B)
    LDI XL, LOW(B)
    LDI R16, 0x05
    LDI R17, 0x00
    LDI R18, 0x00
    LDI R19, 0x00
    RCALL init_32bits

    LDI XH, HIGH(C)
    LDI XL, LOW(C)
    RCALL zera_32bits

    LDI XH, HIGH(A)
    LDI XL, LOW(A)
    LDI YH, HIGH(B)
    LDI YL, LOW(B)
    LDI ZH, HIGH(C)
    LDI ZL, LOW(C)
    RCALL sub_32bits

end:
    RJMP end

init_32bits:
    ST X+, R16
    ST X+, R17
    ST X+, R18
    ST X+, R19
    RET

zera_32bits:
    PUSH R16
    PUSH R17
    IN   R17, SREG
    PUSH R17

    CLR R16
    ST X+, R16
    ST X+, R16
    ST X+, R16
    ST X+, R16

    POP R17
    OUT SREG, R17
    POP R17
    POP R16
    RET

sub_32bits:
    PUSH R16
    PUSH R17
    PUSH R18
    PUSH R19
    IN   R19, SREG
    PUSH R19

    LD  R16, X+
    LD  R17, Y+
    SUB R16, R17
    ST  Z+, R16

    LDI R18, 3

sub_loop:
    LD  R16, X+
    LD  R17, Y+
    SBC R16, R17
    ST  Z+, R16
    DEC R18
    BRNE sub_loop

    POP R19
    OUT SREG, R19
    POP R19
    POP R18
    POP R17
    POP R16
    RET