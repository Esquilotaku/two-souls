class_name GameHud
extends Control
## HUD da partida, montado por código para a tela de 640x360.
## Referências do Gabriel (01/11/2026): Grand Chase (retrato e barras no canto) e o RPG do vídeo
## "3 meses criando meu jogo RPG com IA" (painéis em pixel art com moldura e barra de habilidades com a tecla embaixo).
## Não tem botões clicáveis: tudo é jogado no teclado ou no controle.

const FRAME_BG := Color("141a2b")
const FRAME_BORDER := Color("8d9ab8")
const FRAME_SHADOW := Color("070a12")
const HP_COLOR := Color("e2504a")
const MP_COLOR := Color("4a8fe2")
const XP_COLOR := Color("b9e05a")
const BOSS_COLOR := Color("c23b3b")
const TEXT_COLOR := Color("eef3ff")
const DIM_TEXT := Color("9fb0d0")

var _hp_fill: ColorRect
var _hp_text: Label
var _mp_fill: ColorRect
var _mp_text: Label
var _xp_fill: ColorRect
var _level_text: Label
var _place_text: Label
var _time_text: Label
var _objective_text: Label
var _message_text: Label
var _boss_box: Control
var _boss_name: Label
var _boss_fill: ColorRect
var _slots: Array[Dictionary] = []

const BAR_WIDTH := 116.0
const BOSS_BAR_WIDTH := 300.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_status()
	_build_place()
	_build_boss()
	_build_hotbar()
	_message_text = _label("", 13, TEXT_COLOR, Vector2(40, 262), Vector2(560, 24), HORIZONTAL_ALIGNMENT_CENTER)
	_message_text.add_theme_color_override("font_outline_color", FRAME_SHADOW)
	_message_text.add_theme_constant_override("outline_size", 4)

## info: dicionário montado pelo game.gd a cada quadro (ver _hud_info no game.gd).
func refresh(info: Dictionary) -> void:
	_set_bar(_hp_fill, _hp_text, int(info["health"]), int(info["max_health"]), BAR_WIDTH)
	_set_bar(_mp_fill, _mp_text, int(info["magic"]), int(info["max_magic"]), BAR_WIDTH)
	_xp_fill.size.x = BAR_WIDTH * clampf(float(info["xp"]) / maxf(1.0, float(info["xp_next"])), 0.0, 1.0)
	_level_text.text = "Nv %d" % int(info["level"])
	_place_text.text = info["place"]
	_time_text.text = info["time"]
	_objective_text.text = info.get("objective", "")
	var boss_max := int(info.get("boss_max", 0))
	_boss_box.visible = boss_max > 0
	if boss_max > 0:
		_boss_name.text = info["boss_name"]
		_boss_fill.size.x = BOSS_BAR_WIDTH * clampf(float(info["boss_health"]) / float(boss_max), 0.0, 1.0)
	var skills: Array = info.get("skills", [])
	for index in range(_slots.size()):
		var slot: Dictionary = _slots[index]
		var skill: Dictionary = skills[index] if index < skills.size() else {}
		var ready := bool(skill.get("unlocked", false))
		slot["icon"].text = skill.get("short", "")
		slot["icon"].add_theme_color_override("font_color", TEXT_COLOR if ready else DIM_TEXT.darkened(0.35))
		slot["key"].text = skill.get("key", "")
		var cooldown := clampf(float(skill.get("cooldown", 0.0)), 0.0, 1.0)
		slot["shade"].size.y = 26.0 * (1.0 if not ready else cooldown)
		slot["root"].visible = not skill.is_empty()

func set_message(text: String) -> void:
	_message_text.text = text

# --- Montagem ---

func _build_status() -> void:
	_frame(Vector2(6, 6), Vector2(186, 54))
	# Retrato: a cabeça do primeiro quadro do Orion, ampliada 2x.
	var portrait_frame := _frame(Vector2(10, 10), Vector2(46, 46), Color("23304a"))
	var portrait := TextureRect.new()
	portrait.texture = _portrait_texture()
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(2, 2)
	portrait.size = Vector2(42, 42)
	portrait_frame.add_child(portrait)
	_level_text = _label("Nv 1", 9, TEXT_COLOR, Vector2(12, 45), Vector2(42, 12), HORIZONTAL_ALIGNMENT_CENTER)
	_level_text.add_theme_color_override("font_outline_color", FRAME_SHADOW)
	_level_text.add_theme_constant_override("outline_size", 3)
	var hp := _bar(Vector2(62, 12), HP_COLOR, "HP")
	_hp_fill = hp[0]
	_hp_text = hp[1]
	var mp := _bar(Vector2(62, 28), MP_COLOR, "MP")
	_mp_fill = mp[0]
	_mp_text = mp[1]
	var xp_back := ColorRect.new()
	xp_back.color = FRAME_SHADOW
	xp_back.position = Vector2(62, 45)
	xp_back.size = Vector2(BAR_WIDTH, 4)
	add_child(xp_back)
	_xp_fill = ColorRect.new()
	_xp_fill.color = XP_COLOR
	_xp_fill.position = xp_back.position
	_xp_fill.size = Vector2(0, 4)
	add_child(_xp_fill)

func _build_place() -> void:
	_frame(Vector2(452, 6), Vector2(182, 34))
	_place_text = _label("", 9, TEXT_COLOR, Vector2(458, 8), Vector2(170, 14), HORIZONTAL_ALIGNMENT_RIGHT)
	_time_text = _label("", 9, Color("f2d8a0"), Vector2(458, 22), Vector2(170, 14), HORIZONTAL_ALIGNMENT_RIGHT)
	_objective_text = _label("", 9, Color("ffe2a0"), Vector2(420, 44), Vector2(214, 14), HORIZONTAL_ALIGNMENT_RIGHT)
	_objective_text.add_theme_color_override("font_outline_color", FRAME_SHADOW)
	_objective_text.add_theme_constant_override("outline_size", 3)

