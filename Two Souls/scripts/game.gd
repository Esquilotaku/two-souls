extends Node2D
## Main flow for the first playable production build.

const LEVEL_WIDTH := 2700.0
const FLOOR_Y := 304.0
const DAY_CYCLE_REAL_SECONDS := 900.0
const TREE_ART = preload("res://assets/mother_tree_forest.png")
const ORION_IDLE_TEXTURE = preload("res://assets/sprites/orion_idle.png")
const AENIA_IDLE_TEXTURE = preload("res://assets/sprites/aenia_idle.png")
const SAVE_MANAGER = preload("res://scripts/save_manager.gd")
const CORRUPTION_BARRIER_SCRIPT = preload("res://scripts/corruption_barrier.gd")
const ITEM_PICKUP_SCRIPT = preload("res://scripts/item_pickup.gd")
const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const SKILL_CATALOG = preload("res://scripts/skill_catalog.gd")

const STAGES := [
	{"title":"Trilha da Raiz", "sub":"O guardião testa quem entra na floresta", "ground":"18363c", "grass":"6bc184", "glow":"72e6d0", "boss":"The Rock", "boss_id":"the_rock", "boss_hour":10.0, "boss_tier":"major"},
	{"title":"Bosque das Lanternas", "sub":"Luzes perdidas entre as copas", "ground":"263849", "grass":"81bd76", "glow":"f5cb74", "boss":""},
	{"title":"Ruínas Afogadas", "sub":"Raízes corrompidas fecham o caminho", "ground":"29343e", "grass":"67a99a", "glow":"64d4df", "boss":"Árvore Corrompida", "boss_id":"corrupted_tree", "boss_hour":18.0, "boss_tier":"major"},
	{"title":"Garganta das Brumas", "sub":"A trilha desaparece na névoa", "ground":"263346", "grass":"8a9db5", "glow":"b5d9f3", "boss":""},
	{"title":"Jardim de Vidro", "sub":"Espinhos cantam ao vento", "ground":"3b3042", "grass":"ba8c76", "glow":"f8b76e", "boss":""},
	{"title":"Pântano das Cinzas", "sub":"A sentinela guarda a passagem", "ground":"34343a", "grass":"a28a62", "glow":"cfa06b", "boss":"Serpe do Brejo", "boss_id":"swamp_guardian", "boss_tier":"sub_boss"},
	{"title":"Coração Corrompido", "sub":"A magia dos gêmeos volta a brilhar", "ground":"392c41", "grass":"a973a0", "glow":"cf96ff", "boss":""},
	{"title":"Árvore Mãe", "sub":"A última noite de Monte Ligna", "ground":"202438", "grass":"795fc0", "glow":"80f6e9", "boss":"Feiticeiro Encapuzado", "boss_id":"hooded_sorcerer", "boss_hour":22.0, "boss_tier":"major"}
]

const PLATFORM_LAYOUTS := [
	[[250, 250, 96], [478, 215, 88], [790, 255, 128], [1030, 224, 88], [1365, 246, 104], [1640, 208, 94], [1910, 250, 112]],
	[[225, 242, 104], [450, 205, 92], [715, 234, 130], [970, 195, 110], [1240, 246, 94], [1510, 206, 120], [1855, 222, 100]],
	[[245, 242, 112], [490, 205, 100], [755, 233, 96], [1000, 198, 128], [1330, 228, 102], [1620, 194, 105], [1870, 236, 115]],
	[[210, 242, 96], [465, 215, 120], [775, 192, 90], [1020, 233, 114], [1340, 205, 100], [1590, 240, 125], [1870, 198, 96]],
	[[248, 230, 102], [500, 193, 104], [750, 234, 120], [1010, 193, 86], [1290, 221, 100], [1560, 194, 108], [1880, 228, 112]],
	[[230, 245, 116], [490, 210, 90], [745, 239, 122], [1030, 199, 100], [1320, 235, 104], [1610, 193, 110], [1890, 226, 120]],
	[[215, 233, 100], [470, 197, 112], [760, 228, 94], [1020, 194, 108], [1300, 232, 116], [1580, 199, 92], [1880, 225, 120]],
	[[235, 235, 112], [500, 197, 94], [770, 226, 120], [1040, 188, 96], [1320, 220, 112], [1600, 190, 118], [1910, 229, 110]]
]

