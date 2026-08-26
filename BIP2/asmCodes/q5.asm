; if (a == b)
;   a = a + 1;
; else if (a > b)
;   a = a + 2;
; else if  (a < b)
;   a = a + 3;

.data
    A : 0
    B : 0

.text
    LD A
    SUB B
    BEQ EQUALS
    BGT GREATER
    BLT LESS
    JMP END

EQUALS:
    LD A
    ADDI 1
    STO A
    JMP END

GREATER:
    LD A
    ADDI 2
    STO A
    JMP END

LESS:
    LD A
    ADDI 3
    STO A
    JMP END

END:
    HLT
