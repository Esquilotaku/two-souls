# Ferramentas de IA avaliadas para o Two Souls

Levantamento de 01/11/2026. Dados lidos no GitHub (repositório, licença, README) nesse dia. Nada foi instalado; o Gabriel lê e aprova antes.

Origem: posts do Instagram de 99hud (Orca, Paperclip, Hindsight, AX, Agent Substrate) e guilhermemorais.ia (10 repositórios, incluindo Taskmaster, Spec Kit e Serena). O MCP do Godot é sugestão do Claude, não veio dos vídeos.

PC hoje: Node 22.14, npm 10.9, uv 0.13.4, sem Python instalado (o `uv` baixa o Python que precisar).

## Resumo

| Ferramenta | Serve pra quê no jogo | Custo extra | Minha opinião |
|---|---|---|---|
| godot-mcp | Claude/Codex abrem o Godot, rodam o jogo e leem os erros | nenhum | **Instalar primeiro** |
| Spec Kit | Escrever a especificação antes de programar cada sistema | nenhum | Talvez, depois do brainstorm |
| Serena | Agente navega melhor no código quando ele crescer | nenhum | Depois, quando houver muitos scripts |
| Taskmaster | Quebra o plano em tarefas | **pede chave de API paga** (ou usa Claude Code/Codex) | Não agora; repete o STATUS.md |
| Paperclip | "Empresa" de agentes com cargos e orçamento | nenhum, mas roda servidor | Não agora; pesado pra uma pessoa |

## Detalhes

### godot-mcp — [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp)
- Licença MIT. ~6.460 estrelas. Último commit: 16/04/2026 (6 meses parado; compatibilidade com Godot 4.7.2 **não verificada**).
- Faz: abrir o editor, rodar o projeto em modo debug, capturar saída e erros, criar cenas e nós, carregar sprites, gerenciar UIDs.
- Instala: `claude mcp add godot -e GODOT_PATH=F:\GAME\tools\Godot4.7.2\Godot_v4.7.2-stable_win64_console.exe -- npx @coding-solo/godot-mcp`. Requer Node 18+ (já tem).
- Por que primeiro: hoje o Claude roda o Godot por linha de comando; isso já funciona, mas o MCP deixa rodar e ler erros durante o jogo de forma direta. Ganho moderado, risco baixo.
- Alternativas maiores (não avaliadas a fundo): tugcantopaloglu/godot-mcp (157 ferramentas, commit em 10/2026), youichi-uda/godot-mcp-pro.

### Spec Kit — [github/spec-kit](https://github.com/github/spec-kit)
- Licença MIT, do próprio GitHub. ~144.800 estrelas. Ativo (commit em 30/10/2026).
- Faz: fluxo "especificação → plano → tarefas" antes do código.
- Instala: `uv tool install specify-cli` (precisa Python 3.11+, que o uv baixa).
- Sobreposição: parecido com a skill superpowers (brainstorming → writing-plans) que já está instalada.

### Serena — [oraios/serena](https://github.com/oraios/serena)
- Licença GPL-3.0 (o app) e MIT (parte SolidLSP). ~31.000 estrelas. Ativo (28/10/2026).
- Faz: busca e edição por símbolo (função, classe) em vez de texto, via MCP.
- Instala: `uv tool install -p 3.13 serena-agent`.
- Suporte a GDScript **não verificado**. Com 16 scripts hoje, o ganho é pequeno.

### Taskmaster — [eyaltoledano/claude-task-master](https://github.com/eyaltoledano/claude-task-master)
- Licença "MIT com cláusula própria" (Task Master License) — ler o arquivo LICENSE inteiro antes. ~28.300 estrelas. Último commit 28/04/2026.
- Faz: lê um documento de requisitos e gera tarefas com dependências.
- Instala: `claude mcp add taskmaster-ai -- npx -y task-master-ai`.
- **Custo:** os comandos de IA pedem chave de API (Anthropic, OpenAI, Perplexity…), cobrada à parte. Também aceita usar Claude Code ou Codex sem chave.

### Paperclip — [paperclipai/paperclip](https://github.com/paperclipai/paperclip)
- Licença MIT. ~109.800 estrelas. Muito ativo (commit hoje).
- Faz: servidor Node + painel web que organiza agentes como empresa: cargos, metas, orçamento, aprovações e histórico.
- Instala: `npx paperclipai@latest onboard --yes`. **Exige Node 24.11+** (o PC tem 22.14, teria que atualizar). Cria banco PostgreSQL embutido e roda em `localhost:3100`.
- Combina com a ideia de "montar a empresa com cargos", mas o próprio README diz que é para "rodar um negócio" com vários agentes. Para uma pessoa com Claude e Codex, a regra do `AGENTS.md` cobre o essencial. Reavaliar quando o brainstorm do estúdio definir os cargos.

### Descartados
- Orca: útil só se Claude e Codex trabalharem ao mesmo tempo; hoje se revezam.
- Hindsight, AX, Agent Substrate: feitos para muita escala.
- Ponytail, UI UX Pro Max, Understand Anything, GStack, Trail of Bits, Strix: web, segurança e invasão; fora do escopo do jogo.
- Skill "Apple" (viniciusguimaraes.ia): só por DM, sem repositório para conferir.
