class_name Game
extends Node

enum State {ROLLING, SELECTING, SCORING}

var state = State.ROLLING

# Indices of dice that are able to be rolled--unracked dice
var rollable_dice: Array[int] = [0, 1, 2, 3, 4, 5]

var unbanked_score: int = 0
var banked_score: int = 0
var game_finish: bool = false

signal banked_score_sig(new_score: int)
signal unbanked_score_sig(unbank_score: int)

var turns_left: int = 0
signal turns_left_sig(turns: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_game()
	
const END_SCREEN = preload("res://EndScreen.tscn")
const END_OF_ROUND = preload("res://shop.tscn")

@export var goal: int = 10_000

var enter_prev_pressed: bool = false
var space_prev_pressed: bool = false
var q_prev_pressed: bool = false
var is_rolling: bool = false
var b_prev_pressed: bool = false

var die_array: Array[Die] = []
var rolled_sides: Array[Die_side] = []

var selected: Array[int] = []
var racked: Array[int] = []

var hands: Array[Hands.HandTypes] = []

'''Initializes everything'''
func begin_game():
	$HandsLbl.text = ""
	$UI/GoalNum.text = str(goal)
	for child_dice in $Dice.get_children():
		child_dice.clicked_signal.connect(_die_clicked)
	
	die_array = init_base_dice()
	
	turns_left = 3

	await roll_rollable_dice(die_array)
	#for die in unselected_dice:
	#	die.print_parameters()
	
	emit_signal("turns_left_sig", turns_left)
	

func end_of_round():
	if banked_score < goal:
		get_tree().change_scene_to_packed(END_SCREEN)
	else:
		get_tree().change_scene_to_packed(END_OF_ROUND)

# Create an array of 6 dice with normal sides, weights, and no abilities
func init_base_dice() -> Array[Die]:
	var die_array: Array[Die] = []
	for i in range($Dice.get_child_count()):
		var die: Die = $Dice.get_child(i) as Die
		die_array.append(die)

	return die_array

func roll_rollable_dice(dice: Array[Die]):
	await get_tree().process_frame
	for die in dice:
		die.disabled_override = true
	rolled_sides = []
	if rollable_dice.is_empty():
		return
	for i in rollable_dice:
		var side: Die_side = await dice[i].roll_die()
		rolled_sides.append(side)
	
	await get_tree().process_frame
	update_scoring()
	var die_sides: Array[Die_side.DieType] = []
	for side in rolled_sides:
		die_sides.append(side.side_num)
	var hands_cls = Hands.calculate_hands(die_sides)
	
	
	if (hands_cls.hands.is_empty()):
		$BustedLabel.show()
		await get_tree().create_timer(2).timeout
		$BustedLabel.hide()
		farkled_up()
		finish_roll(true)
	for die in dice:
		die.disabled_override = false


func update_scoring():
	var die_sides: Array[Die_side.DieType] = []
	for side in selected:
		var idx = rolled_sides.find_custom(func(a: Die_side): return a.side_index == side)
		die_sides.append(rolled_sides[idx].side_num)
	var hands_cls = Hands.calculate_hands(die_sides)
	hands = hands_cls.hands if hands_cls.remainder.is_empty() and not hands_cls.hands.is_empty() else ([] as Array[Hands.HandTypes])
	
	var names = []
	for hand in hands:
		var name = ""
		match hand:
			Hands.HandTypes.SINGLE_1: name = "One"
			Hands.HandTypes.SINGLE_5: name = "Five"
			Hands.HandTypes.THREE_2: name = "Triple Twos"
			Hands.HandTypes.THREE_3: name = "Triple Threes"
			Hands.HandTypes.THREE_4: name = "Triple Fours"
			Hands.HandTypes.THREE_5: name = "Triple Fives"
			Hands.HandTypes.THREE_6: name = "Triple Sixes"
			Hands.HandTypes.THREE_1: name = "Triple Ones"
			Hands.HandTypes.FOUR_OF_KIND: name = "Four of a kind"
			Hands.HandTypes.FOUR_OF_KIND_1: name = "Four Ones"
			Hands.HandTypes.STRAIGHT: name = "Straight"
			Hands.HandTypes.THREE_PAIR: name = "Three Pair"
			Hands.HandTypes.FULL_HOUSE: name = "Full House"
			Hands.HandTypes.FIVE_OF_KIND: name = "Five of a kind"
			Hands.HandTypes.FIVE_OF_KIND_1: name = "Five Ones"
			Hands.HandTypes.TWO_TRIPLETS: name = "Two Triples"
			Hands.HandTypes.SIX_OF_KIND: name = "Six of a kind"
			Hands.HandTypes.SIX_OF_KIND_1: name = "Six ones"
		names.append(name)
	
	var hands_string = ""
	for i in range(0, len(names)):
		hands_string += names[i]
		if i != len(names) - 1:
			hands_string += ", "
	
	$HandsLbl.text = hands_string
	$ScoreBtn.disabled = hands.is_empty()
	$BankBtn.disabled = hands.is_empty()

# adds a die to the list of scorable dice while removing it
# from the list of selectable dice
func add_die_to_scoring_dice(i: int):
	selected.append(i)
	update_scoring()

func reset_rollable_dice():
	rollable_dice = [0, 1, 2, 3, 4, 5]

func deselect_die(i: int):
	#unselected_dice.append(die_side)
	selected.erase(i)
	update_scoring()
	
func bank_score():
	banked_score += unbanked_score
	unbanked_score = 0
	banked_score_sig.emit(banked_score)
	emit_signal("unbanked_score_sig", unbanked_score)
	
func score_dice():
	for i in range(0, len(die_array)):
		if i in selected:
			die_array[i].score()
	unbanked_score += hands.reduce(func(a, b): return a + Hands.HandVals[b], 0)
	emit_signal("unbanked_score_sig", unbanked_score)

# if unable to score
func farkled_up():
	unbanked_score = 0
	emit_signal("unbanked_score_sig", unbanked_score)
	emit_signal("turns_left_sig", turns_left)

func finish_roll(end_turn):
	for die in selected:
		die_array[die].die_state = 7
		rollable_dice.erase(die)
	selected.clear()
	
	if (end_turn):
		turns_left-=1
		if turns_left == 0:
			end_of_round()
			return
		turns_left_sig.emit(turns_left)
	
	# test if all dice used
	if(rollable_dice.size() == 0 || end_turn):
		reset_rollable_dice()
		for die in die_array:
			die.die_state = 8
		await get_tree().process_frame
		for button in get_tree().get_nodes_in_group("dice_buttons"):
			if button is BaseButton:
				button.button_pressed = false
		

	await roll_rollable_dice(die_array)

func _die_clicked(active: bool, place: int):
	if(active):
		add_die_to_scoring_dice(place)
	else:
		deselect_die(place)


func _on_score_btn_pressed() -> void:
	score_dice()
	finish_roll(false)


func _on_bank_btn_pressed() -> void:
	score_dice()
	bank_score()
	finish_roll(true)
