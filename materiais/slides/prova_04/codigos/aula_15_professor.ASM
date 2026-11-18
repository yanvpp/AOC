.ORG 0x0000             ; Vetor de reset
    RJMP setup

.ORG 0x001A             ; Vetor do T/C1
    RJMP isr_tc1

setup:
    sbi DDRB, PB5
    cbi PORTB, PB5      ; desliga LED

    ; TC1 com prescaler de 256
    ldi R16, 0b0000_0100
    sts TCCR1B, R16

    ; Habilitar interrupção do modo CTC com o OCR0A
    ldi R16, 1
    sts TIMSK1, R16     ; habilita int. do TC1 (TIMSK1(0) = TOIE1 <- 1)

    clr R16             ; zera o registrador R16

    sei                 ; habilita as interrupções globais

main:
    rjmp main

;------------------------
; Rotina interrupção TC1
;------------------------
isr_tc1:
    sbi PINB, PB5       ; inverte o estado do led a cada interrupção

fim:
    reti