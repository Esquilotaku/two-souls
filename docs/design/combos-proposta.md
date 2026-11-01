# Combos do Orion — proposta para aprovação

Proposta do Claude em 01/11/2026, a partir do pedido do Gabriel ("metroidvania bem arcade, fliperama, combos tipo A+A+A+seta cima, A+A+seta baixo") e da pesquisa em `referencia-grand-chase.md` (fontes públicas). **Nada aqui foi programado ainda**: o Gabriel aprova, corta ou muda e só então vira código.

## Como os comandos funcionam

- **A** é o ataque da lança (tecla remapeável).
- Os golpes são lidos numa **fila de comandos** (buffer): apertar o próximo golpe até **0,3 s** antes do atual terminar já conta. Isso deixa o combo fluido sem exigir tempo perfeito.
- Uma seta segurada junto do A muda o golpe: "A + ↑" é apertar A segurando a seta para cima.
- O **dash** é o duplo toque na seta (já funciona). Ele cancela o fim de qualquer golpe comum.

## No chão

| Comando | Golpe | Para que serve |
|---|---|---|
| A | Estocada rápida | começa tudo; pode parar aqui |
| A, A | Corte lateral | empurra um pouco |
| A, A, A | Giro da lança | acerta dos dois lados |
| A, A, A, A | **Final: transformação relâmpago** (o animal aparece por um instante e dá o golpe) | maior dano; é o "transformação automática no fim do combo" do brainstorm |
| A, A, **↑+A** | **Lançador**: joga o inimigo para cima | abre o combo no ar |
| A, A, **↓+A** | Varredura baixa: derruba | inimigo fica no chão por um tempo |
| **↑+A** (parado) | Golpe para cima | contra inimigos voadores |
| **dash + A** | Investida com a lança | atravessa a tela rápido |

## No ar

| Comando | Golpe | Para que serve |
|---|---|---|
| A, A, A | 3 golpes aéreos | continua o lançador |
| **↓+A** | Mergulho com a lança | desce rápido e quica em inimigos (estilo pogo) |
| dash no ar | Dash aéreo (1 por pulo) | travessia e esquiva |

## Especiais (gastam MP)

| Tecla | Especial | Custo |
|---|---|---|
| Q | Lança cravada (arremesso; vira degrau na parede depois da 1.7) | 1 MP |
| W | Super soco | 2 MP |
| E | Magia | 1 MP |

## Coisas que vêm junto

- **Contador de combo** na tela ("12 HITS"), sem nota obrigatória.
- **Inimigos grandes** (do tamanho do Orion ou maiores) recuam a cada golpe e podem ser lançados; chefes têm **super armadura** em alguns ataques (não recuam).
- **Fôlego** (barra amarela) só para dash e esquiva, como no brainstorm; os golpes comuns não gastam nada.

## Perguntas para o Gabriel

1. A tabela acima está boa ou quer trocar algum comando?
2. O final do combo (A, A, A, A) vira mesmo o animal por um instante, ou fica só um golpe forte da lança?
3. Fôlego para o dash: sim (limita spam) ou dash livre, só com o pequeno intervalo de 0,35 s que já existe?
