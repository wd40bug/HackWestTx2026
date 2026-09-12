class_name Die_side
extends Node

var side_weight: int
var side_ability: int
var side_num: int
enum Side_ability {NONE}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_values(weight, ability: Side_ability, num):
	side_weight = weight
	side_ability = ability
	side_num = num

# function to do the side ability based on the ability enum
func do_side_ability():
	pass

func print_parameters():
	print("side_weight: ", side_weight)
	print("side_ability: ", side_ability)
	print("side_num: ", side_num)
