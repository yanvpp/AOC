# Resumo por tópicos — Assembly AVR (ATmega328p)

Material do Prof. Roberto de Matos (IFSC, Câmpus São José), reunindo três apresentações:

- **[P1]** Projetando, codificando e simulando para MCU
- **[P2]** Assembly AVR — Trabalhando com os registradores
- **[P3]** Assembly AVR — SRAM

**Convenções**

- Cada tópico indica a origem entre colchetes, por exemplo *[P2, slides 4–5]*.
- Complementa `configurarIDE.md`, `pilhas-ponteiros-subrotinas.md` e `SRAM.md`; onde o conteúdo já está lá, só referencio. `pilha_sp_subrotinas.pdf` não foi resumido (coberto pelo `.md` de pilha).
- Itens marcados com *(obs.)* são observações minhas, não estão nos slides.

## Índice

1. Software embarcado e planejamento (round-robin, fluxogramas)
2. Arquitetura do ATmega328p (núcleo, memórias, registradores)
3. Escrevendo código: arquivo fonte, diretivas e números
4. Instruções que operam sobre registradores
5. Memória de dados (SRAM): modos de endereçamento
6. Alocando variáveis na SRAM
7. Ambiente de desenvolvimento e simulação (MPLAB X)
8. Exercícios propostos
9. Erros e pegadinhas — lista rápida

---

## 1. Software embarcado e planejamento

*[P1, slides 1–5]*

**Resumo:** O modelo mais simples de firmware é o *round-robin*, ou "loopão": configura o sistema após o reset e executa as tarefas em sequência, repetidamente. Antes de codificar, planeja-se com fluxograma.

**Pontos-chave**

- Estrutura: Reset → inicialização (uma vez) → laço (Tarefa 1 … Tarefa N) → volta ao laço.
- Exemplo: pisca-pisca = configura pino como saída → laço: liga LED, atraso, desliga LED, atraso.
- Símbolos de fluxograma: **terminação** (início/fim; no início leva o nome da rotina), **processo**, **sub-rotina** (hexágono), **decisão** (losango), **direção** (setas), **conexão** (círculo).
- Sub-rotina de atraso: três decrementos aninhados. `R19 = 0x02`, depois `R17 = R17-1`; se zerou, `R18 = R18-1`; se zerou, `R19 = R19-1`; se zerou, retorna.
- Para programar bem: planejar/modelar, conhecer a arquitetura, as instruções (manual do conjunto de instruções) e as diretivas (manual do montador).

**Pontos de atenção**

- A inicialização fica **fora** do laço; só as tarefas se repetem.
- No fluxograma do atraso, o ramo **Não** de cada losango volta ao **topo** do laço (decremento de R17), igual ao código com um único rótulo `loop`.
- R17 e R18 não têm valor inicial no fluxograma. Começando em 0, o primeiro `dec` leva a 0xFF, então cada um conta 256 vezes.
- *(obs.)* Estimativa a 16 MHz, ~3 ciclos por iteração: R19 = 2 dá cerca de 25 ms; R19 = 16, cerca de 200 ms (coerente com `pilhas-ponteiros-subrotinas.md`).
- *(obs.)* Num round-robin, um atraso longo atrasa todas as outras tarefas.
- Sub-rotinas e pilha: ver `pilhas-ponteiros-subrotinas.md`.

---

## 2. Arquitetura do ATmega328p

*[P2, slides 1, 3–5; P3, slides 3–6]*

**Resumo:** O ATmega328p tem três memórias separadas e um núcleo de 8 bits. A aula introduz a arquitetura **Load-Store**: a ALU trabalha sobre registradores, e a memória só é acessada por instruções de carga e armazenamento.

**Pontos-chave**

- **Núcleo:** Flash → Program Counter → Instruction Register → Decoder → linhas de controle; 32 × 8 registradores ligados à ALU; SRAM com endereçamento **direto** (vindo da instrução) e **indireto** (vindo de ponteiros); barramento de dados de **8 bits** para SRAM, EEPROM e periféricos (interrupções, SPI, watchdog, comparador analógico…).
- **Memória de programa (Flash):** 16 bits de largura, `0x0000`–`0x3FFF` (16K × 16 = 32 KB), com seção de aplicação e *Boot Flash* (256 a 2048 words).
- **Memória de dados:** 8 bits de largura.

