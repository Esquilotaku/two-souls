# Plano técnico do mundo interligado (tarefa 1.1)

Escrito pelo Claude em 01/11/2026, a partir de `docs/brainstorm-mundo-interligado.md` (temas 1, 2 e 4) e `docs/brainstorm-jogo.md` (seções 3 e 7). O Gabriel aprovou: base no branch do Orion de 72 px, **mapa completo do 1.0 em blocos cinzas** e o Codex em paralelo só em partes isoladas.

Este documento é a referência para o Claude e o Codex programarem o marco 1. Quando o código mudar uma decisão daqui, atualize este arquivo no mesmo commit.

## 1. Ideia geral

- O mundo é feito de **salas**. Cada sala é montada por código a partir de dados (`scripts/world/world_map.gd`), com blocos cinzas no lugar da arte. Quando a arte chegar, cada sala pode virar uma cena `.tscn` com TileMap sem mudar o resto.
- As salas se ligam por **portas** nas bordas. Encostar na porta troca de sala com uma transição rápida (escurece e clareia).
- Não há fases nem tela de seleção: o jogo começa na Clareira e o jogador anda pelo mapa.
- O `game.gd` deixa de ter a fila de 8 corredores. Ele passa a cuidar do fluxo (título, pausa, menus, HUD) e pede ao mundo para entrar numa sala.

## 2. Medidas

- Tela interna: 640×360. O Orion tem 72 px de altura e colisão de 22×66 (`player.gd`).
- **Célula do mapa = uma tela (640×360).** Cada sala ocupa um retângulo de células (`cell`, `size`). O minimapa desenha essas células.
- Chão: 48 px de espessura na base da sala. Paredes e teto: 32 px.
- Pulo simples do Orion: cerca de 177 px de altura (velocidade 1020, gravidade 2940). Por isso as plataformas de escada ficam a no máximo 140 px uma da outra.
- Abertura de porta lateral: 128 px de altura. Abertura de porta de cima ou de baixo: 128 px de largura.

## 3. Formato de uma sala

```gdscript
"clareira_inicio": {
	"region": "clareira",          # chave em REGIONS
	"name": "Clareira da Árvore Mãe",
	"cell": Vector2i(0, 0),        # posição no mapa, em telas
	"size": Vector2i(2, 1),        # largura e altura, em telas
	"doors": [ {"id": "leste", "side": "east", "row": 0, "to": "trilha_entrada", "to_door": "oeste"} ],
	"platforms": [ [x, y, largura] ],     # em px, relativos à sala (opcional)
	"shrine": 320.0,               # x do santuário no chão (opcional)
	"foes": 2,                     # inimigos comuns espalhados no chão (opcional)
	"boss": "the_rock",            # chefe da sala (opcional)
	"grants": "spear_wall",        # habilidade que a sala dá (altar provisório ou chefe)
	"pickups": ["luminous_herb"],  # itens no chão (opcional)
}
```

Portas:

- `side`: `east`, `west`, `up` ou `down`.
- `row` (portas laterais): em que fileira de telas fica a porta. `col` (portas de cima e de baixo): em que coluna.
- `gate`: habilidade que abre a porta (ver seção 5). Sem `gate`, a porta é livre.
- `future: true`: gancho para depois do 1.0. Aparece fechado com o nome da região futura e não leva a lugar nenhum.
- Toda porta que não é `future` tem que ter uma volta: a sala `to` precisa ter a porta `to_door`, apontando de volta. O teste confere.

Salas com 2 telas de altura ganham uma escada automática de plataformas, para o jogador alcançar as portas de cima sem precisar de pulo duplo. Portas que exigem pulo duplo usam `gate`.

## 4. Transição entre salas

1. O jogador encosta na área da porta (uma faixa de 24 px na borda).
2. O jogo escurece a tela em 0,12 s, troca a sala e coloca o jogador no ponto de chegada da porta de destino:
   - porta lateral: 48 px para dentro, no chão daquela fileira;
   - porta de baixo (chegando por um buraco no chão): ao lado do buraco, em pé;
   - porta de cima (chegando de cima): logo abaixo da abertura, caindo.
3. A câmera fica presa nos limites da sala. O limite de queda do jogador também passa a ser o fundo da sala.
4. Inimigos e itens pegos não voltam enquanto o jogador estiver na mesma sala. Os inimigos voltam ao descansar num santuário (tema 1, item 6).

## 5. Habilidades e bloqueios

Ordem do `brainstorm-jogo.md`, seção 3. Os nomes no código:

