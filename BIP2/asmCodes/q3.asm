; Estrutura while

; i = 0;
; while (i<10) {
;     A += 2;     // Bloco 1
;     i++; 
; }

.data
    I : 0
    A : 0

.text
LDI 0
STO I
JMP END

LOOP:
    SUBI 10
    BGE END

    LD A
    ADDI 2
    STO A

    LD I
    ADDI 1
    STO I

    SUBI 10
    BLT LOOP

END:
    HLT