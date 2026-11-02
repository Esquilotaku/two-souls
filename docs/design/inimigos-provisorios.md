# Inimigos provisórios

São três formas temporárias desenhadas por código, sem imagem. A origem fica no centro do corpo; os pés tocam o chão quando a metade inferior da colisão alcança a superfície.

- **Corredor corrompido** (`corrupted_runner`): 72 px de altura e 34 px de largura. Persegue e tenta chegar perto para atacar; representa animais corrompidos velozes, como o calango ou a jaguatirica.
- **Lanceiro tribal** (`tribal_spearman`): 76 px de altura e 28 px de largura. Mantém distância e arremessa lanças, como o lanceiro da Trilha da Tribo.
- **Bicho grande** (`giant_beast`): 100 px de altura e 56 px de largura. É a opção mais alta e larga para uma criatura pesada; usa provisoriamente o comportamento de aproximação e ataque próximo.

Ao criar um inimigo, Claude escolhe o tipo antes de adicioná-lo à cena:

```gdscript
var foe := ForestFoe.new()
foe.kind = "giant_beast" # ou "corrupted_runner" / "tribal_spearman"
```

Sem escolher `kind`, o inimigo continua sendo o corredor padrão. As opções antigas `ranged` e `tribal` continuam funcionando; `tribal = true` também seleciona o lanceiro quando `kind` está vazio.
