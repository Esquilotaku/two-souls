extends CharacterBody2D
class_name ForestFoe

## A origem fica no centro do corpo; os pés ficam a metade da altura da colisão abaixo dela.

const EXPERIENCE_ORB_SCRIPT = preload("res://scripts/experience_orb.gd")
const ITEM_PICKUP_SCRIPT = preload("res://scripts/item_pickup.gd")

var health := 2
var max_health := 2
var experience_reward := 12
var start_x := 0.0
var age := 0.0
var hit_flash := 0.0
var attack_cooldown := 0.0
var ranged_cooldown := 0.9
var speed := 28.0
var patrol_span := 110.0
var floor_y := 304.0
var ranged := false
var tribal := false
var is_rock_summon := false
var facing := 1
var drop_id := ""
## Atordoado por golpe (combos do Kaê): não anda nem ataca.
var stun_timer := 0.0
const STUN_GRAVITY := 2400.0
var time_difficulty := 0.0
var base_health := 2
var base_speed := 28.0
var difficulty_initialized := false
## Opções: "corrupted_runner" (padrão), "tribal_spearman", "giant_beast".
var kind := ""
var has_been_hit := false
var charge_cooldown := 0.0

func _resolved_kind() -> String:
	if not kind.is_empty():
		return kind
	if tribal:
		return "tribal_spearman"
	return "corrupted_runner"

func _collision_size() -> Vector2:
	match _resolved_kind():
		"tribal_spearman": return Vector2(28, 76)
		"giant_beast": return Vector2(56, 100)
		_: return Vector2(34, 72)

func _ready() -> void:
	if speed == 28.0:
		match _resolved_kind():
			"corrupted_runner": speed = 42.0
			"giant_beast": speed = 17.0
	add_to_group("hostile")
	collision_layer = 1
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = _collision_size()
	collision.shape = shape
	add_child(collision)
	start_x = global_position.x
	max_health = health

