class_name Die
extends Node

var die_sides: Array[Die_side] = []
var die_ability: Novilty_ability
var die_index: int

enum Parameter {WEIGHT, ABILITY, NUM}
enum Novilty_ability {NONE}

# 0 = rolling
# 1-6 is side to show
# 7 is unclickable
# 8 is transfer from unclickable to clickable
enum DieState {ROLLING, ONE, TWO, THREE, FOUR, FIVE, SIX, UNCLICKABLE, TRANSFER }
var die_state = DieState.ONE

var disabled_override: bool = false

signal die_roll_state(state: int)
signal clicked_signal(state: bool, index: int)

@onready var animated_sprite = $AnimatedSprite2D
@onready var button = $AnimatedSprite2D/Button
var sound_effect: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound_effect = AudioStreamPlayer.new()
	animated_sprite.add_child(sound_effect)
	
	button.disabled = true
	
	sound_effect.stream = load("res://sounds/die_rolling.mp3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not animated_sprite:
		return
	$AnimatedSprite2D.animation = "Roll"
	if(die_state == 0):
		button.disabled = true
		$AnimatedSprite2D.play()
	elif(die_state == 7):
		button.disabled = true
		animated_sprite.hide()
	elif(die_state == 8):
		button.disabled = true
		animated_sprite.show()
		die_state = 1
		print("Die index: ", die_index)
		print("Die state: ", die_state)
	else:
		button.disabled = disabled_override
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = die_state - 1
	

func create_sides(die_index: int):
	for i in range(0, 6):
		var side: Die_side = Die_side.new()
		side.set_values(1, 0, i + 1, die_index)
		die_sides.append(side)

# Modify a parameter of a side of the die
func modify_die_side_parameter(side: int, parameter: Parameter, value: int):
	if(parameter == Parameter.WEIGHT):
		die_sides[side].side_weight = value
	elif(parameter == Parameter.ABILITY):
		die_sides[side].side_ability = value
	elif(parameter == Parameter.NUM):
		die_sides[side].side_num = value
		
func print_die():
	print("Novilty ability: ", die_ability)
	print()
	for i in range(0, 6):
		print("side: ", i)
		die_sides[i].print_parameters()
		print()

# return one of the sides of the die, accounting for weight
func roll_die():
	sound_effect.play()
	die_state = 0
	emit_signal("die_roll_state", die_state)
	if get_tree():
		await get_tree().create_timer(.5).timeout
	else:
		var t = Timer.new()
		add_child(t)
		t.start(2)
		await t.timeout
		t.queue_free()
	var total_weight: float = 0.0
	for side in die_sides:
		total_weight += side.side_weight
	
	var random_number: float = randf_range(0.0, total_weight)
	var acc_weight: float = 0.0
	
	
	for side in die_sides:
		acc_weight += side.side_weight
		if random_number < acc_weight:
			die_state = side.side_num
			emit_signal("die_roll_state", die_state)
			return side
	
func _on_button_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		$"AnimatedSprite2D".position += Vector2(0, 32)
	if(toggled_on and die_state != 0 and not button.disabled):
		$"AnimatedSprite2D".position += Vector2(0, -32)
		#animated_sprite.modulate = Color(10, 10, 10, 1)
		emit_signal("clicked_signal", toggled_on, die_index)
	elif(die_state != 7):
		animated_sprite.show()
		emit_signal("clicked_signal", toggled_on, die_index)
	elif(die_state == 7):
		emit_signal("clicked_signal", toggled_on, die_index)
