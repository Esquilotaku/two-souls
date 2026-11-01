extends RefCounted
## Versioned, single-slot campaign save with a recoverable previous copy.

const SAVE_PATH := "user://two_souls_save.json"
const TEMP_PATH := "user://two_souls_save.tmp"
const BACKUP_PATH := "user://two_souls_save.bak"
const SAVE_VERSION := 5
const MODES := ["historia", "aventura", "desafio"]
const INVENTORY_ITEMS := ["luminous_herb", "mana_seed"]
const SKILL_IDS := ["spear_throw", "super_punch", "vitality", "mana_reserve"]
const SKILL_PREREQUISITES := {"super_punch":"spear_throw", "mana_reserve":"vitality"}

static func has_save() -> bool:
	return not load_campaign().is_empty()

static func load_campaign() -> Dictionary:
	var primary := _upgrade_campaign(_read_file(SAVE_PATH))
	if _is_valid(primary):
		return primary
	var backup := _upgrade_campaign(_read_file(BACKUP_PATH))
	if _is_valid(backup):
		return backup
	return {}

static func save_campaign(data: Dictionary) -> bool:
	if not _is_valid(data):
		return false
	var temporary_file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if temporary_file == null:
		return false
	temporary_file.store_string(JSON.stringify(data, "\t", true))
	temporary_file.flush()
	var write_error := temporary_file.get_error()
	temporary_file.close()
	var temporary_absolute := ProjectSettings.globalize_path(TEMP_PATH)
	var save_absolute := ProjectSettings.globalize_path(SAVE_PATH)
	var backup_absolute := ProjectSettings.globalize_path(BACKUP_PATH)
	if write_error != OK:
		DirAccess.remove_absolute(temporary_absolute)
		return false
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(BACKUP_PATH):
			if DirAccess.remove_absolute(backup_absolute) != OK:
				DirAccess.remove_absolute(temporary_absolute)
				return false
		if DirAccess.rename_absolute(save_absolute, backup_absolute) != OK:
			DirAccess.remove_absolute(temporary_absolute)
			return false
	if DirAccess.rename_absolute(temporary_absolute, save_absolute) != OK:
		if FileAccess.file_exists(BACKUP_PATH) and not FileAccess.file_exists(SAVE_PATH):
			DirAccess.rename_absolute(backup_absolute, save_absolute)
		DirAccess.remove_absolute(temporary_absolute)
		return false
	return true

static func _read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


