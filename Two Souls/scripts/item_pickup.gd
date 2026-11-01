extends Node2D
class_name ItemPickup
## A collectible consumable. Artwork and collection range are prototype values.

const ITEM_CATALOG = preload("res://scripts/item_catalog.gd")

var item_id := "luminous_herb"
var pickup_id := ""
var age := 0.0
var drift := Vector2(0.0, -20.0)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = 12

func _process(delta: float) -> void:
	age += delta
	drift = drift.move_toward(Vector2.ZERO, 70.0 * delta)
	position += drift * delta
	var player := get_tree().get_first_node_in_group("player")
	if player and bool(player.get("active")):
		var target: Vector2 = player.global_position + Vector2(0.0, -4.0)
		var distance := global_position.distance_to(target)
		if distance < 62.0:
			global_position = global_position.move_toward(target, 190.0 * delta)
			if distance < 18.0 and bool(player.call("add_item", item_id, 1, pickup_id)):
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	var definition := ITEM_CATALOG.get_definition(item_id)
	if definition.is_empty():
		return
	var color := Color(str(definition["color"]))
	var pulse := 0.72 + sin(age * 6.0) * 0.16
	draw_circle(Vector2.ZERO, 13.0, Color(color, 0.12 * pulse))
	if item_id == "luminous_herb":
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, 8), Vector2(-8, 0), Vector2(-6, -7), Vector2(0, -3),
			Vector2(6, -8), Vector2(8, 0)
		]), color)
		draw_line(Vector2(0, 8), Vector2(0, -7), Color("e8ffd9"), 2.0, false)
	else:
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, -10), Vector2(7, -4), Vector2(5, 6), Vector2(0, 10),
			Vector2(-5, 6), Vector2(-7, -4)
		]), color)
		draw_rect(Rect2(-2, -5, 3, 9), Color("e5ffff"))
	draw_rect(Rect2(-1, -2, 2, 4), Color.WHITE)
