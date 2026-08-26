; Estrutura if-then-else

; if (A>B) {
;   A = A+1; // Bloco 1
; } else {
;   B = B+1; // Bloco 2
; }

.data
    A : 0
    B : 0
.text
    LD A
    SUB B
    BGT GREATER
    BLE LEQUAL
    JMP END

GREATER :
    LD A
    ADDI 1
    STO A
    JMP END

LEQUAL:
    LD B
    ADDI 1
    STO B

END:
    HLT