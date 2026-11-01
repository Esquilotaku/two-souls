# Folha de estilo do Orion

Aprovada pelo Gabriel em 01/11/2026 (tarefa A.1). Vale para todo quadro do Orion, feito à mão ou como rascunho de IA: **mande esta folha junto com cada pedido de rascunho**, como diz o fluxo de arte em `docs/producao/estudio-e-cargos.md`.

Base: `docs/design/brainstorm-jogo.md`, seções 2 e 5 (pixel art com tela interna de 640×360 e Orion de 64 a 80 px). Referência visual aprovada: `Two Souls/assets/concepts/orion-aenia-approved-reference.png`.

## Arquivos

- Paleta do Aseprite: `Two Souls/art/orion-paleta.gpl`.
- Arquivo novo do Orion já no padrão: `pipeline/new-orion.lua` (ver "Como começar um arquivo").

## Tamanho

- **Orion humano: 72 px de altura**, do topo do cabelo até a sola do pé, sem contar a lança. São 20% da altura da tela de 360 px.
- **Quadro: 160×96 px**, o mesmo em todas as animações. A largura aumentou de 128 para 160 px para conter a lança nos quadros de dash sem reduzir o personagem; o pivô do pé permanece em (64, 88).
- **Pivô no pé: ponto (64, 88).** A cabeça fica na linha 16 e a sola na linha 88. O Orion fica centrado no x 64 quando está parado.
- O arquivo novo traz a camada escondida `guia`, com essas três linhas. Ela não entra no export.

Alternativas descartadas: 64 px (os olhos ficariam com 1 ou 2 pixels) e 80 px (mais caro por quadro e ocupa 22% da tela).

## Paleta (28 cores mais a transparente)

O arquivo trabalha em **modo indexado**, então só essas cores existem. O índice 0 é a transparência; não pinte com ele.

As cores de pele, cabelo, túnica e couro foram medidas na referência aprovada. Metal, olho e as cores animais são propostas do Claude, porque a referência não mostra essas partes de perto.

| Índices | Grupo | Cores (escura → clara) |
|---|---|---|
| 1 | contorno | `#0a0c0b` |
| 2–5 | pele | `#80562a` `#ce9c66` `#e7b97d` `#f6d3a0` |
| 6–10 | cabelo e folhas | `#0e3a11` `#225214` `#386b1b` `#4f8025` `#95c652` |
| 11–13 | túnica | `#1c1c1e` `#2e2e2f` `#45443d` |
| 14–17 | couro, madeira e chifres | `#2a1d12` `#4a321e` `#6f4c29` `#9a6e3e` |
| 18–20 | metal da lança | `#4a5560` `#8a96a0` `#d4dde2` |
| 21–22 | olho e branco | `#2d8c3c` `#f2f4ee` |
| 23–25 | animal (corpo preto) | `#111614` `#1d2622` `#2c3833` |
| 26–28 | brilho verde (animal e magia) | `#1f7a3a` `#3ccf5e` `#b6ff9c` |

Alternativas descartadas: 16 cores (túnica e contorno ficam iguais) e 32 cores, com 4 tons de luz da lua. Esses 4 tons podem entrar depois, quando houver cenário noturno.

## Contorno

- **Por fora: 1 px de `#0a0c0b`** (índice 1) em volta da silhueta do Orion humano.
- **Por dentro:** onde dois materiais se encontram, use o tom mais escuro do material que está na frente (cabelo `#0e3a11`, couro `#2a1d12`, pele `#80562a`), não o preto.
- **Formas animais:** contorno de fora em **verde-escuro `#0e3a11`** (índice 6, o mesmo do cabelo mais escuro). Bicho preto com contorno preto vira mancha à noite.
- Sem contorno de 2 px nem antisserrilhado contra o fundo; o fundo muda conforme a região e a hora.

## Formas animais

- O corpo usa só os índices 23 a 25 (pretos esverdeados).
- O verde aparece só em detalhes: olhos, crina, folhas e marcas. Use o índice 27 no geral e o 28 só no ponto mais claro (o olho, por exemplo). No máximo cerca de 10% dos pixels do animal são verdes.
- Os animais e as habilidades estão em `docs/design/brainstorm-jogo.md`, seção 3: onça-pintada preta, jiboia, tatu-canastra e gavião-real.

## Animações

12 quadros por segundo (83 ms cada). O nome da tag é o nome da animação no Godot, em inglês como a tag `idle` que já existe.

| Animação | Tag | Quadros | Repete? |
|---|---|---|---|
| parado | `idle` | 6 | sim |
| correndo | `run` | 8 | sim |
| pulando (subida) | `jump` | 3 | não |
| caindo | `fall` | 2 | sim |
| atacando (golpe básico com a lança) | `attack` | 6 | não |
| dash | `dash` | 4 | não |
| **total** | | **29** | |

- As tags que não repetem saem do Aseprite com `"repeat": "1"` no JSON. **Ainda não usado:** hoje o `scripts/aseprite_frames.gd` aplica o mesmo `loop` a todas as animações. Ler esse campo fica para a tarefa A.3.
- O combo de 3 golpes, que termina com a transformação em animal, fica para outro arquivo.
- Alternativas descartadas: versão enxuta (21 quadros) e fluida (39 quadros).

## Como começar um arquivo

Na pasta `F:\GAME`:

```
C:\dev\aseprite\build\bin\aseprite.exe -b --script-param dst="Two Souls\art\orion-novo.aseprite" --script pipeline\new-orion.lua
```

O script cria o arquivo com:

- o tamanho;
- a paleta travada;
- as 6 tags e a duração dos quadros;
- as camadas `corpo`, `lanca` e `guia` (escondida).

Ele **não sobrescreve** arquivo existente: se o destino já existir, dá erro. O `Two Souls/art/orion.aseprite` atual é a ilustração antiga com 1 quadro e fica como está.

Depois de desenhar, renomeie o arquivo para `orion.aseprite` e exporte com `pipeline\export-aseprite.ps1 orion` (ver `AGENTS.md`).

## Pedido de rascunho para IA (modelo)

> Sprite de pixel art do Orion, 128×96 px, fundo transparente. Orion com 72 px de altura, pé no ponto (64, 88). Use só as 28 cores da paleta anexa, sem antisserrilhado. Contorno de fora de 1 px `#0a0c0b`. Animação: `<nome>`, `<n>` quadros. Referência: imagem aprovada anexa.

Toda geração paga é avisada antes, com quanto e onde (`AGENTS.md`).
