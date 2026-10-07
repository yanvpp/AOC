# AI2_1 — Regiões da Memória de Dados (2025-2)

Conteúdo de apoio e resolução comentada da prova, para ATmega328p em Assembly (montador `avrasm2`, MPLAB X).

Material relacionado: `SRAM.md` (modos de endereçamento), `pilhas-ponteiros-subrotinas.md` (pilha, sub-rotinas, salvar contexto) e `configurarIDE.md` (IDE e simulador).

## Índice

1. Enunciado
2. Conteúdo necessário
3. Parte 1 — Manipulação de vetores
4. Parte 2 — Sub-rotinas de 32 bits
5. Como simular e conferir
6. Checklist e erros comuns

---

## 1. Enunciado

### Parte 1 — Manipulação de vetores

1. Declare dois vetores com 8 posições de 8 bits (`V0`, `V1`) e um vetor com 4 posições (`V2`).
2. Inicialize `V0` com os valores de 8 até 15.
3. Copie de trás para frente o `V0` para `V1`.
4. Some as posições pares do `V0` com as ímpares do `V1`, colocando o resultado em `V2`. Exemplo: `V2(0) = V0(0) + V1(1)`, etc.

*Obs.: utilize as diretivas do montador e os modos de endereçamento adequados.*

### Parte 2 — Sub-rotinas

| Sub-rotina | O que faz | Parâmetros |
|---|---|---|
| `inc_32bits` | Incrementa uma variável de 32 bits | **X**: ponteiro para a posição inicial da variável |
| `dec_32bits` | Decrementa uma variável de 32 bits | **X**: ponteiro para a posição inicial da variável |
| `mov_32bits` | Copia uma variável de 32 bits | **X**: origem; **Y**: destino |

*Obs.:*
- *Em todos os casos, o byte menos significativo fica no menor endereço (little-endian).*
- *Implemente as sub-rotinas sem chamada de sub-rotinas intermediárias.*
- *Implemente testes para cada uma das sub-rotinas.*

---

## 2. Conteúdo necessário

### 2.1 Diretivas para declarar variáveis

- `.DSEG` abre o segmento de dados (RAM); `.CSEG` volta ao de programa.
- `.ORG SRAM_START` posiciona o início em `0x0100` (símbolo definido em `m328Pdef.inc`).
- `rótulo: .BYTE n` reserva `n` bytes; o rótulo é o endereço do **primeiro** byte. Vetores consecutivos ficam em sequência.
- `.BYTE` só reserva espaço e **não inicializa**: os valores são gravados em tempo de execução.
- `LOW()`, `HIGH()` e o operador `+` montam endereços: `ldi XL, LOW(V0+8)`.

### 2.2 Modos de endereçamento da SRAM

| Modo | Sintaxe | Ponteiro muda? | Quando usar |
|---|---|---|---|
| Indireto | `ld Rd, X` / `st X, Rr` | Não | Acesso pontual |
| Pós-incremento | `ld Rd, X+` / `st X+, Rr` | +1 **depois** do acesso | Percorrer vetor do início ao fim |
| Pré-decremento | `ld Rd, -X` / `st -X, Rr` | −1 **antes** do acesso | Percorrer vetor do fim ao início |
| Deslocamento | `ldd Rd, Y+q` / `std Y+q, Rr` | Não | Acessar `base + q` (0 ≤ q ≤ 63), **só Y ou Z** |

### 2.3 Aritmética de vários bytes (32 bits)

- Little-endian: byte 0 (menos significativo) no endereço `P`, byte 1 em `P+1`, byte 2 em `P+2`, byte 3 em `P+3`.
- **Incremento:** soma 1 no byte 0; só propaga para o próximo byte se o byte virou `0x00` (flag **Z** do `inc`).
- **Decremento:** subtrai 1 do byte 0; só propaga se houve **empréstimo** (flag **C** do `subi`).
- `INC` e `DEC` **não alteram o Carry**, por isso o decremento usa `subi Rd, 1`, que seta C quando há empréstimo.
- Ao chegar no byte 3, o valor dá a volta: `0xFFFFFFFF + 1 = 0x00000000` e `0x00000000 − 1 = 0xFFFFFFFF`.

