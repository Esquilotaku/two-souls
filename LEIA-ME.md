# Two Souls — comece por aqui

Two Souls é um jogo de ação e exploração em pixel art (estilo metroidvania), feito no **Godot 4.7.2** pelo Gabriel com ajuda de IAs (Claude e Codex). Esta página explica cada pasta em linguagem simples.

## Como jogar a versão atual

1. Dê dois cliques em **`JOGAR.bat`**, aqui na pasta `F:\GAME`.
2. Ou, num terminal PowerShell, rode (o `&` na frente é obrigatório no PowerShell):

   ```powershell
   & "F:\GAME\tools\Godot4.7.2\Godot_v4.7.2-stable_win64.exe" --path "F:\GAME\Two Souls"
   ```

3. O jogo abre em tela cheia. As teclas estão no menu **COMO JOGAR** e podem ser trocadas em **CONTROLES**.

## O que tem em cada pasta

| Pasta ou arquivo | O que é | Pode mexer? |
|---|---|---|
| `Two Souls\` | **O jogo.** Projeto do Godot: código (`scripts\`), imagens (`assets\`), arte do Aseprite (`art\`), cenas e testes automáticos (`tests\`). | Sim, com cuidado |
| `Two Souls\STATUS.md` | Onde o projeto parou, o que falta e o próximo passo. Todo agente atualiza ao parar. | Sim |
| `docs\design\` | **As decisões de como o jogo é**: mundo, história, habilidades, runas, level design, estilo da arte. | Sim |
| `docs\producao\` | Organização do trabalho: quadro de tarefas (`TAREFAS.md`), quem faz o quê, plano de negócio. | Sim |
| `docs\tecnico\` | Como as coisas são programadas e ferramentas avaliadas. | Sim |
| `docs\historico\` | Primeiros planos (outubro de 2026). Só para consulta; `docs\design\` vale mais. | Não |
| `material-original\` | **O jogo original da faculdade** (2018) e os arquivos antigos que ficavam soltos (PSDs, `.capx`, imagens). | **Não. Só leitura** |
| `notas-do-gabriel\` | Anotações e conversas do Gabriel sobre o jogo. | Só o Gabriel |
| `pipeline\` | Scripts que ajudam a criar e exportar a arte do Aseprite. | Sim |
| `tools\` | O Godot já instalado (fora do git, porque é grande). | Não |
| `_QUARENTENA_2026-11-01\` | Arquivos tirados do caminho, mas **não apagados**. Ver o LEIA-ME dentro dela. | Só o Gabriel |
| `AGENTS.md` e `CLAUDE.md` | Regras para as IAs que trabalham no projeto. | Sim |
| pastas que começam com ponto (`.git`, `.github`, `.claude`, `.serena`) | Configurações internas do git, do GitHub e das IAs. | Não |

## Onde o projeto está guardado

- **No PC:** `F:\GAME`.
- **Na nuvem:** repositório privado no GitHub (`Esquilotaku/two-souls`). Cada envio roda os testes automáticos (GitHub Actions).
- Ficam fora do GitHub: o Godot (`tools\`) e a quarentena.

## Quem faz o quê

Veja `docs\producao\estudio-e-cargos.md`. Resumo: o Gabriel decide e joga para testar; o Claude organiza, programa e escreve; o Codex programa em paralelo, sempre em ramos (branches) separados.
