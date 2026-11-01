extends RefCounted
class_name RuneCatalog

const STARTING_SLOTS := 2
const MAX_SLOTS := 6
const MAX_LEVEL := 3
const UPGRADE_COSTS := {1: 3, 2: 6} # custo para passar do nível indicado ao próximo

const RUNES := {
	"onca": {"name": "Runa da Onça", "effect": "Velocidade de dash", "bonus": "dash_speed", "values": [0.12, 0.20, 0.30]},
	"curupira": {"name": "Runa do Curupira", "effect": "Velocidade de movimento", "bonus": "move_speed", "values": [0.06, 0.10, 0.15]},
	"boitata": {"name": "Runa do Boitatá", "effect": "Chance de golpe forte", "bonus": "damage", "values": [0.08, 0.14, 0.22]},
	"iara": {"name": "Runa da Iara", "effect": "Magia máxima", "bonus": "max_magic", "values": [1, 2, 3]},
	"mapinguari": {"name": "Runa do Mapinguari", "effect": "Vida máxima", "bonus": "max_health", "values": [1, 1, 2]},
	"saci": {"name": "Runa do Saci", "effect": "Recarga das habilidades", "bonus": "cooldown", "values": [-0.05, -0.09, -0.14]},
	"tatu": {"name": "Runa do Tatu", "effect": "Fôlego máximo", "bonus": "stamina", "values": [5, 9, 14]},
	"gaviaoreal": {"name": "Runa do Gavião-real", "effect": "Chance de golpe forte", "bonus": "damage", "values": [0.06, 0.11, 0.18]},
	"jiboia": {"name": "Runa da Jiboia", "effect": "Recarga da magia", "bonus": "cooldown", "values": [-0.04, -0.08, -0.12]},
	"mboi": {"name": "Runa do Mboi-tatá", "effect": "Desbloqueia um combo extra", "bonus": "combo", "values": [1, 1, 1]}
}

static func has_rune(rune_id: String) -> bool:
	return RUNES.has(rune_id)

static func info(rune_id: String) -> Dictionary:
	return RUNES.get(rune_id, {}).duplicate(true)

static func effect_value(rune_id: String, level: int) -> Variant:
	if not has_rune(rune_id) or level < 1 or level > MAX_LEVEL:
		return 0
	return RUNES[rune_id]["values"][level - 1]

static func effect_text(rune_id: String, level: int) -> String:
	if not has_rune(rune_id) or level < 1 or level > MAX_LEVEL:
		return "Efeito indisponível"
	var data: Dictionary = RUNES[rune_id]
	var value: Variant = effect_value(rune_id, level)
	if data["bonus"] == "combo":
		return "+1 combo (provisório)"
	if data["bonus"] in ["move_speed", "dash_speed", "damage", "cooldown"]:
		return "%s: %+d%%" % [data["effect"], roundi(float(value) * 100.0)]
	return "%s: +%d" % [data["effect"], int(value)]
