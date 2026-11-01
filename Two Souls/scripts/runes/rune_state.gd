extends RefCounted
class_name RuneState

var slots: int = RuneCatalog.STARTING_SLOTS
var fragments: int = 0
var found_runes: Dictionary = {} # id -> true (corrompida)
var purified_runes: Dictionary = {} # id -> nível
var equipped_runes: Array[String] = []

func found(rune_id: String) -> bool:
	if not RuneCatalog.has_rune(rune_id): return false
	if found_runes.has(rune_id) or purified_runes.has(rune_id): return false
	found_runes[rune_id] = true
	return true

func purify(rune_id: String) -> bool:
	if not found_runes.get(rune_id, false): return false
	found_runes.erase(rune_id)
	purified_runes[rune_id] = 1
	return true

func equip(rune_id: String) -> bool:
	if not purified_runes.has(rune_id) or equipped_runes.has(rune_id) or equipped_runes.size() >= slots: return false
	equipped_runes.append(rune_id)
	return true

func unequip(rune_id: String) -> bool:
	if not equipped_runes.has(rune_id): return false
	equipped_runes.erase(rune_id)
	return true

func add_slot() -> bool:
	if slots >= RuneCatalog.MAX_SLOTS: return false
	slots += 1
	return true

func add_fragments(amount: int) -> void:
	if amount > 0: fragments += amount

func upgrade(rune_id: String) -> bool:
	if not purified_runes.has(rune_id): return false
	var level: int = int(purified_runes[rune_id])
	if level >= RuneCatalog.MAX_LEVEL: return false
	var cost: int = int(RuneCatalog.UPGRADE_COSTS[level])
	if fragments < cost: return false
	fragments -= cost
	purified_runes[rune_id] = level + 1
	return true

func total_bonuses() -> Dictionary:
	var totals := {"damage": 0.0, "max_health": 0, "max_magic": 0, "move_speed": 0.0, "dash_speed": 0.0, "cooldown": 0.0, "stamina": 0, "combos": []}
	for rune_id in equipped_runes:
		var info: Dictionary = RuneCatalog.info(rune_id)
		var level: int = int(purified_runes.get(rune_id, 1))
		var key: String = info.get("bonus", "")
		var value: Variant = RuneCatalog.effect_value(rune_id, level)
		if key == "combo":
			(totals["combos"] as Array).append(rune_id)
		elif totals.has(key):
			totals[key] += value
	return totals

func to_save() -> Dictionary:
	return {"version": 1, "slots": slots, "fragments": fragments, "found": found_runes.keys(), "purified": purified_runes.duplicate(true), "equipped": equipped_runes.duplicate()}

func from_save(data: Variant) -> void:
	_reset()
	if not data is Dictionary or data.get("version") != 1: return
	var saved_slots: Variant = data.get("slots")
	var saved_fragments: Variant = data.get("fragments")
	var saved_found: Variant = data.get("found")
	var saved_purified: Variant = data.get("purified")
	var saved_equipped: Variant = data.get("equipped")
	if not _is_int(saved_slots) or saved_slots < RuneCatalog.STARTING_SLOTS or saved_slots > RuneCatalog.MAX_SLOTS: return
	if not _is_int(saved_fragments) or saved_fragments < 0: return
	if not saved_found is Array or not saved_purified is Dictionary or not saved_equipped is Array: return
	var all_ids: Dictionary = {}
	for id in saved_found:
		if not id is String or not RuneCatalog.has_rune(id) or all_ids.has(id): return
		all_ids[id] = true
	for id in saved_purified:
		var level: Variant = saved_purified[id]
		if not id is String or not RuneCatalog.has_rune(id) or all_ids.has(id) or not _is_int(level) or level < 1 or level > RuneCatalog.MAX_LEVEL: return
		all_ids[id] = true
	var equip_ids: Array[String] = []
	for id in saved_equipped:
		if not id is String or not saved_purified.has(id) or equip_ids.has(id): return
		equip_ids.append(id)
	if equip_ids.size() > saved_slots: return
	slots = saved_slots
	fragments = saved_fragments
	for id in saved_found: found_runes[id] = true
	purified_runes = saved_purified.duplicate(true)
	equipped_runes = equip_ids

func _is_int(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and floorf(float(value)) == float(value)

func _reset() -> void:
	slots = RuneCatalog.STARTING_SLOTS
	fragments = 0
	found_runes.clear()
	purified_runes.clear()
	equipped_runes.clear()
