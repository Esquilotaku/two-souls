extends Node2D
class_name TunnelLayerPainter
## Repeating cave silhouettes for the remembered underground passage.

@export_range(0, 3) var layer_index: int = 0
@export var tint: Color = Color("111d27")
@export var accent: Color = Color("6ed6c6")

const SEGMENT_WIDTH := 960.0
const HEIGHT := 360.0

func _draw() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 5729 + layer_index * 9203
	if layer_index == 0:
		draw_rect(Rect2(0.0, 0.0, SEGMENT_WIDTH, HEIGHT), tint)
		for i in range(36):
			var x := random.randf_range(0.0, SEGMENT_WIDTH)
			var y := random.randf_range(72.0, HEIGHT - 18.0)
			draw_rect(Rect2(x, y, random.randi_range(2, 5), random.randi_range(2, 4)), tint.lightened(0.08))
	elif layer_index == 1:
		var roof := PackedVector2Array([Vector2(0.0, 0.0), Vector2(SEGMENT_WIDTH, 0.0)])
		for x in range(int(SEGMENT_WIDTH), -1, -24):
			var edge := 66.0 + sin(float(x) * 0.012) * 12.0 + random.randf_range(-9.0, 9.0)
			roof.append(Vector2(float(x), edge))
		draw_colored_polygon(roof, tint)
		for i in range(24):
			var x := random.randf_range(8.0, SEGMENT_WIDTH - 8.0)
			var width := random.randf_range(9.0, 23.0)
			var tip := random.randf_range(92.0, 162.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x - width, 42.0), Vector2(x + width, 42.0), Vector2(x + 3.0, tip)
			]), tint.darkened(random.randf_range(0.04, 0.17)))
	elif layer_index == 2:
		for i in range(11):
			var x := random.randf_range(0.0, SEGMENT_WIDTH)
			var width := random.randf_range(26.0, 58.0)
			var top := random.randf_range(165.0, 236.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x - width, HEIGHT), Vector2(x - width * 0.55, top + 22.0),
				Vector2(x, top), Vector2(x + width * 0.45, top + 15.0), Vector2(x + width, HEIGHT)
			]), tint.darkened(0.06))
			if i % 3 == 0:
				draw_rect(Rect2(x - 2.0, top + 28.0, 4.0, 3.0), accent.darkened(0.12))
	else:
		for i in range(17):
			var x := random.randf_range(12.0, SEGMENT_WIDTH - 12.0)
			var y := random.randf_range(94.0, 256.0)
			var size := random.randi_range(6, 15)
			var crystal := Color(accent, random.randf_range(0.48, 0.82))
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, y - size), Vector2(x + size * 0.55, y),
				Vector2(x, y + size), Vector2(x - size * 0.55, y)
			]), crystal)
		for i in range(8):
			var x := 34.0 + i * 119.0
			var root_y := random.randf_range(83.0, 138.0)
			draw_rect(Rect2(x, 0.0, 3.0, root_y), tint.lightened(0.12))
