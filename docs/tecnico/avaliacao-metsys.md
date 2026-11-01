# Avaliação do Metroidvania System (MetSys)

**Para decisão do Gabriel — 01/11/2026**

## O que é

Metroidvania System (MetSys) é um addon aberto para Godot que reúne ferramentas para planejar e mostrar mapas de jogos 2D. Em termos simples, ele deixa desenhar as salas num editor de mapa, associar salas a cenas, mostrar um mapa/minimapa que se descobre ao explorar, acompanhar objetos persistentes (como itens já coletados) e oferece exemplos de transição e salvamento. As peças podem ser usadas separadamente; não é necessário adotar todo o pacote.

- [Repositório oficial e README](https://github.com/KoBeWi/Metroidvania-System)
- [Wiki oficial de instruções](https://github.com/KoBeWi/Metroidvania-System/wiki)
- [Pasta do addon e exemplos](https://github.com/KoBeWi/Metroidvania-System/tree/master/addons/MetroidvaniaSystem)

## Licença, manutenção e compatibilidade

| Item | O que encontrei |
|---|---|
| Licença | MIT. O arquivo oficial [LICENSE.txt](https://github.com/KoBeWi/Metroidvania-System/blob/master/LICENSE.txt) permite usar, copiar, modificar e distribuir, desde que o aviso de copyright e a licença acompanhem as cópias. |
| Godot | O README atual declara Godot **4.6 ou mais recente**. O `project.godot` da cópia consultada também declara recurso 4.6. Portanto, o 4.7.2 do Two Souls está dentro da faixa declarada pelo projeto. Isso não comprova que o addon foi executado com sucesso no nosso projeto/versão: não o instalamos nem testamos. Há um relato externo de teste em Godot 4.7.2 que falhou ao carregar a versão estável 1.6, então a compatibilidade prática deve ser tratada como **a confirmar** ([relato, fonte secundária](https://flockbay.com/godot-plugins/metroidvania-system/)). |
| Mantenedor / autoria | O repositório oficial é de [KoBeWi](https://github.com/KoBeWi); o `plugin.cfg` também o identifica como autor. O arquivo MIT traz copyright de “Tomek” (2023). O README diz que o projeto veio de ferramentas feitas para *Voice of Flowers*. |
| Versão vista | O `plugin.cfg` no branch principal, consultado em 01/11/2026, informa **1.7-dev**. O README aponta a versão estável 1.6 para Godot anterior a 4.6. |
| Último commit | **7 de outubro de 2026**, commit `0065ae8974291d1c4dfe72f55cfca0f37e3d6ef3` (“Add Dutch translation”), conforme o [histórico oficial](https://github.com/KoBeWi/Metroidvania-System/commits/master/). |
| Issues abertas | **14** na consulta de 01/11/2026 ([issues abertas](https://github.com/KoBeWi/Metroidvania-System/issues?q=is%3Aissue%20is%3Aopen)). Uma recente, de 22/10/2026, relata correções necessárias em plugins do editor ([issue #131](https://github.com/KoBeWi/Metroidvania-System/issues/131)). O número muda com o tempo. |

**Sobre mudanças incompatíveis na 1.4:** não achei no README consultado uma afirmação de que a versão 1.4 introduziu mudanças incompatíveis. O que ele afirma é que Godot 4.6+ é suportado e que, para versões anteriores do Godot, existe a versão 1.6 estável. Assim, não atribuo uma quebra específica à 1.4 sem uma fonte de migração que confirme isso. O risco geral de uma atualização mudar API ou dados continua existindo e recomenda fixar uma versão, ler o histórico e testar antes de atualizar.

## Comparação com o sistema atual

O mundo planejado tem 22 salas em 8 regiões. `WorldMap` descreve células, salas, portas e habilidades; `WorldScene` monta todas as salas na posição correspondente do mapa.

| Parte do Two Souls | O que o MetSys oferece | O que perderíamos ou mudaria |
|---|---|---|
| **Mapa em células** — `world_map.gd` organiza salas em células de 640×360, algumas salas ocupam mais de uma célula. | Editor visual de mapa em grade, células quadradas/retangulares, camadas, grupos, cores, símbolos e validação de passagens. | Deixaria de ser necessário manter à mão toda a visualização/coordenada do mapa em GDScript. A grade continuaria adequada. Teríamos de traduzir nosso formato de `WorldMap` para o recurso de mapa do MetSys; os dados não são intercambiáveis automaticamente. |
| **Áreas / regiões** — cada sala aponta para uma região (Clareira, Trilha, Lago etc.). | Camadas nomeadas e grupos para separar subáreas; células contíguas compõem salas no editor. | Precisaríamos decidir como representar “região” e “sala”: camada/grupo/etiqueta não vira automaticamente o conceito usado pelo jogo. Poderíamos perder a fonte única de dados atual ou manter uma integração própria. |
| **Portas e conexões** — portas têm destino e porta de retorno; `WorldMap.validate()` confere conexões e posições. | Editor de mapa conecta visualmente células e valida passagens para lugar nenhum; os exemplos de transição levam o jogador à cena da sala conectada. | A conectividade geométrica seria mais fácil de visualizar. As regras de destino, posição de chegada e validação próprias do Two Souls precisariam ser migradas ou integradas; não há substituição automática das nossas portas por simples cliques. |
| **Bloqueios por habilidade** — uma porta tem `gate` (ex.: `super_punch`, `gaviao`); `WorldRoom` mostra o bloqueio e o remove quando a habilidade é obtida. | Cores, bordas e símbolos personalizáveis no mapa; API permite alterar células em runtime. | Isso representa visualmente um bloqueio, mas a regra “exige esta habilidade” e o comportamento da porta precisam continuar em lógica própria. Não encontrei um sistema pronto de habilidades/chaves equivalente à nossa tabela de gates. |
| **Minimapa ainda não feito** | `MapView`/temas e exemplo de minimapa; pode descobrir células ou a sala inteira e marcar posição do jogador. | É a parte com maior potencial de reaproveitamento. A aparência precisaria ser ajustada à direção visual do Two Souls e ligada à descoberta/salvamento atuais. |
| **Save de áreas visitadas** — `game.gd` mantém `visited_rooms`, e `save_manager.gd` valida e grava a lista dentro do save único da campanha. | O addon pode exportar/importar um `Dictionary` com salas descobertas, IDs de objetos persistentes e células customizadas. | Poderíamos substituir ou duplicar parte do campo `visited_rooms`, mas a campanha guarda também vida, runas, habilidades, santuário e outros dados. Ainda seria necessário integrar os formatos e cuidar de migração/cópias de segurança do nosso `SaveManager`. |
| **Mapa inteiro numa cena só** — `world_scene.gd` cria as 22 instâncias de `WorldRoom` como filhos de um único mundo; o jogador caminha entre áreas contíguas. | O editor do MetSys mantém um mapa lógico e permite associar cenas a salas. O template de transição carrega a sala seguinte e remove a instância anterior; a variante com rolagem mantém as duas durante o efeito e depois descarta a anterior. | O mapa lógico do editor poderia ser usado como ferramenta sem adotar as transições. Já o fluxo pronto de salas como cenas separadas muda a arquitetura e não preserva o mundo contínuo numa cena que Gabriel escolheu. |

## Ponto crítico: uma cena para o mundo todo

**O template de transição do MetSys espera uma cena por sala.** No [README](https://github.com/KoBeWi/Metroidvania-System), o mapa pode associar cenas às salas; no código oficial [`RoomTransitions.gd`](https://github.com/KoBeWi/Metroidvania-System/blob/master/addons/MetroidvaniaSystem/Template/Scripts/Modules/RoomTransitions.gd), a transição remove a instância da sala anterior, chama `load_room(target_room)` para carregar a próxima e descarta a anterior. A variante [`ScrollingRoomTransitions.gd`](https://github.com/KoBeWi/Metroidvania-System/blob/master/addons/MetroidvaniaSystem/Template/Scripts/Modules/ScrollingRoomTransitions.gd) mantém as duas apenas durante a rolagem.

Isso **conflita com adotar o fluxo de jogo pronto do MetSys**, pois o Two Souls decidiu manter o mapa inteiro numa cena, com todas as áreas posicionadas no mundo e sem troca de cena por porta ([decisão em `world_scene.gd`](../../Two%20Souls/scripts/world/world_scene.gd); [plano técnico](plano-tecnico-mundo.md)). Não significa que o addon seja impossível de usar: seu editor e o `MapView` são componentes separáveis e poderiam servir como ferramenta de planejamento/minimapa, mantendo nosso `WorldScene` e nossa lógica de portas. Essa integração parcial, porém, não é automática.

## Riscos e esforço de migração

- **Dependência de terceiro:** correções e compatibilidade dependem do mantenedor e da comunidade. As 14 issues abertas e a issue recente de plugins do editor são um sinal para revisar o histórico antes de adotar, não uma prova de que o addon seja inseguro.
- **Atualizações:** o projeto está em `1.7-dev`; uma atualização pode alterar classes, dados ou integrações. O README atual não documenta uma quebra da 1.4. Se adotado, convém fixar a revisão usada e atualizar deliberadamente, rodando verificações em cópia.
- **Compatibilidade:** 4.7.2 está no intervalo declarado (4.6+), mas não foi verificado aqui. O relato externo de falha com 1.6 reforça a necessidade de uma prova isolada antes de integrar ao jogo.
- **Migração integral:** manter cenas separadas exigiria refazer a entrada/saída de salas e revisar câmera, carregamento, posição do jogador, inimigos, itens, chefes, santuários e save. Isso contraria a decisão atual do mapa contínuo.
- **Esforço (estimativa opinativa, não compromisso):** (1) protótipo isolado para checar importação e Godot 4.7.2: algumas horas; (2) importar/representar as 22 salas e validar portas: cerca de 1–2 dias; (3) integrar minimapa e descoberta ao save: cerca de 1–3 dias; (4) migrar tudo para cenas por sala e revalidar fluxo: vários dias a algumas semanas, além de mudar a decisão de arquitetura. A estimativa depende do estado do projeto e de problemas encontrados.

**Regra antes de instalar:** o `AGENTS.md` diz para não instalar plugin, addon ou script de terceiros sem o Gabriel ler antes. Portanto, a avaliação e as fontes devem ser lidas por ele antes de qualquer instalação. Nada foi instalado nesta avaliação.

## Recomendação

**Fato:** o MetSys oferece editor de mapa, `MapView`, descoberta e persistência de objetos; seus templates carregam cenas de sala separadas; o README declara Godot 4.6+; a compatibilidade prática com 4.7.2 não foi confirmada.

**Opinião:** **adotar só uma parte, se Gabriel aprovar depois de ler** — avaliar o editor visual como ferramenta de planejamento e o `MapView` para o minimapa, mantendo `world_scene.gd`, portas/gates e `SaveManager` como estão até um protótipo isolado provar que a integração vale o custo. Não adotar o fluxo completo de transições/salvamento de salas neste momento, pois ele exigiria mudar a decisão de uma cena para o mundo inteiro.

---

### Fontes locais consultadas

- [Plano técnico do mundo](plano-tecnico-mundo.md)
- [Referências de level design](level-design-referencias.md)
- [Código atual do mundo](../Two%20Souls/scripts/world/world_map.gd), [montagem do mundo](../../Two%20Souls/scripts/world/world_scene.gd), [salvamento](../Two%20Souls/scripts/save_manager.gd) e [fluxo do jogo](../Two%20Souls/scripts/game.gd)
- [`AGENTS.md`](../AGENTS.md)