### 2.4 Sub-rotinas e contexto

- Chamar com `rcall`, terminar com `ret` (endereço de retorno na pilha; o SP do ATmega328p já inicia em `0x08FF`).
- Parâmetros por registrador: aqui, **X** e **Y** carregam os endereços.
- Boa prática: a sub-rotina salva com `push` o que modifica e restaura com `pop` na **ordem inversa**. O `SREG` entra nessa conta quando a sub-rotina altera flags (`inc`, `subi`…).
- *"Sem chamadas intermediárias"*: as três sub-rotinas não podem usar `rcall` para outras sub-rotinas. Os testes podem.

---

## 3. Parte 1 — Manipulação de vetores

### 3.1 Análise

- Três vetores em sequência na SRAM:

| Vetor | Tamanho | Endereços |
|---|---|---|
| `V0` | 8 bytes | `0x0100`–`0x0107` |
| `V1` | 8 bytes | `0x0108`–`0x010F` |
| `V2` | 4 bytes | `0x0110`–`0x0113` |

- **Inicializar `V0` (8 a 15):** laço com `st X+, r16`, incrementando `r16`.
- **Copiar de trás para frente:** `Y` aponta para o fim de `V0`; `ld r16, -Y` lê `V0(7)`, `V0(6)`… e `st X+, r16` grava `V1(0)`, `V1(1)`… (pré-decremento + pós-incremento).
- **Somar pares e ímpares:** `V2(i) = V0(2i) + V1(2i+1)`, com `i = 0…3`. Usa indireto (`ld r16, Y`) e deslocamento (`ldd r17, Z+1`), avançando os ponteiros de 2 em 2 com `adiw`.

### 3.2 Ponto de atenção: interpretação de "de trás para frente"

O enunciado admite duas leituras. A resolução abaixo usa a **primeira**; a segunda está na seção 3.4.

1. **Inverter:** `V1(i) = V0(7−i)`, ou seja, `V1 = {15, 14, …, 8}`.
2. **Copiar percorrendo do fim para o início:** `V1(i) = V0(i)`, só que começando pelo último elemento.

*Sugestão: confirme com o professor qual leitura é a esperada.*

### 3.3 Código (leitura 1: inverter)

```asm
;===============================================================
; AI2_1 - Parte 1: Manipulação de vetores
;===============================================================
.INCLUDE <m328Pdef.inc>

;------------------------- DADOS (SRAM) ------------------------
.DSEG
.ORG SRAM_START          ; 0x0100
V0: .BYTE 8              ; 0x0100 .. 0x0107
V1: .BYTE 8              ; 0x0108 .. 0x010F
V2: .BYTE 4              ; 0x0110 .. 0x0113

;------------------------- PROGRAMA ----------------------------
.CSEG
start:
    ;--- 1) V0 = {8, 9, ..., 15} (indireto com pós-incremento) ---
    ldi  XH, HIGH(V0)
    ldi  XL, LOW(V0)
    ldi  r16, 8              ; valor inicial
    ldi  r17, 8              ; contador de elementos
init_v0:
    st   X+, r16             ; V0(i) <- r16 ; X avança
    inc  r16
    dec  r17
    brne init_v0

    ;--- 2) copia V0 -> V1 de trás para frente (inverte) ---
    ldi  YH, HIGH(V0+8)      ; Y aponta uma posição além do fim de V0
    ldi  YL, LOW(V0+8)
    ldi  XH, HIGH(V1)        ; X aponta o início de V1
    ldi  XL, LOW(V1)
    ldi  r17, 8
copia:
    ld   r16, -Y             ; pré-decremento: lê V0(7), V0(6), ... V0(0)
    st   X+, r16             ; pós-incremento: grava V1(0), V1(1), ... V1(7)
    dec  r17
    brne copia

    ;--- 3) V2(i) = V0(2i) + V1(2i+1), i = 0..3 ---
    ldi  YH, HIGH(V0)        ; Y -> V0
    ldi  YL, LOW(V0)
    ldi  ZH, HIGH(V1)        ; Z -> V1
    ldi  ZL, LOW(V1)
    ldi  XH, HIGH(V2)        ; X -> V2
    ldi  XL, LOW(V2)
    ldi  r18, 4              ; 4 somas
soma:
    ld   r16, Y              ; V0(2i)      (posição par)
    ldd  r17, Z+1            ; V1(2i+1)    (posição ímpar, deslocamento)
    add  r16, r17
    st   X+, r16             ; V2(i)
    adiw YL, 2               ; Y avança 2 posições
    adiw ZL, 2               ; Z avança 2 posições
    dec  r18
    brne soma

fim:
    rjmp fim
```

