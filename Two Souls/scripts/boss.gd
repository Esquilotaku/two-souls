extends CharacterBody2D
class_name CorruptedBoss

const EXPERIENCE_ORB_SCRIPT = preload("res://scripts/experience_orb.gd")
const THE_ROCK_ART: Texture2D = preload("res://assets/sprites/the_rock_idle.png")

signal defeated

var boss_name := "Guardião Corrompido"
var boss_id := "generic"
var encounter_tier := "major"
var variant := 0
var health := 12
var max_health := 12
var experience_reward := 80
var floor_y := 304.0
var age := 0.0
var hit_flash := 0.0
var attack_timer := 1.2
var attack_state := "idle"
var attack_state_timer := 0.0
var horn_cooldown := 4.0
var meteor_cooldown := 6.0
var meteor_target_x := 0.0
var tree_attack_index := 0
var tree_target_x := 0.0
var is_ally := false
var direction := -1

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if is_ally:
		add_to_group("friendly")
		collision_layer = 0
		collision_mask = 0
	else:
		add_to_group("hostile")
		collision_layer = 1
		collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	# Chefes têm super armadura: não implementam apply_knockback; seus tamanhos destacam-se ao lado do Kaê (72 px).
	shape.size = Vector2(88, 116) if boss_id == "the_rock" else (Vector2(64, 58) if boss_id == "hooded_sorcerer" else Vector2(52, 48))
	collision.shape = shape
	if boss_id == "the_rock":
		collision.position = Vector2(0.0, -34.0)
	elif boss_id == "hooded_sorcerer":
		collision.position = Vector2(0.0, -5.0)
	add_child(collision)

func _physics_process(delta: float) -> void:
	age += delta
	hit_flash = maxf(0.0, hit_flash - delta)
	if boss_id == "the_rock":
		_physics_process_the_rock(delta)
		return
	if boss_id == "corrupted_tree":
		_physics_process_corrupted_tree(delta)
		return
	if boss_id == "hooded_sorcerer":
		_physics_process_hooded_sorcerer(delta)
		return
	attack_timer -= delta
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var toward := signf(player.global_position.x - global_position.x)
		if absf(player.global_position.x - global_position.x) > 110.0:
			velocity.x = toward * (44.0 + (1.0 - float(health) / max_health) * 28.0)
			direction = int(toward)
		elif attack_timer <= 0.0:
			_attack(player)
			attack_timer = 1.5 if health > max_health / 2 else 1.05
	if not is_on_floor():
		velocity.y += 980.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	queue_redraw()

func _physics_process_corrupted_tree(delta: float) -> void:
	velocity.x = 0.0
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var horizontal_distance: float = player.global_position.x - global_position.x
		if absf(horizontal_distance) > 1.0:
			direction = 1 if horizontal_distance > 0.0 else -1
		if attack_state == "idle":
			attack_timer -= delta
			if attack_timer <= 0.0:
				_begin_tree_attack(player)
		else:
			attack_state_timer -= delta
			if attack_state_timer <= 0.0:
				if attack_state == "recovery":
					attack_state = "idle"
					attack_timer = 0.85
				elif attack_state == "root_warning":
					_spawn_root_spike()
					attack_state = "recovery"
					attack_state_timer = 0.8
				elif attack_state == "vine_warning":
					_spawn_vines()
					attack_state = "recovery"
					attack_state_timer = 0.9
	if not is_on_floor():
		velocity.y += 980.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	queue_redraw()

func _begin_tree_attack(player: Node) -> void:
	if tree_attack_index % 2 == 0:
		attack_state = "root_warning"
		tree_target_x = clampf(player.global_position.x, 48.0, 2652.0)
		attack_state_timer = 0.82
	else:
		attack_state = "vine_warning"
		attack_state_timer = 0.78
	tree_attack_index += 1

func _spawn_root_spike() -> void:
	var root_spike := MagicBolt.new()
	root_spike.enemy_attack = true
	root_spike.projectile_kind = "root_spike"
	root_spike.direction = 0
	root_spike.speed = 0.0
	root_spike.life = 0.34
	root_spike.position = Vector2(tree_target_x, floor_y - 16.0)
	get_parent().add_child(root_spike)

func _spawn_vines() -> void:
	for vine_direction in [-1, 1]:
		var vine := MagicBolt.new()
		vine.enemy_attack = true
		vine.projectile_kind = "vine"
		vine.direction = vine_direction
		vine.speed = 148.0
		vine.life = 1.7
		vine.position = global_position + Vector2(vine_direction * 30.0, -22.0)
		get_parent().add_child(vine)

