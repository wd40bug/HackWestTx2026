@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	#set global or custom seed
	var seed_gen: Global_seed = Global_seed.new()
	seed_gen.set_seed(12345)
	
	print("\n\n----- TESTING -----\n\n")
	
	# Test creating a die
	var die_test: Die = create_die(Die.Novilty_ability.NONE)
	#die_test.print_die()
	
	# test rolling a number
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	print("Rolled number: ", die_test.roll_die())
	
# function to test die initialization
func create_die(ability: Die.Novilty_ability):
	var new_die = Die.new()
	new_die.die_ability = ability
	new_die.create_sides()
	return new_die
