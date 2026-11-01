# Level design: o que aprender com Dead Cells, Hollow Knight, Silksong, Ori e Terraria

Pesquisa do Claude em 01/11/2026, pedida pelo Gabriel. Nada aqui é cópia: são ideias de como esses jogos organizam o mundo, para servir de régua ao Two Souls.

**Como ler:** cada item diz de onde veio.
- **[fonte]**: o que a página aberta diz, com o link.
- **[opinião]**: proposta do Claude para o nosso jogo.

O código desses jogos é fechado e **não foi baixado nem consultado**.

## 1. O que cada jogo ensina

### Dead Cells (Motion Twin)

- **[fonte]** O mapa geral é fixo e desenhado à mão. Dentro dele entram "blocos" de salas feitas à mão, com algumas variações cada ([texto do designer-chefe, Sébastien Bénard](https://deepnight.net/tutorial/the-level-design-of-dead-cells-a-hybrid-approach/)).
- **[fonte]** Cada região (bioma) tem um **grafo**:
  - ele diz o tamanho, quantas salas especiais existem e quanto a área é labiríntica;
  - primeiro se colocam a entrada e a saída, depois as salas especiais (tesouro, loja) e por fim as salas de luta e exploração (mesma fonte).
- **[fonte]** Salas de uma região não se repetem em outra. Cada região tem regras de movimento próprias (os esgotos apertados limitam pulo e esquiva).
- **[fonte]** O ritmo alterna **picos de tensão e pausas**, inspirado no "AI Director" de Left 4 Dead.
- **[fonte]** A quantidade de inimigos é proporcional às salas de combate, com regras de onde cada tipo pode ficar.

### Hollow Knight e Silksong (Team Cherry)

- **[fonte]** O terreno é a fechadura e a habilidade é a chave ([análise de terreno](https://ludonauta.itch.io/platformer-essentials/devlog/1084669/the-hidden-genius-behind-hollow-knights-terrain-design)):
  - penhasco alto pede pulo duplo;
  - poço vertical pede escalada;
  - vão largo pede dash;
  - ácido pede imunidade.
- **[fonte]** Toda superfície é sólida e previsível, sem plataformas que se atravessam por baixo. Isso deixa o caminho fácil de ler (mesma fonte).
- **[fonte]** Bancos são checkpoint, cura e lugar de atualizar o mapa ([wiki](https://hollowknight.wiki.fextralife.com/Bench)). Uma crítica aponta que, no primeiro jogo, os bancos ficam longe demais e a volta cansa (mesma página).
- **[fonte]** Em Silksong ([análise do GMTK](https://gmtk.substack.com/p/the-world-design-of-hollow-knight)):
  - são 12 áreas, cada uma com cor e clima próprios;
  - o ato 1 é quase uma linha em "U", com poucas bifurcações;
  - o ato 2 é aberto, com três destinos em qualquer ordem;
  - há muito mais conteúdo opcional do que obrigatório;
  - atalhos e quebras de sequência são permitidos;
  - o mapa começa vazio e as paredes secretas não aparecem nele.
- **[fonte]** A Hornet é mais alta que o Cavaleiro, e isso obrigou a refazer cavernas e passagens ([GameSpot](https://www.GameSpot.com/articles/in-hollow-knight-silksong-hornets-height-changes-everything-says-dev/1100-6485856/)). **O tamanho do personagem manda no tamanho das salas.**
- **[fonte]** O personagem é pequeno na tela para mostrar o cenário em volta ([análise de arte](https://blog.uat.edu/art-analysis-hollow-knight)).
- **Não achei fonte** da Team Cherry dizendo como o mapa é carregado por dentro.

### Ori and the Blind Forest e Will of the Wisps (Moon Studios)

- **[fonte]** O processo de cada fase ([entrevista na Game Developer](https://www.gamedeveloper.com/design/q-a-designing-the-gorgeous-metroidvania-i-ori-and-the-will-of-the-wisps-i-)):
  1. conceito no papel;
  2. blockout com polígonos simples;
  3. jogar e ajustar;
  4. crítica de outros designers, até a fase ser "aprovada";
  5. só então entra a arte.
- **[fonte]** O movimento foi polido por muito tempo. Objetos do cenário (galhos, cordas, projéteis) reagem ao Ori e viram parte do caminho (mesma fonte).
- **[fonte]** Speedrunners foram contratados cedo para achar atalhos não previstos (mesma fonte).
- **[fonte]** O mundo não é baseado em grade e tem mais de 300 fases. Mudar uma coisa pode afetar um ponto longe no mapa (mesma fonte).
- **[fonte]** Críticos elogiam o encadeamento de movimentos: combate, pulo e alavancas formam um fluxo só ([Epilogue Gaming](https://epiloguegaming.com/strikingly-good-level-design-ori-and-the-will-of-the-wisps-impressions/)).

### Terraria (Re-Logic)

- **[fonte]** O mundo é dividido em camadas de profundidade ([wiki oficial](https://terraria.wiki.gg/wiki/Layers)):
  - Espaço, Superfície, Subterrâneo, Cavernas e Submundo;
  - os biomas atravessam as camadas, e a versão "funda" de cada bioma só aparece nas Cavernas.
- **[opinião]** Terraria é mundo aberto gerado e destrutível, um gênero diferente. A ideia útil é a de **profundidade como progressão**: quanto mais fundo, mais perigoso e mais raro.

### Metroidvania em geral

- **[fonte]** Uma tese da Chalmers conclui que habilidades com vários usos ajudam a voltar a áreas antigas com prazer, se a função de cada uma for clara, as pistas no cenário forem consistentes e o caminho principal continuar compreensível ([tese](https://odr.chalmers.se/items/d79d64a8-8f42-4b85-a4f8-5b1b259962b0)).
- **[fonte]** Um guia prático resume o gênero: áreas presas a habilidades, conexões densas, atalhos e um mapa legível para a volta valer a pena ([Bugnet](https://bugnet.io/blog/how-to-design-a-metroidvania-map)).

## 2. Regras para o Two Souls [opinião]

1. **Tela e escala:** tela interna de 960×540, com o Orion de 72 px ocupando 13% da altura, perto do "personagem pequeno, cenário grande" de Hollow Knight. Toda passagem respeita o tamanho do Orion (lição da Hornet): altura mínima de 96 px e degrau máximo de 130 px.
2. **Um mapa só:** o mundo inteiro numa cena, com as áreas nas posições reais do mapa. Andar de uma para outra não tem tela preta e a câmera segue livre. Fora das áreas aparece rocha escura, como em Hollow Knight.
3. **Mapa fixo, salas à mão:** como em Dead Cells e Ori, primeiro o mapa e os bloqueios (já em `world_map.gd`), depois cada sala em blockout cinza, depois teste e só então arte.
4. **Terreno é a fechadura:** cada habilidade abre um tipo de terreno que se reconhece de longe:
   - lança cravada: parede lisa alta;
   - super soco: pedra rachada;
   - onça: vão largo;
   - jiboia: água ou fresta;
   - tatu: terra fofa;
   - gavião: penhasco alto;
   - purificação: corrupção.

   Hoje os bloqueios são blocos laranja provisórios; a tarefa 1.7 troca pelo terreno de verdade.
5. **Superfícies sólidas:** sem plataformas que se atravessam por baixo, como em Hollow Knight. As passagens verticais são buracos onde o pulo alcança a borda de cima.
6. **Grafo e ritmo por região:** cada região alterna pico (luta, desafio de plataforma) e pausa (santuário, tesouro, vista bonita). Todo desafio difícil tem santuário perto, regra que já está no brainstorm.
7. **Identidade de região pelo movimento**, não só pela cor:
   - Copas: verticais e com vãos;
   - Cavernas: apertadas e escuras;
   - Lago: água;
   - Trilha: plataformas de madeira.
8. **Começo quase linear, meio aberto:** como no ato 1 de Silksong, a Clareira e a Trilha guiam. Depois do super soco, várias regiões em qualquer ordem, que é o que o `world_map.gd` já faz com onça, jiboia e tatu.
9. **Profundidade é perigo** (Terraria): as Cavernas profundas e as Raízes Profundas são mais difíceis que a superfície.
10. **Testar cedo:** cada região em blockout é jogada pelo Gabriel antes de qualquer arte.

## 3. Ferramentas abertas que podem ajudar

- **[Metroidvania System](https://github.com/KoBeWi/Metroidvania-System)** (Godot, MIT): editor de mapa em grade, minimapa, transição e save de salas. Avaliação em andamento (`docs/avaliacao-metsys.md`, a escrever). O Gabriel lê antes de instalar.
- **[LDtk](https://github.com/deepnight/ldtk)** (MIT): editor de fases do autor de Dead Cells, segundo fonte de terceiros (o repositório não confirma). Precisa de importador para o Godot. Não avaliado.

## 4. Perguntas em aberto

- Os números de pulo e de altura vêm de cálculo. Só jogando dá para confirmar.
- Quanto do mapa deve ser vertical (Copas, Cavernas) ou horizontal (Trilha, Floresta).
- Se haverá áreas com geração procedural, como em Dead Cells. Pelo brainstorm, não: o mapa é feito à mão.
