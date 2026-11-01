# Two Souls: Orion's Journey

Projeto de jogo 2D para PC, baseado nos documentos e estudos visuais encontrados em `F:\GAME\twosouls`. O jogo antigo `.capx` não faz parte desta produção: o usuário esclareceu que aquele arquivo era somente um teste de sprites aleatórios.

## Abrir

1. Instale o Godot 4.7.2 estável.
2. Abra `project.godot` pelo Project Manager.
3. Pressione F6/F5 para rodar.

## Direção atual

- Plataforma de ação em pixel art, com parallax em múltiplas velocidades, neblina e luzes mágicas.
- Orion usa lança e magia; depois de reencontrar Aenia, a magia dos gêmeos fica mais forte.
- Direção visual aprovada para Orion e Aenia: a referência `assets/concepts/orion-aenia-approved-reference.png` define o cabelo verde, olhos visíveis, roupa de explorador e lança de Orion; e o cabelo loiro com flores, vestido claro e magia luminosa de Aenia. É referência de design, não arte pronta para gameplay.
- O documento original planejava oito fases e três chefes; a nova campanha terá mais chefes, e o total de fases ainda está em pesquisa.
- Este projeto Godot é um protótipo de produção. Não define a engine final nem representa a campanha completa.

## Exploração planejada

A campanha será uma floresta não linear, dividida em áreas conectadas. Orion explorará trilhas pelo chão, caminhos por cima das copas, cavernas e passagens subterrâneas, além de uma região de lago. Habilidades específicas vão abrir passagens e incentivar o retorno a lugares já visitados. O jogo também terá checkpoints e minimapa; a proposta inicial é revelar o mapa aos poucos, incluindo caminhos em diferentes níveis, enquanto Orion explora. A direção também prevê chefes principais, subchefes e minibosses, poucos puzzles ambientais e desafios de plataforma de precisão inspirados nos *Jump Quests* de MapleStory. Esses sistemas ainda não estão implementados como mundo conectado: os oito corredores e marcadores de checkpoint atuais são apenas estrutura provisória do protótipo.

## Sistemas no protótipo

- Movimento, pulo, ataques, magia, checkpoints, quatro encontros de chefe temporários e camadas de parallax.
- Relógio de 24 horas em ciclo de 15 minutos; os inimigos comuns ficam gradualmente mais resistentes e agressivos à noite. Alguns chefes fixam o horário ao começar o encontro; as horas atuais são provisórias.
- Inimigos deixam orbes de essência; recolhê-las aumenta o XP de Orion. Cada nível concede 1 ponto de talento.
- A bolsa provisória, aberta por I ou pelo menu de pausa, guarda ervas que restauram vida e sementes que restauram magia. Há coletas no cenário e uma chance de consumível em inimigos comuns; os itens são salvos junto com a campanha.
- The Rock e a Árvore Corrompida têm comportamentos próprios de protótipo: soco, pedra e trombeta que chama lanceiros para The Rock; raízes e vinhas para a árvore. O Feiticeiro Encapuzado final tem ataques de magia, golpe de garra e meteoros na segunda fase.
- The Rock agora aparece com o sprite estático em `assets/sprites/the_rock_idle.png`; os indicadores de soco e trombeta continuam sendo desenhados pelo código.
- Orion agora usa `assets/sprites/orion_idle.png` como sprite estático inicial, com filtro nearest e espelhamento ao mudar de direção. `assets/sprites/aenia_idle.png` é usado como companheira flutuante depois do resgate e na tela final; ainda é um único quadro estático.
- Depois da libertação de Aenia, ela acompanha Orion como sprite flutuante sem colisão; a tela final mostra os dois. Ainda faltam animação de movimento e diálogo narrativo completo.
- Pressione E perto de Aenia para abrir uma conversa simples; o texto atual é provisório.
- A árvore de talentos provisória abre com T ou pelo menu de pausa. Ela tem quatro opções: lança arremessada, super soco, +1 de vida máxima e +1 de magia máxima. Cada chefe derrotado concede 1 ponto; o super soco exige aprender a lança primeiro.
- O protótipo grava a campanha localmente nos santuários, após chefes, ao avançar de região e ao obter ou usar consumíveis e talentos. O menu permite continuar; começar uma nova jornada pede confirmação quando há progresso salvo.
- XP, consumíveis, talentos e combate dos chefes são provisórios. As habilidades lembradas do jogo antigo ainda não foram associadas a chefes específicos.

## Limites atuais

O código posiciona The Rock na fase 1 e a árvore na fase 3, mas o criador ainda não confirmou a ordem entre esses chefes. Serpe do Brejo (fase 6) continua genérica; o chefe final encapuzado tem comportamento e silhueta procedurais provisórios. A lista de regiões, a fase de túnel e os períodos de dia/noite ainda não estão alinhados com a lembrança do jogo antigo.

Orion usa um único sprite estático. Aenia aparece como companheira decorativa depois do resgate e na tela final; nenhum dos dois tem spritesheet ou animações. Inimigos e a maioria dos chefes ainda usam desenhos temporários ou não têm sprite de gameplay. As referências aprovadas dos gêmeos e The Rock orientam a produção, mas não substituem arte final. Há uma ilustração de floresta, referências de personagens, mas falta áudio. A árvore atual é um primeiro sistema funcional e provisório; o inventário ainda não tem equipamentos nem itens de missão. O salvamento continua em um único arquivo local, sem integração Steam Cloud.

## Controles

- Andar: A/D ou setas.
- Pular: Espaço, W ou seta para cima.
- Ataque: J ou X.
- Magia: K ou C.
- Bolsa: I.
- Conversar com Aenia após o resgate: E.
- Árvore de talentos: T.
- Lança arremessada: L, depois de aprendida.
- Super soco: U, depois de aprendido.
- Pausar: Esc.

O retrato panorâmico em `assets/mother_tree_forest.png` é uma ilustração nova de direção visual. A referência aprovada dos gêmeos está em `assets/concepts/orion-aenia-approved-reference.png`. Os arquivos antigos continuam intactos em `F:\GAME` e servem como referência.
