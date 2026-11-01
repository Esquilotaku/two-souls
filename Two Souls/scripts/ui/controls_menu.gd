extends Control

signal closed

var _rows: Dictionary = {}
var _capture_action := ""
var _capture_slot := -1
var _scroll: ScrollContainer
var _list: VBoxContainer
var _status: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.025, 0.04, 0.09, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var frame := VBoxContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 20)
	frame.add_theme_constant_override("margin_right", 20)
	frame.add_theme_constant_override("margin_top", 12)
	frame.add_theme_constant_override("margin_bottom", 12)
	add_child(frame)
	var title := Label.new()
	title.text = "Controles"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(title)
	_status = Label.new()
	_status.text = "Selecione uma tecla ou botão; Esc cancela."
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(_status)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_list)
	for action in InputConfig.DEFAULTS:
		_add_row(action)
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	frame.add_child(footer)
	var reset := Button.new()
	reset.text = "Restaurar padrões"
	reset.pressed.connect(_reset)
	footer.add_child(reset)
	var done := Button.new()
	done.text = "Voltar"
	done.pressed.connect(_close)
	footer.add_child(done)

func _add_row(action: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 26
	_list.add_child(row)
	var name := Label.new()
	name.text = InputConfig.ACTION_NAMES.get(action, action)
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name)
	var key := Button.new()
	key.custom_minimum_size.x = 155
	key.pressed.connect(_begin_capture.bind(action, 0))
	row.add_child(key)
	var pad := Button.new()
	pad.custom_minimum_size.x = 155
	pad.pressed.connect(_begin_capture.bind(action, 1))
	row.add_child(pad)
	_rows[action] = [key, pad]
	_refresh_row(action)

func _refresh_row(action: String) -> void:
	if not _rows.has(action): return
	var events := InputMap.action_get_events(action)
	for slot in 2:
		var button: Button = _rows[action][slot]
		button.text = ("Tecla: " + InputConfig.key_label(action)) if slot == 0 else ("Controle: " + InputConfig.pad_label(action))

func _begin_capture(action: String, slot: int) -> void:
	_capture_action = action
	_capture_slot = slot
	_status.text = "Aperte a nova tecla ou botão (Esc cancela)."

func _input(event: InputEvent) -> void:
	if _capture_action.is_empty():
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		if (event as InputEventKey).physical_keycode == KEY_ESCAPE:
			_cancel_capture()
		else:
			_apply_capture(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		_apply_capture(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.65:
		_apply_capture(event)
		get_viewport().set_input_as_handled()

func _apply_capture(event: InputEvent) -> void:
	var displaced := InputConfig.remap(_capture_action, event, _capture_slot)
	_capture_action = ""
	_capture_slot = -1
	_status.text = "Conflito trocado com %s." % InputConfig.ACTION_NAMES.get(displaced, displaced) if not displaced.is_empty() else "Controle atualizado."
	for action in _rows: _refresh_row(action)
	InputConfig.save()

func _cancel_capture() -> void:
	_capture_action = ""
	_capture_slot = -1
	_status.text = "Alteração cancelada."

func _reset() -> void:
	InputConfig.reset_all()
	InputConfig.save()
	for action in _rows: _refresh_row(action)
	_status.text = "Padrões restaurados."

func _close() -> void:
	closed.emit()
	queue_free()
