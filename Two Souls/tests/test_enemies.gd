extends SceneTree
## Confere os três inimigos provisórios, a colisão e a reação aos golpes.

var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	await process_frame
	_check_kind("corrupted_runner", Vector2(34, 72))
	_check_kind("tribal_spearman", Vector2(28, 76))
	_check_kind("giant_beast", Vector2(56, 100))
	print("Inimigos conferidos, falhas: %d" % failures)
	quit(1 if failures > 0 else 0)

func _check_kind(enemy_kind: String, expected_size: Vector2) -> void:
	var foe := ForestFoe.new()
	foe.kind = enemy_kind
	foe.health = 3
	root.add_child(foe)
	await process_frame
	var collision := foe.get_node("CollisionShape2D") as CollisionShape2D
	var shape := collision.shape as RectangleShape2D
	_expect(shape.size == expected_size, "%s tem colisão %s" % [enemy_kind, shape.size])
	foe.apply_knockback(Vector2(135, -280), 0.7)
	_expect(foe.velocity == Vector2(135, -280), "%s recebe empurrão" % enemy_kind)
	_expect(foe.stun_timer >= 0.7, "%s fica atordoado" % enemy_kind)
	foe.take_hit(1)
	_expect(foe.health == 2 and foe.has_been_hit, "%s perde vida no primeiro golpe" % enemy_kind)
	foe.take_hit(2)
	await process_frame
	_expect(not is_instance_valid(foe), "%s morre ao perder toda a vida" % enemy_kind)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FALHOU: " + message)
