# Sistema de runas (rascunho jogável)

Runas são recompensas encontradas corrompidas no mapa, por exemplo em chefes, minibosses e segredos. A lógica guarda a runa como corrompida até que ela seja purificada; o menu só oferece essa ação quando é aberto num santuário. Depois da purificação, a runa pode ser equipada. O menu mostra as runas encontradas e o estado de cada uma.

## Espaços e melhoria

O protótipo começa com **2 espaços** e pode crescer até **6** por chamadas a `add_slot()`. Essa quantidade é uma proposta porque a pergunta O.2 do brainstorm continua aberta. Nenhuma runa ocupa mais de um espaço nesta versão.

Cada runa tem **3 níveis**. Melhorar do nível 1 para 2 custa **3 fragmentos de runa**; do nível 2 para 3 custa **6**. Fragmentos são um recurso independente de XP, que permanece dedicado à árvore de talentos. O sistema aceita fragmentos por `add_fragments()` e não define ainda como ou onde o jogo os concede.

## Runas provisórias

| Runa | Efeito proposto por nível (1 / 2 / 3) |
|---|---|
| Onça | velocidade de dash +12% / +20% / +30% |
| Curupira | velocidade de movimento +6% / +10% / +15% |
| Boitatá | dano +8% / +14% / +22% |
| Iara | magia máxima +5 / +10 / +16 |
| Mapinguari | vida máxima +8 / +14 / +22 |
| Saci | recarga −5% / −9% / −14% |
| Tatu | fôlego +5 / +9 / +14 |
| Gavião-real | dano da lança +6% / +11% / +18% |
| Jiboia | recarga da magia −4% / −8% / −12% |
| Mboi-tatá | libera um combo adicional; efeito textual/flag provisório |

Os nomes, bônus e números são propostas para testar o fluxo, não balanceamento aprovado. `total_bonuses()` soma efeitos compatíveis; os dois bônus de dano compartilham a chave `damage`. A runa de combo aparece na lista `combos`, pois ainda não existe integração de combos.

## Estado e interface

`RuneState` é independente da cena e do jogador: registra achadas, purificadas, equipadas, espaços e fragmentos, calcula bônus e converte seus dados para/de um dicionário de save. Save inválido é descartado e o estado volta aos valores iniciais. Isso deixa o modelo pronto para o Claude integrar depois ao `save_manager.gd`.

`RuneMenu` recebe o estado por `setup(state, at_shrine)`. Ao abrir fora do santuário, runas corrompidas continuam visíveis, mas não têm botão de purificação. Esc e Voltar emitem `closed`.

Ainda falta ligar o estado ao save, conceder runas e fragmentos no mundo, aumentar espaços em pontos de progressão, integrar os bônus às habilidades e submeter nomes, números e interface à revisão e ao balanceamento do Gabriel. Nenhum destes valores foi testado em gameplay manual.
