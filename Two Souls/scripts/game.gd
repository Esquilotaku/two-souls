extends Node2D
## Fluxo do jogo: título, mundo interligado em salas, santuários, save, HUD e menus.
## O mapa e as salas vêm de WorldMap e WorldRoom (docs/tecnico/plano-tecnico-mundo.md).

const DAY_CYCLE_REAL_SECONDS := 900.0
const UI_SCALE := 1.0
const UI_SIZE := Vector2(640.0, 360.0)
const TREE_ART = preload("res://assets/mother_tree_forest.png")
const ORION_IDLE_TEXTURE = preload("res://assets/sprites/orion_idle.png")
const AENIA_IDLE_TEXTURE = preload("res://assets/sprites/aenia_idle.png")
const SAVE_MANAGER = preload("res://scripts/save_manager.gd")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const SKILL_CATALOG = preload("res://scripts/skill_catalog.gd")

## Habilidade de travessia -> talento do player.gd que ela libera.
const ABILITY_SKILLS := {"spear_wall": "spear_throw", "super_punch": "super_punch"}

var ui_layer: CanvasLayer
var ui_root: Control
var world: WorldScene
## Área onde o Orion está agora e o chefe dela (se houver).
var current: WorldRoom
var active_boss: Node2D
var player: Orion
var aenia_companion: Node2D
var room_id := ""
var shrine_room := ""
var visited_rooms: Dictionary = {}
var activated_shrines: Dictionary = {}
var abilities: Dictionary = {}
var defeated_bosses: Dictionary = {}
## Runas achadas, purificadas e equipadas (scripts/runes, docs/design/runas.md).
var runes := RuneState.new()
var day := 1
var mode := "aventura"
var rock_recruited := false
var playing := false
var paused := false
var dialogue_open := false
var inventory_open := false
var inventory_returns_to_pause := false
var skill_tree_open := false
var skill_tree_returns_to_pause := false
var respawn_timer := 0.0
var message_timer := 0.0
var hud: GameHud
var world_hour := 7.0
var world_ambient: CanvasModulate
var last_enemy_night_pressure := -1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_controller")
	_configure_controls()
	world_ambient = CanvasModulate.new()
	world_ambient.color = Color.WHITE
	add_child(world_ambient)
	move_child(world_ambient, 0)
	_create_ui()
	_show_title()

func _process(delta: float) -> void:
	if dialogue_open:
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("pause"):
			_close_aenia_dialogue()
		return
	if Input.is_action_just_pressed("pause") and playing:
		if inventory_open:
			_close_inventory()
		elif skill_tree_open:
			_close_skill_tree()
		elif paused:
			_resume_game()
		else:
			_show_pause()
	if Input.is_action_just_pressed("inventory") and playing:
		if inventory_open:
			_close_inventory()
		elif not skill_tree_open and paused:
			_open_inventory(true)
		elif not skill_tree_open:
			_open_inventory(false)
	if Input.is_action_just_pressed("skill_tree") and playing:
		if skill_tree_open:
			_close_skill_tree()
		elif not inventory_open and paused:
			_open_skill_tree(true)
		elif not inventory_open:
			_open_skill_tree(false)
	if not playing or paused:
		return
	if not player or not is_instance_valid(player) or not world or not is_instance_valid(world):
		return
	if Input.is_action_just_pressed("interact") and player.health > 0:
		if _try_shrine():
			return
		if aenia_companion and is_instance_valid(aenia_companion) and player.global_position.distance_to(aenia_companion.global_position) <= 120.0:
			_open_aenia_dialogue()
			return
	_advance_world_time(delta)
	message_timer = maxf(0.0, message_timer - delta)
	if message_timer <= 0.0 and hud:
		hud.set_message("")
	_update_aenia_companion(delta)
	if player.health <= 0:
		respawn_timer += delta
		if respawn_timer >= 1.0:
			_respawn_player()
		return
	_track_room()
	_check_altar()
	_check_rune_stone()
	_update_hud()

func _create_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)
	# Os menus foram desenhados para 640x360; com a tela de 960x540 a camada inteira é ampliada 1,5x.
	ui_layer.scale = Vector2.ONE * UI_SCALE
	ui_root = Control.new()
	ui_root.position = Vector2.ZERO
	ui_root.size = UI_SIZE
	ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	ui_layer.add_child(ui_root)

## Teclas e botões do brainstorm-jogo.md (seção 7), com as trocas do jogador em user://controles.cfg.
func _configure_controls() -> void:
	InputConfig.load_saved()

## Nome curto da tecla de uma ação, para textos na tela (ex.: "Seta para cima").
func _key_name(action: String) -> String:
	return InputConfig.key_label(action)

## Abre a tela de remapeamento; ao fechar, volta para a tela de onde veio.
func _open_controls_menu(return_to: Callable) -> void:
	_clear_ui()
	var menu: Control = load("res://scripts/ui/controls_menu.gd").new()
	menu.closed.connect(func():
		menu.queue_free()
		return_to.call()
	)
	ui_root.add_child(menu)

