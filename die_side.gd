class_name Die_side
extends Resource

enum DieType { ONE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5, SIX = 6, WILD}

@export var side_ability: GameManager.modifier
@export var side_num: DieType

# the die that the side belongs to
var side_index: int

func _init(side_ability: GameManager.modifier, side_num: DieType, side_index: int):
	self.side_ability = side_ability
	self.side_num = side_num
	self.side_index = side_index
