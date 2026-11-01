# Two Souls — regras para agentes (Claude Code, Codex e outros)

Este arquivo vale para qualquer agente de IA que trabalhe nesta pasta. Responda em português do Brasil.

## Onde está o quê

- `Two Souls/` — projeto Godot 4.7.2 (o jogo). Abrir `project.godot`.
- `Two Souls/STATUS.md` — **bilhete de passagem compartilhado**: estado atual, o que falta, próximo passo.
- `Two Souls - Plano do Jogo.md` — decisões de design e perguntas em aberto.
- `Two Souls - Pesquisa Inicial.md` — pesquisa e fontes.
- `twosouls/` e os `.psd` na raiz — material original da faculdade. Só leitura: nunca editar, mover ou apagar.
- `tools/Godot4.7.2/` — executável do Godot (fora do git).

## Regra de passagem entre agentes

Claude e Codex não trabalham ao mesmo tempo nos mesmos arquivos.

1. **Ao começar:** leia `Two Souls/STATUS.md` e rode `git status` e `git log --oneline -10`. Se houver mudança não commitada que você não fez, pare e pergunte ao Gabriel.
2. **Durante:** faça commits pequenos, um por mudança que faça sentido sozinha. A mensagem começa com quem fez: `[claude] ...` ou `[codex] ...`.
3. **Ao parar** (fim da tarefa, cota acabando ou troca de agente): atualize a seção "Ponto de retomada" do `STATUS.md` (o que fez, o que não foi verificado, próximo passo) e faça commit. Nunca deixe mudança sem commit ao passar a vez.
4. Trabalho em paralelo só em branches separados (`claude/...`, `codex/...`), e quem junta é o Gabriel.

## Como verificar

- Checar se o projeto carrega sem erro de script:
  `tools/Godot4.7.2/Godot_v4.7.2-stable_win64_console.exe --headless --path "Two Souls" --quit`
- O repositório privado `Esquilotaku/two-souls` roda o mesmo teste no GitHub Actions a cada `git push` (`.github/workflows/godot-check.yml`). Envie seus commits ao terminar e confira se o teste passou.
- "Pronto" só depois de rodar e conferir o resultado. Se não rodou, escreva no STATUS que não foi verificado.

## Limites

- Não instale plugin, addon ou script de terceiros sem o Gabriel ler antes.
- Não gaste crédito pago (APIs, geração de imagem, voz) sem dizer quanto e onde antes.
- O jogo é uma refeitura de um projeto original do Gabriel e de amigos. Referências de outros jogos inspiram sistemas, não são para copiar arte, nomes ou fases.