| Região | Endereços de dados |
|---|---|
| 32 registradores de uso geral | `0x0000`–`0x001F` |
| 64 registradores de E/S | `0x0020`–`0x005F` (endereço de E/S: `0x00`–`0x3F`) |
| 160 registradores de E/S estendidos | `0x0060`–`0x00FF` |
| SRAM interna (2 KB) | `0x0100`–`0x08FF` |

- **EEPROM:** 1 KB, 8 bits, `0x000`–`0x3FF`.
- **Registradores de uso geral:** R0–R31 em `0x00`–`0x1F`. **R26/R27 = X**, **R28/R29 = Y**, **R30/R31 = Z** (pares de 16 bits, byte baixo no registrador de número menor), usados como ponteiros.
- No simulador, a CPU liga-se à Memória de Programa por endereços de **14 bits** e instruções de **16 bits**, e à Memória de Dados por endereços e dados de **8 bits**.

**Pontos de atenção**

- Endereços da Flash são em **words** (16 bits); os de dados são em **bytes**.
- Os registradores de uso geral estão **dentro** do espaço de dados.
- Os registradores de E/S têm **dois endereços**: o de dados (soma `0x20`) e o de E/S. `lds`/`sts` usam o de dados; `in`, `out`, `sbi`, `cbi` usam o de E/S. Por isso `PORTB` aparece como `0x025` na janela do simulador e como `0x05` em `sbi 0x05, 5`.
- A divisão R0–R15 / R16–R31 é relevante: as instruções imediatas só aceitam R16–R31 (tópico 4).
- *(obs.)* Programa e dados em memórias separadas é o que se chama arquitetura Harvard; o termo não aparece nos slides.

---

## 3. Escrevendo código: arquivo fonte, diretivas e números

*[P1, slides 6–8; P2, slide 12]*

**Resumo:** Um arquivo `.asm` mistura **instruções** (executadas pela CPU) e **diretivas** (comandos para o montador), mais comentários e linhas em branco.

**Pontos-chave**

- **Formato de linha:** `[Rótulo:] .diretiva [operandos] [comentários]` ou `[Rótulo:] instrução [operandos] [comentários]`. O que está entre `[ ]` é opcional.
- **Comentários:** tudo após `;` ou `//`.
- **Diretivas do curso:** segmentos `.DSEG`, `.CSEG`, `.ESEG`; `.BYTE` (reserva bytes na SRAM); `.DB`, `.DW` (constantes); `.DEF`; `.EQU`, `.SET`; `.ORG`; `.INCLUDE`. A lista completa está no manual online do montador.
- **`.DEF nome = registrador`:** nome simbólico para um registrador. Ex.: `.DEF temp=r16`.
- **`.EQU label = expressão`:** símbolo para um valor calculado pelo montador. Ex.: `.EQU valor=0x23+5`, depois `ldi temp, valor` / `inc temp`.
- **Formatos de números:** decimal (`10`, `255`); hexadecimal (`0x0a`, `$0a`, `0xff`, `$ff`); binário (`0b00110101`, `0b1100_1010`, com `_` como separador); octal com zero à frente (`010`, `077`).

**Pontos de atenção**

- Diretiva não gera instrução de máquina. `.DEF` e `.EQU` só criam nomes e não reservam memória.
- No exemplo do slide, `valor = 0x23 + 5 = 0x28` (40 decimal) e, no fim, `temp = 0x29`.
- **Pegadinha:** `010` é octal = 8 decimal, não 10.
- `.BYTE` reserva espaço na RAM; `.DB`/`.DW` colocam constantes (programa/EEPROM). Não confundir.
- *(obs.)* `.EQU` define constante fixa; para símbolo reatribuível existe `.SET` (ver manual do montador).

---

## 4. Instruções que operam sobre registradores

*[P2, slides 2, 6–11]*

**Resumo:** Instruções agrupadas pela forma como obtêm os operandos: constante (imediato), um registrador, dois registradores.

### 4.1 Modo imediato: `Registrador ← Constante`

