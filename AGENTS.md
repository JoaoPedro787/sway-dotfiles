# Arquitetura do Sistema de Temas e Bordas Dinâmicos (Theme & Border Suite)

Este documento descreve o funcionamento interno, a arquitetura e as convenções adotadas para os sistemas unificados de gerenciamento e troca de paletas visuais e estilos de bordas/cantos arredondados no ambiente Sway Suite (SwayFX, Kitty, Rofi, Swaylock, SwayNC e Waybar).

---

## 1. Visão Geral e Filosofia

O ecossistema divide-se em dois eixos orquestradores complementares:
1. **Theme Suite (`global-theme-selector.sh`)**: Gerenciamento dinâmico da paleta cromática global (Nord, Gruvbox, etc.).
2. **Border Suite (`global-border-selector.sh`)**: Gerenciamento de raio de curvatura (*corner radius*) e espessura/visibilidade de bordas nas janelas e componentes de interface.

Ambos foram desenhados com base em quatro princípios:
1. **Desacoplamento e Modularidade**: Os scripts principais não contêm código de apps hardcodado. A lógica reside em submódulos isolados (`scripts/components/*.sh` para cores e `scripts/components/borders/*.sh` para bordas).
2. **Dupla Interface**: Cada módulo funciona tanto como biblioteca importável (`source`) quanto como ferramenta executável autônoma de linha de comando (`CLI`).
3. **Recarregamento em Tempo Real (Hot-Reload)**: Aplicação instantânea sem reiniciar a sessão Sway ou fechar janelas ativas.
4. **Sincronização Integrada**: Quando uma borda colorida está ativa (`*-colored`), a troca de tema no seletor de cores atualiza a cor da borda instantaneamente para refletir o tom de destaque do novo tema.

---

## 2. Estrutura de Arquivos

```text
~/.dotfiles/
├── scripts/
│   ├── global-theme-selector.sh        # Orquestrador global de cores (Rofi & CLI)
│   ├── global-border-selector.sh       # Orquestrador global de bordas & raio (Rofi & CLI)
│   │
│   └── components/                     # Módulos auxiliares de temas de cores
│       ├── kitty.sh
│       ├── rofi.sh
│       ├── sway.sh
│       ├── swaylock.sh
│       ├── swaync.sh
│       ├── waybar.sh
│       │
│       └── borders/                    # Módulos auxiliares de bordas e corner radius
│           ├── rofi.sh
│           ├── sway.sh
│           ├── swaync.sh
│           └── waybar.sh
│
├── kitty/.config/kitty/
│   ├── kitty.conf                      # Contém: include ./colors/current.conf
│   └── colors/
│       ├── current.conf                # Aponta para o tema ativo (include ./<tema>.conf)
│       ├── nord.conf
│       └── gruvbox.conf
│
├── rofi/.config/rofi/
│   ├── config.rasi                     # Contém imports de ./colors/current.rasi e ./borders/current.rasi
│   ├── colors/
│   │   ├── current.rasi                # Contém: @import "<tema>.rasi"
│   │   └── <tema>.rasi
│   └── borders/
│       ├── current.rasi                # Contém: @import "<preset>.rasi"
│       └── <preset>.rasi
│
├── sway/.config/sway/
│   ├── config                          # Contém: include ~/.config/sway/borders/current.conf
│   ├── colors/
│   │   ├── current.conf                # Contém: include ./<tema>.conf (client.focused, etc.)
│   │   └── <tema>.conf
│   └── borders/
│       ├── current.conf                # Contém: include ./<preset>.conf
│       └── <preset>.conf
│
├── swaylock/.config/swaylock/
│   ├── base                            # Configurações de layout
│   ├── config                          # Arquivo final gerado (base + tema ativo)
│   └── colors/
│       ├── current.conf                # Nome do tema ativo
│       └── <tema>.conf
│
├── swaync/.config/swaync/
│   ├── style.css                       # Contém imports de colors/current.css e borders/current.css
│   ├── colors/
│   │   ├── current.css                 # Contém: @import "<tema>.css";
│   │   └── <tema>.css
│   └── borders/
│       ├── current.css                 # Contém: @import "<preset>.css";
│       └── <preset>.css
│
└── waybar/.config/waybar/
    ├── style.css                       # Contém imports de colors/current.css e borders/current.css
    ├── colors/
    │   ├── current.css                 # Contém: @import "<tema>.css";
    │   └── <tema>.css
    └── borders/
        ├── current.css                 # Contém: @import "<preset>.css";
        └── <preset>.css
```

---

## 3. Presets Padronizados de Borda (Border Suite)

O sistema de bordas define 6 presets padronizados, combinando 3 níveis de curvatura de cantos com estilo visível (colorido) ou invisível (sem borda):

