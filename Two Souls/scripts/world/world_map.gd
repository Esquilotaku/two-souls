class_name WorldMap
extends RefCounted
## Dados do mundo interligado: regiões, salas e portas (docs/plano-tecnico-mundo.md, seções 3, 5 e 6).
## Cada célula do mapa é uma tela de 640x360. As salas são montadas por WorldRoom a partir destes dados.

const SCREEN := Vector2(960.0, 540.0)
const FLOOR_THICKNESS := 48.0
const WALL_THICKNESS := 32.0
const START_ROOM := "clareira_inicio"

const REGIONS := {
	"clareira": {"name": "Clareira da Árvore Mãe", "color": "3f6b4f"},
	"trilha": {"name": "Trilha da Tribo", "color": "6b5a3f"},
	"floresta": {"name": "Floresta Antiga", "color": "2f5a45"},
	"lago": {"name": "Lago", "color": "2f4f6b"},
	"cavernas": {"name": "Cavernas e Túnel", "color": "4a4458"},
	"copas": {"name": "Copas", "color": "4f7a3a"},
	"coracao": {"name": "Coração Corrompido", "color": "5a3a5f"},
	"covil": {"name": "Covil do Feiticeiro", "color": "3a2f4f"},
}

## Habilidades de travessia, na ordem do brainstorm-jogo.md (seção 3).
const ABILITIES := {
	"spear_wall": "Lança cravada",
	"super_punch": "Super soco",
	"onca": "Corrida da onça",
	"jiboia": "Mergulho da jiboia",
	"tatu": "Escavação do tatu",
	"gaviao": "Pulo duplo do gavião",
	"purificacao": "Purificação",
}

## Ganchos depois do 1.0 (portas "future").
const FUTURE_REGIONS := {
	"brejo": "Brejo",
	"ruinas": "Ruínas sob o Lago",
	"raizes_profundas": "Raízes Profundas",
	"pico_nevado": "Pico Nevado",
	"bosque_aenia": "Bosque de Aenia",
}

## Chefes por sala. "boss_id" usa os comportamentos do boss.gd; os subchefes ainda são o genérico.
const BOSSES := {
	"the_rock": {"rune": "mapinguari", "name": "D Rock", "boss_id": "the_rock", "tier": "major", "hour": 10.0, "health": 14, "variant": 2},
	"onca_corrompida": {"rune": "onca", "name": "Onça Corrompida", "boss_id": "generic", "tier": "sub_boss", "health": 10, "variant": 1},
	"jiboia_corrompida": {"rune": "jiboia", "name": "Jiboia Corrompida", "boss_id": "swamp_guardian", "tier": "sub_boss", "health": 12, "variant": 1},
	"tatu_corrompido": {"rune": "tatu", "name": "Tatu Corrompido", "boss_id": "generic", "tier": "sub_boss", "health": 12, "variant": 0},
	"gaviao_corrompido": {"rune": "gaviaoreal", "name": "Gavião Corrompido", "boss_id": "generic", "tier": "sub_boss", "health": 12, "variant": 2},
	"corrupted_tree": {"rune": "curupira", "name": "Árvore Corrompida", "boss_id": "corrupted_tree", "tier": "major", "hour": 18.0, "health": 16, "variant": 0},
	"hooded_sorcerer": {"name": "Feiticeiro Encapuzado", "boss_id": "hooded_sorcerer", "tier": "major", "hour": 22.0, "health": 18, "variant": 2},
}

