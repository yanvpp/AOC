.EQU MAX = 31
.EQU MIN = 7

; declaração das variáveis a partir do início da SRAM
.DSEG
.ORG SRAM_START
    contagem  : .BYTE 1
    intervalo : .BYTE 1
.CSEG

.ORG 0x0000 ; Vetor reset
    RMJP setup

.ORG 0x0002 ; Vetor interrupção do botão (int0)

.ORG 0x0020 ; Vetor interrupção do TC/0
    RMJP isr_tc0b

; setup no primeiro endereço fora da zona de vetores
.ORG 0x0034
setup:
    sbi DDRB,  PB5  ; config. como saída
    cbi PORTB, PB5  ; desliga o LED

    cbi DDRD,  PD2  ; config. Ajuste como entrada
    sbi PORTD, PD2  ; ativa pull-up no Ajuste

    ldi R16, 0b0000_0101 ; TC0 com prescaler de 1024, a 16 MHz gera
    out TCCR0B, R16     ; uma interrupção a cada 16,384 ms
    ldi R16, 1
    sts TIMSK0, R16     ; habilita int. do TC0 (TIMSK0(0) = TOIE0 <- 1)

    ldi R16, 2 ; ou 0b000_0010 (0010 é referente à borda de descida)
    sts EICRA, R16  ; config. int0 sensível à borda de descida
    sbi EIMSK, int0 ; habilita a int0

    clr R16           ; R16 = 0
    sts contagem, R16 ; iniciando contagem em 0
    ldi R16, MAX      ; R16 = 31
    sts intervalo     ; intervalo = R16

    sei               ; inicializa interrupções globais

main:
    RJMP main

;-------------------------------------
; Rotina de Interrupção (ISR) da INT0
;-------------------------------------
isr_int0:
    push R16                ; salva o contexto (SREG)
    in R16, SREG
    push R16

    lds R16, intervalo
    cpi MIN                 ; se intervalo for igual a 7 (mínimo)
    breq reset_intervalo    ; reseta o intervalo
    subi R16, 6             ; se não, subtrai 6 e salta para o fim da interrupção
    rjmp fim_int0           ; salta para o fim da interrupção

reset_intervalo:
    ldi R16, MAX            ; volta para o máximo

fim_int0: 
    sts intervalo, R16

    pop R16                 ; restaura contexto
    out SREG, R16
    pop R16

    reti

;-------------------------------------
; Sub-rotina de Interrupção do TC0
;-------------------------------------
isr_tc0b:
    lds R16, contagem
    inc R16

    lds R17, intervalo

    cp R16, R17             ; compara o valor do intervalo com o da contagem
    breq inverte_LED        ; se forem iguais, inverte o LED
    rjmp fim_tc0            ; salta para o fim da contagem

inverte_LED:
    sbi PINB, PB5           ; inverte o estado do LED
    clr R16                 ; R16 = 0

fim_tc0:
    sts contagem, R16

    pop R16                 ; restaura contexto
    out SREG, R16
    pop R16
    pop R17

    reti