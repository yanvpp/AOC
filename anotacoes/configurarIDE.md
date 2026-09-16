# Guia para configuração da IDE

## Setup Ferramentas AVR para Assembly

### Baixar e instalar os seguintes arquivos para o SO desejado:
1. IDE: Abra o link MPLAB X v6.15 (Windows, Linux, macOS). Baixe para o seu SO e instale.
1. Compilador: MPLAB XC8 (Windows, Linux, macOS). Baixe a versão v2.05 para o seu SO e instale.
1. Anotar os caminhos das instalações

### Configurar (adicionar o montador em avrasm2):
1. Abrir o MPLAB X IDE
1. Abra Tools -> Options. Abrirá a seguinte janela.
1. Selecione Embedded -> Build Tools -> Add ...
1. Adicione o caminho da instalação do compilador (anotado no passo anterior) em "Base Directory". Exemplo: /opt/microchip/xc8/v2.05/avr/bin
1. Em "Version" selecione "avrasm2" clique em OK e OK novamente.

> Opcionalmente: Crie um projeto, adicione um arquivo *.asm e simule conforme o guia abaixo para verificar se está tudo correto.

## Criando o Projeto

1. Abra o MPLAB X IDE
1. File -> New Project
1. Configure:
    - Categories: Microchip Embedded
    - Projects: Standalon Project
    - Clique em `Next`
1. Configure:
    - Device: ATmega328P (digite)
    - Tool: Simulator
    - Clique em `Next`
1. Selecione avrasm2
1. Clique em `Next`
1. Defina o nome do projeto e a localização
1. Clique em `Finish`

## Adicionando um arquivo *.ASM

1. Clique com o botão direito em "Source Files"
1. New -> main.asm ...
1. Defina o nome do arquivo (mantenha Extension como ASM)
1. Clique em Finish
1. Será criado um exemplo abaixo:

```asm
start:
  inc r16
  rjmp start
```

## Configurando o simulador

1. Selecione as propriedades do projeto (botão direito sobre o nome do projeto) no painel Projects
1. No menu Categories selecione Simulator
1. Configure o oscilador para 16MHz:
    - Instruction Frequency (Fcyc): 16
    - Frequency in: MHz
1. Selecione no menu Option Categories: Reset
1. Configure Reset Type: MCLR
1. Pressionar `Apply` e `OK`

## Simulando

1. No menu Window –> Target Memories Views selecione as seguintes janelas Program Memory, SRAM Data Memory e I/O Memory (SFRs).
1. Configure o posicionamento das janelas. [Sugestão](https://docente.ifsc.edu.br/roberto.matos/mic_public/figs/mplab_windows.png).
1. Monte o programa para Debug: Debug -> Discrete Debugger Operation -> Build for Debugging Main Project
1. Simule: Menu Debug –> Debug Main Project