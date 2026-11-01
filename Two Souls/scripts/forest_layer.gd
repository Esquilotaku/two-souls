extends Node2D
class_name ForestLayerPainter
## Long side-scrolling silhouettes; each copy drifts at a different parallax speed.

@export_range(0, 3) var layer_index: int = 0
@export var tint: Color = Color("183d69")
@export var accent: Color = Color("36bed1")

const SEGMENT_WIDTH := 960.0
const HEIGHT := 360.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 1297 + layer_index * 8191
	var base_y: float = [182.0, 216.0, 258.0, 291.0][layer_index]
	var points := PackedVector2Array([Vector2(0, HEIGHT), Vector2(0, base_y)])
	for x in range(0, int(SEGMENT_WIDTH) + 16, 16):
		var wave := sin(float(x) * (0.009 + layer_index * 0.002) + layer_index) * (14.0 + layer_index * 7.0)
		var tooth := random.randf_range(-7.0, 7.0) if layer_index > 0 else 0.0
		points.append(Vector2(x, base_y + wave + tooth))
	points.append(Vector2(SEGMENT_WIDTH, HEIGHT))
	draw_colored_polygon(points, tint)

	if layer_index == 0:
		for i in range(7):
			var x := 36.0 + i * 148.0
			var peak := base_y - 22.0 - random.randf_range(0.0, 34.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(x - 82, HEIGHT), Vector2(x - 50, peak + 22),
				Vector2(x - 18, peak), Vector2(x + 16, peak + 15),
				Vector2(x + 48, peak - 3), Vector2(x + 88, HEIGHT)
			]), tint.lightened(0.11))
	elif layer_index == 1:
		for i in range(13):
			var x := 8.0 + i * 76.0
			var h := random.randf_range(48.0, 104.0)
			draw_rect(Rect2(x, base_y - h * 0.28, 9, h), tint.darkened(0.12))
			draw_rect(Rect2(x - 19, base_y - h * 0.62, 47, 26), tint)
			draw_rect(Rect2(x - 13, base_y - h * 0.80, 35, 23), tint)
	elif layer_index == 2:
		for i in range(19):
			var x := random.randf_range(0.0, SEGMENT_WIDTH)
			var h := random.randf_range(44.0, 122.0)
			draw_rect(Rect2(x, base_y - h * 0.35, 11, h), tint.darkened(0.08))
			for branch in range(3):
				var y := base_y - h * (0.62 + branch * 0.10)
				draw_rect(Rect2(x - 34 - branch * 4, y, 79 + branch * 8, 20), tint)
			draw_rect(Rect2(x - 20, base_y - h * 0.83, 47, 18), tint.lightened(0.06))
	else:
		for i in range(30):
			var x := random.randf_range(0.0, SEGMENT_WIDTH)
			var y := random.randf_range(base_y - 23.0, HEIGHT - 5.0)
			var color := accent if i % 3 == 0 else tint.lightened(random.randf_range(0.06, 0.28))
			draw_rect(Rect2(x, y, random.randi_range(3, 8), random.randi_range(3, 7)), color)
			if i % 5 == 0:
				draw_circle(Vector2(x + 3, y - 5), 4.0, Color(accent, 0.20))

	# Repeated root and branch highlights give the layers a hand-built pixel-art edge.
	if layer_index > 0:
		for i in range(9):
			var x := 24.0 + i * 109.0
			var y := base_y + 8.0 + (i % 3) * 12.0
			draw_rect(Rect2(x, y, 14, 3), Color(accent, 0.38))
