extends CharacterBody2D
class_name Orion

signal health_changed(value: int)
signal defeated
signal twin_magic_unlocked
signal leveled_up(new_level: int)
signal inventory_changed
signal item_added(item_id: String, count: int)
signal skills_changed

const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")
const SKILL_CATALOG = preload("res://scripts/skill_catalog.gd")

const WORLD_SCALE := 3.0
const GRAVITY := 980.0 * WORLD_SCALE
const MOVE_SPEED := 152.0 * WORLD_SCALE
const ACCELERATION := 1180.0 * WORLD_SCALE
## Pulo de ~120 px (1,7 vez a altura do Orion), proporção de jogo arcade na tela de 640x360.
## Altura = JUMP_SPEED² / (2 * GRAVITY). O mundo (world_room.gd) conta com esse valor.
const JUMP_SPEED := -840.0
const JUMP_HEIGHT := 120.0
## Dash por duplo toque na seta (como no Grand Chase): dois toques na mesma direção em até DASH_WINDOW.
const DASH_WINDOW := 0.25
const DASH_TIME := 0.18
const DASH_SPEED := 1150.0
const DASH_COOLDOWN := 0.35
const COLLISION_SIZE := Vector2(22.0, 66.0)
const SPRITE_PIVOT_OFFSET_X := 16.0

var health := 5
var max_health := 5
var magic := 3
var max_magic := 5
var level := 1
var experience := 0
var experience_to_next := 100
var facing := 1
var attack_timer := 0.0
## Combos de comando (scripts/combat/orion_combo.gd).
var combo := OrionCombo.new()
var hit_stop := 0.0
var magic_timer := 0.0
var spear_cooldown := 0.0
var super_punch_cooldown := 0.0
var super_punch_flash := 0.0
var hurt_timer := 0.0
var anim_time := 0.0
var attack_animation_timer := 0.0
var dash_animation_timer := 0.0
var jump_count := 0
## Pulo duplo do gavião (ligado pelo game.gd a partir das habilidades).
var double_jump := false
## Abaixo deste y (fundo da sala + folga) o Orion leva dano de queda.
var fall_limit_y := 470.0
var twin_magic := false
var active := true
var inventory: Dictionary = ITEM_CATALOG.empty_inventory()
var collected_pickups: Dictionary = {}
var skill_points := 0
var unlocked_skills: Dictionary = {}
var character_sprite: AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 1
	character_sprite = AnimatedSprite2D.new()
	character_sprite.name = "CharacterVisual"
	character_sprite.sprite_frames = AsepriteFrames.load_frames("res://assets/sprites/orion.json")
	character_sprite.animation = "idle"
	character_sprite.play()
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.scale = Vector2.ONE
	# O ponto (64, 88) do quadro deve coincidir com o pé da colisão (y=12).
	character_sprite.position = Vector2(SPRITE_PIVOT_OFFSET_X, COLLISION_SIZE.y * 0.5 - 40.0)
	character_sprite.z_index = -1
	add_child(character_sprite)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = COLLISION_SIZE
	collision.shape = shape
	add_child(collision)
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = -100
	camera.limit_bottom = 360
	add_child(camera)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active:
		return
	combo.read_input()
	# Pausa curtinha no acerto (hit-stop) para o golpe ter peso.
	if hit_stop > 0.0:
		hit_stop -= delta
		return
	anim_time += delta
	attack_timer = maxf(0.0, attack_timer - delta)
	attack_animation_timer = maxf(0.0, attack_animation_timer - delta)
	dash_animation_timer = maxf(0.0, dash_animation_timer - delta)
	magic_timer = maxf(0.0, magic_timer - delta)
	spear_cooldown = maxf(0.0, spear_cooldown - delta)
	super_punch_cooldown = maxf(0.0, super_punch_cooldown - delta)
	super_punch_flash = maxf(0.0, super_punch_flash - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)
	var direction := Input.get_axis("move_left", "move_right")
	if absf(direction) > 0.01:
		facing = 1 if direction > 0.0 else -1
	_check_dash_tap(delta)
	if dash_time_left > 0.0:
		# Durante o dash: reto, sem gravidade e sem frear.
		dash_time_left -= delta
		velocity = Vector2(dash_direction * DASH_SPEED * (1.0 + float(rune_bonus.get("dash_speed", 0.0))), 0.0)
	else:
		velocity.x = move_toward(velocity.x, direction * MOVE_SPEED * (1.0 + float(rune_bonus.get("move_speed", 0.0))), ACCELERATION * delta)
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			jump_count = 0
	if Input.is_action_just_pressed("jump") and (is_on_floor() or (double_jump and jump_count < 2)):
		velocity.y = JUMP_SPEED
		# Cair de uma borda conta como o primeiro pulo: no ar sobra só o pulo duplo.
		jump_count = maxi(jump_count, 0 if is_on_floor() else 1) + 1
		dash_time_left = 0.0
	var started := combo.update(self, delta)
	if started != "":
		attack_animation_timer = float(OrionCombo.MOVES[started]["time"]) + 0.05
		if character_sprite:
			character_sprite.play("attack")
			character_sprite.frame = 0
	if Input.is_action_just_pressed("magic") and magic_timer <= 0.0 and magic > 0:
		_cast_magic()
	if Input.is_action_just_pressed("throw_spear") and spear_cooldown <= 0.0 and has_skill("spear_throw"):
		_throw_spear()
	if Input.is_action_just_pressed("super_punch") and super_punch_cooldown <= 0.0 and has_skill("super_punch"):
		_super_punch()
	move_and_slide()
	if global_position.y > fall_limit_y:
		take_damage(1, true)
	if character_sprite:
		character_sprite.flip_h = facing < 0
		# O pivô (64, 88) fica 16 px à esquerda do centro do quadro; ao espelhar, vai para a direita.
		character_sprite.position.x = SPRITE_PIVOT_OFFSET_X * (-1.0 if facing < 0 else 1.0)
		character_sprite.visible = not (hurt_timer > 0.0 and int(anim_time * 18.0) % 2 == 0)
		_update_animation()
	queue_redraw()

