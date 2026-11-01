class_name WorldScene
extends Node2D
## O mapa inteiro numa cena só (decisão do Gabriel, 01/11/2026): cada área de WorldMap é montada
## por WorldRoom na posição real do mapa (célula x tamanho da tela). As aberturas das portas de
## áreas vizinhas se encontram, então o jogador anda de uma para outra sem tela preta.

const ROCK_COLOR := Color("0d1014")
const ROCK_MARGIN := 960.0

var rooms: Dictionary = {}          # id -> WorldRoom
var cell_to_room: Dictionary = {}   # Vector2i -> id
var bounds := Rect2()

func build(abilities: Dictionary, activated_shrines: Dictionary, collected_pickups: Callable) -> void:
	name = "World"
	var first := true
	for room_id: String in WorldMap.room_ids():
		var data := WorldMap.room(room_id)
		var cell: Vector2i = data["cell"]
		var size: Vector2i = data["size"]
		for x in range(size.x):
			for y in range(size.y):
				cell_to_room[Vector2i(cell.x + x, cell.y + y)] = room_id
		var origin := Vector2(cell.x * WorldMap.SCREEN.x, cell.y * WorldMap.SCREEN.y)
		var area := Rect2(origin, WorldMap.room_pixel_size(room_id))
		bounds = area if first else bounds.merge(area)
		first = false
		var room := WorldRoom.new()
		room.position = origin
		add_child(room)
		room.build(room_id, abilities, activated_shrines, collected_pickups)
		rooms[room_id] = room
	# Rocha escura em volta e entre as áreas: o que não é área é chão maciço.
	var rock := Polygon2D.new()
	var outer := bounds.grow(ROCK_MARGIN)
	rock.polygon = PackedVector2Array([outer.position, Vector2(outer.end.x, outer.position.y), outer.end, Vector2(outer.position.x, outer.end.y)])
	rock.color = ROCK_COLOR
	rock.z_index = -30
	add_child(rock)
	move_child(rock, 0)

func room(room_id: String) -> WorldRoom:
	return rooms.get(room_id, null)

## Área que contém um ponto do mundo ("" se o ponto estiver na rocha, fora de qualquer área).
func room_at(point: Vector2) -> String:
	var cell := Vector2i(floori(point.x / WorldMap.SCREEN.x), floori(point.y / WorldMap.SCREEN.y))
	return cell_to_room.get(cell, "")

## Converte um ponto local de uma área para o mundo.
func to_world(room_id: String, local_point: Vector2) -> Vector2:
	return rooms[room_id].position + local_point

## Tira os bloqueios das habilidades que o jogador já tem, em todas as áreas.
func refresh_gates(abilities: Dictionary) -> void:
	for room_id in rooms:
		rooms[room_id].refresh_gates(abilities)
