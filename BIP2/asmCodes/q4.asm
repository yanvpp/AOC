; Estrutura do-while

; i = 0; 
; do {
;   A += 2    // Bloco 1
;   i++;
; } while (i<10) // Bloco 2

.data
    I : 0
    A : 0

.text
    LID 0
    STO I

LOOP:
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