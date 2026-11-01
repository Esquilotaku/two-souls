# Two Souls — checkpoint de desenvolvimento

Atualizado em 17/10/2026. Este arquivo registra o estado de trabalho para uma pausa e retomada. O objetivo continua sendo desenvolver o jogo completo para preparação e lançamento na Steam; o projeto atual ainda é um protótipo e não está perto de pronto para lançamento.

## Estado do projeto

- Projeto Godot em `F:\GAME\Two Souls`, aberto como protótipo de plataforma 2D.
- O README e o plano do jogo são os documentos de contexto atuais. A engine final, a campanha, o escopo e as referências ainda precisam ser validados com o criador.
- Não houve verificação de execução ou testes nesta etapa.

## Já existe no protótipo

- Movimento, pulo, combate corpo a corpo e magia, checkpoints, HUD, pausa, salvamento local e oito corredores procedurais.
- Os checkpoints são marcadores simples nos corredores atuais; ainda não existe um minimapa.
- Parallax procedural, luzes mágicas e uma barreira de corrupção atacável.
- Quatro encontros provisórios: The Rock, Árvore Corrompida, Serpe do Brejo e Feiticeiro Encapuzado.
- Inimigos comuns, orbes de XP, itens consumíveis e inventário simples.
- Árvore de talentos provisória com lança, super soco, vida máxima e magia máxima.
- The Rock e Orion usam sprites estáticos; depois do resgate, Aenia acompanha Orion com um sprite flutuante sem colisão, aparece na tela final e pode ser chamada para uma conversa simples com E. A maior parte dos demais personagens ainda é desenhada por formas temporárias.
- A habilidade de meteoros foi atribuída ao chefe final encapuzado, conforme a lembrança do criador; The Rock fica com socos, pedras e trombeta. O chefe final agora tem golpes de garra, projéteis de magia e meteoro na fase baixa de vida, além de uma silhueta procedural provisória.
- O criador aprovou como direção visual de Orion e Aenia a referência `assets/concepts/orion-aenia-approved-reference.png`: olhos visíveis, silhuetas e roupas descritas no plano do jogo. A imagem foi copiada para o projeto e gerou os primeiros sprites estáticos; ainda faltam spritesheets e animações de gameplay.
- `assets/sprites/orion_idle.png` está conectado em `scripts/player.gd`, usa filtro nearest e espelha a imagem conforme a direção. `assets/sprites/aenia_idle.png` é usado como companheira decorativa depois do resgate e na tela final; ainda faltam animação, diálogo e interação.

## História e direção visual confirmadas pelo criador

- Orion e Aenia são gêmeos ligados à proteção da floresta de Monte Ligna. O feiticeiro sequestra Aenia e deixa Orion desacordado; Orion parte para resgatá-la e impedir a corrupção da floresta.
- O início era de manhã. Há lembrança de uma fase de túnel, da árvore corrompida perto do pôr do sol e do chefe final à noite; a ordem exata entre The Rock e a árvore ainda está em aberto.
- The Rock é um guardião tribal que testa Orion, luta sem camisa, usa máscara com penas e trombeta, soca, arremessa pedras e chama lanceiros; depois pode tornar-se aliado. Ao vencê-lo, Orion recebe um super soco. Lançar lanças também é uma habilidade lembrada.
- A árvore corrompida usa raízes e vinhas. O último chefe lembrado é um lagarto ou dragão encapuzado, com ataque de meteoros.
- O material original inclui `F:\GAME\twosouls\Cut Scenes.docx`, imagens antigas de Aenia e cenas dos gêmeos, e o projeto atual contém a referência aprovada de The Rock. O `.capx` encontrado é um teste separado de sprites aleatórios, segundo o criador.

## Direção nova de exploração confirmada pelo criador

