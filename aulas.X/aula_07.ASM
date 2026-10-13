.INCLUDE <m328Pdef.inc>        ; nomes dos registradores (DDRB, PIND, GPIOR0...)

.ORG 0x0000
    rjmp start                 ; vetor de reset

.ORG 0x0034                    ; depois da tabela de vetores
start:

; ---------------------------------------------------------------------
; 1) in / out  (slide 11)
; Observar: R0 incrementa, GPIOR0 recebe o valor, R1 le de volta.
; ---------------------------------------------------------------------
    inc  R0                    ; Incrementa R0
    out  GPIOR0, R0            ; Escreve no GPIOR0 (0x1E) o R0
    in   R1, GPIOR0            ; Le do GPIOR0 (0x1E) para o R1
                               ; Esperado: R1 = R0

; ---------------------------------------------------------------------
; 2) sbi / cbi  (slide 12)
; Observar: bit 5 do DDRB (0x04) vai a 1 e depois a 0.
; ---------------------------------------------------------------------
    sbi  DDRB, 5               ; Seta o bit 5 do DDRB (0x04)
    cbi  DDRB, 5               ; Reseta o bit 5 do DDRB (0x04)

; ---------------------------------------------------------------------
; 3) EXTRA: mesmo registrador por dois enderecos (slide 9)
; Endereco SRAM = endereco de I/O + 0x20  ->  DDRB: 0x04 (I/O) = 0x24 (SRAM)
; Observar: escrita via sts em 0x24 aparece no DDRB lida com in.
; ---------------------------------------------------------------------
    ldi  R16, 0x20
    sts  0x0024, R16           ; Escreve no DDRB pelo endereco SRAM
    in   R17, DDRB             ; Le pelo endereco de I/O
                               ; Esperado: R17 = 0x20
    lds  R18, 0x0024           ; Le de novo pelo endereco SRAM
                               ; Esperado: R18 = 0x20
    clr  R16
    out  DDRB, R16             ; Devolve o DDRB a zero

; ---------------------------------------------------------------------
; 4) sbis / sbic  (slide 13)
; No simulador, altere o bit 7 do PIND na janela de I/O View
; para o programa sair de cada espera.
; ---------------------------------------------------------------------
waitUM:
    sbis PIND, 7               ; Salta a proxima instrucao se o bit 7 do PIND e UM
    rjmp waitUM                ; Bit 7 do PIND nao setado: aguarda
waitZERO:
    sbic PIND, 7               ; Salta a proxima instrucao se o mesmo bit e ZERO
    rjmp waitZERO              ; Senao, aguarda
    nop                        ; Continua o programa

    rjmp start