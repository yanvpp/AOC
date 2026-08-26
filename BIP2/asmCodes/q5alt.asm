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
    BGT GREATER
    BLT LOWER

EQUALS:
    LDI 1
    JMP END

GREATER:
    LDI 2
    JMP END

LOWER:
    LDI 3

END:
    ADD A
    STO A
    HLT
