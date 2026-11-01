class_name WorldRoom
extends Node2D
## Monta uma sala em blocos cinzas a partir de WorldMap (docs/tecnico/plano-tecnico-mundo.md, seções 3 a 5).
## A sala fica com a origem em (0, 0); o game.gd carrega uma sala por vez.

const DOOR_OPENING := 128.0
const DOOR_TRIGGER := 24.0
const STEP_HEIGHT := 130.0
const STEP_WIDTH := 112.0
const UP_LANDING_Y := 104.0
## Relevo: espaço livre perto de portas, buracos, santuário e altar para não bloquear passagem.
const RELIEF_CLEARANCE := 200.0
const ITEM_PICKUP_SCRIPT = preload("res://scripts/item_pickup.gd")

var room_id := ""
var data: Dictionary = {}
var size_px := Vector2.ZERO
## Portas com a área de disparo e o ponto de chegada: [{"door": Dictionary, "rect": Rect2, "arrival": Vector2}]
var door_triggers: Array[Dictionary] = []
var gates: Array[Dictionary] = []
var shrine: WorldShrine
var altar_rect := Rect2()
var boss: Node2D

var _region_color := Color("3f6b4f")
var _solid_color := Color("5b6670")

## abilities e activated_shrines são conjuntos (Dictionary id -> true) do estado do jogo.
## O chefe não nasce aqui: o mundo chama spawn_boss() quando o jogador entra na área.
func build(id: String, abilities: Dictionary, activated_shrines: Dictionary, collected_pickups: Callable) -> void:
	room_id = id
	name = "Room_" + id
	data = WorldMap.room(id)
	size_px = WorldMap.room_pixel_size(id)
	_region_color = Color(WorldMap.REGIONS[data["region"]]["color"])
	_solid_color = _region_color.lerp(Color("8a939b"), 0.55)
	_add_background()
	_add_shell()
	_add_platforms()
	_add_relief()
	_add_doors(abilities)
	if data.has("shrine"):
		_add_shrine(float(data["shrine"]), activated_shrines.has(room_id))
	if data.has("altar") and data.has("grants") and not abilities.has(data["grants"]):
		_add_altar(float(data["altar"]), data["grants"])
	if data.has("rune") and not collected_pickups.call("rune:" + data["rune"]):
		_add_rune_stone(data["rune"])
	_add_pickups(collected_pickups)
	_add_foes()

## Faz o chefe da área aparecer (se ela tiver um e ele ainda não foi vencido). Devolve o chefe ou null.
func spawn_boss(defeated_bosses: Dictionary) -> Node2D:
	if boss and is_instance_valid(boss):
		return boss
	if not data.has("boss") or defeated_bosses.has(data["boss"]):
		return null
	_add_boss(data["boss"])
	return boss

## Tira o chefe quando o jogador sai da área sem vencê-lo; ele volta inteiro na próxima entrada.
func despawn_boss() -> void:
	if boss and is_instance_valid(boss):
		boss.queue_free()
	boss = null

func contains_local(point: Vector2) -> bool:
	return Rect2(Vector2.ZERO, size_px).has_point(point)

func floor_y() -> float:
	return size_px.y - WorldMap.FLOOR_THICKNESS

## Ponto de chegada do jogador (centro da colisão) ao entrar pela porta door_id.
func arrival_point(door_id: String) -> Vector2:
	for trigger in door_triggers:
		if trigger["door"]["id"] == door_id:
			return trigger["arrival"]
	return spawn_point()

func spawn_point() -> Vector2:
	var spawn: Vector2 = data.get("spawn", Vector2(160.0, 0.0))
	return Vector2(spawn.x, floor_y() - 33.0)

func shrine_point() -> Vector2:
	if shrine:
		return Vector2(shrine.position.x + 40.0, floor_y() - 33.0)
	return spawn_point()

## Tira os bloqueios das habilidades que o jogador já tem (chamado ao ganhar uma habilidade).
func refresh_gates(abilities: Dictionary) -> void:
	for gate in gates:
		if abilities.has(gate["ability"]) and is_instance_valid(gate["node"]):
			gate["node"].queue_free()

# --- Montagem ---

