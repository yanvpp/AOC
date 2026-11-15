.ORG 0x0000          ; Vetor reset
  rjmp setup


.ORG 0x0020          ; Vetor (endereço na Flash) do estouro do T/C0
  rjmp isr_tc0b


setup:
  sbi DDRB, PB5      ; PB5 como saída
  cbi PORTB, PB5     ; desliga LED


  ldi R16, 0b00000101 ; TC0 com prescaler de 1024, a 16 MHz gera
  out TCCR0B, R16     ; uma interrupção a cada 16,384 ms
  ldi R16, 1
  sts TIMSK0, R16     ; habilita int. do TC0 (TIMSK0(0) = TOIE0 <- 1)


  sei                 ; habilita as interrupções globais


main:
  rjmp main


isr_tc0b:
  inc r16
  cpi r16, 62
  brne fim
  sbi PINB, PB5       ; inverte o estado do LED depois de entrar 62 vezes
                      ; na interrupção: 62 * 16,384 ms = 1.015,81 ms
  ldi r16, 0
fim:
  reti