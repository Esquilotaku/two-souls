extends Node2D
class_name MagicBolt

var direction := 1
var empowered := false
var enemy_attack := false
var projectile_kind := "magic"
var speed := 270.0
var life := 1.6
var age := 0.0
var velocity_y := 0.0
var gravity := 0.0
var damage := 1

func _process(delta: float) -> void:
	age += delta
	position.x += direction * speed * delta
	velocity_y += gravity * delta
	position.y += velocity_y * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	if enemy_attack:
		var player := get_tree().get_first_node_in_group("player")
		var hit_radius := 17.0
		if projectile_kind == "meteor":
			hit_radius = 25.0
		elif projectile_kind == "root_spike":
			hit_radius = 30.0
		elif projectile_kind == "vine":
			hit_radius = 21.0
		if player and global_position.distance_to(player.global_position) < hit_radius:
			player.call("take_damage", damage)
			queue_free()
			return
	else:
		for target in get_tree().get_nodes_in_group("magic_target"):
			if not is_instance_valid(target):
				continue
			var hit_radius := float(target.get("magic_hit_radius"))
			if global_position.distance_to(target.global_position) < hit_radius:
				target.call("take_magic_hit", 2 if empowered else 1)
				queue_free()
				return
		for target in get_tree().get_nodes_in_group("hostile"):
			if is_instance_valid(target) and global_position.distance_to(target.global_position) < 24.0:
				target.take_hit(2 if empowered else 1)
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	if projectile_kind == "rock":
		draw_colored_polygon(PackedVector2Array([Vector2(-9, -3), Vector2(-5, -9), Vector2(4, -8), Vector2(10, -1), Vector2(6, 8), Vector2(-5, 7), Vector2(-10, 2)]), Color("777064"))
		draw_rect(Rect2(-4, -5, 5, 2), Color("c3b690"))
		return
	if projectile_kind == "spear":
		var back := Vector2(-14.0 * direction, 3.0)
		var tip := Vector2(14.0 * direction, -3.0)
		draw_line(back, tip, Color("c5a36c"), 3.0, false)
		draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-6.0 * direction, -3.0), tip + Vector2(-4.0 * direction, 4.0)]), Color("d8ded2"))
		return
	if projectile_kind == "meteor":
		draw_line(Vector2(0, 18), Vector2(0, -10), Color("ff7b3e", 0.72), 9.0, false)
		draw_circle(Vector2.ZERO, 10.0, Color("ff8150", 0.22))
		draw_colored_polygon(PackedVector2Array([Vector2(-6, -7), Vector2(-3, -12), Vector2(5, -10), Vector2(8, -2), Vector2(3, 6), Vector2(-6, 3)]), Color("f6a14d"))
		draw_rect(Rect2(-2, -7, 4, 5), Color("fff1a4"))
		return
	if projectile_kind == "root_spike":
		draw_line(Vector2(0, 12), Vector2(0, -14), Color("76508c"), 8.0, false)
		draw_colored_polygon(PackedVector2Array([Vector2(-7, -4), Vector2(0, -18), Vector2(7, -4)]), Color("a576bd"))
		draw_rect(Rect2(-12, 6, 8, 3), Color("5c4468"))
		draw_rect(Rect2(4, 3, 9, 3), Color("5c4468"))
		return
	if projectile_kind == "vine":
		var tail := Vector2(-16.0 * direction, 3.0)
		var tip := Vector2(16.0 * direction, -3.0)
		draw_line(tail, tip, Color("4e8350"), 5.0, false)
		draw_line(tail, tip, Color("93bd64"), 2.0, false)
		draw_colored_polygon(PackedVector2Array([
			tip, tip + Vector2(-7.0 * direction, -4.0), tip + Vector2(-5.0 * direction, 4.0)
		]), Color("b6d77a"))
		draw_rect(Rect2(-2, -6, 4, 3), Color("75a857"))
		return
	var radius := 5.0 if empowered else 3.0
	var hue := Color("9fffee") if empowered else Color("7fd6ea")
	draw_circle(Vector2.ZERO, radius + 6.0, Color(hue, 0.12))
	draw_rect(Rect2(-radius, -radius, radius * 2, radius * 2), hue)
	draw_rect(Rect2(-radius + 2, -radius + 2, 3, 3), Color.WHITE)
	if empowered:
		draw_rect(Rect2(-1, -radius - 5, 2, radius * 2 + 10), Color("c6fff1"))
