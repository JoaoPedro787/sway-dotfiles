# Arquitetura do Sistema de Temas Dinâmicos (Theme Suite)

Este documento descreve o funcionamento interno, a arquitetura e as convenções adotadas para o sistema unificado de gerenciamento e troca de temas visuais no ambiente Sway Suite (Kitty, Rofi, Swaylock, SwayNC e Waybar).

---

## 1. Visão Geral e Filosofia

O sistema foi desenhado com base em três princípios:
1. **Desacoplamento e Modularidade**: O script principal não possui código específico de componentes hardcodado. Toda a lógica de configuração e recarregamento reside em submódulos isolados (`scripts/components/*.sh`).
2. **Dupla Interface**: Cada módulo funciona tanto como uma biblioteca importável (`source`) quanto como um script executável autônomo de linha de comando (`CLI`).
3. **Recarregamento em Tempo Real (Hot-Reload)**: Aplicação instantânea das novas cores nas janelas e barras ativas através de sinais do sistema operacional e IPC, dispensando reinicialização de processos ou da sessão Sway.

---

## 2. Estrutura de Arquivos

```text
~/.dotfiles/
├── scripts/
│   ├── global-theme-selector.sh       # Orquestrador global interativo (Rofi) e CLI
│   └── components/                    # Módulos auxiliares específicos de cada app
│       ├── kitty.sh
│       ├── rofi.sh
│       ├── swaylock.sh
│       ├── swaync.sh
│       └── waybar.sh
│
├── kitty/.config/kitty/
│   ├── kitty.conf                     # Contém: include ./colors/current.conf
│   └── colors/
│       ├── current.conf               # Aponta para o tema ativo (include ./<tema>.conf)
│       ├── nord.conf
│       └── gruvbox.conf
│
├── rofi/.config/rofi/colors/
│   ├── current.rasi                   # Contém: @import "<tema>.rasi"
│   └── <tema>.rasi
│
├── swaylock/.config/swaylock/
│   ├── base                           # Configurações de comportamento e layout
│   ├── config                         # Arquivo final gerado (base + tema ativo)
│   └── colors/
│       ├── current.conf               # Nome do tema ativo
│       └── <tema>.conf
│
├── swaync/.config/swaync/colors/
│   ├── current.css                    # Contém: @import "<tema>.css";
│   └── <tema>.css
│
└── waybar/.config/waybar/colors/
    ├── current.css                    # Contém: @import "<tema>.css";
    └── <tema>.css
```

---

## 3. Como Acontece a "Mágica" (Mecanismos de Hot-Reload)

Cada software no ecossistema Wayland/Linux gerencia estilos de forma diferente. Abaixo está o detalhamento de como a atualização acontece em cada um:

| Componente | Como o tema é apontado | Como o reload dinâmico acontece |
| :--- | :--- | :--- |
| **Kitty** | `colors/current.conf` faz `include ./<tema>.conf` | Envia o sinal UNIX `SIGUSR1` para todos os processos kitty (`killall -SIGUSR1 kitty`). O Kitty relê sua configuração sem fechar terminais abertos. |
| **Waybar** | `colors/current.css` faz `@import "<tema>.css";` | Envia o sinal UNIX `SIGUSR2` (`killall -SIGUSR2 waybar`). O Waybar recarrega o stylesheet CSS instantaneamente mantendo o layout e módulos ativos. |
| **SwayNC** | `colors/current.css` faz `@import "<tema>.css";` | Invoca o cliente oficial IPC: `swaync-client -rs` (recarrega estilos) e `swaync-client -R` (recarrega configuração). |
| **Swaylock** | `cat base colors/<tema>.conf > config` | O Swaylock é um utilitário sob demanda (executado apenas no bloqueio). A concatenação da base com a paleta gera o `config` final que será lido no próximo lock. |
| **Rofi** | `colors/current.rasi` faz `@import "<tema>.rasi"` | O Rofi é invocado sob demanda via atalhos. Ao abrir qualquer launcher ou menu, o arquivo `current.rasi` já estará apontando para a paleta escolhida. |

