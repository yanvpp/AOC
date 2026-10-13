# Assembly AVR: Registradores de I/O (ATmega328p)

## 1. Conceito: o que são registradores de I/O

- Para processar dados, basta trazê-los aos registradores da CPU (R0 a R31) e usar instruções lógicas e aritméticas.
- Para **interagir com o mundo externo** e **controlar periféricos**, usa-se os registradores de I/O.
- Funcionam como o **painel de controle e de estado** do microcontrolador (analogia do slide: cockpit de um Boeing 757).
- A disponibilidade depende do hardware da família/dispositivo.
- Registradores marcados como **reservados não devem ser escritos**.

---

## 2. Mapa de memória do ATmega328p

| Memória | Largura | Tamanho / endereços |
|---|---|---|
| Program Memory (Flash) | 16 bits | 16K x 16 (32 KB), `0x0000` a `0x3FFF` |
| Data Memory | 8 bits | `0x0000` a `0x08FF` |
| EEPROM | 8 bits | 1 KB, `0x000` a `0x3FF` |

- A Flash tem a seção de aplicação (Application Flash) e a seção de boot (Boot Flash, 256 a 2048 words).

### Data Memory (endereços SRAM x endereços de I/O)

| Região | Endereço SRAM | Endereço I/O |
|---|---|---|
| 32 registradores de uso geral (R0 a R31) | `0x0000` a `0x001F` | n/a |
| **64 registradores de I/O** | `0x0020` a `0x005F` | `0x00` a `0x3F` |
| 160 registradores de I/O estendidos | `0x0060` a `0x00FF` | n/a |
| SRAM interna (2 KB) | `0x0100` a `0x08FF` | n/a |

**Regra principal:** endereço SRAM = endereço de I/O + `0x20`.

- Os 64 registradores de I/O são acessados com `in`/`out` (endereço de I/O).
- Os registradores da **área estendida** são acessados como SRAM, com `lds`/`sts`.

---

## 3. Registradores de I/O importantes (slide 8, "válidos")

Formato: endereço de I/O (endereço SRAM).

### Portas de E/S

| Endereço | Nome | Função |
|---|---|---|
| `0x03` (`0x23`) | **PINB** | leitura dos pinos da porta B |
| `0x04` (`0x24`) | **DDRB** | direção da porta B |
| `0x05` (`0x25`) | **PORTB** | saída/pull-up da porta B |
| `0x06` (`0x26`) | **PINC** | leitura dos pinos da porta C |
| `0x07` (`0x27`) | **DDRC** | direção da porta C |
| `0x08` (`0x28`) | **PORTC** | saída/pull-up da porta C |
| `0x09` (`0x29`) | **PIND** | leitura dos pinos da porta D |
| `0x0A` (`0x2A`) | **DDRD** | direção da porta D |
| `0x0B` (`0x2B`) | **PORTD** | saída/pull-up da porta D |

- Bits de cada registrador: PINB0 a PINB7, DDB0 a DDB7, PORTB0 a PORTB7 (mesma ideia para C e D).
- **A porta C não tem o bit 7**: PINC, DDRC e PORTC só têm bits 0 a 6.

### Outros registradores que aparecem nos slides

| Endereço | Nome | Observação |
|---|---|---|
| `0x3F` (`0x5F`) | **SREG** | status: I, T, H, S, V, N, Z, C |
| `0x3E` (`0x5E`) | SPH | ponteiro de pilha (parte alta) |
| `0x3D` (`0x5D`) | SPL | ponteiro de pilha (parte baixa) |
| `0x1E` (`0x3E`) | **GPIOR0** | registrador de uso geral de I/O (usado nos exemplos) |
| `0x2A` (`0x4A`) | GPIOR1 | uso geral |
| `0x2B` (`0x4B`) | GPIOR2 | uso geral |
| `0x2C` (`0x4C`) | SPCR | controle da SPI |
| `0x2D` (`0x4D`) | SPSR | status da SPI |
| `0x2E` (`0x4E`) | SPDR | dado da SPI |
| `0x25` (`0x45`) | TCCR0B | controle do Timer/Counter0 |
| `0x24` (`0x44`) | TCCR0A | controle do Timer/Counter0 |
| `0x26` (`0x46`) | TCNT0 | contador do Timer0 |
| `0x27` (`0x47`) | OCR0A | comparação A do Timer0 |
| `0x28` (`0x48`) | OCR0B | comparação B do Timer0 |
| `0x15` (`0x35`) | TIFR0 | flags de interrupção do Timer0 |
| `0x16` (`0x36`) | TIFR1 | flags de interrupção do Timer1 |
| `0x17` (`0x37`) | TIFR2 | flags de interrupção do Timer2 |
| `0x1B` (`0x3B`) | PCIFR | flags de interrupção por mudança de pino |
| `0x1C` (`0x3C`) | EIFR | flags de interrupção externa |
| `0x1D` (`0x3D`) | EIMSK | máscara de interrupção externa |
| `0x1F` (`0x3F`) | EECR | controle da EEPROM |
| `0x20` (`0x40`) | EEDR | dado da EEPROM |
| `0x21` (`0x41`) | EEARL | endereço da EEPROM (byte baixo) |
| `0x22` (`0x42`) | EEARH | endereço da EEPROM (byte alto) |
| `0x30` (`0x50`) | ACSR | controle do comparador analógico |

> Os endereços de I/O acima são os mesmos da tabela do slide 8. Para a prova, os mais cobrados costumam ser PINx, DDRx, PORTx e GPIOR0.

---

## 4. Instruções para a região de I/O