var ui_layer: CanvasLayer
var ui_root: Control
var world: Node2D
var player: Orion
var aenia_companion: Node2D
var stage_index := 0
var checkpoint_x := 72.0
var checkpoint_marker := 0
var boss_spawned := false
var boss_defeated := false
var current_boss_id := ""
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
var hud_health: Label
var hud_magic: Label
var hud_progress: Label
var hud_stage: Label
var hud_objective: Label
var hud_message: Label
var hud_inventory_button: Button
var glow_lights: Array[PointLight2D] = []
var light_origins: Array[Vector2] = []
var stage_start_time := 0.0
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
	if Input.is_action_just_pressed("interact") and playing and not paused and player and is_instance_valid(player) and player.health > 0 and aenia_companion and is_instance_valid(aenia_companion) and player.global_position.distance_to(aenia_companion.global_position) <= 88.0:
		_open_aenia_dialogue()
		return
	if not playing or paused:
		return
	_advance_world_time(delta)
	message_timer = maxf(0.0, message_timer - delta)
	if message_timer <= 0.0 and hud_message:
		hud_message.text = ""
	if player and is_instance_valid(player):
		_update_aenia_companion(delta)
		for i in range(glow_lights.size()):
			var light := glow_lights[i]
			light.position.y = light_origins[i].y + sin(Time.get_ticks_msec() * 0.0017 + i * 2.1) * 5.0
			light.energy = 0.9 + sin(Time.get_ticks_msec() * 0.0024 + i) * 0.18
		if player.health <= 0:
			respawn_timer += delta
			if respawn_timer >= 1.0:
				_respawn_player()
		_check_checkpoints()
		_check_boss_trigger()
		if player.global_position.x >= LEVEL_WIDTH - 88.0 and (STAGES[stage_index].boss == "" or boss_defeated):
			_clear_stage()
		_update_hud()

func _create_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	ui_layer.add_child(ui_root)

