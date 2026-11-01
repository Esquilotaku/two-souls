class_name WorldShrine
extends Node2D
## Santuário fixo (docs/plano-tecnico-mundo.md, seção 7). Só vale como ponto de volta depois de ativado.
## A origem fica no chão; o game.gd confere a distância e a tecla de interação.

const REACH := 56.0

var active := false:
	set(value):
		active = value
		queue_redraw()

func is_player_near(player_position: Vector2) -> bool:
	return absf(player_position.x - position.x) <= REACH and absf(player_position.y - (position.y - 33.0)) <= 48.0

func _draw() -> void:
	var stone := Color("3c5c5c") if active else Color("4a4f55")
	draw_colored_polygon(PackedVector2Array([Vector2(-14, 0), Vector2(-16, -44), Vector2(0, -60), Vector2(16, -44), Vector2(14, 0)]), stone)
	var mark := Color("b5fff0") if active else Color("7d8790")
	draw_colored_polygon(PackedVector2Array([Vector2(-4, -12), Vector2(-6, -36), Vector2(0, -46), Vector2(6, -36), Vector2(4, -12)]), mark)
	if active:
		draw_circle(Vector2(0, -40), 22.0, Color(0.5, 1.0, 0.9, 0.18))