### 3.4 Variante (leitura 2: copiar do fim para o início)

Substitua o bloco `;--- 2) ---` por este. Os dois ponteiros começam no fim e usam pré-decremento:

```asm
    ;--- 2) copia V0 -> V1 percorrendo do fim para o início ---
    ldi  YH, HIGH(V0+8)
    ldi  YL, LOW(V0+8)
    ldi  XH, HIGH(V1+8)
    ldi  XL, LOW(V1+8)
    ldi  r17, 8
copia:
    ld   r16, -Y             ; V0(7), V0(6), ... V0(0)
    st   -X, r16             ; V1(7), V1(6), ... V1(0)
    dec  r17
    brne copia
```

### 3.5 Resultado esperado na SRAM

| Vetor | Endereço | Leitura 1 (inverter) | Leitura 2 (cópia) |
|---|---|---|---|
| `V0` | `0x0100`–`0x0107` | `08 09 0A 0B 0C 0D 0E 0F` | igual |
| `V1` | `0x0108`–`0x010F` | `0F 0E 0D 0C 0B 0A 09 08` | `08 09 0A 0B 0C 0D 0E 0F` |
| `V2` | `0x0110`–`0x0113` | `16 16 16 16` | `11 15 19 1D` |

Conferência das somas:

- Leitura 1: `8+14 = 10+12 = 12+10 = 14+8 = 22 = 0x16`.
- Leitura 2: `8+9 = 17`, `10+11 = 21`, `12+13 = 25`, `14+15 = 29`.

### 3.6 Pontos de atenção

- Em `ld r16, -Y`, o primeiro acesso é em `V0+7`, porque o ponteiro é decrementado **antes** do acesso. Por isso `Y` começa em `V0+8`.
- `ldd` só aceita **Y ou Z**; por isso `V1` é lido por `Z+1`.
- Recarregue o ponteiro de cada etapa: X, Y e Z terminam cada laço em outro endereço.
- Nos laços, `dec` seguido de `brne` usa o Z do `dec`; o `adiw` vem **antes** do `dec`, senão alteraria o Z testado.

---

## 4. Parte 2 — Sub-rotinas de 32 bits

### 4.1 Decisões de projeto

- **Convenção de contexto:** cada sub-rotina devolve **X** (e **Y**, no `mov_32bits`), os registradores auxiliares e o `SREG` como estavam. Quem chama pode continuar usando o ponteiro. O `mov_32bits` não salva `SREG` porque `ld`/`st` não alteram flags.
- **Sem chamadas intermediárias:** as três sub-rotinas são sequências diretas, sem `rcall`. Os laços foram desenrolados (4 repetições) para manter o código simples.
- **Propagação de carry/empréstimo:**
  - `inc`: `inc r16` e `brne` (se o byte não virou 0, para).
  - `dec`: `subi r16, 1` e `brcc` (se não houve empréstimo, para).
- **Saída antecipada:** o rótulo `*_fim` fica antes da restauração do contexto, de modo que o caminho curto e o completo restauram tudo.

### 4.2 Sub-rotinas

