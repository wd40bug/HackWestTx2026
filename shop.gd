extends Node2D

@export var seed = 1234

var num_images = (
	["res://Assets/Dice Assetes/One.png",
	"res://Assets/Dice Assetes/Two.png",
	"res://Assets/Dice Assetes/Three.png",
	"res://Assets/Dice Assetes/Four.png",
	"res://Assets/Dice Assetes/Five.png",
	"res://Assets/Dice Assetes/Six.png"])
	
var mod_images = (
	["res://Assets/Modifiers/Add.png",
	"res://Assets/Modifiers/Coins.png",
	"res://Assets/Modifiers/Daisy.png",
	"res://Assets/Modifiers/MultModifier.png",
	"res://Assets/Modifiers/Weighted.png"])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ChestScreen.visible = false
	$Chests/Chest1.visible = true
	$Chests/Chest2.visible = true
	seed(seed)
	generate_chests()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

enum modifier {add, coins, daisy, multmod, weighted, none}

# separate lists in case we want to weigh each cup modifier type's
# probability of appearing in the sop

# pool of cups that multiply hand types, e.g. 3 of a kind, full house
var cup_hand_mult_list: Array[String] = [
	"mult_2_triplets",
	"mult_3_of_kind",
	"mult_3_pair",
	"mult_4_of_kind",
	"mult_5_of_kind",
	"mult_6_of_kind",
	"mult_full_house",
	"mult_single",
	"mult_straight"
]

# pool of cups that multiply compoundingly via number of
# numbers in a hand
var cup_comp_mult_list: Array[String] = [
	"comp_mult_mixed_fives",
	"comp_mult_mixed_fours",
	"comp_mult_mixed_ones",
	"comp_mult_mixed_sixes",
	"comp_mult_mixed,threes",
	"comp_mult_mixed_twos",
	"comp_mult_only_fives",
	"comp_mult_only_fours",
	"comp_mult_only_ones",
	"comp_mult_only_sixes",
	"comp_mult_only,threes",
	"comp_mult_only_twos"
]

# cups with misc abilities
var cup_other_abilities_list = [
	"additional_all_two",
	"angel",
	"extra_die",
	"reroll_evens",
	"reroll_odds",
	"times_two"
]

var mod_list = [modifier.add, modifier.coins, modifier.daisy, modifier.multmod, modifier.weighted]

var side_pool = [1, 2, 3, 4, 5, 6]

@export var mod_chance = .33

@export var tier2_chance = .33

var shopdies = []

var shopchests = []

var chestsides = []

var shop_cup

var cup_pool: Array[String] = []

func generate_cup():
	const HAND_MULT_CHANCE = .5
	const HAND_COMP_MULT_CHANCE = .3
	const OTHER_ABILITY_CHANCE = .2
	
	var rand_num = randf()
	var cup_pool
	if(rand_num < HAND_MULT_CHANCE):
		cup_pool = cup_hand_mult_list
	elif(rand_num > HAND_MULT_CHANCE + HAND_COMP_MULT_CHANCE):
		cup_pool = cup_comp_mult_list
	else:
		cup_pool = cup_other_abilities_list
		
	var shop_cup_name = cup_pool.pick_random()
	var shop_cup_path = "res://Specials/Cups/" + shop_cup_name + ".tres"
	
	var cup = load(shop_cup_path)

	return cup
	
		

func generate_side():
	var side = side_pool[randi() % side_pool.size()]
	var side_mod = modifier.none
	if(randf() < mod_chance):
		side_mod = mod_list[randi() % mod_list.size()]
	return [side, side_mod]

func generate_chest():
	var chest = "tier 1"
	var chestprice = 5
	if(randf() < tier2_chance):
		chest = "tier 2"
		chestprice += 3
	return [chest, chestprice]

func generate_chests():
	shopchests = [generate_chest(), generate_chest()]
		
	shop_cup = generate_cup()
	
	$ShopCup.item_data = shop_cup
	$ShopCup/Price.text = "$" + str(shop_cup.price)
	

	if shopchests[0][0] == "tier 1":
		$Chests/Chest1.texture = load("res://Assets/Shop Assets/Chest3.png")
	else:
		$Chests/Chest1.texture = load("res://Assets/Shop Assets/Chest5.png")
		
	if shopchests[1][0] == "tier 1":
		$Chests/Chest2.texture = load("res://Assets/Shop Assets/Chest3.png")
	else:
		$Chests/Chest2.texture = load("res://Assets/Shop Assets/Chest5.png")

	$Chests/Chest1/Price.text = "$%d" %shopchests[0][1]
	$Chests/Chest2/Price.text = "$%d" %shopchests[1][1]

func open_chest(type):
	chestsides = []
	if type == "tier 1":
		chestsides = [generate_side(), generate_side(), generate_side()]
		$ChestScreen/Dice/Die4.visible = false
		$ChestScreen/Dice/Die5.visible = false
	else:
		chestsides = [generate_side(), generate_side(), generate_side(), generate_side(), generate_side()]
		$ChestScreen/Dice/Die4.visible = true
		$ChestScreen/Dice/Die5.visible = true
		
		$ChestScreen/Dice/Die4/Side_num.texture = load(num_images[chestsides[3][0] - 1])
		if chestsides[3][1] != modifier.none:
			$ChestScreen/Dice/Die4/Side_mod.texture = load(mod_images[chestsides[3][1]])
	
		$ChestScreen/Dice/Die5/Side_num.texture = load(num_images[chestsides[4][0] - 1])
		if chestsides[4][1] != modifier.none:
			$ChestScreen/Dice/Die5/Side_mod.texture = load(mod_images[chestsides[4][1]])
	
	$ChestScreen/Dice/Die1/Side_num.texture = load(num_images[chestsides[0][0] - 1])
	if chestsides[0][1] != modifier.none:
		$ChestScreen/Dice/Die1/Side_mod.texture = load(mod_images[chestsides[0][1]])
	
	$ChestScreen/Dice/Die2/Side_num.texture = load(num_images[chestsides[1][0] - 1])
	if chestsides[1][1] != modifier.none:
		$ChestScreen/Dice/Die2/Side_mod.texture = load(mod_images[chestsides[1][1]])
	
	$ChestScreen/Dice/Die3/Side_num.texture = load(num_images[chestsides[2][0] - 1])
	if chestsides[2][1] != modifier.none:
		$ChestScreen/Dice/Die3/Side_mod.texture = load(mod_images[chestsides[2][1]])
		
	$ChestScreen.visible = true

func _on_chest_1_button_button_down():
	$Chests/Chest1.visible = false
	open_chest(shopchests[0][0])

func _on_chest_2_button_button_down():
	$Chests/Chest2.visible = false
	open_chest(shopchests[1][0])


func _on_chest_screen_side_selected(side):
	on_side_select(side)

func on_side_select(side):
	$ChestScreen.visible = false
	$Chest_open_info.text = "Select die and side!"
	

func user_die_select(die):
	pass

#func _on_item_hover(special: Special) -> void:
	#print("Hovering!!!")
	#$TextureRect.visible = true
	#$TextureRect.display(special)


#func _on_shop_item_hover(item: Special) -> void:
	#pass # Replace with function body.


func _on_pd_1_button_button_down() -> void:
	user_die_select(1)


func _on_pd_2_button_button_down() -> void:
	user_die_select(2)


func _on_pd_3_button_button_down() -> void:
	user_die_select(3)


func _on_pd_4_button_button_down() -> void:
	user_die_select(4)


func _on_pd_5_button_button_down() -> void:
	user_die_select(5)


func _on_pd_6_button_button_down() -> void:
	pass # Replace with function body.