func _add_background() -> void:
	var back := Polygon2D.new()
	back.polygon = _rect_polygon(Rect2(Vector2.ZERO, size_px))
	back.color = _region_color.darkened(0.55)
	back.z_index = -20
	add_child(back)
	# Linhas finas marcando cada tela, para dar noção de escala nos blocos cinzas.
	var cells: Vector2i = data["size"]
	for x in range(1, cells.x):
		_add_line(Vector2(x * WorldMap.SCREEN.x, 0.0), Vector2(x * WorldMap.SCREEN.x, size_px.y))
	for y in range(1, cells.y):
		_add_line(Vector2(0.0, y * WorldMap.SCREEN.y), Vector2(size_px.x, y * WorldMap.SCREEN.y))

func _add_line(from: Vector2, to: Vector2) -> void:
	var line := Line2D.new()
	line.points = PackedVector2Array([from, to])
	line.width = 1.0
	line.default_color = _region_color.darkened(0.3)
	line.z_index = -19
	add_child(line)

## Chão, teto e paredes, com aberturas onde há portas.
func _add_shell() -> void:
	var floor_t := WorldMap.FLOOR_THICKNESS
	var wall_t := WorldMap.WALL_THICKNESS
	var down_holes: Array[float] = []
	var up_holes: Array[float] = []
	var east_rows: Array[int] = []
	var west_rows: Array[int] = []
	for entry: Dictionary in data.get("doors", []):
		match entry["side"]:
			"down": down_holes.append(_column_center(int(entry["col"])))
			"up": up_holes.append(_column_center(int(entry["col"])))
			"east": east_rows.append(int(entry["row"]))
			"west": west_rows.append(int(entry["row"]))
	for span in _spans(0.0, size_px.x, down_holes, DOOR_OPENING):
		_add_solid(Rect2(span.x, size_px.y - floor_t, span.y - span.x, floor_t))
	for span in _spans(0.0, size_px.x, up_holes, DOOR_OPENING):
		_add_solid(Rect2(span.x, 0.0, span.y - span.x, wall_t))
	_add_wall(0.0, west_rows)
	_add_wall(size_px.x - wall_t, east_rows)
	# Salas com mais de uma fileira: piso de apoio embaixo de cada porta lateral alta.
	var rows: int = data["size"].y
	for row in range(rows - 1):
		if west_rows.has(row):
			_add_solid(Rect2(0.0, WorldMap.row_floor_y(row), 192.0, 16.0))
		if east_rows.has(row):
			_add_solid(Rect2(size_px.x - 192.0, WorldMap.row_floor_y(row), 192.0, 16.0))

func _add_wall(x: float, door_rows: Array[int]) -> void:
	var openings: Array[float] = []
	for row in door_rows:
		openings.append(WorldMap.row_floor_y(row) - DOOR_OPENING * 0.5)
	for span in _spans(0.0, size_px.y, openings, DOOR_OPENING):
		_add_solid(Rect2(x, span.x, WorldMap.WALL_THICKNESS, span.y - span.x))

## Trechos de [start, end] que sobram depois de abrir buracos de largura width centrados em holes.
func _spans(start: float, end: float, holes: Array[float], width: float) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var cursor := start
	var sorted := holes.duplicate()
	sorted.sort()
	for center: float in sorted:
		var hole_start := center - width * 0.5
		if hole_start > cursor:
			result.append(Vector2(cursor, hole_start))
		cursor = maxf(cursor, center + width * 0.5)
	if cursor < end:
		result.append(Vector2(cursor, end))
	return result

func _column_center(col: int) -> float:
	return (col + 0.5) * WorldMap.SCREEN.x

func _add_platforms() -> void:
	for item in data.get("platforms", []):
		_add_solid(Rect2(float(item[0]), float(item[1]), float(item[2]), 14.0), 0.18)
	# Escadas automáticas até cada porta alta (portas de cima e portas laterais das fileiras de cima).
	for entry: Dictionary in data.get("doors", []):
		if entry["side"] == "up":
			# Apoio parte embaixo da abertura do teto: o pulo (~177 px) passa pela abertura e
			# deixa o pé uns 25 px acima do chão da área de cima, dando tempo de andar para o lado.
			var hole_x := _column_center(int(entry["col"]))
			var landing := Vector2(hole_x - 24.0, UP_LANDING_Y)
			_add_solid(Rect2(landing.x, landing.y, 120.0, 14.0), 0.18)
			_add_stairs(landing)
		elif entry["side"] in ["east", "west"] and int(entry["row"]) < int(data["size"].y) - 1:
			var ledge_x := 200.0 if entry["side"] == "west" else size_px.x - 200.0 - STEP_WIDTH
			_add_stairs(Vector2(ledge_x, WorldMap.row_floor_y(int(entry["row"]))))

