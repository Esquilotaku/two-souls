extends CharacterBody2D
class_name ForestFoe

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
var time_difficulty := 0.0
var base_health := 2
var base_speed := 28.0
var difficulty_initialized := false

func _ready() -> void:
	add_to_group("hostile")
	collision_layer = 1
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 16)
	collision.shape = shape
	add_child(collision)
	start_x = global_position.x
	max_health = health

func _physics_process(delta: float) -> void:
	age += delta
	hit_flash = maxf(0.0, hit_flash - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	ranged_cooldown = maxf(0.0, ranged_cooldown - delta)
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var horizontal_distance := player.global_position.x - global_position.x
		var vertical_distance := absf(player.global_position.y - global_position.y)
		if absf(horizontal_distance) > 1.0:
			facing = 1 if horizontal_distance > 0.0 else -1
		if ranged:
			velocity.x = -facing * speed * 0.6 if absf(horizontal_distance) < 112.0 else 0.0
			if absf(horizontal_distance) < 320.0 and vertical_distance < 58.0 and ranged_cooldown <= 0.0:
				_throw_spear()
				ranged_cooldown = lerpf(2.1, 1.55, time_difficulty)
		elif absf(horizontal_distance) < 150.0:
			velocity.x = signf(horizontal_distance) * speed * 0.72
			if absf(horizontal_distance) < 23.0 and attack_cooldown <= 0.0:
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
	if tribal:
		_draw_tribal_spearman()
		return
	var body_color := Color("fff0c0") if hit_flash > 0.0 else Color("8b4f91")
	var wobble := int(sin(age * 9.0) * 2.0)
	draw_rect(Rect2(-11, 2, 22, 11), Color("182033"))
	draw_rect(Rect2(-10 + wobble, -5, 20, 13), body_color)
	draw_rect(Rect2(-8 + wobble, -9, 15, 7), body_color.lightened(0.12))
	draw_rect(Rect2(-8 + wobble, 6, 4, 3), Color("463359"))
	draw_rect(Rect2(4 + wobble, 6, 4, 3), Color("463359"))
	draw_rect(Rect2(-6 + wobble, -4, 3, 3), Color("f4e8c9"))
	draw_rect(Rect2(3 + wobble, -4, 3, 3), Color("f4e8c9"))
	draw_rect(Rect2(-5 + wobble, -3, 2, 2), Color("2d1d3d"))
	draw_rect(Rect2(4 + wobble, -3, 2, 2), Color("2d1d3d"))
	if health == 1:
		draw_rect(Rect2(-2, -12, 4, 2), Color("da88c9"))

func _draw_tribal_spearman() -> void:
	var body_color := Color("fff0c0") if hit_flash > 0.0 else Color("6f8350")
	var bob := int(sin(age * 8.0) * 1.0)
	draw_rect(Rect2(-12, 4, 24, 5), Color(0.02, 0.04, 0.08, 0.5))
	draw_rect(Rect2(-7, -1 + bob, 14, 12), body_color.darkened(0.15))
	draw_rect(Rect2(-8, -10 + bob, 16, 10), Color("5b3829"))
	draw_rect(Rect2(-7, -9 + bob, 14, 6), Color("c1a46d"))
	draw_rect(Rect2(-5, -7 + bob, 3, 2), Color("e7dfb0"))
	draw_rect(Rect2(2, -7 + bob, 3, 2), Color("e7dfb0"))
	draw_rect(Rect2(-7, 10 + bob, 5, 4), Color("342d2d"))
	draw_rect(Rect2(2, 10 + bob, 5, 4), Color("342d2d"))
	for leaf in range(3):
		draw_colored_polygon(PackedVector2Array([
			Vector2(-7 + leaf * 7, -10 + bob), Vector2(-5 + leaf * 7, -17 + bob),
			Vector2(-1 + leaf * 7, -10 + bob)
		]), Color("43a35c"))
	draw_line(Vector2(4 * facing, -1 + bob), Vector2(20 * facing, -7 + bob), Color("bc9862"), 2.0, false)
	draw_colored_polygon(PackedVector2Array([
		Vector2(20 * facing, -7 + bob), Vector2(16 * facing, -9 + bob), Vector2(17 * facing, -4 + bob)
	]), Color("d4ded1"))
	if health == 1:
		draw_rect(Rect2(-2, -19, 4, 2), Color("e59678"))
