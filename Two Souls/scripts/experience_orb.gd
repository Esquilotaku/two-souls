extends Node2D
class_name ExperienceOrb
## A small essence pickup. Its art and values are prototype placeholders.

var amount := 12
var age := 0.0
var drift := Vector2(0.0, -22.0)

const MAGNET_RANGE := 86.0
const MAGNET_SPEED := 250.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = 12

func _process(delta: float) -> void:
	age += delta
	drift = drift.move_toward(Vector2.ZERO, 75.0 * delta)
	position += drift * delta

	var player := get_tree().get_first_node_in_group("player")
	if player and player.get("active"):
		var target: Vector2 = player.global_position + Vector2(0.0, -4.0)
		var distance := global_position.distance_to(target)
		if distance < MAGNET_RANGE:
			global_position = global_position.move_toward(target, MAGNET_SPEED * delta)
			if distance < 17.0:
				player.call("gain_experience", amount)
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	var pulse := 0.68 + sin(age * 7.0) * 0.18
	var bob := sin(age * 5.0) * 1.5
	var essence := Color("8cf6ee")
	draw_rect(Rect2(-7, -7 + bob, 14, 14), Color(essence, 0.13 * pulse))
	draw_rect(Rect2(-4, -6 + bob, 8, 12), Color("35b9c8"))
	draw_rect(Rect2(-2, -4 + bob, 4, 8), Color("baffee"))
	draw_rect(Rect2(-1, -2 + bob, 2, 3), Color.WHITE)