func _physics_process_the_rock(delta: float) -> void:
	horn_cooldown = maxf(0.0, horn_cooldown - delta)
	var player := get_tree().get_first_node_in_group("player")
	if is_ally:
		if player:
			var player_facing := int(player.get("facing"))
			var follow_x: float = player.global_position.x - player_facing * 48.0
			var follow_offset := follow_x - global_position.x
			var follow_speed := clampf(follow_offset * 2.5, -92.0, 92.0)
			velocity.x = move_toward(velocity.x, follow_speed, 420.0 * delta)
			if absf(player.global_position.x - global_position.x) > 1.0:
				direction = 1 if player.global_position.x > global_position.x else -1
		else:
			velocity.x = move_toward(velocity.x, 0.0, 420.0 * delta)
		if not is_on_floor():
			velocity.y += 980.0 * delta
		else:
			velocity.y = 0.0
		move_and_slide()
		queue_redraw()
		return
	if player:
		var horizontal_distance: float = player.global_position.x - global_position.x
		var distance := absf(horizontal_distance)
		if absf(horizontal_distance) > 1.0:
			direction = 1 if horizontal_distance > 0.0 else -1
		if attack_state == "idle":
			velocity.x = direction * 36.0 if distance > 105.0 else 0.0
			attack_timer -= delta
			if attack_timer <= 0.0:
				_begin_rock_attack(player, distance)
		else:
			velocity.x = 0.0
			attack_state_timer -= delta
			if attack_state_timer <= 0.0:
				if attack_state == "recovery":
					attack_state = "idle"
					attack_timer = 0.5
				else:
					_resolve_rock_attack(player)
					attack_state = "recovery"
					attack_state_timer = 0.82
	else:
		velocity.x = 0.0
	if not is_on_floor():
		velocity.y += 980.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	queue_redraw()

func _begin_rock_attack(player: Node, distance: float) -> void:
	if horn_cooldown <= 0.0 and _rock_summon_count() < 2:
		attack_state = "trumpet"
		attack_state_timer = 0.95
		horn_cooldown = 9.0
	elif distance < 112.0:
		attack_state = "punch"
		attack_state_timer = 0.48
	else:
		attack_state = "rock"
		attack_state_timer = 0.58

func _resolve_rock_attack(player: Node) -> void:
	if attack_state == "punch":
		if absf(player.global_position.x - global_position.x) < 122.0 and absf(player.global_position.y - global_position.y) < 60.0:
			player.call("take_damage", 1)
			player.set("velocity", Vector2(direction * 510.0, -375.0))
	elif attack_state == "rock":
		var projectile := MagicBolt.new()
		projectile.enemy_attack = true
		projectile.projectile_kind = "rock"
		projectile.direction = direction
		projectile.speed = 178.0
		projectile.velocity_y = -142.0
		projectile.gravity = 390.0
		projectile.life = 2.1
		projectile.position = global_position + Vector2(direction * 28.0, -12.0)
		get_parent().add_child(projectile)
	elif attack_state == "trumpet":
		_summon_spear_tribal()

func _summon_spear_tribal() -> void:
	if _rock_summon_count() >= 2 or not get_parent():
		return
	var spearman := ForestFoe.new()
	spearman.position = global_position + Vector2(-direction * 56.0, -6.0)
	spearman.health = 3
	spearman.experience_reward = 18
	spearman.speed = 24.0
	spearman.patrol_span = 92.0
	spearman.ranged = true
	spearman.tribal = true
	spearman.is_rock_summon = true
	spearman.add_to_group("rock_summon")
	get_parent().add_child(spearman)
	var game_controller := get_tree().get_first_node_in_group("game_controller")
	if game_controller:
		spearman.set_time_difficulty(float(game_controller.call("_night_pressure")))

func _rock_summon_count() -> int:
	var count := 0
	for minion in get_tree().get_nodes_in_group("rock_summon"):
		if is_instance_valid(minion) and not minion.is_queued_for_deletion():
			count += 1
	return count

func _spawn_meteor() -> void:
	var meteor := MagicBolt.new()
	meteor.enemy_attack = true
	meteor.projectile_kind = "meteor"
	meteor.direction = 0
	meteor.speed = 0.0
	meteor.gravity = 690.0
	meteor.life = 1.35
	meteor.damage = 1
	meteor.position = Vector2(meteor_target_x, floor_y - 320.0)
	get_parent().add_child(meteor)