| Instrução | Descrição |
|---|---|
| `in` | lê um registrador de I/O |
| `out` | escreve em um registrador de I/O |
| `cbi` | zera um bit de um registrador de I/O |
| `sbi` | seta um bit de um registrador de I/O |
| `sbic` | salta se o bit do registrador de I/O é **zero** |
| `sbis` | salta se o bit do registrador de I/O é **um** |

### 4.1 Movimentação de dados: `in` e `out`

- Endereçamento de **I/O direto**.
- A leitura e a escrita são **intermediadas pelos 32 registradores de uso geral** (não dá para ir de I/O direto para I/O).

**Sintaxe:**

```asm
in  Rd, A      ; Rd <- A
out A, Rr      ; A  <- Rr
```

**Onde:** `0 <= r/d <= 31` e `0 <= A <= 63`.

**Exemplo:**

```asm
inc R0          ; Incrementa R0
out 0x1E, R0    ; Escreve no GPIOR0 (0x1E) o R0
in  R1, 0x1E    ; Lê do GPIOR0 (0x1E) para o R1
```

### 4.2 Instruções bit a bit: `sbi` e `cbi`

- Setam ou zeram **um bit diretamente**.
- Funcionam **somente nos registradores de I/O "baixos"**, ou seja, os primeiros 32 (`0x00` a `0x1F`).

**Sintaxe:**

```asm
cbi A, b       ; I/O(A, b) <- 0
sbi A, b       ; I/O(A, b) <- 1
```

**Onde:** `0 <= A <= 31` e `0 <= b <= 7`.

**Exemplo:**

```asm
sbi 0x04, 5    ; Seta o bit 5 do registrador DDRB (0x04)
cbi 0x04, 5    ; Reseta o bit 5 do registrador DDRB (0x04)
```

### 4.3 Desvio baseado em bit: `sbic` e `sbis`

- Testam **um único bit** de um registrador de I/O e **saltam a próxima instrução** conforme o estado do bit:
  - `sbic`: salta se o bit for **zero** (clear)
  - `sbis`: salta se o bit for **um** (set)
- Funcionam **somente nos registradores de I/O "baixos"** (os primeiros 32).
- **Não saltam para um rótulo.** Só pulam a instrução seguinte. Quem desvia para o rótulo é o `rjmp`.

**Sintaxe:**

```asm
sbic A, b
sbis A, b
```

**Onde:** `0 <= A <= 31` e `0 <= b <= 7`.

**Exemplo (espera por borda no bit 7 de PIND):**

```asm
waitUM:
    sbis 0x09, 7    ; Salta a próxima instrução se o bit 7 do PIND (0x09) é UM
    rjmp waitUM     ; Bit 7 do PIND não setado: volta para waitUM
waitZERO:
    sbic 0x09, 7    ; Salta a próxima instrução se o mesmo bit é ZERO
    rjmp waitZERO   ; Senão, aguarda
    nop             ; Continua o programa ("não faz nada")
```

### Resumo dos limites dos operandos

| Instrução | Registrador de I/O (A) | Bit (b) | Registrador geral (r/d) |
|---|---|---|---|
| `in` / `out` | 0 a 63 | n/a | 0 a 31 |
| `sbi` / `cbi` | 0 a 31 | 0 a 7 | n/a |
| `sbic` / `sbis` | 0 a 31 | 0 a 7 | n/a |

---

## 5. Diretiva `.INCLUDE`

- Informa ao montador para **incluir um arquivo durante a montagem**.
- Pode ser usada para incluir o arquivo com as **definições dos nomes dos registradores** (`m328Pdef.inc`).
- Não é restrita a uma extensão (serve para `.inc`, `.asm` etc.).

**Sintaxe:**

```asm
.INCLUDE "filename"    ; procura primeiro no diretório local
.INCLUDE <filename>    ; não procura primeiro no diretório local
```

- No formato com aspas (`" "`), o montador **primeiro procura no diretório local**. No formato com `< >`, não.

### Exemplo: antes e depois do `.INCLUDE`

**Sem `.INCLUDE`** (endereços numéricos):

```asm
start:
    inc R0
    out 0x1E, R0       ; GPIOR0
    in  R1, 0x1E

    sbi 0x04, 5        ; DDRB, bit 5
    cbi 0x04, 5

waitUM:
    sbis 0x09, 7       ; PIND, bit 7
    rjmp waitUM
waitZERO:
    sbic 0x09, 7
    rjmp waitZERO
    nop

    rjmp start
```

**Com `.INCLUDE`** (nomes simbólicos):

```asm
.INCLUDE <m328Pdef.inc>

start:
    inc R0
    out GPIOR0, R0
    in  R1, GPIOR0

    sbi DDRB, 5
    cbi DDRB, 5

waitUM:
    sbis PIND, 7
    rjmp waitUM
waitZERO:
    sbic PIND, 7
    rjmp waitZERO
    nop

    rjmp start
```

---

## 6. Pontos de atenção para a prova

- `sbic`/`sbis` **pulam a próxima instrução**, não saltam para rótulo.
- `sbic` salta se o bit é **0**; `sbis` salta se o bit é **1**.
- `sbi`, `cbi`, `sbic` e `sbis` só alcançam I/O `0x00` a `0x1F`; `in` e `out` alcançam `0x00` a `0x3F`.
- `in`/`out` usam **endereço de I/O**; `lds`/`sts` usam **endereço SRAM** (I/O + `0x20`) e são necessários para a área estendida.
- Não existe cópia direta de I/O para I/O: tudo passa por um registrador R0 a R31.
- Registradores **reservados** não devem ser escritos.
- A porta C não tem o bit 7.
- O nome do registrador de direção é **DDRx** (ex.: DDRC); **DDCn** são os nomes dos bits (ex.: DDC0).
- Exemplos dos slides: `GPIOR0 = 0x1E`, `DDRB = 0x04`, `PIND = 0x09`.