func _update_animation() -> void:
	var desired := "idle"
	if dash_animation_timer > 0.0:
		desired = "dash"
	elif attack_animation_timer > 0.0:
		desired = "attack"
	elif not is_on_floor():
		desired = "jump" if velocity.y < 0.0 else "fall"
	elif absf(velocity.x) > 8.0:
		desired = "run"
	if character_sprite.animation != desired:
		character_sprite.play(desired)

func start_dash_animation(duration: float = 0.24) -> void:
	# Ponto de entrada para o estado de dash quando a habilidade for acionada.
	dash_animation_timer = maxf(dash_animation_timer, duration)

func _cast_magic() -> void:
	magic -= 1
	magic_timer = 0.58 * _cooldown_scale()
	var bolt: MagicBolt = MagicBolt.new()
	bolt.position = global_position + Vector2(facing * 17.0, -3.0)
	bolt.direction = facing
	bolt.empowered = twin_magic
	get_parent().add_child(bolt)

func take_damage(amount: int, from_fall: bool = false) -> void:
	if hurt_timer > 0.0:
		return
	health = maxi(0, health - amount)
	hurt_timer = 1.05
	velocity = Vector2(-facing * 100.0 * WORLD_SCALE, -145.0 * WORLD_SCALE)
	health_changed.emit(health)
	if health <= 0:
		active = false
		defeated.emit()

func restore(amount: int) -> void:
	health = mini(max_health, health + amount)
	magic = mini(max_magic, magic + amount)
	health_changed.emit(health)

func set_inventory(value: Variant) -> void:
	inventory = ITEM_CATALOG.sanitize_inventory(value)
	inventory_changed.emit()

func set_collected_pickups(value: Variant) -> void:
	collected_pickups.clear()
	if typeof(value) != TYPE_ARRAY:
		return
	for pickup_id in value:
		if typeof(pickup_id) == TYPE_STRING and not str(pickup_id).is_empty():
			collected_pickups[str(pickup_id)] = true

func set_skill_state(points: int, learned_skills: Variant) -> void:
	skill_points = clampi(points, 0, 99)
	unlocked_skills.clear()
	if typeof(learned_skills) == TYPE_ARRAY:
		for skill_id in learned_skills:
			if typeof(skill_id) == TYPE_STRING and SKILL_CATALOG.skill_ids().has(str(skill_id)):
				unlocked_skills[str(skill_id)] = true
	_refresh_skill_stats(false)
	skills_changed.emit()

func get_unlocked_skill_ids() -> Array:
	var ids: Array = unlocked_skills.keys()
	ids.sort()
	return ids

func has_skill(skill_id: String) -> bool:
	return unlocked_skills.has(skill_id)

func can_unlock_skill(skill_id: String) -> bool:
	var definition := SKILL_CATALOG.get_definition(skill_id)
	if definition.is_empty() or has_skill(skill_id) or skill_points < int(definition["cost"]):
		return false
	for prerequisite in definition.get("prerequisites", []):
		if not has_skill(str(prerequisite)):
			return false
	return true

func purchase_skill(skill_id: String) -> bool:
	if not can_unlock_skill(skill_id):
		return false
	var definition := SKILL_CATALOG.get_definition(skill_id)
	skill_points -= int(definition["cost"])
	unlocked_skills[skill_id] = true
	_refresh_skill_stats(true)
	skills_changed.emit()
	return true