| Identificador | Nível de Raio | Borda / Contorno | Descrição |
| :--- | :--- | :--- | :--- |
| `sharp-none` | **0px** (Reto / Quadrado) | 0px / Nenhuma | Cantos vivos, janelas e caixas sem linha perimetral |
| `sharp-colored` | **0px** (Reto / Quadrado) | 1px Sólida | Cantos vivos com borda sólida na cor de destaque do tema ativo |
| `rounded-none` | **10px** (Moderado) | 0px / Nenhuma | Cantos arredondados suaves sem linha perimetral |
| `rounded-colored` | **10px** (Moderado) | 1px Sólida | Cantos arredondados com borda colorida ativa |
| `extra-none` | **18px** (Extra Redondo) | 0px / Nenhuma | Curvatura pronunciada moderna sem moldura |
| `extra-colored` | **18px** (Extra Redondo) | 1px Sólida | Curvatura pronunciada com moldura na cor de destaque |

---

## 4. Mecanismos de Hot-Reload

| Componente | Sistema de Cores | Sistema de Bordas e Raio |
| :--- | :--- | :--- |
| **Sway / SwayFX** | `sway/.config/sway/colors/current.conf` é recarregado via `swaymsg reload`. Atualiza as classes `client.focused`, `client.unfocused`, etc. | `sway/.config/sway/borders/current.conf` define `corner_radius`, `default_border` e `default_floating_border`. Executa `swaymsg reload` e sincroniza janelas abertas via `swaymsg "[app_id=.*] border ..."` instantaneamente. |
| **Waybar** | `killall -SIGUSR2 waybar`. Recarrega o CSS instantaneamente. | `killall -SIGUSR2 waybar`. Recarrega o arquivo `borders/current.css` sobrepondo as regras dos módulos. |
| **SwayNC** | `swaync-client -rs` e `swaync-client -R`. | `swaync-client -rs` e `swaync-client -R`. Atualiza `border-radius` e `box-shadow` perimetral dos cards e painel. |
| **Kitty** | `killall -SIGUSR1 kitty`. | Gerenciado automaticamente pela moldura e cantos do SwayFX. |
| **Rofi** | Sob demanda ao abrir menus. | Sob demanda ao abrir menus (`@import "borders/current.rasi"` em `config.rasi` e launchers). |
| **Swaylock** | Concatenação prévia (`base + color > config`). | Sob demanda ao bloquear a sessão. |

---

## 5. Guia: Como Adicionar um Novo Tema ou Preset

### Adicionar uma Nova Paleta de Cores (Theme Suite)
1. Crie o arquivo `<novo_tema>.<ext>` em:
   - `kitty/.config/kitty/colors/<novo_tema>.conf`
   - `rofi/.config/rofi/colors/<novo_tema>.rasi`
   - `sway/.config/sway/colors/<novo_tema>.conf`
   - `swaylock/.config/swaylock/colors/<novo_tema>.conf`
   - `swaync/.config/swaync/colors/<novo_tema>.css`
   - `waybar/.config/waybar/colors/<novo_tema>.css`
2. Adicione o identificador ao array `AVAILABLE_THEMES` em [scripts/global-theme-selector.sh](file:///home/joaofedora/.dotfiles/scripts/global-theme-selector.sh).

### Adicionar um Novo Preset de Bordas (Border Suite)
1. Crie o arquivo `<novo_preset>.<ext>` em:
   - `sway/.config/sway/borders/<novo_preset>.conf`
   - `waybar/.config/waybar/borders/<novo_preset>.css`
   - `swaync/.config/swaync/borders/<novo_preset>.css`
   - `rofi/.config/rofi/borders/<novo_preset>.rasi`
2. Adicione o identificador ao array `AVAILABLE_PRESETS` e o rótulo descritivo em `PRESET_LABELS` no arquivo [scripts/global-border-selector.sh](file:///home/joaofedora/.dotfiles/scripts/global-border-selector.sh).

---

## 6. Convenções para Agentes e Desenvolvedores

- **Nunca hardcode paths absolutos de usuário** (`/home/joaofedora`): utilize sempre `$HOME` ou referências relativas via `BASH_SOURCE`.
- **Preserve a idempotência**: invocar qualquer script com o tema ou preset já ativo deve reaplicar os arquivos e sinais com segurança e sem erros.
- **Tratamento de Erros**: Qualquer novo módulo adicionado em `scripts/components/` ou `scripts/components/borders/` deve:
  - Validar a existência dos diretórios e arquivos de origem antes de escrever.
  - Retornar código de saída `0` para sucesso e `1` (com mensagem em `stderr`) para falha.
  - Implementar funções de consulta no formato `get_<component>_theme` e `get_<component>_border`.