func _physics_process_hooded_sorcerer(delta: float) -> void:
	meteor_cooldown = maxf(0.0, meteor_cooldown - delta)
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var horizontal_distance: float = player.global_position.x - global_position.x
		var distance := absf(horizontal_distance)
		if absf(horizontal_distance) > 1.0:
			direction = 1 if horizontal_distance > 0.0 else -1
		if attack_state == "idle":
			velocity.x = direction * 24.0 if distance > 185.0 else 0.0
			attack_timer -= delta
			if attack_timer <= 0.0:
				if health <= max_health * 0.62 and meteor_cooldown <= 0.0:
					attack_state = "meteor_warning"
					attack_state_timer = 1.0
					meteor_cooldown = 5.4
					meteor_target_x = clampf(player.global_position.x, 48.0, 2652.0)
				elif distance < 150.0:
					attack_state = "claw_warning"
					attack_state_timer = 0.58
				else:
					attack_state = "orb_warning"
					attack_state_timer = 0.52
		else:
			velocity.x = 0.0
			attack_state_timer -= delta
			if attack_state_timer <= 0.0:
				if attack_state == "recovery":
					attack_state = "idle"
					attack_timer = 0.42
				elif attack_state == "meteor_warning":
					_spawn_meteor()
					attack_state = "recovery"
					attack_state_timer = 0.9
				elif attack_state == "claw_warning":
					_resolve_hooded_claw(player)
					attack_state = "recovery"
					attack_state_timer = 0.78
				else:
					_spawn_hooded_orb(player)
					attack_state = "recovery"
					attack_state_timer = 0.72
	else:
		velocity.x = 0.0
	if not is_on_floor():
		velocity.y += 980.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	queue_redraw()

func _resolve_hooded_claw(player: Node) -> void:
	if absf(player.global_position.x - global_position.x) < 158.0 and absf(player.global_position.y - global_position.y) < 72.0:
		player.call("take_damage", 1)
		player.set("velocity", Vector2(direction * 555.0, -435.0))

func _spawn_hooded_orb(player: Node) -> void:
	var bolt := MagicBolt.new()
	bolt.direction = int(signf(player.global_position.x - global_position.x))
	bolt.position = global_position + Vector2(bolt.direction * 24.0, -27.0)
	bolt.empowered = true
	bolt.enemy_attack = true
	bolt.speed = 208.0
	get_parent().add_child(bolt)

func _attack(player: Node) -> void:
	var distance := absf(player.global_position.x - global_position.x)
	if distance < 150.0:
		player.call("take_damage", 1)
		player.set("velocity", Vector2(-direction * 300.0, -540.0))
	else:
		var bolt: MagicBolt = MagicBolt.new()
		bolt.direction = int(signf(player.global_position.x - global_position.x))
		bolt.position = global_position + Vector2(bolt.direction * 24, -10)
		bolt.empowered = variant == 2
		bolt.enemy_attack = true
		bolt.speed = 170.0
		get_parent().add_child(bolt)

func take_hit(amount: int) -> void:
	if is_ally:
		return
	health = maxi(0, health - amount)
	hit_flash = 0.16
	if health <= 0:
		_drop_experience()
		if boss_id == "the_rock":
			is_ally = true
			remove_from_group("hostile")
			add_to_group("friendly")
			collision_layer = 0
			collision_mask = 0
			attack_state = "idle"
			defeated.emit()
		else:
			defeated.emit()
			queue_free()

func _drop_experience() -> void:
	if experience_reward <= 0 or not get_parent():
		return
	var orb = EXPERIENCE_ORB_SCRIPT.new()
	orb.amount = experience_reward
	get_parent().add_child(orb)
	orb.global_position = global_position + Vector2(0.0, -16.0)