func _show_title() -> void:
	playing = false
	paused = false
	inventory_open = false
	skill_tree_open = false
	get_tree().paused = true
	if player and is_instance_valid(player):
		player.active = false
	_clear_ui()
	var backdrop := TextureRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.texture = TREE_ART
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ui_root.add_child(backdrop)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.04, 0.12, 0.63)
	ui_root.add_child(shade)
	var title := _label("TWO SOULS", 48, Color("e7fff6"), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(70, 24)
	title.size = Vector2(500, 66)
	title.add_theme_color_override("font_shadow_color", Color("1d8c9e"))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 4)
	ui_root.add_child(title)
	var subtitle := _label("A JORNADA DE KAÊ", 16, Color("b8e9e1"), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.position = Vector2(70, 82)
	subtitle.size = Vector2(500, 30)
	ui_root.add_child(subtitle)
	var rule := ColorRect.new()
	rule.color = Color("6edcca")
	rule.position = Vector2(238, 116)
	rule.size = Vector2(164, 2)
	ui_root.add_child(rule)
	var story := _label("Quando o feiticeiro levou Aenia, a floresta perdeu sua luz.\nOrion segue o rastro até o coração de Monte Ligna.", 16, Color("e2e0d4"), HORIZONTAL_ALIGNMENT_CENTER)
	story.position = Vector2(90, 126)
	story.size = Vector2(460, 52)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_root.add_child(story)
	var buttons := VBoxContainer.new()
	var has_save := SAVE_MANAGER.has_save()
	buttons.position = Vector2(224, 188 if has_save else 200)
	buttons.size = Vector2(192, 130 if has_save else 96)
	buttons.add_theme_constant_override("separation", 6)
	ui_root.add_child(buttons)
	if has_save:
		var continue_button := _button("CONTINUAR")
		continue_button.custom_minimum_size.y = 28
		continue_button.pressed.connect(_continue_game)
		buttons.add_child(continue_button)
	var start := _button("NOVA JORNADA" if has_save else "INICIAR JORNADA")
	start.custom_minimum_size.y = 28
	start.pressed.connect(_request_new_game)
	buttons.add_child(start)
	var how := _button("COMO JOGAR")
	how.custom_minimum_size.y = 28
	how.pressed.connect(_show_controls)
	buttons.add_child(how)
	var keys := _button("CONTROLES")
	keys.pressed.connect(func(): _open_controls_menu(_show_title))
	keys.custom_minimum_size.y = 28
	buttons.add_child(keys)
	var footer := _label("Setas andam  ·  %s pula  ·  %s ataca  ·  seta 2x dash  ·  %s interage" % [_key_name("jump"), _key_name("attack"), _key_name("interact")], 11, Color("bed2d6"), HORIZONTAL_ALIGNMENT_CENTER)
	footer.position = Vector2(20, 333)
	footer.size = Vector2(600, 18)
	ui_root.add_child(footer)

func _request_new_game() -> void:
	if SAVE_MANAGER.has_save():
		_show_new_game_confirmation()
	else:
		_start_new_game()

func _show_new_game_confirmation() -> void:
	playing = false
	paused = false
	get_tree().paused = true
	_clear_ui()
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.035, 0.08, 0.86)
	ui_root.add_child(shade)
	var title := _label("NOVA JORNADA", 32, Color("e7fff6"), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(70, 82)
	title.size = Vector2(500, 48)
	ui_root.add_child(title)
	var warning := _label("Isso vai substituir o único arquivo de campanha salvo.\nSeu progresso atual será mantido se você voltar.", 16, Color("d8e9e4"), HORIZONTAL_ALIGNMENT_CENTER)
	warning.position = Vector2(84, 142)
	warning.size = Vector2(472, 64)
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_root.add_child(warning)
	var buttons := VBoxContainer.new()
	buttons.position = Vector2(210, 226)
	buttons.size = Vector2(220, 84)
	buttons.add_theme_constant_override("separation", 8)
	ui_root.add_child(buttons)
	var confirm := _button("SUBSTITUIR E COMEÇAR")
	confirm.pressed.connect(_start_new_game)
	buttons.add_child(confirm)
	var cancel := _button("VOLTAR")
	cancel.pressed.connect(_show_title)
	buttons.add_child(cancel)

func _show_controls() -> void:
	_clear_ui()
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.045, 0.105, 0.88)
	ui_root.add_child(shade)
	var title := _label("COMO JOGAR", 34, Color("e7fff6"), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(90, 42)
	title.size = Vector2(460, 48)
	ui_root.add_child(title)
	var help := "Ande com as setas; %s pula. Seta 2x: dash.\n%s ataca (A A A A; A A + seta cima ou baixo).\n%s magia; %s lança e %s super soco, depois de ganhá-los.\n%s ativa santuários e fala com Aená.\nBlocos laranja pedem uma habilidade.\n%s bolsa; %s talentos; %s pausa." % [
		_key_name("jump"), _key_name("attack"), _key_name("magic"),
		_key_name("throw_spear"), _key_name("super_punch"), _key_name("interact"),
		_key_name("inventory"), _key_name("skill_tree"), _key_name("pause")]
	var text := _label(help, 14, Color("d8e9e4"), HORIZONTAL_ALIGNMENT_CENTER)
	text.position = Vector2(100, 112)
	text.size = Vector2(440, 172)
	ui_root.add_child(text)
	var back := _button("VOLTAR")
	back.position = Vector2(232, 292)
	back.size = Vector2(176, 34)
	back.pressed.connect(_show_title)
	ui_root.add_child(back)

func _start_new_game() -> void:
	rock_recruited = false
	world_hour = 7.0
	day = 1
	mode = "aventura"
	last_enemy_night_pressure = -1.0
	shrine_room = ""
	visited_rooms.clear()
	activated_shrines.clear()
	abilities.clear()
	defeated_bosses.clear()
	runes = RuneState.new()
	_begin_play()
	_build_world()
	_place_at_shrine()
	_apply_world_time(true)
	_show_hud()
	if _save_campaign():
		_show_message("Siga as luzes entre as raízes", 3.2)
	else:
		_show_message("Jornada iniciada, mas não foi possível salvar no disco.", 4.0)

func _continue_game() -> void:
	var save_data: Dictionary = SAVE_MANAGER.load_campaign()
	if save_data.is_empty():
		_show_title()
		return
	rock_recruited = bool(save_data["rock_recruited"])
	world_hour = fposmod(float(save_data.get("world_hour", 7.0)), 24.0)
	day = int(save_data["day"])
	mode = str(save_data["mode"])
	last_enemy_night_pressure = -1.0
	shrine_room = str(save_data["shrine_room"])
	visited_rooms = _to_set(save_data["visited_rooms"])
	activated_shrines = _to_set(save_data["activated_shrines"])
	abilities = _to_set(save_data["abilities"])
	defeated_bosses = _to_set(save_data["defeated_bosses"])
	runes = RuneState.new()
	runes.from_save(save_data.get("runes", {}))
	_begin_play()
	player.set_skill_state(int(save_data.get("skill_points", 0)), save_data.get("unlocked_skills", []))
	player.health = clampi(int(save_data["health"]), 1, player.max_health)
	player.magic = clampi(int(save_data["magic"]), 0, player.max_magic)
	player.level = maxi(1, int(save_data["level"]))
	player.experience = maxi(0, int(save_data["experience"]))
	player.experience_to_next = maxi(1, int(save_data["experience_to_next"]))
	player.twin_magic = bool(save_data["twin_magic"])
	player.set_inventory(save_data.get("inventory", {}))
	player.set_collected_pickups(save_data.get("collected_pickups", []))
	_sync_player_abilities()
	# A campanha sempre recomeça no último santuário ativado (ou no início da Clareira).
	_build_world()
	_place_at_shrine()
	_apply_world_time(true)
	_show_hud()
	_show_message("Campanha retomada no último santuário", 3.0)

func _begin_play() -> void:
	if player and is_instance_valid(player):
		player.queue_free()
	player = null
	playing = true
	paused = false
	inventory_open = false
	skill_tree_open = false
	get_tree().paused = false
	respawn_timer = 0.0
	_create_player()

func _create_player() -> void:
	player = Orion.new()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.health_changed.connect(_on_health_changed)
	player.leveled_up.connect(_on_level_up)
	player.defeated.connect(_on_player_defeated)
	player.inventory_changed.connect(_on_inventory_changed)
	player.item_added.connect(_on_item_added)
	player.skills_changed.connect(_on_skills_changed)
	add_child(player)
	_sync_player_abilities()

func _to_set(values: Variant) -> Dictionary:
	var result := {}
	if typeof(values) == TYPE_ARRAY:
		for value in values:
			result[str(value)] = true
	return result

# --- Mundo ---

## Monta o mapa inteiro de novo (no início, ao continuar e ao descansar, para os inimigos voltarem).
func _build_world() -> void:
	if world and is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	aenia_companion = null
	active_boss = null
	current = null
	world = WorldScene.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	move_child(world, 1)
	world.build(abilities, activated_shrines, _is_collected)
	player.fall_limit_y = world.bounds.end.y + 200.0
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = int(world.bounds.position.x)
	camera.limit_top = int(world.bounds.position.y)
	camera.limit_right = int(world.bounds.end.x)
	camera.limit_bottom = int(world.bounds.end.y)
	if rock_recruited:
		_add_rock_companion()
	if player.twin_magic:
		_add_aenia_companion()

## Põe o Orion num ponto de uma área e atualiza a área atual.
func _place_player(target_room: String, local_point: Vector2) -> void:
	player.global_position = world.to_world(target_room, local_point)
	player.velocity = Vector2.ZERO
	player.active = true
	respawn_timer = 0.0
	room_id = ""
	_on_room_changed(target_room)
	player.get_node("Camera2D").reset_smoothing()
	_apply_world_time(true)
	_update_hud()

## Põe o Orion no último santuário ativado, ou no início da Clareira se nenhum foi ativado.
func _place_at_shrine() -> void:
	if shrine_room != "" and WorldMap.has_room(shrine_room):
		_place_player(shrine_room, world.room(shrine_room).shrine_point())
	else:
		_place_player(WorldMap.START_ROOM, world.room(WorldMap.START_ROOM).spawn_point())

## Descobre em que área o Orion está; ao mudar de área, troca o chefe e marca a área como visitada.
func _track_room() -> void:
	var here := world.room_at(player.global_position)
	if here != "" and here != room_id:
		_on_room_changed(here)

func _on_room_changed(next_room: String) -> void:
	if current and active_boss and is_instance_valid(active_boss):
		current.despawn_boss()
	active_boss = null
	room_id = next_room
	current = world.room(room_id)
	visited_rooms[room_id] = true
	var fighter := current.spawn_boss(defeated_bosses)
	if fighter:
		_start_boss(fighter)
	_update_hud()

## Ponto do Orion nas coordenadas da área atual.
func _local_player() -> Vector2:
	return player.global_position - current.position

func _check_altar() -> void:
	if current.altar_rect.size == Vector2.ZERO or not current.altar_rect.has_point(_local_player()):
		return
	var ability: String = current.data["grants"]
	current.altar_rect = Rect2()
	var altar := current.get_node_or_null("Altar")
	if altar:
		altar.queue_free()
	_grant_ability(ability)

## Itens e runas já pegos não voltam a aparecer no mapa ("rune:<id>" para as pedras de runa).
func _is_collected(pickup_id: String) -> bool:
	if pickup_id.begins_with("rune:"):
		var rune_id := pickup_id.trim_prefix("rune:")
		return runes.found_runes.has(rune_id) or runes.purified_runes.has(rune_id)
	return player.has_collected_pickup(pickup_id)

func _check_rune_stone() -> void:
	if current.rune_rect.size == Vector2.ZERO or not current.rune_rect.has_point(_local_player()):
		return
	current.rune_rect = Rect2()
	var stone := current.get_node_or_null("RuneStone")
	if stone:
		stone.queue_free()
	_find_rune(current.data["rune"])

## Runa achada (sempre corrompida): só vale depois de purificada num santuário.
func _find_rune(rune_id: String, fragments: int = 0) -> void:
	var is_new := runes.found(rune_id)
	if fragments > 0:
		runes.add_fragments(fragments)
	var saved := _save_campaign()
	var name_text: String = RuneCatalog.info(rune_id).get("name", "Runa")
	var message := "%s (corrompida) · purifique num santuário" % name_text if is_new else "+%d fragmentos de runa" % fragments
	if not saved:
		message += " · não foi possível salvar"
	_show_message(message, 3.6)

func _drop_boss_rune(boss_key: String) -> void:
	var info: Dictionary = WorldMap.BOSSES.get(boss_key, {})
	if info.has("rune"):
		_find_rune(info["rune"], 3)

## Menu de runas. No santuário dá para purificar; fora dele, só equipar e melhorar.
func _open_rune_menu(at_shrine: bool) -> void:
	paused = true
	get_tree().paused = true
	player.active = false
	_clear_ui()
	var menu: Control = load("res://scripts/ui/rune_menu.gd").new()
	ui_root.add_child(menu)
	menu.setup(runes, at_shrine)
	menu.closed.connect(func():
		menu.queue_free()
		player.apply_rune_bonuses(runes.total_bonuses(), true)
		_save_campaign()
		_resume_game()
		player.active = player.health > 0
	)

func _grant_ability(ability: String) -> void:
	if abilities.has(ability):
		return
	abilities[ability] = true
	_sync_player_abilities()
	world.refresh_gates(abilities)
	var saved := _save_campaign()
	var message := "Nova habilidade: %s" % WorldMap.ABILITIES.get(ability, ability)
	if not saved:
		message += " · não foi possível salvar"
	_show_message(message, 3.6)

## Liga as habilidades de travessia ao player: talentos equivalentes e o pulo duplo do gavião.
func _sync_player_abilities() -> void:
	if not player:
		return
	player.double_jump = abilities.has("gaviao")
	var learned: Array = player.get_unlocked_skill_ids()
	var changed := false
	for ability in ABILITY_SKILLS:
		if abilities.has(ability) and not learned.has(ABILITY_SKILLS[ability]):
			learned.append(ABILITY_SKILLS[ability])
			changed = true
	if changed:
		player.set_skill_state(player.skill_points, learned)
	player.apply_rune_bonuses(runes.total_bonuses())

# --- Santuários ---

func _try_shrine() -> bool:
	var shrine := current.shrine
	if not shrine or not shrine.is_player_near(_local_player()):
		return false
	if not shrine.active:
		shrine.active = true
		activated_shrines[room_id] = true
		shrine_room = room_id
		player.restore(99)
		_show_message("Santuário ativado · campanha salva" if _save_campaign() else "Santuário ativado, mas a gravação falhou.", 3.0)
	else:
		# Descansar: salva, enche vida e magia e faz os inimigos voltarem (o mapa é montado de novo).
		shrine_room = room_id
		player.restore(99)
		var saved := _save_campaign()
		_build_world()
		_place_at_shrine()
		_show_message("Você descansou · os inimigos voltaram" if saved else "Você descansou, mas a gravação falhou.", 3.0)
		_open_rune_menu(true)
	return true

func _respawn_player() -> void:
	respawn_timer = -999.0
	player.health = player.max_health
	player.magic = player.max_magic
	player.hurt_timer = 1.4
	_place_at_shrine()
	player.health_changed.emit(player.health)
	_show_message("Kaê desperta no último santuário", 2.6)

func _on_player_defeated() -> void:
	respawn_timer = 0.01

# --- Chefes ---

func _start_boss(fighter: Node2D) -> void:
	active_boss = fighter
	var boss_key: String = fighter.get_meta("boss_key")
	var info: Dictionary = WorldMap.BOSSES[boss_key]
	fighter.defeated.connect(_on_boss_defeated.bind(boss_key))
	if info.has("hour"):
		world_hour = fposmod(float(info["hour"]), 24.0)
		_apply_world_time(true)
	_show_message(info["name"] + " bloqueia a passagem!", 3.0)

func _on_boss_defeated(boss_key: String) -> void:
	defeated_bosses[boss_key] = true
	_drop_boss_rune(boss_key)
	active_boss = null
	player.restore(2)
	player.grant_skill_point()
	if boss_key == "the_rock":
		rock_recruited = true
	if boss_key == "corrupted_tree":
		player.unlock_twin_magic()
		player.restore(5)
		_add_aenia_companion()
	if current.data.has("grants"):
		_grant_ability(current.data["grants"])
	var saved := _save_campaign()
	if current.data.get("final", false):
		_show_ending()
		return
	if boss_key == "the_rock":
		_show_message("D Rock virou aliado. +1 ponto de talento." if saved else "D Rock virou aliado, mas não foi possível salvar o progresso.", 4.0)
	elif boss_key == "corrupted_tree":
		_show_message("Aená está livre! Pressione %s para conversar." % _key_name("interact") if saved else "Aená está livre, mas não foi possível salvar o progresso.", 4.0)

func _add_rock_companion() -> void:
	var companion := CorruptedBoss.new()
	companion.boss_id = "the_rock"
	companion.boss_name = "D Rock"
	companion.is_ally = true
	companion.floor_y = player.global_position.y + 33.0
	companion.position = Vector2(player.position.x - 64.0, player.position.y - 30.0)
	companion.process_mode = Node.PROCESS_MODE_PAUSABLE
	companion.collision_layer = 0
	companion.collision_mask = 0
	world.add_child(companion)

func _add_aenia_companion() -> void:
	if aenia_companion and is_instance_valid(aenia_companion):
		return
	var companion := Node2D.new()
	companion.name = "AeniaCompanion"
	companion.process_mode = Node.PROCESS_MODE_PAUSABLE
	companion.position = world.to_local(player.global_position) + Vector2(56.0, -10.0)
	companion.z_index = 1
	var sprite := Sprite2D.new()
	sprite.name = "AeniaSprite"
	sprite.texture = AENIA_IDLE_TEXTURE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(0.056, 0.056)
	companion.add_child(sprite)
	world.add_child(companion)
	aenia_companion = companion

func _update_aenia_companion(delta: float) -> void:
	if not aenia_companion or not is_instance_valid(aenia_companion) or not player or not is_instance_valid(player):
		return
	var direction := 1.0 if player.facing >= 0 else -1.0
	var target := player.global_position + Vector2(56.0 * direction, -10.0)
	aenia_companion.global_position = aenia_companion.global_position.move_toward(target, 540.0 * delta)
	var sprite := aenia_companion.get_node_or_null("AeniaSprite") as Sprite2D
	if sprite:
		sprite.flip_h = direction < 0.0
		sprite.position.y = sin(Time.get_ticks_msec() * 0.004) * 3.0

func _open_aenia_dialogue() -> void:
	dialogue_open = true
	paused = true
	get_tree().paused = true
	player.active = false
	_show_aenia_dialogue()

func _show_aenia_dialogue() -> void:
	_clear_ui()
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.025, 0.06, 0.58)
	ui_root.add_child(shade)
	var portrait := TextureRect.new()
	portrait.texture = AENIA_IDLE_TEXTURE
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.position = Vector2(72, 186)
	portrait.size = Vector2(126, 132)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(portrait)
	var panel := ColorRect.new()
	panel.position = Vector2(190, 192)
	panel.size = Vector2(382, 116)
	panel.color = Color(0.035, 0.09, 0.15, 0.94)
	ui_root.add_child(panel)
	var speaker := _label("AENÁ", 15, Color("9ef5dc"))
	speaker.position = Vector2(208, 198)
	speaker.size = Vector2(344, 24)
	ui_root.add_child(speaker)
	var dialogue := _label("Nossa magia voltou a se unir, Orion.\nVamos proteger Monte Ligna juntos.", 15, Color("e6f2eb"))
	dialogue.position = Vector2(208, 222)
	dialogue.size = Vector2(342, 52)
	dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_root.add_child(dialogue)
	var close := _button("FECHAR [%s]" % _key_name("interact"))
	close.position = Vector2(430, 270)
	close.size = Vector2(126, 28)
	close.custom_minimum_size = Vector2(126, 28)
	close.add_theme_font_size_override("font_size", 11)
	close.pressed.connect(_close_aenia_dialogue)
	ui_root.add_child(close)
	close.grab_focus()

