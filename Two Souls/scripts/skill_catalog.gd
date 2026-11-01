extends RefCounted
class_name SkillCatalog
## Provisional branches for Orion's first playable talent tree.

const SKILL_IDS := ["spear_throw", "super_punch", "vitality", "mana_reserve"]

static func skill_ids() -> Array:
	return SKILL_IDS.duplicate()

static func get_definition(skill_id: String) -> Dictionary:
	match skill_id:
		"spear_throw":
			return {
				"name": "Lança arremessada",
				"description": "Lança uma arma em linha reta. Tecla L.",
				"cost": 1,
				"prerequisites": [],
				"branch": "Combate"
			}
		"super_punch":
			return {
				"name": "Super soco",
				"description": "Golpe próximo que causa dano elevado. Tecla U.",
				"cost": 1,
				"prerequisites": ["spear_throw"],
				"branch": "Combate"
			}
		"vitality":
			return {
				"name": "Coração firme",
				"description": "Aumenta a vida máxima em 1 ponto.",
				"cost": 1,
				"prerequisites": [],
				"branch": "Essência"
			}
		"mana_reserve":
			return {
				"name": "Reserva mágica",
				"description": "Aumenta a magia máxima em 1 ponto.",
				"cost": 1,
				"prerequisites": ["vitality"],
				"branch": "Essência"
			}
	return {}
