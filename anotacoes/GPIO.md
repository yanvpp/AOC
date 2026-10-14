# Portas de Entrada e Saída (GPIO) — ATmega328p

[slides](../materiais/slides/prova_03/portasIO_GPIO.pdf)

## 1. O que é GPIO

- Portas de entrada e saída de uso geral (**GPIO**) são os periféricos **mais simples** do microcontrolador.
- Forma mais simples de interagir com **sensores (entrada)** e **atuadores (saída)**.
- O ATmega328 tem 3 conjuntos de pinos de I/O:

| Porta | Pinos |
|---|---|
| PORTB | PB7 .. PB0 |
| PORTC | PC6 .. PC0 (**não tem o bit 7**) |
| PORTD | PD7 .. PD0 |

- Todos os pinos têm a função **Lê – Modifica – Escreve**.
- Cada pino pode ser configurado **individualmente** como entrada ou saída.
- Todos os pinos têm **resistores de pull-up internos**, **diodos de proteção** entre VCC e terra e uma capacitância de ~**10 pF**.

---

## 2. Estrutura interna de um pino (PXn)

Esquema geral (Fig. 5.1 dos slides):

- O pino **PXn** liga-se à **lógica** interna.
- **Diodo para VCC** e **diodo para GND** (proteção).
- **Capacitância Cpin** do pino para o terra.
- **Resistor de pull-up** ligado a VCC através de uma **chave de habilitação do pull-up**.

---

## 3. Registradores das portas: DDRx, PORTx, PINx

Cada porta `x` (B, C, D) tem 3 registradores:

| Registrador | Função |
|---|---|
| **DDRx** | **Direção**: define se cada pino é entrada (0) ou saída (1) |
| **PORTx** | **Dados**: modifica o nível dos pinos quando são **saída**; habilita o **pull-up** quando são **entrada** |
| **PINx** | **Entrada**: lê o estado dos pinos |

### Endereços (I/O e SRAM)

| Endereço I/O (SRAM) | Registrador | Bits |
|---|---|---|
| `0x0B` (`0x2B`) | PORTD | PORTD7 .. PORTD0 |
| `0x0A` (`0x2A`) | DDRD | DDD7 .. DDD0 |
| `0x09` (`0x29`) | PIND | PIND7 .. PIND0 |
| `0x08` (`0x28`) | PORTC | — , PORTC6 .. PORTC0 |
| `0x07` (`0x27`) | DDRC | — , DDC6 .. DDC0 |
| `0x06` (`0x26`) | PINC | — , PINC6 .. PINC0 |
| `0x05` (`0x25`) | PORTB | PORTB7 .. PORTB0 |
| `0x04` (`0x24`) | DDRB | DDB7 .. DDB0 |
| `0x03` (`0x23`) | PINB | PINB7 .. PINB0 |

- Lembrete: endereço SRAM = endereço de I/O + `0x20`.
- Na porta C, o **bit 7 não existe**.
- Todos esses registradores estão na faixa `0x00`–`0x1F` de I/O, então podem usar `sbi`, `cbi`, `sbic` e `sbis`.

### Configuração do pino: DDxn, PORTxn e PUD

| DDxn | PORTxn | PUD | I/O | Pull-up | Comentário |
|---|---|---|---|---|---|
| 0 | 0 | x | Entrada | Não | Alta impedância (Hi-Z) |
| 0 | 1 | 0 | Entrada | **Sim** | PXn fornece corrente se for colocado externamente em nível 0 |
| 0 | 1 | 1 | Entrada | Não | Alta impedância (Hi-Z) |
| 1 | 0 | x | Saída | Não | Saída em **zero** (drena corrente) |
| 1 | 1 | x | Saída | Não | Saída em **nível alto** (fornece corrente) |

- **PUD** (Pull-up Disable) é um bit do registrador MCUCR (`0x35`, bit 4). Com PUD = 1, o pull-up é desabilitado em todos os pinos.
- Para **entrada com pull-up**: `DDxn = 0` e `PORTxn = 1`.

