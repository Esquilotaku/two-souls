# Minimapa

O minimapa mostra apenas as áreas que Kaê já visitou, cada uma com a cor da sua região. Um ponto piscando mostra onde ele está, uma borda clara destaca a área atual, e marcas nas bordas mostram portas conhecidas. Um bloqueio de habilidade ainda fechado aparece em laranja com uma letra provisória. A versão pequena mede 120×70 pixels e fica no canto inferior direito, abaixo do HUD. O mapa grande ocupa a tela, acompanha Kaê e permite aproximar ou afastar com a roda do mouse.

## Como ligar no jogo

No `game.gd`, declare a variável junto das outras variáveis do jogo, adicione o minimapa dentro de `_ready()` depois de montar a interface, e atualize-o dentro de `_process()` junto do HUD:

```gdscript
var minimap := WorldMinimap.new() # junto das variáveis do game.gd
add_child(minimap); minimap.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT) # em _ready()
minimap.update_view(visited_rooms, room_id, player.global_position, abilities) # em _process(), junto do HUD
```

Para abrir/fechar o mapa grande ao tratar a ação `map`, chame `minimap.set_large_map(true/false)`.

## Depois

Marcadores manuais do jogador, tipos de marcador e ícones próprios dos animais ficam para depois. Por enquanto, bloqueios conhecidos usam uma letra do nome da habilidade.