## Relevo provisório para o blockout não ficar um corredor reto: morros no chão, plataformas soltas e,
## nas regiões fechadas, rochas penduradas no teto. Sempre igual para a mesma sala (semente = id).
## As arenas de chefe ficam planas. Será substituído pelo desenho à mão de cada sala.
func _add_relief() -> void:
	if data.has("boss"):
		return
	var random := RandomNumberGenerator.new()
	random.seed = hash(room_id)
	var blocked := _relief_blocked_spans()
	var screens: int = data["size"].x
	var floor_top := floor_y()
	var placed: Array[Vector2] = []
	for _i in range(screens * 2):
		var width := random.randf_range(160.0, 320.0)
		var x := random.randf_range(WorldMap.WALL_THICKNESS, size_px.x - WorldMap.WALL_THICKNESS - width)
		if _overlaps(Vector2(x - 120.0, x + width + 120.0), blocked) or _overlaps(Vector2(x - 120.0, x + width + 120.0), placed):
			continue
		var height: float = [48.0, 72.0, 96.0][random.randi_range(0, 2)]
		_add_solid(Rect2(x, floor_top - height, width, height), 0.08)
		placed.append(Vector2(x, x + width))
	for screen in range(screens):
		var width := random.randf_range(96.0, 160.0)
		var x := screen * WorldMap.SCREEN.x + random.randf_range(120.0, WorldMap.SCREEN.x - 120.0 - width)
		var y := floor_top - random.randf_range(150.0, 250.0)
		if _overlaps(Vector2(x, x + width), blocked):
			continue
		_add_solid(Rect2(x, y, width, 14.0), 0.18)
	if data["region"] in ["cavernas", "lago", "coracao"]:
		var ceilings := _relief_blocked_spans(true)
		for _i in range(screens):
			var width := random.randf_range(96.0, 200.0)
			var x := random.randf_range(WorldMap.WALL_THICKNESS + 80.0, size_px.x - WorldMap.WALL_THICKNESS - 80.0 - width)
			if _overlaps(Vector2(x - 40.0, x + width + 40.0), ceilings):
				continue
			_add_solid(Rect2(x, WorldMap.WALL_THICKNESS, width, random.randf_range(60.0, 140.0)), -0.05)

## Trechos de x onde o relevo não pode ficar: perto das paredes laterais, dos buracos do chão
## (ou do teto, com ceiling = true), do santuário, do altar e do ponto inicial.
func _relief_blocked_spans(ceiling: bool = false) -> Array[Vector2]:
	var spans: Array[Vector2] = [Vector2(0.0, RELIEF_CLEARANCE), Vector2(size_px.x - RELIEF_CLEARANCE, size_px.x)]
	for entry: Dictionary in data.get("doors", []):
		if entry["side"] in ["up", "down"]:
			var center := _column_center(int(entry["col"]))
			if ceiling and entry["side"] == "down":
				continue
			spans.append(Vector2(center - DOOR_OPENING * 0.5 - RELIEF_CLEARANCE, center + DOOR_OPENING * 0.5 + RELIEF_CLEARANCE))
	if data.has("rune"):
		spans.append(Vector2(_rune_x() - 80.0, _rune_x() + 80.0))
	for key in ["shrine", "altar"]:
		if data.has(key):
			spans.append(Vector2(float(data[key]) - RELIEF_CLEARANCE, float(data[key]) + RELIEF_CLEARANCE))
	if data.has("spawn"):
		var spawn: Vector2 = data["spawn"]
		spans.append(Vector2(spawn.x - RELIEF_CLEARANCE, spawn.x + RELIEF_CLEARANCE))
	var items: Array = data.get("pickups", [])
	for index in range(items.size()):
		var item_x := _pickup_x(index, items.size())
		spans.append(Vector2(item_x - 60.0, item_x + 60.0))
	return spans

func _pickup_x(index: int, count: int) -> float:
	return size_px.x * (index + 1) / (count + 1) + 60.0

func _overlaps(span: Vector2, spans: Array[Vector2]) -> bool:
	for other in spans:
		if span.x < other.y and other.x < span.y:
			return true
	return false

