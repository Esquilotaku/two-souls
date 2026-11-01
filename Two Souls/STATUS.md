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
  - se o Codex enxerga a skill (ela está em `~/.agents/skills`, sem link em `~/.codex/skills`). Depois disso foi instalado o **Codex CLI 0.166.0** (`npm -g @openai/codex`): logado com ChatGPT e `codex doctor` sem falhas. Depois de o Gabriel liberar scripts no PowerShell (RemoteSigned, só o usuário dele), o Orca abriu o Codex e ele **confirmou que vê a skill** em `~/.agents/skills`. O Orca abre o Codex em "YOLO mode", sem aprovação de comandos (ver `docs/orca.md`);
  - um ciclo completo Claude → Codex → `worker_done`;
  - a telemetria do Orca continua **ligada**: o Gabriel precisa desligar em Settings → Privacy.
- **Fora do git:** a pasta `txt/` (notas do Gabriel) continua sem commit; falta decidir se entra.
- **Próximo passo:** testar o Orca com uma tarefa pequena, por exemplo o Claude pedir ao Codex uma revisão e receber o resultado. Depois, a tarefa 1.1, o plano técnico do mundo interligado.

## Ponto de retomada — 01/11/2026, noite (Claude, tarefa A.1)

- Branch `claude/folha-estilo`, saído de `claude/brainstorm-mundo`.
- **Feito (aprovado pelo Gabriel):** `docs/folha-de-estilo-orion.md`. Decisões:
  - paleta de 28 cores, com pele, cabelo, túnica e couro medidos na referência aprovada (`Two Souls/art/orion-paleta.gpl`);
  - Orion com 72 px de altura, quadro de 128×96, pé em (64, 88);
  - contorno de fora de 1 px quase preto e, nas formas animais, verde-escuro;
  - 6 animações, 29 quadros a 12 por segundo: `idle` 6, `run` 8, `jump` 3, `fall` 2, `attack` 6, `dash` 4.
- `pipeline/new-orion.lua` cria um `.aseprite` vazio nesse padrão: modo indexado com a paleta travada, as tags, as camadas `corpo`, `lanca` e `guia` (escondida). Não sobrescreve arquivo existente.
- **Verificado:** o script rodou no Aseprite e o arquivo gerado foi reaberto e conferido (tamanho, modo, 29 cores, tags e faixas, duração de 83 ms, guia escondida). O export no formato do `export-aseprite.ps1` sai com as 6 tags, e a guia não entra no PNG. A recusa de sobrescrever também foi testada. O Godot carrega sem erro (`--headless --quit`).
- **Não verificado:**
  - nenhum quadro foi desenhado;
  - as cores de metal, olho e animais são propostas, não medidas;
  - o `aseprite_frames.gd` ainda ignora o `"repeat": "1"` das tags que não repetem (fica para a A.3).
- `art/orion.aseprite` (ilustração antiga) não foi mexido.
- **Próximo passo:** A.3, o Orion básico desenhado num arquivo gerado pelo script e ligado ao `player.gd`.
## Ponto de retomada — 01/11/2026 (Codex, tarefa A.3)

- Branch `codex/orion-basico`, derivado de `claude/folha-estilo`; a A.3 está marcada em andamento no quadro.
- A ferramenta de imagem integrada gerou seis folhas de rascunho (idle, run, jump, fall, attack e dash), sem API ou serviço cobrado. Foram usadas 6 imagens geradas. Os PNGs estão em `Two Souls/art/rascunhos/`; a ilustração anterior foi preservada como `orion-ilustracao-antiga.aseprite`.
- A CLI Aseprite criou o esqueleto `Two Souls/art/orion.aseprite` com 29 quadros e seis tags, mas não abriu os PNGs para montagem. A conversão pela interface foi iniciada, mas só o rascunho idle virou `.aseprite`; o run ficou aberto para salvar. O arquivo atual de destino ainda não tem os sprites desenhados.
- **Não verificado/não feito:** desenho final e indexação dos quadros, export `orion.png`/`orion.json`, integração no player, tratamento de `repeat`, testes Godot e de frames, execução do jogo, push e Actions.
- **Próximo passo:** retomar a conversão/montagem das folhas no Aseprite, conferir a paleta e os pivôs e só então integrar e rodar as verificações. A arte precisa ser mostrada ao Gabriel; a A.3 deve passar a “esperando Gabriel” depois da conclusão técnica.

## Ponto de retomada — 01/11/2026 (Codex, A.3 concluída para revisão)