### Fluxo de Execução do `global-theme-selector.sh`

1. **Importação**: Faz `source` dos módulos em `scripts/components/`.
2. **Detecção de Estado**: Lê `~/.config/.current_theme` (ou infere dos componentes) para destacar o tema atual no menu.
3. **Seleção**:
   - Se recebeu argumento via terminal (ex: `./global-theme-selector.sh gruvbox`), usa-o diretamente.
   - Se executado sem argumentos, abre o `rofi -dmenu` com a lista curada.
4. **Validação**: Confere se o tema solicitado pertence à lista autorizada.
5. **Aplicação Concorrente**: Executa a função `apply_<component>_theme "$chosen"` para cada aplicação, registrando eventuais falhas.
6. **Persistência & Feedback**: Grava o novo tema em `~/.config/.current_theme` e dispara uma notificação desktop via `notify-send`.

---

## 4. Guia: Como Adicionar uma Nova Cor / Tema

Para adicionar um novo tema (por exemplo, `catppuccin` ou `dracula`), siga os passos abaixo:

### Passo 1: Criar o arquivo de paleta em cada componente

Certifique-se de que o nome base do arquivo seja idêntico em todas as pastas (letras minúsculas, ex: `catppuccin`):

1. **Kitty** (`kitty/.config/kitty/colors/catppuccin.conf`):
   Defina foreground, background e as 16 cores (`color0` a `color15`).
2. **Rofi** (`rofi/.config/rofi/colors/catppuccin.rasi`):
   Defina as variáveis `@background`, `@background-alt`, `@foreground`, `@selected`, `@active` e `@urgent`.
3. **Swaylock** (`swaylock/.config/swaylock/colors/catppuccin.conf`):
   Defina as diretivas de cores hexadecimais (`color`, `inside-color`, `ring-color`, `key-hl-color`, `text-color`, etc.).
4. **SwayNC** (`swaync/.config/swaync/colors/catppuccin.css`):
   Defina as variáveis `@define-color cc-bg`, `@define-color noti-bg`, `@define-color noti-border-color`, etc.
5. **Waybar** (`waybar/.config/waybar/colors/catppuccin.css`):
   Defina as variáveis CSS `@define-color background`, `@define-color foreground`, etc.

### Passo 2: Registrar o tema na lista curada

Abra o arquivo [scripts/global-theme-selector.sh](file:///home/joaofedora/.dotfiles/scripts/global-theme-selector.sh) e adicione o identificador ao array `AVAILABLE_THEMES`:

```bash
AVAILABLE_THEMES=(
    "nord"
    "gruvbox"
    "catppuccin"   # <-- adicione o novo tema aqui
)
```

### Passo 3: Testar e Validar

Você pode testar isoladamente um único componente antes de rodar o seletor global:
```bash
# Teste unitário de um componente
./scripts/components/kitty.sh catppuccin
./scripts/components/waybar.sh catppuccin

# Teste global de todos os componentes
./scripts/global-theme-selector.sh catppuccin
```

---

## 5. Convenções para Agentes e Desenvolvedores

- **Nunca hardcode paths absolutos de usuário** (`/home/joaofedora`): utilize sempre referências relativas ao script via `BASH_SOURCE` ou a variável de ambiente `$HOME`.
- **Preserve a idempotência**: rodar o script com o tema que já está ativo deve reaplicar os arquivos e sinais com segurança e sem erros.
- **Tratamento de Erros**: Qualquer novo módulo adicionado em `scripts/components/` deve:
  - Validar a existência do diretório e arquivo de cores antes de escrever.
  - Retornar código de saída `0` para sucesso e `1` (com mensagem em `stderr`) para falha.
  - Implementar a função `get_<component>_theme` para permitir introspecção pelo orquestrador.