func _close_aenia_dialogue() -> void:
	dialogue_open = false
	paused = false
	get_tree().paused = false
	if player and is_instance_valid(player):
		player.active = player.health > 0
	_show_hud()

# --- Save ---

func _save_campaign() -> bool:
	if not playing or not player or not is_instance_valid(player):
		return false
	var save_data := {
		"version": SAVE_MANAGER.SAVE_VERSION,
		"world_hour": world_hour,
		"day": day,
		"mode": mode,
		"room_id": room_id,
		"shrine_room": shrine_room,
		"visited_rooms": visited_rooms.keys(),
		"activated_shrines": activated_shrines.keys(),
		"abilities": abilities.keys(),
		"defeated_bosses": defeated_bosses.keys(),
		"health": player.health,
		"magic": player.magic,
		"level": player.level,
		"experience": player.experience,
		"experience_to_next": player.experience_to_next,
		"twin_magic": player.twin_magic,
		"rock_recruited": rock_recruited,
		"inventory": player.inventory.duplicate(true),
		"collected_pickups": player.get_collected_pickup_ids(),
		"skill_points": player.skill_points,
		"unlocked_skills": player.get_unlocked_skill_ids(),
		"runes": runes.to_save()
	}
	return SAVE_MANAGER.save_campaign(save_data)

