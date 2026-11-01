# Two Souls — quadro de tarefas

Regras (ver `AGENTS.md`):
- Antes de começar, marque a tarefa com o seu nome e o branch.
- Não pegue tarefa marcada por outro agente.
- Ao parar, atualize o estado da tarefa.
- Quem junta os branches no `main` é o Gabriel.

**Estados:**
- `livre`
- `em andamento (quem, branch)`
- `esperando Gabriel`
- `feito (data)`

A ordem segue os marcos do `docs/plano-de-negocio.md`, seção 6.

## Marco 1 — Base pronta

| # | Tarefa | Responsável sugerido | Estado | Referência |
|---|---|---|---|---|
| 1.1 | Plano técnico do mundo interligado: salas, transições, regiões, como o save guarda a sala atual e as salas visitadas | Claude | feito (01/11/2026), `docs/plano-tecnico-mundo.md` | mundo, tema 1 |
| 1.2 | Trocar os 8 corredores lineares por salas interligadas (primeiro, só a Clareira, a Trilha e a entrada das Cavernas com arte provisória) | Codex ou Claude | feito (01/11/2026): mapa completo do 1.0, 22 salas em cinza, branch claude/estrutura-mundo | mundo, tema 1 |
| 1.3 | Santuários fixos que só valem se ativados; morrer volta ao último ativado sem perder nada | Codex ou Claude | feito (01/11/2026), sem a escolha manhã/noite do descanso (fica na 1.5) | mundo, tema 1, itens 6 e 7 |
| 1.4 | Minimapa revelado conforme as salas visitadas | Codex ou Claude | livre | mundo, tema 1 |
| 1.5 | Relógio com descanso no santuário e os modos História, Aventura e Desafio | Codex ou Claude | livre | mundo, tema 4 |
| 1.6 | Controles novos (setas, Espaço, A, S, QWER, D, F, Enter) com remapeamento | Codex ou Claude | esperando Claude (integrar no game.gd), feito pelo Codex no branch codex/controles | jogo, seção 7 |
| 1.7 | Bloqueios de habilidade: lança cravada e super soco primeiro | Codex ou Claude | livre | jogo, seção 3 |
| 1.8 | Runas: achadas corrompidas, purificadas no santuário, equipadas em espaços, sobem com fragmentos | Codex | em andamento (Codex, codex/runas) | jogo, seção 3 |

## Arte (em paralelo)

| # | Tarefa | Responsável sugerido | Estado | Referência |
|---|---|---|---|---|
| A.1 | Folha de estilo do Orion em 640×360 (paleta, altura de 64 a 80 px, contorno, formas animais pretas com verde) | Gabriel + Claude | feito (01/11/2026) | `docs/folha-de-estilo-orion.md` |
| A.2 | Exportar os PSDs originais para PNG, como referência | Gabriel | livre | AGENTS.md, seção Aseprite |
| A.3 | Orion básico no Aseprite (parado, correndo, pulando, atacando) e ligar no `player.gd` | Gabriel + Codex | esperando Gabriel | AGENTS.md, seção Aseprite |

## Organização e decisões pendentes

| # | Tarefa | Responsável sugerido | Estado | Referência |
|---|---|---|---|---|
| O.1 | Avaliar a skill de orquestração do Orca (`stablyai/orca`) para Claude e Codex trabalharem juntos. **O Gabriel lê antes de instalar**; a instalação é no PC | Gabriel + Claude (sessão do PC) | feito (01/11/2026) | `docs/orca.md` |
| O.2 | Decidir as perguntas em aberto do design quando o assunto chegar (final verdadeiro, feiticeiro, subchefes do folclore, animais do R, espaços de runa) | Gabriel | livre | fim de cada doc em `docs/` |
| O.3 | Antes da página da Steam: buscar a marca "D Rock" (USPTO/INPI), conferir o MEI para jogos e fazer a consulta com o contador | Gabriel + Claude | livre | negócio, seções 1 e 4 |

## Feito

| # | Tarefa | Quem | Data |
|---|---|---|---|
| — | Brainstorm completo (4 documentos em `docs/`) | Claude + Gabriel | 01/11/2026 |
| — | Quadro de tarefas e cargos no `AGENTS.md` | Claude | 01/11/2026 |
| O.1 | Orca instalado e skill `orchestration` para Claude e Codex (`docs/orca.md`) | Claude + Gabriel | 01/11/2026 |
| A.1 | Folha de estilo do Orion: paleta de 28 cores, 72 px, contorno, 6 animações e script `pipeline/new-orion.lua` | Claude + Gabriel | 01/11/2026 |
