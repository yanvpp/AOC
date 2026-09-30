# Pilha, Ponteiro da Pilha (SP) e Sub-rotinas — AVR ATmega328p

## 1. Motivação: por que sub-rotinas?

O exemplo "pisca-pisca" com código **duplicado** (ex.: dois blocos idênticos
de delay, um para ligar e outro para desligar o LED) é uma **solução ruim**:
repete trechos de código. A fatoração desse código em blocos reutilizáveis
motiva o uso de **sub-rotinas**.

## 2. Pilha (Stack)

- Utiliza **parte da SRAM**.
- Armazena **temporariamente** dados de variáveis locais e **endereços de
  retorno** de sub-rotinas/interrupções.

## 3. Ponteiro de Pilha (Stack Pointer — SP)

- **Pós-decrementado** quando um dado é **adicionado** na pilha (`PUSH`).
- **Pré-incrementado** quando um dado é **retirado** da pilha (`POP`).
- Deve ser inicializado para o **último endereço da RAM**.
- No **ATmega328p**, esse endereço é **`0x08FF`**, e o SP **já é carregado
  automaticamente durante o reset** — não precisa inicializar manualmente.
- ⚠️ Alguns outros MCUs da família ATmega **precisam** ter o SP inicializado
  manualmente pelo programador (nem todos fazem isso automaticamente).

### Mapa de memória do ATmega328p (contexto)

| Região | Faixa |
|---|---|
| 32 Registradores de uso geral | `0x0000`–`0x001F` |
| 64 Registradores de I/O | `0x0020`–`0x005F` |
| 160 Registradores de I/O estendidos | `0x0060`–`0x00FF` |
| SRAM interna (2 KBytes) | `0x0100`–`0x08FF` |

A pilha cresce **de cima para baixo** dentro da SRAM, começando em `0x08FF`
(topo/fim da RAM) e descendo conforme dados são empilhados.

## 4. Instruções que manipulam a pilha

| Instrução | Efeito no SP | Descrição |
|---|---|---|
| `PUSH` | Decrementa em **1** | Coloca um dado (1 byte) na pilha |
| `CALL` / `ICALL` / `RCALL` | Decrementa em **2** | Coloca o endereço de retorno (2 bytes) na pilha ao chamar sub-rotina/interrupção |
| `POP` | Incrementa em **1** | Retira o dado do topo da pilha (1 byte) |
| `RET` / `RETI` | Incrementa em **2** | Retira o endereço de retorno (2 bytes) da pilha, ao voltar de sub-rotina/interrupção |

### Exemplo `push`/`pop`

```asm
ldi r16, 0x01   ; carrega r16 com 0x01
ldi r17, 0x02   ; carrega r17 com 0x02

push r16        ; salva r16 na pilha
push r17        ; salva r17 na pilha

pop r17         ; restaura r17 da pilha
pop r16         ; restaura r16 da pilha
```
> Atenção à **ordem LIFO** (último a entrar, primeiro a sair): o que foi
> empilhado por último (`r17`) deve ser desempilhado primeiro.

## 5. Sub-rotinas

O mecanismo de sub-rotina permite:
- Organizar o código em **blocos modulares**, inclusive bibliotecas.
- Continuar a execução de onde foi chamada, sem precisar de rótulos manuais
  ("retorno automático").
- **Reutilização de código**.

### Exemplo mínimo

```asm
main:
    rcall sub_rotina
    rjmp main

sub_rotina:
    ; executa sub-rotina
    ret
```

### Rótulo vs. Sub-rotina

| | Rótulo | Sub-rotina |
|---|---|---|
| Uso | Identifica um ponto na memória de programa | Começa com um rótulo e **termina com `ret`** |
| Como é chamado | Instruções de desvio condicional/incondicional (`rjmp`, `brne`, ...) | `rcall`, `icall`, `call` |
| Retorno | **Não tem** mecanismo de retorno | **Retorna de onde foi chamada** |
| Pilha | Não usa | **Usa a pilha** para guardar o endereço de retorno |

```asm
rótulo:
    ; trecho de programa a ser executado a partir do rótulo
    ; continua sequencialmente até encontrar outro desvio

sub_rotina:
    ; pode saltar para rótulos quantas vezes quiser
    ; pode executar outras sub-rotinas (rcall, icall, call)
    ; desde que a última instrução seja ret
    ret
```