- A floresta deve ser explorada por áreas interconectadas; o jogo não será uma campanha linear de fases em fila.
- Algumas rotas começam bloqueadas e só poderão ser atravessadas ao obter uma habilidade específica. O jogador deve poder voltar a áreas já conhecidas para abrir caminhos.
- O jogo terá checkpoints e minimapa. Como proposta inicial, o minimapa revela as áreas percorridas e indica conexões, bloqueios e checkpoints; detalhes de interface ainda estão em aberto.
- A floresta precisa oferecer bastante exploração em diferentes ambientes e alturas: trilhas no chão, percursos pelas copas das árvores, cavernas/subterrâneos e um lago. A distribuição e as mecânicas desses locais ainda não foram definidas.
- O criador pediu um relógio que avance durante a exploração, dificuldade dos inimigos acompanhando a hora, e alguns chefes que façam o horário saltar para um momento narrativo exato. Pediu também chefes principais, subchefes e minibosses, poucos puzzles ambientais pontuais e desafios de plataforma de precisão no estilo dos *Jump Quests* de MapleStory.

## Lacunas que impedem considerar o jogo completo

- Campanha e ordem dos níveis ainda não foram aprovadas; a fase de túnel e os horários do dia precisam ser integrados ao percurso.
- O resgate é representado provisoriamente ao concluir a sexta região: o jogo libera a magia dos gêmeos e passa a mostrar Aenia seguindo Orion. Ainda não há sequência de sequestro ou resgate nem cena de reencontro; a única fala é uma conversa curta acionada por E.
- O chefe final encapuzado, a árvore de progressão completa, os aliados, os inimigos e os encontros ainda precisam de design e implementação de produção.
- Faltam spritesheets e animações de Orion e Aenia, falas e interação narrativa para a companheira, além da arte final de inimigos, chefes, cenários e efeitos; a conversa atual é provisória e o material permanece majoritariamente de protótipo.
- Inventário não tem equipamentos, itens de missão ou economia; faltam áudio, acessibilidade, opções, localização, créditos e integração com Steam/Steam Cloud.
- Salvamento local, balanceamento, controles, desempenho, exportação e preparação de lançamento ainda precisam de revisão e validação.
- O protótipo agora tem um ciclo de 24 horas em 15 minutos, iniciado às 07:00. A noite aumenta gradualmente vida, velocidade e ritmo de ataque dos inimigos comuns; The Rock, a árvore corrompida e o chefe final saltam provisoriamente para 10:00, 18:00 e 22:00 ao iniciar a luta. A duração, os horários e o balanceamento são valores de protótipo, ainda sem validação em jogo.

## Próximo passo recomendado

Reprojetar a progressão como um mundo de áreas interconectadas, com caminhos que exigem habilidades, checkpoints e minimapa revelado pela exploração. Planejar chão, copas, cavernas, subterrâneos e lago, além de puzzles pontuais e desafios de precisão. Criar encontros de chefe principal, subchefe e miniboss. O protótipo atual ainda é linear e deve ser tratado como andaime, não como estrutura final. Depois, revisar a sequência narrativa do prólogo ao confronto final e calibrar o relógio contínuo e os saltos de horário dos chefes.

## Ponto de retomada desta sessão

- Pausa registrada quando o Codex atingiu 90% de uso consumido (10% restante), conforme combinado; o objetivo completo de preparar Two Souls para lançamento na Steam permanece preservado.
- `scripts/game.gd` agora avança o relógio de 07:00 por um ciclo de 24 horas em 15 minutos, altera a iluminação do mundo e salta para horários provisórios nas lutas de The Rock (10:00), Árvore Corrompida (18:00) e chefe final (22:00).
- `scripts/foe.gd` ajusta vida, velocidade e ritmo de ataque dos inimigos comuns conforme a pressão noturna; `scripts/save_manager.gd` foi atualizado para a versão 4 e migra campanhas anteriores começando o relógio às 07:00.
- Atributos `boss_tier` começaram a separar chefe principal e subchefe, mas ainda não existem lutas de miniboss e os subchefes não têm mecânicas próprias.
- O relógio e as alterações de código não foram executados no Godot nesta etapa; horários, ciclo e balanceamento continuam provisórios.
- Próxima tarefa: substituir o avanço sequencial por uma rede de áreas transitáveis, com bloqueios por habilidade, pontos de checkpoint independentes e minimapa de áreas exploradas. Depois, integrar os ambientes de chão, copas, cavernas/subterrâneos e lago, mais puzzles pontuais e desafios de plataforma de precisão.

## Arquivos principais

