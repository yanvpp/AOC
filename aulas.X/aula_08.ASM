.INCLUDE <m328Pdef.inc>

.EQU LED   = 7              ; bit do GPIOR0
.EQU BOTAO = 3              ; bit do GPIOR0

; Atraso: cada passada do laço interno gasta ~197.375 ciclos.
; Com clock de 16 MHz: 16.000.000 / 197.375 ~ 81 passadas = ~1 s.
.EQU DELAY = 81

.DSEG
.ORG SRAM_START
    COUNT .BYTE 1 ; contador

.CSEG
.ORG 0x0000

START:
    CLR R16 ; limpa o registrador R16
    OUT GPIOR0, R16

    STS COUNT, R16 ; inicializa o contador

LOOP:
    SBIS GPIOR0, BOTAO ; se botão = 1 (pressionado), salta
    RJMP NOT_PRESSED

; botão pressionado:
PRESSED:
    SBI GPIOR0, LED ; liga o LED
    

NOT_PRESSED:
    CBI GPIOR0, LED1 ; desliga LED
    RJMP LOOP ; volta para o loop

END:
    RJMP START ; volta para o começo