func _draw() -> void:
	if boss_id == "the_rock":
		_draw_the_rock()
		return
	if boss_id == "corrupted_tree":
		_draw_corrupted_tree()
		return
	if boss_id == "hooded_sorcerer":
		_draw_hooded_sorcerer()
		return
	var main: Color = [Color("719d5a"), Color("75518f"), Color("242c46")][variant]
	var light: Color = [Color("b7e276"), Color("cf8cc3"), Color("793da4")][variant]
	if hit_flash > 0.0:
		main = Color("fff4ca")
	var bob := int(sin(age * 3.0) * 2.0)
	draw_rect(Rect2(-28, 20, 56, 6), Color(0.02, 0.04, 0.08, 0.55))
	# Broad shoulders and body silhouette read clearly at the game's small resolution.
	draw_rect(Rect2(-23, -19 + bob, 46, 40), main)
	draw_rect(Rect2(-18, -26 + bob, 37, 17), main.lightened(0.1))
	draw_rect(Rect2(-30, -12 + bob, 15, 21), main.darkened(0.1))
	draw_rect(Rect2(15, -12 + bob, 15, 21), main.darkened(0.1))
	draw_rect(Rect2(-17, 16 + bob, 13, 12), main.darkened(0.25))
	draw_rect(Rect2(5, 16 + bob, 13, 12), main.darkened(0.25))
	# Mask, eyes, and corruption veins.
	draw_rect(Rect2(-16, -15 + bob, 32, 11), Color("25283a"))
	draw_rect(Rect2(-12, -12 + bob, 6, 4), light)
	draw_rect(Rect2(6, -12 + bob, 6, 4), light)
	draw_rect(Rect2(-2, 1 + bob, 4, 17), light.darkened(0.1))
	for i in range(4):
		draw_rect(Rect2(-22 + i * 12, -28 + bob, 5, 4), light)
	# A thin health indicator stays readable above the silhouette.
	draw_rect(Rect2(-24, -39, 48, 4), Color("20263a"))
	draw_rect(Rect2(-23, -38, 46.0 * float(health) / max_health, 2), Color("ee8292"))

func _draw_the_rock() -> void:
	var bob := int(sin(age * 3.2) * 2.0)
	var sprite_tint := Color.WHITE if hit_flash <= 0.0 else Color("fff2ce")
	draw_rect(Rect2(-54, 20, 108, 8), Color(0.02, 0.04, 0.08, 0.52))
	draw_texture_rect(THE_ROCK_ART, Rect2(-58, -100 + bob, 116, 124), false, sprite_tint)
	if attack_state == "trumpet":
		var horn_mouth := Vector2(52, -82 + bob)
		for wave in range(3):
			var radius := 8.0 + float(wave) * 6.0
			draw_arc(horn_mouth, radius, -0.7, 0.7, 12, Color("9ef5df", 0.8 - wave * 0.18), 2.0, false)
	if attack_state == "punch":
		draw_arc(Vector2(-43, -40 + bob), 15.0, -0.95, 0.95, 10, Color("fff0a0"), 3.0, false)
	if is_ally:
		draw_colored_polygon(PackedVector2Array([Vector2(-4, -108), Vector2(0, -116), Vector2(4, -108)]), Color("baffdf"))
	else:
		draw_rect(Rect2(-37, -108, 74, 5), Color("20263a"))
		draw_rect(Rect2(-36, -107, 72.0 * float(health) / max_health, 3), Color("ed9a68"))

