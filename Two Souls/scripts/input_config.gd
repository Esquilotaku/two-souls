extends RefCounted
class_name InputConfig

const SAVE_PATH := "user://controles.cfg"
const ACTION_NAMES := {
	"move_left": "Mover para a esquerda", "move_right": "Mover para a direita",
	"look_up": "Olhar para cima", "look_down": "Olhar para baixo",
	"interact": "Interagir", "jump": "Pular", "attack": "Atacar",
	"dash": "Esquivar", "throw_spear": "Lançar lança", "super_punch": "Super soco",
	"magic": "Magia", "transform": "Transformar", "context": "Habilidade de contexto",
	"quick_heal": "Cura rápida", "confirm": "Confirmar", "map": "Mapa",
	"inventory": "Inventário", "skill_tree": "Árvore de talentos", "pause": "Pausar"
}

## Ações que ainda não fazem nada no jogo: ficam fora do menu e da ajuda até serem programadas.
## O dash não tem tecla: é duplo toque na seta (player.gd).
const NOT_READY := ["dash", "transform", "context", "quick_heal", "confirm"]

static var DEFAULTS: Dictionary = _make_defaults()

static func visible_actions() -> Array:
	return DEFAULTS.keys().filter(func(action): return not NOT_READY.has(action))

static func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	return event

static func _button(button: JoyButton) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	return event

static func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	return event

static func _make_defaults() -> Dictionary:
	var d := {}
	d["move_left"] = [_key(KEY_LEFT), _button(JOY_BUTTON_DPAD_LEFT), _axis(JOY_AXIS_LEFT_X, -1.0)]
	d["move_right"] = [_key(KEY_RIGHT), _button(JOY_BUTTON_DPAD_RIGHT), _axis(JOY_AXIS_LEFT_X, 1.0)]
	d["look_up"] = [_key(KEY_UP), _button(JOY_BUTTON_DPAD_UP)]
	d["look_down"] = [_key(KEY_DOWN), _button(JOY_BUTTON_DPAD_DOWN)]
	d["interact"] = [_key(KEY_UP), _button(JOY_BUTTON_Y)]
	d["jump"] = [_key(KEY_SPACE), _button(JOY_BUTTON_A)]
	d["attack"] = [_key(KEY_A), _button(JOY_BUTTON_X)]
	d["dash"] = [_key(KEY_S), _button(JOY_BUTTON_B)]
	d["throw_spear"] = [_key(KEY_Q), _button(JOY_BUTTON_LEFT_SHOULDER)]
	d["super_punch"] = [_key(KEY_W), _button(JOY_BUTTON_RIGHT_SHOULDER)]
	d["magic"] = [_key(KEY_E), _axis(JOY_AXIS_TRIGGER_LEFT, 1.0)]
	d["transform"] = [_key(KEY_R), _axis(JOY_AXIS_TRIGGER_RIGHT, 1.0)]
	d["context"] = [_key(KEY_D), _button(JOY_BUTTON_RIGHT_STICK)]
	d["quick_heal"] = [_key(KEY_F), _button(JOY_BUTTON_LEFT_STICK)]
	d["confirm"] = [_key(KEY_ENTER), _button(JOY_BUTTON_A)]
	d["map"] = [_key(KEY_TAB), _button(JOY_BUTTON_BACK)]
	d["inventory"] = [_key(KEY_I), _button(JOY_BUTTON_PADDLE1)]
	d["skill_tree"] = [_key(KEY_T), _button(JOY_BUTTON_PADDLE2)]
	d["pause"] = [_key(KEY_ESCAPE), _button(JOY_BUTTON_START)]
	return d

static func apply_defaults() -> void:
	for action in DEFAULTS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action)
		for event in DEFAULTS[action]:
			InputMap.action_add_event(action, event.duplicate())

static func save(path: String = SAVE_PATH) -> bool:
	var config := ConfigFile.new()
	var actions := {}
	for action in DEFAULTS:
		if InputMap.has_action(action):
			var ordered: Array[InputEvent] = []
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					ordered.push_front(event)
				else:
					ordered.append(event)
			actions[action] = ordered
	config.set_value("controls", "actions", actions)
	return config.save(path) == OK

static func load_saved(path: String = SAVE_PATH) -> bool:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		apply_defaults()
		return false
	var saved: Variant = config.get_value("controls", "actions", null)
	if typeof(saved) != TYPE_DICTIONARY:
		apply_defaults()
		return false
	for action in DEFAULTS:
		if not saved.has(action) or typeof(saved[action]) != TYPE_ARRAY or saved[action].size() < 2:
			apply_defaults()
			return false
		if not saved[action][0] is InputEventKey:
			apply_defaults()
			return false
		for event in saved[action].slice(1):
			if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				apply_defaults()
				return false
		if saved[action].size() == 1:
			apply_defaults()
			return false
	apply_defaults()
	for action in DEFAULTS:
		InputMap.action_erase_events(action)
		for event in saved[action]:
			InputMap.action_add_event(action, event)
	return true

