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

A ordem segue os marcos do `docs/producao/plano-de-negocio.md`, seção 6.

## Marco 1 — Base pronta

| # | Tarefa | Responsável sugerido | Estado | Referência |
|---|---|---|---|---|
| 1.1 | Plano técnico do mundo interligado: salas, transições, regiões, como o save guarda a sala atual e as salas visitadas | Claude | feito (01/11/2026), `docs/tecnico/plano-tecnico-mundo.md` | mundo, tema 1 |
| 1.2 | Trocar os 8 corredores lineares por salas interligadas (primeiro, só a Clareira, a Trilha e a entrada das Cavernas com arte provisória) | Codex ou Claude | feito (01/11/2026): mapa completo do 1.0, 22 salas em cinza, branch claude/estrutura-mundo | mundo, tema 1 |
| 1.3 | Santuários fixos que só valem se ativados; morrer volta ao último ativado sem perder nada | Codex ou Claude | feito (01/11/2026), sem a escolha manhã/noite do descanso (fica na 1.5) | mundo, tema 1, itens 6 e 7 |
| 1.4 | Minimapa revelado conforme as salas visitadas | Codex ou Claude | esperando Claude (ligar no game.gd), branch codex/minimapa | mundo, tema 1 |
| 1.5 | Relógio com descanso no santuário e os modos História, Aventura e Desafio | Codex ou Claude | livre | mundo, tema 4 |
| 1.6 | Controles novos (setas, Espaço, A, S, QWER, D, F, Enter) com remapeamento | Codex ou Claude | feito (01/11/2026): Codex fez, Claude ligou no jogo (título e pausa) | jogo, seção 7 |
| 1.7 | Bloqueios de habilidade: lança cravada e super soco primeiro | Codex ou Claude | livre | jogo, seção 3 |
| 1.8 | Runas: achadas corrompidas, purificadas no santuário, equipadas em espaços, sobem com fragmentos | Codex | feito (01/11/2026): Codex fez, Claude ligou (chefes e pedras dão runas; santuário purifica; pausa equipa); faltam fôlego e combo | jogo, seção 3 |
| 2.1 | Combos de comando no estilo arcade (tabela em `docs/design/combos-proposta.md`) | Claude | feito (02/11/2026): tabela aprovada e programada; faltam fôlego e transformação real (R) | combos-proposta |
| 2.2 | Mapa grande no estilo Grand Chase: céu aberto, andares de plataforma, uns 5 min correndo até o D Rock (blocos à mão + montador fixo) | Claude + Codex | feito para o caminho até o D Rock (02/11): 302 s medidos pelo corredor automático; o resto do mapa ainda no tamanho antigo | level-design-referencias, referencia-grand-chase |
| 2.3 | Inimigos grandes (do tamanho do Orion ou maiores) e chefes com super armadura | Codex ou Claude | em andamento (Codex, codex/inimigos-grandes) | referencia-grand-chase |

## Arte (em paralelo)

| # | Tarefa | Responsável sugerido | Estado | Referência |
|---|---|---|---|---|
| A.1 | Folha de estilo do Orion em 640×360 (paleta, altura de 64 a 80 px, contorno, formas animais pretas com verde) | Gabriel + Claude | feito (01/11/2026) | `docs/design/folha-de-estilo-orion.md` |
| A.2 | Exportar os PSDs originais para PNG, como referência | Gabriel | livre | AGENTS.md, seção Aseprite |
| A.3 | Orion básico no Aseprite (parado, correndo, pulando, atacando) e ligar no `player.gd` | Gabriel + Codex | esperando Gabriel | AGENTS.md, seção Aseprite |

## Referências e decisões novas (da pesquisa de 01/11/2026)

| # | Tarefa | Responsável sugerido | Estado | Referência |
|---|---|---|---|---|
| R.1 | Rodar `pipeline/baixar-referencias.ps1` no PC e conferir `referencias/imagens/INDICE.md` | Gabriel ou agente do PC | livre | `referencias/README.md` |
| R.2 | Decidir viagem rápida, marcadores no mapa e se o mapa é comprado ou só revelado | Gabriel | feito (01/11): viagem rápida pelas raízes da Árvore Mãe, mapa revelado andando, marcadores manuais e automáticos (só manuais no Desafio) | `referencias/checklist-do-jogo.md` |
| R.3 | Escolher as lendas dos 5 subchefes e 8 minibosses, e de 20 a 25 inimigos comuns | Gabriel | feito (01/11): lendas decididas; **todos os 50 inimigos comuns** entram no 1.0 (núcleo de 25 primeiro) | `referencias/lendas-do-brasil.md`, `referencias/bestiario-ideias.md` |
| R.4 | Teste de arte: um quadro do Orion à mão, a IA completa a corrida com referência de pose 3D (Mixamo), ajuste no Aseprite | Gabriel + Codex | livre | `referencias/videos-e-aprendizados.md` |
| R.5 | Avaliar addons (MetSys, LimboAI, Dialogue Manager, Phantom Camera); o Gabriel lê antes de instalar | Gabriel + Claude | livre | `referencias/codigo-aberto-godot.md` |
| R.6 | Definir fonte e HUD pensando no Steam Deck (texto ≥ 9 px a 1280×800) | Gabriel + Claude | adiado para o final (decisão do Gabriel, 01/11) | `referencias/checklist-do-jogo.md`, seção 9 |

## Organização e decisões pendentes

| # | Tarefa | Responsável sugerido | Estado | Referência |
|---|---|---|---|---|
| O.1 | Avaliar a skill de orquestração do Orca (`stablyai/orca`) para Claude e Codex trabalharem juntos. **O Gabriel lê antes de instalar**; a instalação é no PC | Gabriel + Claude (sessão do PC) | feito (01/11/2026) | `docs/tecnico/orca.md` |
| O.2 | Decidir as perguntas em aberto do design quando o assunto chegar (final verdadeiro, feiticeiro, subchefes do folclore, animais do R, espaços de runa) | Gabriel | feito (01/11, ver `brainstorm-jogo.md`, seção 0); faltam o nome do espírito da seca e a decisão sobre os nomes de Orion, Aenia e do jogo | fim de cada doc em `docs/` |
| O.3 | Antes da página da Steam: buscar a marca "D Rock" (USPTO/INPI), conferir o MEI para jogos e fazer a consulta com o contador | Gabriel + Claude | livre | negócio, seções 1 e 4 |
| O.4 | Avaliar o Metroidvania System (MetSys) para adotar ou não | Codex + Gabriel | esperando Gabriel (ler docs/tecnico/avaliacao-metsys.md) | docs/design/level-design-referencias.md |
| O.5 | Pesquisa da jogabilidade do Grand Chase por fontes públicas | Codex | esperando Gabriel (ler docs/design/referencia-grand-chase.md) | — |

## Feito

| # | Tarefa | Quem | Data |
|---|---|---|---|
| — | Brainstorm completo (4 documentos em `docs/`) | Claude + Gabriel | 01/11/2026 |
| — | Quadro de tarefas e cargos no `AGENTS.md` | Claude | 01/11/2026 |
| — | Pesquisa de referências: jogos, ferramentas, vídeos, lendas, fauna, bestiário, código aberto, checklist (`referencias/`) | Claude | 01/11/2026 |
| O.1 | Orca instalado e skill `orchestration` para Claude e Codex (`docs/tecnico/orca.md`) | Claude + Gabriel | 01/11/2026 |
| A.1 | Folha de estilo do Orion: paleta de 28 cores, 72 px, contorno, 6 animações e script `pipeline/new-orion.lua` | Claude + Gabriel | 01/11/2026 |
