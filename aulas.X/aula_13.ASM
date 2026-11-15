.INLCUDE <m328pdef.inc>

; Definições
.EQU LED = PB5
.EQU BOTAO_AJUSTE = PD2
.EQU INTERVALO_INICIAL = 30 ; 30 x 16,384 ms = 491,5 ms (meio período de ~1 s)
.EQU PASSO = 6              ; 6 x 16,384 ms = 98,3 ms (~100 ms por meio período)

; Variáveis na SRAM
.DSEG
.ORG 0X0100
  contagem:  .BYTE 1
  intervalo: .BYTE 1

; Vetores
.CSEG
.ORG 0x0000          ; Vetor reset
  RJMP setup

.ORG 0X0002          ; Vetor da INT0
  RJMP isr_int0 

.ORG 0x0020          ; Vetor (endereço na Flash) do estouro do T/C0
  rjmp isr_tc0b

.ORG 0X0034          ; Primeiro endereço livre depois dos vetores

setup:
  SBI DDRB, LED           ; PB5 como saída
  SBI PORTB, LED          ; desliga LED

  CBI DDRD, BOTAO_AJUSTE  ; PD2 como entrada
  SBI PORTD, BOTAO_AJUSTE ; pull-up do botão de ajuste

  CLR R16                 ; inicializa as variáveis

  STS contagem, R16
  LDI R16, INTERVALO_INICIAL
  STS intervalo, R16

  ldi R16, 0b00000101 ; TC0 com prescaler de 1024, a 16 MHz gera
  out TCCR0B, R16     ; uma interrupção a cada 16,384 ms
  ldi R16, 1
  sts TIMSK0, R16     ; habilita int. do TC0 (TIMSK0(0) = TOIE0 <- 1)

  LDI R16, 0b00000010 ; borda de descida

  STS EICRA, R16
  SBI EIMSK, INT0     ; habilita a INT0

  sei                 ; habilita as interrupções globais

main:
  rjmp main           ; todo o processo é realizado nas interrupções

isr_tc0b:
  PUSH R16            ; salva o contexto
  IN R16, SREG
  PUSH R16
  PUSH R17

  LDS R16, contagem
  INC R16            ; contagem++
  LDS R17, intervalo
  CP R16, R17
  BRLO salva         ; BRLO == Branch if Lower
                     ; contagem < intervalo: só guarda a contagem
  SBI PINB, LED      ; inverte o LED
  CLR R16            ; contagem = 0

salva:
  STS contagem, R16

  POP R17            ; restaura o contexto
  POP R16
  OUT SREG, R16
  POP R16
  RETI

;-----------------------------------------------------
; ISR da INT0 (botão pressionado)
; intervalo -= PASSO; se chegar a 0, volta ao inicial
;-----------------------------------------------------
isr_int0:
  PUSH R16                    ; salva o contexto
  IN R16, SREG
  PUSH R16

  LDS R16, intervalo
  SUBI R16, PASSO             ; intervalo -= PASSO
  BRNE grava                  ; se for diferente, grava
  LDI R16, INTERVALO_INICIAL  ; se for igual, volta ao primeiro estágio

grava:
  STS intervalo, R16

  POP R16                     ; restaura o contexto
  OUT SREG, R16
  POP R16
  RETI