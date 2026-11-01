# Vídeos de referência — o que cada um ensina para o Two Souls

Pesquisa do Claude, 01/11/2026. Transcrições lidas via vidIQ, com autorização do Gabriel. Os links abrem no YouTube.

**Legenda:**
- **[vídeo]**: o que o autor diz no vídeo.
- **[opinião]**: leitura do Claude para o Two Souls.

---

## 1. Vídeos que o Gabriel mandou

### "3 meses criando meu jogo RPG com IA" — Ninefir (Jean)
[Link](https://www.youtube.com/watch?v=fOblpuZNAUI) · 16 min · out/2026 · RPG em pixel art, GameMaker e Codex

**O que ele faz:** [vídeo]
- **Programação:** o Codex faz toda a programação, e ele só desenha.
- **Animação:** **desenha um quadro à mão e pede à IA para gerar os outros quadros** da mesma animação, depois ajusta à mão ("ela erra bastante, mas adianta muito").
- **Personagem modular:** cada equipamento é uma camada com os próprios quadros, então dá para trocar capacete ou espada sem redesenhar o personagem inteiro.
- **Cenário:** a IA faz uma **primeira versão** ("suja, craquelada") e ele **sempre finaliza à mão**: "tem que ter o meu estilo... é o meu jogo, não o jogo da IA".
- **Bugs:** guarda os bugs num **Trello**, com um print de cada; a IA lê e corrige depois.
- **Planejamento do mapa:** usava o Milanote, que é pago. Pediu à IA para criar uma ferramenta própria de quadro de mapa.
- **Custo:** paga uns R$550 a 600 por mês num plano alto do ChatGPT.

**[opinião] Para o Two Souls:**
- É **exatamente o fluxo que o Gabriel escolheu** (`docs/estudio-e-cargos.md`).
- A diferença que importa: **ele desenha o primeiro quadro à mão**. É isso que mantém o estilo. Pedir o sprite inteiro à IA tende a "sair ruim".
- O **Trello de bugs** é o mesmo papel do `docs/TAREFAS.md`.

### "Como CRIAR personagens com IA que funcionam no seu JOGO" — Carlos Wendell (Noru)
[Link](https://www.youtube.com/watch?v=MmuPhqADyj0) · 19 min · out/2026 · RPG top-down, Unity e PixelLab

**O fluxo dele** (da descrição do vídeo), passo a passo:
1. Pensar no contexto do personagem.
2. Explorar a ideia no ChatGPT.
3. Levar a referência ao **PixelLab** ([pixellab.ai](https://www.pixellab.ai/)).
4. Criar uma base consistente.
5. Gerar as rotações.
6. Gerar a caminhada e a corrida.
7. Reaproveitar os quadros bons.
8. Fazer separadamente as animações difíceis.
9. Ajustar no **Aseprite**.
10. Testar no jogo.

**Dicas principais:** [vídeo]
- **"Não peça tudo de uma vez para a IA."** Primeiro a **pose** (por exemplo, o escudo levantado) e só depois a **animação andando nessa pose**. Pedido junto, a IA troca a arma, a mão e a proporção.
- **Lado bom:** escolha o lado em que o personagem mostra mais (escudo e armas visíveis), gere a partir dele e **espelhe** para o outro lado.
- **Erros aproveitados:** quadros "errados" às vezes viram ataques novos.
- **Velocidade do golpe:** menos quadros dão um golpe mais rápido; mais quadros, um golpe mais suave.
- **Créditos gastos aprendendo:** ele diz ter gastado de **200 a 300 créditos** jogados fora até aprender essas dicas. Conta própria: uns US$9 por 2.000 créditos no PixelLab (**valor dito por ele, não verificado**).
- **Mapa:** "não dá para deixar a IA criando o mapa, fica horrível". Ele monta o mapa no **Tiled**, com os inimigos como objetos que a engine lê.
- **HUD:** fez o HUD **à mão**, porque o feito por IA ficou simples e estranho.
- **Economia de tokens:** usa o **GitHub** para a IA não precisar reler o projeto inteiro.

**[opinião] Para o Two Souls:**
- **Pose separada da animação:** vale para o **combo com transformação**. Primeiro a pose do Orion no fim do golpe, depois a passagem para o animal.
- **Espelhar** é natural num jogo de lado, que só precisa de um lado.
- **PixelLab:** o jogo dele é visto de cima, com 8 direções. **Não verifiquei** se o PixelLab funciona bem para personagens de lado, de plataforma. Antes de assinar, testar com o crédito grátis e avisar o custo (regra do AGENTS.md).

---

## 2. Vídeos encontrados na pesquisa (os mais úteis)

### Design de mundo e mapa

**"The World Design of Hollow Knight: Silksong" — Game Maker's Toolkit (Boss Keys)**
[Link](https://www.youtube.com/watch?v=l7xXW0EbK4g) · 1h05 · dez/2025

- **Ato 1 quase linear:** uma sequência apertada de chefes e habilidades. Cada "chave" abre poucas "fechaduras", e a fechadura que avança a história fica **logo depois da chave**. [vídeo]
- **Rotas alternativas escondidas:** dá para pular chefes por caminhos secretos ou comprando uma chave cara. Há **duas formas de terminar o Ato 1**: um chefe difícil, ou um caminho de exploração com um chefe mais fácil. [vídeo]
- **Ato 2 aberto:** três objetivos em qualquer ordem, e uma habilidade que pode ser obtida por **dois caminhos**. [vídeo]
- **Ritmo "sanfona":** o jogo alterna trechos lineares e abertos, e isso mantém o interesse. [vídeo]
- **Conteúdo opcional enorme:** **20 chefes obrigatórios e 25 opcionais**, na contagem dele. Quem trava num chefe pode explorar, ficar mais forte e voltar. [vídeo]
- **Mapa por cartógrafo:** cada área começa sem mapa, que é comprado e preenchido no banco. O mapa mostra as **passagens ainda não exploradas**, o que permite "cutucar o mapa" para achar o caminho. Há **marcadores**. [vídeo]
- **Paredes secretas:** mais de 50, **fora do mapa** até serem achadas. Áreas inteiras ficam escondidas, e há **duas entradas** para as mais importantes. [vídeo]
- **Perder dinheiro ao morrer:** ele **critica** o sistema em metroidvania, porque faz o jogador voltar sempre ao mesmo lugar em vez de explorar outro. [vídeo]
- **Mapa que conta a história:** o mapa conta a história (subir das profundezas até a cidadela). [vídeo]

**[opinião] O que isso confirma nas decisões do Two Souls:**
- **Morrer sem perder nada** (tema 1, item 7): bate com a crítica dele.
- **Segredos de recompensa fora do mapa e atalhos de volta com pista:** é o que o Silksong faz.
- **Habilidades:**
  - a **ordem do 1.0** (lança → soco → onça → jiboia e tatu em qualquer ordem → gavião → purificação) reproduz o "linear depois aberto";
  - **sugestão nova:** dar uma **segunda rota** para pelo menos uma habilidade importante, como o tatu, alcançável por dois caminhos.
- **Desafio alternativo:** dar a pelo menos um chefe obrigatório uma **alternativa de exploração** para quem travar. Por exemplo, um caminho secreto que evita o subchefe do Túnel.

**"Why You (Probably) Didn't Get Lost in Metroid Dread" — Game Maker's Toolkit**
[Link](https://www.youtube.com/watch?v=5pop-cc9kmY) · 17 min

Quatro técnicas para o jogador não se perder [vídeo]:
1. **Pontos sem volta:** quedas, portas que fecham atrás e frestas de um lado só prendem o jogador numa parte pequena do mapa. Assim ele tem menos lugares para procurar.
2. **Fechadura perto da chave:** a fechadura que avança fica no mesmo bioma da chave, enquanto ainda está "fresca na memória".
3. **Viagem rápida:** quando a fechadura está longe, um teletransporte leva até perto dela.
4. **Migalhas de pão:** itens e inimigos atrás de paredes puxam o jogador para o caminho certo.

- **O outro lado:** usar demais deixa o jogo "guiado" e frustra quem gosta de explorar. Ele terminou com 39% dos itens. [vídeo]

**[opinião] Para o Two Souls:**
- **Usar com moderação:** os modos História e Aventura podem ter **mais migalhas**.
- **Falta decidir a viagem rápida.** Ver `checklist-do-jogo.md`.

**"How to Design GREAT Metroidvania Levels" — LazyTeaStudios** · [Link](https://www.youtube.com/watch?v=RISNX2USJvk) · 20 min, um passo a passo em 4 etapas. Não li a transcrição.

**"How to Design Great Metroidvania Levels" — Goodgis** · [Link](https://www.youtube.com/watch?v=bAHXYfP38CA) · 7 min, feito por um dev que usa Godot. Não li a transcrição.

**Série Boss Keys** (Super Metroid, Symphony of the Night, Hollow Knight, Dark Souls): [Hollow Knight](https://www.youtube.com/watch?v=7ITtPPE-pXE), [Super Metroid](https://www.youtube.com/watch?v=nn2MXwplMZA), [Symphony of the Night](https://www.youtube.com/watch?v=a1hHOVIkrcc), [Dark Souls](https://www.youtube.com/watch?v=QhWdBhc3Wjc). Não li as transcrições.

**"Making Ori and The Will of the Wisps' Best Level"** · [Link](https://www.youtube.com/watch?v=gIdHTL18kTU), uma entrevista com o level designer. Não li a transcrição.

### Metroidvania feito em Godot (o mais parecido com o Two Souls)

**"Making a Massive Metroidvania Map (The Right Way)" — Inbound Shovel (Isadora's Edge, Godot)**
[Link](https://www.youtube.com/watch?v=FI0-yz5Xcz0) · 17 min · jan/2026

- **MetSys:** ele testou o **MetSys** (addon de metroidvania para Godot), mas não serviu para o que queria e fez o próprio sistema. [vídeo]
- **Organização do mapa:** [vídeo]
  - uma **cena única do mapa do mundo**, com "salas de mapa" que apontam para as cenas das salas de verdade;
  - **"transições"** com um ID cada;
  - as ligações entre salas são definidas **só no mapa do mundo**.
- **Erros clássicos de transição:** [vídeo]
  - trocar de sala antes de o personagem sair da tela;
  - área de gatilho menor que o corredor, que deixa o jogador "escapar";
  - aparecer no ar na sala nova.
  - **Solução dele:** desenhar no editor os limites da câmera e o tamanho da transição.
- **Carregamento:** só a sala atual fica na memória, e já é rápido. Pré-carregar as vizinhas fica para depois. [vídeo]
- **Desenho do minimapa:** encolher o cenário inteiro **derrubou de 2.500 para 40 quadros por segundo**. A solução foi uma **camada de tiles própria do mapa**, invisível no jogo. [vídeo]
- **Estilo antes do código:** decidir o **estilo visual do mapa antes** de programar como ele revela as áreas. [vídeo]

**[opinião]** É **a referência técnica mais importante para a tarefa 1.1** (plano técnico do mundo interligado). Ler antes de programar.

**"How Metroidvania Cameras are Shockingly Different than Platformer Cameras" — Inbound Shovel** · [Link](https://www.youtube.com/watch?v=drbatB2KWlo) · 20 min. Não li a transcrição. Assunto: câmera de metroidvania em Godot.

**"I made a pixel style Hollow Knight in Godot"** · [Link](https://www.youtube.com/watch?v=7hBDyPOqoHY). Não li a transcrição.

### Animação em pixel art (para o fluxo do Gabriel)
- **Saultoons**, tutorial de animação em pixel art no Aseprite: referência, poses-chave, smear frames, timing ([link](https://www.youtube.com/watch?v=iWvfaiiVuDI)); ciclo de caminhada ([link](https://www.youtube.com/watch?v=7T6yOk5n-zk)).
- **Penusbmic**, ataque suave com quadros-chave e intermediários ([link](https://www.youtube.com/watch?v=KS837a-TFRc)). Ele também é artista de jogos comerciais.
- **AdamCYounis**, corrida para jogo de lado, em várias passadas ([link](https://www.youtube.com/watch?v=LPBvrdJ_1a8)).
- **Pixel Overload**, "segredos da boa animação em pixel art": timing, planejamento, movimento ([link](https://www.youtube.com/watch?v=J1sFBDQt8J0)).

Não li as transcrições destes; ficam como lista de estudo.

### Em português
- **"O Jeito CERTO de USAR IA pra CRIAR JOGOS" — MagmaDev** ([link](https://www.youtube.com/watch?v=tibV8bHCTcQ), 47 min, set/2026). Li parte da transcrição. [vídeo]:
  - **Protótipo não é jogo:** protótipo em HTML não é jogo de verdade.
  - **"Cara de IA":** a Steam está cheia de jogos com "cara de IA", e ele não usa assets de IA no jogo final, só como placeholder.
  - **Cortar trabalho manual:** use a IA para **cortar o trabalho manual**, não para substituir a criação.
  - **Animação a partir de 3D:** **baixar uma animação 3D pronta (Mixamo), tirar quadros de referência de pose e ângulo** e mandar **essa referência junto com o personagem** para a IA de imagem gerar o sprite sheet. Assim os pés e as poses ficam no lugar certo. Ele criou com IA uma ferramenta que exporta esses quadros.
- **Lua Lúdica:** dev brasileiro com jogos na Steam. Guia de pixel art ([link](https://www.youtube.com/watch?v=f8AGVBXJbnI)), que recomenda as paletas do Lospec, e "não comece a criar jogos em 2026 sem ver isso" ([link](https://www.youtube.com/watch?v=_q6yrR_bNSE)). Não li as transcrições.

**[opinião] A técnica do MagmaDev combina com o Dead Cells:**
- **Dead Cells:** animação 3D renderizada em pixel ([`estudo-de-jogos.md`](estudo-de-jogos.md)).
- **Teste sugerido para o Orion:**
  1. pegar uma corrida e um ataque com lança no Mixamo (grátis);
  2. tirar quadros de referência;
  3. o Gabriel desenha **um** quadro do Orion por cima;
  4. a IA gera os outros quadros usando a pose 3D como guia;
  5. o Gabriel ajusta no Aseprite.

---

## 3. Lições juntas (resumo para o Gabriel)

1. **Sprite:**
   - o primeiro quadro à mão, para manter o estilo;
   - a IA preenche o resto, com uma **referência de pose** (3D ou um desenho seu);
   - ajuste final no Aseprite.
2. **Uma coisa por vez para a IA:** primeiro a pose, depois o movimento.
3. **Mapa e HUD à mão** (os dois devs dizem que a IA faz mal). A IA ajuda a **programar** o mapa, não a desenhá-lo.
4. **Mapa do Two Souls:**
   - fechadura perto da chave;
   - segredos fora do mapa;
   - **duas rotas** para o que é importante;
   - **alternativa** para quem travar num chefe;
   - sem perder nada ao morrer (já decidido).
5. **Godot:** cena única do mapa do mundo, transições com ID, camada de tiles própria para o minimapa.
