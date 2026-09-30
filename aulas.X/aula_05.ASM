; PISCA LED

;DEFINIÇÕES
.equ LED = PB5 	 ; LED é o substituto de PB5
                      
start:                
	sbi DDRB, LED  ;configura pino LED como saída

main:
  sbi PORTB, LED ;coloca 5v no pino LED
	
	ldi R19, 16
  rcall delay    ;chama a sub-rotina de atraso
  
  cbi PORTB, LED ;coloca 0V no pino LED
	
	ldi R19, 16
  rcall delay    ;chama a sub-rotina de atraso
	
  rjmp main      ;volta para main

;--------------------------------------------------------------
;SUB-ROTINA DE ATRASO Programável 
; Depende do valor de R19 carregado antes da chamada.
; Ex.: - R19 = 16 --> 200ms 
;      - R19 = 80 --> 1s
;--------------------------------------------------------------
delay:           
  push r17	      ; Salva os valores de r17,
  push r18	      ; ... r18,
  in r17,SREG     ; ...
  push r17        ; ... e SREG na pilha.

  ; Executa sub-rotina :
  clr r17
  clr r18
loop:            
  dec  R17        ;decrementa R17, começa com 0x00
  brne loop       ;enquanto R17 > 0 fica decrementando R17
  dec  R18        ;decrementa R18, começa com 0x00
  brne loop       ;enquanto R18 > 0 volta decrementar R18
  dec  R19        ;decrementa R19
  brne loop       ;enquanto R19 > 0 vai para volta

  pop r17          
  out SREG, r17   ; Restaura os valores de SREG,
  pop r18         ; ... r18
  pop r17         ; ... r17 da pilha

  ret