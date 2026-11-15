;==============================================================
; Pisca LED com intervalo de 1 s exato - T/C0 em modo CTC
; ATmega328p @ 16 MHz, LED em PB5
;
; Cálculo (prescaler 1024):
;   t_comparação = (OCR0A + 1) * prescaler / fosc
;                = 125 x 1024 / 16 MHz = 8 ms     (OCR0A = 124)
;   1 s / 8 ms   = 125 interrupções
;   => 125 * 8 ms = 1 s exato (o exemplo com overflow
;      dava 62 x 16,384 ms = 1,0158 s)
;==============================================================

.INCLUDE <m328Pdef.inc>

.ORG 0x0000         ; Vetor de reset
    RJMP setup

.ORG 0x001C         ; Vetor do T/C0 Compare Match A (TIMER0 COMPA)
    RJMP isr_tc0a

setup:
    SBI DDRB, PB5   ; Declara PB5 como saída
    CBI PORTB, PB5  ; Desliga LED

    LDI R16, 124    ; TOP = 124 (conta de 0 a 124, 125 contagens)
    OUT OCR0A, R16 

    LDI R16, 0b00000010 ; WGM01 = 1 e WGM00 = 0 (WGM02 = 0 no TCCR0B) -> modo CTC
    OUT TCCR0A, R16

    LDI R16, 0b00000101 ; prescaler 1024
    OUT TCCR0B, R16     ; (escrever o prescaler dá início à contagem)

    LDI R16, 0b00000010
    STS TIMSK0, R16     ; habilita a interrupção por comparação A

    CLR R16             ; contador de interrupções começa em 0

    SEI                 ; habilita as interrupções globais

main:
    RJMP main

isr_tc0a:
    INC R16
    CPI R16, 125
    BRNE fim
    SBI PINB, PB5       ; inverte o LED a cada 1 segundo exato (125*8ms)

    CLR R16

fim:
    RETI