func _build_boss() -> void:
	_boss_box = Control.new()
	_boss_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_boss_box)
	var frame := _frame(Vector2(164, 62), Vector2(BOSS_BAR_WIDTH + 12, 30), FRAME_BG, _boss_box)
	_boss_name = _label("", 9, TEXT_COLOR, Vector2(170, 63), Vector2(BOSS_BAR_WIDTH, 13), HORIZONTAL_ALIGNMENT_CENTER, _boss_box)
	var back := ColorRect.new()
	back.color = FRAME_SHADOW
	back.position = Vector2(170, 77)
	back.size = Vector2(BOSS_BAR_WIDTH, 9)
	_boss_box.add_child(back)
	_boss_fill = ColorRect.new()
	_boss_fill.color = BOSS_COLOR
	_boss_fill.position = back.position
	_boss_fill.size = Vector2(BOSS_BAR_WIDTH, 9)
	_boss_box.add_child(_boss_fill)
	frame.move_to_front()
	_boss_name.move_to_front()
	back.move_to_front()
	_boss_fill.move_to_front()
	_boss_box.visible = false

## Barra de habilidades embaixo, com a tecla de cada uma (lança, super soco, magia; a transformação entra quando existir).
func _build_hotbar() -> void:
	var count := 3
	var slot_size := 30.0
	var gap := 6.0
	var width := count * slot_size + (count - 1) * gap + 12.0
	var origin := Vector2((640.0 - width) * 0.5, 312)
	_frame(origin, Vector2(width, 44))
	for index in range(count):
		var root := Control.new()
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.position = origin + Vector2(6 + index * (slot_size + gap), 4)
		add_child(root)
		_frame(Vector2.ZERO, Vector2(slot_size, slot_size), Color("23304a"), root)
		var icon := _label("", 9, TEXT_COLOR, Vector2(0, 2), Vector2(slot_size, slot_size - 4), HORIZONTAL_ALIGNMENT_CENTER, root)
		icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var shade := ColorRect.new()
		shade.color = Color(0, 0, 0, 0.55)
		shade.position = Vector2(2, 2)
		shade.size = Vector2(slot_size - 4, 0)
		root.add_child(shade)
		var key := _label("", 8, Color("ffe08a"), Vector2(0, slot_size - 1), Vector2(slot_size, 10), HORIZONTAL_ALIGNMENT_CENTER, root)
		key.add_theme_color_override("font_outline_color", FRAME_SHADOW)
		key.add_theme_constant_override("outline_size", 3)
		_slots.append({"root": root, "icon": icon, "shade": shade, "key": key})

# --- Peças ---

## Painel com moldura clara de 1 px e sombra escura por fora, no estilo pixel art.
func _frame(at: Vector2, size_px: Vector2, fill: Color = FRAME_BG, parent: Node = self) -> Panel:
	var panel := Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = at
	panel.size = size_px
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill, 0.92)
	style.border_color = FRAME_BORDER
	style.set_border_width_all(1)
	style.shadow_color = FRAME_SHADOW
	style.shadow_size = 1
	style.shadow_offset = Vector2(1, 1)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

## Barra com rótulo ("HP"), fundo escuro, preenchimento colorido e texto "atual/máximo".
func _bar(at: Vector2, color: Color, tag: String) -> Array:
	_label(tag, 8, DIM_TEXT, at + Vector2(0, 0), Vector2(16, 12))
	var back := ColorRect.new()
	back.color = FRAME_SHADOW
	back.position = at + Vector2(16, 1)
	back.size = Vector2(BAR_WIDTH - 16, 11)
	add_child(back)
	var fill := ColorRect.new()
	fill.color = color
	fill.position = back.position
	fill.size = back.size
	add_child(fill)
	var shine := ColorRect.new()
	shine.color = Color(1, 1, 1, 0.18)
	shine.position = back.position
	shine.size = Vector2(back.size.x, 3)
	add_child(shine)
	var text := _label("", 8, TEXT_COLOR, back.position, back.size, HORIZONTAL_ALIGNMENT_CENTER)
	text.add_theme_color_override("font_outline_color", FRAME_SHADOW)
	text.add_theme_constant_override("outline_size", 3)
	return [fill, text]

func _set_bar(fill: ColorRect, text: Label, value: int, maximum: int, width: float) -> void:
	fill.size.x = (width - 16.0) * clampf(float(value) / maxf(1.0, float(maximum)), 0.0, 1.0)
	text.text = "%d / %d" % [value, maximum]

func _label(text: String, size: int, color: Color, at: Vector2, box: Vector2, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, parent: Node = self) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.position = at
	label.size = box
	label.clip_text = true
	parent.add_child(label)
	return label

func _portrait_texture() -> Texture2D:
	var frames := AsepriteFrames.load_frames("res://assets/sprites/orion.json")
	if frames == null or not frames.has_animation("idle") or frames.get_frame_count("idle") == 0:
		return null
	var first := frames.get_frame_texture("idle", 0) as AtlasTexture
	if first == null:
		return null
	# Cabeça do Orion: quadro de 160x96 com o pé em (64, 88) e a cabeça entre y 14 e 44.
	var head := AtlasTexture.new()
	head.atlas = first.atlas
	head.region = Rect2(first.region.position + Vector2(44, 12), Vector2(36, 36))
	return head
