class_name WorldMinimap
extends Control
## Mapa revelado por áreas visitadas. Fica numa camada de interface independente.

const COMPACT_SIZE := Vector2(120.0, 70.0)
const COMPACT_MARGIN := Vector2(12.0, 12.0)
## Uma tela do jogo é 16:9; as áreas são desenhadas nessa proporção para não ficarem tortas.
const CELL_ASPECT := Vector2(16.0, 9.0)
## Pixels por unidade de proporção: mapa grande 2 (uma tela = 32x18 px), minimapa 1,25 (uma tela = 20x11 px).
const LARGE_UNIT := 2.0
const COMPACT_UNIT := 1.25
const DOOR_COLOR := Color("d9d5bc")
const GATE_COLOR := Color("f29b38")

var _visited: Dictionary = {}
var _current_room := ""
var _player_world_pos := Vector2.ZERO
var _abilities: Dictionary = {}
var _large_map := false
var _large_zoom := 1.0

func _ready() -> void:
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = COMPACT_SIZE
	# Áreas fora da caixa são cortadas (o mapa tem centenas de telas de largura).
	clip_contents = true
	_set_layout()

## Alimenta o mapa com os mesmos dados que o fluxo do jogo já mantém.
func update_view(visited: Dictionary, current_room: String, player_world_pos: Vector2, abilities: Dictionary) -> void:
	_visited = visited.duplicate()
	_current_room = current_room
	_player_world_pos = player_world_pos
	_abilities = abilities.duplicate()
	queue_redraw()

## O game pode chamar esta função ao abrir ou fechar a ação map (Tab).
func set_large_map(open: bool) -> void:
	_large_map = open
	_set_layout()
	queue_redraw()

func is_large_map_open() -> bool:
	return _large_map

func _set_layout() -> void:
	if _large_map:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		anchor_left = 1.0
		anchor_top = 1.0
		anchor_right = 1.0
		anchor_bottom = 1.0
		offset_left = -COMPACT_SIZE.x - 12.0
		offset_top = -COMPACT_SIZE.y - 12.0
		offset_right = -12.0
		offset_bottom = -12.0

## Lista de retângulos revelados em coordenadas do Control, usada também pelo teste.
func visible_rects() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for room_id in WorldMap.room_ids():
		if not _visited.has(room_id) or not bool(_visited[room_id]):
			continue
		var rect := _room_rect(room_id)
		if rect.size.x > 0.0 and rect.size.y > 0.0:
			var data: Dictionary = WorldMap.room(room_id)
			var region: Dictionary = WorldMap.REGIONS.get(data.get("region", ""), {})
			result.append({"id": room_id, "rect": rect, "color": Color(region.get("color", "ffffff"))})
	return result

## Converte dados de uma sala para um retângulo; útil para validar formatos extremos.
func rect_for_room(room_data: Dictionary) -> Rect2:
	var cell: Vector2i = room_data.get("cell", Vector2i.ZERO)
	var cells: Vector2i = room_data.get("size", Vector2i.ONE)
	var map_scale := _cell_scale()
	return Rect2(_map_point(Vector2(cell)), Vector2(cells) * map_scale)

func _process(_delta: float) -> void:
	if not _visited.is_empty():
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not _large_map:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_large_zoom = minf(_large_zoom * 1.2, 4.0)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_large_zoom = maxf(_large_zoom / 1.2, 0.35)
			queue_redraw()

func _draw() -> void:
	if _large_map:
		_draw_backdrop()
	else:
		# Moldura no estilo do HUD (scripts/ui/hud.gd).
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.1, 0.17, 0.85), true)
		draw_rect(Rect2(Vector2.ZERO, size), Color("8d9ab8"), false, 1.0)
	for item in visible_rects():
		var rect: Rect2 = item["rect"]
		draw_rect(rect, item["color"], true)
		draw_rect(rect, Color(0.07, 0.08, 0.08, 0.95), false, 1.0 if _large_map else 0.6)
		_draw_doors(item["id"])
		if item["id"] == _current_room:
			draw_rect(rect.grow(1.5 if _large_map else 0.75), Color("fff4cf"), false, 2.0 if _large_map else 1.0)
	_draw_player()

func _draw_backdrop() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.025, 0.025, 0.92), true)

func _room_rect(room_id: String) -> Rect2:
	return rect_for_room(WorldMap.room(room_id))

func _draw_doors(room_id: String) -> void:
	var data: Dictionary = WorldMap.room(room_id)
	var origin: Vector2 = Vector2(data.get("cell", Vector2i.ZERO))
	var extent: Vector2 = Vector2(data.get("size", Vector2i.ONE))
	for door: Dictionary in data.get("doors", []):
		var point := origin
		match door.get("side", ""):
			"east": point += Vector2(extent.x, int(door.get("row", 0)) + 0.5)
			"west": point += Vector2(0, int(door.get("row", 0)) + 0.5)
			"up": point += Vector2(int(door.get("col", 0)) + 0.5, 0)
			"down": point += Vector2(int(door.get("col", 0)) + 0.5, extent.y)
		var pixel := _map_point(point)
		var gate: String = door.get("gate", "")
		var blocked := gate != "" and not bool(_abilities.get(gate, false))
		var color := GATE_COLOR if blocked else DOOR_COLOR
		var radius := 3.0 if _large_map else 1.5
		draw_circle(pixel, radius, color)
		if blocked:
			var label := gate.substr(0, 1).to_upper()
			draw_string(ThemeDB.fallback_font, pixel + Vector2(3, -2), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 9 if _large_map else 6, color)

func _draw_player() -> void:
	if not _visited.has(_current_room) or not bool(_visited.get(_current_room, false)):
		return
	var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) / 180.0)
	var point := _map_point(_player_world_pos / WorldMap.SCREEN)
	draw_circle(point, (2.0 if _large_map else 1.2) + pulse * (1.5 if _large_map else 0.7), Color("fff7b0"))

## Tamanho de uma tela do jogo no mapa, sempre na proporção 16:9.
func _cell_scale() -> Vector2:
	return CELL_ASPECT * (LARGE_UNIT * _large_zoom if _large_map else COMPACT_UNIT)

## Os dois modos ficam centrados no Kaê: o mapa é largo demais para caber inteiro numa caixa pequena.
func _map_point(map_units: Vector2) -> Vector2:
	var center := _player_world_pos / WorldMap.SCREEN
	return size * 0.5 + (map_units - center) * _cell_scale()

