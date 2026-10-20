.INCLUDE <m328Pdef.inc>

.DSEG
.ORG SRAM_START
    Count: .BYTE 1

.CSEG
.ORG 0x0000

START:
    ; Inicializando o SP no fim da RAM
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16
    LDI R16, LOW(RAMEND)
    OUT SPL, R16

    ; Garante que o LED inicie apagado
    CBI GPIOR0, 7

LOOP:
    ; Leitura do botão no bit 3
    SBIC GPIOR0, 3 ; pula a próxima instrução caso não esteja pressionado
    RJMP PRESSED ; pula para PRESSED se estiver pressionado

; botão não pressionado:
NOT_PRESSED:
    ; neste caso, o LED é apagado
    CBI GPIOR0, 7
    RJMP LOOP

; botão pressionado:
PRESSED:
    SBI GPIOR0, 7 ; liga o LED
    RCALL DELAY   ; mantém ligado durante o delay

    CBI GPIOR0, 7 ; desliga o LED
    RCALL DELAY   ; matém desligado durante o delay

    RJMP LOOP     ; retorna para verificar se o botão ainda está pressionado    

DELAY:
    ; Salva o contexto atual na pilha
    PUSH R16
    PUSH R17
    PUSH R18
    IN R16, SREG
    PUSH R16

    ; Inicializa o contador na SRAM
    LDI R16, 106 ; ~15,96 milhões de ciclos = ~0,998 s a 16 MHz
    STS Count, R16

LOOP_ATRASO_EXT:
    LDI R17, 200

LOOP_ATRASO_MID:
    LDI R18, 250

LOOP_ATRASO_INT:
    DEC R18
    BRNE LOOP_ATRASO_INT

    DEC R17
    BRNE LOOP_ATRASO_MID

    LDS R16, Count
    DEC R16
    STS Count, R16
    BRNE LOOP_ATRASO_EXT

    ; Restaura o contexto original
    POP R16
    OUT SREG, R16
    POP R18
    POP R17
    POP R16

    RET