## Degraus do chão até target (topo do último apoio), alternando de lado.
func _add_stairs(target: Vector2) -> void:
	var y := floor_y() - STEP_HEIGHT
	var index := 0
	while y > target.y + STEP_HEIGHT * 0.5:
		var offset := -150.0 if index % 2 == 0 else 150.0
		var x := clampf(target.x + offset, WorldMap.WALL_THICKNESS + 8.0, size_px.x - WorldMap.WALL_THICKNESS - STEP_WIDTH - 8.0)
		_add_solid(Rect2(x, y, STEP_WIDTH, 14.0), 0.18)
		y -= STEP_HEIGHT
		index += 1

func _add_doors(abilities: Dictionary) -> void:
	for entry: Dictionary in data.get("doors", []):
		var opening := _door_opening(entry)
		if entry.has("future"):
			_add_block(opening, Color("2a2a33"), WorldMap.FUTURE_REGIONS[entry["future"]] + "\n(depois do 1.0)")
			continue
		if entry.has("gate") and not abilities.has(entry["gate"]):
			var node := _add_block(opening, Color("c08a3e"), WorldMap.ABILITIES[entry["gate"]])
			gates.append({"ability": entry["gate"], "node": node})
		door_triggers.append({"door": entry, "rect": _door_trigger(entry), "arrival": _door_arrival(entry)})

## Retângulo da abertura da porta na casca da sala.
func _door_opening(entry: Dictionary) -> Rect2:
	match entry["side"]:
		"east":
			var y_east := WorldMap.row_floor_y(int(entry["row"])) - DOOR_OPENING
			return Rect2(size_px.x - WorldMap.WALL_THICKNESS, y_east, WorldMap.WALL_THICKNESS, DOOR_OPENING)
		"west":
			return Rect2(0.0, WorldMap.row_floor_y(int(entry["row"])) - DOOR_OPENING, WorldMap.WALL_THICKNESS, DOOR_OPENING)
		"up":
			return Rect2(_column_center(int(entry["col"])) - DOOR_OPENING * 0.5, 0.0, DOOR_OPENING, WorldMap.WALL_THICKNESS)
		_:
			return Rect2(_column_center(int(entry["col"])) - DOOR_OPENING * 0.5, size_px.y - WorldMap.FLOOR_THICKNESS, DOOR_OPENING, WorldMap.FLOOR_THICKNESS)

## Faixa na borda da sala que, tocada pelo jogador, troca de sala.
func _door_trigger(entry: Dictionary) -> Rect2:
	var opening := _door_opening(entry)
	match entry["side"]:
		"east":
			return Rect2(size_px.x - DOOR_TRIGGER, opening.position.y, DOOR_TRIGGER + 64.0, DOOR_OPENING)
		"west":
			return Rect2(-64.0, opening.position.y, DOOR_TRIGGER + 64.0, DOOR_OPENING)
		"up":
			return Rect2(opening.position.x, -64.0, DOOR_OPENING, DOOR_TRIGGER + 64.0)
		_:
			return Rect2(opening.position.x, size_px.y - DOOR_TRIGGER, DOOR_OPENING, DOOR_TRIGGER + 64.0)

func _door_arrival(entry: Dictionary) -> Vector2:
	var opening := _door_opening(entry)
	match entry["side"]:
		"east":
			return Vector2(size_px.x - 72.0, WorldMap.row_floor_y(int(entry["row"])) - 33.0)
		"west":
			return Vector2(72.0, WorldMap.row_floor_y(int(entry["row"])) - 33.0)
		"up":
			# Chega de cima e cai pela abertura, longe da faixa de disparo.
			return Vector2(opening.get_center().x, 96.0)
		_:
			# Chega por baixo: aparece em pé ao lado do buraco.
			var side := 1.0 if opening.get_center().x + 140.0 < size_px.x - 64.0 else -1.0
			return Vector2(opening.get_center().x + 140.0 * side, floor_y() - 33.0)

func _add_shrine(x: float, active: bool) -> void:
	shrine = WorldShrine.new()
	shrine.position = Vector2(x, floor_y())
	shrine.active = active
	add_child(shrine)

func _add_altar(x: float, ability: String) -> void:
	altar_rect = Rect2(x - 24.0, floor_y() - 72.0, 48.0, 72.0)
	var altar := _add_block(Rect2(x - 20.0, floor_y() - 40.0, 40.0, 40.0), Color("7fe6cf"), WorldMap.ABILITIES[ability], false)
	altar.name = "Altar"

