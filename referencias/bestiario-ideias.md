# Bestiário — banco de ideias de inimigos

Proposta do Claude, 01/11/2026, a pedido do Gabriel ("quero muitas variedades"). **Nada aqui está decidido.** É um cardápio para o Gabriel escolher. A meta do 1.0 é de **20 a 25 tipos comuns**, mais os 8 minibosses e os 5 subchefes (`docs/design/brainstorm-jogo.md`, seção 4). Abaixo há **mais de 60 ideias**, para sobrar escolha.

Base: fauna brasileira corrompida (decisão do Gabriel), lendas (`lendas-do-brasil.md`) e biomas (`fauna-e-biomas.md`).

## Regras de design (com fonte)

1. **Comportamento primeiro, visual depois.** Inimigos diferentes no visual mas iguais no comportamento são lidos como a mesma ameaça. Mudar só a vida, o dano ou a velocidade é chato ([Mega Cat Studios](https://megacatstudios.com/blogs/retro-development/enemy-design-101-apeels-court), [post no itch.io](https://itch.io/post/8596517)).
2. **Todo ataque tem aviso (*telegraph*):** um sinal visual ou sonoro antes do golpe, e o mesmo sinal sempre significa a mesma coisa ([Game Developer](https://www.gamedeveloper.com/design/enemy-attacks-and-telegraphing), [Unity](https://unity.com/blog/how-enemy-ai-works-video-games)). A preparação de cada golpe deve ser **bem diferente** das outras, não sutil ([GDKeys](https://gdkeys.com/keys-to-combat-design-1-anatomy-of-an-attack/)).
3. **Combinações:** um atirador atrás de um inimigo corpo a corpo é muito mais intenso que cada um sozinho ([gamedesignskills](https://gamedesignskills.com/game-design/platformer/)).
4. **Chefes:**
   - **Legibilidade:** se o jogador, revendo a própria morte, consegue ver o que devia ter feito, o aviso funcionou ([Choost Games](https://choostgames.com/blog/what-makes-a-good-boss-fight/)).
   - **Ensino:** o chefe ensina o próprio padrão ([Bugnet](https://bugnet.io/blog/how-to-design-a-boss-that-teaches-its-own-pattern)).
   - **Fases:** mudam com ataques novos, mais agressividade ou mudança no ambiente ([AI Wiki](https://artificial-intelligence-wiki.com/industry-ai/ai-in-gaming/ai-boss-fight-design/)).
   - **Forma e cor:** uma linguagem de formas consistente (linha para golpe direcional, cone para leque, círculo para área), e a mesma cor sempre com o mesmo significado ([Gamineai](https://gamineai.com/blog/enemy-telegraph-shape-language-top-down-boss-fights-fast-visual-consistency-audit-2026)).

**Regra própria do Two Souls** [ideia]:
- **Cor da corrupção:** a corrupção tem uma cor só (roxo, por exemplo). **Brilho roxo = ataque que não dá para bloquear.**
- **Versão noturna:** cada inimigo tem uma, para o modo Desafio e para a noite. No 1.0 isso é números mais um efeito, como decidido. Algumas têm **um comportamento extra** (marcado com 🌙).

## Arquétipos (para não repetir comportamento)

| Código | Arquétipo | O que exige do jogador |
|---|---|---|
| COR | corredor / investida | pular por cima, dash |
| VOO | voador | atacar para cima, pulo duplo, timing |
| TIR | atirador | aproximar-se e desviar de projéteis |
| TAN | tanque / escudo | atacar por trás, super soco quebra a guarda |
| EMB | emboscada (sai do chão, da água, do teto) | ler o cenário |
| ENX | enxame (fraco em grupo) | golpe em área |
| INV | invocador / ninho | priorizar o alvo |
| ARE | área / perigo (veneno, fogo, elétrico) | posicionamento |
| PLA | plataforma viva (anda, afunda, carrega) | travessia |
| FUG | foge / rouba | perseguição |

---

## Inimigos por região

As regiões são as do `docs/design/brainstorm-mundo-interligado.md`. Cada ideia tem arquétipo, comportamento, aviso e versão noturna.

### Clareira da Árvore Mãe (início, tutorial)
1. **Saúva-cortadeira (ENX):** anda em fila carregando folhas; inofensiva até ser atacada, aí avança em grupo. Aviso: as antenas tremem. 🌙 à noite, já anda em formação de ataque.
2. **Calango corrompido (COR):** corrida curta e para. Ensina a pular por cima.
3. **Vaga-lume corrompido (VOO):** voa em zigue-zague e solta faísca ao ser tocado. Ensina a atacar para cima.
4. **Broto espinhoso (ARE, parado):** planta que solta espinhos de tempos em tempos. Ensina a observar o ritmo.

### Trilha da Tribo (D Rock)
5. **Lanceiro tribal (TIR)** [Gabriel: lembrança]: arremessa lanças. Some depois de vencer o D Rock (a tribo vira amiga).
6. **Arqueiro tribal (TIR)** [Gabriel: brainstorm com o Gemini]: atira flechas em diagonal de cima de plataformas.
7. **Quati ladrão (FUG):** rouba um consumível e foge. Pegá-lo devolve o item com bônus.
8. **Seriema (COR):** corre muito e dá bicadas; joga pedras em você, como a ave real faz com presas (o comportamento real não foi verificado).
9. **Cupinzeiro vivo (INV):** solta cupins voadores até ser destruído. O tatu cava ele por dentro.

### Floresta Antiga (Mata Atlântica)
10. **Jaguatirica corrompida (COR):** finta e salta. Aviso: agacha e balança a cauda.
11. **Bugio (TIR / ARE):** grita (onda sonora em cone) e joga frutos podres. 🌙 o grito atordoa.
12. **Jararaca na grama (EMB):** só a cabeça aparece; bote em linha reta.
13. **Perereca venenosa (ARE):** pula e deixa uma poça tóxica. As cores vivas avisam que é venenosa.
14. **Aranha-armadeira (COR):** levanta as patas da frente (aviso) e salta.
15. **Taturana no galho (ARE, parado):** encostar causa sangramento por alguns segundos.
16. **Bromélia carnívora (EMB):** fechada parece plataforma; abre e morde.

### Copas (Amazônia, dossel)
17. **Tucano corrompido (VOO):** mergulho em linha. O bico brilha antes.
18. **Macaco-aranha corrompido (VOO / FUG):** balança entre galhos e joga castanhas. Lembrete: o macaco-prego foi descartado como forma do Orion; como **inimigo** ainda é opção.
19. **Morcego-vampiro (VOO):** cola em você e drena vida até ser sacudido (dash).
20. **Harpia corrompida (VOO)**, inimigo raro: agarra e solta de altura. É um contraponto ao gavião do Orion.
21. **Vespa / marimbondo (ENX / INV):** casa de marimbondo solta vespas; destruir a casa resolve.
22. **Cipó vivo (PLA):** cipó que se mexe e pode ser plataforma ou perigo.

### Cavernas e Túnel
23. **Morcego de caverna (VOO, enxame):** dorme no teto e acorda com barulho ou luz.
24. **Escorpião-amarelo (ENX):** grupos pequenos; a cauda sobe e treme antes da picada.
25. **Surucucu (EMB / TAN):** grande, bote longo, sai de buracos.
26. **Caranguejeira (COR / TAN):** solta pelos urticantes em área (nuvem) quando ameaçada.
27. **Cascavel (EMB):** **o guizo avisa** antes do bote. Pensado para o áudio.
28. **Tatu-peba corrompido (COR / TAN):** rola como bola e quica nas paredes. Contraste com o tatu do Orion.
29. **Cristal corrompido (INV / ARE):** formação de cristal que dispara estilhaços; o super soco quebra.
30. **Caboclo d'Água (EMB)** [lenda]: no trecho alagado do Túnel, puxa para baixo.
31. **Minhoca gigante (EMB / PLA):** atravessa o chão de terra fofa e deixa túneis que o tatu usa.

### Lago (Pantanal e várzea)
32. **Piranha (ENX):** cardume na água funda; persegue quem nada (jiboia).
33. **Poraquê (ARE):** descarga elétrica em círculo na água. Aviso: a água brilha.
34. **Jacaré (EMB / TAN):** parece tronco boiando; morde quem pisa. O jogador aprende a diferenciar o tronco de verdade.
35. **Tuiuiú corrompido (VOO / TIR):** voa baixo sobre a água e bica.
36. **Sucuri-amarela (EMB):** enrola e prende; o jogador aperta botões para soltar.
37. **Ariranha corrompida (COR na água):** rápida, em grupo familiar de 3.
38. **Aguapé que afunda (PLA):** plataforma que afunda com o peso; não é inimigo, é perigo de travessia.

### Coração Corrompido (Caatinga seca e espinhosa)
39. **Corpo-seco (TAN)** [lenda]: árvore seca que anda, lenta e resistente; só a purificação mata de vez.
40. **Mandacaru corrompido (TIR, parado):** dispara espinhos em leque.
41. **Urubu corrompido (VOO):** circula em cima e mergulha quando a vida do Orion está baixa.
42. **Raiz estranguladora (EMB):** sai do chão e prende. Aviso: a terra racha antes.
43. **Servo encapuzado (TIR / INV)** [servo do feiticeiro]: lança magia roxa e invoca raízes.
44. **Lobo-guará corrompido (COR):** pernas longas, salto alto, ataca em dupla. 🌙 uiva e chama outro.

### Covil do Feiticeiro (topo, noite)
45. **Servo encapuzado de elite (TAN):** escudo de magia; o super soco quebra.
46. **Gárgula de pedra-raiz (VOO / TAN):** parada até o jogador passar.
47. **Eco do feiticeiro (INV):** cópia sombria que some ao ser atingida e reaparece.
48. **Meteoro menor (ARE):** a sombra no chão avisa onde vai cair; prepara para o golpe do chefe final.

### Inimigos que aparecem em várias regiões
49. **Mula sem cabeça corrompida (COR, noturna)** [lenda]: investida reta com rastro de fogo.
50. **Matinta Pereira (miniboss itinerante, noite)** [lenda]: o assobio avisa que ela chegou.
51. **Formiga tocandira (COR / ARE):** picada que "atordoa" por um instante.
52. **Besouro-hércules (TAN):** chifre que levanta e joga longe; por trás é vulnerável.
53. **Louva-a-deus (EMB):** camuflado em folhas; golpe rápido duplo. O Brasil tem a maior diversidade do mundo.
54. **Fungo de saúva (ARE):** esporos em nuvem perto de formigueiros.

### Depois do 1.0 (regiões-gancho)
55. **Brejo:** Serpe do Brejo (subchefe; já existe no protótipo), sapo-cururu gigante, enguia, garça.
56. **Raízes Profundas:** larvas, cupins-rainha, raízes vivas, fungos luminosos.
57. **Ruínas sob o Lago:** Iara (miniboss), pirarucu gigante, estátuas animadas.
58. **Pico Nevado (Pampa):** graxaim (a confirmar), ema que corre, quero-quero que avisa os outros, geada que congela plataformas.
59. **Bosque de Aenia:** inimigos "de luz" corrompidos (flores que encantam), para a magia dela.

---

## Minibosses (8) — ideias com lendas

[ideia] As recompensas seguem o aprovado: vida máxima, talento, runa ou item.

| Miniboss | Região | Comportamento | Recompensa |
|---|---|---|---|
| **Saci** | Copas | redemoinhos que empurram; some e reaparece; rouba o gorro (ou um item) e o jogador persegue | runa de vento |
| **Quibungo** | Trilha | grande, agarra e joga; vulnerável depois de errar o agarrão | pedra rúnica de vida |
| **Romãozinho** | Floresta Antiga | joga pedras e foge pelas copas; luta-perseguição | runa de arremesso |
| **Capelobo** | Cavernas | só de noite; focinho que suga; ataca no escuro | talento |
| **Iara** | Lago | canto que puxa para a água; ataques com ondas | runa da água |
| **Cabeça de Cuia** | rio do Lago | sai do rio e volta; libertado pela purificação (volta depois do resgate) | fragmentos de runa |
| **Teiniaguá** | gruta secreta (tatu) | lagartixa rápida com pedra brilhante; reflexos de luz | runa rara |
| **Matinta Pereira** | itinerante, noite | aparece em regiões aleatórias à noite; o assobio avisa | item único |

## Subchefes (5) — proposta

Ver `lendas-do-brasil.md`: **Curupira** (onça), **Boiúna** (jiboia), **Minhocão** (tatu), **Mapinguari** (gavião), **Boitatá** (caminho do Covil).

## Como escolher (sugestão)

1. **Primeira lista:** para cada região, escolher **3 ou 4** inimigos da lista com **arquétipos diferentes**. Isso dá uns 25 no 1.0.
2. **Corte:** se dois inimigos têm o mesmo arquétipo na mesma região, cortar um.
3. **Aviso de cada inimigo:** para os escolhidos, desenhar primeiro o aviso do ataque e depois o visual.
4. **Registro:** guardar a lista final em `docs/design/brainstorm-jogo.md`, seção 4.
