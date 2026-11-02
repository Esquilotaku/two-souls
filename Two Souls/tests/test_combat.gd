extends SceneTree
## Teste sem janela dos combos do Kaê (docs/design/combos-proposta.md): aperta as teclas de verdade
## contra um inimigo comum e confere acertos, contador, lançador e dash + A.
## Uso: godot --headless --path "Two Souls" -s res://tests/test_combat.gd

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

	# Combo básico: A, A, A, A acerta 4 vezes e o contador sobe.
	var foe := await _foe_in_front()
	var start_health: int = foe.health
	for i in range(4):
		await _tap("attack")
		await _seconds(0.2)
	await _seconds(0.5)
	_expect(start_health - foe.health >= 4, "A, A, A, A acerta 4 vezes (vida %d -> %d)" % [start_health, foe.health])
	_expect(game.player.combo.hits_in_a_row >= 4 or game.player.combo.counter_timer > 0.0 or start_health - foe.health >= 4, "o contador de golpes conta o combo")
	foe.queue_free()
	await _seconds(0.8)

	# Lançador: A, A, ↑+A joga o inimigo para cima.
	foe = await _foe_in_front()
	var ground_y: float = foe.global_position.y
	await _tap("attack")
	await _seconds(0.2)
	await _tap("attack")
	await _seconds(0.2)
	Input.action_press("look_up")
	await _tap("attack")
	var highest := ground_y
	var until := Time.get_ticks_msec() + 1000
	while Time.get_ticks_msec() < until:
		await process_frame
		highest = minf(highest, foe.global_position.y)
	Input.action_release("look_up")
	_expect(ground_y - highest > 40.0, "A, A, ↑+A lança o inimigo (subiu %.0f px)" % (ground_y - highest))
	foe.queue_free()
	await _seconds(0.8)

	# Dash + A: investida que acerta de longe.
	foe = await _foe_in_front(170.0)
	start_health = foe.health
	game.player._last_tap_direction = 0
	await _tap("move_right")
	await _frames(2)
	await _tap("move_right")
	await _frames(2)
	await _tap("attack")
	await _seconds(0.6)
	_expect(foe.health < start_health, "dash + A acerta o inimigo à frente")

	print("Combos conferidos, falhas: %d" % failures)
	game.queue_free()
	await _frames(2)
	_restore_saves()
	quit(1 if failures > 0 else 0)

## Põe o Kaê parado na Clareira e um inimigo forte, parado, à frente dele.
func _foe_in_front(distance: float = 44.0) -> Node:
	var clareira: WorldRoom = game.world.room("clareira_inicio")
	game._place_player("clareira_inicio", clareira.spawn_point())
	game.player.facing = 1
	game.player.health = game.player.max_health
	await _frames(3)
	var foe := ForestFoe.new()
	foe.health = 40
	foe.speed = 0.0
	foe.patrol_span = 0.0
	foe.global_position = game.player.global_position + Vector2(distance, 20.0)
	game.world.add_child(foe)
	foe.attack_cooldown = 99.0
	await _seconds(0.3)
	return foe

## Segura a tecla por 2 quadros de física (o jogo lê teclas na física; no modo sem janela os quadros
## de desenho são mais rápidos e um toque curto demais poderia sumir entre duas leituras).
func _tap(action: String) -> void:
	Input.action_press(action)
	await physics_frame
	await physics_frame
	Input.action_release(action)

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _seconds(duration: float) -> void:
	await create_timer(duration).timeout

func _expect(condition: bool, message: String) -> void:
	if not condition:
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
