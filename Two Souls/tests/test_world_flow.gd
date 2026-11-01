extends SceneTree
## Teste sem janela do fluxo do mundo: começa um jogo, atravessa todas as portas,
## ativa santuário, morre, volta no santuário, continua do save e migra um save da versão 4.
## Guarda o save real do jogador antes e devolve no fim.
## Uso: godot --headless --path "Two Souls" -s res://tests/test_world_flow.gd

const SAVE_MANAGER = preload("res://scripts/save_manager.gd")
const SAVE_FILES := ["user://two_souls_save.json", "user://two_souls_save.bak", "user://two_souls_save.tmp"]

var failures := 0
var game: Node

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_backup_saves()
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await _frames(5)
	game._start_new_game()
	await _frames(5)
	_expect(game.room_id == WorldMap.START_ROOM, "o jogo começa na Clareira")
	_expect(SAVE_MANAGER.has_save(), "o jogo novo grava o save")

	await _test_gate_blocks()
	await _test_shrine_and_death()
	await _test_all_doors()
	await _test_continue()
	_test_v4_upgrade()

	print("Fluxo do mundo conferido, falhas: %d" % failures)
	game.queue_free()
	await _frames(2)
	_restore_saves()
	quit(1 if failures > 0 else 0)

## Sem a lança cravada, a porta leste da Trilha não deixa passar.
func _test_gate_blocks() -> void:
	await _enter("trilha_entrada")
	var trigger := _trigger("trilha_entrada", "leste")
	game.player.global_position = _inside(trigger)
	await _frames(20)
	_expect(game.room_id == "trilha_entrada", "porta bloqueada não troca de sala sem a habilidade")

func _test_shrine_and_death() -> void:
	await _enter("clareira_inicio")
	game.player.global_position = Vector2(game.world.shrine.position.x, game.world.floor_y() - 33.0)
	_expect(game._try_shrine(), "o santuário da Clareira responde à interação")
	_expect(game.shrine_room == "clareira_inicio", "ativar o santuário marca o ponto de volta")
	var saved: Dictionary = SAVE_MANAGER.load_campaign()
	_expect(saved.get("shrine_room", "") == "clareira_inicio", "o save guarda o santuário ativado")
	await _enter("floresta_borda")
	game.player.take_damage(99)
	await _seconds(1.6)
	_expect(game.room_id == "clareira_inicio", "morrer volta à sala do último santuário")
	_expect(game.player.health == game.player.max_health, "morrer não tira vida máxima")

## Com todas as habilidades, cada porta leva à sala e porta certas.
func _test_all_doors() -> void:
	for ability in WorldMap.ABILITIES:
		game.abilities[ability] = true
	game._sync_player_abilities()
	_expect(game.player.double_jump, "o gavião liga o pulo duplo")
	var crossed := 0
	for room_id: String in WorldMap.room_ids():
		for entry: Dictionary in WorldMap.room(room_id).get("doors", []):
			if entry.has("future"):
				continue
			await _enter(room_id)
			var trigger := _trigger(room_id, entry["id"])
			game.player.global_position = _inside(trigger)
			var changed := false
			var deadline := Time.get_ticks_msec() + 2000
			while Time.get_ticks_msec() < deadline:
				await process_frame
				if game.room_id == entry["to"] and not game.transitioning:
					changed = true
					break
			if not changed:
				_fail("%s/%s não levou a %s" % [room_id, entry["id"], entry["to"]])
				continue
			crossed += 1
			var expected: Vector2 = game.world.arrival_point(entry["to_door"])
			_expect(game.player.global_position.distance_to(expected) < 80.0, "%s/%s chega perto da porta %s" % [room_id, entry["id"], entry["to_door"]])
	print("Portas atravessadas: %d" % crossed)
	_expect(game.visited_rooms.size() == WorldMap.room_ids().size(), "todas as salas ficam como visitadas")

func _test_continue() -> void:
	_expect(game._save_campaign(), "o save do mundo interligado é válido")
	game._show_title()
	await _frames(3)
	game._continue_game()
	await _frames(5)
	_expect(game.room_id == "clareira_inicio", "continuar volta ao último santuário")
	_expect(game.abilities.size() == WorldMap.ABILITIES.size(), "continuar mantém as habilidades")
	_expect(game.visited_rooms.size() == WorldMap.room_ids().size(), "continuar mantém o mapa visitado")

func _test_v4_upgrade() -> void:
	var old := {
		"version": 4, "world_hour": 9.5, "stage_index": 3, "checkpoint_x": 1040.0, "checkpoint_marker": 1,
		"health": 4, "magic": 2, "level": 3, "experience": 10, "experience_to_next": 90,
		"twin_magic": false, "rock_recruited": true, "boss_defeated": false,
		"inventory": {"luminous_herb": 2, "mana_seed": 1}, "collected_pickups": ["stage_01_herb"],
		"skill_points": 1, "unlocked_skills": ["spear_throw"]
	}
	var upgraded: Dictionary = SAVE_MANAGER._upgrade_campaign(old)
	_expect(SAVE_MANAGER._is_valid(upgraded), "save da versão 4 vira versão 5 válida")
	_expect(upgraded.get("room_id", "") == WorldMap.START_ROOM and int(upgraded.get("level", 0)) == 3, "a migração começa na Clareira e mantém o nível")

func _enter(room_id: String) -> void:
	game._enter_room(room_id, "")
	game.door_cooldown = 0.0
	await _frames(2)
	game.door_cooldown = 0.0

func _trigger(room_id: String, door_id: String) -> Dictionary:
	for trigger in game.world.door_triggers:
		if trigger["door"]["id"] == door_id:
			return trigger
	_fail("porta %s/%s não montada" % [room_id, door_id])
	return {"rect": Rect2()}

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	failures += 1
	push_error("FALHOU: " + message)

func _backup_saves() -> void:
	for path in SAVE_FILES:
		if FileAccess.file_exists(path):
			DirAccess.rename_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(path + ".antes_do_teste"))

func _restore_saves() -> void:
	for path in SAVE_FILES:
		var absolute := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(absolute)
		if FileAccess.file_exists(path + ".antes_do_teste"):
			DirAccess.rename_absolute(absolute + ".antes_do_teste", absolute)

## Ponto da faixa da porta que fica dentro da sala (por onde o jogador entra nela de verdade).
func _inside(trigger: Dictionary) -> Vector2:
	var bounds := Rect2(Vector2.ZERO, game.world.size_px)
	return (trigger["rect"] as Rect2).intersection(bounds).get_center()

func _seconds(duration: float) -> void:
	await create_timer(duration).timeout
