class_name Game
extends Node

# Indices of dice that are able to be rolled--unracked dice
var rollable_dice: Array[int] = [0, 1, 2, 3, 4, 5]

var unselected_dice: Array[Die_side] = []
var sides_to_score: Array[Die_side] = []

var unbanked_score: int = 0
var banked_score: int = 0

signal banked_score_sig(new_score: int)
signal unbanked_score_sig(unbank_score: int)

enum Scoring_Dice_Sets {
	SINGLE_1 = 100,
	SINGLE_5 = 50,
	THREE_1 = 1000,
	THREE_2 = 200,
	THREE_3 = 300,
	THREE_4 = 400,
	THREE_5 = 500,
	THREE_6 = 600,
	FOUR_OF_KIND = 1000,
	FIVE_OF_KIND = 2000,
	SIX_OF_KIND = 3000,
	STRAIGHT = 1500,
	THREE_PAIR = 1500,
	FULL_HOUSE = 1500,
	TWO_TRIPLETS = 2500,
	NONE = 0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var die_array: Array[Die] = init_base_dice()
	
	var die_side_array: Array[Die_side] = await roll_rollable_dice(die_array)
	for die in die_side_array:
		die.print_parameters()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_pressed("confirm_dice")):
		score_dice()
		

# Create an array of 6 dice with normal sides, weights, and no abilities
func init_base_dice() -> Array[Die]:
	var die_array: Array[Die] = []
	"""for i in range(0, 6):
		var new_die: Die = Die.new()
		new_die.create_sides(i)
		die_array.append(new_die)"""
	#die_array = $Dice.get_children() as Array[Die]
	#var i = 0
	"""for die in $Dice.get_children():
		var new_die: Die = Die.new()
		new_die.create_sides(i)
		die_array.append(new_die)
		i += 1"""
	for i in range($Dice.get_child_count()):
		var die: Die = $Dice.get_child(i) as Die
		print(die)
		die.create_sides(i)
		die_array.append(die)
	
	print(die_array)
	return die_array

func roll_rollable_dice(dice: Array[Die]) -> Array[Die_side]:
	var rolled_sides: Array[Die_side] = []
	for i in rollable_dice:
		var side: Die_side = await dice[i].roll_die()
		rolled_sides.append(side)
	return rolled_sides

# adds a die to the list of scorable dice while removing it
# from the list of selectable dice
func add_die_to_scoring_dice(die_side: Die_side):
	sides_to_score.append(die_side)
	# die_side.die_index tells which die the side came from
	# this die is removed from unselected_dice
	unselected_dice.erase(die_side)
	
# Finds highest possible hand of selected dice. Does not
# account for modifiers
func find_highest_hand_of_selected() -> Scoring_Dice_Sets:
	var numbers: Array[int] = []
	for die in sides_to_score:
		numbers.append(die.side_num)
	# test for four, five, six of kind
	# no issues with conflicting hands, so can be out of order
	# true if all elements in array are the same
	if(numbers.all(func(number): return number == numbers[0])):
		if(numbers.size() == 6):
			return Scoring_Dice_Sets.SIX_OF_KIND
		elif(numbers.size() == 5):
			return Scoring_Dice_Sets.FIVE_OF_KIND
		elif(numbers.size() == 4):
			return Scoring_Dice_Sets.FOUR_OF_KIND
	# test for three pairs, full house, straight, or two triplets
	elif(numbers.size() == 6):
		var unique_numbers: Array[int] = []
		# create array of unique numbers
		for num in numbers:
			if not unique_numbers.has(num):
				unique_numbers.append(num)
		# three pairs
		if(unique_numbers.size() == 3):
			var unique_count1 = 0
			var unique_count2 = 0
			for num in numbers:
				if(num == unique_numbers[0]):
					unique_count1 += 1
				if(num == unique_numbers[1]):
					unique_count2 += 1
			if(unique_count1 == 2 and unique_count2 == 2):
				return Scoring_Dice_Sets.THREE_PAIR
		# full house or two triplets
		elif(unique_numbers.size() == 2):
			var unique_count1 = 0
			for num in numbers:
				if(num == unique_numbers[0]):
					unique_count1 += 1
			if(unique_count1 == 2 or unique_count1 == 4):
				return Scoring_Dice_Sets.FULL_HOUSE
			elif(unique_count1 == 3):
				return Scoring_Dice_Sets.TWO_TRIPLETS
		# straight
		elif(unique_numbers.size() == 6):
			return Scoring_Dice_Sets.FULL_HOUSE
	# test for sets of 3
	elif(numbers.size() == 3):
		if(numbers.all(func(number): return number == numbers[0])):
			match numbers[0]:
				6:
					return Scoring_Dice_Sets.THREE_6
				5:
					return Scoring_Dice_Sets.THREE_5
				4:
					return Scoring_Dice_Sets.THREE_4
				3:
					return Scoring_Dice_Sets.THREE_3
				2:
					return Scoring_Dice_Sets.THREE_2
				1:
					return Scoring_Dice_Sets.THREE_1
	# test for single 5 or 1
	elif(numbers.size() == 1):
		match numbers[0]:
			1:
				return Scoring_Dice_Sets.SINGLE_1
			5:
				return Scoring_Dice_Sets.SINGLE_5
	else:
		return Scoring_Dice_Sets.NONE
	return Scoring_Dice_Sets.NONE

func reset_rollable_dice():
	rollable_dice = [0, 1, 2, 3, 4, 5]

func deselect_die(die_side: Die_side):
	unselected_dice.append(die_side)
	sides_to_score.erase(die_side)
	
func bank_score():
	banked_score += unbanked_score
	unbanked_score = 0
	reset_rollable_dice()
	emit_signal("banked_score_sig", banked_score)
	
func score_dice():
	unbanked_score += find_highest_hand_of_selected()
	emit_signal("unbanked_score_sig", unbanked_score)

# if unable to score
func farkled_up():
	unbanked_score = 0
	reset_rollable_dice()

	
