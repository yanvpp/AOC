.INCLUDE <m328Pdef.inc>

; Questão 2: Interrupção

;     Converta o código acima para que os botões INC/DEC e RST funcionem como interrupções externas.

;     A porta B deve ser incrementada no momento em que o botão INC/DEC for pressionado e a porta C decrementada quando o botão for liberado. Os intervalos de incremento é de 0 até 15 e de decremento é de 15 até 0.

;     Mantenha duas variáveis na memória count_b e count_c para armazenar o estado das portas.

.DEF aux = R16

.EQU botao_reset  = PD2
.EQU botao_incdec = PD3

.DSEG
  count_b: .BYTE 1 ; valor mostrado na porta b
  count_c: .BYTE 1 ; valor mostrado na porta c

.CSEG
; Escreve o complemento do valor nos 4 bits baixos da porta (LED liga com 0)
.MACRO atualiza_portB
    LDS aux, count_b
    COM aux
    ANDI aux, 0x0F
    OUT PORTB, AUX
.ENDMACRO

; Escreve o complemento do valor nos 4 bits baixos da porta (LED liga com 0)
.MACRO atualiza_portC
    LDS aux, count_c
    COM aux
    ANDI aux, 0x0F
    OUT PORTC, aux
.ENDMACRO

.ORG 0x0000     ; Reset vector
  RJMP SETUP       

.ORG 0x0002	    ; Vetor (endereço na Flash) da INT0 (RST)
  RJMP isr_int0     

.ORG 0x0004     ; Vetor da INT1 (INC/DEC)
  RJMP isr_int1

.ORG 0x0034     ; primeira end. livre depois dos vetores

setup:
  LDI aux, 0x0F            ; 0b00001111   
  OUT DDRB, aux            ; configura PB0-3 como saída
  OUT DDRC, aux            ; configura PC0-3 como saída
  CBI DDRD, botao_incdec   ; configura o PD3 como entrada
  CBI DDRD, botao_reset    ; configura o PD2 como entrada
  SBI PORTD, botao_reset   ; liga o pull-up do PD2
  SBI PORTD, botao_incdec  ; liga o pull-up do PD3

  RCALL valores_iniciais
  ; ================================================================
  ; EICRA: sensibilidade das interrupções (2 bits por interrupção)

  ;   ISCx1 ISCx0 = 00 nível baixo | 01 qualquer mudança
  ;                 10 descida     | 11 subida
  
  ; INT0 (RST):     descida (10)           -> dispara ao pressionar
  ; INT1 (INC/DEC): qualquer mudança (01)  -> pressionar e soltar
  ; EICRA = 0b0000_0110 = 0x06
  ; ================================================================

  LDI aux, 0x06
  STS EICRA, aux
  SBI EIMSK, INT0   ; habilita a INT0
  SBI EIMSK, INT1   ; habilita a INT1

  SEI              ; habilita a interrupção global

; aguarda a interrupção
wait:
  RJMP wait

; valores iniciais
valores_iniciais:
  CLR aux          ; aux = 0
  STS count_b, aux ; count_b = 0
  atualiza_portB   ; portB mostra 0  - XXXXXXXX
  LDI aux, 15      ; aux = 15
  STS count_c, aux ; count_c = 15
  atualiza_portC   ; portC mostra 15 - OOOOOOOO
  RET

; funcionamento do botão de reset
reset:
  CLR aux          ; aux = 0
  STS count_b, aux ; count_b = 0
  atualiza_portB   ; portB mostra 0  - XXXXXXXX
  LDI aux, 15      ; aux = 15
  STS count_c, aux ; count_c = 15
  atualiza_portC   ; portC mostra 15 - OOOOOOOO
  RET

incdec_pressionado:
  ; se inc/dec pressionado, incrementa b
  LDS aux, count_b
  CPI aux, 15
  BREQ zera_b ; se count_B = 15, volta para o 0
  INC aux     ; se não, incrementa count_b
  RJMP fim_b

zera_b:
  CLR aux     ; count_b = 0

fim_b:
  STS count_b, aux ; carrega novo valor de count_b
  atualiza_portB   ; portB mostra 0  - XXXXXXXX
  RET

incdec_solto:
  ; portC
  LDS aux, count_c
  TST aux     ; TST = Test for Zero or Minus
  BREQ zera_c ; se count_c = 0, volta para o 15
  DEC aux     ; se não, decrementa count_c
  RJMP fim_c

zera_c:
  LDI aux, 15 ; count_c = 15

fim_c:
  STS count_c, aux ; carrega novo valor de count_c
  atualiza_portC   ; portC mostra 15 - OOOOOOOO
  RET

;-------------------------------------------------
; ISR da INT0 (Botão Reset): 
;-------------------------------------------------
isr_int0:
  push aux	    ; Salva o contexto (SREG)
  IN aux, SREG
  PUSH aux
  
  RCALL reset

  pop aux       ; restaura o contexto
  out SREG, aux
  pop aux

  RETI

;-------------------------------------------------
; ISR da INT1 (Botão INC/DEC):
;-------------------------------------------------
isr_int1:
  push aux      ; Salva o contexto (SREG)
  in aux, SREG
  push aux

  SBIC PIND, botao_incdec ; salta a próxima instrução se inc/dec pressionado (0)
  RJMP botao_solto
  RCALL incdec_pressionado
  RJMP fim_int1

botao_solto:
  RCALL incdec_solto

fim_int1:
  pop aux       ; restaura o contexto
  out SREG, aux
  pop aux
  reti