func _physics_process(delta: float) -> void:
	age += delta
	if stun_timer > 0.0:
		# Lançado ou empurrado por um golpe: sem andar nem atacar até cair e o tempo passar.
		stun_timer -= delta
		velocity.y += STUN_GRAVITY * delta
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
		move_and_slide()
		queue_redraw()
		return
	hit_flash = maxf(0.0, hit_flash - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	ranged_cooldown = maxf(0.0, ranged_cooldown - delta)
	charge_cooldown = maxf(0.0, charge_cooldown - delta)
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var horizontal_distance: float = player.global_position.x - global_position.x
		var vertical_distance := absf(player.global_position.y - global_position.y)
		if absf(horizontal_distance) > 1.0:
			facing = 1 if horizontal_distance > 0.0 else -1
		if ranged:
			velocity.x = -facing * speed * 0.6 if absf(horizontal_distance) < 112.0 else 0.0
			if absf(horizontal_distance) < 320.0 and vertical_distance < 73.0 and ranged_cooldown <= 0.0:
				_throw_spear()
				ranged_cooldown = lerpf(2.1, 1.55, time_difficulty)
		elif absf(horizontal_distance) < 150.0 and vertical_distance < 90.0:
			velocity.x = signf(horizontal_distance) * speed * 0.72
			if _resolved_kind() == "corrupted_runner" and absf(horizontal_distance) > 64.0 and charge_cooldown <= 0.0:
				velocity.x = signf(horizontal_distance) * speed * 2.8
				charge_cooldown = 2.2
			if absf(horizontal_distance) < 23.0 and vertical_distance < 60.0 and attack_cooldown <= 0.0:
				player.call("take_damage", 1)
				attack_cooldown = lerpf(1.0, 0.76, time_difficulty)
	else:
		velocity.x = sin(age * 1.4) * speed
	if not is_on_floor():
		velocity.y += 980.0 * delta
	else:
		velocity.y = 0.0
	if not ranged and absf(global_position.x - start_x) > patrol_span:
		velocity.x = signf(start_x - global_position.x) * speed
	move_and_slide()
	queue_redraw()

func _throw_spear() -> void:
	var spear := MagicBolt.new()
	spear.enemy_attack = true
	spear.projectile_kind = "spear"
	spear.direction = facing
	spear.speed = 205.0 * (1.0 + time_difficulty * 0.16)
	spear.gravity = 45.0
	spear.life = 2.0
	spear.position = position + Vector2(facing * 12.0, -7.0)
	get_parent().add_child(spear)

func set_time_difficulty(value: float) -> void:
	if not difficulty_initialized:
		base_health = health
		max_health = health
		base_speed = speed
		difficulty_initialized = true
	var health_ratio := float(health) / float(max_health) if max_health > 0 else 1.0
	time_difficulty = clampf(value, 0.0, 1.0)
	max_health = maxi(1, roundi(float(base_health) * (1.0 + 0.3 * time_difficulty)))
	health = clampi(roundi(float(max_health) * health_ratio), 1, max_health)
	speed = base_speed * (1.0 + 0.2 * time_difficulty)

func take_hit(amount: int) -> void:
	health -= amount
	hit_flash = 0.12
	has_been_hit = true
	if health <= 0:
		_drop_experience()
		queue_free()

func _drop_experience() -> void:
	if experience_reward <= 0 or not get_parent():
		return
	var orb = EXPERIENCE_ORB_SCRIPT.new()
	orb.amount = experience_reward
	get_parent().add_child(orb)
	orb.global_position = global_position + Vector2(0.0, -8.0)
	_drop_consumable()

func _drop_consumable() -> void:
	if is_rock_summon or drop_id.is_empty() or randf() >= 0.22 or not get_parent():
		return
	var pickup_id := drop_id + "_consumable"
	var player := get_tree().get_first_node_in_group("player")
	if player and bool(player.call("has_collected_pickup", pickup_id)):
		return
	var pickup: ItemPickup = ITEM_PICKUP_SCRIPT.new()
	pickup.item_id = "mana_seed" if tribal else "luminous_herb"
	pickup.pickup_id = pickup_id
	get_parent().add_child(pickup)
	pickup.global_position = global_position + Vector2(0.0, -12.0)

func _draw() -> void:
	match _resolved_kind():
		"tribal_spearman": _draw_tribal_spearman()
		"giant_beast": _draw_giant_beast()
		_: _draw_corrupted_runner()
	if has_been_hit:
		var width := _collision_size().x + 8.0
		var top := -_collision_size().y * 0.5 - 10.0
		draw_rect(Rect2(-width * 0.5, top, width, 4), Color("20263a"))
		draw_rect(Rect2(-width * 0.5 + 1, top + 1, (width - 2) * clampf(float(health) / maxf(float(max_health), 1.0), 0.0, 1.0), 2), Color("ee8292"))

func _draw_corrupted_runner() -> void:
	var color := Color("fff0c0") if hit_flash > 0.0 else Color("76527f")
	var bob := int(sin(age * 9.0) * 2.0)
	draw_rect(Rect2(-13, 24, 26, 8), Color(0.02, 0.04, 0.08, 0.5))
	draw_colored_polygon(PackedVector2Array([Vector2(-15, 18), Vector2(-18, 3 + bob), Vector2(-12, -20 + bob), Vector2(-5, -30 + bob), Vector2(10, -27 + bob), Vector2(17, -8 + bob), Vector2(13, 13), Vector2(5, 22), Vector2(-7, 22)]), color)
	draw_colored_polygon(PackedVector2Array([Vector2(7, -23 + bob), Vector2(18, -31 + bob), Vector2(16, -17 + bob), Vector2(8, -14 + bob)]), Color("8b4f91"))
	draw_rect(Rect2(-8, -16 + bob, 5, 3), Color("d9f28a"))
	draw_rect(Rect2(5, -16 + bob, 5, 3), Color("d9f28a"))
	draw_line(Vector2(-7, 18), Vector2(-11, 30), color.darkened(0.3), 5.0)
	draw_line(Vector2(8, 18), Vector2(12, 30), color.darkened(0.3), 5.0)

func _draw_tribal_spearman() -> void:
	var body_color := Color("fff0c0") if hit_flash > 0.0 else Color("6f8350")
	var bob := int(sin(age * 8.0) * 1.0)
	draw_rect(Rect2(-13, 34, 26, 7), Color(0.02, 0.04, 0.08, 0.5))
	draw_rect(Rect2(-10, -7 + bob, 20, 38), body_color.darkened(0.15))
	draw_rect(Rect2(-11, -24 + bob, 22, 18), Color("5b3829"))
	draw_rect(Rect2(-10, -21 + bob, 20, 9), Color("c1a46d"))
	draw_rect(Rect2(-7, -16 + bob, 4, 3), Color("e7dfb0"))
	draw_rect(Rect2(3, -16 + bob, 4, 3), Color("e7dfb0"))
	draw_rect(Rect2(-9, 28 + bob, 7, 13), Color("342d2d"))
	draw_rect(Rect2(3, 28 + bob, 7, 13), Color("342d2d"))
	for leaf in range(3):
		draw_colored_polygon(PackedVector2Array([
			Vector2(-9 + leaf * 8, -22 + bob), Vector2(-7 + leaf * 8, -34 + bob),
			Vector2(-2 + leaf * 8, -22 + bob)
		]), Color("43a35c"))
	draw_line(Vector2(8 * facing, -1 + bob), Vector2(25 * facing, -29 + bob), Color("bc9862"), 3.0, false)
	draw_colored_polygon(PackedVector2Array([
		Vector2(25 * facing, -29 + bob), Vector2(21 * facing, -31 + bob), Vector2(22 * facing, -26 + bob)
	]), Color("d4ded1"))

func _draw_giant_beast() -> void:
	var color := Color("fff0c0") if hit_flash > 0.0 else Color("58694b")
	var bob := int(sin(age * 2.2) * 1.0)
	draw_rect(Rect2(-31, 40, 62, 10), Color(0.02, 0.04, 0.08, 0.5))
	draw_colored_polygon(PackedVector2Array([Vector2(-29, 29), Vector2(-35, 5), Vector2(-27, -17 + bob), Vector2(-19, -34 + bob), Vector2(17, -36 + bob), Vector2(33, -16 + bob), Vector2(36, 13), Vector2(24, 30)]), color)
	draw_circle(Vector2(-22, -24 + bob), 11.0, color.lightened(0.12))
	draw_colored_polygon(PackedVector2Array([Vector2(-29, -30 + bob), Vector2(-37, -45 + bob), Vector2(-18, -35 + bob)]), Color("b5a27a"))
	draw_colored_polygon(PackedVector2Array([Vector2(-13, -30 + bob), Vector2(-7, -46 + bob), Vector2(-2, -31 + bob)]), Color("b5a27a"))
	draw_rect(Rect2(-28, -27 + bob, 5, 3), Color("d9f28a"))
	draw_line(Vector2(-19, 25), Vector2(-22, 47), color.darkened(0.3), 9.0)
	draw_line(Vector2(20, 24), Vector2(24, 47), color.darkened(0.3), 9.0)

## Empurrão e lançamento dos combos (scripts/combat/orion_combo.gd). Chefes não têm esta função: super armadura.
func apply_knockback(push: Vector2, stun: float) -> void:
	velocity = push
	stun_timer = maxf(stun_timer, stun)
