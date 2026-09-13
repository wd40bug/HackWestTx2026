class_name Game
extends Node

# Indices of dice that are able to be rolled--unracked dice
var rollable_dice: Array[int] = [0, 1, 2, 3, 4, 5]

var unselected_dice: Array[Die_side] = []
var sides_to_score: Array[Die_side] = []

var unbanked_score: int = 0
var banked_score: int = 0
var game_finish: bool = false

#player can only reroll (q for now) or bank (space) if they scored 
# this most recent roll
var recent_score: bool = false

signal banked_score_sig(new_score: int)
signal unbanked_score_sig(unbank_score: int)

var turns_left: int = 0
signal turns_left_sig(turns: int)

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

enum Game_state {
	IN_ROUND,
	OUT_OF_ROUND
}

#var able_to_roll_again: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	begin_game()
	
	

var enter_prev_pressed: bool = false
var space_prev_pressed: bool = false
var q_prev_pressed: bool = false
var is_rolling: bool = false
var b_prev_pressed: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enter_button_pressed: bool = Input.is_action_pressed("confirm_dice")
	var space_button_pressed: bool = Input.is_action_pressed("bank_score")
	var q_button_pressed: bool = Input.is_action_pressed("roll_again")
	var b_button_pressed: bool = Input.is_action_pressed("bust")
	
	if(not game_finish):
		if(enter_button_pressed and not space_button_pressed):
			if(not enter_prev_pressed):
				score_dice()
				enter_prev_pressed = true
		else:
			enter_prev_pressed = false
		
		if(space_button_pressed and not enter_button_pressed and recent_score):
			if(not space_prev_pressed):
				bank_score()
				space_prev_pressed = true
		else:
			space_prev_pressed = false
		
		
		if(q_button_pressed and not is_rolling and recent_score):
			if(not q_prev_pressed):
				if(turns_left > 0):
					is_rolling = true
					#turns_left -= 1
					emit_signal("turns_left_sig", turns_left)
					q_prev_pressed = true
					unselected_dice = await roll_rollable_dice(die_array)
					is_rolling = false
					recent_score = false
				q_prev_pressed = true
			else:
				q_prev_pressed = false
				
		if(b_button_pressed and not recent_score):
			if(not b_prev_pressed):
				b_prev_pressed = true
				farkled_up()
		else:
			b_prev_pressed = false
			
		if(turns_left == 0):
			game_finish = true
	else:
		# round over
		end_of_round()
		
	
var die_array: Array[Die] = []

func begin_game():
	for child_dice in $Dice.get_children():
		child_dice.clicked_signal.connect(_die_clicked)
	
	die_array = init_base_dice()
	
	turns_left = 3

	unselected_dice = await roll_rollable_dice(die_array)
	#for die in unselected_dice:
	#	die.print_parameters()
	
	emit_signal("turns_left_sig", turns_left)

func end_of_round():
	print("This is where the game ends")

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
		die.die_index = i
		die_array.append(die)
	
	print(die_array)
	return die_array

func roll_rollable_dice(dice: Array[Die]) -> Array[Die_side]:
	var rolled_sides: Array[Die_side] = []
	print("Rollable dice:")
	print(rollable_dice)
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
	# unselected_dice.erase(die_side)
	
# Finds highest possible hand of selected dice. Does not
# account for modifiers
func find_highest_hand_of_selected() -> Scoring_Dice_Sets:
	var numbers: Array[int] = []
	for die in sides_to_score:
		numbers.append(die.side_num)
	print(numbers)
	# test for four, five, six of kind
	# no issues with conflicting hands, so can be out of order
	# true if all elements in array are the same
	if(numbers.all(func(number): return number == numbers[0])):
		if(numbers.size() == 6):
			print(Scoring_Dice_Sets.SIX_OF_KIND)
			return Scoring_Dice_Sets.SIX_OF_KIND
		elif(numbers.size() == 5):
			print(Scoring_Dice_Sets.FIVE_OF_KIND)
			return Scoring_Dice_Sets.FIVE_OF_KIND
		elif(numbers.size() == 4):
			print(Scoring_Dice_Sets.FOUR_OF_KIND)
			return Scoring_Dice_Sets.FOUR_OF_KIND
	# test for three pairs, full house, straight, or two triplets
	if(numbers.size() == 6):
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
				print(Scoring_Dice_Sets.THREE_PAIR)
				return Scoring_Dice_Sets.THREE_PAIR
		# full house or two triplets
		elif(unique_numbers.size() == 2):
			var unique_count1 = 0
			for num in numbers:
				if(num == unique_numbers[0]):
					unique_count1 += 1
			if(unique_count1 == 2 or unique_count1 == 4):
				print(Scoring_Dice_Sets.FULL_HOUSE)
				return Scoring_Dice_Sets.FULL_HOUSE
			elif(unique_count1 == 3):
				print(Scoring_Dice_Sets.TWO_TRIPLETS)
				return Scoring_Dice_Sets.TWO_TRIPLETS
		# straight
		elif(unique_numbers.size() == 6):
			print("Scoring_Dice_Sets.FULL_HOUSE")
			return Scoring_Dice_Sets.FULL_HOUSE
	# test for sets of 3
	elif(numbers.size() == 3):
		if(numbers.all(func(number): return number == numbers[0])):
			match numbers[0]:
				6:
					print(Scoring_Dice_Sets.THREE_6)
					return Scoring_Dice_Sets.THREE_6
				5:
					print(Scoring_Dice_Sets.THREE_5)
					return Scoring_Dice_Sets.THREE_5
				4:
					print(Scoring_Dice_Sets.THREE_4)
					return Scoring_Dice_Sets.THREE_4
				3:
					print(Scoring_Dice_Sets.THREE_3)
					return Scoring_Dice_Sets.THREE_3
				2:
					print(Scoring_Dice_Sets.THREE_2)
					return Scoring_Dice_Sets.THREE_2
				1:
					print(Scoring_Dice_Sets.THREE_1)
					return Scoring_Dice_Sets.THREE_1
	# test for single 5 or 1
	elif(numbers.size() == 1):
		print("Got to size 1")
		match numbers[0]:
			1:
				print(Scoring_Dice_Sets.SINGLE_1)
				return Scoring_Dice_Sets.SINGLE_1
			5:
				print(Scoring_Dice_Sets.SINGLE_5)
				return Scoring_Dice_Sets.SINGLE_5
	else:
		print(Scoring_Dice_Sets.NONE)
		return Scoring_Dice_Sets.NONE
	return Scoring_Dice_Sets.NONE

