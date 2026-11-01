# Two Souls — regras para agentes (Claude Code, Codex e outros)

Este arquivo vale para qualquer agente de IA que trabalhe nesta pasta. Responda em português do Brasil.

## Onde está o quê

O mapa completo das pastas, em linguagem simples, está no `LEIA-ME.md` da raiz. Resumo:

- `Two Souls/` — projeto Godot 4.7.2 (o jogo). Abrir `project.godot`.
- `Two Souls/STATUS.md` — **bilhete de passagem compartilhado**: estado atual, o que falta, próximo passo.
- `docs/` — documentos do projeto, em quatro pastas:
  - `docs/design/` — **fonte de verdade do design**:
    - `brainstorm-mundo-interligado.md`: mapa, regiões, chefes, relógio;
    - `brainstorm-jogo.md`: história, habilidades, runas, arte, som, controles;
    - `level-design-referencias.md`: o que aprender com outros jogos e regras do nosso level design;
    - `historia.md`: a história com os nomes novos (Kaê, Aená, Tau), em rascunho para aprovação;
    - `runas.md`, `folha-de-estilo-orion.md`.
  - `docs/producao/` — `TAREFAS.md` (**quadro de tarefas**: quem pegou cada tarefa, o estado e o branch), `estudio-e-cargos.md` (quem faz o quê), `plano-de-negocio.md` (Steam, impostos, marketing).
  - `docs/tecnico/` — `plano-tecnico-mundo.md` (como o mundo é programado), `orca.md`, `ferramentas-avaliadas.md`, `avaliacao-metsys.md`.
  - `docs/historico/` — "Plano do Jogo" e "Pesquisa Inicial" de outubro de 2026. Valem só como histórico; o `docs/design/` prevalece quando houver conflito.
- `referencias/` — pesquisa de referências: jogos, vídeos, lendas, fauna, bestiário, código aberto e checklist do jogo. Comece por `referencias/checklist-do-jogo.md`.
- `material-original/` — material original da faculdade (`twosouls/`) e os arquivos que ficavam soltos na raiz (`soltos-da-raiz/`: PSDs, `.capx`, PNG). **Só leitura: nunca editar, mover ou apagar.** (O Gabriel autorizou a mudança para esta pasta em 01/11/2026.)
- `notas-do-gabriel/` — anotações e conversas do Gabriel. Leia como contexto; não edite.
- `pipeline/` — scripts do Aseprite. `tools/Godot4.7.2/` — executável do Godot (fora do git).
- `_QUARENTENA_*/` — arquivos tirados do caminho, fora do git. Apagar de vez só com novo ok do Gabriel.

## Arte com Aseprite

- Aseprite 1.3.18.6 compilado localmente em `C:\dev\aseprite\build\bin\aseprite.exe` (uso pessoal pela EULA; nunca commitar o executável). Recompilar: `C:\dev\build-aseprite.cmd`.
- Fonte da arte: `Two Souls/art/*.aseprite`. Cada tag vira uma animação no Godot.
- Exportar para o jogo: `powershell -ExecutionPolicy Bypass -File pipeline\export-aseprite.ps1 [nome]`. Gera `assets/sprites/<nome>.png` + `.json`; commite os dois junto com o `.aseprite`.
- No jogo: `AsepriteFrames.load_frames("res://assets/sprites/<nome>.json")` devolve um `SpriteFrames` para `AnimatedSprite2D`.
- PNG → `.aseprite` com tag: `aseprite -b --script-param src=... --script-param dst=... --script-param tag=idle --script pipeline\new-from-png.lua`.
- Arquivo novo do Orion no padrão da folha de estilo (`docs/design/folha-de-estilo-orion.md`): `aseprite -b --script-param dst="Two Souls\art\orion-novo.aseprite" --script pipeline\new-orion.lua`. Não sobrescreve arquivo existente.
- Este Aseprite **não abre os PSDs** do material original; exporte-os em PNG antes.
- O Aseprite sai com código 0 mesmo quando falha: sempre confira o arquivo gerado.

## Quem faz o quê

Detalhes em `docs/producao/estudio-e-cargos.md`. Não há freelancers: tudo é feito pelo Gabriel e pelas IAs.

| Cargo | Responsável |
|---|---|
| Direção criativa e palavra final | Gabriel |
| Produção (STATUS, TAREFAS, planejamento) | Claude organiza, Gabriel aprova |
| Programação (Godot/GDScript) | Codex e Claude, em branches separados |
| Game design e roteiro | Gabriel cria, Claude escreve e organiza em `docs/` |
| Arte e animação | Gabriel (conceitos, ajuste fino no Aseprite) e IA de imagem (rascunhos) |
| Música e efeitos sonoros | IA de música, com o Gabriel escolhendo e editando |
| Testes | Gabriel joga; GitHub Actions a cada envio |
| Marketing, comunidade, textos | Gabriel é o rosto; Claude escreve, Gabriel revisa |

