class_name OrionCombo
extends RefCounted
## Combos de comando do Kaê (docs/design/combos-proposta.md, aprovada pelo Gabriel em 01/11/2026).
## O player.gd chama update() a cada quadro físico; aqui ficam a fila de comandos, a escolha do
## golpe pela seta segurada e as caixas de acerto. Os números são provisórios: ajustar jogando.

## Apertar A até este tempo antes de o golpe atual acabar já conta como o próximo (buffer).
## 0,45 s porque cada golpe dura ~0,25 s mais a pausa do impacto: apertar num ritmo constante não pode perder toque.
const BUFFER := 0.45
## Depois de um golpe acabar, o combo continua se o próximo A vier dentro desta janela.
const CHAIN_WINDOW := 0.45
## Golpes no ar por pulo.
const MAX_AIR_HITS := 3
## Tempo do contador "N golpes" na tela depois do último acerto.
const COUNTER_TIME := 1.2

## duração (s), momento do acerto (s), caixa (deslocamento e tamanho, com x virado para a frente),
## dano, empurrão (x para a frente, y negativo = para cima), quanto o Kaê anda para a frente.
## Os golpes do meio do combo empurram pouco, para o inimigo continuar ao alcance do próximo golpe.
const MOVES := {
	"a1": {"time": 0.22, "hit": 0.06, "offset": Vector2(34, -8), "size": Vector2(62, 40), "damage": 1, "knock": Vector2(40, -30), "step": 40.0},
	"a2": {"time": 0.24, "hit": 0.07, "offset": Vector2(36, -8), "size": Vector2(68, 44), "damage": 1, "knock": Vector2(50, -30), "step": 50.0},
	"a3": {"time": 0.30, "hit": 0.10, "offset": Vector2(0, -10), "size": Vector2(118, 50), "damage": 1, "knock": Vector2(60, -50), "step": 20.0},
	"a4": {"time": 0.42, "hit": 0.14, "offset": Vector2(44, -10), "size": Vector2(104, 62), "damage": 2, "knock": Vector2(380, -220), "step": 90.0, "animal": true},
	"launcher": {"time": 0.34, "hit": 0.09, "offset": Vector2(28, -30), "size": Vector2(62, 84), "damage": 1, "knock": Vector2(40, -720), "step": 20.0, "stun": 0.8},
	"sweep": {"time": 0.34, "hit": 0.09, "offset": Vector2(32, 22), "size": Vector2(86, 30), "damage": 1, "knock": Vector2(40, -110), "step": 30.0, "stun": 0.9},
	"upper": {"time": 0.28, "hit": 0.07, "offset": Vector2(14, -52), "size": Vector2(54, 74), "damage": 1, "knock": Vector2(20, -460), "step": 0.0, "stun": 0.6},
	"lunge": {"time": 0.30, "hit": 0.05, "offset": Vector2(38, -6), "size": Vector2(76, 40), "damage": 1, "knock": Vector2(320, -90), "step": 0.0, "dash": 760.0, "continuous": true},
	"air": {"time": 0.22, "hit": 0.06, "offset": Vector2(32, -4), "size": Vector2(66, 50), "damage": 1, "knock": Vector2(30, -120), "step": 0.0},
	"dive": {"time": 0.9, "hit": 0.0, "offset": Vector2(4, 34), "size": Vector2(44, 46), "damage": 1, "knock": Vector2(60, 200), "step": 0.0},
}

var move := ""
var move_time := 0.0
var _hit_done := false
var _buffer := 0.0
## Toques de A guardados na fila (até 2): apertar rápido durante um golpe não perde o próximo.
var _queued := 0
## Seta segurada no momento em que o A foi apertado (vale mesmo se soltar antes de o golpe começar).
var _buffer_up := false
var _buffer_down := false
var _chain_step := 0
var _chain_timer := 0.0
var _air_hits := 0
var hits_in_a_row := 0
var counter_timer := 0.0
## Quem já levou o golpe atual (para não acertar duas vezes no mesmo golpe).
var _hit_targets: Array = []

func is_attacking() -> bool:
	return move != ""

## Lê o A em todo quadro, inclusive durante a pausa de impacto (hit-stop), para nenhum toque se perder.
func read_input() -> void:
	if Input.is_action_just_pressed("attack"):
		_buffer = BUFFER
		_queued = mini(_queued + 1, 2)
		_buffer_up = Input.is_action_pressed("look_up")
		_buffer_down = Input.is_action_pressed("look_down")

