# Two Souls — plano de negócio e marketing

Brainstorm entre o Gabriel e o Claude, 01/11/2026. Pesquisa feita na mesma data.

**Legenda de origem:**
- **[Gabriel]**: decisão do Gabriel.
- **[proposta]**: sugestão do Claude aprovada.
- **[opinião]**: avaliação do Claude.
- **Fato com link**: fonte aberta. Blogs e escritórios de contabilidade estão marcados como fontes secundárias.
- **Não verificado**: não confirmado em fonte oficial.

> Este documento **não é orientação jurídica ou contábil**. Antes de abrir empresa, declarar receita ou publicar o jogo, confirme com fontes oficiais ou com um contador.

---

## 1. Forma de venda: pessoa física primeiro

**Decisão (opção A)** [Gabriel]:
- Vender na Steam como **pessoa física**, preenchendo o formulário W-8BEN, até haver receita.
- **Antes do lançamento:**
  1. conferir no Portal do Empreendedor (gov.br) se existe ocupação de MEI para jogos;
  2. fazer **uma consulta pontual com um contador** para decidir quando abrir uma ME.

**O que as fontes dizem:**
- **MEI:** as fontes se contradizem.
  - A maioria diz que programação e desenvolvimento de jogos **não podem ser MEI** ([Contabilidade.com](https://contabilidade.com/blog/programador-pode-ser-mei-descubra-como-abrir-empresa/), [Agilize](https://agilize.com.br/blog/abrir-sua-empresa/cnpj-para-desenvolvedor/), [Meu Contador Online](https://www.meucontadoronline.com.br/consulta-cnae/fabricacao-de-produtos-diversos/3240001-fabricacao-de-jogos-eletronicos/)).
  - Um blog afirma que o Marco Legal dos Games (Lei 14.852/2024) abriu caminho para o MEI ([CursoGame](https://cursogame.dev/blog/abrir-empresa-jogos-mei-brasil)). **Não verificado:** a lei e a lista oficial de ocupações não foram lidas.
- **Pessoa física:** dá para vender na Steam com o W-8BEN. A receita do exterior entra no **carnê-leão**, com alíquota de até 27,5% ([CursoGame: impostos](https://cursogame.dev/blog/impostos-vender-jogo-brasil); fonte secundária).
- **Retenção nos EUA:** como **não há tratado tributário** entre Brasil e EUA, haveria retenção sobre as vendas a compradores dos EUA. Uma fonte cita 30%. **Não verificado** em fonte oficial.
- **ME no Simples Nacional:** a receita de exportação teria isenção de ISS, PIS e Cofins, e software poderia chegar a 6% com o Fator R ([Agilize](https://artigos.agilize.com.br/tributacao-desenvolvedor-software-simples-nacional/), [Tactus](https://tactus.com.br/impostos-para-desenvolvedores/); secundárias). Regra de limite de receita: [Receita, perguntas do Simples](https://www8.receita.fazenda.gov.br/simplesnacional/arquivos/manual/perguntaosn.pdf).

**Descartados:**
- **ME já antes de vender:** custo fixo sem receita.
- **MEI:** provavelmente não é permitido; depende da confirmação acima.

## 2. Steam

- **Steam Direct:** **US$100 por jogo**. Não é devolvido, mas é recuperado no pagamento depois que o jogo passa de US$1.000 de receita bruta ajustada ([Steamworks: taxa](https://partner.steamgames.com/doc/gettingstarted/appfee?l=portuguese), oficial).
- **Conta bancária** ([Steam Direct](https://partner.steamgames.com/steamdirect?l=portuguese), oficial):
  - precisa estar no nome do titular cadastrado (se for empresa, conta da empresa);
  - a verificação leva de 15 a 30 dias.
- **Pagamento** ([Beancount](https://beancount.io/pt/blog/2026/07/09/steam-revenue-share-indie-game-developer-bookkeeping-guide), [Xataka](https://www.xataka.com.br/informatica/steam-exige-que-desenvolvedores-vendam-pelo-r-580-mes-ou-mandara-e-mails-mensais-os-alertando); secundárias): cerca de 30 dias após o fim do mês, com mínimo de US$100.
- **Não verificado:** qual banco brasileiro tem o melhor câmbio para receber em dólar.
- **Declaração de IA** ([VGC](https://www.videogameschronicle.com/news/valve-has-significantly-rewritten-steams-rules-for-how-developers-much-disclose-ai-use), [Game Developer](https://gamedeveloper.com/business/valve-tweaks-and-clarifies-ai-disclosure-rules-for-steam); secundárias, não li a página oficial):
  - o uso de IA generativa em conteúdo do jogo é declarado e aparece na página da loja;
  - desde jan/2026, ferramentas de desenvolvimento, como IA que programa, ficam isentas;
  - **a arte e a música feitas com IA precisam ser declaradas** (afeta o fluxo de arte e a trilha do `estudio-e-cargos.md`).
- **Descontos** ([Steamworks: descontos](https://partner.steamgames.com/doc/marketing/discounts), oficial, lido em trechos):
  - mínimo de 10% e máximo de 90%;
  - 30 dias de espera entre descontos.
  - **Desconto de lançamento:** máximo de 40%, segundo um guia de 2026 ([Steam Page Analyzer](https://www.steampageanalyzer.com/blog/steam-discount-rules-2026)). **Não verificado na fonte oficial.** O plano de cerca de 33% caberia.
- **Next Fest** ([Steamworks: Next Fest](https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest), oficial):
  - **cada jogo participa de um só**;
  - a demo é enviada pelo menos 3 semanas antes;
  - há edições anunciadas para [fev/2027](https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/feb_2027) e [jun/2027](https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/june_2027).

## 3. Preço

- **Decisão** [Gabriel]: **US$14,99**, com desconto de lançamento até cerca de **US$9,99** (uns 33%). Preço regional sugerido pela Steam.
- **Não verificado:** os preços de referência, citados de memória (Hollow Knight US$14,99, Silksong US$19,99).

## 4. O nome do chefe: "D Rock"

- **Decisão** [Gabriel]: **"D Rock"**, com o grito "D ROCKKKK!". O nome brinca com o "D." de One Piece. O nome original do jogo da faculdade era "The Rock".
- **Por que mudou:** desde jan/2024 **Dwayne Johnson é dono da marca "The Rock"** ([Law360](https://law360.com/amp/articles/1789231), [Yahoo](https://www.yahoo.com/lifestyle/dwayne-johnson-officially-gains-ownership-041822676.html)). Uma análise jurídica lista registros que incluem software de jogos ([Gerben Law](https://www.gerbenlaw.com/?p=15416)). **Não conferido** direto no USPTO.
- **Ponto de atenção** [opinião, não é parecer jurídico]: "D Rock" ainda soa parecido com "The Rock". **Antes de publicar a página da Steam, fazer uma busca no USPTO e no INPI.** O "uso justo" citado no brainstorm com o Gemini é um conceito da lei dos EUA e não protege bem um nome de personagem num produto à venda.
- **Descartados:** manter "The Rock" (risco de marca); nome em português (Rochedo, Pedrão); "The Rock" só como apelido.

## 5. Orçamento

**Princípio** [Gabriel]: sem freelancers. Tudo é feito pelo Gabriel e pelas IAs. O Gabriel se dedica em tempo integral; **o limite é a cota das IAs**.

| Item | Quando | Custo | Situação |
|---|---|---|---|
| Claude Pro | mensal, já | preço atual não verificado | assinado [Gabriel] |
| ChatGPT Go (Codex) | mensal, já | preço e cota do Codex no Go não verificados | assinado [Gabriel] |
| Aseprite | uma vez | não verificado | para finalizar os sprites |
| Suno ou outra IA de música, plano pago | só quando gerar a trilha de verdade | uns US$10/mês segundo fontes secundárias, não verificado | as músicas do plano grátis **não** viram comerciais depois ([terms.law](https://terms.law/ai-output-rights/suno/), [Music in Africa](https://www.musicinafrica.net/magazine/suno-adjusts-ai-music-ownership-terms-after-warner-music-partnership)); a propriedade das músicas mudou no fim de 2025, **conferir os termos oficiais** |
| Steam Direct | antes da página | US$100 (recuperável) | oficial |
| Consulta com contador | antes do lançamento | não pesquisado | decisão do Gabriel |
| Busca de marca (USPTO/INPI) | antes da página | gratuita, segundo o Claude; não verificado | — |

**Regra do AGENTS.md:** qualquer gasto pago de API, imagem, voz ou música é avisado antes, com quanto e onde.

## 6. Cronograma: sem data, por marcos

**Decisão** [Gabriel]: **sem meta e sem data. O foco é o jogo completo, não a demo.**

1. **Base pronta:** mundo interligado, Orion jogável, santuários e relógio.
2. **Primeira região com arte final:** a Clareira.
3. **Metade do jogo:** umas 4 das 8 regiões. Nesse ponto entram a **página da Steam, o Discord e os posts** (seção 7).
4. **As 8 regiões e as 16 lutas.**
5. **Demo:** recortada do começo do jogo pronto (do início até o D Rock), no Next Fest anterior ao lançamento.
6. **Lançamento do 1.0.**

[opinião, registrada uma vez] Sem data, vale olhar o andamento no STATUS de tempos em tempos.

**Descartados:** metas com data (demo em jun/2027 ou out/2027; 1.0 em 2028 ou 2029). A demo como meta própria.

## 7. Marketing

- **Canal Esquilo Otaku** (opção C) [Gabriel]: o canal é de anime, então o jogo entra só como **menção de vez em quando**, para medir o engajamento. Se engajar, a série de devlogs pode ser reavaliada.
- **Discord e GIFs semanais nas redes** (X, Bluesky, TikTok) [proposta + Gabriel]:
  - **começam só quando o jogo estiver pela metade**, junto com a página da Steam;
  - antes disso, nada de postar [Gabriel];
  - a IA escreve os textos dos posts e o Gabriel revisa.
- **Página da Steam:** vai ao ar na metade do jogo, para acumular listas de desejos até o lançamento. [opinião] O ideal é de 6 a 12 meses de página antes do lançamento.
- **Público** (bloco 2): o alvo são os fãs de metroidvania do mundo todo; o Brasil é a primeira comunidade; o hardcore entra pelo modo Desafio.
- **Ganchos de comunicação** [opinião]:
  - "refazendo o jogo da faculdade";
  - folclore brasileiro;
  - "no original ele se chamava The Rock";
  - o modo Desafio todo à noite.

## Perguntas em aberto

- Se existe MEI para jogos: conferir no Portal do Empreendedor e a Lei 14.852/2024.
- O valor real da retenção nos EUA e quando abrir a ME (contador).
- Qual banco usar para receber em dólar.
- Busca de marca "D Rock" no USPTO e no INPI.
- Qual IA de música usar e os termos oficiais dela.
- Preços atuais do Claude Pro, do ChatGPT Go e do Aseprite.
- Regra oficial do desconto de lançamento na Steam.
