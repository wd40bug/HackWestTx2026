class_name Die
extends Node

var die_sides: Array[Die_side] = []
var die_ability: Novilty_ability
enum Parameter {WEIGHT, ABILITY, NUM}
enum Novilty_ability {NONE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	var total_weight: float = 0.0
	for side in die_sides:
		total_weight += side.side_weight
	
	var random_number: float = randf_range(0.0, total_weight)
	var acc_weight: float = 0.0
	
	for side in die_sides:
		acc_weight += side.side_weight
		if random_number < acc_weight:
			return side
		
