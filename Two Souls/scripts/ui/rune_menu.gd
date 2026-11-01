extends Control

signal closed

var state: RuneState
var at_shrine := false
var _list: VBoxContainer
var _summary: Label
var _status: Label

func setup(new_state: RuneState, shrine: bool) -> void:
	state = new_state
	at_shrine = shrine
	if is_node_ready(): _refresh()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	_refresh()

func _build() -> void:
	var background := ColorRect.new()
	background.color = Color(0.025, 0.04, 0.09, 0.97)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var frame := VBoxContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 16)
	frame.add_theme_constant_override("margin_right", 16)
	frame.add_theme_constant_override("margin_top", 8)
	frame.add_theme_constant_override("margin_bottom", 8)
	add_child(frame)
	var title := Label.new()
	title.text = "Runas"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(title)
	_summary = Label.new()
	_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(_summary)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frame.add_child(_status)
	var back := Button.new()
	back.text = "Voltar"
	back.pressed.connect(_close)
	frame.add_child(back)

func _refresh() -> void:
	if state == null or _list == null: return
	for child in _list.get_children(): child.queue_free()
	_summary.text = "Espaços: %d/%d     Fragmentos: %d" % [state.equipped_runes.size(), state.slots, state.fragments]
	for rune_id in RuneCatalog.RUNES:
		var info: Dictionary = RuneCatalog.info(rune_id)
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 34
		_list.add_child(row)
		var text := Label.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if state.found_runes.has(rune_id):
			text.text = "%s — Corrompida" % info["name"]
		elif state.purified_runes.has(rune_id):
			var level: int = state.purified_runes[rune_id]
			text.text = "%s — Nível %d — %s" % [info["name"], level, RuneCatalog.effect_text(rune_id, level)]
			if state.equipped_runes.has(rune_id): text.text += " — Equipada"
		else:
			continue
		row.add_child(text)
		if state.found_runes.has(rune_id):
			if at_shrine: _add_button(row, "Purificar", _act.bind("purify", rune_id))
		elif state.equipped_runes.has(rune_id):
			_add_button(row, "Tirar", _act.bind("unequip", rune_id))
		else:
			_add_button(row, "Equipar", _act.bind("equip", rune_id))
			_add_button(row, "Melhorar", _act.bind("upgrade", rune_id))

func _add_button(row: HBoxContainer, label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size.x = 78
	button.pressed.connect(callback)
	row.add_child(button)

func _act(action: String, rune_id: String) -> void:
	var success := false
	match action:
		"purify": success = state.purify(rune_id)
		"equip": success = state.equip(rune_id)
		"unequip": success = state.unequip(rune_id)
		"upgrade": success = state.upgrade(rune_id)
	_status.text = "Ação concluída." if success else "Não foi possível: confira espaços, santuário ou fragmentos."
	_refresh()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	closed.emit()
	queue_free()
