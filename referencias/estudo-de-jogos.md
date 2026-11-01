# Estudo de jogos de referência — ferramentas, level design e lições para o Two Souls

Pesquisa feita pelo Claude em 01/11/2026, a pedido do Gabriel. As imagens de cada jogo são baixadas no PC com `pipeline/baixar-referencias.ps1` (ver `referencias/README.md`).

**Legenda:**
- **[fato]**: com fonte linkada. Quando a fonte é wiki, blog ou fórum, aparece como *secundária*.
- **[opinião]**: leitura do Claude, para discutir.
- **Não encontrado / não verificado**: a pesquisa não achou fonte confiável.

> Referência inspira sistemas e ensina técnica. **Não copiar arte, nomes ou fases** (`AGENTS.md`).

---

## 1. Resumo: o que isso muda para o Two Souls

1. **A engine importa menos do que parece.**
   - Os jogos que você admira usam engines diferentes: Unity (Hollow Knight, Silksong, Ori, Blasphemous, Dandara, Kaze), Haxe/Heaps (Dead Cells), XNA/FNA com framework próprio (Celeste), GameMaker (Momodora), Flash com C++ (Castle Crashers) e Gamebryo (Grand Chase).
   - O que faz esses jogos ficarem bonitos é o **fluxo de arte e o design**, não a engine.
   - [opinião] **O Godot serve.** Há jogos comerciais grandes feitos nele (seção 6). O que eu não achei foi um **metroidvania em pixel art famoso, já lançado na Steam, feito em Godot**. Então, nesse gênero, o Two Souls estaria abrindo caminho.