func _draw_hooded_sorcerer() -> void:
	var bob := int(sin(age * 2.7) * 2.0)
	var cloak := Color("26313b") if hit_flash <= 0.0 else Color("fff2ce")
	var scales := Color("47665b") if hit_flash <= 0.0 else Color("fff2ce")
	draw_rect(Rect2(-30, 24, 60, 6), Color(0.02, 0.04, 0.08, 0.55))
	draw_colored_polygon(PackedVector2Array([Vector2(-15, -22 + bob), Vector2(-31, 2 + bob), Vector2(-24, 23), Vector2(25, 23), Vector2(31, 1 + bob), Vector2(13, -22 + bob)]), cloak)
	draw_colored_polygon(PackedVector2Array([Vector2(-13, -1 + bob), Vector2(-35, 8 + bob), Vector2(-49, 15), Vector2(-27, 17), Vector2(-10, 12 + bob)]), Color("1a2730"))
	# The hood hides most of a narrow reptilian face; scales and a long tail keep the silhouette nonhuman.
	draw_rect(Rect2(-17, -31 + bob, 34, 25), scales)
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -28 + bob), Vector2(-16, -49 + bob), Vector2(-4, -58 + bob), Vector2(8, -54 + bob), Vector2(20, -37 + bob), Vector2(14, -22 + bob), Vector2(-14, -22 + bob)]), Color("121d29"))
	draw_colored_polygon(PackedVector2Array([Vector2(-9, -28 + bob), Vector2(10, -30 + bob), Vector2(8, -12 + bob), Vector2(0, -6 + bob), Vector2(-8, -14 + bob)]), Color("738c68"))
	draw_rect(Rect2(-10, -25 + bob, 5, 3), Color("f7bd6d"))
	draw_rect(Rect2(5, -26 + bob, 5, 3), Color("f7bd6d"))
	draw_colored_polygon(PackedVector2Array([Vector2(-8, 2 + bob), Vector2(-34, 11), Vector2(-55, 14), Vector2(-43, 20), Vector2(-16, 16 + bob)]), Color("314c45"))
	for i in range(4):
		draw_rect(Rect2(-12 + i * 8, -5 + bob, 4, 4), Color("6b8f6d"))
	if attack_state == "meteor_warning":
		var marker_x := meteor_target_x - global_position.x
		var marker_y := floor_y - global_position.y
		draw_rect(Rect2(marker_x - 18, marker_y - 5, 36, 4), Color("ff936d", 0.95))
		draw_rect(Rect2(marker_x - 2, marker_y - 14, 4, 7), Color("fff0a0", 0.9))
	elif attack_state == "claw_warning":
		draw_arc(Vector2(direction * 24.0, -16.0 + bob), 23.0, -0.8, 0.8, 12, Color("b6f0cb"), 3.0, false)
	elif attack_state == "orb_warning":
		draw_circle(Vector2(direction * 23.0, -29.0 + bob), 7.0, Color("a8f4d0", 0.9))
	draw_rect(Rect2(-24, -67, 48, 4), Color("20263a"))
	draw_rect(Rect2(-23, -66, 46.0 * float(health) / max_health, 2), Color("ee8292"))

func _draw_corrupted_tree() -> void:
	var bob := int(sin(age * 2.1) * 1.0)
	var bark := Color("50403c") if hit_flash <= 0.0 else Color("fff0ce")
	var corruption := Color("8a5aa0")
	draw_rect(Rect2(-42, 20, 84, 8), Color(0.02, 0.04, 0.08, 0.52))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24, 22), Vector2(-28, 4), Vector2(-17, -13), Vector2(-20, -35 + bob),
		Vector2(-7, -49 + bob), Vector2(9, -45 + bob), Vector2(20, -29 + bob),
		Vector2(17, -5), Vector2(29, 22)
	]), bark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24, -31 + bob), Vector2(-35, -48 + bob), Vector2(-27, -64 + bob),
		Vector2(-11, -58 + bob), Vector2(-5, -75 + bob), Vector2(10, -63 + bob),
		Vector2(27, -69 + bob), Vector2(32, -48 + bob), Vector2(20, -32 + bob)
	]), bark.darkened(0.08))
	# Branches and exposed roots make the tree silhouette readable at gameplay scale.
	draw_line(Vector2(-13, -30 + bob), Vector2(-37, -48 + bob), bark.lightened(0.18), 7.0, false)
	draw_line(Vector2(13, -30 + bob), Vector2(38, -49 + bob), bark.lightened(0.18), 7.0, false)
	draw_line(Vector2(-31, 21), Vector2(-50, 29), corruption, 6.0, false)
	draw_line(Vector2(-10, 22), Vector2(-25, 35), corruption, 6.0, false)
	draw_line(Vector2(10, 22), Vector2(27, 35), corruption, 6.0, false)
	draw_line(Vector2(31, 21), Vector2(52, 29), corruption, 6.0, false)
	draw_rect(Rect2(-17, -36 + bob, 11, 5), Color("dca3ff"))
	draw_rect(Rect2(6, -36 + bob, 11, 5), Color("dca3ff"))
	draw_rect(Rect2(-2, -25 + bob, 5, 15), corruption)
	draw_rect(Rect2(-29, -82, 58, 5), Color("20263a"))
	draw_rect(Rect2(-28, -81, 56.0 * float(health) / max_health, 3), Color("c98bd6"))
	if attack_state == "root_warning":
		var marker_x := tree_target_x - global_position.x
		var marker_y := floor_y - global_position.y
		draw_rect(Rect2(marker_x - 17, marker_y - 4, 34, 4), Color("c895e2", 0.92))
		draw_line(Vector2(-3, 18), Vector2(marker_x, marker_y - 8), Color("a96dca", 0.8), 3.0, false)
	elif attack_state == "vine_warning":
		draw_rect(Rect2(-39, -52 + bob, 8, 5), Color("bcf279"))
		draw_rect(Rect2(31, -52 + bob, 8, 5), Color("bcf279"))