- `ldi Rd, K` carrega uma constante. A constante está na Flash, dentro da própria instrução.
- Opcode `1110 KKKK dddd KKKK`; restrições `16 ≤ d ≤ 31` e `0 ≤ K ≤ 255`.
- Exemplo: `ldi R16, 0x14` → `1110 0001 0000 0100` (K = `0001 0100`, d = R16 → `dddd = 0000`).
- Outras do modo: `andi`, `ori`, `adiw`, `subi`, `sbci`, `sbiw` (lógica/aritmética) e `cpi` (desvio, compara com constante).
- **Atenção:** `ldi` **não funciona com R0–R15**. Para carregar constante neles, use um registrador alto e depois `mov`. *(obs.)* `andi`, `ori`, `subi`, `sbci` e `cpi` têm a mesma restrição; `adiw`/`sbiw` usam pares específicos (confirmar no manual).

### 4.2 Registrador único: `<instrução> Rd`, com `0 ≤ d ≤ 31`

- Rd é o operando e também recebe o resultado. Ex.: `inc r0`, `clr r0`.
- Transferência: `push`, `pop`. Lógica/aritmética: `com`, `neg`, `inc`, `dec`, `tst`, `clr`, `ser`. Bit e teste de bit: `lsl`, `lsr`, `asr`, `rol`, `ror`, `swap`, `bld`, `bst`.
- **Atenção:** vale qualquer registrador, R0–R31. `push`/`pop` usam a pilha (ver `pilhas-ponteiros-subrotinas.md`).

### 4.3 Dois registradores: `Rr` e `Rd`, resultado em `Rd`

- `mov Rd, Rr`: `Rd ← Rr`, qualquer registrador.
- `movw Rd, Rr`: `Rd+1:Rd ← Rr+1:Rr` (copia 16 bits); só registradores **pares** (0, 2, …, 30).
- Aritmética/lógica: `add`, `adc`, `sub`, `sbc`, `and`, `or`, `eor`, `mul`, `muls`, `mulsu`, `fmul`, `fmuls`, `fmulsu`.
- **Atenção:** `mov` copia, a origem não muda. No exemplo (`inc r0` / `mov r1,r0` / `inc r0` / `movw r2,r0`), partindo de registradores zerados, termina com R0 = 2, R1 = 1, R2 = 2, R3 = 1. `adc`/`sbc` usam o Carry anterior, a base das contas de vários bytes.

### 4.4 Tabela de instruções aritméticas e lógicas

- Soma/subtração: `ADD`, `ADC`, `ADIW`, `SUB`, `SUBI`, `SBC`, `SBCI`, `SBIW`.
- Lógicas: `AND`, `ANDI`, `OR`, `ORI`, `EOR`, `COM`, `NEG`, `SBR`, `CBR`.
- Um operando: `INC`, `DEC`, `TST`, `CLR`, `SER`.
- Multiplicação: `MUL`, `MULS`, `MULSU`, `FMUL`, `FMULS`, `FMULSU`, com resultado em **R1:R0**.
- Ciclos: a maioria leva **1**; `ADIW`/`SBIW` e as multiplicações levam **2**.
- **Atenção:**
  - `INC` e `DEC` afetam Z, N, V, mas **não o Carry**.
  - `AND/OR/EOR` afetam só Z, N, V.
  - `SER` não afeta flags.
  - `CLR` é `EOR Rd,Rd` e `TST` é `AND Rd,Rd`.
  - Não existe `ADDI`: para somar constante, use `SUBI` com valor negativo ou carregue a constante num registrador e faça `add`.

---

## 5. Memória de dados (SRAM): modos de endereçamento

*[P3, slides 1–2, 7–12]*

**Resumo:** Registradores e periféricos não bastam: variáveis temporárias e vetores de dados vão para a SRAM. Há cinco modos de acessá-la. Detalhes e exemplos `C = A + B` estão em `SRAM.md`; abaixo ficam o resumo e os exemplos dos slides.

