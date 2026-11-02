extends SceneTree
## Ferramenta de medição (não é teste do CI): um "corredor" automático vai da Clareira até a arena
## do D Rock segurando a direita e pulando sem parar, como quem já sabe o caminho e ignora inimigos.
## Mede o tempo no relógio do jogo. Roda a física 4x mais rápido com o mesmo passo de tempo.
## Uso: godot --headless --path "Two Souls" -s res://tests/medir_corrida.gd
## Meta do Gabriel (01/11/2026): uns 5 minutos correndo direto; 15 a 20 minutos jogando normal.

const SAVE_FILES := ["user://two_souls_save.json", "user://two_souls_save.bak", "user://two_souls_save.tmp"]
const SPEEDUP := 4
const LIMIT_GAME_SECONDS := 900.0

var game: Node
var game_time := 0.0
var stuck_time := 0.0
var last_x := 0.0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_backup_saves()
	Engine.physics_ticks_per_second = 60 * SPEEDUP
	Engine.time_scale = SPEEDUP
	Engine.max_physics_steps_per_frame = 32
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await physics_frame
	game._start_new_game()
	# A lança cravada é ganha no altar da Clareira, que fica no caminho; liga direto para não depender dele.
	game._grant_ability("spear_wall")
	await physics_frame
	Input.action_press("move_right")
	var jump_clock := 0.0
	var visited := {}
	while game.room_id != "trilha_arena" and game_time < LIMIT_GAME_SECONDS:
		await physics_frame
		var dt := 1.0 / 60.0
		game_time += dt
		# Invencível: a medição é do caminho, não da luta.
		game.player.hurt_timer = 1.0
		game.player.health = game.player.max_health
		jump_clock += dt
		if jump_clock >= 0.42:
			jump_clock = 0.0
			Input.action_press("jump")
		elif jump_clock >= 0.05:
			Input.action_release("jump")
		if not visited.has(game.room_id):
			visited[game.room_id] = true
			print("%6.1f s  entrou em %s" % [game_time, game.room_id])
		var x: float = game.player.global_position.x
		stuck_time = stuck_time + dt if absf(x - last_x) < 0.5 else 0.0
		last_x = x
		if stuck_time > 6.0:
			print("PRESO em %s, posição na área %s" % [game.room_id, (game.player.global_position - game.current.position).round()])
			break
	Input.action_release("move_right")
	Input.action_release("jump")
	if game.room_id == "trilha_arena":
		print("Chegou ao D Rock em %.0f s (%.1f min) de jogo." % [game_time, game_time / 60.0])
	else:
		print("Não chegou ao D Rock (parou em %s depois de %.0f s)." % [game.room_id, game_time])
	Engine.time_scale = 1.0
	game.queue_free()
	await physics_frame
	_restore_saves()
	quit(0)

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