- Branch `codex/orion-basico`, criado sobre `claude/folha-estilo`. A A.3 está em **esperando Gabriel** para revisar a arte.
- Usei 6 imagens geradas pela ferramenta integrada do ChatGPT/Codex; nenhuma chave de API nem serviço cobrado. As seis folhas PNG brutas estão em `Two Souls/art/rascunhos/`, junto da ilustração antiga preservada como `orion-ilustracao-antiga.aseprite`.
- `Two Souls/art/orion.aseprite` agora tem 29 quadros 128×96, em modo indexado com a paleta aprovada, seis tags e contorno externo de 1 px. `assets/sprites/orion.png` e `orion.json` foram exportados; o JSON confirma idle/run/jump/fall/attack/dash com 6/8/3/2/6/4 quadros.
- `player.gd` usa `AnimatedSprite2D`, escolhe idle/run/jump/fall/attack, espelha pela direção e alinha o pivô (64,88) ao pé da colisão. A função `start_dash_animation()` fornece a entrada visual para dash; o protótipo ainda não tinha ação/estado de dash existente para chamar essa função.
- `aseprite_frames.gd` lê `repeat="1"` como animação sem loop e usa o loop padrão nas tags sem esse campo.
- **Verificado:** após importar os recursos no editor headless, `Godot --headless --path "Two Souls" --quit` carregou sem erros; `tests/test_aseprite_frames.gd` passou (1 JSON, 0 falhas); o jogo rodou com `--quit-after 600` sem erro. A inspeção Aseprite confirmou 29 quadros, 3 camadas (`guia` oculta), 27 cores opacas usadas da paleta indexada e 6 tags com as faixas corretas.
- **Pendente:** o Gabriel precisa avaliar a arte; não foi feita revisão visual dentro do jogo. Também falta enviar o branch e conferir o GitHub Actions. Se o dash for ativado no protótipo, ligar a ação de gameplay a `start_dash_animation()`.

## Ponto de retomada — 01/11/2026 (Codex, correção A.3)

- Branch `codex/orion-basico`, continuado de `368babc`. A A.3 continua **esperando Gabriel**.
- Reaproveitei os mesmos 6 rascunhos PNG (nenhuma imagem nova gerada nesta correção). A conversão calibra cada folha pelo tamanho da cabeça e aplica correção residual por quadro para a cabeça ficar uniforme; o fator de saída comum é `72/567 = 0,126984`. Fatores de folha: idle `1,000000`, run `1,574150`, jump `0,992281`, fall `0,777554`, attack `1,433705`, dash `1,452605`.
- `orion.aseprite` está em modo indexado na paleta aprovada, 29 quadros nas tags idle/run/jump/fall/attack/dash (6/8/3/2/6/4), quadro 160×96 e pivô (64,88). A largura foi ampliada de 128 para 160 para a lança do dash caber; a lança está na camada `corpo` e `lanca` segue vazia. O contorno externo é reconstruído em 1 px da cor de índice 1.
- Medição pelo script: corpo do idle e das outras folhas entre 72 e 73 px; cabeça projetada 24,5 px em todos os quadros. Foram removidas 65 ilhas soltas, 33 com menos de 20 px; ficaram 0 ilhas desconectadas. Conteúdo projetado cabe nos 160×96 quadros.
- Na física: colisão passou a 22×66; gravidade, velocidade horizontal, aceleração, pulo e recuos do jogador foram multiplicados por 3 para acompanhar a escala integral. Reposicionei os spawns no chão, baixei o limite superior da câmera, ampliei os alcances de ataque e ajustei o teste de colisão dos projéteis inimigos e a tolerância vertical do inimigo de tiro.
- Mundo inspecionado: o piso e as plataformas abertas não têm teto físico baixo; `tunnel_layer.gd` é decorativo e não está instanciado no protótipo. Alcances de ataque de chefe e velocidades de inimigos/chefes não foram balanceados jogando; as plataformas mais altas, passagens visuais e proporção do personagem em movimento não foram validadas com controle manual.
- **Verificado:** Aseprite CLI refez o arquivo e exportou o PNG/JSON; Godot 4.7.2 headless abriu o projeto, `tests/test_aseprite_frames.gd` passou (1 JSON, 0 falhas) e o jogo rodou com `--quit-after 600`, sem erros de script.
- **Pendente:** enviar o branch e conferir o GitHub Actions; não foi feito teste manual jogando. A aprovação visual da arte continua com o Gabriel.

## Ponto de retomada — 01/11/2026, noite (Claude, marco 1: estrutura do mundo)