```asm
;---------------------------------------------------------------
; inc_32bits
; Incrementa a variável de 32 bits apontada por X (little-endian).
; Entrada : X = endereço do byte menos significativo
; Altera  : memória apontada por X (X, r16 e SREG são preservados)
; Obs.    : 0xFFFFFFFF + 1 = 0x00000000
;---------------------------------------------------------------
inc_32bits:
    push r16
    push XL
    push XH
    in   r16, SREG
    push r16                 ; salva SREG

    ld   r16, X              ; byte 0
    inc  r16
    st   X+, r16             ; st e X+ não alteram o Z do inc
    brne inc32_fim           ; != 0: sem propagação, terminou

    ld   r16, X              ; byte 1
    inc  r16
    st   X+, r16
    brne inc32_fim

    ld   r16, X              ; byte 2
    inc  r16
    st   X+, r16
    brne inc32_fim

    ld   r16, X              ; byte 3
    inc  r16
    st   X, r16
inc32_fim:
    pop  r16
    out  SREG, r16           ; restaura SREG
    pop  XH
    pop  XL
    pop  r16
    ret

;---------------------------------------------------------------
; dec_32bits
; Decrementa a variável de 32 bits apontada por X (little-endian).
; Entrada : X = endereço do byte menos significativo
; Altera  : memória apontada por X (X, r16 e SREG são preservados)
; Obs.    : 0x00000000 - 1 = 0xFFFFFFFF
;---------------------------------------------------------------
dec_32bits:
    push r16
    push XL
    push XH
    in   r16, SREG
    push r16                 ; salva SREG

    ld   r16, X              ; byte 0
    subi r16, 1              ; C = 1 se houve empréstimo
    st   X+, r16             ; st e X+ não alteram o C
    brcc dec32_fim           ; C = 0: sem empréstimo, terminou

    ld   r16, X              ; byte 1
    subi r16, 1
    st   X+, r16
    brcc dec32_fim

    ld   r16, X              ; byte 2
    subi r16, 1
    st   X+, r16
    brcc dec32_fim

    ld   r16, X              ; byte 3
    subi r16, 1
    st   X, r16
dec32_fim:
    pop  r16
    out  SREG, r16           ; restaura SREG
    pop  XH
    pop  XL
    pop  r16
    ret

;---------------------------------------------------------------
; mov_32bits
; Copia 4 bytes da variável apontada por X para a apontada por Y.
; Entrada : X = origem (byte menos significativo)
;           Y = destino (byte menos significativo)
; Altera  : memória apontada por Y (X, Y e r16 são preservados)
; Obs.    : ld/st não alteram flags, então o SREG não é salvo.
;---------------------------------------------------------------
mov_32bits:
    push r16
    push XL
    push XH
    push YL
    push YH

    ld   r16, X+
    st   Y+, r16             ; byte 0
    ld   r16, X+
    st   Y+, r16             ; byte 1
    ld   r16, X+
    st   Y+, r16             ; byte 2
    ld   r16, X
    st   Y, r16              ; byte 3

    pop  YH
    pop  YL
    pop  XH
    pop  XL
    pop  r16
    ret
```

### 4.3 Programa de testes

Duas sub-rotinas auxiliares tornam os testes curtos:

- `t_carrega`: grava `r19:r18:r17:r16` na variável apontada por X.
- `t_confere`: compara a variável apontada por X com `r19:r18:r17:r16` e devolve **Z = 1** se for igual.

Cada teste grava seu número em `r24` antes de conferir. Se algo falhar, o programa para em `falha` com o número do teste em `r24`. Se tudo passar, para em `passou` com `r24 = 0xFF`.