func _configure_controls() -> void:
	_bind_keys("move_left", [KEY_A, KEY_LEFT])
	_bind_keys("move_right", [KEY_D, KEY_RIGHT])
	_bind_keys("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_bind_keys("attack", [KEY_J, KEY_X])
	_bind_keys("magic", [KEY_K, KEY_C])
	_bind_keys("throw_spear", [KEY_L])
	_bind_keys("super_punch", [KEY_U])
	_bind_keys("inventory", [KEY_I])
	_bind_keys("skill_tree", [KEY_T])
	_bind_keys("interact", [KEY_E])
	_bind_keys("pause", [KEY_ESCAPE])

func _bind_keys(action: String, keys: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var event := InputEventKey.new()
		event.keycode = key
		InputMap.action_add_event(action, event)
	var joy_axis := InputEventJoypadMotion.new()
	if action == "move_left":
		joy_axis.axis = JOY_AXIS_LEFT_X
		joy_axis.axis_value = -1.0
		InputMap.action_add_event(action, joy_axis)
	elif action == "move_right":
		joy_axis.axis = JOY_AXIS_LEFT_X
		joy_axis.axis_value = 1.0
		InputMap.action_add_event(action, joy_axis)

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
	var footer := _label("A / D ou setas  ·  Espaço pula  ·  J ataca  ·  K magia", 11, Color("bed2d6"), HORIZONTAL_ALIGNMENT_CENTER)
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
	var text := _label("Mova Orion com A/D ou as setas.\nPule com Espaço, W ou seta para cima.\nAtaque com J/X; magia com K/C.\nLança L e super soco U após aprendê-los.\nE conversa com Aenia após o resgate.\nI abre a bolsa; T abre talentos; Esc pausa.\nRecolha essência, itens e pontos de talento.", 14, Color("d8e9e4"), HORIZONTAL_ALIGNMENT_CENTER)
	text.position = Vector2(100, 112)
	text.size = Vector2(440, 172)
	ui_root.add_child(text)
	var back := _button("VOLTAR")
	back.position = Vector2(232, 292)
	back.size = Vector2(176, 34)
	back.pressed.connect(_show_title)
	ui_root.add_child(back)

func _start_new_game() -> void:
	stage_index = 0
	rock_recruited = false
	world_hour = 7.0
	last_enemy_night_pressure = -1.0
	checkpoint_x = 72.0
	checkpoint_marker = 0
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
	_build_stage()
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
	stage_index = int(save_data["stage_index"])
	rock_recruited = bool(save_data["rock_recruited"])
	world_hour = fposmod(float(save_data.get("world_hour", 7.0)), 24.0)
	last_enemy_night_pressure = -1.0
	if player and is_instance_valid(player):
		player.queue_free()
	player = null
	playing = true
	paused = false
	get_tree().paused = false
	respawn_timer = 0.0
	_create_player()
	player.set_skill_state(int(save_data.get("skill_points", 0)), save_data.get("unlocked_skills", []))
	player.health = clampi(int(save_data["health"]), 1, player.max_health)
	player.magic = clampi(int(save_data["magic"]), 0, player.max_magic)
	player.level = maxi(1, int(save_data["level"]))
	player.experience = maxi(0, int(save_data["experience"]))
	player.experience_to_next = maxi(1, int(save_data["experience_to_next"]))
	player.twin_magic = bool(save_data["twin_magic"])
	player.set_inventory(save_data.get("inventory", {}))
	player.set_collected_pickups(save_data.get("collected_pickups", []))
	_build_stage()
	_apply_world_time(true)
	checkpoint_x = clampf(float(save_data["checkpoint_x"]), 72.0, LEVEL_WIDTH - 88.0)
	checkpoint_marker = clampi(int(save_data["checkpoint_marker"]), 0, 2)
	player.global_position = Vector2(checkpoint_x, FLOOR_Y - 33.0)
	boss_defeated = bool(save_data["boss_defeated"])
	boss_spawned = boss_defeated
	_show_hud()
	_show_message("Campanha retomada no último santuário", 3.0)

func _create_player() -> void:
	player = Orion.new()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.position = Vector2(72, FLOOR_Y - 33)
	player.health_changed.connect(_on_health_changed)
	player.leveled_up.connect(_on_level_up)
	player.defeated.connect(_on_player_defeated)
	player.inventory_changed.connect(_on_inventory_changed)
	player.item_added.connect(_on_item_added)
	player.skills_changed.connect(_on_skills_changed)
	add_child(player)

func _build_stage() -> void:
	if world and is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	aenia_companion = null
	world = Node2D.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	move_child(world, 0)
	var stage: Dictionary = STAGES[stage_index]
	boss_spawned = false
	boss_defeated = false
	current_boss_id = ""
	checkpoint_x = 72.0
	checkpoint_marker = 0
	respawn_timer = 0.0
	stage_start_time = Time.get_ticks_msec() / 1000.0
	player.position = Vector2(72, FLOOR_Y - 33)
	player.velocity = Vector2.ZERO
	player.active = true
	var palette_index := stage_index
	_add_background(stage, palette_index)
	_add_terrain(stage)
	_add_platforms(stage_index, stage)
	_add_portal(stage)
	_add_enemies(stage_index)
	_add_item_pickups(stage_index)
	if rock_recruited:
		_add_rock_companion()
	if player.twin_magic:
		_add_aenia_companion()
	_add_checkpoint_lights()
	player.get_node("Camera2D").limit_right = int(LEVEL_WIDTH)
	player.get_node("Camera2D").reset_smoothing()
	if hud_stage:
		hud_stage.text = "%02d  ·  %s" % [stage_index + 1, stage.title]
	if hud_objective:
		hud_objective.text = "" if stage.boss == "" else "DERROTE: " + stage.boss.to_upper()
	_update_hud()

func _add_background(stage: Dictionary, palette_index: int) -> void:
	var far := Parallax2D.new()
	far.scroll_scale = Vector2(0.075, 0.0)
	far.repeat_size = Vector2.ZERO
	far.z_index = -100
	world.add_child(far)
	var art := Sprite2D.new()
	art.centered = false
	art.texture = TREE_ART
	art.position = Vector2(-22, -28)
	art.scale = Vector2(0.61, 0.42)
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tints := [Color("a7c5d8"), Color("c1bfc2"), Color("a9bec4"), Color("b6c0da"), Color("d8b7a5"), Color("c8b9a4"), Color("b99fcb"), Color("98ced2")]
	art.modulate = tints[palette_index]
	far.add_child(art)
	_add_forest_layer(0, 0.15, -82, Color("273d65"), Color("678db7"))
	_add_forest_layer(1, 0.29, -62, Color("1b4056"), Color("70aeb3"))
	_add_forest_layer(2, 0.48, -42, Color("163e42"), Color("5bb39b"))
	_add_forest_layer(3, 0.78, -22, Color("152c35"), Color(stage.glow))
	var modulate := CanvasModulate.new()
	modulate.color = Color("d8edff") if stage_index < 2 else Color("bdc3e6")
	world.add_child(modulate)
	_add_glow_lights(stage)

func _add_forest_layer(index: int, scroll: float, z: int, tint: Color, accent: Color) -> void:
	var parallax := Parallax2D.new()
	parallax.scroll_scale = Vector2(scroll, 0.0)
	parallax.repeat_size = Vector2(960.0, 0.0)
	parallax.z_index = z
	world.add_child(parallax)
	var painter := ForestLayerPainter.new()
	painter.layer_index = index
	painter.tint = tint
	painter.accent = accent
	parallax.add_child(painter)

func _add_glow_lights(stage: Dictionary) -> void:
	glow_lights.clear()
	light_origins.clear()
	var texture := _make_glow_texture()
	var random := RandomNumberGenerator.new()
	random.seed = 900 + stage_index * 49
	for i in range(13):
		var light := PointLight2D.new()
		light.texture = texture
		light.color = Color(stage.glow)
		light.energy = random.randf_range(0.65, 1.0)
		light.texture_scale = random.randf_range(1.4, 2.6)
		light.position = Vector2(random.randf_range(60, LEVEL_WIDTH - 80), random.randf_range(145, 280))
		light.z_index = -10
		world.add_child(light)
		glow_lights.append(light)
		light_origins.append(light.position)

func _make_glow_texture() -> Texture2D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(64):
			var distance := Vector2(x - 31.5, y - 31.5).length() / 32.0
			var alpha := clampf(1.0 - distance, 0.0, 1.0)
			alpha = alpha * alpha * (3.0 - 2.0 * alpha)
			image.set_pixel(x, y, Color(1, 1, 1, alpha))
	return ImageTexture.create_from_image(image)

func _add_terrain(stage: Dictionary) -> void:
	var terrain := TerrainPainter.new()
	terrain.world_width = LEVEL_WIDTH
	terrain.floor_y = FLOOR_Y
	terrain.ground = Color(stage.ground)
	terrain.grass = Color(stage.grass)
	terrain.glow = Color(stage.glow)
	terrain.z_index = -5
	world.add_child(terrain)
	var floor := StaticBody2D.new()
	floor.position = Vector2(LEVEL_WIDTH * 0.5, FLOOR_Y + 80.0)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(LEVEL_WIDTH + 40.0, 160.0)
	collision.shape = shape
	floor.add_child(collision)
	world.add_child(floor)

func _add_platforms(index: int, stage: Dictionary) -> void:
	for item in PLATFORM_LAYOUTS[index]:
		_add_platform(float(item[0]), float(item[1]), float(item[2]), stage)
	# Low roots and raised paths break up long stretches of flat ground.
	_add_platform(680, FLOOR_Y - 14, 74, stage, 13)
	_add_platform(1150, FLOOR_Y - 17, 58, stage, 16)
	_add_platform(1775, FLOOR_Y - 13, 86, stage, 12)

func _add_platform(x: float, y: float, width: float, stage: Dictionary, height: float = 14.0) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(x + width * 0.5, y)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	collision.shape = shape
	body.add_child(collision)
	var color := Color(stage.ground).lightened(0.22)
	var top := Polygon2D.new()
	top.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -height * 0.5), Vector2(width * 0.5, -height * 0.5),
		Vector2(width * 0.5, height * 0.5), Vector2(-width * 0.5, height * 0.5)
	])
	top.color = color
	body.add_child(top)
	var rim := Polygon2D.new()
	rim.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -height * 0.5), Vector2(width * 0.5, -height * 0.5),
		Vector2(width * 0.5, -height * 0.5 + 3), Vector2(-width * 0.5, -height * 0.5 + 3)
	])
	rim.color = Color(stage.grass)
	body.add_child(rim)
	world.add_child(body)