| Código | Habilidade | Onde ganha (blocos cinzas) | O que abre |
|---|---|---|---|
| `spear_wall` | lança cravada | Clareira (altar) | subida da Trilha |
| `super_punch` | super soco | D Rock (chefe da Trilha) | chão rachado para as Cavernas |
| `onca` | corrida (onça) | subchefe da Floresta Antiga | vão largo até a toca do Lago |
| `jiboia` | mergulho, frestas | subchefe do Lago | fundo do Lago e trecho alagado |
| `tatu` | escavação | subchefe do Túnel | terra fofa para as Cavernas profundas |
| `gaviao` | pulo duplo | subchefe das Cavernas profundas | Copas e entrada alta do Coração |
| `purificacao` | purificação | resgate de Aenia (Árvore Corrompida) | barreira do Covil |

- **Nos blocos cinzas, todo bloqueio é um bloco colorido na abertura da porta**, com o nome da habilidade. Ele some quando o jogador tem a habilidade. A mecânica de verdade (cravar a lança, nadar, cavar) é a tarefa 1.7.
- Os subchefes que ainda não existem usam o chefe genérico do `boss.gd` com o nome provisório da região.
- `super_punch` e `spear_throw` continuam também na árvore de talentos atual até a 1.7 decidir.

## 6. Mapa do 1.0 em salas

22 salas nas 8 regiões. Coordenadas em telas, com x crescendo para leste e y para baixo. A Clareira fica em (0, 0).

| Região | Salas |
|---|---|
| Clareira da Árvore Mãe | `clareira_inicio` |
| Trilha da Tribo | `trilha_entrada`, `trilha_aldeia`, `trilha_arena` (D Rock) |
| Floresta Antiga | `floresta_borda`, `floresta_centro`, `floresta_toca` (subchefe, onça) |
| Lago | `lago_margem`, `lago_toca` (subchefe, jiboia), `lago_fundo` |
| Cavernas e Túnel | `cav_clareira`, `cav_tunel`, `cav_toca_tatu` (subchefe, tatu), `cav_profundas`, `cav_ninho` (subchefe, gavião), `cav_alagada` |
| Copas | `copas_baixa`, `copas_alta` |
| Coração Corrompido | `coracao_raizes`, `coracao_arena` (Árvore Corrompida, Aenia) |
| Covil do Feiticeiro | `covil_portao`, `covil_trono` (feiticeiro, final) |

Ganchos pós-1.0 (portas `future`): Brejo (a oeste da toca do Lago), Ruínas sob o Lago (abaixo do fundo do Lago), Raízes Profundas (abaixo das Cavernas profundas), Pico Nevado (acima das Copas) e Bosque de Aenia (a oeste das raízes do Coração).

O caminho obrigatório: lança na Clareira → Trilha → D Rock (super soco) → Cavernas pelo chão rachado → tatu → Cavernas profundas → gavião. Em paralelo: Floresta → onça → Lago → jiboia. Com o gavião: Copas → entrada alta do Coração → Árvore Corrompida → Aenia e purificação → Covil → feiticeiro. O teste automático confere que todas as salas são alcançáveis nessa ordem.

## 7. Santuários (tarefa 1.3)

- Ficam em salas fixas (campo `shrine`), uns 9 no mapa.
- **Ativar:** encostar e apertar `interact` (seta para cima depois da 1.6; até lá, a tecla E). Ativado, o santuário salva, enche vida e magia e vira o ponto de volta.
- **Descansar:** apertar `interact` de novo num santuário ativado. Salva, enche vida e magia e faz os inimigos voltarem. A escolha de descansar até de manhã ou até a noite é da tarefa 1.5.
- **Morrer:** volta à sala do último santuário ativado, com tudo (sem perder XP, itens nem habilidades). Antes de ativar o primeiro, volta ao início da Clareira.

## 8. Save (versão 5)

Um arquivo só, com cópia de segurança, como hoje (`save_manager.gd`). Campos novos:

| Campo | Tipo | Para quê |
|---|---|---|
| `room_id` | texto | sala onde o jogador está |
| `shrine_room` | texto | sala do último santuário ativado ("" se nenhum) |
| `visited_rooms` | lista de textos | minimapa (tarefa 1.4) |
| `activated_shrines` | lista de textos | santuários ativados |
| `abilities` | lista de textos | habilidades da seção 5 |
| `defeated_bosses` | lista de textos | chefes que não voltam |
| `day` | inteiro | dia da jornada (tarefa 1.5) |
| `mode` | texto | `historia`, `aventura` ou `desafio` (tarefa 1.5; por enquanto sempre `aventura`) |

