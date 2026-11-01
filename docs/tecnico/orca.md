# Orca — avaliação e instalação (tarefa O.1)

01/11/2026, Claude, com aprovação do Gabriel.

## O que é

- Repositório oficial: `stablyai/orca`. Organização "Stably" verificada no GitHub, licença MIT, site orca.dev.
- App de desktop (Electron) que roda vários agentes (Claude Code, Codex e outros) em terminais e worktrees, usando as assinaturas que já pagamos.
- A skill `orchestration` permite a um agente (o coordenador) criar tarefas, iniciar outro agente como "worker" e receber o resultado (`worker_done`).

## O que foi conferido antes de instalar

- O `SKILL.md` é só um aviso, sem scripts. O guia de verdade vem do programa: `orca skills get orchestration`.
- O app instala hooks de status no Claude e no Codex (avisam se o agente está trabalhando). Desligar: Settings → Agents → Agent status hooks, ou `orca agent hooks off`.
- Ele lê `~/.claude` e `~/.codex` e usa o login para mostrar a cota. Pela documentação, não mexe no `CLAUDE.md` nem no `AGENTS.md`.
- Atualização automática ligada (canal estável).
- **Telemetria anônima ligada por padrão** (PostHog, EUA): versão, sistema, agentes usados e contagem de tokens. Pela documentação, não manda código, prompts nem caminhos. Desligar: Settings → Privacy, ou a variável `ORCA_TELEMETRY_DISABLED=1`.

## Instalação feita

- Instalador `orca-windows-setup.exe` v1.4.245 baixado do release oficial. O SHA-256 `e1c96fd5…1cb07803` bate com o publicado no GitHub. Assinatura válida da SignPath Foundation (certificado GlobalSign).
- App em `%LOCALAPPDATA%\Programs\orca`; comando em `resources\bin\orca.exe`. Esse comando não está no PATH do Windows.
- Skill instalada pelo próprio Orca, sem npx: `orca skills install --skill orchestration --agent claude,codex`. Ela foi gravada em `~/.agents/skills/orchestration`, com link em `~/.claude/skills/orchestration`.
- A versão instalada é a que vem com o 1.4.245. O texto de descrição é um pouco diferente do `main` do GitHub, mas os comandos são iguais e não há scripts.

## Verificado

- `orca --version` → 1.4.245; `orca status` → app e runtime prontos.
- A skill aparece no Claude Code.
- `orca skills get orchestration` e `orca orchestration run-list` funcionam sem ligar nada em Settings → Experimental.

## Codex CLI (instalado na mesma noite)

- O PC só tinha o app Codex da Microsoft Store, sem o comando `codex` no PATH, e o Orca abre o Codex por esse comando.
- Instalado o oficial `npm install -g @openai/codex@0.166.0` (OpenAI, Apache-2.0, sem script de instalação, cerca de 500 MB). Comando em `%APPDATA%\npm\codex.cmd`.
- `codex --version` → 0.166.0; `codex login status` → logado com ChatGPT (usa o mesmo `~/.codex` do app); `codex doctor` → 0 falhas. Os avisos são opcionais: exclusão do Codex no Microsoft Defender e Dev Drive.
- O planejador do Orca (`orca skills install --dry-run`) não cria link em `~/.codex/skills`; ele conta com o Codex lendo a pasta compartilhada `~/.agents/skills`.

## Teste final (01/11/2026)

- O Gabriel liberou scripts no PowerShell só para o usuário dele: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, conferido com `Get-ExecutionPolicy`.
- `orca agent launch --agent codex` abriu o Codex 0.166.0 em `F:\GAME`. Ele respondeu que tem a skill `orchestration`, carregada de `C:/Users/Gabriel/.agents/skills/orchestration/SKILL.md`.
- **Atenção:** o Orca abriu o Codex em **"YOLO mode"**, sem pedir aprovação de comandos e sem sandbox. Antes de dar tarefas de escrita ao Codex pelo Orca, decidir se isso fica assim, ver nas configurações de agentes do Orca, e manter tudo em branch `codex/...`.

## Não verificado

- Um ciclo completo de orquestração: o Claude cria a tarefa, o Codex trabalha e manda `worker_done`, e o Claude recebe.
- Primeira tentativa, antes da liberação do PowerShell: `orca agent launch --agent codex` abriu o terminal, mas o PowerShell bloqueou o `codex.ps1` do npm ("a execução de scripts foi desabilitada", política de execução do Windows). Saídas: trocar o shell do Orca para Prompt de Comando ou Git Bash (usam `codex.cmd`), ou o Gabriel liberar scripts do usuário no PowerShell. Isso é uma configuração de segurança, então quem decide e faz é ele.
- Um ciclo completo (Claude coordena e Codex entrega `worker_done`) ainda não foi testado.
- A telemetria continuava ligada até o fim desta sessão: o Gabriel não achou a opção na configuração inicial.