func _on_health_changed(_value: int) -> void:
	_update_hud()

func _on_level_up(new_level: int) -> void:
	var saved := _save_campaign()
	var message := "Nível %d · +1 ponto de talento" % new_level
	if not saved:
		message += " · não foi possível salvar"
	_show_message(message, 2.8)

func _on_inventory_changed() -> void:
	_update_hud()

func _on_item_added(item_id: String, count: int) -> void:
	var definition := ITEM_CATALOG.get_definition(item_id)
	var saved := _save_campaign()
	if definition.is_empty():
		return
	var message := "%s · %d na bolsa" % [definition["name"], count]
	if not saved:
		message += " · não foi possível salvar"
	_show_message(message, 2.2)

func _on_skills_changed() -> void:
	_update_hud()

# --- HUD (scripts/ui/hud.gd) ---

func _show_hud() -> void:
	_clear_ui()
	hud = GameHud.new()
	ui_root.add_child(hud)
	_update_hud()

func _update_hud() -> void:
	if not hud or not is_instance_valid(hud) or not player:
		return
	hud.refresh(_hud_info())

## Tudo o que o HUD mostra, num dicionário (o HUD não conhece o jogo).
func _hud_info() -> Dictionary:
	var place := ""
	if room_id != "":
		var region_label := WorldMap.region_name(room_id)
		var room_label: String = WorldMap.room(room_id).get("name", "")
		place = room_label if room_label == region_label else "%s · %s" % [region_label, room_label]
	var objective := ""
	var shrine_near := current != null and is_instance_valid(current) and current.shrine != null and current.shrine.is_player_near(_local_player())
	if shrine_near and not current.shrine.active:
		objective = "%s · ATIVAR SANTUÁRIO" % _key_name("interact")
	elif shrine_near:
		objective = "%s · DESCANSAR E RUNAS" % _key_name("interact")
	var info := {
		"health": player.health, "max_health": player.max_health,
		"magic": player.magic, "max_magic": player.max_magic,
		"level": player.level, "xp": player.experience, "xp_next": player.experience_to_next,
		"place": place,
		"time": "Dia %d · %s · %s" % [day, _time_of_day_name().capitalize(), _format_world_time()],
		"objective": objective,
		"combo": player.combo.hits_in_a_row,
		"skills": [
			{"key": _key_name("throw_spear"), "short": "Lança", "unlocked": player.has_skill("spear_throw"),
				"cooldown": player.spear_cooldown / maxf(0.01, 1.15 * player._cooldown_scale())},
			{"key": _key_name("super_punch"), "short": "Soco", "unlocked": player.has_skill("super_punch"),
				"cooldown": player.super_punch_cooldown / maxf(0.01, 3.8 * player._cooldown_scale())},
			{"key": _key_name("magic"), "short": "Magia", "unlocked": player.magic > 0,
				"cooldown": player.magic_timer / maxf(0.01, 0.58 * player._cooldown_scale())},
		],
	}
	if active_boss and is_instance_valid(active_boss):
		info["boss_name"] = str(active_boss.boss_name)
		info["boss_health"] = int(active_boss.health)
		info["boss_max"] = int(active_boss.max_health)
	return info

