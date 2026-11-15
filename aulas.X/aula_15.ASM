;==============================================================
; Pisca LED com T/C1 (16 bits) - interrupção por overflow
; ATmega328p @ 16 MHz, LED em PB5
;
; Cálculo (modo normal, TOP = 0xFFFF = 65535):
;   t_estouro = (TOP + 1) * prescaler / fosc
;             = 65536 * 256 / 16 MHz = 1,048576 s
; Como o contador tem 16 bits, um único estouro já dá ~1 s,
; então a ISR inverte o LED a cada estouro (sem contador
; auxiliar, ao contrário do T/C0 de 8 bits, que exigia 62 estouros).
;==============================================================

.INCLUDE <m328Pdef.inc>

.ORG 0x0000         ; Vetor de reset
    RJMP setup

.ORG 0X001A         ; Vetor do T/C1 Overflow (TIMER1 OVF)
    RJMP isr_tc1

setup:
    SBI DDRB, PB5   ; Declara PB5 como saída
    CBI PORTB, PB5  ; Desliga LED

    LDI R16, 0b00000000 ; TCCR1A = 0 => modo normal (WGM11:WGM10 = 00)
    STS TCCR1A, R16     ; OC1A/OC1B desconectados

    LDI R16, 0b00000100 ; TCCR1B: WGM13:WGM12 = 00 => modo normal
    STS TCCR1A, R16     ; CS12:CS10 = 100 => prescaler 256 (inicia a contagem)

    LDI R16, 0b00000001
    STS TIMSK1, R16     ; TOIE1 = 1: habilita a interrupção por overflow do T/C1

    LDI R16, 0b00000001

    SEI                 ; habilita  as interrupções globais

main:
    RJMP main

;--------------------------------------------------------------
; ISR do T/C1 Overflow: ocorre a cada 1,048576 s
;--------------------------------------------------------------
isr_tc1:
  SBI PINB, PB5      ; inverte o LED
  RETI

