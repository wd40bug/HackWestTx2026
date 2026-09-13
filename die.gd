class_name Die
extends Node

@export var die_index: int

@export var side1: Die_side = Die_side.new(GameManager.modifier.none, 1, die_index)
@export var side2: Die_side = Die_side.new(GameManager.modifier.none, 2, die_index)
@export var side3: Die_side = Die_side.new(GameManager.modifier.none, 3, die_index)
@export var side4: Die_side = Die_side.new(GameManager.modifier.none, 4, die_index)
@export var side5: Die_side = Die_side.new(GameManager.modifier.none, 5, die_index)
@export var side6: Die_side = Die_side.new(GameManager.modifier.none, 6, die_index)

@onready var die_sides: Array[Die_side] = [side1, side2, side3, side4, side5, side6]
@export var die_ability: Novilty_ability


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
	
	for die in die_sides:
		die.side_index = die_index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(die_state == 0):
		button.disabled = true
	elif(die_state == 7):
		button.disabled = true
		animated_sprite.show()
	elif(die_state == 8):
		button.disabled = true
		animated_sprite.show()
		die_state = 1
	else:
		button.disabled = disabled_override
		set_current(die_state - 1)

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

func roll() -> int:
	var total_weight = 0
	for side in die_sides:
		total_weight += 1 + (1 if side.side_ability == GameManager.modifier.weighted else 0)
	
	var random_number: float = randf_range(0.0, total_weight)
	var acc_weight: float = 0.0
	
	
	for i in range(die_sides.size()):
		var side: Die_side = die_sides[i]
		acc_weight += 1 + (1 if side.side_ability == GameManager.modifier.weighted else 0)
		if random_number < acc_weight:
			die_state = side.side_num
			emit_signal("die_roll_state", die_state)
			return i # Return the array index (0-5)
	assert(false)
	return 0

func roll_die():

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
	
	sound_effect.play()
	$Timer.start()
	$OverallTimer.start()
	
	await $OverallTimer.timeout
	$Timer.stop()
	
	var v = roll()
	return die_sides[v]

var pip_resources = {
	Die_side.DieType.ONE: preload("res://Assets/Dice Assetes/One.png"),
	Die_side.DieType.TWO: preload("res://Assets/Dice Assetes/Two.png"),
	Die_side.DieType.THREE: preload("res://Assets/Dice Assetes/Three.png"),
	Die_side.DieType.FOUR: preload("res://Assets/Dice Assetes/Four.png"),
	Die_side.DieType.FIVE: preload("res://Assets/Dice Assetes/Five.png"),
	Die_side.DieType.SIX: preload("res://Assets/Dice Assetes/Six.png"),
	Die_side.DieType.WILD: preload("res://Assets/Dice Assetes/Wild.png")
}

var mod_resources = {
	GameManager.modifier.add: preload("res://Assets/Modifiers/Add.png"),
	GameManager.modifier.multmod: preload("res://Assets/Modifiers/MultModifier.png"),
	GameManager.modifier.daisy: preload("res://Assets/Modifiers/Daisy.png"),
	GameManager.modifier.coins: preload("res://Assets/Modifiers/Coins.png"),
	GameManager.modifier.weighted: preload("res://Assets/Modifiers/Weighted.png"),
	GameManager.modifier.none: null
}

func shake():
	$AnimatedSprite2D/AnimationPlayer.play("shake")

func set_current(i: int):
	$AnimatedSprite2D/PipRect.texture = pip_resources[die_sides[i].side_num]
	$AnimatedSprite2D/ModifierRect.texture = mod_resources[die_sides[i].side_ability]

func tick_animation():
	var i = roll()
	set_current(i)
	$Timer.start()

func score() -> void:
	$AnimatedSprite2D/AnimationPlayer.play("score")

func _on_button_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		$"AnimatedSprite2D/AnimationPlayer".play("unselect")
	if(toggled_on and die_state != 0 and not button.disabled):
		$AnimatedSprite2D/AnimationPlayer.play("select")
		#animated_sprite.modulate = Color(10, 10, 10, 1)
		emit_signal("clicked_signal", toggled_on, die_index)
	elif(die_state != 7):
		animated_sprite.show()
		emit_signal("clicked_signal", toggled_on, die_index)
	elif(die_state == 7):
		emit_signal("clicked_signal", toggled_on, die_index)