func _add_pickups(collected_pickups: Callable) -> void:
	var items: Array = data.get("pickups", [])
	for index in range(items.size()):
		var pickup_id := "%s:item:%d" % [room_id, index]
		if collected_pickups.call(pickup_id):
			continue
		var pickup: ItemPickup = ITEM_PICKUP_SCRIPT.new()
		pickup.item_id = items[index]
		pickup.pickup_id = pickup_id
		pickup.position = Vector2(_pickup_x(index, items.size()), floor_y() - 22.0)
		pickup.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(pickup)

func _add_foes() -> void:
	var count := int(data.get("foes", 0))
	var usable := size_px.x - 400.0
	for index in range(count):
		var foe := ForestFoe.new()
		foe.drop_id = "%s:foe:%d" % [room_id, index]
		# Nasce no alto e cai: assim pousa no chão ou em cima do relevo, nunca dentro dele.
		foe.position = Vector2(200.0 + usable * (index + 0.5) / count, floor_y() - 120.0)
		foe.floor_y = floor_y()
		foe.speed = 27.0 + float(index % 3) * 5.0
		foe.patrol_span = 74.0 + float((index % 2) * 40)
		if data.get("tribal", false) and index % 2 == 1:
			foe.ranged = true
			foe.tribal = true
		foe.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(foe)

func _add_boss(boss_key: String) -> void:
	var info: Dictionary = WorldMap.BOSSES[boss_key]
	var fighter := CorruptedBoss.new()
	fighter.boss_name = info["name"]
	fighter.boss_id = info["boss_id"]
	fighter.encounter_tier = info["tier"]
	fighter.variant = int(info.get("variant", 0))
	fighter.max_health = int(info["health"])
	fighter.health = fighter.max_health
	fighter.floor_y = floor_y()
	fighter.position = Vector2(size_px.x * 0.68, floor_y() - 60.0)
	fighter.process_mode = Node.PROCESS_MODE_PAUSABLE
	fighter.set_meta("boss_key", boss_key)
	add_child(fighter)
	boss = fighter

# --- Peças ---

func _add_solid(rect: Rect2, lighten: float = 0.0) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	var fill := Polygon2D.new()
	fill.polygon = _rect_polygon(Rect2(-rect.size * 0.5, rect.size))
	fill.color = _solid_color.lightened(lighten)
	body.add_child(fill)
	var rim := Polygon2D.new()
	rim.polygon = _rect_polygon(Rect2(-rect.size * 0.5, Vector2(rect.size.x, minf(3.0, rect.size.y))))
	rim.color = _region_color.lightened(0.35)
	body.add_child(rim)
	add_child(body)
	return body

## Bloco colorido com nome (bloqueio de habilidade, gancho futuro ou altar).
func _add_block(rect: Rect2, color: Color, text: String, solid: bool = true) -> Node2D:
	var node: Node2D
	if solid:
		node = StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		node.add_child(collision)
	else:
		node = Node2D.new()
	node.position = rect.get_center()
	var fill := Polygon2D.new()
	fill.polygon = _rect_polygon(Rect2(-rect.size * 0.5, rect.size))
	fill.color = color
	node.add_child(fill)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("f4f1e6"))
	label.add_theme_color_override("font_outline_color", Color("10131a"))
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(160.0, 32.0)
	# Rótulo fora do bloco, do lado de dentro da sala.
	var outward := Vector2.ZERO
	if rect.position.x <= 0.0:
		outward = Vector2(60.0, 0.0)
	elif rect.end.x >= size_px.x:
		outward = Vector2(-60.0, 0.0)
	elif rect.position.y <= 0.0:
		outward = Vector2(0.0, 36.0)
	else:
		outward = Vector2(0.0, -40.0)
	label.position = outward - label.size * 0.5
	node.add_child(label)
	add_child(node)
	return node

func _rect_polygon(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])

# --- Pedra de runa (runa corrompida escondida na área; docs/design/runas.md) ---

var rune_rect := Rect2()

func _rune_x() -> float:
	return size_px.x * 0.5 + 40.0

func _add_rune_stone(rune_id: String) -> void:
	var x := _rune_x()
	rune_rect = Rect2(x - 24.0, floor_y() - 72.0, 48.0, 72.0)
	var stone := _add_block(Rect2(x - 14.0, floor_y() - 34.0, 28.0, 34.0), Color("8a4fd1"), RuneCatalog.info(rune_id).get("name", "Runa"), false)
	stone.name = "RuneStone"
