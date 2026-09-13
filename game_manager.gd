extends Node
class_name GameManager

var level = 1
var dice_amm = 6
var dice_side_num = ([
	[1,2,3,4,5,6],
	[1,2,3,4,5,6],
	[1,2,3,4,5,6],
	[1,2,3,4,5,6],
	[1,2,3,4,5,6],
	[1,2,3,4,5,6]
])

enum modifier {add, coins, daisy, multmod, weighted, none}

var dice_side_mod = ([
	[modifier.none,modifier.none,modifier.none,modifier.none,modifier.none,modifier.none],
	[modifier.none,modifier.none,modifier.none,modifier.none,modifier.none,modifier.none],
	[modifier.none,modifier.none,modifier.none,modifier.none,modifier.none,modifier.none],
	[modifier.none,modifier.none,modifier.none,modifier.none,modifier.none,modifier.none],
	[modifier.none,modifier.none,modifier.none,modifier.none,modifier.none,modifier.none],
	[modifier.none,modifier.none,modifier.none,modifier.none,modifier.none,modifier.none],
])

var cups = []

var nov_dice = []

var money = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_side(die, side_selected, new_side, new_mod):
	dice_side_num[die][side_selected] = new_side
	dice_side_mod[die][side_selected] = new_mod
