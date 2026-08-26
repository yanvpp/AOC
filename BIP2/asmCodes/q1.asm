; Estrutura if-then

; if (A>=B) {
;   A = A + 1 // Bloco 1
; }

.data
    A : 0
    B : 0
.text
    LD A ; ACC <= (A)
    SUB B ; ACC <= ACC - B
    BGE GrEqual ; desvia para o bloco GrEqual
    JMP END

GrEqual:
    LD A
    ADDI 1
    STO A
    JMP END

END:
    HLT