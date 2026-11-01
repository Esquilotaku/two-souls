# Two Souls â€” quadro de tarefas

Regras (ver `AGENTS.md`):
- Antes de comeÃ§ar, marque a tarefa com o seu nome e o branch.
- NÃ£o pegue tarefa marcada por outro agente.
- Ao parar, atualize o estado da tarefa.
- Quem junta os branches no `main` Ã© o Gabriel.

**Estados:**
- `livre`
- `em andamento (quem, branch)`
- `esperando Gabriel`
- `feito (data)`

A ordem segue os marcos do `docs/plano-de-negocio.md`, seÃ§Ã£o 6.

## Marco 1 â€” Base pronta

| # | Tarefa | ResponsÃ¡vel sugerido | Estado | ReferÃªncia |
|---|---|---|---|---|
| 1.1 | Plano tÃ©cnico do mundo interligado: salas, transiÃ§Ãµes, regiÃµes, como o save guarda a sala atual e as salas visitadas | Claude | em andamento (Claude, claude/estrutura-mundo) | mundo, tema 1 |
| 1.2 | Trocar os 8 corredores lineares por salas interligadas (primeiro, sÃ³ a Clareira, a Trilha e a entrada das Cavernas com arte provisÃ³ria) | Codex ou Claude | em andamento (Claude, claude/estrutura-mundo) | mundo, tema 1 |
| 1.3 | SantuÃ¡rios fixos que sÃ³ valem se ativados; morrer volta ao Ãºltimo ativado sem perder nada | Codex ou Claude | em andamento (Claude, claude/estrutura-mundo) | mundo, tema 1, itens 6 e 7 |
| 1.4 | Minimapa revelado conforme as salas visitadas | Codex ou Claude | livre | mundo, tema 1 |
| 1.5 | RelÃ³gio com descanso no santuÃ¡rio e os modos HistÃ³ria, Aventura e Desafio | Codex ou Claude | livre | mundo, tema 4 |
| 1.6 | Controles novos (setas, EspaÃ§o, A, S, QWER, D, F, Enter) com remapeamento | Codex ou Claude | livre | jogo, seÃ§Ã£o 7 |
| 1.7 | Bloqueios de habilidade: lanÃ§a cravada e super soco primeiro | Codex ou Claude | livre | jogo, seÃ§Ã£o 3 |

## Arte (em paralelo)

| # | Tarefa | ResponsÃ¡vel sugerido | Estado | ReferÃªncia |
|---|---|---|---|---|
| A.1 | Folha de estilo do Orion em 640Ã—360 (paleta, altura de 64 a 80 px, contorno, formas animais pretas com verde) | Gabriel + Claude | feito (01/11/2026) | `docs/folha-de-estilo-orion.md` |
| A.2 | Exportar os PSDs originais para PNG, como referÃªncia | Gabriel | livre | AGENTS.md, seÃ§Ã£o Aseprite |
| A.3 | Orion bÃ¡sico no Aseprite (parado, correndo, pulando, atacando) e ligar no `player.gd` | Gabriel + Codex | esperando Gabriel | AGENTS.md, seÃ§Ã£o Aseprite |

## OrganizaÃ§Ã£o e decisÃµes pendentes

| # | Tarefa | ResponsÃ¡vel sugerido | Estado | ReferÃªncia |
|---|---|---|---|---|
| O.1 | Avaliar a skill de orquestraÃ§Ã£o do Orca (`stablyai/orca`) para Claude e Codex trabalharem juntos. **O Gabriel lÃª antes de instalar**; a instalaÃ§Ã£o Ã© no PC | Gabriel + Claude (sessÃ£o do PC) | feito (01/11/2026) | `docs/orca.md` |
| O.2 | Decidir as perguntas em aberto do design quando o assunto chegar (final verdadeiro, feiticeiro, subchefes do folclore, animais do R, espaÃ§os de runa) | Gabriel | livre | fim de cada doc em `docs/` |
| O.3 | Antes da pÃ¡gina da Steam: buscar a marca "D Rock" (USPTO/INPI), conferir o MEI para jogos e fazer a consulta com o contador | Gabriel + Claude | livre | negÃ³cio, seÃ§Ãµes 1 e 4 |

## Feito

| # | Tarefa | Quem | Data |
|---|---|---|---|
| â€” | Brainstorm completo (4 documentos em `docs/`) | Claude + Gabriel | 01/11/2026 |
| â€” | Quadro de tarefas e cargos no `AGENTS.md` | Claude | 01/11/2026 |
| O.1 | Orca instalado e skill `orchestration` para Claude e Codex (`docs/orca.md`) | Claude + Gabriel | 01/11/2026 |
| A.1 | Folha de estilo do Orion: paleta de 28 cores, 72 px, contorno, 6 animaÃ§Ãµes e script `pipeline/new-orion.lua` | Claude + Gabriel | 01/11/2026 |
