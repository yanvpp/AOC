.ORG 0x0000             ; Vetor de reset
    RJMP setup

.ORG 0x001C             ; Vetor do T/C0
    RJMP isr_tc0_ctc

setup:
    sbi DDRB, PB5
    cbi PORTB, PB5      ; desliga LED

    ; Configura o modo CTC do TC0 (WGM02:1=2)
    ldi R16, 2
    out TCCR0A

    ; TC0 com prescaler de 1024
    ; ldi R16, 0b0000_0101
    ; out TCCR0B, R16
    in R16, TCCR0A
    ori R16, 2
    out TCCR0A, R16

    ; TOP do CTC
    ; t_estouro = (TOP+1) * 1024 / 16M
    ; TOP = 124 => t_estouro = 8ms, ou seja, 1s/8ms = 124 interrupções
    ldi R16, 124
    out OCR0A, R16

    ; Habilitar interrupção do modo CTC com o OCR0A
    ldi R16, 2
    sts TIMSK0, R16     ; habilita int. do TC0 (TIMSK0(1) = OCIE0A <- 1)

    clr R16             ; zera o registrador R16

    sei                 ; habilita as interrupções globais

main:
    rjmp main

;------------------------
; Rotina interrupção TC0
;------------------------
isr_tc1:
    inc R16
    cpi R16, 125
    brne fim   
    sbi PINB, PB5       ; inverte o estado do led a cada interrupção

    clr R16             ; zera o registrador R16
fim:
    reti