func _add_portal(stage: Dictionary) -> void:
	var portal := Node2D.new()
	portal.position = Vector2(LEVEL_WIDTH - 48.0, FLOOR_Y - 25.0)
	portal.z_index = -2
	var arch := Polygon2D.new()
	arch.polygon = PackedVector2Array([
		Vector2(-27, 25), Vector2(-27, -11), Vector2(-21, -22), Vector2(-11, -29),
		Vector2(11, -29), Vector2(21, -22), Vector2(27, -11), Vector2(27, 25)
	])
	arch.color = Color(stage.glow).darkened(0.15)
	portal.add_child(arch)
	var core := Polygon2D.new()
	core.polygon = PackedVector2Array([Vector2(-19, 25), Vector2(-19, -9), Vector2(-12, -19), Vector2(0, -23), Vector2(13, -18), Vector2(19, -8), Vector2(19, 25)])
	core.color = Color("d5fff0")
	core.modulate.a = 0.7
	portal.add_child(core)
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([Vector2(-16, 22), Vector2(-16, -7), Vector2(-9, -15), Vector2(0, -18), Vector2(10, -14), Vector2(16, -5), Vector2(16, 22)])
	shadow.color = Color("284462")
	portal.add_child(shadow)
	world.add_child(portal)
	var light := PointLight2D.new()
	light.texture = _make_glow_texture()
	light.color = Color(stage.glow)
	light.energy = 1.5
	light.texture_scale = 2.0
	light.position = portal.position + Vector2(0, -6)
	world.add_child(light)

