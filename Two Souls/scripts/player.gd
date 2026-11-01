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
const ORION_IDLE_TEXTURE = preload("res://assets/sprites/orion_idle.png")

const GRAVITY := 980.0
const MOVE_SPEED := 152.0
const ACCELERATION := 1180.0
const JUMP_SPEED := -340.0

var health := 5
var max_health := 5
var magic := 3
var max_magic := 5
var level := 1
var experience := 0
var experience_to_next := 100
var facing := 1
var attack_timer := 0.0
var magic_timer := 0.0
var spear_cooldown := 0.0
var super_punch_cooldown := 0.0
var super_punch_flash := 0.0
var hurt_timer := 0.0
var anim_time := 0.0
var jump_count := 0
var twin_magic := false
var active := true
var inventory: Dictionary = ITEM_CATALOG.empty_inventory()
var collected_pickups: Dictionary = {}
var skill_points := 0
var unlocked_skills: Dictionary = {}
var character_sprite: Sprite2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 1
	character_sprite = Sprite2D.new()
	character_sprite.name = "CharacterVisual"
	character_sprite.texture = ORION_IDLE_TEXTURE
	character_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	character_sprite.scale = Vector2(0.037, 0.037)
	character_sprite.position = Vector2(0.0, -1.0)
	character_sprite.z_index = -1
	add_child(character_sprite)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(14, 24)
	collision.shape = shape
	add_child(collision)
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = -40
	camera.limit_bottom = 360
	add_child(camera)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active:
		return
	anim_time += delta
	attack_timer = maxf(0.0, attack_timer - delta)
	magic_timer = maxf(0.0, magic_timer - delta)
	spear_cooldown = maxf(0.0, spear_cooldown - delta)
	super_punch_cooldown = maxf(0.0, super_punch_cooldown - delta)
	super_punch_flash = maxf(0.0, super_punch_flash - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)
	var direction := Input.get_axis("move_left", "move_right")
	if absf(direction) > 0.01:
		facing = 1 if direction > 0.0 else -1
	velocity.x = move_toward(velocity.x, direction * MOVE_SPEED, ACCELERATION * delta)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		jump_count = 0
	if Input.is_action_just_pressed("jump") and (is_on_floor() or (twin_magic and jump_count < 1)):
		velocity.y = JUMP_SPEED
		jump_count += 1
	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		_attack()
	if Input.is_action_just_pressed("magic") and magic_timer <= 0.0 and magic > 0:
		_cast_magic()
	if Input.is_action_just_pressed("throw_spear") and spear_cooldown <= 0.0 and has_skill("spear_throw"):
		_throw_spear()
	if Input.is_action_just_pressed("super_punch") and super_punch_cooldown <= 0.0 and has_skill("super_punch"):
		_super_punch()
	move_and_slide()
	if global_position.y > 470.0:
		take_damage(1, true)
	if character_sprite:
		character_sprite.flip_h = facing < 0
		character_sprite.visible = not (hurt_timer > 0.0 and int(anim_time * 18.0) % 2 == 0)
	queue_redraw()

func _attack() -> void:
	attack_timer = 0.34
	for target in get_tree().get_nodes_in_group("hostile"):
		if not is_instance_valid(target):
			continue
		var offset: Vector2 = target.global_position - global_position
		if absf(offset.x) < 48.0 and absf(offset.y) < 42.0 and offset.x * facing > -12.0:
			target.call("take_hit", 1)
	for target in get_tree().get_nodes_in_group("attackable_scenery"):
		if not is_instance_valid(target):
			continue
		var offset: Vector2 = target.global_position - global_position
		if absf(offset.x) < 50.0 and absf(offset.y) < 62.0 and offset.x * facing > -12.0:
			target.call("take_hit", 1)

func _cast_magic() -> void:
	magic -= 1
	magic_timer = 0.58
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
	velocity = Vector2(-facing * 100.0, -145.0)
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
	max_health = 5 + (1 if has_skill("vitality") else 0)
	max_magic = 5 + (1 if has_skill("mana_reserve") else 0)
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
	spear_cooldown = 1.15
	var spear := MagicBolt.new()
	spear.projectile_kind = "spear"
	spear.speed = 360.0
	spear.life = 1.2
	spear.direction = facing
	spear.position = global_position + Vector2(facing * 18.0, -3.0)
	get_parent().add_child(spear)

func _super_punch() -> void:
	super_punch_cooldown = 3.8
	super_punch_flash = 0.24
	attack_timer = 0.34
	for target in get_tree().get_nodes_in_group("hostile"):
		if not is_instance_valid(target):
			continue
		var offset: Vector2 = target.global_position - global_position
		if absf(offset.x) < 72.0 and absf(offset.y) < 48.0 and offset.x * facing > -12.0:
			target.call("take_hit", 3)
	for target in get_tree().get_nodes_in_group("attackable_scenery"):
		if not is_instance_valid(target):
			continue
		var offset: Vector2 = target.global_position - global_position
		if absf(offset.x) < 74.0 and absf(offset.y) < 62.0 and offset.x * facing > -12.0:
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
	if attack_timer > 0.13:
		draw_arc(Vector2(10 * facing, -1), 22.0, -1.25 if facing > 0 else 2.1, 1.2 if facing > 0 else 4.55, 12, Color("a7fff2"), 2.0, false)
		_draw_sparkle(Vector2(27 * facing, -11), Color("f4f1c0"))
	if super_punch_flash > 0.0:
		var impact := Vector2(19.0 * facing, -2.0)
		draw_circle(impact, 15.0, Color(0.52, 0.96, 0.87, super_punch_flash * 2.2))
		draw_rect(Rect2(impact.x - 5.0, impact.y - 5.0, 10.0, 10.0), Color("f6ffe7"))
		_draw_sparkle(impact + Vector2(10.0 * facing, -4.0), Color("fff1ad"))

func _draw_sparkle(at: Vector2, color: Color) -> void:
	draw_rect(Rect2(at.x - 1, at.y - 5, 2, 10), color)
	draw_rect(Rect2(at.x - 5, at.y - 1, 10, 2), color)