2. **O Aseprite é a ferramenta certa para pixel art.** O time do **Celeste** fez todo o pixel art e a animação do jogo no Aseprite [fato, [Celeste Tools](https://celestegame.tumblr.com/tools)]. Você já tem o Aseprite compilado no PC.
3. **Para quem desenha pouco, existe um caminho testado: o 3D virando pixel.** O **Dead Cells** teve **um único artista no primeiro ano**. Ele modelava e animava em 3D, e um programa próprio renderizava em tamanho minúsculo, sem suavização, gerando quadros em pixel art [fato, [Game Developer: 3D para 2D no Dead Cells](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-), [Game Anim](https://www.gameanim.com/2018/01/31/dead-cells-3d-pipeline-2d-animation/)]. [opinião] Isso pode ser uma alternativa melhor que pedir sprite pronto à IA, que hoje está "saindo ruim". Vale um teste pequeno com o Orion.
4. **O mapa do Hollow Knight começou simples.** Primeiro foram definidas a ordem dos poderes e a forma geral do mundo: quatro áreas com um cruzamento no meio. Depois o mapa foi ficando **menos linear**, e vários bloqueios obrigatórios viraram opcionais [fato, secundária: [Game Developer](https://www.gamedeveloper.com/design/how-the-i-hollow-knight-i-devs-mapped-out-their-metroidvania-), [GoNintendo](https://gonintendo.com/archives/265229-hollow-knight-devs-detail-the-process-of-creating-the-game-s-map)]. É o mesmo caminho que fizemos no brainstorm (A, com um pouco de C).
5. **Diagrama de chaves e fechaduras.** Antes de desenhar salas, faça o **diagrama de "chaves e fechaduras"** do mapa (método Boss Keys, seção 4). Ele mostra onde o jogador fica preso, o que ele já pode explorar e quanto precisa voltar.

---

## 2. Ferramentas por jogo

| Jogo | Engine | Arte e animação | Situação da informação |
|---|---|---|---|
| **Hollow Knight** | Unity, com PlayMaker, TextMesh Pro e 2D Toolkit | toda a arte e as animações desenhadas no **Photoshop**; protótipo feito no Stencyl | [fato] [FAQ da Team Cherry](https://www.teamcherry.com.au/faq), [Unity: Hollow Knight](https://unity.com/made-with-unity/hollow-knight), [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight) |
| **Hollow Knight: Silksong** | Unity (lançado no Unity 6, segundo a Unity) | igual ao anterior, segundo o FAQ | [fato] [Wikipedia](https://en.wikipedia.org/wiki/Hollow_Knight:_Silksong), [FAQ](https://www.teamcherry.com.au/faq) |
| **Ori and the Blind Forest** | Unity, com o editor muito modificado | os artistas montavam, viam e animavam a arte **dentro do editor**; ferramenta própria para editar várias cenas juntas, porque o mundo é contínuo | [fato] [Wikipedia](https://en.wikipedia.org/wiki/Ori_and_the_Blind_Forest), [MCV/Develop](https://mcvuk.com/development-news/unity-focus-making-ori-and-the-blind-forest/) |
| **Ori and the Will of the Wisps** | Unity 2018 | mudaram para um **pipeline 3D integrado ao 2D**; iluminação "pintada" dinâmica | [fato] [PCGamingWiki](https://www.pcgamingwiki.com/wiki/Ori_and_the_Will_of_the_Wisps), [Unity Discussions](https://discussions.unity.com/t/making-of-ori-and-the-will-of-the-wisps-teaser-cinematic-timeline-tools/679729), [Nintendo Life](https://www.nintendolife.com/news/2021/01/feature_moon_studios_on_ori_and_the_will_of_the_wisps_journey_from_xbox_to_switch) |
| **Dead Cells** | **Haxe + Heaps** (engine própria do estúdio, código aberto) | **3ds Max**: modelo 3D simples e esqueleto, animação à mão, render minúsculo sem suavização, PNG com normal map e shader "toon" | [fato] [Heaps](https://heaps.io/about.html), [Deepnight](https://deepnight.net/games/motion-twin/dead-cells/), [Game Developer](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-) |
| **Celeste** | XNA/FNA (MonoGame) com o framework **Monocle**, em C# | **Aseprite** (pixel art e animação); Clip Studio (conceitos); **Ogmo Editor** (fases); Blender (tela do mapa); Ableton Live (música); FMOD (som) | [fato] [Celeste Tools](https://celestegame.tumblr.com/tools), [PCGamingWiki](https://www.pcgamingwiki.com/wiki/Celeste) |
| **Blasphemous 1 e 2** | Unity (2017 e 2021) | animação **pixel a pixel**, à mão; plugin **PowerSprite Animator** para levar as animações ao Unity | [fato] [Kickstarter do estúdio](https://www.kickstarter.com/projects/828401966/blasphemous-dark-and-brutal-2d-non-linear-platform/posts/1899193), [PCGamingWiki](https://www.pcgamingwiki.com/wiki/Blasphemous_2). Um site cita Aseprite e Photoshop, mas por suposição: **não verificado** ([Foro3D](https://foro3d.com/en/2026/february/blasphemous-2-how-unity-powers-its-pixel-art-world.html)) |
| **Castle Crashers** | Flash com C++ e ferramentas próprias | arte desenhada no **Flash** com mesa digitalizadora (Dan Paladin) | [fato] [GameDev.net](https://gamedev.net/tutorials/industry/interviews/the-behemoth-r2353), [Game Developer](https://www.gamedeveloper.com/design/taunting-the-behemoth-tom-fulp-and-dan-paladin-cry-out), [Wikipedia](https://en.wikipedia.org/wiki/Dan_Paladin) |
| **Grand Chase** | **Gamebryo** | não encontrado | [fato, secundária] [Wikipedia](https://en.wikipedia.org/wiki/Grand_Chase), [Wikidata](https://www.wikidata.org/wiki/Q487975). Engine do Grand Chase Classic e do Dimensional Chaser: **não encontrada** |
| **Momodora: Reverie Under the Moonlight** | GameMaker Studio 1 | não encontrado | [fato, secundária] [Wikipedia](https://en.wikipedia.org/wiki/Momodora:_Reverie_Under_the_Moonlight), [fórum Steam](https://steamcommunity.com/app/428550/discussions/0/135512305400387052/) |
| **Owlboy, Axiom Verge** | base MonoGame (engines próprias) | não encontrado | [fato, secundária] [gist sobre engines próprias](https://gist.github.com/raysan5/909dc6cf33ed40223eb0dfe625c0de74?permalink_comment_id=4192381) |
| **Katana ZERO, Hyper Light Drifter** | GameMaker | não encontrado | [secundária] listas de blogs ([sprite-ai](https://www.sprite-ai.art/blog/best-game-engines-pixel-art)). **Não verificado** em fonte primária |
| **Shovel Knight** | engine própria; o jogo é 2D, mas a engine é 3D | não encontrado | [fato, secundária] [PC Gamer](https://www.pcgamer.com/shovel-knight-developer-yacht-club-games-is-working-on-a-3d-project/) |
| **Titan Souls** | saiu do Flash para uma "engine nova", **sem nome nas fontes** | não encontrado | [fato] [Wikipedia](https://en.wikipedia.org/wiki/Titan_Souls). Engine: **não encontrada** |
| **Sea of Stars** | Unity | não encontrado | [secundária] [wiki](https://seaofstars.fandom.com/wiki/Sea_of_Stars) |
| **Dandara** (Brasil) | Unity | não encontrado | [fato] [Wikipedia](https://en.wikipedia.org/wiki/Dandara_(video_game)) |
| **Kaze and the Wild Masks** (Brasil, PixelHive) | Unity 5 | não encontrado | [fato] [PCGamingWiki](https://www.pcgamingwiki.com/wiki/Kaze_and_the_Wild_Masks), [Steam](https://steamcommunity.com/app/829280/discussions/0/1697169163396348140/), [SOEDESCO](https://www.soedesco.com/news/kaze-and-the-wild-masks-to-be-published-by-soedesco) |

---

## 3. Estudo por jogo: o que olhar e o que levar para o Two Souls

### Hollow Knight e Silksong (mapa, exploração, HUD)

**Fatos:**
- **Começar simples:** primeiro a ordem dos poderes e a forma do mundo; depois menos linearidade, com bloqueios obrigatórios virando opcionais ([Game Developer](https://www.gamedeveloper.com/design/how-the-i-hollow-knight-i-devs-mapped-out-their-metroidvania-)).
- **Primeiras áreas:** quatro áreas com o cruzamento no meio ([PC Gamer](https://www.pcgamer.com/how-to-design-a-great-metroidvania-map/)).
- **Do lugar para a fase:** Pellen diz que eles partem do **conceito de um lugar** (exemplo: "caverna com um lago") e preenchem os detalhes, em vez de jogar plataformas num espaço vazio ([Mundo Gamer](https://mundogamer.community/en/articles/understand-how-team-cherry-created-the-world-of-hollow-knight)).
- **Mapa comprado:** o mapa é comprado de um cartógrafo (Cornifer). O jogo começa **sem mapa, sem bússola e sem marcador**, e preencher o mapa vira parte do jogo ([Super Jump](https://www.superjumpmagazine.com/getting-lost-by-design-in-hollow-knight/), [wiki](https://hollowknight.wiki/w/Cornifer); secundárias).

**[opinião] Para o Two Souls:**
- Já decidimos o **minimapa revelado conforme se anda**. Fica em aberto se haverá também um mapa "comprado" ou "achado" por região. É uma decisão a tomar no marco 1.
- Desenhe cada região a partir de **uma frase de lugar**: "Lago: águas escuras com raízes da Árvore Mãe no fundo". Só depois desenhe as salas.

### Ori 1 e 2 (mundo contínuo, fugas, beleza)

**Fatos:**
- **Mundo sem cortes:** o mundo do Ori é contínuo, e o estúdio criou uma ferramenta para editar várias cenas juntas e ver as transições ([MCV/Develop](https://mcvuk.com/development-news/unity-focus-making-ori-and-the-blind-forest/)).
- **Fugas:** são sequências isoladas em que a área desaba ou alaga. Os críticos dividem opinião: há quem veja como "provas finais" e há quem ache tentativa e erro demais ([Gamecritics](https://gamecritics.com/mike-suskie/ori-and-the-blind-forest-review/), [Steam](https://steamcommunity.com/app/261570/discussions/0/458606877309244752/)).
- **Testes antes de programar:** o estúdio fez vídeos de protótipo dos movimentos e animatics com música antes de produzir ([Postmortem](https://www.gamedeveloper.com/audio/postmortem-moon-studios-heartfelt-i-ori-and-the-blind-forest-i-)).

**[opinião] Para o Two Souls:**
- **Transições:** o Godot carrega sala por sala, como decidimos. A lição é **testar as transições cedo**.
- **Uma fuga:** o resgate de Aenia no Coração Corrompido, com a árvore desabando, seria um lugar natural para uma fuga. Ela precisa de um santuário perto, que é a sua regra.

### Dead Cells (combate, salas, arte com pouca gente)

**Fatos:**
- **Mapa híbrido:** o mapa geral e a ordem dos biomas são **desenhados à mão**. Dentro de cada fase, o jogo monta **pedaços feitos à mão** de forma procedural, com regras: primeiro a entrada e a saída, depois as salas especiais, depois o resto ([devlog na IndieDB](https://www.indiedb.com/games/dead-cells/news/the-level-design-of-a-procedurally-generated-metroidvania), [80.lv](https://80.lv/articles/interview-with-the-developers-of-dead-cells)).
- **Arte em 3D:** usa o pipeline de 3D para pixel descrito na seção 1.

**[opinião] Para o Two Souls:**
- O Two Souls é feito à mão, mas a ideia de **pedaços de sala reaproveitáveis por região**, com o mesmo tileset e variações, economiza muito tempo de construção.
- **Teste sugerido:** modelar um Orion simples em 3D, no Blender, que é grátis, e renderizar em 64 a 80 px. Comparar com o rascunho da IA.

### Celeste (plataforma de precisão, a referência para os Jump Quests)

**Fatos:**
- **Telas como desafios:** cada tela é um pequeno desafio fechado ([Play Journal](https://theplayjournal.com/celeste-review/)).
- **Janela de perdão:** o pulo ainda funciona um instante depois de sair da borda, o chamado *coyote time* ([Vice](https://www.vice.com/en/article/celeste-difficulty-assist-mode/)).
- **Modo de assistência:** existe, mas o jogo padrão é a experiência pensada ([Vice](https://www.vice.com/en/article/celeste-assist-mode-change-and-accessibility/)).
- **Desafios opcionais:** os "lados B" reaproveitam as mecânicas de cada capítulo em versões mais difíceis.
- **Ferramentas:** Aseprite e Ogmo Editor ([Celeste Tools](https://celestegame.tumblr.com/tools)).

**[opinião] Para o Two Souls:**
- Os **desafios de precisão** (as Copas e os segredos) devem ser **telas curtas e fechadas**, com santuário perto, que é a sua regra.
- **Coyote time** e "guardar o pulo apertado um instante" desde o primeiro protótipo.
- Os **modos História, Aventura e Desafio** fazem o papel do modo de assistência.

### MapleStory: Jump Quests (a sua referência original)

**Fatos (secundária, guias de comunidade):**
- **Exemplos conhecidos:** os mais famosos são os do Shumi, no metrô de Kerning City, com fios elétricos, lasers e manchas de óleo, e o **John's Deep Forest of Patience**, com 7 fases, considerado um dos mais difíceis ([StrategyWiki](https://strategywiki.org/wiki/MapleStory/Quests/Jump_Quests), [Wikibooks](https://en.wikibooks.org/wiki/MapleStory/Quests/Jump_Quests), [meowdb](https://meowdb.com/msclassic/guides/jump-quests)).
- **Regras próprias:** em alguns, a velocidade e o pulo são fixos no padrão, e as habilidades de movimento ficam desligadas.

**[opinião] Para o Two Souls:**
- **Velocidade fixa** em certos desafios, por exemplo sem a onça, garante que o desafio funcione igual para todos.
- **Recompensa:** o prêmio é um item único ou uma runa rara.

### Blasphemous (pixel art detalhado, chefes)

**Fato:** animação **pixel a pixel, à mão**, levada ao Unity com um plugin de animação ([Kickstarter](https://www.kickstarter.com/projects/828401966/blasphemous-dark-and-brutal-2d-non-linear-platform/posts/1899193)).

**[opinião]** É a melhor referência de **pixel art detalhado em resolução alta**, parecida com os 640×360 do Two Souls. Estude os chefes e a leitura dos ataques.

### Castle Crashers (combate cômico, cooperativo)

**Fato:** desenhado no Flash, com ferramentas próprias ([GameDev.net](https://gamedev.net/tutorials/industry/interviews/the-behemoth-r2353)). **Não é pixel art.**

**[opinião]** A referência é o **humor e o exagero das animações**. Combina com o D Rock tirando a trombeta e com o grito "D ROCKKKK!".

### Grand Chase (combos, a sua referência de skills)

**Fato:** a engine é a Gamebryo ([Wikipedia](https://en.wikipedia.org/wiki/Grand_Chase)).

**[opinião]** A referência é o **combo com a skill no final**, que é a sua transformação automática no fim do combo. Também o meteoro da Arme, para o feiticeiro.

### Titan Souls (chefes)

**Fato:** saiu do Flash para uma engine nova; o protótipo tinha 3 titãs e o jogo final 16 ([Wikipedia](https://en.wikipedia.org/wiki/Titan_Souls)).

**[opinião]** A referência são **chefes que se leem pelo padrão**, com arena simples. Útil para os 16 confrontos do Two Souls.

### Dandara e Kaze (Brasil)

**Fato:** os dois foram feitos em Unity por estúdios brasileiros, Long Hat House e PixelHive ([Wikipedia](https://en.wikipedia.org/wiki/Dandara_(video_game)), [PCGamingWiki](https://www.pcgamingwiki.com/wiki/Kaze_and_the_Wild_Masks)).

**[opinião]** Mostram que jogo brasileiro em pixel art vende lá fora. Bons para o discurso de marketing.

---

## 4. Princípios de level design de metroidvania (método para o Two Souls)

**Fatos (método Boss Keys, de Mark Brown, do canal Game Maker's Toolkit):**
- **Origem:** a série analisou primeiro as masmorras de Zelda e, na 2ª temporada (2018), os **mapas de metroidvania** ([Wikipedia: GMTK](https://en.wikipedia.org/wiki/Game_Maker's_Toolkit)).
- **Diagramas:** usa diagramas com **chaves (losangos) e fechaduras (quadrados)** que mostram as ligações, os bloqueios, quanto o jogador precisa voltar e o "espaço explorável" enquanto ele está travado ([Boris the Brave](https://www.boristhebrave.com/2021/02/27/lock-and-key-dungeons/), [Kudzu](https://www.gamedeveloper.com/design/zen-and-the-art-of-retro-level-design-in-kudzu-), [Metroidvania Review](https://steamcommunity.com/groups/MetroidvaniaReview/discussions/0/1743342383226164241/)).

**[opinião] Como aplicar:**
1. **Diagrama das habilidades.** Montar o diagrama do mapa do Two Souls com as 7 habilidades como chaves: lança, soco, onça, jiboia, tatu, gavião e purificação.
2. **Espaço explorável.** Para cada momento travado, contar quantas salas o jogador ainda pode explorar. Se for pouco, ele se sente preso; se for demais, se perde.
3. **Atalho de volta.** Toda habilidade nova deve abrir **pelo menos um atalho de volta** para um lugar conhecido. É a sua regra dos atalhos com pista.
4. **Desenho de cada região:**
   - frase de lugar;
   - salas-chave (santuário, chefe, segredo, desafio de precisão);
   - ligações;
   - só então os detalhes.
5. **Ferramenta:** o Celeste usou o **Ogmo Editor** para as fases. No Godot o equivalente é o próprio TileMap. Há também o editor externo **LDtk**, do mesmo autor do Dead Cells (Sébastien Bénard), mas **isso não foi pesquisado agora; verificar antes de adotar**.

---

## 5. HUD (o que comparar nas imagens)

[opinião] Checklist para olhar nas capturas baixadas:
- **Hollow Knight:** a vida em máscaras e a "alma" num recipiente, no canto superior esquerdo, ocupando pouco espaço.
- **Blasphemous:** barra de vida e de fervor e os frascos de cura.
- **Dead Cells:** barra de vida mais os espaços de arma e de skill embaixo. É a referência para os **espaços de runa** e o **R da transformação** com recarga.
- **Celeste:** quase nenhum HUD. Para os **desafios de precisão**, vale esconder a interface.

O Two Souls tem a vida em **pedras rúnicas**, a barra de **fôlego**, a magia, o **ícone do animal no R com a recarga** e o relógio. É bastante coisa: comparar com o Hollow Knight para ver como mostrar tudo isso ocupando pouco.

---

## 6. Godot: o que já foi feito com a engine do Two Souls

**Fatos (secundárias, números são estimativas):**
- **Brotato:** mais de 10 milhões de cópias até 2025, segundo uma fonte ([gamedesignskills](https://gamedesignskills.com/game-design/famous-godot-games/)).
- **Cassette Beasts:** publicado pela Raw Fury ([godotawesome](https://godotawesome.com/godot-games-table/)).
- **Road to Vostok:** migrou do Unity para o Godot e ficou entre os mais vendidos da Steam na semana de lançamento, em abril de 2026 ([Wikipedia](https://en.wikipedia.org/wiki/Road_to_Vostok)).
- **Metroidvanias em pixel art feitos em Godot** apareceram só no itch.io e no GitHub (Toziuha Night, Enkhirydion, PerlaKnight). **Não confirmei nenhum lançado na Steam** ([itch.io: Godot e metroidvania](https://itch.io/games/made-with-godot/tag-metroidvania), [PerlaKnight](https://github.com/IsjaslawEisenstadt/PerlaKnight)).

[opinião] O Godot aguenta jogo comercial. Para um metroidvania, o que precisa ser bem feito é o **carregamento de salas** e o **mapa**, e é isso que o marco 1 começa.

---

## 7. Próximos passos sugeridos

1. **No PC:** rodar `pipeline/baixar-referencias.ps1` e conferir o `INDICE.md`.
2. **Escolher de 3 a 5 jogos de referência de arte** com o personagem do tamanho parecido com o Orion. Blasphemous e Momodora são bons candidatos [opinião].
3. **Teste de arte:** comparar o rascunho da IA, o 3D renderizado (como no Dead Cells) e o desenho à mão no Aseprite, com uma pose só do Orion parado.
4. **Fazer o diagrama de chaves e fechaduras do mapa** antes da tarefa 1.2 do quadro.