func _add_enemies(index: int) -> void:
	if index == 2:
		var barrier: StaticBody2D = CORRUPTION_BARRIER_SCRIPT.new()
		barrier.position = Vector2(640.0, FLOOR_Y - 48.0)
		barrier.process_mode = Node.PROCESS_MODE_PAUSABLE
		world.add_child(barrier)
	var positions := [410.0, 910.0, 1310.0, 1790.0, 2170.0]
	for i in range(positions.size()):
		var enemy := ForestFoe.new()
		enemy.drop_id = "stage_%02d_foe_%02d" % [index + 1, i + 1]
		enemy.position = Vector2(positions[i] + float(index % 3) * 24.0, FLOOR_Y - 10.0)
		enemy.speed = 27.0 + float((index + i) % 3) * 5.0
		enemy.patrol_span = 74.0 + float((i % 2) * 40)
		if index == 0 and (i == 1 or i == 3):
			enemy.ranged = true
			enemy.tribal = true
		enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
		world.add_child(enemy)
		enemy.set_time_difficulty(_night_pressure())
		if i == 1 or i == 3:
			var high_enemy := ForestFoe.new()
			high_enemy.drop_id = "stage_%02d_foe_%02d_upper" % [index + 1, i + 1]
			high_enemy.position = Vector2(positions[i] + 38.0, 205.0)
			high_enemy.speed = 18.0
			high_enemy.patrol_span = 50.0
			world.add_child(high_enemy)
			high_enemy.set_time_difficulty(_night_pressure())

func _add_item_pickups(index: int) -> void:
	_add_item_pickup("luminous_herb", Vector2(570.0, FLOOR_Y - 22.0), "stage_%02d_herb" % (index + 1))
	_add_item_pickup("mana_seed", Vector2(1510.0 + float(index % 2) * 90.0, FLOOR_Y - 22.0), "stage_%02d_mana" % (index + 1))

func _add_item_pickup(item_id: String, at: Vector2, pickup_id: String) -> void:
	if player.has_collected_pickup(pickup_id):
		return
	var pickup: ItemPickup = ITEM_PICKUP_SCRIPT.new()
	pickup.item_id = item_id
	pickup.pickup_id = pickup_id
	pickup.position = at
	pickup.process_mode = Node.PROCESS_MODE_PAUSABLE
	world.add_child(pickup)