- `README.md` — como abrir o protótipo, controles e sistemas atuais.
- `scripts/game.gd` — fluxo de campanha, regiões, interface e progresso.
- `scripts/player.gd` — Orion, combate, itens e talentos.
- `scripts/boss.gd` — comportamentos provisórios de chefes.
- `scripts/save_manager.gd` — salvamento local.
- `Two Souls - Plano do Jogo.md` em `F:\GAME` — decisões e perguntas de design.
- `F:\GAME\twosouls\Cut Scenes.docx` — descrição original das cenas.

## Ponto de retomada — 01/11/2026 (Claude)

- A pasta `F:\GAME` agora é um repositório git (branch `main`). As regras de trabalho entre Claude e Codex estão em `F:\GAME\AGENTS.md`: ler este STATUS ao começar, commits pequenos com prefixo `[claude]` ou `[codex]`, atualizar esta seção e commitar antes de passar a vez.
- Verificação feita: o projeto **não compilava**. `foe.gd:47` e `boss.gd:83/164/265` usavam `var horizontal_distance :=` com valor sem tipo; trocado por `: float =`. Também foi preciso rodar `--import`, porque os sprites novos e o `ItemPickup` ainda não estavam no cache do Godot.
- Depois da correção, o projeto carrega e roda 600 quadros sem janela (`--headless --quit-after 600`) sem erro. Isso **não** testa gameplay: ninguém jogou, apertou botões ou chegou nos chefes.
- Próximo passo de código continua o mesmo: mundo de áreas interconectadas. Antes disso o Gabriel quer um brainstorm de design (modelo Fable, crédito de nuvem ainda a confirmar).

## Ponto de retomada — 01/11/2026, tarde (Claude)

- Repositório privado no GitHub: `Esquilotaku/two-souls`. O GitHub Actions abre o jogo sem janela a cada envio e roda `tests/test_aseprite_frames.gd`.
- Aseprite 1.3.18.6 compilado em `C:\dev` e integrado (ver seção "Arte com Aseprite" no `AGENTS.md`). Primeiro arquivo: `art/orion.aseprite` (tag `idle`), exportado para `assets/sprites/orion.png/.json` e carregado com sucesso por `AsepriteFrames`. Ainda **não** está ligado ao `player.gd`, que continua usando `orion_idle.png`.
- Atenção de arte: `orion_idle.png` tem 1218×1291 px, é ilustração e não sprite de pixel art. Antes das animações é preciso decidir a resolução dos personagens (ex.: 32–64 px de altura) e redesenhar no Aseprite.
- Os PSDs originais não abrem no Aseprite; precisam ser exportados em PNG.
- Um brainstorm completo (jogo, estúdio/cargos, plano de negócio) roda numa sessão na nuvem e deve entregar em `docs/` no branch `claude/brainstorm-mundo`.

## Ponto de retomada — 01/11/2026 (Claude, brainstorm de design)

- Branch `claude/brainstorm-mundo`. Brainstorm de design com o Gabriel; nenhum código de jogo foi alterado.
- **Bloco 1 concluído:** `docs/brainstorm-mundo-interligado.md`. Decisões principais:
  - mapa único com alturas híbridas;
  - mapa grande lançado por partes (1.0 com 8 regiões, 12 a 18 h);
  - rede de cavernas sob o mapa, atalhos de volta com pista e segredos escondidos;
  - santuários fixos, que só valem se ativados; morrer não tira nada;
  - 5 habilidades (lança cravada → super soco → pulo duplo e mergulho em qualquer ordem → purificação);
  - The Rock antes da árvore, que guarda Aenia (decisão da refeitura);
  - o feiticeiro vira o lagarto na 2ª fase;
  - 16 lutas (3 + 5 + 8);
  - vários dias com descanso no santuário e modos História, Aventura e Desafio (Desafio todo à noite);
  - demo do início até vencer The Rock.
- **Bloco 2 concluído:** `docs/brainstorm-jogo.md`. Destaques:
  - Árvore Mãe narradora; folclore brasileiro nos subchefes;
  - 7 habilidades com espíritos animais (onça, jiboia, tatu, gavião-real);
  - runas purificáveis; XP só para a árvore de talentos;
  - pixel art 640×360; trilha brasileira;
  - controles setas, Espaço, A, S e QWER (R = transformação escolhida por runa);
  - US$14,99; PT-BR e inglês.
  - As habilidades mudaram em relação ao bloco 1; o doc do mundo tem um aviso "Revisado no bloco 2".
