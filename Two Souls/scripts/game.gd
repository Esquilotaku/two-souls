extends Node2D
## Fluxo do jogo: título, mundo interligado em salas, santuários, save, HUD e menus.
## O mapa e as salas vêm de WorldMap e WorldRoom (docs/plano-tecnico-mundo.md).

const DAY_CYCLE_REAL_SECONDS := 900.0
const DOOR_COOLDOWN := 0.35
const FADE_SECONDS := 0.12
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
var fade_rect: ColorRect
var world: WorldRoom
var player: Orion
var aenia_companion: Node2D
var room_id := ""
var shrine_room := ""
var visited_rooms: Dictionary = {}
var activated_shrines: Dictionary = {}
var abilities: Dictionary = {}
var defeated_bosses: Dictionary = {}
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
var door_cooldown := 0.0
var transitioning := false
var hud_health: Label
var hud_magic: Label
var hud_progress: Label
var hud_stage: Label
var hud_objective: Label
var hud_message: Label
var hud_inventory_button: Button
var world_hour := 7.0
var world_ambient: CanvasModulate
var last_enemy_night_pressure := -1.0
var hud_time: Label

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
	if not playing or paused or transitioning:
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
	if message_timer <= 0.0 and hud_message:
		hud_message.text = ""
	door_cooldown = maxf(0.0, door_cooldown - delta)
	_update_aenia_companion(delta)
	if player.health <= 0:
		respawn_timer += delta
		if respawn_timer >= 1.0:
			_respawn_player()
		return
	_check_altar()
	_check_doors()
	_update_hud()

