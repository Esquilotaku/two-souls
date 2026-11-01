extends RefCounted
class_name ItemCatalog
## Small provisional consumable list for the first playable RPG inventory.

const ITEM_IDS := ["luminous_herb", "mana_seed"]

static func item_ids() -> Array:
	return ITEM_IDS.duplicate()

static func get_definition(item_id: String) -> Dictionary:
	match item_id:
		"luminous_herb":
			return {
				"name": "Erva luminosa",
				"description": "Recupera 2 pontos de vida.",
				"effect": "health",
				"amount": 2,
				"color": "8de3a0"
			}
		"mana_seed":
			return {
				"name": "Semente de mana",
				"description": "Recupera 2 pontos de magia.",
				"effect": "magic",
				"amount": 2,
				"color": "79dce8"
			}
	return {}

static func empty_inventory() -> Dictionary:
	return {
		"luminous_herb": 0,
		"mana_seed": 0
	}

static func sanitize_inventory(value: Variant) -> Dictionary:
	var result := empty_inventory()
	if typeof(value) != TYPE_DICTIONARY:
		return result
	for item_id in ITEM_IDS:
		var count: Variant = value.get(item_id, 0)
		if typeof(count) == TYPE_INT:
			result[item_id] = clampi(int(count), 0, 99)
	return result
