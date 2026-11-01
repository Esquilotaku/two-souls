extends Node2D
class_name TerrainPainter

@export var world_width: float = 2600.0
@export var floor_y: float = 304.0
@export var ground: Color = Color("172e39")
@export var grass: Color = Color("64bc83")
@export var glow: Color = Color("63d9ce")

func _draw() -> void:
	draw_rect(Rect2(0, floor_y, world_width, 200), ground)
	draw_rect(Rect2(0, floor_y, world_width, 7), grass)
	var random := RandomNumberGenerator.new()
	random.seed = 7001
	for x in range(0, int(world_width), 24):
		draw_rect(Rect2(x, floor_y + 10, 20, 3), ground.lightened(0.16))
		if x % 72 == 0:
			draw_rect(Rect2(x + 6, floor_y + 18, 3, 3), glow.darkened(0.1))
		if random.randf() < 0.34:
			draw_rect(Rect2(x + random.randi_range(0, 17), floor_y - random.randi_range(3, 8), 3, 5), grass.lightened(0.15))