- **Bloco 3 concluído:** `docs/estudio-e-cargos.md`. Sem freelancers, só Gabriel e IAs. Coordenação pelo AGENTS.md, mais `docs/TAREFAS.md` (a criar), e agentes por cargo quando a tarefa se repetir. Paperclip adiado.
- **Bloco 4 concluído:** `docs/plano-de-negocio.md`. Decisões:
  - pessoa física primeiro, conferindo o MEI e consultando um contador antes do lançamento;
  - Steam Direct US$100; US$14,99 com desconto de lançamento até cerca de US$9,99;
  - **The Rock passou a se chamar "D Rock"**, porque Dwayne Johnson é dono da marca; falta buscar no USPTO e no INPI;
  - sem freelancers; Claude Pro e ChatGPT Go;
  - **sem data**: o foco é o jogo completo, e a demo será só um recorte para o Next Fest;
  - página da Steam, Discord e posts só quando o jogo estiver pela metade;
  - canal Esquilo Otaku, que é de anime, só com menções.
- **Brainstorm completo.** Os 4 documentos estão em `docs/`, cada um com uma lista de perguntas em aberto.
- **Próximo passo sugerido:**
  1. criar `docs/TAREFAS.md` e a linha de cargos no `AGENTS.md`;
  2. depois, programar o marco 1 (mundo interligado, santuários, minimapa) a partir dos documentos.
- **Não verificado:** nada foi rodado no Godot; o documento é só de design. O protótipo continua linear.
- **Ligação com a nota de arte acima:** o brainstorm decidiu a resolução como **pixel art 640×360, com Orion de uns 64 a 80 px** (`docs/brainstorm-jogo.md`, seção 5). As formas animais são pretas com detalhes verdes.

## Ponto de retomada — 01/11/2026, noite (Claude, nuvem)

- O brainstorm foi juntado ao `main` ([PR #1](https://github.com/Esquilotaku/two-souls/pull/1)).
- **Feito:**
  - criado `docs/TAREFAS.md`, o quadro de tarefas com os marcos, a arte e as decisões pendentes;
  - o `AGENTS.md` ganhou a seção "Quem faz o quê", os documentos de `docs/` na lista de arquivos e a regra de marcar e atualizar tarefas no quadro.
- **Pendente (O.1):** o Gabriel quer usar o **Orca** (`stablyai/orca`, app de desktop que roda Claude Code e Codex lado a lado) e a skill de orquestração dele. **Nada foi instalado.** Pela regra do AGENTS.md, o Gabriel lê antes; a instalação é feita na **sessão do PC**, onde os agentes rodam.
- **Próximo passo:** tarefa 1.1 do quadro, o plano técnico do mundo interligado.

## Ponto de retomada — 01/11/2026, noite (Claude, PC, tarefa O.1)

- Branch `claude/brainstorm-mundo`. O `main` local só foi avançado até o `origin/main`.
- **Feito:**
  - o Orca 1.4.245 foi instalado no PC;
  - a skill `orchestration` foi instalada pelo próprio Orca para o Claude e o Codex;
  - detalhes, conferências e ressalvas estão em `docs/orca.md`, e há uma linha de uso no `AGENTS.md` (seção "Como verificar");
  - a O.1 está marcada como feita no quadro.
- **Verificado:** `orca status` ok, a skill aparece no Claude Code, e `orca skills get orchestration` e `orca orchestration run-list` funcionam.
- **Não verificado:**
  - se o Codex enxerga a skill (ela está em `~/.agents/skills`, sem link em `~/.codex/skills`). Depois disso foi instalado o **Codex CLI 0.166.0** (`npm -g @openai/codex`): logado com ChatGPT e `codex doctor` sem falhas. Ainda falta abrir o Codex pelo Orca;
  - um ciclo completo Claude → Codex → `worker_done`;
  - a telemetria do Orca continua **ligada**: o Gabriel precisa desligar em Settings → Privacy.
- **Fora do git:** a pasta `txt/` (notas do Gabriel) continua sem commit; falta decidir se entra.
- **Próximo passo:** testar o Orca com uma tarefa pequena, por exemplo o Claude pedir ao Codex uma revisão e receber o resultado. Depois, a tarefa 1.1, o plano técnico do mundo interligado.
