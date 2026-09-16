# Modos de Endereçamento — Memória de Dados (SRAM) — AVR/ATmega328p

Resumo dos modos de endereçamento usados para acessar a memória de dados (SRAM)
no núcleo AVR, com sintaxe, semântica e exemplos de código.

## Contexto

A memória de dados do ATmega328p é organizada de forma linear e inclui:

| Região                       | Faixa de endereços |
|-------------------------------|---------------------|
| 32 Registradores de uso geral | `0x0000` – `0x001F` |
| 64 Registradores de I/O       | `0x0020` – `0x005F` |
| 160 Registradores de I/O estendidos | `0x0060` – `0x00FF` |
| SRAM interna (2 KBytes)       | `0x0100` – `0x08FF` |

Os registradores **R26–R31** funcionam como três ponteiros de 16 bits para
endereçamento indireto:

| Ponteiro | Byte baixo | Byte alto |
|----------|------------|-----------|
| X        | R26 (XL)   | R27 (XH)  |
| Y        | R28 (YL)   | R29 (YH)  |
| Z        | R30 (ZL)   | R31 (ZH)  |

---

## 1. Direto

O endereço da posição de memória é fornecido diretamente na instrução (codificado
como parte do opcode).

**Sintaxe**

```
lds Rd, k     ; Rd ← (k)
sts k, Rr     ; (k) ← Rr
```

- `0 ≤ r/d ≤ 31`
- `0 ≤ k ≤ 65535`

**Exemplo — `C = A + B`**

```asm
.DSEG
.ORG 0x0100
    A: .BYTE 1
    B: .BYTE 1
    C: .BYTE 1

.CSEG
start:
    lds  R16, A
    lds  R17, B
    add  R16, R17
    sts  C, R16
    rjmp start
```

---

## 2. Indireto (sem incrementar)

O endereço é o conteúdo de um dos ponteiros X, Y ou Z. O ponteiro **não é
alterado** pela instrução.

**Sintaxe**

```
ld Rd, index    ; Rd ← (index)
st index, Rr    ; (index) ← Rr
```

- `0 ≤ r/d ≤ 31`
- `index = X, Y ou Z`

**Exemplo — `C = A + B`**

```asm
.DSEG
.ORG 0x0100
    A: .BYTE 1
    B: .BYTE 1
    C: .BYTE 1

.CSEG
start:
    ldi  R27, HIGH(A)   ; XH
    ldi  R26, LOW(A)    ; XL
    ld   R16, X         ; R16 <- A

    ldi  R27, HIGH(B)
    ldi  R26, LOW(B)
    ld   R17, X         ; R17 <- B

    add  R16, R17

    ldi  R27, HIGH(C)
    ldi  R26, LOW(C)
    st   X, R16         ; C <- R16

    rjmp start
```

> Como o ponteiro não muda sozinho, é preciso recarregá-lo (LOW/HIGH) a cada
> variável — por isso esse modo é mais verboso quando os dados não estão em
> loop.

---

## 3. Indireto com pós-incremento

O conteúdo é acessado no endereço atual do ponteiro e, **em seguida**, o
ponteiro é incrementado em 1. A leitura/escrita e o incremento acontecem
dentro da mesma instrução — não é preciso salvar o valor "antes" do ponteiro
mudar, pois o acesso já ocorre primeiro.

**Sintaxe**

```
ld Rd, index+   ; Rd ← (index)
                ; index ← index + 1

st index+, Rr   ; (index) ← Rr
                ; index ← index + 1
```

- `0 ≤ r/d ≤ 31`
- `index = X, Y ou Z`

**Exemplo — `C = A + B`** (aproveitando que A, B, C são sequenciais na SRAM)

```asm
.DSEG
.ORG 0x0100
    A: .BYTE 1
    B: .BYTE 1
    C: .BYTE 1

.CSEG
start:
    ldi  R27, HIGH(A)
    ldi  R26, LOW(A)

    ld   R16, X+        ; R16 <- A ; X passa a apontar B
    ld   R17, X+        ; R17 <- B ; X passa a apontar C
    add  R16, R17
    st   X, R16         ; C <- R16 (X já aponta para C)

    rjmp start
```

> Existe também o modo **indireto com pré-decremento** (`ld Rd, -index` /
> `st -index, Rr`), simétrico a este: o ponteiro é decrementado **antes** do
> acesso.

---

## 4. Indireto com deslocamento

O endereço acessado é o **conteúdo do ponteiro (Y ou Z) + um deslocamento `q`**
fixo, codificado na própria instrução. **O ponteiro não é alterado.** Útil
para acessar campos próximos a um endereço base sem precisar mover o ponteiro
a cada acesso.

**Sintaxe**

```
ldd Rd, index+q   ; Rd ← (index + q)
std index+q, Rr   ; (index + q) ← Rr
```

- `0 ≤ r/d ≤ 31`
- `index = Y ou Z` (**não é possível usar X neste modo**)
- `0 ≤ q ≤ 63`

**Exemplo — `C = A + B`**

```asm
.DSEG
.ORG 0x0100
    A: .BYTE 1
    B: .BYTE 1
    C: .BYTE 1

.CSEG
start:
    ldi  R29, HIGH(A)   ; YH
    ldi  R28, LOW(A)    ; YL  -> Y fica apontando para A o tempo todo

    ldd  R16, Y+0       ; R16 <- A
    ldd  R17, Y+1       ; R17 <- B (endereço de A + 1)
    add  R16, R17
    std  Y+2, R16       ; C <- R16 (endereço de A + 2)

    rjmp start
```

---

## Resumo comparativo

| Modo                          | Ponteiro muda? | Registradores usáveis | Observação |
|--------------------------------|-----------------|-------------------------|------------|
| Direto (`lds`/`sts`)           | —               | R0–R31                  | Endereço fixo no opcode; até 65535 |
| Indireto (`ld`/`st`)           | Não             | X, Y ou Z                | Precisa recarregar o ponteiro para cada endereço |
| Indireto pós-incremento (`ld Rd, X+`) | Sim (+1 após acesso) | X, Y ou Z | Ideal para percorrer dados sequenciais |
| Indireto pré-decremento (`ld Rd, -X`) | Sim (−1 antes do acesso) | X, Y ou Z | Simétrico ao pós-incremento |
| Indireto com deslocamento (`ldd`/`std`) | Não | **Y ou Z apenas** | Acesso a `index + q`, `0 ≤ q ≤ 63`, sem mover o ponteiro |