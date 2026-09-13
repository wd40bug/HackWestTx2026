@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	#set global or custom seed
	var seed_gen: Global_seed = Global_seed.new()
	#seed_gen.set_seed(12345678)
	
	# create game instance
	var Game_instance: Game = Game.new()
	
	print("\n\n----- TESTING -----\n\n")
	
	# Test creating a die
	var die_test: Die = create_die(Die.Novilty_ability.NONE, 0)
	#die_test.print_die()
	
	# test rolling a side
	#print("Rolled side:")
	#die_test.roll_die().print_parameters()
	
	# Creating 6 dice
	var test_dice_array: Array[Die] = Game_instance.init_base_dice()
	"""print("Dice:")
	print("\n")
	for die in test_dice_array:
		die.print_die()
	print("\n\n")"""
	

	# test rolling a set of base game dice
	var test_rolled_sides: Array[Die_side] = []
	print("Rolling dice:")
	test_rolled_sides = Game_instance.roll_rollable_dice(test_dice_array)
	for side in test_rolled_sides:
		side.print_parameters()
		
	

	
# function to test die initialization
func create_die(ability: Die.Novilty_ability, die_index: int):
	var new_die = Die.new()
	new_die.die_ability = ability
	new_die.create_sides(die_index)
	return new_die