## 6. Exemplo prático: sub-rotina de delay (pisca-pisca refatorado)

```asm
;DEFINIÇÕES
.equ LED = PB5    ; LED é o substituto de PB5

start:
    sbi DDRB, LED   ; configura pino LED como saída

main:
    sbi PORTB, LED  ; coloca o pino PB5 em 5V
    rcall delay     ; chama a sub-rotina de atraso
    cbi PORTB, LED  ; coloca o pino PB5 em 0V
    rcall delay     ; chama a sub-rotina de atraso
    rjmp main       ; volta para main

delay:              ; atraso de aprox. 200ms
    ldi R19, 16
loop:
    dec R17         ; decrementa R17, começa com 0x00
    brne loop       ; enquanto R17 > 0 fica decrementando R17
    dec R18         ; decrementa R18, começa com 0x00
    brne loop       ; enquanto R18 > 0 volta a decrementar R18
    dec R19         ; decrementa R19
    brne loop       ; enquanto R19 > 0 volta ao loop
    ret
```

> Repare: uma única sub-rotina `delay` é chamada **duas vezes** (ligar e
> desligar o LED), eliminando a duplicação do código original.

## 7. Salvando o contexto (boas práticas)

**Problema:** a sub-rotina `delay` acima **modifica** `R17`, `R18`, `R19` (e
implicitamente o `SREG`, via as flags alteradas pelos `dec`). Se o código que
chamou a sub-rotina estava usando esses registradores para outra coisa, os
valores são **perdidos/corrompidos**.

**Solução: salvar o contexto** — empilhar no início da sub-rotina todos os
registradores que serão modificados (inclusive `SREG`, via um registrador
auxiliar) e desempilhá-los **na ordem inversa** antes do `ret`:

```asm
delay:              ; atraso de aprox. 200ms
    push r17         ; salva r17,
    push r18         ; ... r18,
    push r19         ; ... r19,
    in   r17, SREG   ;
    push r17         ; ... e SREG na pilha

    ; --- executa a sub-rotina ---
    clr r17
    clr r18
    ldi R19, 16
loop:
    dec R17
    brne loop
    dec R18
    brne loop
    dec R19
    brne loop

    pop r17
    out SREG, r17    ; restaura SREG,
    pop r19          ; ... r19,
    pop r18          ; ... r18,
    pop r17          ; ... r17 da pilha

    ret
```

⚠️ **Ordem importa** (pilha é LIFO): o que foi empilhado por último (`SREG`,
via `r17`) é o primeiro a ser restaurado.

## 8. Passando parâmetros via registrador

Em vez de fixar o tempo de delay direto no código, o valor de `R19` pode ser
**carregado antes da chamada** pelo código que invoca a sub-rotina, tornando o
delay **programável**:

```asm
;--------------------------------------------------------------
; SUB-ROTINA DE ATRASO Programável
; Depende do valor de R19 carregado antes da chamada.
; Ex.: R19 = 16  --> 200ms
;      R19 = 80  --> 1s
;--------------------------------------------------------------
delay:
    push r17       ; salva r17,
    push r18       ; ... r18,
    in   r17, SREG
    push r17       ; ... e SREG na pilha
                    ; (R19 NÃO é salvo — ele é o parâmetro de entrada!)

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

> Observação-chave: `R19` **não é empilhado/restaurado** nessa versão, porque
> ele funciona como **parâmetro de entrada** vindo de quem chamou a
> sub-rotina — se fosse salvo, seu valor de entrada seria perdido na
> restauração.

## 9. Pontos-chave para prova

- **`PUSH`/`POP`** mexem 1 byte por vez; **`CALL`/`RCALL`/`ICALL`/`RET`/`RETI`**
  mexem 2 bytes (endereço de retorno de 16 bits).
- Empilhar é **pós-decremento**; desempilhar é **pré-incremento**.
- SP do ATmega328p já vem inicializado em `0x08FF` no reset (nem todo MCU
  AVR faz isso automaticamente).
- Toda sub-rotina precisa terminar em **`ret`** para o retorno funcionar.
- **Salvar contexto** = empilhar registradores (e SREG) que a sub-rotina vai
  alterar, e desempilhar na ordem inversa antes do `ret`.
- Um registrador usado para **passar parâmetro** (como `R19` no exemplo de
  delay programável) **não deve** ser salvo/restaurado pela sub-rotina.