Saem `stage_index`, `checkpoint_x`, `checkpoint_marker` e `boss_defeated`. Um save da versão 4 vira versão 5 no início da Clareira, mantendo nível, XP, itens, talentos e a hora.

## 9. Controles (tarefa 1.6, do Codex)

Nomes das ações no `InputMap`. Os que já existem continuam com o mesmo nome, para o `player.gd` não mudar.

| Ação | Teclado | Uso |
|---|---|---|
| `move_left`, `move_right` | ← → | andar |
| `look_up`, `look_down` | ↑ ↓ | olhar; `look_down` também desce de plataforma no futuro |
| `interact` | ↑ | santuários, falas, Aenia |
| `jump` | Espaço | pular, pulo duplo |
| `attack` | A | ataque da lança |
| `dash` | S | dash e esquiva |
| `throw_spear` | Q | lança cravada |
| `super_punch` | W | super soco |
| `magic` | E | magia e purificação |
| `transform` | R | transformação escolhida |
| `context` | D | habilidade de contexto (jiboia, tatu) |
| `quick_heal` | F | cura rápida |
| `confirm` | Enter | confirmar falas e menus |
| `map` | Tab | mapa |
| `inventory` | I | bolsa |
| `skill_tree` | T | talentos |
| `pause` | Esc | pausa |

- Controle: Q, W, E e R viram LB, RB, LT e RT. O Codex propõe o resto do controle.
- O Codex entrega `scripts/input_config.gd` (padrões, remapeamento, gravação em `user://controles.cfg`) e a tela de remapeamento em `scripts/ui/controls_menu.gd`. **Ele não mexe no `game.gd`, no `player.gd` nem no `project.godot`**: o Claude liga essas peças no jogo.

## 10. Arquivos

| Arquivo | O que faz | Quem |
|---|---|---|
| `scripts/world/world_map.gd` | dados das regiões, salas e portas; validação | Claude |
| `scripts/world/world_room.gd` | monta uma sala (chão, paredes, plataformas, portas, bloqueios, santuário, inimigos, chefe) | Claude |
| `scripts/world/shrine.gd` | santuário (`WorldShrine`); portas e bloqueios ficam dentro do `world_room.gd` | Claude |
| `scripts/game.gd` | fluxo: entra na sala, transição, morte, santuário, save | Claude |
| `scripts/save_manager.gd` | save versão 5 e migração da 4 | Claude |
| `scripts/input_config.gd`, `scripts/ui/controls_menu.gd` | controles e remapeamento | Codex |
| `tests/test_world_map.gd` | portas com volta e vizinhas, salas alcançáveis, salas montam sem erro | Claude |
| `tests/test_world_flow.gd` | joga sozinho: atravessa todas as portas, santuário, morte, continuar, migração do save 4 | Claude |
| `tests/test_input_config.gd` | padrões e remapeamento | Codex |

O GitHub Actions roda todos os `tests/test_*.gd`.

## 11. Depois do núcleo

- **1.4 minimapa:** desenha as células de `visited_rooms` e as portas conhecidas; segredos ficam de fora até serem achados.
- **1.5 relógio e modos:** descanso até de manhã ou noite, `day`, os três modos.
- **1.7 bloqueios de verdade:** trocar os blocos coloridos pelas mecânicas.

Essas três podem ir para o Codex quando o núcleo estiver no branch, uma por vez ou em paralelo se não tocarem nos mesmos arquivos.

## 12. Não verificado

- Os números de pulo, as alturas das plataformas e o tamanho das salas foram calculados, não jogados.
- Os chefes atuais foram feitos para o mundo de antes, com o chão em y 304; cada sala passa o próprio chão para eles, mas o comportamento nas salas novas só se confirma jogando.

## 13. O que mudou ao programar (01/11/2026)

- As portas e os bloqueios ficaram dentro do `world_room.gd`; só o santuário virou arquivo próprio.
- O JSON do Godot lê todo número como decimal (1 vira 1.0). O `save_manager.gd` passou a aceitar números redondos; antes disso o "Continuar" nunca aparecia, inclusive no protótipo antigo.
- A câmera do Orion não tinha nome e o jogo não achava ela para prender nos limites; agora se chama `Camera2D`.
- "Continuar" sempre volta ao último santuário ativado (ou ao início da Clareira), não ao ponto exato onde o jogador parou.
- O pulo duplo agora vem do gavião (`double_jump` no `player.gd`), não mais da magia dos gêmeos.