const ROOMS := {
	# --- Clareira da Árvore Mãe ---
	"clareira_inicio": {
		"region": "clareira", "name": "Clareira da Árvore Mãe",
		"cell": Vector2i(0, 0), "size": Vector2i(2, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "trilha_entrada", "to_door": "oeste"},
			{"id": "oeste", "side": "west", "row": 0, "to": "floresta_borda", "to_door": "leste"},
			{"id": "baixo", "side": "down", "col": 1, "to": "cav_clareira", "to_door": "cima", "gate": "super_punch"},
		],
		"spawn": Vector2(160.0, 0.0), "shrine": 360.0, "grants": "spear_wall", "altar": 860.0,
		"pickups": ["luminous_herb"],
		"platforms": [[520.0, 220.0, 120.0]],
	},
	# --- Trilha da Tribo ---
	"trilha_entrada": {
		"region": "trilha", "name": "Trilha da Tribo",
		"cell": Vector2i(2, 0), "size": Vector2i(2, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "clareira_inicio", "to_door": "leste"},
			{"id": "leste", "side": "east", "row": 0, "to": "trilha_aldeia", "to_door": "oeste", "gate": "spear_wall"},
		],
		"foes": 3, "tribal": true,
		"platforms": [[300.0, 230.0, 112.0], [620.0, 200.0, 96.0], [940.0, 230.0, 112.0]],
	},
	"trilha_aldeia": {
		"region": "trilha", "name": "Aldeia da Tribo",
		"cell": Vector2i(4, 0), "size": Vector2i(2, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "trilha_entrada", "to_door": "leste"},
			{"id": "leste", "side": "east", "row": 0, "to": "trilha_arena", "to_door": "oeste"},
			{"id": "baixo", "side": "down", "col": 0, "to": "cav_tunel", "to_door": "cima", "gate": "super_punch"},
		],
		"shrine": 760.0, "foes": 2, "tribal": true, "pickups": ["mana_seed"],
		"platforms": [[880.0, 210.0, 140.0], [1080.0, 170.0, 100.0]],
	},
	"trilha_arena": {
		"region": "trilha", "name": "Arena do D Rock",
		"cell": Vector2i(6, 0), "size": Vector2i(1, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "trilha_aldeia", "to_door": "leste"},
		],
		"boss": "the_rock", "grants": "super_punch",
	},
	# --- Floresta Antiga ---
	"floresta_borda": {
		"region": "floresta", "name": "Borda da Floresta Antiga",
		"cell": Vector2i(-2, 0), "size": Vector2i(2, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "clareira_inicio", "to_door": "oeste"},
			{"id": "oeste", "side": "west", "row": 0, "to": "floresta_centro", "to_door": "leste"},
		],
		"foes": 2, "rune": "saci", "platforms": [[420.0, 220.0, 120.0], [760.0, 200.0, 100.0]],
	},
	"floresta_centro": {
		"region": "floresta", "name": "Coração da Floresta Antiga",
		"cell": Vector2i(-4, -1), "size": Vector2i(2, 2),
		"doors": [
			{"id": "leste", "side": "east", "row": 1, "to": "floresta_borda", "to_door": "oeste"},
			{"id": "oeste", "side": "west", "row": 1, "to": "floresta_toca", "to_door": "leste"},
			{"id": "oeste_alto", "side": "west", "row": 0, "to": "coracao_raizes", "to_door": "leste"},
			{"id": "cima", "side": "up", "col": 1, "to": "copas_baixa", "to_door": "baixo", "gate": "gaviao"},
			{"id": "baixo", "side": "down", "col": 0, "to": "lago_margem", "to_door": "cima"},
		],
		"shrine": 640.0, "foes": 3, "pickups": ["luminous_herb"],
	},
	"floresta_toca": {
		"region": "floresta", "name": "Toca da Onça",
		"cell": Vector2i(-5, 0), "size": Vector2i(1, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "floresta_centro", "to_door": "oeste"},
		],
		"boss": "onca_corrompida", "grants": "onca",
	},
	# --- Lago ---
	"lago_margem": {
		"region": "lago", "name": "Margem do Lago",
		"cell": Vector2i(-5, 1), "size": Vector2i(2, 1),
		"doors": [
			{"id": "cima", "side": "up", "col": 1, "to": "floresta_centro", "to_door": "baixo"},
			{"id": "oeste", "side": "west", "row": 0, "to": "lago_toca", "to_door": "leste", "gate": "onca"},
			{"id": "baixo", "side": "down", "col": 0, "to": "lago_fundo", "to_door": "cima", "gate": "jiboia"},
		],
		"shrine": 900.0, "foes": 2, "pickups": ["mana_seed"],
		"platforms": [[560.0, 220.0, 120.0]],
	},
	"lago_toca": {
		"region": "lago", "name": "Toca da Jiboia",
		"cell": Vector2i(-6, 1), "size": Vector2i(1, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "lago_margem", "to_door": "oeste"},
			{"id": "oeste", "side": "west", "row": 0, "future": "brejo"},
		],
		"boss": "jiboia_corrompida", "grants": "jiboia",
	},
	"lago_fundo": {
		"region": "lago", "name": "Fundo do Lago",
		"cell": Vector2i(-5, 2), "size": Vector2i(2, 1),
		"doors": [
			{"id": "cima", "side": "up", "col": 0, "to": "lago_margem", "to_door": "baixo"},
			{"id": "leste", "side": "east", "row": 0, "to": "cav_alagada", "to_door": "oeste"},
			{"id": "baixo", "side": "down", "col": 1, "future": "ruinas"},
		],
		"foes": 2, "rune": "iara",
	},
	# --- Cavernas e Túnel ---
	"cav_clareira": {
		"region": "cavernas", "name": "Caverna sob a Clareira",
		"cell": Vector2i(0, 1), "size": Vector2i(2, 1),
		"doors": [
			{"id": "cima", "side": "up", "col": 1, "to": "clareira_inicio", "to_door": "baixo", "gate": "super_punch"},
			{"id": "leste", "side": "east", "row": 0, "to": "cav_tunel", "to_door": "oeste"},
			{"id": "baixo", "side": "down", "col": 0, "to": "cav_profundas", "to_door": "cima", "gate": "tatu"},
		],
		"foes": 2, "platforms": [[880.0, 210.0, 140.0]],
	},
	"cav_tunel": {
		"region": "cavernas", "name": "O Túnel",
		"cell": Vector2i(2, 1), "size": Vector2i(3, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "cav_clareira", "to_door": "leste"},
			{"id": "cima", "side": "up", "col": 2, "to": "trilha_aldeia", "to_door": "baixo", "gate": "super_punch"},
			{"id": "leste", "side": "east", "row": 0, "to": "cav_toca_tatu", "to_door": "oeste"},
		],
		"shrine": 960.0, "foes": 3, "pickups": ["luminous_herb"],
		"platforms": [[1500.0, 210.0, 140.0]],
	},
	"cav_toca_tatu": {
		"region": "cavernas", "name": "Toca do Tatu",
		"cell": Vector2i(5, 1), "size": Vector2i(1, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "cav_tunel", "to_door": "leste"},
		],
		"boss": "tatu_corrompido", "grants": "tatu",
	},
	"cav_alagada": {
		"region": "cavernas", "name": "Galeria Alagada",
		"cell": Vector2i(-3, 2), "size": Vector2i(3, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "lago_fundo", "to_door": "leste"},
			{"id": "leste", "side": "east", "row": 0, "to": "cav_profundas", "to_door": "oeste"},
		],
		"foes": 2, "platforms": [[700.0, 220.0, 120.0], [1200.0, 220.0, 120.0]],
	},
	"cav_profundas": {
		"region": "cavernas", "name": "Cavernas Profundas",
		"cell": Vector2i(0, 2), "size": Vector2i(3, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "cav_alagada", "to_door": "leste"},
			{"id": "cima", "side": "up", "col": 0, "to": "cav_clareira", "to_door": "baixo", "gate": "tatu"},
			{"id": "leste", "side": "east", "row": 0, "to": "cav_ninho", "to_door": "oeste"},
			{"id": "baixo", "side": "down", "col": 1, "future": "raizes_profundas"},
		],
		"shrine": 1600.0, "foes": 3, "pickups": ["mana_seed"], "rune": "boitata",
	},
	"cav_ninho": {
		"region": "cavernas", "name": "Ninho do Gavião",
		"cell": Vector2i(3, 2), "size": Vector2i(1, 1),
		"doors": [
			{"id": "oeste", "side": "west", "row": 0, "to": "cav_profundas", "to_door": "leste"},
		],
		"boss": "gaviao_corrompido", "grants": "gaviao",
	},
	# --- Copas ---
	"copas_baixa": {
		"region": "copas", "name": "Copas Baixas",
		"cell": Vector2i(-4, -3), "size": Vector2i(2, 2),
		"doors": [
			{"id": "baixo", "side": "down", "col": 1, "to": "floresta_centro", "to_door": "cima", "gate": "gaviao"},
			{"id": "oeste", "side": "west", "row": 0, "to": "copas_alta", "to_door": "leste"},
		],
		"foes": 2,
	},
	"copas_alta": {
		"region": "copas", "name": "Copas Altas",
		"cell": Vector2i(-6, -3), "size": Vector2i(2, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "copas_baixa", "to_door": "oeste"},
			{"id": "baixo", "side": "down", "col": 1, "to": "coracao_arena", "to_door": "cima"},
			{"id": "oeste", "side": "west", "row": 0, "to": "covil_portao", "to_door": "leste", "gate": "purificacao"},
			{"id": "cima", "side": "up", "col": 0, "future": "pico_nevado"},
		],
		"shrine": 360.0, "platforms": [[240.0, 220.0, 100.0], [900.0, 200.0, 100.0]], "rune": "mboi",
	},
	# --- Coração Corrompido ---
	"coracao_raizes": {
		"region": "coracao", "name": "Raízes do Coração",
		"cell": Vector2i(-6, -1), "size": Vector2i(2, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "floresta_centro", "to_door": "oeste_alto"},
			{"id": "cima", "side": "up", "col": 0, "to": "coracao_arena", "to_door": "baixo", "gate": "gaviao"},
			{"id": "oeste", "side": "west", "row": 0, "future": "bosque_aenia"},
		],
		"shrine": 900.0, "foes": 3,
	},
	"coracao_arena": {
		"region": "coracao", "name": "Coração Corrompido",
		"cell": Vector2i(-6, -2), "size": Vector2i(2, 1),
		"doors": [
			{"id": "cima", "side": "up", "col": 1, "to": "copas_alta", "to_door": "baixo"},
			{"id": "baixo", "side": "down", "col": 0, "to": "coracao_raizes", "to_door": "cima"},
		],
		"boss": "corrupted_tree", "grants": "purificacao",
	},
	# --- Covil do Feiticeiro ---
	"covil_portao": {
		"region": "covil", "name": "Portão do Covil",
		"cell": Vector2i(-8, -3), "size": Vector2i(2, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "copas_alta", "to_door": "oeste", "gate": "purificacao"},
			{"id": "oeste", "side": "west", "row": 0, "to": "covil_trono", "to_door": "leste"},
		],
		"shrine": 900.0, "foes": 3,
	},
	"covil_trono": {
		"region": "covil", "name": "Trono do Feiticeiro",
		"cell": Vector2i(-9, -3), "size": Vector2i(1, 1),
		"doors": [
			{"id": "leste", "side": "east", "row": 0, "to": "covil_portao", "to_door": "oeste"},
		],
		"boss": "hooded_sorcerer", "final": true,
	},
}