func reset_rollable_dice():
	rollable_dice = [0, 1, 2, 3, 4, 5]

func deselect_die(die_side: Die_side):
	#unselected_dice.append(die_side)
	sides_to_score.erase(die_side)
	
func bank_score():
	banked_score += unbanked_score
	unbanked_score = 0
	reset_rollable_dice()
	emit_signal("banked_score_sig", banked_score)
	emit_signal("unbanked_score_sig", unbanked_score)
	# unpress all the buttons
	for button in get_tree().get_nodes_in_group("dice_buttons"):
		if button is BaseButton:
			button.button_pressed = false
	turns_left -= 1
	emit_signal("turns_left_sig", turns_left)
	# show all dice
	for die in die_array:
		die.die_state = 8
	await get_tree().process_frame
	if(turns_left > 0):
		unselected_dice = await roll_rollable_dice(die_array)
	
func score_dice():
	print("sides to score:")
	print(sides_to_score)
	unbanked_score += find_highest_hand_of_selected()
	print(unbanked_score)
	emit_signal("unbanked_score_sig", unbanked_score)
	# hide used dice
	if(find_highest_hand_of_selected() != Scoring_Dice_Sets.NONE):
		for die in sides_to_score:
			print("\n\n\n")
			#die.print_parameters()
			die_array[die.side_index].die_state = 7
			print("\nside index: ", die.side_index)
			for i in range(rollable_dice.size()):
				if(rollable_dice[i] == die.side_index):
					rollable_dice.remove_at(i)
					break
	# unpress all the buttons
	for button in get_tree().get_nodes_in_group("dice_buttons"):
		if button is BaseButton:
			button.button_pressed = false
	# test if all dice used
	print("\nall dice test!\n")
	print(rollable_dice.size())
	if(rollable_dice.size() == 0):
		print("test passed")
		print("\n\n")
		reset_rollable_dice()
		print(die_array)
		for die in die_array:
			die.die_state = 8
		await get_tree().process_frame

		unselected_dice = await roll_rollable_dice(die_array)
	# user can reroll
	recent_score = true

		
# if unable to score
func farkled_up():
	unbanked_score = 0
	emit_signal("unbanked_score_sig", unbanked_score)
	turns_left -= 1
	emit_signal("turns_left_sig", turns_left)
	reset_rollable_dice()
	for die in die_array:
		die.die_state = 8
	await get_tree().process_frame
	if (turns_left > 0):
		unselected_dice = await roll_rollable_dice(die_array)
	for button in get_tree().get_nodes_in_group("dice_buttons"):
		if button is BaseButton:
			button.button_pressed = false

func _die_clicked(active: bool, place: int):
	if(active):
		print("place: ", place)
		for i in range(unselected_dice.size()):
			if(unselected_dice[i].side_index == place):
				add_die_to_scoring_dice(unselected_dice[i])
				print("side_index: ")
				print(unselected_dice[i].side_index)
		"""if unselected_dice[unselected_dice.find(place)] not in sides_to_score:
			sides_to_score.append(unselected_dice[unselected_dice.find(place)])
			print("place: ", place)
			print(unselected_dice[unselected_dice.find(place)])"""
	else:
		var in_selected_dice: bool = true
		for i in range(sides_to_score.size() - 1, -1, -1):
			if(sides_to_score[i].side_index == place):
				in_selected_dice = true
				deselect_die(sides_to_score[i])
			
		"""if unselected_dice[unselected_dice.find(place)] in sides_to_score:
			deselect_die(unselected_dice[unselected_dice.find(place)])"""
