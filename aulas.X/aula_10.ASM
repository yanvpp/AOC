.INCLUDE <m328Pdef.inc>

; Simular um circuito com dois botões, ON (PD2) e OFF (PD3), e dois LEDs, L0 (PB0) e o L1 (PB1).

; Utilizando interrupção externa, implementar um sistema com o seguinte comportamento:

; - Piscar o L0 a cada 2s;
; - Quando o botão ON for pressionado, o L1 deve ligar;
; - Quando o botão OFF for pressionado, o L1 deve desligar.


;DEFINIÇÕES
.EQU BOTAO_ON  = PD2
.EQU BOTAO_OFF = PD3
.EQU L0 = PB0        
.EQU L1 = PB1
.DEF AUX = R16 
  
.ORG 0x0000        ; Reset vector
  RJMP SETUP       

.ORG 0x0002	   ; Vetor (endereço na Flash) da INT0
  RJMP isr_int0     

.ORG 0x0004    ; Vetor da INT1
  RJMP isr_int1

.ORG 0x0034        ; primeira end. livre depois dos vetores

SETUP:
  ldi AUX,0x03     ; 0b00000011   
  out DDRB,AUX     ; configura PB1/0 como saída
  out PORTB,AUX    ; desliga os LEDs
  cbi DDRD, BOTAO_ON   ; configura o PD2 como entrada
  cbi DDRD, BOTAO_OFF  ; configura o PD3 como entrada
  sbi PORTD, BOTAO_ON  ; liga o pull-up do PD2
  sbi PORTD, BOTAO_OFF ; liga o pull-up do PD3

  ldi AUX, 0x0A
  sts EICRA, AUX   ; configura INT0 e INT1 sensível a borda de descida
  sbi EIMSK, INT0  ; habilita a INT0
  sbi EIMSK, INT1  ; habilita a INT1
                    
  sei              ; habilita a interrupção global (bit I do SREG)
main:
  cbi PORTB, L0    ; liga L0
  ldi R19, 160 
  rcall delay      ; delay 2s
  sbi PORTB, L0    ; desliga L0
  ldi R19, 160 
  rcall delay      ; delay 2s
  rjmp main

;-------------------------------------------------
; ISR da INT0 (Botão ON): Liga L1
;-------------------------------------------------
isr_int0:
  push AUX	    ; Salva o contexto (SREG)
  in AUX, SREG
  push AUX
  
  cbi PORTB, L1 ; liga L1

  pop AUX       ; restaura o contexto
  out SREG, AUX
  pop AUX

  reti

;-------------------------------------------------
; ISR da INT1 (Botão OFF): Desliga L1
;-------------------------------------------------
isr_int1:
  push AUX      ; Salva o contexto (SREG)
  in AUX, SREG
  push AUX

  sbi PORTB, L1 ; desliga L1

  pop AUX       ; restaura o contexto
  out SREG, AUX
  pop AUX
  reti

;------------------------------------------------------------
;SUB-ROTINA DE ATRASO Programável
;Depende do valor de R19 carregado antes da chamada.
;Exemplos: 
; - R19 = 16  --> 200ms 
; - R19 = 80  --> 1s 
; - R19 = 160 --> 2s
;------------------------------------------------------------
delay:           
  push R17	     ; Salva os valores de R17,
  push r18	     ; ... r18,
  in R17,SREG    ; ...
  push R17       ; ... e SREG na pilha.

  ; Executa sub-rotina :
  clr R17
  clr r18

loop:            
  dec  R17       ; decrementa R17, começa com 0x00
  brne loop      ; enquanto R17 > 0 fica decrementando R17
  dec  R18       ; decrementa R18, começa com 0x00
  brne loop      ; enquanto R18 > 0 volta decrementar R18
  dec  R19       ; decrementa R19
  brne loop      ; enquanto R19 > 0 vai para volta

  pop R17         
  out SREG, R17  ; Restaura os valores de SREG,
  pop r18        ; ... r18
  pop R17        ; ... R17 da pilha

  ret
