extends SceneTree
## Teste sem janela do mundo contínuo: começa um jogo e ANDA de verdade (apertando as ações)
## por todas as passagens entre áreas, confere bloqueio, santuário, morte, continuar e a
## migração do save 4. Guarda o save real do jogador antes e devolve no fim.
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
	_expect(game.world.rooms.size() == WorldMap.room_ids().size(), "o mapa inteiro está na mesma cena")

	await _test_gate_blocks()
	await _test_shrine_and_death()
	await _test_dash()
	await _test_all_passages()
	await _test_continue()
	_test_v4_upgrade()

	print("Fluxo do mundo conferido, falhas: %d" % failures)
	_release_all()
	game.queue_free()
	await _frames(2)
	_restore_saves()
	quit(1 if failures > 0 else 0)

## Sem a lança cravada, o bloco laranja da Trilha não deixa passar.
func _test_gate_blocks() -> void:
	var entry := WorldMap.door("trilha_entrada", "leste")
	var room: WorldRoom = game.world.room("trilha_entrada")
	game._place_player("trilha_entrada", Vector2(room.size_px.x - 120.0, WorldMap.row_floor_y(int(entry["row"])) - 33.0))
	await _hold("move_right", 1.0)
	_expect(game.room_id == "trilha_entrada", "o bloqueio impede a passagem sem a habilidade")

func _test_shrine_and_death() -> void:
	var clareira: WorldRoom = game.world.room("clareira_inicio")
	game._place_player("clareira_inicio", clareira.shrine_point())
	_expect(game._try_shrine(), "o santuário da Clareira responde à interação")
	_expect(game.shrine_room == "clareira_inicio", "ativar o santuário marca o ponto de volta")
	var saved: Dictionary = SAVE_MANAGER.load_campaign()
	_expect(saved.get("shrine_room", "") == "clareira_inicio", "o save guarda o santuário ativado")
	game._place_player("floresta_borda", game.world.room("floresta_borda").spawn_point())
	game.player.take_damage(99)
	await _seconds(1.6)
	_expect(game.room_id == "clareira_inicio", "morrer volta à área do último santuário")
	_expect(game.player.health == game.player.max_health, "morrer não tira vida máxima")

## Com todas as habilidades, anda por cada passagem e confere que chega à área vizinha.
func _test_all_passages() -> void:
	for ability in WorldMap.ABILITIES:
		game.abilities[ability] = true
	# As arenas ficam vazias: aqui se testa o mapa, não a luta.
	for boss_key in WorldMap.BOSSES:
		game.defeated_bosses[boss_key] = true
	game._sync_player_abilities()
	game.world.refresh_gates(game.abilities)
	await _frames(2)
	_expect(game.player.double_jump, "o gavião liga o pulo duplo")
	var crossed := 0
	for room_id: String in WorldMap.room_ids():
		for entry: Dictionary in WorldMap.room(room_id).get("doors", []):
			if entry.has("future"):
				continue
			if await _cross(room_id, entry):
				crossed += 1
			else:
				_fail("%s/%s não levou a %s (parou em %s, posição %s)" % [room_id, entry["id"], entry["to"], game.room_id, game.player.global_position - game.current.position])
	print("Passagens atravessadas andando: %d" % crossed)
	_expect(game.visited_rooms.size() == WorldMap.room_ids().size(), "todas as áreas ficam como visitadas")

func _cross(room_id: String, entry: Dictionary) -> bool:
	_release_all()
	# Sem isso, apertar "direita" em duas passagens seguidas vira duplo toque (dash).
	game.player._last_tap_direction = 0
	var room: WorldRoom = game.world.room(room_id)
	var target: String = entry["to"]
	match entry["side"]:
		"east", "west":
			var row_floor := WorldMap.row_floor_y(int(entry["row"]))
			var x := room.size_px.x - 120.0 if entry["side"] == "east" else 120.0
			game._place_player(room_id, Vector2(x, row_floor - 33.0))
			return await _until(target, "move_right" if entry["side"] == "east" else "move_left", 2.5)
		"down":
			var hole_x := (int(entry["col"]) + 0.5) * WorldMap.SCREEN.x
			game._place_player(room_id, Vector2(hole_x, room.floor_y() - 60.0))
			return await _until(target, "", 2.5)
		_:
			# Sobe pela abertura do teto: parte do apoio embaixo dela, pula e anda para o lado.
			var hole_x := (int(entry["col"]) + 0.5) * WorldMap.SCREEN.x
			game._place_player(room_id, Vector2(hole_x + 20.0, WorldRoom.UP_LANDING_Y - 33.0))
			await _frames(3)
			Input.action_press("jump")
			await _frames(2)
			Input.action_release("jump")
			return await _until(target, "move_right", 2.0)

## Segura uma ação (ou nenhuma) até o Orion entrar na área target ou o tempo acabar.
func _until(target: String, action: String, seconds: float) -> bool:
	if action != "":
		Input.action_press(action)
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	var reached := false
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if game.room_id == target:
			reached = true
			break
	_release_all()
	return reached

func _hold(action: String, seconds: float) -> void:
	Input.action_press(action)
	await _seconds(seconds)
	Input.action_release(action)

func _release_all() -> void:
	for action in ["move_left", "move_right", "jump"]:
		Input.action_release(action)

func _test_continue() -> void:
	game._drop_boss_rune("the_rock")
	_expect(game.runes.found_runes.has("mapinguari"), "vencer o D Rock deixa a runa do Mapinguari")
	game._find_rune("saci")
	_expect(game.runes.purify("saci") and game.runes.equip("saci"), "runa achada pode ser purificada e equipada")
	_expect(game._save_campaign(), "o save do mundo contínuo é válido")
	game._show_title()
	await _frames(3)
	game._continue_game()
	await _frames(5)
	_expect(game.room_id == "clareira_inicio", "continuar volta ao último santuário")
	_expect(game.abilities.size() == WorldMap.ABILITIES.size(), "continuar mantém as habilidades")
	_expect(game.visited_rooms.size() == WorldMap.room_ids().size(), "continuar mantém o mapa visitado")
	_expect(game.runes.equipped_runes.has("saci"), "continuar mantém a runa equipada")
	_expect(game.runes.found_runes.has("mapinguari"), "continuar mantém a runa achada")
	_expect(float(game.player.rune_bonus.get("cooldown", 0.0)) < 0.0, "a runa equipada chega ao Orion")

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

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _seconds(duration: float) -> void:
	await create_timer(duration).timeout

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

## Duplo toque rápido na seta dá dash; dois toques lentos não.
func _test_dash() -> void:
	var clareira: WorldRoom = game.world.room("clareira_inicio")
	game._place_player("clareira_inicio", clareira.spawn_point())
	await _frames(3)
	game.player._last_tap_direction = 0
	await _tap("move_right")
	await _frames(2)
	await _tap("move_right")
	_expect(game.player.is_dashing(), "dois toques rápidos na seta dão dash")
	await _seconds(0.6)
	_release_all()
	game.player._last_tap_direction = 0
	await _tap("move_right")
	await _seconds(0.4)
	await _tap("move_right")
	_expect(not game.player.is_dashing(), "dois toques lentos não dão dash")
	_release_all()

## Segura a tecla por 2 quadros de física (o jogo lê teclas na física; no modo sem janela os quadros
## de desenho são mais rápidos e um toque curto demais poderia sumir entre duas leituras).
func _tap(action: String) -> void:
	Input.action_press(action)
	await physics_frame
	await physics_frame
	Input.action_release(action)