```asm
;===============================================================
; AI2_1 - Parte 2: testes das sub-rotinas de 32 bits
;===============================================================
.INCLUDE <m328Pdef.inc>

.DSEG
.ORG SRAM_START
var_a: .BYTE 4           ; 0x0100 .. 0x0103
var_b: .BYTE 4           ; 0x0104 .. 0x0107

.CSEG
start:
    ;--- Teste 1: inc com propagação: 0x000000FF + 1 = 0x00000100 ---
    ldi  r24, 1
    ldi  XH, HIGH(var_a)
    ldi  XL, LOW(var_a)
    ldi  r16, 0xFF
    ldi  r17, 0x00
    ldi  r18, 0x00
    ldi  r19, 0x00
    rcall t_carrega
    rcall inc_32bits
    ldi  r16, 0x00           ; esperado: 0x00000100
    ldi  r17, 0x01
    ldi  r18, 0x00
    ldi  r19, 0x00
    rcall t_confere
    brne falha

    ;--- Teste 2: inc com overflow: 0xFFFFFFFF + 1 = 0x00000000 ---
    ldi  r24, 2
    ldi  r16, 0xFF
    ldi  r17, 0xFF
    ldi  r18, 0xFF
    ldi  r19, 0xFF
    rcall t_carrega          ; X ainda aponta var_a (inc_32bits preserva X)
    rcall inc_32bits
    ldi  r16, 0x00           ; esperado: 0x00000000
    ldi  r17, 0x00
    ldi  r18, 0x00
    ldi  r19, 0x00
    rcall t_confere
    brne falha

    ;--- Teste 3: dec com empréstimo: 0x00000100 - 1 = 0x000000FF ---
    ldi  r24, 3
    ldi  r16, 0x00
    ldi  r17, 0x01
    ldi  r18, 0x00
    ldi  r19, 0x00
    rcall t_carrega
    rcall dec_32bits
    ldi  r16, 0xFF           ; esperado: 0x000000FF
    ldi  r17, 0x00
    ldi  r18, 0x00
    ldi  r19, 0x00
    rcall t_confere
    brne falha

    ;--- Teste 4: dec com underflow: 0x00000000 - 1 = 0xFFFFFFFF ---
    ldi  r24, 4
    ldi  r16, 0x00
    ldi  r17, 0x00
    ldi  r18, 0x00
    ldi  r19, 0x00
    rcall t_carrega
    rcall dec_32bits
    ldi  r16, 0xFF           ; esperado: 0xFFFFFFFF
    ldi  r17, 0xFF
    ldi  r18, 0xFF
    ldi  r19, 0xFF
    rcall t_confere
    brne falha

    ;--- Teste 5: mov var_a -> var_b ---
    ldi  r24, 5
    ldi  XH, HIGH(var_b)     ; zera o destino antes
    ldi  XL, LOW(var_b)
    ldi  r16, 0x00
    ldi  r17, 0x00
    ldi  r18, 0x00
    ldi  r19, 0x00
    rcall t_carrega
    ldi  XH, HIGH(var_a)     ; origem = 0x12345678
    ldi  XL, LOW(var_a)
    ldi  r16, 0x78           ; byte menos significativo no menor endereço
    ldi  r17, 0x56
    ldi  r18, 0x34
    ldi  r19, 0x12
    rcall t_carrega
    ldi  YH, HIGH(var_b)
    ldi  YL, LOW(var_b)
    rcall mov_32bits
    rcall t_confere          ; origem (X restaurado) não pode mudar
    brne falha
    ldi  XH, HIGH(var_b)     ; destino deve ser igual à origem
    ldi  XL, LOW(var_b)
    rcall t_confere
    brne falha

passou:
    ldi  r24, 0xFF           ; todos os testes passaram
    rjmp passou
falha:
    rjmp falha               ; r24 = número do teste que falhou

;---------------------------------------------------------------
; Auxiliares dos testes
;---------------------------------------------------------------
; t_carrega: grava r19:r18:r17:r16 na variável apontada por X
t_carrega:
    push XL
    push XH
    st   X+, r16
    st   X+, r17
    st   X+, r18
    st   X,  r19
    pop  XH
    pop  XL
    ret

; t_confere: Z=1 se a variável apontada por X == r19:r18:r17:r16
t_confere:
    push XL
    push XH
    push r20
    ld   r20, X+
    cp   r20, r16
    brne conf_fim            ; já diferente: Z=0
    ld   r20, X+
    cp   r20, r17
    brne conf_fim
    ld   r20, X+
    cp   r20, r18
    brne conf_fim
    ld   r20, X
    cp   r20, r19            ; Z reflete o último byte
conf_fim:
    pop  r20                 ; pop e ret não alteram os flags
    pop  XH
    pop  XL
    ret

;---------------------------------------------------------------
; (cole aqui inc_32bits, dec_32bits e mov_32bits da seção 4.2)
;---------------------------------------------------------------
```

