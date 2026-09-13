class_name Game
extends Control

enum State {ROLLING, SELECTING, SCORING}

func has_novelty(name: String) -> bool:
	for die in die_array:
		if die.die_ability.title == name:
			return true
	return false

func get_novelty(name: String) -> Die:
	for die in die_array:
		if die.die_ability.title == name:
			return die
	return null

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

signal goal_sig(final_goal: int)
signal level_sig(new_level: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_game()
	
const END_SCREEN = preload("res://EndScreen.tscn")
const END_OF_ROUND = preload("res://shop.tscn")

@export var goal: int = 10_000
@export var cup: Special

var angel_cup_used = false
const PERCENT_OVER_FOR_MONEY = .1
const MONEY_FOR_WINNING = 4
const GOAL_INCREASE_BY = 500

@onready var sound_effect = $AudioStreamPlayer

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
	angel_cup_used = false
	lock_locked = false
	has_rerolled_even = false
	has_rerolled_odd = false
	hand_has_saved_hands = false
	
	#$AudioStreamPlayer.play()
	goal = gamemanager.goal
	$HandsLbl.text = ""
	$UI/GoalNum.text = str(goal)

	for child_dice in $Dice.get_children():
		child_dice.clicked_signal.connect(_die_clicked)
		(child_dice as Die).hovered.connect(_on_die_hovered)
		(child_dice as Die).unhovered.connect(_on_die_unhovered)
	
	die_array = []
	
	emit_signal("goal_sig", goal)
	level_sig.emit(gamemanager.level)
	
	print("Level: ", gamemanager.level)
	print("Goal: ", goal)
	
	# populate dice
	for i in range(gamemanager.dice_amm):
		#var new_die = Die.new()
			
		var new_die: Die = $Dice.get_child(i) as Die
		
		for k in range(6):
			#die_side

			# die side ability
			var side_ability = gamemanager.dice_side_mod[i][k]
			var side_num = gamemanager.dice_side_num[i][k]
			var side_index = i
			var side_weight = gamemanager.dice_weight_mod[i][k]
			
			var new_side = Die_side.new(side_ability, side_num, side_index)
			#new_side.print_parameters()
			new_die.die_sides[k] = (new_side)
		if(gamemanager.nov_dice[i] != null):
			new_die.set_special(gamemanager.nov_dice[i])
		if(gamemanager.cup != null):
			cup = gamemanager.cup
		die_array.append(new_die)
		print(new_die.die_ability)
		$UI/TextureRect.texture = cup.texture
	
	turns_left = 3

	await roll_rollable_dice(die_array)
	#for die in unselected_dice:
	#	die.print_parameters()
	
	emit_signal("turns_left_sig", turns_left)
	

func end_of_round():
	# player loses, reset
	if banked_score < goal:
		emit_signal("turns_left_sig", turns_left)
		$AudioStreamPlayer.play()
		gamemanager.goal = 1500
		gamemanager.level = 1
		level_sig.emit(gamemanager.level)
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_packed(END_SCREEN)
	# player succeeds, proceed to shop and increase difficulty
	else:
		var extra_money: int = int((banked_score - goal) / (goal * PERCENT_OVER_FOR_MONEY))
		gamemanager.money += MONEY_FOR_WINNING + extra_money
		gamemanager.goal += GOAL_INCREASE_BY
		gamemanager.level += 1
		level_sig.emit(gamemanager.level)
		get_tree().change_scene_to_packed(END_OF_ROUND)

# Create an array of 6 dice with normal sides, weights, and no abilities
func init_base_dice() -> Array[Die]:
	var die_array: Array[Die] = []
	for i in range($Dice.get_child_count()):
		var die: Die = $Dice.get_child(i) as Die
		die_array.append(die)

	return die_array

var has_rerolled_even = false
var has_rerolled_odd = false

var lock_locked = false
var locked_num = 0
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
	var hands_cls = Hands.calculate_hands(die_sides, has_novelty("Gap Straight"))
	
	var post_roll_add = {
		"Ones": Die_side.DieType.ONE,
		"Twos": Die_side.DieType.TWO,
		"Threes": Die_side.DieType.THREE,
		"Fours": Die_side.DieType.FOUR,
		"Fives": Die_side.DieType.FIVE,
		"Sixes": Die_side.DieType.SIX
	}
	
	for name in post_roll_add:
		var novelty = get_novelty("%s Add" % name)
		if novelty:
			var shake = false
			for side in rolled_sides:
				if side.side_num == post_roll_add[name]:
					unbanked_score += 50
					die_array[side.side_index].shake()
					shake = true
			if shake:
				novelty.shake()
	
	var lock = get_novelty("Lock")
	if lock && lock_locked:
		var shake = false
		for side in rolled_sides:
			if side.side_num == locked_num:
				unbanked_score += 50
				shake = true
				die_array[side.side_index].shake()
		if shake:
			lock.shake()
	
	unbanked_score_sig.emit(unbanked_score)
	
	if cup.title == "Reroll Even" && not has_rerolled_even:
		var even_sides: Array[int] = []
		for side in rolled_sides:
			if side.side_num % 2 == 0:
				even_sides.append(side.side_index)
		
		if even_sides:
			var rolled_sides_bak = rolled_sides
			var rollable_dice_bak = rollable_dice
			rollable_dice = even_sides
			has_rerolled_even = true
			await roll_rollable_dice(die_array)
			has_rerolled_even = false
			rollable_dice = rollable_dice_bak
			rolled_sides += rolled_sides.filter(func(a: Die_side): return a.side_num % 2 == 1)
			
	if cup.title == "Reroll Odd" && not has_rerolled_odd:
		var odd_sides: Array[int] = []
		for side in rolled_sides:
			if side.side_num % 2 == 1:
				odd_sides.append(side.side_index)
		
		if odd_sides:
			var rolled_sides_bak = rolled_sides
			var rollable_dice_bak = rollable_dice
			rollable_dice = odd_sides
			has_rerolled_odd = true
			has_rerolled_even = true
			await roll_rollable_dice(die_array)
			has_rerolled_odd = false
			has_rerolled_even = false
			rollable_dice = rollable_dice_bak
			rolled_sides += rolled_sides.filter(func(a: Die_side): return a.side_num % 2 == 0)
	

	if (hands_cls.hands.is_empty()):
		farkled_up()
		
	for die in dice:
		die.disabled_override = false


func update_scoring():
	var die_sides: Array[Die_side.DieType] = []
	for side in selected:
		var idx = rolled_sides.find_custom(func(a: Die_side): return a.side_index == side)
		die_sides.append(rolled_sides[idx].side_num)
	var hands_cls = Hands.calculate_hands(die_sides, has_novelty("Gap Straight"))
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
			Hands.HandTypes.STRAIGHT_GAP: name = "Straight"
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
	
var hand_history: Array[Hands.HandTypes] = []

var hand_has_saved_hands = false
var hand_saved_hands: Array[Hands.HandTypes]
func score_dice() -> void:
	# 1. Trigger visuals/scoring state on selected dice
	for i in selected:
		die_array[i].score()

	var mult: int = 1
	var add: int = 0
	

	# 2. Check modifiers on SELECTED dice
	for die_idx in selected:
		var die: Die = die_array[die_idx]
		# Get the current active side from the die's state (1-6 converted to 0-5 array index)
		var active_side: Die_side = die.die_sides[die.die_state - 1]
		
		if active_side.side_ability == GameManager.modifier.multmod:
			die.shake()
			mult += 1
		elif active_side.side_ability == GameManager.modifier.add:
			die.shake()
			add += 100

	for hand in hands:
		if hand == Hands.HandTypes.STRAIGHT_GAP:
			for die in die_array:
				if die.die_ability.title == "Gap Straight":
					die.shake()

	# 3. Check for passive UNSELECTED modifiers (e.g., Daisy on unselected dice)
	for i in range(die_array.size()):
		if not (i in selected) and (i in rollable_dice):
			var die: Die = die_array[i]
			var active_side: Die_side = die.die_sides[die.die_state - 1]
			
			if active_side.side_ability == GameManager.modifier.daisy:
				die.shake()
				mult += 1
	
	var snowflake = get_novelty("Snowflake")
	if snowflake:
		var shake = false
		for hand in hands:
			if hand not in hand_history:
				mult += 1
				shake = true
			hand_history.append(hand)
		if shake:
			snowflake.shake()
	else:
		hand_history += hands
		
	if has_novelty("Hand"):
		if !hand_has_saved_hands:
			for s in selected:
				if die_array[s].die_ability.title == "Hand":
					hand_has_saved_hands = true
					hand_saved_hands = hands
		else:
			var shake = false
			for hand in hands:
				if hand in hand_saved_hands:
					mult += 1
					shake = true
			if shake:
				get_novelty("Hand").shake()
	if has_novelty("Lock") and not lock_locked:
		for s in selected:
			if die_array[s].die_ability.title == "Lock":
				lock_locked = true;
				locked_num = die_array[s].die_state
	# 4. Calculate score with intended formula: (Base + Add) * Mult
	
	var base_score: int = hands.reduce(func(accum, hand): return accum + Hands.HandVals[hand], 0)
	unbanked_score += (base_score + add) * mult

	emit_signal("unbanked_score_sig", unbanked_score)

# if unable to score
func farkled_up():
	if cup.title == "Angel" and not angel_cup_used:
		$SavedLabel.show()
		await get_tree().create_timer(2).timeout
		$SavedLabel.hide()
		angel_cup_used = true
		finish_roll(false)
		return
	
	$BustedLabel.show()
	await get_tree().create_timer(2).timeout
	$BustedLabel.hide()
	unbanked_score = 0
	emit_signal("unbanked_score_sig", unbanked_score)
	emit_signal("turns_left_sig", turns_left)
	finish_roll(true)

func finish_roll(end_turn):

	for die in selected:
		die_array[die].die_state = 7
		rollable_dice.erase(die)
	selected.clear()
	
	if (end_turn):
		lock_locked = false
		hand_has_saved_hands = false
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
	await score_dice()
	finish_roll(false)


func _on_bank_btn_pressed() -> void:
	await score_dice()
	bank_score()
	finish_roll(true)
	
func _on_die_hovered(idx: int) -> void:
	show_hover(die_array[idx].die_ability)
	
func _on_die_unhovered(idx: int) -> void:
	$UI/TextureRect2.hide_menu()
	
func show_hover(item: Special) -> void:
	var popup = $UI/TextureRect2
	
	popup.display(item)

	await get_tree().process_frame

	var mouse := get_global_mouse_position()
	var viewport_size := get_viewport_rect().size
	
	# Get the actual size of the texture being displayed
	var popup_size = popup.texture.get_size() * popup.scale
	
	var margin := 10.0
	
	# Default position: centered above mouse
	var target := Vector2(
		mouse.x - popup_size.x / 2.0,
		mouse.y - popup_size.y - margin
	)
	
	# --------------------------------
	# LEFT / RIGHT
	# --------------------------------
	if target.x < margin:
		target.x = margin
	
	if target.x + popup_size.x > viewport_size.x - margin:
		target.x = viewport_size.x - popup_size.x - margin
	
	# --------------------------------
	# TOP
	# --------------------------------
	if target.y < margin:
		target.y = mouse.y + margin
	
	# --------------------------------
	# BOTTOM
	# --------------------------------
	if target.y + popup_size.y > viewport_size.y - margin:
		target.y = viewport_size.y - popup_size.y - margin
	
	popup.global_position = target


func _on_texture_rect_mouse_entered() -> void:
	show_hover(cup)


func _on_texture_rect_mouse_exited() -> void:
	$UI/TextureRect2.hide_menu()