func grant_skill_point(amount: int = 1) -> void:
	if amount <= 0:
		return
	skill_points = mini(99, skill_points + amount)
	skills_changed.emit()

func _refresh_skill_stats(replenish_increase: bool) -> void:
	var previous_max_health := max_health
	var previous_max_magic := max_magic
	max_health = 5 + (1 if has_skill("vitality") else 0) + int(rune_bonus.get("max_health", 0))
	max_magic = 5 + (1 if has_skill("mana_reserve") else 0) + int(rune_bonus.get("max_magic", 0))
	if replenish_increase:
		health += maxi(0, max_health - previous_max_health)
		magic += maxi(0, max_magic - previous_max_magic)
	health = mini(max_health, health)
	magic = mini(max_magic, magic)

func get_collected_pickup_ids() -> Array:
	var ids: Array = collected_pickups.keys()
	ids.sort()
	return ids

func has_collected_pickup(pickup_id: String) -> bool:
	return not pickup_id.is_empty() and collected_pickups.has(pickup_id)

func add_item(item_id: String, amount: int = 1, pickup_id: String = "") -> bool:
	if amount <= 0 or not inventory.has(item_id):
		return false
	if has_collected_pickup(pickup_id):
		return false
	var old_count := int(inventory[item_id])
	var new_count := mini(99, old_count + amount)
	if new_count == old_count:
		return false
	inventory[item_id] = new_count
	if not pickup_id.is_empty():
		collected_pickups[pickup_id] = true
	inventory_changed.emit()
	item_added.emit(item_id, new_count)
	return true

func can_use_item(item_id: String) -> bool:
	if int(inventory.get(item_id, 0)) <= 0:
		return false
	var definition := ITEM_CATALOG.get_definition(item_id)
	if definition.is_empty():
		return false
	if definition["effect"] == "health":
		return health < max_health
	if definition["effect"] == "magic":
		return magic < max_magic
	return false

func use_item(item_id: String) -> bool:
	if not can_use_item(item_id):
		return false
	var definition := ITEM_CATALOG.get_definition(item_id)
	var amount := int(definition["amount"])
	if definition["effect"] == "health":
		health = mini(max_health, health + amount)
		health_changed.emit(health)
	elif definition["effect"] == "magic":
		magic = mini(max_magic, magic + amount)
	else:
		return false
	inventory[item_id] = int(inventory[item_id]) - 1
	inventory_changed.emit()
	return true

func _throw_spear() -> void:
	spear_cooldown = 1.15 * _cooldown_scale()
	var spear := MagicBolt.new()
	spear.projectile_kind = "spear"
	spear.speed = 360.0 * WORLD_SCALE
	spear.life = 1.2
	spear.direction = facing
	spear.position = global_position + Vector2(facing * 18.0 * WORLD_SCALE, -3.0 * WORLD_SCALE)
	get_parent().add_child(spear)

func _super_punch() -> void:
	super_punch_cooldown = 3.8 * _cooldown_scale()
	super_punch_flash = 0.24
	attack_timer = 0.34
	attack_animation_timer = 0.5
	for target in get_tree().get_nodes_in_group("hostile"):
		if not is_instance_valid(target):
			continue
		var offset: Vector2 = target.global_position - global_position
		if absf(offset.x) < 72.0 * WORLD_SCALE and absf(offset.y) < 48.0 * WORLD_SCALE and offset.x * facing > -12.0 * WORLD_SCALE:
			target.call("take_hit", 3)
	for target in get_tree().get_nodes_in_group("attackable_scenery"):
		if not is_instance_valid(target):
			continue
		var offset: Vector2 = target.global_position - global_position
		if absf(offset.x) < 74.0 * WORLD_SCALE and absf(offset.y) < 62.0 * WORLD_SCALE and offset.x * facing > -12.0 * WORLD_SCALE:
			target.call("take_hit", 3)

func gain_experience(amount: int) -> void:
	if amount <= 0:
		return
	experience += amount
	while experience >= experience_to_next:
		experience -= experience_to_next
		level += 1
		skill_points = mini(99, skill_points + 1)
		skills_changed.emit()
		# These prototype thresholds are easy to rebalance after the talent tree is designed.
		experience_to_next = 100 + (level - 1) * 25
		leveled_up.emit(level)

func unlock_twin_magic() -> void:
	twin_magic = true
	twin_magic_unlocked.emit()