| Modo | Sintaxe | Ponteiro muda? | Registradores | Exemplo do slide |
|---|---|---|---|---|
| Direto | `lds Rd, k` / `sts k, Rr` | — | — | `lds R0, 0x0100` / `sts 0x0101, R0` |
| Indireto | `ld Rd, X` / `st X, Rr` | Não | X, Y ou Z | X = `0x0100`; `ld r0,X`; `inc r0`; `st X,r0` |
| Pós-incremento | `ld Rd, X+` / `st X+, Rr` | Sim, **+1 depois** do acesso | X, Y ou Z | laço `inc r0` / `st X+,r0` grava 1, 2, 3… em `0x0100`, `0x0101`… |
| Pré-decremento | `ld Rd, -X` / `st -X, Rr` | Sim, **−1 antes** do acesso | X, Y ou Z | X = `0x010B`; laço `inc r0` / `st -X,r0` |
| Deslocamento | `ldd Rd, Y+q` / `std Y+q, Rr` | Não | **só Y ou Z** | Y = `0x0100`; `std Y+2,r0` → `0x0102`; `std Y+3,r0` → `0x0103` |

**Pontos-chave**

- Em todos, `0 ≤ r/d ≤ 31`. Direto: `0 ≤ k ≤ 65535`. Deslocamento: `0 ≤ q ≤ 63`.
- No indireto, o ponteiro de 16 bits é montado com dois `ldi`: `r27`/`XH` recebe o byte **alto** e `r26`/`XL` o **baixo**.
- Com pós-incremento e pré-decremento, X, Y e Z são **modificados**; com deslocamento e indireto simples, não.
- Toda a memória de dados pode ser alcançada por esses modos.

**Pontos de atenção**

- `lds`/`sts` ocupam **32 bits** (duas palavras), porque o endereço vai dentro do opcode.
- *(obs.)* `k` aceita até 65535, mas o espaço de dados do ATmega328p termina em `0x08FF`.
- **Pré-decremento:** o primeiro acesso do exemplo é em `0x010A`, não em `0x010B`.
- Os laços dos exemplos de pós-incremento e pré-decremento são **infinitos** e sem teste de limite. O pós-incremento passa de `0x08FF`. O pré-decremento desce por `0x00FF` e abaixo, atingindo E/S estendida e depois os registradores. *(obs.)* A pilha fica no topo da SRAM (`0x08FF`), então um laço assim poderia sobrescrevê-la.
- No deslocamento, **X não pode** ser usado, e `q` é constante embutida na instrução (6 bits), não um registrador.
- O slide de resumo diz que o deslocamento "alcança 63 endereços". Na prática, `q` vai de 0 a 63, ou seja, 64 posições contando a base (`q = 0`).
- Quando precisar de outro endereço no modo indireto simples, é preciso recarregar o ponteiro. O pós-incremento evita isso em dados sequenciais.

---

## 6. Alocando variáveis na SRAM

*[P3, slides 13–15]*

**Resumo:** O montador reserva espaço e dá nomes (rótulos) às posições da SRAM; os valores só podem ser inicializados em tempo de execução.

**Pontos-chave**

- **`.DSEG`** abre o segmento de dados (RAM); **`.CSEG`** o de programa (Flash); **`.ESEG`** o de EEPROM.
- **`.ORG SRAM_START`** posiciona o início em `0x0100`; `SRAM_START` vem de `m328Pdef.inc` (`.INCLUDE <m328Pdef.inc>`).
- **`.BYTE n`** reserva `n` bytes, e o rótulo aponta para o **primeiro** byte.
- Exemplo do slide: `var1: .BYTE 1` (`0x0100`), `var2: .BYTE 2` (a partir de `0x0101`), `var3: .BYTE 1`. No código: `ldi r19,15` / `sts var1,r19`.
- **Operador `+` em rótulos:** `uint: .BYTE 2`; `sts uint,r16` (0xCD) e `sts uint+1,r17` (0xAB) gravam 0xABCD; `lds r0,uint` e `lds r1,uint+1` leem em R1:R0.
- **`LOW()` e `HIGH()`:** `ldi XL, LOW(char)` e `ldi XH, HIGH(char)` carregam X com o endereço de `char`; depois `st X, r16`.
- `XL` e `XH` são nomes de R26/R27 definidos em `m328Pdef.inc`.

**Pontos de atenção**

- **Erro no slide 13:** o comentário diz que o segundo byte de `var2` é `var2+1 (0x0103)`. O correto é **`0x0102`**, porque `var2` está em `0x0101`; então `var3` fica em `0x0103`.
- `.BYTE` **não inicializa** nada: use `ldi` + `sts` no programa.
- O exemplo do operador `+` ilustra **little-endian**: byte baixo (`0xCD`) no endereço menor, byte alto (`0xAB`) em `uint+1`.
- Um comentário do slide fala em "int" em vez de "uint" (erro de digitação).

