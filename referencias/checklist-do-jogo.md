# Two Souls — tudo o que o jogo precisa ter (checklist)

Montado pelo Claude em 01/11/2026 a partir do brainstorm (`docs/`) e da pesquisa (`referencias/`).

**Estado de cada item:**
- ✅ **decidido**: aprovado pelo Gabriel no brainstorm.
- ❓ **pendente**: falta decisão do Gabriel.
- 🆕 **novo**: a pesquisa mostrou que é importante e o brainstorm não cobriu.
- 📌 **obrigatório para a Steam ou a acessibilidade**: com fonte.

---

## 1. Movimento e combate

- ✅ Correr, pular, atacar com a lança (combo), magia; dash e esquiva com fôlego.
- 🆕 **Coyote time e buffer de pulo.** O Celeste usa janelas de perdão ([Vice](https://www.vice.com/en/article/celeste-difficulty-assist-mode/)). Há controladores prontos com isso ([código aberto](codigo-aberto-godot.md)).
- 🆕 **Hit-stop e knockback** no golpe, para dar peso ([CodingQuests](https://github.com/CodingQuests/godot-hitbox-hurtbox)).
- 🆕 **Invencibilidade curta depois de levar dano.**
- ✅ **Transformação automática no fim do combo.**
- ✅ **7 habilidades** com espírito animal, na ordem decidida.
- ✅ **R = transformação livre** no animal escolhido, com duração e recarga; trocado por runa.
- ❓ Quais animais podem ir para o R (onça e tatu confirmados).
- ✅ Gancho e planar só depois do 1.0.

## 2. Progressão

- ✅ XP só para a árvore de talentos.
- ✅ Runas purificáveis, equipadas em espaços, que sobem de nível com fragmentos.
- ❓ Quantos espaços de runa existem, e quantas runas no 1.0.
- ✅ Vida em pedras rúnicas; vida e magia máximas por itens achados.
- ❓ Ferramentas e utilitários (aprovados como categoria, sem detalhe).
- ✅ Inventário básico com consumíveis (já existe no protótipo).

## 3. Mundo e mapa

- ✅ Mapa único: 8 regiões no 1.0 e 5 ganchos.
- ✅ Alturas híbridas, com rede de cavernas por baixo.
- ✅ Santuários fixos que só valem se ativados; morrer não tira nada.
- ✅ Minimapa revelado conforme se anda.
- ✅ Atalhos de volta com pista; segredos de recompensa fora do mapa.
- ✅ **Viagem rápida: SIM** (01/11). ❓ Como funciona ainda falta decidir.
- (Histórico da pesquisa:) **Viagem rápida (fast travel).**
  - **O que a pesquisa mostra:**
    - é vista como conforto essencial, e um jogo foi criticado por não ter;
    - o Blasphemous ganhou viagem entre santuários numa atualização;
    - o Metroid Dread usa teletransportes para levar a fechaduras distantes;
    - o Silksong tem uma criatura de transporte ([fontes](https://steamcommunity.com/app/2230650/discussions/0/4033599336912482385), [vídeo GMTK Dread](https://www.youtube.com/watch?v=5pop-cc9kmY), [vídeo GMTK Silksong](https://www.youtube.com/watch?v=l7xXW0EbK4g)).
  - [opinião] **Sugestão:**
    - viajar **entre santuários já ativados**, liberado depois do D Rock ou da onça;
    - no **Desafio**, a viagem pode custar algo ou ficar limitada.
- 🆕❓ **Marcadores no mapa:** o jogador marca lugares para voltar depois. O Blasphemous e o Silksong têm. [opinião] Barato de fazer e muito pedido.
- 🆕 **O mapa mostra as saídas ainda não exploradas** de cada sala. Isso permite "cutucar o mapa" quando o jogador trava ([vídeo GMTK Silksong](https://www.youtube.com/watch?v=l7xXW0EbK4g), [fórum Steam](https://steamcommunity.com/app/2230650/discussions/0/4033599336912482385)).
- ✅ **O minimapa existe desde o início e se revela andando** (01/11). Sem compra.
- 🆕 **Fechadura perto da chave.** A primeira utilidade de cada habilidade fica perto de onde ela é ganha ([GMTK Dread](https://www.youtube.com/watch?v=5pop-cc9kmY)).
- 🆕 **Duas rotas para o que é importante.** Pelo menos uma habilidade alcançável por dois caminhos, e **uma alternativa de exploração para quem travar num chefe** ([GMTK Silksong](https://www.youtube.com/watch?v=l7xXW0EbK4g)).
- 🆕 **Migalhas de pão:** itens e inimigos que puxam para o caminho certo; mais fortes nos modos História e Aventura.
- 🆕 **Diagrama de chaves e fechaduras** do mapa antes de construir ([estudo](estudo-de-jogos.md)).
- ✅ Poucos puzzles e desafios de precisão estilo Jump Quest, com santuário perto.

## 4. Tempo e dificuldade

- ✅ Relógio de 24 h; vários dias; descanso no santuário.
- ✅ Modos História, Aventura e Desafio (Desafio todo à noite; chefes em versão noturna).
- ✅ Troca entre História e Aventura livre; Desafio só no início.
- ❓ Duração de um dia de jogo e horários exatos dos chefes.
- 📌 **A Game Accessibility Guidelines recomenda permitir mudar a dificuldade durante o jogo** ([GAG](https://gameaccessibilityguidelines.com/)). Os modos já fazem isso.

## 5. Chefes e inimigos

- ✅ 16 lutas: 3 principais, 5 subchefes, 8 minibosses.
- ✅ **Lendas decididas** para os 5 subchefes e os 8 minibosses, e a regra vencer → acalmar → purificar → NPC (`docs/brainstorm-mundo-interligado.md`). O Saci é NPC.
- ❓ Escolher de 20 a 25 inimigos comuns entre as mais de 60 ideias em [`bestiario-ideias.md`](bestiario-ideias.md).
- 🆕 **Todo ataque tem aviso**, e a mesma cor tem sempre o mesmo significado (por exemplo, brilho roxo da corrupção = não dá para bloquear) ([fontes no bestiário](bestiario-ideias.md)).
- 🆕 **Os chefes ensinam o próprio padrão**, com fases que mudam ataque ou ambiente.

## 6. História e conteúdo

- ✅ Prólogo do texto original; Árvore Mãe narradora; folclore brasileiro.
- ✅ Final normal (feliz); final verdadeiro para quem achar todos os segredos ou terminar no Desafio.
- ❓ Conteúdo do final verdadeiro; nome, personalidade e motivação do feiticeiro.
- 🆕 **Sistema de diálogos:** NPCs, a narradora, D Rock, Aenia. Existe addon pronto ([Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager)), que precisa da leitura do Gabriel antes.
- 🆕 **Missões secundárias:** o Silksong tem "pedidos" de NPCs como fonte de itens opcionais. [opinião] Algumas missões simples (como a Comadre Fulozinha pedindo algo) dão vida ao mundo.
- ❓ NPCs: quem vive na floresta (a tribo depois do D Rock, o Boto, a Comadre Fulozinha…).

## 7. Arte e som

- ✅ Pixel art em 640×360; Orion de 64 a 80 px; formas animais pretas com verde.
- ✅ Fluxo de arte: desenho do Gabriel, rascunho de IA, ajuste no Aseprite.
- 🆕 **Referência de pose para a IA:** quadros de animação 3D (Mixamo) ou um quadro desenhado à mão ([vídeos](videos-e-aprendizados.md)).
- 🆕 **Mapa e HUD à mão.** Os dois devs que usam IA dizem que a IA faz mal ([vídeos](videos-e-aprendizados.md)).
- ✅ Trilha: orquestra leve com instrumentos brasileiros, com variação noturna.
- 🆕 **Efeitos sonoros que avisam ataques** (o guizo da cascavel, o assobio da Matinta).
- ❓ Fonte dos efeitos sonoros e IA de música (termos de uso).

## 8. Interface e opções

- ✅ Controles: setas, Espaço, A, S, QWER, D, F, Enter; controle de videogame; tudo remapeável.
- 📌 **Remapeamento, legendas e texto legível** são as opções de acessibilidade mais citadas pelos jogadores ([estudo DiGRA](https://dl.digra.org/index.php/dl/article/view/2833)).
- 🆕 **Opções básicas** ([GAG](https://gameaccessibilityguidelines.com/)):
  - volume separado (música, efeitos, voz);
  - tamanho do texto;
  - tremor de tela liga/desliga;
  - piscadas e flashes reduzíveis;
  - modo para daltonismo, ou avisos que não dependem só da cor.
- 🆕 **Velocidade do jogo ajustável**, um item básico da GAG. [opinião] Opcional, mas ajuda nos desafios de precisão.
- ✅ Tutoriais integrados; pausa; tela de opções; créditos.
- ❓ Quantos arquivos de save (um só ou vários perfis).

## 9. Steam e Steam Deck

- 📌 **Steam Deck Verified** ([Steamworks](https://partner.steamgames.com/doc/steamdeck/compat)):
  - **o texto precisa ter pelo menos 9 px de altura numa tela de 1280×800** (o recomendado é 12 px) e dar para ler a 30 cm;
  - **o controle padrão precisa acessar todo o conteúdo**, sem mudar opções;
  - **os ícones de botão mostrados precisam bater com o controle em uso** (não mostrar teclado quando se joga no controle).
  - 🆕 **Atenção ao 640×360** [opinião]:
    - na tela do Deck (1280×800), o jogo ampliado 2× fica com 1280×720 e sobra uma faixa preta;
    - **9 px na tela equivalem a uns 4,5 px no jogo**, então a fonte em pixel precisa ter **6 a 8 px de altura no jogo**, no mínimo;
    - decidir a fonte e o HUD já pensando no Deck.
- 🆕 **Conquistas** (por exemplo, terminar no Desafio, que já está decidido).
- 🆕 **Steam Cloud** para o save.
- ✅ Declarar o uso de IA na arte e na música (plano de negócio).
- ✅ Página da Steam e Discord na metade do jogo; demo do começo até o D Rock no Next Fest antes do lançamento.

## 10. Técnica

- 🆕 **Mundo interligado no Godot:** cena única do mapa do mundo, transições com ID, só a sala atual na memória, camada de tiles própria para o minimapa ([vídeo Inbound Shovel](https://www.youtube.com/watch?v=FI0-yz5Xcz0)); ou o addon MetSys ([código aberto](codigo-aberto-godot.md)).
- 🆕 **IA de inimigos:** máquinas de estado ou árvores de comportamento (LimboAI ou próprio).
- ✅ Teste automático a cada envio (GitHub Actions).
- 🆕 **Save versionado** (o protótipo já migra versões).
- ❓ Plataformas: só Windows ou também Linux e Mac. [opinião] O Linux importa por causa do Steam Deck, que roda Linux, mas com Proton pode não ser preciso; verificar.

## 11. Negócio (resumo; detalhes em `docs/plano-de-negocio.md`)

- ✅ Pessoa física primeiro; US$100 do Steam Direct; US$14,99.
- ❓ Busca de marca "D Rock"; MEI ou ME; contador.

---

## Decisões pendentes mais importantes (para a próxima conversa)

1. **Viagem rápida:** sim ou não, e como.
2. **Marcadores no mapa** e **mapa comprado/achado ou só revelado andando**.
3. **Lendas dos 5 subchefes e dos 8 minibosses.**
4. **Escolha dos inimigos comuns** (de 20 a 25).
5. **Fonte e HUD pensados para o Steam Deck.**
6. **Quais animais podem ir para o R.**
