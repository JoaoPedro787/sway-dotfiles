# Arquitetura do Sistema de Temas, Bordas e Layouts Dinâmicos (Sway Customization Suite)

Este documento descreve o funcionamento interno, a arquitetura e as convenções adotadas para os sistemas unificados de gerenciamento e troca de paletas visuais, estilos de bordas/cantos arredondados e layouts da Waybar no ambiente Sway Suite (SwayFX, Kitty, Rofi, Swaylock, SwayNC e Waybar).

---

## 1. Visão Geral e Filosofia

O ecossistema divide-se em três eixos orquestradores complementares:
1. **Theme Suite (`global-theme-selector.sh`)**: Gerenciamento dinâmico da paleta cromática global (Nord, Gruvbox, etc.).
2. **Border Suite (`global-border-selector.sh`)**: Gerenciamento de raio de curvatura (*corner radius*) e espessura/visibilidade de bordas nas janelas e componentes de interface.
3. **Waybar Layout Suite (`waybar-layout-selector.sh`)**: Gerenciamento dinâmico da estrutura e estilo de layout da barra (posicionamento, distribuição de módulos e geometria), preservando sincronização imediata com os sistemas de cores e bordas.

Ambos foram desenhados com base em quatro princípios:
1. **Desacoplamento e Modularidade**: Os scripts principais não contêm código de apps hardcodado. A lógica reside em submódulos isolados (`scripts/components/*.sh` para cores, `scripts/components/borders/*.sh` para bordas e `scripts/components/waybar-layout.sh` para layout da barra).
2. **Dupla Interface**: Cada módulo funciona tanto como biblioteca importável (`source`) quanto como ferramenta executável autônoma de linha de comando (`CLI`).
3. **Recarregamento em Tempo Real (Hot-Reload)**: Aplicação instantânea sem reiniciar a sessão Sway ou fechar janelas ativas.
4. **Sincronização Integrada**: 
   - Quando uma borda colorida está ativa (`*-colored`), a troca de tema no seletor de cores atualiza a cor da borda instantaneamente.
   - Qualquer layout de Waybar selecionado herda automaticamente o tema de cor e o preset de bordas ativo através dos imports `@import "colors/current.css";` e `@import "borders/current.css";`.

---

## 2. Estrutura de Arquivos

```text
~/.dotfiles/
├── scripts/
│   ├── global-theme-selector.sh        # Orquestrador global de cores (Rofi & CLI)
│   ├── global-border-selector.sh       # Orquestrador global de bordas & raio (Rofi & CLI)
│   ├── waybar-layout-selector.sh       # Orquestrador de layouts da Waybar (Rofi & CLI)
│   │
│   └── components/                     # Módulos auxiliares de temas e layout
│       ├── kitty.sh
│       ├── rofi.sh
│       ├── sway.sh
│       ├── swaylock.sh
│       ├── swaync.sh
│       ├── waybar.sh                   # Gerenciador de cores da Waybar
│       ├── waybar-layout.sh            # Gerenciador de layouts da Waybar
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
    ├── config.jsonc                    # Symlink para layouts/<ativo>/config.jsonc
    ├── style.css                       # Symlink para layouts/<ativo>/style.css
    ├── colors/
    │   ├── current.css                 # Contém: @import "<tema>.css";
    │   └── <tema>.css
    ├── borders/
    │   ├── current.css                 # Contém: @import "<preset>.css";
    │   └── <preset>.css
    └── layouts/                        # Diretório de variantes e templates
        ├── default/                    # Layout padrão completo
        │   ├── config.jsonc
        │   ├── style.css
        │   ├── colors -> ../../colors
        │   └── borders -> ../../borders
        ├── example/                    # Template / layout alternativo flutuante
        │   ├── config.jsonc
        │   ├── style.css
        │   ├── colors -> ../../colors
        │   └── borders -> ../../borders
        └── retro-dark/                 # Layout retrô minimalista com moldura de borda
            ├── config.jsonc
            ├── style.css
            ├── colors -> ../../colors
            └── borders -> ../../borders
```

---

## 3. Presets Padronizados de Borda (Border Suite)

O sistema de bordas define 6 presets padronizados, combinando 2 níveis de curvatura de cantos com variações de espessura de borda (sem borda, 1px sólida ou 2px sólida):

| Identificador | Nível de Raio | Borda / Contorno | Descrição |
| :--- | :--- | :--- | :--- |
| `sharp-none` | **0px** (Reto / Quadrado) | 0px / Nenhuma | Cantos vivos, janelas e caixas sem linha perimetral |
| `sharp-colored` | **0px** (Reto / Quadrado) | 1px Sólida | Cantos vivos com borda sólida de 1px na cor de destaque do tema ativo |
| `sharp-colored-2px` | **0px** (Reto / Quadrado) | 2px Sólida | Cantos vivos com borda sólida de 2px destacada na cor do tema |
| `rounded-none` | **10px** (Moderado) | 0px / Nenhuma | Cantos arredondados suaves sem linha perimetral |
| `rounded-colored` | **10px** (Moderado) | 1px Sólida | Cantos arredondados com borda colorida de 1px ativa |
| `rounded-colored-2px` | **10px** (Moderado) | 2px Sólida | Cantos arredondados com borda colorida de 2px destacada |


---

## 4. Arquitetura Modular da Waybar (Waybar Layout Suite)

A Waybar foi desenhada para permitir a coexistência de múltiplos estilos de barra (ex: barras completas de ponta a ponta, barras flutuantes, barras minimalistas, barras duplas) sem perder a integração cromática e geométrica global.