static func has_room(room_id: String) -> bool:
	return ROOMS.has(room_id)

static func room(room_id: String) -> Dictionary:
	return ROOMS.get(room_id, {})

static func room_ids() -> Array:
	return ROOMS.keys()

static func room_pixel_size(room_id: String) -> Vector2:
	var data := room(room_id)
	var cells: Vector2i = data.get("size", Vector2i.ONE)
	return Vector2(cells.x * SCREEN.x, cells.y * SCREEN.y)

## y do chão de uma fileira de telas (0 = a de cima), em px relativos à sala.
static func row_floor_y(row: int) -> float:
	return (row + 1) * SCREEN.y - FLOOR_THICKNESS

static func door(room_id: String, door_id: String) -> Dictionary:
	for entry: Dictionary in room(room_id).get("doors", []):
		if entry["id"] == door_id:
			return entry
	return {}

static func region_name(room_id: String) -> String:
	return REGIONS.get(room(room_id).get("region", ""), {}).get("name", "")

## Confere o mapa: portas com volta, células sem sobreposição, habilidades e chefes conhecidos.
## Devolve a lista de erros (vazia = tudo certo).
static func validate() -> Array[String]:
	var errors: Array[String] = []
	var occupied := {}
	for room_id: String in ROOMS:
		var data: Dictionary = ROOMS[room_id]
		if not REGIONS.has(data.get("region", "")):
			errors.append("%s: região desconhecida" % room_id)
		var cell: Vector2i = data["cell"]
		var size: Vector2i = data["size"]
		for x in range(size.x):
			for y in range(size.y):
				var key := Vector2i(cell.x + x, cell.y + y)
				if occupied.has(key):
					errors.append("%s: célula %s já é de %s" % [room_id, key, occupied[key]])
				occupied[key] = room_id
		if data.has("grants") and not ABILITIES.has(data["grants"]):
			errors.append("%s: habilidade desconhecida %s" % [room_id, data["grants"]])
		if data.has("boss") and not BOSSES.has(data["boss"]):
			errors.append("%s: chefe desconhecido %s" % [room_id, data["boss"]])
		if data.has("rune") and not RuneCatalog.has_rune(data["rune"]):
			errors.append("%s: runa desconhecida %s" % [room_id, data["rune"]])
		var door_ids := {}
		for entry: Dictionary in data.get("doors", []):
			var label := "%s/%s" % [room_id, entry.get("id", "?")]
			if door_ids.has(entry["id"]):
				errors.append("%s: id de porta repetido" % label)
			door_ids[entry["id"]] = true
			var side: String = entry.get("side", "")
			if side in ["east", "west"]:
				if int(entry.get("row", -1)) < 0 or int(entry.get("row", -1)) >= size.y:
					errors.append("%s: fileira fora da sala" % label)
			elif side in ["up", "down"]:
				if int(entry.get("col", -1)) < 0 or int(entry.get("col", -1)) >= size.x:
					errors.append("%s: coluna fora da sala" % label)
			else:
				errors.append("%s: lado inválido %s" % [label, side])
			if entry.has("gate") and not ABILITIES.has(entry["gate"]):
				errors.append("%s: bloqueio com habilidade desconhecida" % label)
			if entry.has("future"):
				if not FUTURE_REGIONS.has(entry["future"]):
					errors.append("%s: gancho futuro desconhecido" % label)
				continue
			if not ROOMS.has(entry.get("to", "")):
				errors.append("%s: sala de destino inexistente" % label)
				continue
			var back := door(entry["to"], entry.get("to_door", ""))
			if back.is_empty():
				errors.append("%s: porta de destino inexistente" % label)
			elif back.get("to", "") != room_id or back.get("to_door", "") != entry["id"]:
				errors.append("%s: a porta de destino não volta para cá" % label)
			elif _opposite(side) != back.get("side", ""):
				errors.append("%s: lados das portas não se encaixam" % label)
			elif door_cell(room_id, entry) + _side_step(side) != door_cell(entry["to"], back):
				errors.append("%s: a porta de destino não fica na célula vizinha" % label)
	_check_boss_runes(errors)
	return errors

