.INCLUDE <m328Pdef.inc>

; Questão 1: GPIO

;     Inicialize os GPIOs adequadamente.

;     Cada vez que o botão INC/DEC for pressionado, incremente uma vez o valor mostrado na porta B e decremente uma vez o valor na porta C.
;     Os intervalos são de 0 até 15 para o incremento e de 15 até 0 para o decremento.

;     Se o botão RST for pressionado, a contagem na porta B deve ser zerada e a porta C deve receber o valor 15.

.DEF count_b = R17
.DEF count_c = R18

.DEF aux = R16

.EQU botao_reset  = PD2
.EQU botao_incdec = PD3


; Escreve o complemento do valor nos 4 bits baixos da porta (LED liga com 0)
.MACRO atualiza_portB
    MOV aux, count_b
    COM aux
    ANDI aux, 0x0F
    OUT PORTB, aux
.ENDMACRO

; Escreve o complemento do valor nos 4 bits baixos da porta (LED liga com 0)
.MACRO atualiza_portC
    MOV aux, count_c
    COM aux
    ANDI aux, 0x0F
    OUT PORTC, aux
.ENDMACRO

.ORG 0x0000        ; Reset vector
  RJMP setup

.ORG 0x0034        ; primeira end. livre depois dos vetores

setup:
  LDI aux, 0x0F            ; 0b00001111   
  OUT DDRB, aux            ; configura PB0-3 como saída
  OUT DDRC, aux            ; configura PC0-3 como saída
  CBI DDRD, botao_incdec   ; configura o PD2 como entrada
  CBI DDRD, botao_reset    ; configura o PD3 como entrada
  SBI PORTD, botao_reset   ; liga o pull-up do PD2
  SBI PORTD, botao_incdec  ; liga o pull-up do PD3

; valores iniciais/ funcionamento do botão de reset
reset:
  CLR count_b     ; count_b = 0
  atualiza_portB  ; portB mostra 0  - XXXXXXXX
  LDI count_c, 15 ; count_c = 15
  atualiza_portC  ; portC mostra 15 - OOOOOOOO

main:
  SBIS PIND, botao_reset  ; salta a próxima instrução se botão reset está solto (1)
  RJMP reset              ; botão reset pressionado, executa a subrotina

  SBIC PIND, botao_incdec ; salta a próxima instrução se inc/dec pressionado (0)
  RJMP main               ; inc/dec solto, verifica os botões novamente

  ; se inc/dec pressionado, atualiza portas
  ; portB
  CPI count_b, 15
  BREQ zera_b ; se count_B = 15, volta para o 0
  INC count_B ; se não, incrementa count_b
  RJMP fim_b

zera_b:
  CLR count_b     ; count_b = 0

fim_b:
  atualiza_portB  ; portB mostra 0  - XXXXXXXX

  ; portC
  TST count_c
  BREQ zera_c ; se count_c = 0, volta para o 15
  DEC count_c ; se não, decrementa count_c
  RJMP fim_c

zera_c:
  LDI count_c, 15 ; count_c = 15

fim_c:
  atualiza_portC  ; portC mostra 15 - OOOOOOOO

; aguarda até o usuário soltar o botão para não incremetar 
; .... e decrementar diversas vezes
still_holding:
  SBIS PIND, botao_incdec ; salta a próxima instrução se inc/dec pressionado (0)
  RJMP still_holding ; se ainda estiver pressionado, verifica novamente
  RJMP main ; quando soltar, volta para a main