static func remap(action: String, event: InputEvent, slot: int) -> String:
	if not DEFAULTS.has(action) or slot < 0 or slot > 1 or event == null:
		return ""
	var displaced_action := ""
	for other in DEFAULTS:
		if other == action:
			continue
		for other_event in InputMap.action_get_events(other):
			if _slot_of(other_event) == slot and other_event.is_match(event):
				displaced_action = other
				var old := _event_in_slot(action, slot)
				_set_slot(other, slot, old)
				break
		if displaced_action != "":
			break
	_set_slot(action, slot, event)
	return displaced_action

static func _slot_of(event: InputEvent) -> int:
	return 0 if event is InputEventKey else 1

static func _event_in_slot(action: String, slot: int) -> InputEvent:
	for event in InputMap.action_get_events(action):
		if _slot_of(event) == slot:
			return event
	return null

static func _set_slot(action: String, slot: int, event: InputEvent) -> void:
	for old in InputMap.action_get_events(action):
		var remove_event := false
		if slot == 0:
			remove_event = old is InputEventKey
		elif event is InputEventJoypadButton:
			remove_event = old is InputEventJoypadButton
		elif event is InputEventJoypadMotion and old is InputEventJoypadMotion:
			remove_event = old.axis == event.axis
		elif event == null:
			remove_event = _slot_of(old) == slot
		if remove_event:
			InputMap.action_erase_event(action, old)
	if event != null:
		InputMap.action_add_event(action, event.duplicate())

static func reset_action(action: String) -> void:
	if not DEFAULTS.has(action):
		return
	for slot in 2:
		_set_slot(action, slot, DEFAULTS[action][slot])

static func reset_all() -> void:
	apply_defaults()

static func key_label(action: String) -> String:
	return event_label(_event_in_slot(action, 0))

static func pad_label(action: String) -> String:
	var labels: Array[String] = []
	for event in InputMap.action_get_events(action):
		if not event is InputEventKey:
			labels.append(event_label(event))
	return " + ".join(labels)

static func action_label(action: String) -> String:
	return "%s / %s" % [key_label(action), pad_label(action)]

static func event_label(event: InputEvent) -> String:
	if event == null:
		return "—"
	if event is InputEventKey:
		var key := event as InputEventKey
		match key.physical_keycode:
			KEY_SPACE: return "Espaço"
			KEY_ENTER: return "Enter"
			KEY_ESCAPE: return "Esc"
			KEY_LEFT: return "Seta para esquerda"
			KEY_RIGHT: return "Seta para direita"
			KEY_UP: return "Seta para cima"
			KEY_DOWN: return "Seta para baixo"
			KEY_TAB: return "Tab"
			_: return OS.get_keycode_string(key.physical_keycode)
	if event is InputEventJoypadButton:
		var b := (event as InputEventJoypadButton).button_index
		var labels := {JOY_BUTTON_A:"A", JOY_BUTTON_B:"B", JOY_BUTTON_X:"X", JOY_BUTTON_Y:"Y", JOY_BUTTON_LEFT_SHOULDER:"LB", JOY_BUTTON_RIGHT_SHOULDER:"RB", JOY_BUTTON_LEFT_STICK:"LS", JOY_BUTTON_RIGHT_STICK:"RS", JOY_BUTTON_BACK:"View", JOY_BUTTON_START:"Menu", JOY_BUTTON_GUIDE:"Xbox", JOY_BUTTON_PADDLE1:"Traseiro 1", JOY_BUTTON_PADDLE2:"Traseiro 2", JOY_BUTTON_DPAD_UP:"Direcional ↑", JOY_BUTTON_DPAD_DOWN:"Direcional ↓", JOY_BUTTON_DPAD_LEFT:"Direcional ←", JOY_BUTTON_DPAD_RIGHT:"Direcional →"}
		return labels.get(b, "Botão %d" % b)
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		if motion.axis == JOY_AXIS_TRIGGER_LEFT: return "LT"
		if motion.axis == JOY_AXIS_TRIGGER_RIGHT: return "RT"
		if motion.axis == JOY_AXIS_LEFT_X:
			return "Analógico esquerdo ←" if motion.axis_value < 0 else "Analógico esquerdo →"
	return "Desconhecido"