## Célula do mapa (em telas) onde fica uma porta.
static func door_cell(room_id: String, entry: Dictionary) -> Vector2i:
	var data := room(room_id)
	var cell: Vector2i = data["cell"]
	var size: Vector2i = data["size"]
	match entry["side"]:
		"east":
			return Vector2i(cell.x + size.x - 1, cell.y + int(entry["row"]))
		"west":
			return Vector2i(cell.x, cell.y + int(entry["row"]))
		"up":
			return Vector2i(cell.x + int(entry["col"]), cell.y)
		_:
			return Vector2i(cell.x + int(entry["col"]), cell.y + size.y - 1)

static func _side_step(side: String) -> Vector2i:
	return {"east": Vector2i.RIGHT, "west": Vector2i.LEFT, "up": Vector2i.UP, "down": Vector2i.DOWN}.get(side, Vector2i.ZERO)

static func _check_boss_runes(errors: Array[String]) -> void:
	for boss_key in BOSSES:
		if BOSSES[boss_key].has("rune") and not RuneCatalog.has_rune(BOSSES[boss_key]["rune"]):
			errors.append("chefe %s: runa desconhecida" % boss_key)

static func _opposite(side: String) -> String:
	return {"east": "west", "west": "east", "up": "down", "down": "up"}.get(side, "")

## Salas alcançáveis a partir do início, ganhando as habilidades das salas visitadas.
static func reachable_rooms() -> Dictionary:
	var abilities := {}
	var reached := {START_ROOM: true}
	var changed := true
	while changed:
		changed = false
		for room_id: String in reached.keys():
			var data := room(room_id)
			if data.has("grants") and not abilities.has(data["grants"]):
				abilities[data["grants"]] = true
				changed = true
			for entry: Dictionary in data.get("doors", []):
				if entry.has("future") or reached.has(entry["to"]):
					continue
				if entry.has("gate") and not abilities.has(entry["gate"]):
					continue
				reached[entry["to"]] = true
				changed = true
	return reached
