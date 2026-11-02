extends SceneTree
## Confere revelação por áreas, inclusive um trecho largo de 60 x 2 telas.
## Uso: godot --headless --path "Two Souls" -s res://tests/test_minimap.gd

var failures := 0

func _init() -> void:
	var minimap := WorldMinimap.new()
	root.add_child(minimap)
	minimap.size = Vector2(640, 360)
	minimap.update_view({}, "", Vector2.ZERO, {})
	_expect(minimap.visible_rects().is_empty(), "sem áreas visitadas, o mapa fica vazio")

	var rects := minimap.visible_rects()
	var largo := minimap.rect_for_room({"cell": Vector2i(300, 10), "size": Vector2i(60, 2)})
	_expect(largo.size.x > largo.size.y, "a área de exemplo 60 x 2 mantém proporção horizontal")
	minimap.update_view({"trilha_entrada": true}, "trilha_entrada", Vector2(16 * 640.0, 0), {"spear_wall": false})
	rects = minimap.visible_rects()
	_expect(rects.size() == 1, "somente a área visitada aparece")
	if rects.size() == 1:
		_expect(rects[0]["id"] == "trilha_entrada", "o retângulo pertence à área visitada")
	minimap.set_large_map(true)
	_expect(minimap.is_large_map_open(), "o modo mapa grande pode ser aberto")
	largo = minimap.rect_for_room({"cell": Vector2i(300, 10), "size": Vector2i(60, 2)})
	_expect(largo.size.x > largo.size.y, "área 60 x 2 mantém proporção também no mapa grande")
	_expect(minimap.visible_rects().size() == 1, "só a sala visitada continua visível no modo grande")
	minimap.update_view({"clareira_inicio": true}, "clareira_inicio", Vector2.ZERO, {})
	_expect(minimap.visible_rects().size() == 1, "área não visitada continua escondida")
	minimap.free()
	print("Minimapa conferido, falhas: %d" % failures)
	quit(1 if failures > 0 else 0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FALHOU: " + message)