func _add_rock_companion() -> void:
	var companion := CorruptedBoss.new()
	companion.boss_id = "the_rock"
	companion.boss_name = "The Rock"
	companion.is_ally = true
	companion.position = Vector2(player.position.x - 48.0, FLOOR_Y - 24.0)
	companion.process_mode = Node.PROCESS_MODE_PAUSABLE
	companion.collision_layer = 0
	companion.collision_mask = 0
	world.add_child(companion)

func _add_aenia_companion() -> void:
	var companion := Node2D.new()
	companion.name = "AeniaCompanion"
	companion.process_mode = Node.PROCESS_MODE_PAUSABLE
	companion.position = world.to_local(player.global_position) + Vector2(44.0, 0.0)
	companion.z_index = 1
	var sprite := Sprite2D.new()
	sprite.name = "AeniaSprite"
	sprite.texture = AENIA_IDLE_TEXTURE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(0.032, 0.032)
	sprite.position = Vector2(0.0, -1.0)
	companion.add_child(sprite)
	world.add_child(companion)
	aenia_companion = companion

func _update_aenia_companion(delta: float) -> void:
	if not aenia_companion or not is_instance_valid(aenia_companion) or not player or not is_instance_valid(player):
		return
	var direction := 1.0 if player.facing >= 0 else -1.0
	var target := player.global_position + Vector2(44.0 * direction, 0.0)
	aenia_companion.global_position = aenia_companion.global_position.move_toward(target, 180.0 * delta)
	var sprite := aenia_companion.get_node_or_null("AeniaSprite") as Sprite2D
	if sprite:
		sprite.flip_h = direction < 0.0
		sprite.position.y = -1.0 + sin(Time.get_ticks_msec() * 0.004) * 1.4

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
	var close := _button("FECHAR [E]")
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

func _check_boss_trigger() -> void:
	var stage: Dictionary = STAGES[stage_index]
	if stage.boss == "" or boss_spawned or player.position.x < LEVEL_WIDTH - 610.0:
		return
	boss_spawned = true
	var boss_hour := float(stage.get("boss_hour", -1.0))
	if boss_hour >= 0.0:
		world_hour = fposmod(boss_hour, 24.0)
		_apply_world_time(true)
		_save_campaign()
	var boss := CorruptedBoss.new()
	boss.boss_name = stage.boss
	boss.boss_id = stage.get("boss_id", "generic")
	boss.encounter_tier = str(stage.get("boss_tier", "major"))
	current_boss_id = boss.boss_id
	boss.variant = 0 if stage_index == 2 else (1 if stage_index == 5 else 2)
	boss.max_health = 14 if boss.boss_id == "the_rock" else (16 if boss.boss_id == "corrupted_tree" else (12 if stage_index < 7 else 18))
	boss.health = boss.max_health
	boss.position = Vector2(LEVEL_WIDTH - 340.0, FLOOR_Y - 24.0)
	boss.process_mode = Node.PROCESS_MODE_PAUSABLE
	boss.defeated.connect(_on_boss_defeated)
	world.add_child(boss)
	_show_message(stage.boss + " bloqueia a passagem!", 3.0)

func _add_checkpoint_lights() -> void:
	for x in [1040.0, 1930.0]:
		var shrine := Node2D.new()
		shrine.position = Vector2(x, FLOOR_Y - 24.0)
		shrine.z_index = -1
		var stone := Polygon2D.new()
		stone.polygon = PackedVector2Array([Vector2(-9, 23), Vector2(-11, -6), Vector2(0, -17), Vector2(11, -6), Vector2(9, 23)])
		stone.color = Color("3c5c5c")
		shrine.add_child(stone)
		var mark := Polygon2D.new()
		mark.polygon = PackedVector2Array([Vector2(-3, 12), Vector2(-4, -4), Vector2(0, -9), Vector2(4, -4), Vector2(3, 12)])
		mark.color = Color("b5fff0")
		shrine.add_child(mark)
		world.add_child(shrine)
		var light := PointLight2D.new()
		light.texture = _make_glow_texture()
		light.color = Color("7fe6cf")
		light.energy = 1.8
		light.texture_scale = 1.4
		light.position = shrine.position + Vector2(0, -4)
		world.add_child(light)
		glow_lights.append(light)
		light_origins.append(light.position)