# --- Relógio ---

func _advance_world_time(delta: float) -> void:
	var previous := world_hour
	world_hour = fposmod(world_hour + 24.0 * delta / DAY_CYCLE_REAL_SECONDS, 24.0)
	if world_hour < previous:
		day += 1
	_apply_world_time(false)

func _apply_world_time(force: bool) -> void:
	if world_ambient:
		world_ambient.color = _ambient_color_for_hour(world_hour)
	var pressure := _night_pressure()
	if force or absf(pressure - last_enemy_night_pressure) >= 0.025:
		last_enemy_night_pressure = pressure
		for hostile in get_tree().get_nodes_in_group("hostile"):
			if is_instance_valid(hostile) and hostile.has_method("set_time_difficulty"):
				hostile.call("set_time_difficulty", pressure)

func _night_pressure() -> float:
	if world_hour >= 21.0 or world_hour < 5.0:
		return 1.0
	if world_hour >= 19.0:
		return clampf((world_hour - 19.0) / 2.0, 0.0, 1.0)
	if world_hour >= 5.0 and world_hour < 7.0:
		return clampf((7.0 - world_hour) / 2.0, 0.0, 1.0)
	return 0.0

func _time_of_day_name() -> String:
	if world_hour < 5.0 or world_hour >= 21.0:
		return "NOITE"
	if world_hour < 7.0:
		return "AMANHECER"
	if world_hour < 11.0:
		return "MANHÃ"
	if world_hour < 17.0:
		return "DIA"
	if world_hour < 19.0:
		return "ENTARDECER"
	return "ANOITECER"