### Função especial do PINx (toggle)

- O PINx é **somente leitura**, mas escrever **1** em `PINxn` **inverte** o valor de `PORTxn`, independente do DDRxn.
- Com **uma única instrução** `sbi` é possível inverter o pino de uma porta:

```asm
sbi PINB, PB5    ; inverte o estado do pino PB5 (toggle)
```

---

## 4. Receitas básicas (instruções do capítulo anterior aplicadas às portas)

| Objetivo | Instrução |
|---|---|
| Pino como **saída** | `sbi DDRx, n` |
| Pino como **entrada** | `cbi DDRx, n` |
| Colocar saída em **nível alto** (5V) | `sbi PORTx, n` |
| Colocar saída em **nível baixo** (0V) | `cbi PORTx, n` |
| Habilitar **pull-up** (pino de entrada) | `sbi PORTx, n` |
| Ler o estado de um pino | `sbic PINx, n` / `sbis PINx, n` (ou `in Rd, PINx`) |
| Inverter saída | `sbi PINx, n` |

---

## 5. Notação de fluxogramas (slide 5)

| Símbolo | Significado |
|---|---|
| Terminação (retângulo arredondado) | Início ou fim do programa; no início deve conter o nome da rotina |
| Processo (retângulo) | Ação a ser executada |
| Sub-rotina (hexágono) | Operação separada do fluxo principal |
| Decisão (losango) | Desvio conforme a condição testada |
| Direção (setas) | Direção de execução do programa |
| Conexão (círculo) | Conecta as setas de direção |

---

## 6. Exemplo 1 — Manipulando um LED

**Circuito:** LED **D1** com resistor **R1 = 560 Ω** ligado ao pino **PB5** e ao GND (o LED acende com **nível alto** no pino).

**Fluxograma:** Reset → Configura pino como saída → (laço) Liga LED.

```asm
.INCLUDE <m328Pdef.inc>

setup:
  sbi DDRB, PB5      ; configura o pino PB5 como saída

loop:
  sbi PORTB, PB5     ; coloca o pino PB5 em 5V

  rjmp loop
```

- Para **desligar** o LED, substituir a linha do `sbi PORTB, PB5` por:

```asm
  cbi PORTB, PB5     ; coloca o pino PB5 em 0V
```

---

## 7. Exemplo 2 — Pisca LED (`pisca_led.asm`)

**Fluxograma:** Reset → Configura pino como saída → (laço) Liga LED → Atraso 200ms → Desliga LED → Atraso 200ms → volta ao laço.

```asm
.INCLUDE <m328Pdef.inc>

start:
  sbi DDRB, PB5      ; configura o pino PB5 como saída

main:
  sbi PORTB, PB5     ; coloca o pino PB5 em 5V

  ; atraso de aprox. 200ms
  ldi R19, 16
  rcall delay

  cbi PORTB, PB5     ; coloca o pino PB5 em 0V

  ; atraso de aprox. 200ms
  ldi R19, 16
  rcall delay

  rjmp main

;--------------------------------
; SUB-ROTINA DE ATRASO Programável
; Ex.: R19 = 16 --> 200ms
;      R19 = 80 --> 1s
;--------------------------------
delay:
  push r17
  push r18
  in   r17, SREG
  push r17

  clr r17
  clr r18
loop:
  dec R17
  brne loop
  dec R18
  brne loop
  dec R19
  brne loop

  pop r17
  out SREG, r17
  pop r18
  pop r17

  ret
```

Pontos do exemplo:

- Uma única sub-rotina `delay` é chamada **duas vezes** (ligar e desligar), evitando duplicar código.
- O tempo do atraso é **programável por R19** (parâmetro de entrada, por isso **não** é salvo/restaurado).
- `R17`, `R18` e o `SREG` são **salvos na pilha** no início e restaurados **na ordem inversa** antes do `ret` (contexto preservado).
- Os contadores `R17` e `R18` começam em 0 (`clr`), então `dec` os leva a 255 e o laço roda 256 vezes cada.

