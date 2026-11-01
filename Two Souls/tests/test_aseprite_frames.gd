extends SceneTree
## Teste sem janela: confere se cada JSON do Aseprite em assets/sprites vira SpriteFrames.
## Uso: godot --headless --path "Two Souls" -s res://tests/test_aseprite_frames.gd

func _init() -> void:
	var failures := 0
	var checked := 0
	var dir := DirAccess.open("res://assets/sprites")
	for file_name in dir.get_files():
		if file_name.get_extension() != "json":
			continue
		checked += 1
		var path := "res://assets/sprites/%s" % file_name
		var frames := AsepriteFrames.load_frames(path)
		if frames == null or frames.get_animation_names().is_empty():
			push_error("FALHOU: %s" % path)
			failures += 1
			continue
		for anim in frames.get_animation_names():
			if frames.get_frame_count(anim) == 0:
				push_error("FALHOU: %s animação %s sem quadros" % [path, anim])
				failures += 1
		print("ok: %s -> %s" % [file_name, frames.get_animation_names()])
	print("Sprites do Aseprite conferidos: %d, falhas: %d" % [checked, failures])
	quit(1 if failures > 0 else 0)
