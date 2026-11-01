extends SceneTree
## Teste sem janela do mundo interligado: portas com volta, todas as salas alcançáveis
## na ordem das habilidades e cada sala montando sem erro.
## Uso: godot --headless --path "Two Souls" -s res://tests/test_world_map.gd

var failures := 0

func _init() -> void:
	for error in WorldMap.validate():
		_fail(error)
	var reached := WorldMap.reachable_rooms()
	for room_id in WorldMap.room_ids():
		if not reached.has(room_id):
			_fail("sala inalcançável a partir do início: %s" % room_id)
	var all_abilities := {}
	for ability in WorldMap.ABILITIES:
		all_abilities[ability] = true
	for room_id: String in WorldMap.room_ids():
		_check_room(room_id, {}, "sem habilidades")
		_check_room(room_id, all_abilities, "com todas as habilidades")
	print("Salas conferidas: %d, alcançáveis: %d, falhas: %d" % [WorldMap.room_ids().size(), reached.size(), failures])
	quit(1 if failures > 0 else 0)

func _check_room(room_id: String, abilities: Dictionary, label: String) -> void:
	var room := WorldRoom.new()
	root.add_child(room)
	room.build(room_id, abilities, {}, func(_id: String) -> bool: return false)
	if room.boss:
		_fail("%s: chefe nasceu antes do jogador entrar" % room_id)
	var bounds := Rect2(Vector2.ZERO, room.size_px)
	var expected := 0
	for entry: Dictionary in room.data.get("doors", []):
		if not entry.has("future"):
			expected += 1
	if room.door_triggers.size() != expected:
		_fail("%s (%s): %d portas montadas, esperava %d" % [room_id, label, room.door_triggers.size(), expected])
	for trigger in room.door_triggers:
		var arrival: Vector2 = trigger["arrival"]
		if not bounds.has_point(arrival):
			_fail("%s/%s: chegada fora da sala" % [room_id, trigger["door"]["id"]])
		for other in room.door_triggers:
			if (other["rect"] as Rect2).has_point(arrival):
				_fail("%s/%s: chegada dentro da porta %s" % [room_id, trigger["door"]["id"], other["door"]["id"]])
	if not bounds.has_point(room.spawn_point()):
		_fail("%s: ponto inicial fora da sala" % room_id)
	room.free()

func _fail(message: String) -> void:
	failures += 1
	push_error("FALHOU: " + message)