---

## 8. Exemplo 3 — Lendo um botão

**Circuito:**

- **LED** ligado entre VCC e o pino **PD2** (resistor de **330 Ω**): o LED **acende com '0' no PD2**.
- **Botão** ligado entre **PD7** e o GND: **chave pressionada → PD7 = '0'**.
- Como não há resistor externo, é usado o **pull-up interno** em PD7 (solto = '1').

**Fluxograma:** Reset → Configura pinos → Desliga LED → Botão pressionado? (Não: volta) → Liga LED → Botão solto? (Não: volta; Sim: volta ao início).

```asm
.INCLUDE <m328Pdef.inc>

setup:
  sbi DDRD, PD2      ; configura o pino PD2 como saída

  cbi DDRD, PD7      ; configura o pino PD7 como entrada
  sbi PORTD, PD7     ; habilita o pull-up para o botão

;----------------------
; LAÇO PRINCIPAL
;----------------------
naoPress:            ; loop botão não pressionado (pull-up)
  sbi  PORTD, PD2    ; desliga LED
  sbic PIND, PD7     ; verifica se o botão foi pressionado,
  rjmp naoPress      ; senão volta e fica preso no laço naoPress

press:               ; loop botão pressionado
  cbi  PORTD, PD2    ; liga LED
  sbis PIND, PD7     ; verifica se o botão foi solto, senão
  rjmp press         ; senão, aguarda.

  rjmp naoPress      ; volta para o loop do "botão não pressionado"
```

Pontos do exemplo:

- **Lógica invertida (ativo em baixo):** LED liga com `cbi` (0V) e desliga com `sbi` (5V); botão pressionado = 0.
- `sbic PIND, PD7`: pula a próxima instrução se o bit for **0** (botão pressionado) → sai do laço `naoPress`.
- `sbis PIND, PD7`: pula a próxima instrução se o bit for **1** (botão solto) → sai do laço `press`.
- O programa faz **polling** (fica testando o pino continuamente).

---

## 9. Experimentos (slide 14)

- **Simular** (MPLAB IDE) e **testar na placa** todos os trechos de código apresentados.
- Fazer a **atividade proposta**.

---

## 10. Pontos de atenção para a prova

- **DDRx** define a direção (1 = saída, 0 = entrada); **PORTx** escreve na saída ou liga o pull-up; **PINx** lê o pino.
- Entrada com pull-up: `DDxn = 0` e `PORTxn = 1` (e `PUD = 0`).
- `DDxn = 0` e `PORTxn = 0`: entrada em **alta impedância (Hi-Z)**.
- `DDxn = 1`: saída; `PORTxn = 0` drena corrente (0V) e `PORTxn = 1` fornece corrente (5V).
- Escrever 1 em `PINxn` **inverte** `PORTxn` (toggle com um único `sbi`).
- A porta C **não tem o bit 7** (PC6 é o último; PC6 também é o pino de RESET).
- Endereços: PINB `0x03`, DDRB `0x04`, PORTB `0x05`; PINC `0x06`, DDRC `0x07`, PORTC `0x08`; PIND `0x09`, DDRD `0x0A`, PORTD `0x0B` (SRAM = +`0x20`).
- Em circuito com LED ligado ao VCC ou botão ligado ao GND, a lógica é **invertida** (ativo em baixo): atenção a `sbi` x `cbi` e a `sbic` x `sbis`.
- `sbic`/`sbis` **pulam a próxima instrução**; quem volta ao rótulo é o `rjmp`.
- Sub-rotina de atraso: salvar na pilha o que ela altera (inclusive `SREG`), **exceto o registrador usado como parâmetro** (R19).