func _check_checkpoints() -> void:
	var markers := [1040.0, 1930.0]
	if checkpoint_marker < markers.size() and player.position.x >= markers[checkpoint_marker]:
		checkpoint_x = markers[checkpoint_marker]
		checkpoint_marker += 1
		player.restore(2)
		_show_message("Santuário de luz · campanha salva" if _save_campaign() else "Santuário alcançado, mas a gravação falhou.", 2.8)

func _respawn_player() -> void:
	respawn_timer = -999.0
	player.health = maxi(3, player.max_health)
	player.magic = player.max_magic
	player.velocity = Vector2.ZERO
	player.active = true
	player.hurt_timer = 1.4
	player.global_position = Vector2(checkpoint_x, FLOOR_Y - 33.0)
	player.health_changed.emit(player.health)
	_show_message("A trilha recomeça no último santuário", 2.6)

func _clear_stage() -> void:
	if stage_index >= STAGES.size() - 1:
		_show_ending()
		return
	if stage_index == 5:
		player.unlock_twin_magic()
		player.restore(5)
	stage_index += 1
	_build_stage()
	var stage: Dictionary = STAGES[stage_index]
	if stage_index == 6:
		_show_message("Aenia está livre! Pressione E para conversar." if _save_campaign() else "Aenia está livre, mas não foi possível salvar o progresso.", 4.0)
	else:
		_show_message((stage.title + " · " + stage.sub) if _save_campaign() else "Nova região iniciada, mas não foi possível salvar o progresso.", 3.0)

func _on_boss_defeated() -> void:
	boss_defeated = true
	player.restore(2)
	player.grant_skill_point()
	if current_boss_id == "the_rock":
		rock_recruited = true
	var saved := _save_campaign()
	if current_boss_id == "the_rock":
		_show_message("The Rock virou aliado. +1 ponto de talento." if saved else "The Rock virou aliado, mas não foi possível salvar o progresso.", 4.0)
	else:
		_show_message("A corrupção recua. +1 ponto de talento." if saved else "A passagem está livre, mas não foi possível salvar o progresso.", 3.2)

func _on_player_defeated() -> void:
	respawn_timer = 0.01

func _save_campaign() -> bool:
	if not playing or not player or not is_instance_valid(player):
		return false
	var save_data := {
		"version": SAVE_MANAGER.SAVE_VERSION,
		"world_hour": world_hour,
		"stage_index": stage_index,
		"checkpoint_x": checkpoint_x,
		"checkpoint_marker": checkpoint_marker,
		"health": player.health,
		"magic": player.magic,
		"level": player.level,
		"experience": player.experience,
		"experience_to_next": player.experience_to_next,
		"twin_magic": player.twin_magic,
		"rock_recruited": rock_recruited,
		"boss_defeated": boss_defeated,
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
	hud_objective.position = Vector2(390, 17)
	hud_objective.size = Vector2(236, 24)
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
	if hud_stage:
		hud_stage.text = "%02d  ·  %s" % [stage_index + 1, STAGES[stage_index].title]
	if hud_time:
		hud_time.text = "%s  ·  %s" % [_time_of_day_name(), _format_world_time()]
	if hud_inventory_button:
		var item_total := 0
		for item_id in ITEM_CATALOG.item_ids():
			item_total += int(player.inventory.get(item_id, 0))
		hud_inventory_button.text = "BOLSA [I]  %d" % item_total

func _advance_world_time(delta: float) -> void:
	world_hour = fposmod(world_hour + 24.0 * delta / DAY_CYCLE_REAL_SECONDS, 24.0)
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
		hud_time.text = "%s  ·  %s" % [_time_of_day_name(), _format_world_time()]

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
	var restart := _button("RECOMEÇAR FASE")
	restart.pressed.connect(func():
		get_tree().paused = false
		paused = false
		player.health = player.max_health
		player.magic = player.max_magic
		_build_stage()
		_show_hud()
		if not _save_campaign():
			_show_message("Não foi possível salvar o progresso no disco.", 3.0)
	)
	buttons.add_child(restart)
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