func _create_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	ui_layer.add_child(ui_root)
	# Camada própria para escurecer a tela na troca de sala, acima dos menus.
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 10
	fade_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade_rect)

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
	title.position = Vector2(70, 44)
	title.size = Vector2(500, 66)
	title.add_theme_color_override("font_shadow_color", Color("1d8c9e"))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 4)
	ui_root.add_child(title)
	var subtitle := _label("A JORNADA DE ORION", 16, Color("b8e9e1"), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.position = Vector2(70, 105)
	subtitle.size = Vector2(500, 30)
	ui_root.add_child(subtitle)
	var rule := ColorRect.new()
	rule.color = Color("6edcca")
	rule.position = Vector2(238, 143)
	rule.size = Vector2(164, 2)
	ui_root.add_child(rule)
	var story := _label("Quando o feiticeiro levou Aenia, a floresta perdeu sua luz.\nOrion segue o rastro até o coração de Monte Ligna.", 16, Color("e2e0d4"), HORIZONTAL_ALIGNMENT_CENTER)
	story.position = Vector2(90, 158)
	story.size = Vector2(460, 52)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_root.add_child(story)
	var buttons := VBoxContainer.new()
	var has_save := SAVE_MANAGER.has_save()
	buttons.position = Vector2(224, 204 if has_save else 220)
	buttons.size = Vector2(192, 126 if has_save else 110)
	buttons.add_theme_constant_override("separation", 8)
	ui_root.add_child(buttons)
	if has_save:
		var continue_button := _button("CONTINUAR")
		continue_button.pressed.connect(_continue_game)
		buttons.add_child(continue_button)
	var start := _button("NOVA JORNADA" if has_save else "INICIAR JORNADA")
	start.pressed.connect(_request_new_game)
	buttons.add_child(start)
	var how := _button("COMO JOGAR")
	how.pressed.connect(_show_controls)
	buttons.add_child(how)
	var keys := _button("CONTROLES")
	keys.pressed.connect(func(): _open_controls_menu(_show_title))
	buttons.add_child(keys)
	var footer := _label("Setas andam  ·  %s pula  ·  %s ataca  ·  %s dash  ·  %s interage" % [_key_name("jump"), _key_name("attack"), _key_name("dash"), _key_name("interact")], 11, Color("bed2d6"), HORIZONTAL_ALIGNMENT_CENTER)
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
	var help := "Ande com as setas; %s pula.\n%s ataca; %s dash; %s magia.\n%s lança e %s super soco, depois de ganhá-los.\n%s ativa santuários e fala com Aenia.\nBlocos laranja pedem uma habilidade.\n%s bolsa; %s talentos; %s pausa." % [
		_key_name("jump"), _key_name("attack"), _key_name("dash"), _key_name("magic"),
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
	_begin_play()
	_enter_room(WorldMap.START_ROOM, "")
	_apply_world_time(true)
	_show_hud()
	if _save_campaign():
		_show_message("Monte Ligna · siga as luzes entre as raízes", 3.2)
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
	if shrine_room != "" and WorldMap.has_room(shrine_room):
		_enter_room(shrine_room, "", true)
	else:
		_enter_room(WorldMap.START_ROOM, "")
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
	transitioning = false
	fade_rect.color.a = 0.0
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

# --- Salas ---

## Troca a sala atual. Com door_id vazio, o jogador aparece no santuário (at_shrine) ou no início da sala.
func _enter_room(next_room: String, door_id: String, at_shrine: bool = false) -> void:
	if world and is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	aenia_companion = null
	room_id = next_room
	visited_rooms[room_id] = true
	world = WorldRoom.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	move_child(world, 1)
	world.build(room_id, abilities, defeated_bosses, activated_shrines, player.has_collected_pickup)
	var arrival := world.spawn_point()
	if door_id != "":
		arrival = world.arrival_point(door_id)
	elif at_shrine:
		arrival = world.shrine_point()
	player.global_position = arrival
	player.velocity = Vector2.ZERO
	player.active = true
	respawn_timer = 0.0
	player.fall_limit_y = world.size_px.y + 120.0
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(world.size_px.x)
	camera.limit_bottom = int(world.size_px.y)
	camera.reset_smoothing()
	if world.boss:
		_start_boss(world.boss)
	if rock_recruited:
		_add_rock_companion()
	if player.twin_magic:
		_add_aenia_companion()
	_apply_world_time(true)
	door_cooldown = DOOR_COOLDOWN
	_update_hud()

func _check_doors() -> void:
	if door_cooldown > 0.0:
		return
	for trigger in world.door_triggers:
		if (trigger["rect"] as Rect2).has_point(player.global_position):
			var entry: Dictionary = trigger["door"]
			if entry.has("gate") and not abilities.has(entry["gate"]):
				continue
			_go_through_door(entry["to"], entry["to_door"])
			return

func _go_through_door(next_room: String, door_id: String) -> void:
	transitioning = true
	player.active = false
	var keep_velocity_x := player.velocity.x
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, FADE_SECONDS)
	await tween.finished
	_enter_room(next_room, door_id)
	player.velocity.x = keep_velocity_x
	var back := create_tween()
	back.tween_property(fade_rect, "color:a", 0.0, FADE_SECONDS)
	await back.finished
	transitioning = false

func _check_altar() -> void:
	if world.altar_rect.size == Vector2.ZERO or not world.altar_rect.has_point(player.global_position):
		return
	var ability: String = world.data["grants"]
	world.altar_rect = Rect2()
	var altar := world.get_node_or_null("Altar")
	if altar:
		altar.queue_free()
	_grant_ability(ability)

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

# --- Santuários ---

func _try_shrine() -> bool:
	var shrine := world.shrine
	if not shrine or not shrine.is_player_near(player.global_position):
		return false
	if not shrine.active:
		shrine.active = true
		activated_shrines[room_id] = true
		shrine_room = room_id
		player.restore(99)
		_show_message("Santuário ativado · campanha salva" if _save_campaign() else "Santuário ativado, mas a gravação falhou.", 3.0)
	else:
		# Descansar: salva, enche vida e magia e faz os inimigos voltarem (a sala é montada de novo).
		shrine_room = room_id
		player.restore(99)
		var saved := _save_campaign()
		_enter_room(room_id, "", true)
		_show_message("Você descansou · os inimigos voltaram" if saved else "Você descansou, mas a gravação falhou.", 3.0)
	return true

func _respawn_player() -> void:
	respawn_timer = -999.0
	player.health = player.max_health
	player.magic = player.max_magic
	player.hurt_timer = 1.4
	if shrine_room != "" and WorldMap.has_room(shrine_room):
		_enter_room(shrine_room, "", true)
	else:
		_enter_room(WorldMap.START_ROOM, "")
	player.health_changed.emit(player.health)
	_show_message("Orion desperta no último santuário", 2.6)

func _on_player_defeated() -> void:
	respawn_timer = 0.01

# --- Chefes ---

func _start_boss(fighter: Node2D) -> void:
	var boss_key: String = fighter.get_meta("boss_key")
	var info: Dictionary = WorldMap.BOSSES[boss_key]
	fighter.defeated.connect(_on_boss_defeated.bind(boss_key))
	if info.has("hour"):
		world_hour = fposmod(float(info["hour"]), 24.0)
		_apply_world_time(true)
	_show_message(info["name"] + " bloqueia a passagem!", 3.0)

func _on_boss_defeated(boss_key: String) -> void:
	defeated_bosses[boss_key] = true
	player.restore(2)
	player.grant_skill_point()
	if boss_key == "the_rock":
		rock_recruited = true
	if boss_key == "corrupted_tree":
		player.unlock_twin_magic()
		player.restore(5)
		_add_aenia_companion()
	if world.data.has("grants"):
		_grant_ability(world.data["grants"])
	var saved := _save_campaign()
	if world.data.get("final", false):
		_show_ending()
		return
	if boss_key == "the_rock":
		_show_message("D Rock virou aliado. +1 ponto de talento." if saved else "D Rock virou aliado, mas não foi possível salvar o progresso.", 4.0)
	elif boss_key == "corrupted_tree":
		_show_message("Aenia está livre! Pressione E para conversar." if saved else "Aenia está livre, mas não foi possível salvar o progresso.", 4.0)

func _add_rock_companion() -> void:
	var companion := CorruptedBoss.new()
	companion.boss_id = "the_rock"
	companion.boss_name = "D Rock"
	companion.is_ally = true
	companion.floor_y = world.floor_y()
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
	var speaker := _label("AENIA", 15, Color("9ef5dc"))
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
		"unlocked_skills": player.get_unlocked_skill_ids()
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

# --- HUD ---

func _show_hud() -> void:
	_clear_ui()
	var hud_panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.03, 0.07, 0.13, 0.82)
	panel_style.border_color = Color(0.39, 0.81, 0.78, 0.62)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 12
	panel_style.content_margin_right = 12
	panel_style.content_margin_top = 7
	panel_style.content_margin_bottom = 7
	hud_panel.add_theme_stylebox_override("panel", panel_style)
	hud_panel.position = Vector2(12, 10)
	hud_panel.size = Vector2(260, 94)
	ui_root.add_child(hud_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	hud_panel.add_child(vbox)
	hud_stage = _label("", 14, Color("e4fff2"))
	vbox.add_child(hud_stage)
	var status := HBoxContainer.new()
	status.add_theme_constant_override("separation", 16)
	vbox.add_child(status)
	hud_health = _label("", 13, Color("ffb4a8"))
	status.add_child(hud_health)
	hud_magic = _label("", 13, Color("94eee5"))
	status.add_child(hud_magic)
	hud_progress = _label("", 11, Color("b7d6d9"))
	vbox.add_child(hud_progress)
	hud_time = _label("", 10, Color("f2d8a0"))
	vbox.add_child(hud_time)
	hud_objective = _label("", 11, Color("ffe2a0"))
	hud_objective.position = Vector2(330, 17)
	hud_objective.size = Vector2(250, 24)
	hud_objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ui_root.add_child(hud_objective)
	hud_message = _label("", 16, Color("ecfff7"), HORIZONTAL_ALIGNMENT_CENTER)
	hud_message.position = Vector2(40, 292)
	hud_message.size = Vector2(560, 36)
	hud_message.add_theme_color_override("font_shadow_color", Color(0.02, 0.04, 0.08, 0.85))
	hud_message.add_theme_constant_override("shadow_offset_x", 1)
	hud_message.add_theme_constant_override("shadow_offset_y", 2)
	ui_root.add_child(hud_message)
	var pause_button := _button("Ⅱ")
	pause_button.position = Vector2(588, 8)
	pause_button.size = Vector2(40, 32)
	pause_button.pressed.connect(_show_pause)
	ui_root.add_child(pause_button)
	hud_inventory_button = _button("BOLSA [I]")
	hud_inventory_button.position = Vector2(474, 44)
	hud_inventory_button.size = Vector2(106, 32)
	hud_inventory_button.custom_minimum_size = Vector2(106, 32)
	hud_inventory_button.add_theme_font_size_override("font_size", 11)
	hud_inventory_button.pressed.connect(func(): _open_inventory(false))
	ui_root.add_child(hud_inventory_button)
	_update_hud()

func _update_hud() -> void:
	if not hud_health or not player:
		return
	hud_health.text = "VIDA  " + "♥".repeat(player.health) + "·".repeat(player.max_health - player.health)
	hud_magic.text = "MAGIA  " + "✦".repeat(player.magic) + "·".repeat(player.max_magic - player.magic)
	if hud_progress:
		hud_progress.text = "NÍVEL %02d · XP %d/%d · TALENTOS %d" % [player.level, player.experience, player.experience_to_next, player.skill_points]
	if hud_stage and room_id != "":
		var region_label := WorldMap.region_name(room_id)
		var room_label: String = WorldMap.room(room_id).get("name", "")
		hud_stage.text = room_label if room_label == region_label else "%s · %s" % [region_label, room_label]
	if hud_objective:
		var objective := ""
		if world and is_instance_valid(world) and world.boss and is_instance_valid(world.boss):
			objective = "DERROTE: " + str(world.boss.boss_name).to_upper()
		elif world and is_instance_valid(world) and world.shrine and not world.shrine.active and world.shrine.is_player_near(player.global_position):
			objective = "%s · ATIVAR SANTUÁRIO" % _key_name("interact")
		elif world and is_instance_valid(world) and world.shrine and world.shrine.is_player_near(player.global_position):
			objective = "%s · DESCANSAR" % _key_name("interact")
		hud_objective.text = objective
	if hud_time:
		hud_time.text = "DIA %d · %s  ·  %s" % [day, _time_of_day_name(), _format_world_time()]
	if hud_inventory_button:
		var item_total := 0
		for item_id in ITEM_CATALOG.item_ids():
			item_total += int(player.inventory.get(item_id, 0))
		hud_inventory_button.text = "BOLSA [I]  %d" % item_total

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
	if hud_time:
		hud_time.text = "DIA %d · %s  ·  %s" % [day, _time_of_day_name(), _format_world_time()]

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
	if not hud_message:
		return
	hud_message.text = text
	message_timer = seconds

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
		if shrine_room != "" and WorldMap.has_room(shrine_room):
			_enter_room(shrine_room, "", true)
		else:
			_enter_room(WorldMap.START_ROOM, "")
		_show_hud()
		if not _save_campaign():
			_show_message("Não foi possível salvar o progresso no disco.", 3.0)
	)
	buttons.add_child(restart)
	var keys := _button("CONTROLES")
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
		_show_inventory("Orion só pode usar o item quando precisar dele.")
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
	var story := _label("Orion e Aenia reuniram suas forças. A Árvore Mãe voltou a brilhar, e Monte Ligna respirou em paz.", 16, Color("e6eee7"), HORIZONTAL_ALIGNMENT_CENTER)
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
	hud_health = null
	hud_magic = null
	hud_progress = null
	hud_stage = null
	hud_objective = null
	hud_message = null
	hud_inventory_button = null
	hud_time = null
