.INCLUDE <m328Pdef.inc>

.EQU BOTAO_AJUSTE  = PB1
.EQU BOTAO_SELECAO = PB0

; Configura pinos IO:
SETUP:
    LDI R16, 0XFF
    OUT DDRD, R16           ; PDO a PD7 = saída (LEDs)
    CBI DDRB, BOTAO_AJUSTE  ; PB1 = entrada
    CBI DDRB, BOTAO_SELECAO ; PB2 = entrada
    ; mantém o pino em 1 quando o botão não está pressionado
    SBI PORTB, BOTAO_AJUSTE 
    SBI PORTB, BOTAO_SELECAO

LOOP:
    CLR R16 ; 0X00 - todos os LEDs acesos (ativo em baixo)

    ; se botão ajuste está pressionado:
    SBIS PINB, BOTAO_AJUSTE ; pula a próxima instrução
    ORI R16, 0X0F           ; apaga os 4 bits menos significativos

    ; se o botão seleção está pressionado:
    SBIS PINB, BOTAO_SELECAO ; pula a próxima instrução
    ORI R16, 0X0F            ; apaga os 4 bits mais significativos

    OUT PORTD, R16           ; atualiza os LEDs
    RJMP LOOP                ; recomeça o loop