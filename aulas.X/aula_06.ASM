.INCLUDE <m328Pdef.inc>

.DSEG
.ORG SRAM_START
    A: .BYTE 4
    B: .BYTE 4
    C: .BYTE 4

.CSEG
.ORG 0x0000

start:
    ; ---- A = 0x12345678 ----
    LDI XH, HIGH(A)
    LDI XL, LOW(A)
    LDI R16, 0x78     ; LSB
    LDI R17, 0x56
    LDI R18, 0x34
    LDI R19, 0x12     ; MSB
    RCALL init_32bits

    ; ---- B = 0x00000005 ----
    LDI XH, HIGH(B)
    LDI XL, LOW(B)
    LDI R16, 0x05
    LDI R17, 0x00
    LDI R18, 0x00
    LDI R19, 0x00
    RCALL init_32bits

    ; ---- zera C antes de usar (só para teste visual) ----
    LDI XH, HIGH(C)
    LDI XL, LOW(C)
    RCALL zera_32bits

    ; ---- C = A - B  (0x12345678 - 0x00000005 = 0x12345673) ----
    LDI XH, HIGH(A)
    LDI XL, LOW(A)
    LDI YH, HIGH(B)
    LDI YL, LOW(B)
    LDI ZH, HIGH(C)
    LDI ZL, LOW(C)
    RCALL sub_32bits

FIM:
    RJMP FIM

;--------------------------------------------------------------
init_32bits:
    st X+, R16
    st X+, R17
    st X+, R18
    st X+, R19
    ret

;--------------------------------------------------------------
zera_32bits:
    push R16
    push R17
    in   R17, SREG
    push R17

    clr R16
    st X+, R16
    st X+, R16
    st X+, R16
    st X+, R16

    pop R17
    out SREG, R17
    pop R17
    pop R16
    ret

;--------------------------------------------------------------
sub_32bits:
    push R16
    push R17
    push R18
    push R19
    in   R19, SREG
    push R19

    ld  R16, X+
    ld  R17, Y+
    sub R16, R17
    st  Z+, R16

    ldi R18, 3

sub_loop:
    ld  R16, X+
    ld  R17, Y+
    sbc R16, R17
    st  Z+, R16
    dec R18
    brne sub_loop

    pop R19
    out SREG, R19
    pop R19
    pop R18
    pop R17
    pop R16
    ret