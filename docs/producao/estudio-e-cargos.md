# Two Souls — estúdio e cargos

Brainstorm entre o Gabriel e o Claude, 01/11/2026.

**Legenda de origem:**
- **[Gabriel]**: decisão do Gabriel.
- **[proposta]**: sugestão do Claude aprovada.
- **[opinião]**: avaliação do Claude.
- **Não verificado**: não conferido com fonte.

## Princípio

**Sem freelancers pagos. Tudo é feito pelo Gabriel e pelas IAs** [Gabriel]. A única exceção que ainda pode ser necessária é a contabilidade e o jurídico, que serão decididos no `plano-de-negocio.md`.

## Cargos

| Cargo | Quem | Ferramenta |
|---|---|---|
| Direção criativa | **Gabriel**, com a palavra final em tudo | caderno, `docs/` |
| Produção (planejamento, STATUS, tarefas) | **Claude** organiza, **Gabriel** aprova | `Two Souls/STATUS.md`, `docs/producao/TAREFAS.md` (a criar), GitHub |
| Programação | **Codex e Claude**, em branches separados | Godot 4.7.2, GDScript, GitHub Actions |
| Game design e roteiro | **Gabriel** cria, **Claude/Fable** escrevem e organizam | `docs/` |
| Arte e animação | **Gabriel e IA** (fluxo abaixo) | Codex (imagem), Aseprite |
| Música | **IA de música**, com o Gabriel escolhendo e editando [Gabriel] | a definir |
| Efeitos sonoros | bibliotecas com licença conferida, ou IA | a definir |
| Testes (QA) | **Gabriel** joga; teste automático a cada envio; a comunidade testa a demo | Godot, GitHub Actions |
| Marketing e conteúdo | **Gabriel** é o rosto no canal Esquilo Otaku; **Claude** escreve roteiros e textos | YouTube, Steam |
| Comunidade | **Gabriel**, com textos de apoio da IA | Discord |
| Tradução | IA traduz; **voluntários da comunidade** e quem testa a demo revisam | — |
| Contabilidade e jurídico | a decidir no plano de negócio | — |

## Fluxo de arte [Gabriel]

1. O Gabriel desenha os conceitos no caderno e faz algumas referências em pixel art à mão.
2. A IA faz rascunhos de sprites a partir dessas referências. O Gabriel considera o Codex bom para imagem; isso é a experiência dele, não foi testado nesta sessão.
3. Os rascunhos se juntam ao conjunto de sprites já compilado.
4. O Gabriel finaliza no **Aseprite**, com os ajustes finos.

**Folha de estilo fixa** [opinião]: paleta, tamanho do Orion (64 a 80 px numa tela de 640×360), espessura do contorno e regras das formas animais (pretas com detalhes verdes). A IA recebe essa folha a cada pedido, para manter a consistência entre quadros.

**Pontos de atenção:**
- Toda geração de imagem, música ou voz paga deve ser avisada antes, com quanto e onde (regra do AGENTS.md).
- A **declaração de conteúdo gerado por IA na Steam** e os **termos de uso comercial** das ferramentas de música ainda serão conferidos com fonte (bloco 4).

## Coordenação dos agentes

**Decisão (opção A)** [Gabriel]: continuar com o `AGENTS.md`, com estas melhorias:

1. Criar `docs/producao/TAREFAS.md`, o quadro de tarefas: quem pegou cada tarefa, o estado e o branch.
2. Acrescentar ao `AGENTS.md` qual agente cuida de qual cargo, conforme a tabela acima.
3. **Criar agentes especializados conforme a necessidade** [Gabriel]:
   - Regra [proposta]: só quando uma tarefa se repetir umas 3 vezes.
   - Formato: arquivo de instruções no repositório, como um agente em `.claude/agents/` ou uma skill, lido pelo Gabriel antes do primeiro uso.

### Paperclip: avaliado e adiado

**O que as fontes dizem:**
- Código aberto (MIT), roda no próprio computador como servidor Node.js com tela de controle ([site](https://paperclip.ing/), [docs](https://paperclip.ing/docs)).
- Organograma de agentes com cargos e chefias, e teto de gasto mensal por agente ([Better Stack](https://betterstack.com/community/guides/ai/paperclip-multi-agent/), [Abduzeedo](https://abduzeedo.com/paperclip-open-source-ai-agent-orchestration-builders)).
- Agentes que acordam em horários marcados e agem sozinhos, com pausa e interrupção pelo operador ([DEV Community](https://dev.to/arshkharbanda2010/paperclip-the-open-source-platform-that-lets-you-run-a-company-with-ai-agents-i7b)).
- Muito novo; uma fonte data o código aberto em janeiro de 2026 ([jimmysong.io](https://jimmysong.io/ai/paperclip)).
- **Não verificado:** qual é o repositório oficial no GitHub. Os resultados mostram endereços diferentes e cópias.

**Por que foi adiado** [opinião]:
- Foi feito para muitos agentes trabalhando sozinhos. O projeto tem um humano e de 2 a 3 agentes acionados sob demanda.
- Agentes que acordam sozinhos podem gastar crédito sem supervisão.
- Instalar um servidor de terceiros exige a leitura prévia do Gabriel (AGENTS.md).

**Quando reavaliar:** se o número de agentes crescer ou se o Gabriel quiser agentes trabalhando sozinhos. Nesse caso, testar primeiro num projeto pequeno separado (opção B).

## Alternativas descartadas

- **Freelancers** (animação de chefes, música, revisão nativa): o Gabriel não quer pagar.
- **Gabriel fazendo toda a arte à mão:** gargalo de animação. Foi adotado o fluxo IA + ajuste fino.
- **Adotar o Paperclip agora:** ver acima.

## Perguntas em aberto

- Qual ferramenta de IA de música usar, e os termos de uso comercial dela.
- Fonte dos efeitos sonoros.
- Se a contabilidade pode ser feita sozinha (depende do tipo de empresa).
- Quais agentes especializados criar primeiro.
