# Referências visuais — pixel art, metroidvania e HUD

Pasta de estudo para o Gabriel, o Claude e o Codex. **Referência inspira, não é para copiar**: nada daqui entra no jogo (regra do `AGENTS.md`).

## Como baixar as imagens (no PC)

Na pasta `F:\GAME`:

```
powershell -ExecutionPolicy Bypass -File pipeline\baixar-referencias.ps1
```

- **O que baixa:** a capa e 6 capturas oficiais da página da Steam de cada jogo da lista (uns 35 jogos, cerca de 200 imagens). Para baixar mais por jogo, use `-PorJogo 10`.
- **Onde salva:** `referencias/imagens/<categoria>-<jogo>/`. Também gera `referencias/imagens/INDICE.md` com o link de cada jogo.
- **Confira o índice:** a busca pega o primeiro resultado da Steam, então pode trazer o jogo errado.
- **Fora do git:** as imagens não vão para o git (`.gitignore`). Elas são de terceiros e ficam só no PC, como material de estudo.
- **Não verificado:** o script foi escrito na nuvem e **não pôde ser testado lá**, porque a rede da nuvem bloqueia a Steam. Se der erro, peça ao Claude ou ao Codex do PC para corrigir.
- **Para acrescentar jogos:** edite a lista no início do script.

## Categorias

| Pasta começa com | O que estudar ali |
|---|---|
| `metroidvania-` | mapa, leitura do personagem no cenário, HUD de vida e magia, portas e bloqueios |
| `brasileiro-` | Dandara e Kaze: como jogos brasileiros apresentam a identidade visual |
| `precisao-` | Celeste, Shovel Knight, Katana ZERO: plataforma difícil e legível (referência para os desafios estilo Jump Quest) |
| `atmosfera-` | natureza, luz, neblina e paleta (referência para a floresta e a corrupção) |
| `chefes-` | Titan Souls: chefes grandes em pixel art, leitura de padrão de ataque |
| `hud-` | interface limpa em pixel art |

## O que olhar em cada captura (checklist para quem estuda)

1. **Tamanho do personagem em relação à tela.** O Two Souls usa 640×360 com o Orion de 64 a 80 px. Compare quais jogos têm o personagem com presença parecida.
2. **Contorno.** Escuro, colorido ou sem contorno? Como o personagem se separa do fundo?
3. **Paleta.** Quantas cores no personagem? O fundo é mais escuro, mais claro ou menos saturado que o personagem?
4. **Camadas de fundo (parallax).** Quantas camadas, e como a distância é mostrada (cor, neblina, desfoque)?
5. **HUD.** Onde ficam a vida, a magia e o mapa? Quanto da tela ocupam? A vida é barra, ícones ou pedras? No Two Souls a vida será em **pedras rúnicas**.
6. **Luz.** Como os efeitos (magia, fogo, brilho) se destacam? Isso importa para o verde brilhante das formas animais.
7. **Leitura do perigo.** Como o jogo mostra o que machuca (espinhos, ataques, avisos)?

## Por que os sprites estão saindo ruins, e o que ajuda

[opinião do Claude, sem teste]
- **A IA não segura bem o pixel art.** As IAs de imagem geram "imitação" de pixel art: pixels de tamanhos diferentes, cores demais, contorno borrado. Converter isso para um tamanho pequeno estraga ainda mais.
- **O que costuma funcionar melhor:**
  1. **Defina o tamanho e a paleta antes** (tarefa A.1, folha de estilo). Sem isso, cada rascunho sai diferente.
  2. **Desenhe à mão a pose base** do Orion parado, no tamanho final, no Aseprite. Use a IA só para **ideias e conceitos em tamanho grande**, nunca como sprite final.
  3. **Escolha de 3 a 5 jogos desta pasta** com o personagem do tamanho parecido e estude como eles desenham olho, cabelo e mão nesse tamanho.
  4. **Use uma paleta pronta como ponto de partida.** O site Lospec tem uma biblioteca de paletas de pixel art (lospec.com/palette-list; link de memória, conferir).
- **Tutoriais de pixel art** (links de memória, conferir antes):
  - **Pedro Medeiros (Saint11)**, brasileiro e artista do Celeste, com tutoriais curtos de animação e pixel art;
  - **Slynyrd**, um blog com guias de pixel art;
  - **MortMort**, no YouTube.

## Como pedir ajuda ao Claude ou ao Codex do PC

```text
Leia referencias/README.md e referencias/imagens/INDICE.md. Olhe as capturas de [jogos escolhidos].
Para cada um, descreva: altura aproximada do personagem em relação à tela, contorno, número de cores do personagem,
camadas de fundo e posição e estilo do HUD. Depois compare com docs/folha-de-estilo-orion.md (se existir)
e sugira o que adaptar no Two Souls, sem copiar arte, nomes ou fases.
```
