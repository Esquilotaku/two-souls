class_name AsepriteFrames
extends RefCounted
## Monta um SpriteFrames a partir do PNG + JSON exportados pelo Aseprite
## (`pipeline/export-aseprite.ps1`). Cada tag do Aseprite vira uma animação;
## sem tags, todos os quadros viram a animação "default".

static func load_frames(json_path: String, loop: bool = true) -> SpriteFrames:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("AsepriteFrames: não foi possível abrir %s" % json_path)
		return null
	var data: Variant = JSON.parse_string(file.get_as_text())
	if not data is Dictionary or not data.has("frames") or not data.has("meta"):
		push_error("AsepriteFrames: JSON inválido em %s (exporte com --format json-array)" % json_path)
		return null

	var meta: Dictionary = data["meta"]
	var texture: Texture2D = load(json_path.get_base_dir().path_join(String(meta["image"])))
	if texture == null:
		push_error("AsepriteFrames: imagem %s não encontrada" % meta["image"])
		return null

	var regions: Array[Rect2] = []
	var durations: Array[float] = []
	for entry: Dictionary in data["frames"]:
		var rect: Dictionary = entry["frame"]
		regions.append(Rect2(rect["x"], rect["y"], rect["w"], rect["h"]))
		durations.append(float(entry["duration"]) / 1000.0)

	var tags: Array = meta.get("frameTags", [])
	if tags.is_empty():
		tags = [{"name": "default", "from": 0, "to": regions.size() - 1}]

	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for tag: Dictionary in tags:
		var anim := StringName(tag["name"])
		frames.add_animation(anim)
		frames.set_animation_loop(anim, loop)
		# Com 1 fps, a duração relativa de cada quadro vira segundos reais.
		frames.set_animation_speed(anim, 1.0)
		for index in range(int(tag["from"]), int(tag["to"]) + 1):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = regions[index]
			frames.add_frame(anim, atlas, durations[index])
	return frames
