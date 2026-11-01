extends StaticBody2D
## Temporary world obstacle that can be cleared with Orion's magic or spear.

var health := 3
var hit_flash := 0.0
var age := 0.0
var magic_hit_radius := 36.0

func _ready() -> void:
	add_to_group("magic_target")
	add_to_group("attackable_scenery")
	collision_layer = 1
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(52.0, 96.0)
	collision.shape = shape
	add_child(collision)

func _process(delta: float) -> void:
	age += delta
	hit_flash = maxf(0.0, hit_flash - delta)
	queue_redraw()

func take_magic_hit(amount: int) -> void:
	_take_damage(maxi(1, amount + 1))

func take_hit(amount: int) -> void:
	_take_damage(amount)

func _take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	hit_flash = 0.18
	if health <= 0:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var bark := Color("fff0d0") if hit_flash > 0.0 else Color("493b4b")
	var root_color := Color("f4c6ff") if hit_flash > 0.0 else Color("83528e")
	var pulse := 0.12 + (sin(age * 3.2) + 1.0) * 0.06
	draw_rect(Rect2(-34.0, 43.0, 68.0, 8.0), Color(0.02, 0.04, 0.08, 0.48))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-24.0, 48.0), Vector2(-28.0, 27.0), Vector2(-15.0, 12.0),
		Vector2(-23.0, -8.0), Vector2(-9.0, -24.0), Vector2(-4.0, -4.0),
		Vector2(4.0, -45.0), Vector2(13.0, -21.0), Vector2(21.0, -35.0),
		Vector2(19.0, -7.0), Vector2(29.0, 11.0), Vector2(17.0, 28.0), Vector2(25.0, 48.0)
	]), bark)
	draw_line(Vector2(-18.0, 37.0), Vector2(-6.0, 15.0), root_color, 5.0, false)
	draw_line(Vector2(17.0, 38.0), Vector2(5.0, 14.0), root_color, 5.0, false)
	draw_line(Vector2(-6.0, 16.0), Vector2(-17.0, -1.0), bark.lightened(0.18), 4.0, false)
	draw_line(Vector2(5.0, 13.0), Vector2(20.0, -4.0), bark.lightened(0.18), 4.0, false)
	draw_circle(Vector2(0.0, 2.0), 12.0, Color("a957c6", pulse))
	draw_rect(Rect2(-4.0, -5.0, 8.0, 14.0), Color("d39be3") if hit_flash <= 0.0 else Color("fff4dc"))
	draw_rect(Rect2(-1.0, -2.0, 2.0, 8.0), Color("fff0b8"))
	for thorn_x in [-18.0, -8.0, 10.0, 20.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(thorn_x - 4.0, 8.0), Vector2(thorn_x, -2.0), Vector2(thorn_x + 4.0, 8.0)
		]), root_color.darkened(0.12))
	if health < 3:
		draw_line(Vector2(-18.0, -22.0), Vector2(-7.0, -10.0), Color("261e31"), 2.0, false)
	if health < 2:
		draw_line(Vector2(14.0, -25.0), Vector2(4.0, -12.0), Color("261e31"), 2.0, false)