func _draw() -> void:
	var flicker := hurt_timer > 0.0 and int(anim_time * 18.0) % 2 == 0
	if flicker:
		return
	# The character's body and carried spear come from the approved pixel-art sprite.
	if combo.is_attacking():
		_draw_combo_move()
	if super_punch_flash > 0.0:
		var impact := Vector2(57.0 * facing, -6.0)
		draw_circle(impact, 45.0, Color(0.52, 0.96, 0.87, super_punch_flash * 2.2))
		draw_rect(Rect2(impact.x - 15.0, impact.y - 15.0, 30.0, 30.0), Color("f6ffe7"))
		_draw_sparkle(impact + Vector2(30.0 * facing, -12.0), Color("fff1ad"))

func _draw_sparkle(at: Vector2, color: Color) -> void:
	draw_rect(Rect2(at.x - 3, at.y - 15, 6, 30), color)
	draw_rect(Rect2(at.x - 15, at.y - 3, 30, 6), color)

# --- Runas (docs/design/runas.md) ---

## Bônus das runas equipadas, vindo de RuneState.total_bonuses() pelo game.gd.
var rune_bonus: Dictionary = {}

func apply_rune_bonuses(bonuses: Dictionary, fill_new_slots: bool = false) -> void:
	rune_bonus = bonuses.duplicate(true)
	_refresh_skill_stats(fill_new_slots)
	skills_changed.emit()

## Recarga das habilidades: as runas de recarga dão valores negativos (ex.: -0,09 = 9% mais rápido).
func _cooldown_scale() -> float:
	return maxf(0.4, 1.0 + float(rune_bonus.get("cooldown", 0.0)))

## O dano do jogo é em pontos inteiros; a runa de dano vira chance de um golpe forte (2 pontos).
func _hit_amount() -> int:
	return 2 if randf() < float(rune_bonus.get("damage", 0.0)) else 1

# --- Dash por duplo toque ---

var dash_time_left := 0.0
var dash_cooldown := 0.0
var dash_direction := 1
var _last_tap_direction := 0
var _last_tap_time := -10.0

func is_dashing() -> bool:
	return dash_time_left > 0.0

func _check_dash_tap(delta: float) -> void:
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	var tapped := 0
	if Input.is_action_just_pressed("move_left"):
		tapped = -1
	elif Input.is_action_just_pressed("move_right"):
		tapped = 1
	if tapped == 0:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if tapped == _last_tap_direction and now - _last_tap_time <= DASH_WINDOW and dash_cooldown <= 0.0:
		dash_direction = tapped
		facing = tapped
		dash_time_left = DASH_TIME
		combo.move = ""
		dash_cooldown = DASH_TIME + DASH_COOLDOWN
		start_dash_animation(DASH_TIME + 0.06)
		_last_tap_direction = 0
	else:
		_last_tap_direction = tapped
		_last_tap_time = now

# --- Desenho provisório dos golpes do combo (até a arte de cada golpe existir) ---

func _draw_combo_move() -> void:
	var info: Dictionary = OrionCombo.MOVES[combo.move]
	var progress := clampf(combo.move_time / float(info["time"]), 0.0, 1.0)
	var fade := 1.0 - progress
	var trail := Color(0.65, 1.0, 0.95, 0.85 * fade)
	var f := float(facing)
	match combo.move:
		"a1", "a2", "air", "lunge":
			draw_arc(Vector2(18 * f, -8), 44.0, -0.9 if f > 0 else 2.2, 0.9 if f > 0 else 4.0, 10, trail, 4.0)
		"a3":
			draw_arc(Vector2(0, -10), 52.0, 0.0, TAU * progress, 18, trail, 4.0)
		"launcher", "upper":
			draw_line(Vector2(20 * f, 30), Vector2(26 * f, -70), trail, 5.0)
		"sweep":
			draw_arc(Vector2(10 * f, 24), 46.0, 0.2 if f > 0 else 2.0, 1.1 if f > 0 else 2.9, 10, trail, 4.0)
		"dive":
			draw_line(Vector2(0, -20), Vector2(4 * f, 50), trail, 5.0)
		"a4":
			# Transformação relâmpago: silhueta preta do animal com olhos e marcas verdes (brainstorm, seção 3).
			var alpha := 0.9 * fade
			var body := Vector2(46 * f, -6)
			draw_circle(body, 34.0, Color(0.03, 0.05, 0.04, alpha))
			draw_circle(body + Vector2(28 * f, -16), 18.0, Color(0.03, 0.05, 0.04, alpha))
			draw_circle(body + Vector2(34 * f, -20), 3.0, Color(0.24, 0.81, 0.37, alpha))
			draw_arc(body, 40.0, 0.0, TAU, 20, Color(0.24, 0.81, 0.37, alpha * 0.8), 2.0)
