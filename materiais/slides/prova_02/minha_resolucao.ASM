; – Crie as seguintes sub-rotinas:

;     init_array

;         Inicializa um vetor de bytes de tamanho arbitrário com valores sequenciais.

;         Parâmetros:

;             Registrador X : Ponteiro para a posição inicial do vetor.

;             R20 : Tamanho do vetor. Intervalo [1, 255].

;             R21 : Valor inicial. Intervalo [0, 255]

;     reverse_array

;         Copia os dados de um vetor para outro de forma reversa.

;         Parâmetros:

;             Registrador X : Ponteiro para a posição inicial do vetor origem.

;             Registrador Y : Ponteiro para a última posição mais um do vetor destino.

;             R20 : Tamanho dos vetores. Intervalo [1, 255].

;     search_array

;         Retorna o index da primeira ocorrência de um determinado valor. A primeira posição do array é considerada index=1

;         Parâmetros:

;             Registrador X : Ponteiro para a posição inicial do vetor origem.

;             R20 : Tamanho do vetor. Intervalo [1, 255].

;             R21 : Valor a ser procurado. Intervalo [0, 255].

;             R22 : Index da primeira ocorrência do valor passado no R21. Deve ser 0 se não encontrar.

;     Observações:

;         Salve o contexto adequadamente.

;         Utilize laços de repetição e os modos de endereçamento adequados para cada caso.

; Parte 2 – Faça um código teste

;  OK   Declare dois vetores com 12 posições de 8 bits (VA e VR).

;  OK   Inicialize o VA com os valores de 31 a 42.

;     Procure o valor 31 no VA.

;     Procure o valor 5 no VA.

;     Copie o vetor VA para o VR de forma reversa, utilizando a rotina criada.

;     Procure o valor 31 no VR.

;.EQU R20 = 12 ; DECLARANDO R20 COMO 12

.DSEG ; segmento de memória RAM
.ORG SRAM_START ; 0x0100 para o ATmega328p
    VA: .BYTE 12 ; .BYTE == vetor com 8 bits (1 byte) em cada posição (12 posições)
    VR: .BYTE 12 ; vetor com 12 posições de 8 bits cada

.CSEG ; segmento da memória de flash (programa)
.ORG 0x0000

START:
       ; aponta o ponteiro para a posição inicial do vetor
       LDI XH, HIGH(VA)
       LDI XL, LOW(VA) ; X -> VA[0]
       
       LDI R20, 12 ; contador para o loop (tamanho total do vetor)
       LDI R21, 31 ; valor inicial para armazenar no vetor

       RCALL init_array ; chama a função que preenche o loop

       ; aponta outro ponteiro para a última posição do vetor VR
       LDI YH, HIGH(VR+12)
       LDI YL, LOW(VR+12) ; Y -> VR[11]

       LDI R20, 12 ; contador para o loop (tamanho total do vetor)

       RCALL reverse_array ; chama a função para copiar os dados de um vetor 
                           ; para o outro de forma reversa

       ; LDI R20, 12 ; contador para o loop (tamanho total do vetor)

       ; LDI R22, 0 ; valor caso não tenha o valor no vetor
       ; LDI R21, 31 ; valor que estou procurando
       
       ; RCALL search_array ; chama a função de busca no vetor

END:
       RJMP END

init_array:
       ; armazenar os valores de 31 a 42 no vetor VA
       ST X+, R21 ; VA[X] <- R21, depois X incrementa

       INC R21 ; incrementa em 1 o valor de R21 (valor para armazenar)
       DEC R20 ; decrementa em 1 o valor de R20 (contador do loop)

       BRNE init_array ; repete o loop se R17 != 0

       ; retorna o ponteiro para a posição inicial do vetor VA
       LDI XH, HIGH(VA)
       LDI XL, LOW(VA) ; X -> VA[0]

       RET

reverse_array:
       ; lógica para copiar o vetor inversamente
       ; carrega o valor da posição X do vetor VA (do começo ao fim)
       LD R16, X+ ; R16 <- VA[X], depois X incrementa em 1
       ; armazena o valor na posição Y do vetor VR (de trás para frente)
       ST -Y, R16 ; VR[Y] <- R16, depois Y decrementa em 1

       DEC R20 ; decrementa em 1 o valor de R20 (contador do loop)

       BRNE reverse_array

       ; retorna o ponteiro para a posição inicial do vetor VA
       LDI XH, HIGH(VA)
       LDI XL, LOW(VA) ; X -> VA[0]

       ; retorna o ponteiro para a posição inicial do vetor VR
       LDI YH, HIGH(VR)
       LDI YL, LOW(VR) ; Y -> VR[0]

       RET

; REMOVI A FUNÇÃO, POIS JÁ TINHA FINALIZADO O TEMPO DE PROVA E APARECEU UM ERRO NELA
; search_array:
;        ; valor contido na posição atual do vetor
;        LD R17, X+ ; R17 <- X, depois X incrementa 1

;        LD R22, R17 ; R22 <- R17 (indíce do valor encontrado)

;        CP R21, R17 ; compara o valor de R21 (o que quero encontrar)
;                    ; e R17 (o valor contido na posição atual do vetor)

;        BREQ RET ; se for igual, retorna o index
;        ; caso contrário:
;        DEC R20 ; decrementa o contador
;        BRNE search_array ; recomeça o loop enquanto houverem posições a conferir

;        LDI R22, 0 ; caso não encontre em nenhuma posição, mantém R22 como 0

;        RET