- **Agentes especializados novos** (em `.claude/agents/` ou como skill): só quando uma tarefa se repetir umas 3 vezes, e o Gabriel lê antes do primeiro uso.

## Regra de passagem entre agentes

Claude e Codex não trabalham ao mesmo tempo nos mesmos arquivos.

1. **Ao começar:** leia `Two Souls/STATUS.md` e `docs/producao/TAREFAS.md`, e rode `git status` e `git log --oneline -10`. Se houver mudança não commitada que você não fez, pare e pergunte ao Gabriel. Antes de trabalhar numa tarefa, marque-a em `docs/producao/TAREFAS.md` com o seu nome e o branch. Não pegue tarefa que outro agente já marcou.
2. **Durante:** faça commits pequenos, um por mudança que faça sentido sozinha. A mensagem começa com quem fez: `[claude] ...` ou `[codex] ...`.
3. **Ao parar** (fim da tarefa, cota acabando ou troca de agente): atualize a seção "Ponto de retomada" do `STATUS.md` (o que fez, o que não foi verificado, próximo passo) e o estado da tarefa em `docs/producao/TAREFAS.md`, e faça commit. Nunca deixe mudança sem commit ao passar a vez.
4. Trabalho em paralelo só em branches separados (`claude/...`, `codex/...`), e quem junta é o Gabriel.

## Como verificar

- Checar se o projeto carrega sem erro de script:
  `tools/Godot4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path "Two Souls" --quit`
- O repositório privado `Esquilotaku/two-souls` roda o mesmo teste no GitHub Actions a cada `git push` (`.github/workflows/godot-check.yml`). Envie seus commits ao terminar e confira se o teste passou.
- MCP do Godot (`@coding-solo/godot-mcp@0.1.1`, configurado em `.mcp.json`): ferramentas `run_project`, `get_debug_output`, `stop_project`, `create_scene`, `add_node`, `load_sprite` e outras. `run_project` abre a janela do jogo na tela do Gabriel; feche com `stop_project`. Testado com Godot 4.7.2 em 01/11/2026.
  - Codex: para usar o mesmo servidor, o Gabriel adiciona em `~/.codex/config.toml`: `[mcp_servers.godot]` com `command = "cmd"`, `args = ["/c", "npx", "-y", "@coding-solo/godot-mcp@0.1.1"]` e `env = { GODOT_PATH = "F:\\GAME\\tools\\Godot4.7.2\\Godot_v4.7.2-stable_win64_console.exe" }`.
- Serena 2.1.0 (MCP em `.mcp.json`, projeto em `.serena/project.yml`): busca e edição por símbolo (`find_symbol`, `find_referencing_symbols`, `get_symbols_overview`). **Só funciona com o editor do Godot aberto** no projeto, porque usa o servidor de código do editor. A porta é 6005 (Godot 4.7.2), configurada em `~/.serena/serena_config.yml`; o padrão da Serena (6008) não funciona. Sem o editor aberto, use busca de texto normal. Testado com `serena project health-check` em 01/11/2026.
  - Codex: o Gabriel adiciona em `~/.codex/config.toml`: `[mcp_servers.serena]` com `command = "C:\\Users\\Gabriel\\.local\\bin\\serena.exe"`, `args = ["start-mcp-server", "--context=codex", "--project", "F:\\GAME"]`, `env = { PYTHONUTF8 = "1" }` e `startup_timeout_sec = 30`.
- Orca (app que roda Claude e Codex lado a lado, v1.4.245): para um agente mandar trabalho ao outro e receber o resultado, use a skill `orchestration` (instalada em `~/.agents/skills`, ligada em `~/.claude/skills`). Antes de qualquer comando, rode `orca skills get orchestration`. O comando fica em `%LOCALAPPDATA%\Programs\orca\resources\bin\orca.exe` (o `orca` puro só funciona nos terminais do Orca). Avaliação e ressalvas em `docs/tecnico/orca.md`.
- "Pronto" só depois de rodar e conferir o resultado. Se não rodou, escreva no STATUS que não foi verificado.

## Limites

- Não instale plugin, addon ou script de terceiros sem o Gabriel ler antes.
- Não gaste crédito pago (APIs, geração de imagem, voz) sem dizer quanto e onde antes.
- O jogo é uma refeitura de um projeto original do Gabriel e de amigos. Referências de outros jogos inspiram sistemas, não são para copiar arte, nomes ou fases.