- Branch `claude/estrutura-mundo`, saído de `codex/orion-basico` (o Orion de 72 px). A arte foi pausada a pedido do Gabriel; a A.3 segue esperando revisão.
- **Feito:**
  - 1.1: plano técnico em `docs/plano-tecnico-mundo.md` (salas, portas, habilidades, santuários, save 5, controles, quem faz o quê).
  - 1.2: o jogo deixou de ser 8 corredores em fila. Agora são **22 salas do mapa completo do 1.0** em blocos cinzas (`scripts/world/world_map.gd` e `world_room.gd`), com portas nos 4 lados, transição escurecendo a tela, bloqueios laranja por habilidade, ganchos pós-1.0 fechados, chefes e subchefes provisórios e altares.
  - 1.3: santuários (`scripts/world/shrine.gd`): ativar com E, descansar, morrer volta ao último ativado sem perder nada.
  - Save versão 5 com sala, santuário, salas visitadas, habilidades e chefes; save 4 migra para o início da Clareira mantendo nível, itens e talentos.
  - Corrigidos: Orion deslocava 32 px ao virar; câmera sem nome (os limites não eram aplicados); o save nunca era lido de volta porque o JSON devolve números decimais (o "Continuar" nunca aparecia).
  - CI roda todos os `tests/test_*.gd`.
- **Codex (pelo Orca):** fez a 1.6 no branch `codex/controles` (`input_config.gd`, `ui/controls_menu.gd`, teste próprio; Actions verde segundo ele). **Ainda não foi ligado no jogo**: precisa juntar o branch e chamar o `InputConfig` no `game.gd`. Não conferi o código dele.
- **Verificado:** `tests/test_world_map.gd` (22 salas, todas alcançáveis na ordem das habilidades), `tests/test_world_flow.gd` (jogo sozinho: 48 passagens de porta, bloqueio, santuário, morte, continuar, migração), `test_aseprite_frames.gd`, 600 quadros sem erro. Fotos de 4 salas conferidas.
- **Não verificado:** ninguém jogou com teclado. Pulo, escadas automáticas, alcance das portas de cima, chefes nas salas novas e balanceamento são cálculo, não jogo. Os subchefes ainda usam o chefe genérico. Os rascunhos do Codex ganharam `.gdignore` para o Godot não importá-los.
- **Próximo passo:** o Gabriel joga e junta os branches; depois ligar os controles da 1.6, minimapa (1.4), relógio com descanso e modos (1.5) e as mecânicas reais dos bloqueios (1.7).
## Ponto de retomada — 01/11/2026 (Codex, tarefa 1.6)

- Branch `codex/controles`. Implementados `scripts/input_config.gd`, `scripts/ui/controls_menu.gd` e `tests/test_input_config.gd`; a 1.6 está esperando Claude integrar a tela e chamar `InputConfig` no `game.gd`.
- Padrões de controle: pulo A (inferior), ataque X (esquerdo), dash B (direito), lança LB, super soco RB, magia LT, transformação RT, interação Y, contexto RS, cura LS, mapa View, inventário Xbox/Guide e talentos/Pausa Menu. Movimento também usa direcional e analógico esquerdo. Setas para olhar, Espaço para pular, A/S/QWER, D/F, Enter, Tab/I/T e Esc no teclado.
- Testados: carregamento headless do projeto, `tests/test_input_config.gd` e `tests/test_aseprite_frames.gd`; todos passaram. O GitHub Actions passou no run `41350609632`. Ainda não foi testado por pessoa apertando teclas nem com controle físico.
- Próximo passo: Claude integrar no `game.gd`, incluindo carregamento das configurações e abertura/fechamento do menu; depois Gabriel validar os controles em teclado e controle físico.

## Ponto de retomada - 01/11/2026 (Codex, runas)

- Branch `codex/runas`, criado a partir do topo de `claude/estrutura-mundo`. A tarefa 1.8 foi implementada em `scripts/runes/rune_catalog.gd`, `scripts/runes/rune_state.gd`, `scripts/ui/rune_menu.gd` e `tests/test_runes.gd`; explicacao leiga em `docs/runas.md`.
- Proposta: 10 runas, 2 espacos iniciais, maximo de 6, tres niveis e custos de 3 e 6 fragmentos por melhoria. Valores ainda provisórios conforme pergunta O.2 e precisam de balanceamento.
- Verificado: importacao do projeto, teste dedicado `test_runes.gd`, carregamento headless apos importacao e testes automatizados. Sem teste manual de gameplay.
- Integracao no save, concessao das runas/fragmentos e aplicacao dos bonus nas habilidades ficam para Claude; tarefa 1.8 aguarda essa ligacao.
- Proximo passo: enviar o branch, conferir o GitHub Actions e integrar o RuneState no save e fluxo do jogo.