## Chamado pelo player a cada quadro físico. Devolve o golpe que começou neste quadro ("" se nenhum).
func update(player: CharacterBody2D, delta: float) -> String:
	counter_timer = maxf(0.0, counter_timer - delta)
	if counter_timer <= 0.0:
		hits_in_a_row = 0
	_buffer = maxf(0.0, _buffer - delta)
	if _buffer <= 0.0:
		_queued = 0
	if player.is_on_floor():
		_air_hits = 0
	var started := ""
	if move != "":
		move_time += delta
		_run_move(player)
		var info: Dictionary = MOVES[move]
		var ends := move_time >= float(info["time"]) or (move == "dive" and player.is_on_floor())
		if ends:
			move = ""
			_chain_timer = CHAIN_WINDOW
	else:
		_chain_timer = maxf(0.0, _chain_timer - delta)
		if _chain_timer <= 0.0:
			_chain_step = 0
	if move == "" and _queued > 0:
		started = _choose(player)
		if started != "":
			_queued -= 1
			if _queued > 0:
				_buffer = BUFFER
			_start(player, started)
	return started

## A seta segurada no momento do A escolhe o golpe (tabela da proposta).
func _choose(player: CharacterBody2D) -> String:
	var up := _buffer_up or Input.is_action_pressed("look_up")
	var down := _buffer_down or Input.is_action_pressed("look_down")
	if player.is_dashing():
		return "lunge"
	if not player.is_on_floor():
		if down:
			return "dive"
		if _air_hits < MAX_AIR_HITS:
			_air_hits += 1
			return "air"
		return ""
	if _chain_step == 2 and up:
		_chain_step = 0
		return "launcher"
	if _chain_step == 2 and down:
		_chain_step = 0
		return "sweep"
	if _chain_step == 0 and up:
		return "upper"
	_chain_step += 1
	var step := "a%d" % _chain_step
	if _chain_step >= 4:
		_chain_step = 0
	return step

func _start(player: CharacterBody2D, name: String) -> void:
	move = name
	move_time = 0.0
	_hit_done = false
	_hit_targets.clear()
	var info: Dictionary = MOVES[name]
	if info.has("dash"):
		player.velocity.x = float(info["dash"]) * player.facing
	if name == "dive":
		player.velocity = Vector2(140.0 * player.facing, 900.0)

func _run_move(player: CharacterBody2D) -> void:
	var info: Dictionary = MOVES[move]
	if move == "air":
		# Golpe no ar segura o Kaê no lugar por um instante, como nos jogos de fliperama.
		player.velocity.y = minf(player.velocity.y, 40.0)
	elif move == "dive":
		player.velocity.y = maxf(player.velocity.y, 900.0)
	elif player.is_on_floor():
		# No chão, o golpe trava a corrida e dá um passinho para a frente.
		var step := float(info.get("step", 0.0))
		var lunge := float(info.get("dash", 0.0))
		player.velocity.x = player.facing * (lunge if lunge > 0.0 else step * 4.0 * maxf(0.0, 1.0 - move_time / float(info["time"])))
	var continuous := move == "dive" or (bool(info.get("continuous", false)) and _hit_targets.is_empty())
	if continuous or (not _hit_done and move_time >= float(info["hit"])):
		_hit_done = true
		var hit_any := _apply_hits(player, info)
		if hit_any and move == "dive":
			# Quica no inimigo (estilo pogo) e encerra o mergulho.
			player.velocity.y = -560.0
			move = ""
			_chain_timer = CHAIN_WINDOW

## Acerta inimigos e cenário atacável dentro da caixa do golpe. Devolve true se acertou alguém.
func _apply_hits(player: CharacterBody2D, info: Dictionary) -> bool:
	var offset: Vector2 = info["offset"]
	var size: Vector2 = info["size"]
	var center := player.global_position + Vector2(offset.x * player.facing, offset.y)
	# A caixa cresce um pouco para contar o corpo do alvo (a posição dele é o centro).
	var box := Rect2(center - size * 0.5 - Vector2(14, 20), size + Vector2(28, 40))
	var hit_any := false
	for group in ["hostile", "attackable_scenery"]:
		for target in player.get_tree().get_nodes_in_group(group):
			if not is_instance_valid(target) or _hit_targets.has(target):
				continue
			if not box.has_point(target.global_position):
				continue
			_hit_targets.append(target)
			hit_any = true
			var damage := int(info["damage"])
			if player.has_method("_hit_amount") and damage == 1:
				damage = player._hit_amount()
			target.call("take_hit", damage)
			if is_instance_valid(target) and target.has_method("apply_knockback"):
				var knock: Vector2 = info["knock"]
				target.call("apply_knockback", Vector2(knock.x * player.facing, knock.y), float(info.get("stun", 0.35)))
	if hit_any:
		hits_in_a_row += 1
		counter_timer = COUNTER_TIME
		player.hit_stop = 0.05
	return hit_any
