# Código aberto para Godot — plataforma, metroidvania, luta e beat 'em up

Pesquisa do Claude, 01/11/2026.

> **Regra do `AGENTS.md`:** não instalar plugin, addon ou script de terceiros **sem o Gabriel ler antes**. Esta lista é para **estudar** e decidir. Nada aqui foi instalado ou testado.
>
> **Antes de usar qualquer um:**
> 1. conferir a **licença** no próprio repositório (MIT e CC0 permitem uso comercial; outras podem não permitir);
> 2. conferir a **versão do Godot** exigida (o projeto usa a 4.7.2);
> 3. conferir se o projeto **ainda é mantido**.

As informações vêm dos resultados de busca e das páginas dos projetos; **não abri o código**.

## Sistema de metroidvania (mapa, salas, transições)

| Projeto | O que é | Licença e versão (segundo as fontes) | [opinião] |
|---|---|---|---|
| [**MetSys — Metroidvania System** (KoBeWi)](https://github.com/KoBeWi/Metroidvania-System) | framework para metroidvania em grade: editor de mapa, células, camadas, coletáveis, salvamento básico, `load_room()` para trocar de sala ([wiki](https://github.com/KoBeWi/Metroidvania-System/wiki), [Asset Library](https://godotengine.org/asset-library/asset/2301)) | MIT; o README diz Godot 4.6+ e a loja diz 4.5+ | **o candidato mais forte para a tarefa 1.1.** O dev do Isadora's Edge testou e não serviu para o caso dele ([vídeo](https://www.youtube.com/watch?v=FI0-yz5Xcz0)); avaliar com calma. O autor é um contribuidor conhecido do Godot (de memória, não verificado) |
| [uheartbeast/metroidvania-godot-4](https://github.com/uheartbeast/metroidvania-godot-4) | metroidvania em Godot 4 de um criador de cursos | MIT (2023) | conteúdo não verificado |
| [SummerEngine/template-2d-platformer](https://github.com/SummerEngine/template-2d-platformer) | modelo com 7 salas ligadas, habilidades, NPCs, missões e um chefe com máquina de estados | MIT; **feito para o Summer Engine, uma variação do Godot 4.6+** | pode não abrir no Godot normal; serve para estudar a organização |
| [tssb2007-saibgbs/metroidvania-template](https://github.com/tssb2007-saibgbs/metroidvania-template) | modelo básico para iniciantes | MIT | simples |
| [henriiquecampos/godot-metroidvania-2d](https://github.com/henriiquecampos/godot-metroidvania-2d) | projeto do curso GDQuest de 2019 | conferir | **antigo (Godot 3)**; só para ideias |

## Controle de personagem de plataforma (pulo, coyote time, buffer)

| Projeto | O que é | Licença |
|---|---|---|
| [Ultimate Platformer Controller 2D (Noah-Erz)](https://github.com/Noah-Erz/Ultimate-Platformer-Controller-2D) | personagem configurável com coyote time e buffer de pulo (0,2 s padrão). Atenção: **com mais de 1 pulo, o coyote time e o buffer desligam**, segundo a página. Isso importa por causa do pulo duplo do gavião | MIT, segundo a fonte |
| [PlatformerController2D (Ev01)](https://github.com/Ev01/PlatformerController2D) | pulo duplo, coyote time e buffer | MIT, segundo a fonte |
| [godot-2d-player-controller (priyanshsingh102005)](https://github.com/priyanshsingh102005/godot-2d-player-controller) | baseado em estados: pulo, pulo duplo, coyote time, buffer | conferir |
| [Windy-Codes/2d-platformer-template](https://github.com/Windy-Codes/2d-platformer-template) | modelo modular de plataforma para Godot 4 | MIT |
| [brettchalupa/godot_2d_platformer](https://github.com/brettchalupa/godot_2d_platformer) | kit completo de plataforma para Godot 4 | **CC0** (domínio público) |

[opinião] O Orion já tem movimento no protótipo. Esses projetos servem para **copiar a ideia** do coyote time e do buffer de pulo (o que o Celeste faz), não necessariamente para instalar.

## Combate: hitbox, hurtbox, luta e beat 'em up

| Projeto | O que é | Licença |
|---|---|---|
| [gdquest-demos/godot-4-hitbox-hurtbox](https://github.com/gdquest-demos/godot-4-hitbox-hurtbox) | demo didática de hitbox e hurtbox no Godot 4 | conferir |
| [CodingQuests/godot-hitbox-hurtbox](https://github.com/CodingQuests/godot-hitbox-hurtbox) | componentes de vida, hitbox e hurtbox com **knockback, hit-stop, invencibilidade após o golpe** e uma demo de espada com 2 ataques | conferir |
| [MisterOsoo/Active-Frame-Hitbox](https://github.com/MisterOsoo/Active-Frame-Hitbox) | hitbox ligada aos **quadros ativos** do AnimatedSprite2D, o que combina com sprites do Aseprite | MIT |
| [jv-vogler/2d-hitbox-godot-plugin](https://github.com/jv-vogler/2d-hitbox-godot-plugin) | plugin simples de hitbox e hurtbox | conferir |
| [Fxll3n/FightEngine](https://github.com/Fxll3n/FightEngine) | plugin **em andamento** para jogos de luta 2D (Godot 4.5+), com HitBox2D, HurtBox2D e combate por estados | conferir |
| [BilalAlfayoumi/godot-fighter](https://github.com/BilalAlfayoumi/godot-fighter) | luta versus 2D em **Godot 4.7**, estilo Mortal Kombat: hitstun, knockback, bloqueio, IA | conferir; é projeto de estudo |
| [quiver-dev/template-beat-em-up](https://github.com/quiver-dev/template-beat-em-up) | modelo de **beat 'em up** para Godot 4, estilo Streets of Rage: personagens, ataques e IA configuráveis | conferir; usa Git LFS |

[opinião] Para o **combo da lança com transformação no fim** e para os **avisos dos inimigos**:
- **Active-Frame-Hitbox:** hitbox por quadro de animação.
- **CodingQuests:** hit-stop e knockback, que dão "peso" ao golpe.
- **Leitura de estudo:** o FightEngine e o godot-fighter mostram máquinas de estado de golpes.

## Addons úteis (IA de inimigos, câmera, diálogo)

| Addon | Para quê | Licença (segundo as fontes) |
|---|---|---|
| [**LimboAI**](https://github.com/limbonaut/limboai) | **árvores de comportamento e máquinas de estado** para a IA de inimigos e chefes, com editor e depurador visual; em C++, Godot 4.6+ | MIT |
| **Beehave** | árvores de comportamento em GDScript puro | MIT, segundo uma única fonte (o catálogo do Summer Engine) |
| [**Phantom Camera**](https://github.com/ramokz/phantom-camera) | câmera inspirada no Cinemachine do Unity (seguir, limites, transições) ([site](https://phantom-camera.dev/overview/what-is-this)) | MIT, Godot 4.4.1+ |
| [**Dialogue Manager** (Nathan Hoad)](https://github.com/nathanhoad/godot_dialogue_manager) | editor e sistema de **diálogos com escolhas**. Serviria para a Árvore Mãe narradora, os NPCs, o D Rock e Aenia | MIT, versão 4 para Godot 4.6+ |

[opinião] Para o 1.0, os que mais economizam trabalho são:
- **Dialogue Manager:** diálogos.
- **LimboAI:** 16 chefes e uns 25 inimigos com comportamentos diferentes.
- **MetSys:** o mapa, se servir.

Todos precisam da leitura do Gabriel antes (AGENTS.md).

## Ferramentas externas citadas

- **Tiled:** editor de mapas em tiles. O dev do Noru põe os inimigos como objetos no Tiled e a engine lê ([vídeo](https://www.youtube.com/watch?v=MmuPhqADyj0)).
- **LDtk:** editor de fases do mesmo autor do Dead Cells. **Não pesquisado agora.**
- **Ogmo Editor:** usado no Celeste, grátis e de código aberto ([Celeste Tools](https://celestegame.tumblr.com/tools)).
- **Mixamo:** animações 3D grátis para usar como referência de pose ([vídeo do MagmaDev](https://www.youtube.com/watch?v=tibV8bHCTcQ)). **Termos de uso não verificados.**