func _format_world_time() -> String:
	var hour := int(floor(world_hour))
	var minute := int(floor((world_hour - float(hour)) * 60.0))
	return "%02d:%02d" % [hour, minute]

func _ambient_color_for_hour(hour: float) -> Color:
	var hours: Array[float] = [0.0, 5.0, 7.0, 10.0, 16.0, 18.0, 20.0, 22.0, 24.0]
	var colors: Array[Color] = [
		Color("6876a8"), Color("8996bc"), Color("d7d8c4"), Color("fff5dc"),
		Color("fff2d8"), Color("efb68f"), Color("8f7196"), Color("58658c"), Color("6876a8")
	]
	for index in range(hours.size() - 1):
		if hour <= float(hours[index + 1]):
			var span := float(hours[index + 1]) - float(hours[index])
			var blend := inverse_lerp(float(hours[index]), float(hours[index + 1]), hour) if span > 0.0 else 0.0
			return colors[index].lerp(colors[index + 1], blend)
	return colors[0]

func _show_message(text: String, seconds: float = 2.5) -> void:
	message_timer = seconds
	if hud and is_instance_valid(hud):
		hud.set_message(text)

func _show_pause() -> void:
	paused = true
	inventory_open = false
	skill_tree_open = false
	get_tree().paused = true
	_clear_ui()
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.035, 0.08, 0.76)
	ui_root.add_child(shade)
	var title := _label("PAUSADO", 34, Color("e6fff1"), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(90, 76)
	title.size = Vector2(460, 52)
	ui_root.add_child(title)
	var buttons := VBoxContainer.new()
	buttons.position = Vector2(230, 128)
	buttons.size = Vector2(180, 202)
	buttons.add_theme_constant_override("separation", 8)
	ui_root.add_child(buttons)
	var resume := _button("CONTINUAR")
	resume.pressed.connect(_resume_game)
	buttons.add_child(resume)
	var bag := _button("INVENTÁRIO")
	bag.pressed.connect(func(): _open_inventory(true))
	buttons.add_child(bag)
	var talents := _button("ÁRVORE DE TALENTOS")
	talents.pressed.connect(func(): _open_skill_tree(true))
	buttons.add_child(talents)
	var restart := _button("VOLTAR AO SANTUÁRIO")
	restart.pressed.connect(func():
		get_tree().paused = false
		paused = false
		player.health = player.max_health
		player.magic = player.max_magic
		_place_at_shrine()
		_show_hud()
		if not _save_campaign():
			_show_message("Não foi possível salvar o progresso no disco.", 3.0)
	)
	buttons.add_child(restart)
	var keys := _button("CONTROLES")
	var rune_button := _button("RUNAS")
	rune_button.pressed.connect(func(): _open_rune_menu(false))
	buttons.add_child(rune_button)
	keys.pressed.connect(func(): _open_controls_menu(_show_pause))
	buttons.add_child(keys)
	var menu := _button("MENU PRINCIPAL")
	menu.pressed.connect(_show_title)
	buttons.add_child(menu)

func _resume_game() -> void:
	paused = false
	inventory_open = false
	skill_tree_open = false
	get_tree().paused = false
	_show_hud()

func _open_inventory(return_to_pause: bool) -> void:
	if not playing or not player:
		return
	inventory_returns_to_pause = return_to_pause
	inventory_open = true
	paused = true
	get_tree().paused = true
	_show_inventory()

func _close_inventory() -> void:
	if not inventory_open:
		return
	inventory_open = false
	if inventory_returns_to_pause:
		_show_pause()
	else:
		_resume_game()

func _show_inventory(status_text: String = "") -> void:
	_clear_ui()
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.045, 0.09, 0.91)
	ui_root.add_child(shade)
	var title := _label("BOLSA DE ORION", 30, Color("e7fff6"), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(100, 28)
	title.size = Vector2(440, 42)
	ui_root.add_child(title)
	var status := status_text if not status_text.is_empty() else "Consumíveis: escolha um item para recuperar vida ou magia."
	var subtitle := _label(status, 13, Color("b8d8d4"), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.position = Vector2(100, 70)
	subtitle.size = Vector2(440, 28)
	ui_root.add_child(subtitle)
	var focus_target: Control
	for item_index in range(ITEM_CATALOG.item_ids().size()):
		var item_id: String = ITEM_CATALOG.item_ids()[item_index]
		var definition := ITEM_CATALOG.get_definition(item_id)
		var row := PanelContainer.new()
		row.position = Vector2(108, 108.0 + item_index * 70.0)
		row.size = Vector2(424, 60)
		var row_style := StyleBoxFlat.new()
		row_style.bg_color = Color(0.08, 0.15, 0.22, 0.96)
		row_style.border_color = Color("4f8990")
		row_style.set_border_width_all(1)
		row_style.set_corner_radius_all(4)
		row_style.content_margin_left = 8
		row_style.content_margin_right = 8
		row_style.content_margin_top = 4
		row_style.content_margin_bottom = 4
		row.add_theme_stylebox_override("panel", row_style)
		ui_root.add_child(row)
		var contents := HBoxContainer.new()
		contents.add_theme_constant_override("separation", 8)
		row.add_child(contents)
		var icon := _label("✦", 20, Color(str(definition["color"])), HORIZONTAL_ALIGNMENT_CENTER)
		icon.custom_minimum_size = Vector2(28, 32)
		contents.add_child(icon)
		var details := VBoxContainer.new()
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		details.add_theme_constant_override("separation", 0)
		contents.add_child(details)
		var item_name := _label(str(definition["name"]), 14, Color("e5fff3"))
		details.add_child(item_name)
		var item_description := _label(str(definition["description"]), 11, Color("aec9c8"))
		details.add_child(item_description)
		var count := int(player.inventory.get(item_id, 0))
		var count_label := _label("× %d" % count, 13, Color("f1e5b8"), HORIZONTAL_ALIGNMENT_CENTER)
		count_label.custom_minimum_size = Vector2(42, 30)
		contents.add_child(count_label)
		var use_button := _button("USAR")
		use_button.custom_minimum_size = Vector2(78, 32)
		use_button.size = Vector2(78, 32)
		use_button.disabled = not player.can_use_item(item_id)
		use_button.pressed.connect(_use_inventory_item.bind(item_id))
		contents.add_child(use_button)
		if focus_target == null and not use_button.disabled:
			focus_target = use_button
	var back := _button("VOLTAR")
	back.position = Vector2(232, 268)
	back.size = Vector2(176, 34)
	back.pressed.connect(_close_inventory)
	ui_root.add_child(back)
	if focus_target:
		focus_target.grab_focus()
	else:
		back.grab_focus()

func _open_skill_tree(return_to_pause: bool) -> void:
	if not playing or not player:
		return
	skill_tree_returns_to_pause = return_to_pause
	skill_tree_open = true
	paused = true
	get_tree().paused = true
	_show_skill_tree()

func _close_skill_tree() -> void:
	if not skill_tree_open:
		return
	skill_tree_open = false
	if skill_tree_returns_to_pause:
		_show_pause()
	else:
		_resume_game()

func _show_skill_tree(status_text: String = "") -> void:
	_clear_ui()
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.018, 0.04, 0.09, 0.92)
	ui_root.add_child(shade)
	var title := _label("ÁRVORE DE TALENTOS", 28, Color("e7fff6"), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(70, 24)
	title.size = Vector2(500, 40)
	ui_root.add_child(title)
	var subtitle_text := status_text
	if subtitle_text.is_empty():
		subtitle_text = "Pontos: %d · ganhe pontos ao subir de nível e vencer chefes." % player.skill_points
	var subtitle := _label(subtitle_text, 12, Color("b8d8d4"), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.position = Vector2(62, 64)
	subtitle.size = Vector2(516, 24)
	ui_root.add_child(subtitle)
	var focus_target: Control
	var skill_ids: Array = SKILL_CATALOG.skill_ids()
	for index in range(skill_ids.size()):
		var skill_id: String = str(skill_ids[index])
		var definition := SKILL_CATALOG.get_definition(skill_id)
		var card := PanelContainer.new()
		var branch_column := 0 if definition["branch"] == "Combate" else 1
		var branch_row := 0 if definition.get("prerequisites", []).is_empty() else 1
		card.position = Vector2(52.0 + branch_column * 272.0, 96.0 + branch_row * 94.0)
		card.size = Vector2(260, 86)
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color(0.075, 0.14, 0.2, 0.97)
		card_style.border_color = Color("4f8990")
		card_style.set_border_width_all(1)
		card_style.set_corner_radius_all(4)
		card_style.content_margin_left = 7
		card_style.content_margin_right = 7
		card_style.content_margin_top = 4
		card_style.content_margin_bottom = 4
		card.add_theme_stylebox_override("panel", card_style)
		ui_root.add_child(card)
		var content := VBoxContainer.new()
		content.add_theme_constant_override("separation", 1)
		card.add_child(content)
		var skill_name := _label("%s · %s" % [definition["branch"], definition["name"]], 12, Color("e5fff3"))
		content.add_child(skill_name)
		var description := _label(str(definition["description"]), 10, Color("aec9c8"))
		content.add_child(description)
		var prerequisites: Array = definition.get("prerequisites", [])
		var is_unlocked := player.has_skill(skill_id)
		var can_unlock := player.can_unlock_skill(skill_id)
		var button_text := "APRENDIDA"
		if not is_unlocked:
			button_text = "APRENDER · %d PT" % int(definition["cost"])
		if not is_unlocked and not prerequisites.is_empty() and not can_unlock:
			button_text = "PRÉ-REQUISITO PENDENTE"
		elif not is_unlocked and player.skill_points < int(definition["cost"]):
			button_text = "FALTA PONTO DE TALENTO"
		var learn_button := _button(button_text)
		learn_button.custom_minimum_size = Vector2(242, 28)
		learn_button.size = Vector2(242, 28)
		learn_button.add_theme_font_size_override("font_size", 10)
		learn_button.disabled = not can_unlock
		learn_button.pressed.connect(_purchase_skill.bind(skill_id))
		content.add_child(learn_button)
		if focus_target == null and can_unlock:
			focus_target = learn_button
	var back := _button("VOLTAR")
	back.position = Vector2(232, 292)
	back.size = Vector2(176, 34)
	back.pressed.connect(_close_skill_tree)
	ui_root.add_child(back)
	if focus_target:
		focus_target.grab_focus()
	else:
		back.grab_focus()

func _purchase_skill(skill_id: String) -> void:
	if not player or not is_instance_valid(player) or not player.purchase_skill(skill_id):
		_show_skill_tree("Pré-requisito ou ponto de talento insuficiente.")
		return
	var definition := SKILL_CATALOG.get_definition(skill_id)
	var saved := _save_campaign()
	var status := "%s aprendido." % definition.get("name", "Talento")
	if not saved:
		status += " Não foi possível salvar."
	_show_skill_tree(status)

func _use_inventory_item(item_id: String) -> void:
	if not player or not is_instance_valid(player) or not player.use_item(item_id):
		_show_inventory("Kaê só pode usar o item quando precisar dele.")
		return
	var definition := ITEM_CATALOG.get_definition(item_id)
	var saved := _save_campaign()
	var status := "%s usado." % definition.get("name", "Item")
	if not saved:
		status += " Não foi possível salvar o uso."
	_show_inventory(status)

func _show_ending() -> void:
	playing = false
	get_tree().paused = false
	_clear_ui()
	var backdrop := TextureRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.texture = TREE_ART
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	ui_root.add_child(backdrop)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.05, 0.1, 0.52)
	ui_root.add_child(shade)
	var title := _label("DUAS ALMAS, UMA FLORESTA", 30, Color("ecfff2"), HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(40, 20)
	title.size = Vector2(560, 48)
	ui_root.add_child(title)
	var orion_portrait := TextureRect.new()
	orion_portrait.texture = ORION_IDLE_TEXTURE
	orion_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	orion_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	orion_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	orion_portrait.position = Vector2(150, 66)
	orion_portrait.size = Vector2(150, 156)
	orion_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(orion_portrait)
	var aenia_portrait := TextureRect.new()
	aenia_portrait.texture = AENIA_IDLE_TEXTURE
	aenia_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	aenia_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	aenia_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	aenia_portrait.position = Vector2(340, 66)
	aenia_portrait.size = Vector2(150, 156)
	aenia_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.add_child(aenia_portrait)
	var story := _label("Kaê e Aená reuniram suas forças. A Árvore Mãe voltou a brilhar, e a floresta respirou em paz.", 16, Color("e6eee7"), HORIZONTAL_ALIGNMENT_CENTER)
	story.position = Vector2(62, 228)
	story.size = Vector2(516, 50)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_root.add_child(story)
	var button := _button("VOLTAR AO INÍCIO")
	button.position = Vector2(228, 300)
	button.size = Vector2(184, 38)
	button.pressed.connect(_show_title)
	ui_root.add_child(button)

func _show_pause_again() -> void:
	paused = true
	get_tree().paused = true

func _label(text: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(176, 34)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color("e4fff3"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("9bf6df"))
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("1f4151") if state == "normal" else Color("2b6470")
		style.border_color = Color("72d8c8")
		style.set_border_width_all(1)
		style.set_corner_radius_all(3)
		style.content_margin_left = 9
		style.content_margin_right = 9
		style.content_margin_top = 3
		style.content_margin_bottom = 3
		button.add_theme_stylebox_override(state, style)
	return button

func _clear_ui() -> void:
	for child in ui_root.get_children():
		ui_root.remove_child(child)
		child.queue_free()
	hud = null