### 4.4 Resultados esperados

| Teste | Operação | Entrada (`var_a`) | Esperado |
|---|---|---|---|
| 1 | `inc_32bits` | `FF 00 00 00` | `00 01 00 00` |
| 2 | `inc_32bits` | `FF FF FF FF` | `00 00 00 00` |
| 3 | `dec_32bits` | `00 01 00 00` | `FF 00 00 00` |
| 4 | `dec_32bits` | `00 00 00 00` | `FF FF FF FF` |
| 5 | `mov_32bits` | `78 56 34 12` | `var_b = 78 56 34 12` e `var_a` inalterada |

*(Bytes na ordem de endereço crescente: a SRAM mostra o byte menos significativo primeiro.)*

### 4.5 Pontos de atenção

- Pegue o ponteiro **X** certo antes de chamar: `ldi XH, HIGH(var)` e `ldi XL, LOW(var)`.
- A ordem do `pop` é a inversa do `push`. O `SREG` foi empilhado por último, então é o primeiro a sair (via `r16`).
- O `inc_32bits` testa o **Z** (`brne`); o `dec_32bits` testa o **C** (`brcc`). Trocar um pelo outro dá resultado errado, porque `dec` não altera o Carry.
- Entre o `inc`/`subi` e o `brne`/`brcc`, só `st` e `X+` são permitidos: eles não alteram flags. Colocar outra instrução ali (por exemplo `adiw`) quebra o teste.
- Nos testes, `t_confere` só devolve o resultado em **Z**; a instrução logo após o `rcall` precisa ser o `brne`, sem nada que altere flags no meio.
- Os testes 2 e 4 cobrem os casos extremos (volta de 32 bits), os que mais costumam falhar.

---

## 5. Como simular e conferir

1. Crie o projeto e o `.asm` conforme `configurarIDE.md` (ATmega328P, simulador, `avrasm2`, 16 MHz).
2. Abra as janelas **SRAM Data Memory**, **I/O Memory (SFRs)** (registradores e `SREG`) e **Program Memory**.
3. **Parte 1:** rode até `fim:` e confira `0x0100`–`0x0113` na janela de SRAM com os valores da seção 3.5.
4. **Parte 2:** rode até `passou:` ou `falha:`. Em `passou`, `r24 = 0xFF`; em `falha`, `r24` indica o teste. Para ver passo a passo, entre nas sub-rotinas com *Step Into* e acompanhe `X` (`r27:r26`), `r16` e a pilha (`0x08FF` para baixo).
5. Teste a restauração do contexto: antes de um `rcall`, coloque valores conhecidos em `r16`, `X` e `Y` e confira que continuam iguais depois.

---

## 6. Checklist e erros comuns

- [ ] `.DSEG` / `.ORG SRAM_START` antes dos `.BYTE`; `.CSEG` para voltar ao código.
- [ ] `ldi` só em R16–R31.
- [ ] Ponteiro de 16 bits: `XH` (r27) recebe `HIGH`, `XL` (r26) recebe `LOW`.
- [ ] `ldd`/`std` só com Y ou Z, com `q` de 0 a 63.
- [ ] Pré-decremento: o ponteiro começa **uma posição além** do último elemento.
- [ ] Nenhuma instrução que altere flags entre o teste (`inc`/`subi`) e o desvio (`brne`/`brcc`).
- [ ] `push`/`pop` em ordem inversa; `ret` no fim de toda sub-rotina.
- [ ] Little-endian: byte menos significativo no **menor** endereço.
- [ ] As três sub-rotinas não contêm `rcall`/`call`.
- [ ] Cada sub-rotina tem teste, incluindo os extremos (`0xFFFFFFFF` e `0x00000000`).
- [ ] Documentou a interpretação de "de trás para frente" usada na Parte 1.