---

## 7. Ambiente de desenvolvimento e simulação (MPLAB X)

*[P1, slides 9–12]*

**Resumo:** O código é montado e simulado no MPLAB X, com janelas que espelham a arquitetura. Instalação e configuração do `avrasm2` estão em `configurarIDE.md`.

**Pontos-chave**

- **Abrir o projeto:** descompactar `AOC129004.X.zip` → MPLAB X → `File -> Open Project` → selecionar o diretório → expandir *Source Files* → abrir `aula1.asm`.
- **Layout sugerido:** editor, Dashboard, **I/O Memory (SFRs)**, **Program Memory** e **SRAM Data Memory** (SRAM a partir de `0x100`). O Dashboard mostra Data 2.048 bytes (0x800) e Program 32.768 bytes (0x8000).
- **Arquitetura × simulador:** Memória de Programa → janela *Program Memory*; registradores de trabalho e de E/S → *I/O Memory (SFRs)*; SRAM → *SRAM Data Memory*.
- **Simular:** `Debug -> Discrete Debugger Operation -> Build for Debugging`, depois `... -> Launch Debugger`, e usar a barra de controles do debugger.

**Pontos de atenção**

- A captura de tela é do MPLAB X v5.45; o guia atual usa a v6.15, então os menus podem diferir.
- A janela *Program Memory* da captura mostra um pisca-pisca, diferente do código do editor: a figura é só ilustrativa do layout.
- `configurarIDE.md` usa `Debug -> Debug Main Project` para iniciar; o slide usa `Launch Debugger`. Mudam os nomes de menu, o resultado é abrir o debugger.
- A janela *I/O Memory* mostra R0–R31 **e** os registradores de E/S (PINB, DDRB, PORTB…) juntos.
- A barra de ícones do debugger vem sem legenda no slide; passe o mouse sobre cada ícone para ver a função.

---

## 8. Exercícios propostos

*[P2, slide 13; P3, slide 16]*

**Registradores [P2]**

- Simular todos os trechos dos slides.
- Somar dois números de 8 bits (R16 e R17) **mais a constante 22** e copiar para R18; alterar os valores no simulador para conferir.
- Atenção: não há `ADDI`. O resultado é de 8 bits: acima de 255 o excesso se perde e o Carry sinaliza.

```asm
    mov  r18, r16
    add  r18, r17      ; R18 = R16 + R17
    ldi  r19, 22
    add  r18, r19      ; R18 = R18 + 22
```

**SRAM [P3]**

- Simular todos os trechos e alterar a memória para conferir.
- `C = A + B` com variáveis de **8 bits**, depois de **16 bits**, com A, B e C em sequência a partir do primeiro endereço da SRAM; nos 16 bits, usar **little-endian**.
- Atenção: a versão de 8 bits tem exemplos prontos em `SRAM.md`. Em 16 bits, partindo de `0x0100`: A em `0x0100`–`0x0101`, B em `0x0102`–`0x0103`, C em `0x0104`–`0x0105`. *(obs.)* A soma precisa de `add` no byte baixo e `adc` no alto, para propagar o Carry.

---

## 9. Erros e pegadinhas — lista rápida

1. `ldi` (e imediatas em geral) só aceita **R16–R31**.
2. `INC`/`DEC` **não afetam o Carry**.
3. Não existe `ADDI`; use `SUBI` negativo ou um registrador auxiliar.
4. `movw` só com registradores **pares**.
5. Número com **zero à esquerda é octal** (`010` = 8).
6. `ldd`/`std` aceitam só **Y ou Z** e `q` de 0 a 63.
7. Pré-decremento acessa **depois** de decrementar (primeiro acesso em `0x010A` no exemplo).
8. Laços de pós-incremento e pré-decremento dos exemplos são infinitos e podem sair da SRAM.
9. Slide 13 de SRAM: o segundo byte de `var2` é `0x0102`, não `0x0103`.
10. Registradores de E/S: endereço de **dados** = endereço de **E/S** + `0x20`.
11. `.BYTE` reserva, mas **não inicializa**.
