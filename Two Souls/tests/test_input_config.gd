extends SceneTree

const TEST_PATH := "user://test_controles.cfg"
var failures := 0

func _init() -> void:
	InputConfig.apply_defaults()
	for action in InputConfig.DEFAULTS:
		_expect(InputMap.has_action(action), "ação ausente: %s" % action)
		_expect(InputMap.action_get_events(action).size() == InputConfig.DEFAULTS[action].size(), "eventos duplicados/ausentes: %s" % action)
	InputConfig.apply_defaults()
	for action in InputConfig.DEFAULTS:
		_expect(InputMap.action_get_events(action).size() == InputConfig.DEFAULTS[action].size(), "apply_defaults duplicou %s" % action)

	var z := InputEventKey.new()
	z.physical_keycode = KEY_Z
	_expect(InputConfig.remap("jump", z, 0).is_empty(), "remapeamento sem conflito")
	var displaced := InputConfig.remap("attack", z, 0)
	_expect(displaced == "jump", "conflito deveria deslocar jump, recebeu %s" % displaced)
	_expect(InputConfig.action_label("attack").begins_with("Z /"), "tecla remapeada não foi aplicada")
	_expect(InputConfig.action_label("jump").begins_with("A /"), "troca não preservou tecla anterior")

	_expect(InputConfig.save(TEST_PATH), "save de teste falhou")
	InputConfig.reset_all()
	_expect(InputConfig.load_saved(TEST_PATH), "load de teste falhou")
	_expect(InputConfig.action_label("attack").begins_with("Z /"), "load não preservou remapeamento")
	InputConfig.reset_action("attack")
	_expect(InputConfig.action_label("attack").begins_with("A /"), "reset_action não restaurou padrão")
	_expect(DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH)) == OK, "não apagou arquivo de teste")
	if failures > 0:
		push_error("test_input_config: %d falha(s)" % failures)
	quit(1 if failures > 0 else 0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FALHOU: " + message)