static func _is_valid(data: Dictionary) -> bool:
	var integer_fields := ["version", "day", "health", "magic", "level", "experience", "experience_to_next", "skill_points"]
	for field in integer_fields:
		if not _is_whole(data.get(field)):
			return false
	if int(data["version"]) != SAVE_VERSION:
		return false
	var world_hour_type := typeof(data.get("world_hour"))
	if world_hour_type != TYPE_FLOAT and world_hour_type != TYPE_INT:
		return false
	if float(data["world_hour"]) < 0.0 or float(data["world_hour"]) >= 24.0:
		return false
	if int(data["day"]) < 1:
		return false
	if not MODES.has(data.get("mode")):
		return false
	if typeof(data.get("room_id")) != TYPE_STRING or not WorldMap.has_room(data["room_id"]):
		return false
	if typeof(data.get("shrine_room")) != TYPE_STRING:
		return false
	if data["shrine_room"] != "" and not WorldMap.has_room(data["shrine_room"]):
		return false
	if not _is_id_list(data.get("visited_rooms"), WorldMap.ROOMS.keys()):
		return false
	if not _is_id_list(data.get("activated_shrines"), WorldMap.ROOMS.keys()):
		return false
	if not _is_id_list(data.get("abilities"), WorldMap.ABILITIES.keys()):
		return false
	if not _is_id_list(data.get("defeated_bosses"), WorldMap.BOSSES.keys()):
		return false
	if int(data["health"]) < 1 or int(data["health"]) > 12:
		return false
	if int(data["magic"]) < 0 or int(data["magic"]) > 12:
		return false
	if int(data["level"]) < 1 or int(data["experience"]) < 0 or int(data["experience_to_next"]) < 1:
		return false
	if int(data["skill_points"]) < 0 or int(data["skill_points"]) > 99:
		return false
	for field in ["rock_recruited", "twin_magic"]:
		if typeof(data.get(field)) != TYPE_BOOL:
			return false
	if data.has("runes") and typeof(data["runes"]) != TYPE_DICTIONARY:
		return false
	var inventory: Variant = data.get("inventory")
	if typeof(inventory) != TYPE_DICTIONARY:
		return false
	for item_id in inventory.keys():
		if not INVENTORY_ITEMS.has(item_id):
			return false
		if not _is_whole(inventory[item_id]) or int(inventory[item_id]) < 0 or int(inventory[item_id]) > 99:
			return false
	for item_id in INVENTORY_ITEMS:
		if not _is_whole(inventory.get(item_id, 0)):
			return false
	var collected_pickups: Variant = data.get("collected_pickups")
	if typeof(collected_pickups) != TYPE_ARRAY or collected_pickups.size() > 2048:
		return false
	for pickup_id in collected_pickups:
		if typeof(pickup_id) != TYPE_STRING or str(pickup_id).is_empty() or str(pickup_id).length() > 128:
			return false
	var unlocked_skills: Variant = data.get("unlocked_skills")
	if typeof(unlocked_skills) != TYPE_ARRAY or unlocked_skills.size() > SKILL_IDS.size():
		return false
	var learned_skill_set: Dictionary = {}
	for skill_id in unlocked_skills:
		if typeof(skill_id) != TYPE_STRING or not SKILL_IDS.has(skill_id) or learned_skill_set.has(skill_id):
			return false
		learned_skill_set[skill_id] = true
	for skill_id in learned_skill_set:
		var prerequisite := str(SKILL_PREREQUISITES.get(skill_id, ""))
		if not prerequisite.is_empty() and not learned_skill_set.has(prerequisite):
			return false
	return true

## Lista de textos sem repetição, todos dentro de allowed.
static func _is_id_list(value: Variant, allowed: Array) -> bool:
	if typeof(value) != TYPE_ARRAY or value.size() > allowed.size():
		return false
	var seen := {}
	for entry in value:
		if typeof(entry) != TYPE_STRING or not allowed.has(entry) or seen.has(entry):
			return false
		seen[entry] = true
	return true

static func _upgrade_campaign(data: Dictionary) -> Dictionary:
	if data.is_empty() or not _is_whole(data.get("version")):
		return {}
	var upgraded := data.duplicate(true)
	var version := int(upgraded["version"])
	if version == 1:
		upgraded["inventory"] = {
			"luminous_herb": 0,
			"mana_seed": 0
		}
		upgraded["collected_pickups"] = []
		version = 2
	if version == 2:
		upgraded["skill_points"] = 0
		upgraded["unlocked_skills"] = []
		version = 3
	if version == 3:
		upgraded["world_hour"] = 7.0
		version = 4
	if version == 4:
		# Mundo interligado: as fases lineares somem e a campanha recomeça na Clareira,
		# mantendo nível, XP, itens, talentos e a hora. Itens pegos nas fases antigas não valem mais.
		for old_field in ["stage_index", "checkpoint_x", "checkpoint_marker", "boss_defeated"]:
			upgraded.erase(old_field)
		upgraded["day"] = 1
		upgraded["mode"] = "aventura"
		upgraded["room_id"] = WorldMap.START_ROOM
		upgraded["shrine_room"] = ""
		upgraded["visited_rooms"] = []
		upgraded["activated_shrines"] = []
		upgraded["abilities"] = []
		upgraded["defeated_bosses"] = []
		upgraded["collected_pickups"] = []
		version = 5
	if version != SAVE_VERSION:
		return {}
	upgraded["version"] = SAVE_VERSION
	return upgraded

## O JSON do Godot devolve todo número como decimal (1 vira 1.0); aceita inteiros e decimais redondos.
static func _is_whole(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	return typeof(value) == TYPE_FLOAT and is_equal_approx(value, floorf(value))