### 4.1. Isolamento por Pastas (`layouts/<nome>/`)
Cada layout reside em uma pasta dedicada sob `waybar/.config/waybar/layouts/<nome>/`:
- **`config.jsonc`**: Estrutura JSONC de módulos, ordem de exibição, posições e margens.
- **`style.css`**: Estilização visual dos módulos e da barra. Deve conter obrigatoriamente:
  - `@import "colors/current.css";` (no topo, importando variáveis como `@base-bg`, `@ws-bg`, etc.)
  - `@import "borders/current.css";` (ao final, aplicando raio de curvatura e bordas ativas)
- **Symlinks locais de suporte**:
  - `colors -> ../../colors`
  - `borders -> ../../borders`
  Estes symlinks garantem que o motor GTK CSS resolva os imports com sucesso, independentemente de o arquivo ser lido a partir do symlink raiz ou diretamente de dentro da subpasta.

### 4.2. Chaveamento por Links Simbólicos
Na raiz de `~/.config/waybar/`:
- `config.jsonc` aponta relativamente para `layouts/<ativo>/config.jsonc`.
- `style.css` aponta relativamente para `layouts/<ativo>/style.css`.
- O layout ativo é persistido em `~/.config/.current_waybar_layout`.

### 4.3. Ciclo de Vida do Processo e Reinicialização
Diferente das folhas de estilo CSS (que aceitam hot-reload via sinal `SIGUSR2`), a estrutura de módulos do `config.jsonc` só é lida na inicialização do binário da Waybar. Por essa razão:
1. O submódulo `scripts/components/waybar-layout.sh` encerra graciosamente o processo existente (`killall waybar`).
2. Aguarda a liberação do processo.
3. Spawna a nova barra através de `swaymsg exec waybar`.
4. O uso de `swaymsg exec waybar` faz com que o Sway adote a nova Waybar como processo filho oficial da sessão Wayland, garantindo persistência sem depender da janela de terminal que invocou o script.

---

## 5. Mecanismos de Hot-Reload

| Componente | Sistema de Cores | Sistema de Bordas e Raio | Sistema de Layout (Waybar) |
| :--- | :--- | :--- | :--- |
| **Sway / SwayFX** | `sway/.config/sway/colors/current.conf` é recarregado via `swaymsg reload`. Atualiza as classes `client.focused`, `client.unfocused`, etc. | `sway/.config/sway/borders/current.conf` define `corner_radius`, `default_border` e `default_floating_border`. Executa `swaymsg reload` e sincroniza janelas abertas via `swaymsg "[app_id=.*] border ..."` instantaneamente. | N/A |
| **Waybar** | `killall -SIGUSR2 waybar`. Recarrega o CSS instantaneamente. | `killall -SIGUSR2 waybar`. Recarrega o arquivo `borders/current.css` sobrepondo as regras dos módulos. | `swaymsg exec waybar` após atualizar symlinks `config.jsonc` e `style.css`. Reinicia o processo sem perturbar a sessão Sway. |
| **SwayNC** | `swaync-client -rs` e `swaync-client -R`. | `swaync-client -rs` e `swaync-client -R`. Atualiza `border-radius` e `box-shadow` perimetral dos cards e painel. | N/A |
| **Kitty** | `killall -SIGUSR1 kitty`. | Gerenciado automaticamente pela moldura e cantos do SwayFX. | N/A |
| **Rofi** | Sob demanda ao abrir menus. | Sob demanda ao abrir menus (`@import "borders/current.rasi"` em `config.rasi` e launchers). | N/A |
| **Swaylock** | Concatenação prévia (`base + color > config`). | Sob demanda ao bloquear a sessão. | N/A |

---

## 6. Guia: Como Adicionar Novos Elementos


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

### Adicionar um Novo Layout de Waybar (Waybar Layout Suite)
1. Crie uma nova pasta em `waybar/.config/waybar/layouts/<nome_do_layout>/`.
2. Adicione os arquivos:
   - `config.jsonc`: estrutura JSONC de módulos e posicionamento da barra.
   - `style.css`: regras CSS específicas do layout, contendo no início `@import "colors/current.css";` e no final `@import "borders/current.css";`.
3. (Opcional) Adicione um rótulo amigável no array associativo `LAYOUT_LABELS` em [scripts/waybar-layout-selector.sh](file:///home/joaofedora/.dotfiles/scripts/waybar-layout-selector.sh).
4. O layout será descoberto dinamicamente pelo seletor Rofi e pela CLI (`./scripts/waybar-layout-selector.sh <nome_do_layout>`).

---

## 7. Convenções para Agentes e Desenvolvedores

- **Nunca hardcode paths absolutos de usuário** (`/home/joaofedora`): utilize sempre `$HOME` ou referências relativas via `BASH_SOURCE`.
- **Preserve a idempotência**: invocar qualquer script com o tema, preset ou layout já ativo deve reaplicar os arquivos e sinais com segurança e sem erros.
- **Tratamento de Erros**: Qualquer novo módulo adicionado em `scripts/components/` ou `scripts/components/borders/` deve:
  - Validar a existência dos diretórios e arquivos de origem antes de escrever.
  - Retornar código de saída `0` para sucesso e `1` (com mensagem em `stderr`) para falha.
  - Implementar funções de consulta no formato `get_<component>_theme`, `get_<component>_border` e `get_<component>_layout`.

