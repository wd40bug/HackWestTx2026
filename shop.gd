extends Node2D

#@export var seed = randi() % 50#1234

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
func _ready():
	$ChestScreen.visible = false
	$Chests/Chest1.visible = true
	$Chests/Chest2.visible = true
	$Dice_Select.visible = false
	#seed(seed)

	if gamemanager.nov_dice[0] != null:
		$UserDice/BasicDie1/NovDie1.texture = gamemanager.nov_dice[0].texture
	if gamemanager.nov_dice[1] != null:
		$UserDice/BasicDie2/NovDie2.texture = gamemanager.nov_dice[1].texture 
	if gamemanager.nov_dice[2] != null:
		$UserDice/BasicDie3/NovDie3.texture = gamemanager.nov_dice[2].texture 
	if gamemanager.nov_dice[3] != null:
		$UserDice/BasicDie4/NovDie4.texture = gamemanager.nov_dice[3].texture 
	if gamemanager.nov_dice[4] != null:
		$UserDice/BasicDie5/NovDie5.texture = gamemanager.nov_dice[4].texture 
	if gamemanager.nov_dice[5] != null:
		$UserDice/BasicDie6/NovDie6.texture = gamemanager.nov_dice[5].texture 
	generate_chests()
	generate_dice()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	$UI/Money.text = "$%d"%gamemanager.money

	
enum modifier {add, coins, daisy, multmod, weighted, none}

# separate lists in case we want to weigh each cup modifier type's
# probability of appearing in the sop

# pool of cups that multiply hand types, e.g. 3 of a kind, full house
var cup_hand_mult_list: Array[String] = [

]

# pool of cups that multiply compoundingly via number of
# numbers in a hand
var cup_comp_mult_list: Array[String] = [

]

# cups with misc abilities
var cup_other_abilities_list = [

	"angel",

	"reroll_evens",
	"reroll_odds",

]

var mod_list = [modifier.add, modifier.coins, modifier.daisy, modifier.multmod, modifier.weighted]

var side_pool = [1, 2, 3, 4, 5, 6]

var mod_chance = .33

var tier2_chance = .33

var novilty_pool: Array = DirAccess.get_files_at("res://Specials/Dice/")

var shopchests = []

var chestsides = []

var shop_cup

var cup_pool: Array[String] = []

var placing_side = 0

var side_to_place

var nov_select = 0


func generate_cup():
	$ShopCup.visible = true
	const HAND_MULT_CHANCE = .5
	const HAND_COMP_MULT_CHANCE = .3
	const OTHER_ABILITY_CHANCE = .2
	
	var rand_num = randf()
	var cup_pool
	cup_pool = cup_other_abilities_list
		
	var shop_cup_name = cup_pool.pick_random()
	var shop_cup_path = "res://Specials/Cups/" + shop_cup_name + ".tres"
	
	var cup = load(shop_cup_path)

	return cup
	
var shop_nov: Array	 = []

func generate_dice():
	shop_nov.clear()
	$ShopItem.visible = true
	$ShopItem2.visible = true

	shop_nov.append(load("res://Specials/Dice/" + novilty_pool.pick_random()))
	shop_nov.append(load("res://Specials/Dice/" + novilty_pool.pick_random()))

	print(shop_nov)
	
	$ShopItem.item_data = shop_nov[0]
	$ShopItem2.item_data = shop_nov[1]
	
	$ShopItem/SIPrice1.text = "$%d"%shop_nov[0].price
	$ShopItem2/SIPrice2.text = "$%d"%shop_nov[1].price

	pass
	
func generate_side():
	var side = side_pool[randi() % side_pool.size()]
	var side_mod = modifier.none
	if(randf() < mod_chance):
		side_mod = mod_list[randi() % mod_list.size()]
	return [side, side_mod]

func generate_chest():
	$Chests/Chest1.visible = true
	$Chests/Chest2.visible = true
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
		gamemanager.money -= 5
		chestsides = [generate_side(), generate_side(), generate_side()]
		$ChestScreen/Dice/Die4.visible = false
		$ChestScreen/Dice/Die5.visible = false
		
		$ChestScreen/Dice/Die4/Side_num.texture = null
		$ChestScreen/Dice/Die4/Side_mod.texture = null
		
		$ChestScreen/Dice/Die5/Side_num.texture = null
		$ChestScreen/Dice/Die5/Side_mod.texture = null
		
	else:
		gamemanager.money -= 8
		chestsides = [generate_side(), generate_side(), generate_side(), generate_side(), generate_side()]
		$ChestScreen/Dice/Die4.visible = true
		$ChestScreen/Dice/Die5.visible = true
		
		$ChestScreen/Dice/Die4/Side_num.texture = load(num_images[chestsides[3][0] - 1])
		if chestsides[3][1] != modifier.none:
			$ChestScreen/Dice/Die4/Side_mod.texture = load(mod_images[chestsides[3][1]])
		else:
			$ChestScreen/Dice/Die4/Side_mod.texture = null
			
		$ChestScreen/Dice/Die5/Side_num.texture = load(num_images[chestsides[4][0] - 1])
		if chestsides[4][1] != modifier.none:
			$ChestScreen/Dice/Die5/Side_mod.texture = load(mod_images[chestsides[4][1]])
		else:
			$ChestScreen/Dice/Die5/Side_mod.texture = null

	
	$ChestScreen/Dice/Die1/Side_num.texture = load(num_images[chestsides[0][0] - 1])
	if chestsides[0][1] != modifier.none:
		$ChestScreen/Dice/Die1/Side_mod.texture = load(mod_images[chestsides[0][1]])
	else:
			$ChestScreen/Dice/Die1/Side_mod.texture = null
	
	$ChestScreen/Dice/Die2/Side_num.texture = load(num_images[chestsides[1][0] - 1])
	if chestsides[1][1] != modifier.none:
		$ChestScreen/Dice/Die2/Side_mod.texture = load(mod_images[chestsides[1][1]])
	else:
			$ChestScreen/Dice/Die2/Side_mod.texture = null
	
	$ChestScreen/Dice/Die3/Side_num.texture = load(num_images[chestsides[2][0] - 1])
	if chestsides[2][1] != modifier.none:
		$ChestScreen/Dice/Die3/Side_mod.texture = load(mod_images[chestsides[2][1]])
	else:
			$ChestScreen/Dice/Die3/Side_mod.texture = null
	
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
	$Chest_open_info.visible = true
	$Chest_open_info.text = "Select die and side!"
	side_to_place = chestsides[side]
	print("Plan to place num: %d mod %d"%[chestsides[side][0], chestsides[side][1]])
	placing_side = 1
	
var cur_selected
func user_die_select(die):
	if die == cur_selected:
		cur_selected = null
		$Dice_Select.visible = false
		return
	cur_selected = die
	var cur_num
	var cur_path
	$Dice_Select.visible = true
	for i in 6:
		cur_num = gamemanager.dice_side_num[die][i]
		cur_path = "Dice_Select/SelectDie%d/SD%dNum"%[i+1,i+1]

		match cur_num:
			1:
				get_node(cur_path).texture = load("res://Assets/Dice Assetes/One.png")
			2:
				get_node(cur_path).texture = load("res://Assets/Dice Assetes/Two.png")
			3:
				get_node(cur_path).texture = load("res://Assets/Dice Assetes/Three.png")
			4:
				get_node(cur_path).texture = load("res://Assets/Dice Assetes/Four.png")
			5:
				get_node(cur_path).texture = load("res://Assets/Dice Assetes/Five.png")
			6:
				get_node(cur_path).texture = load("res://Assets/Dice Assetes/Six.png")
		cur_path = "Dice_Select/SelectDie%d/SD%dMod"%[i+1,i+1]
		match gamemanager.dice_side_mod[die][i]:
			0:
				get_node(cur_path).texture = null
			1:
				get_node(cur_path).texture = load("res://Assets/Modifiers/Add.png")
			2:
				get_node(cur_path).texture = load("res://Assets/Modifiers/Coins.png")
			3:
				get_node(cur_path).texture = load("res://Assets/Modifiers/Daisy.png")
			4:
				get_node(cur_path).texture = load("res://Assets/Modifiers/MultModifier.png")
			5:
				get_node(cur_path).texture = load("res://Assets/Modifiers/Weighted.png")

func select_die_selected(side):
	print("Placing side: %d with mod: %d at die: %d side: %d"%[side_to_place[0], side_to_place[1], cur_selected, side])
	gamemanager.update_side(cur_selected, side, side_to_place[0], side_to_place[1])
	placing_side = 0
	$Chest_open_info.visible = false
	print("User die for target is num: %d mod: %d"%[gamemanager.dice_side_num[cur_selected][side], gamemanager.dice_side_mod[cur_selected][side]])
	user_die_select(cur_selected)

#func _on_item_hover(special: Special):
	#print("Hovering!!!")
	#$TextureRect.visible = true
	#$TextureRect.display(special)
	pass

func _on_item_hover(special: Special) -> void:
	print("Hovering!!!")
	$TextureRect.display(special)
	
func _on_shop_cup_unhover() -> void:
	print("Unhovering!!!")
	$TextureRect.hide_menu()


#func _on_shop_item_hover(item: Special):
	#pass # Replace with function body.


func _on_pd_1_button_button_down():
	if nov_select == 1:
		gamemanager.nov_dice[0] = shop_nov[0]
		$UserDice/BasicDie1/NovDie1.texture = shop_nov[0].texture
		print("Nov die assigned!")
		shop_nov[0] = null
		nov_select = 0
	elif nov_select == 2:
		gamemanager.nov_dice[0] = shop_nov[1]
		$UserDice/BasicDie1/NovDie1.texture = shop_nov[1].texture
		shop_nov[1] = null
		nov_select = 0
	else:
		user_die_select(0)


func _on_pd_2_button_button_down():
	if nov_select == 1:
		gamemanager.nov_dice[1] = shop_nov[0]
		$UserDice/BasicDie2/NovDie2.texture = shop_nov[0].texture
		shop_nov[0] = null
		nov_select = 0
	elif nov_select == 2:
		gamemanager.nov_dice[1] = shop_nov[1]
		$UserDice/BasicDie2/NovDie2.texture = shop_nov[1].texture
		shop_nov[1] = null
		nov_select = 0
	else:
		user_die_select(1)


func _on_pd_3_button_button_down():
	if nov_select == 1:
		gamemanager.nov_dice[2] = shop_nov[0]
		$UserDice/BasicDie3/NovDie3.texture = shop_nov[0].texture
		shop_nov[0] = null
		nov_select = 0
	elif nov_select == 2:
		gamemanager.nov_dice[2] = shop_nov[1]
		$UserDice/BasicDie3/NovDie3.texture = shop_nov[1].texture
		shop_nov[1] = null
		nov_select = 0
	else:
		user_die_select(2)

func _on_pd_4_button_button_down():
	if nov_select == 1:
		gamemanager.nov_dice[3] = shop_nov[0]
		$UserDice/BasicDie4/NovDie4.texture = shop_nov[0].texture
		shop_nov[0] = null
		nov_select = 0
	elif nov_select == 2:
		gamemanager.nov_dice[3] = shop_nov[1]
		$UserDice/BasicDie4/NovDie4.texture = shop_nov[1].texture
		shop_nov[1] = null
		nov_select = 0
	else:
		user_die_select(3)


func _on_pd_5_button_button_down():
	if nov_select == 1:
		gamemanager.nov_dice[4] = shop_nov[0]
		$UserDice/BasicDie5/NovDie5.texture = shop_nov[0].texture
		shop_nov[0] = null
		nov_select = 0
	elif nov_select == 2:
		gamemanager.nov_dice[4] = shop_nov[1]
		$UserDice/BasicDie5/NovDie5.texture = shop_nov[1].texture
		shop_nov[1] = null
		nov_select = 0
	else:
		user_die_select(4)


func _on_pd_6_button_button_down():
	if nov_select == 1:
		gamemanager.nov_dice[5] = shop_nov[0]
		$UserDice/BasicDie6/NovDie6.texture = shop_nov[0].texture
		shop_nov[0] = null
		nov_select = 0
	elif nov_select == 2:
		gamemanager.nov_dice[5] = shop_nov[1]
		$UserDice/BasicDie6/NovDie6.texture = shop_nov[1].texture
		shop_nov[1] = null
		nov_select = 0
	else:
		user_die_select(5)



func _on_sd_1_button_button_down():
	if placing_side == 1:
		select_die_selected(0)
	else: return


func _on_sd_2_button_button_down():
	if placing_side == 1:
		select_die_selected(1)
	else: return


func _on_sd_3_button_button_down():
	if placing_side == 1:
		select_die_selected(2)
	else: return


func _on_sd_4_button_button_down():
	if placing_side == 1:
		select_die_selected(3)
	else: return


func _on_sd_5_button_button_down():
	if placing_side == 1:
		select_die_selected(4)
	else: return


func _on_sd_6_button_button_down():
	if placing_side == 1:
		select_die_selected(5)
	else: return
	
	


func _on_reroll_button_down():
	if gamemanager.money < 7:
		return
	else:
		gamemanager.money -= 7
		generate_chests()
		generate_dice()


func _on_shop_item_hover(item: Special) -> void:
	print("Hovering!!!")
	show_hover(item)


func _on_shop_item_unhover() -> void:
	print("Unhovering!!!")
	$TextureRect.hide_menu()


func _on_shop_item_2_hover(item: Special) -> void:
	print("Hovering!!!")
	show_hover(item)

func _on_shop_item_2_unhover() -> void:
	print("Unhovering!!!")
	$TextureRect.hide_menu()

func show_hover(item: Special) -> void:
	var popup = $TextureRect
	
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


func _on_next_button_down() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_cup_button_button_down():
	gamemanager.money -= shop_cup.price
	gamemanager.cup = $ShopCup.item_data
	$ShopCup.visible = false


func _on_si_button_1_button_down() -> void:
	if gamemanager.money >= shop_nov[0].price:
		gamemanager.money -= shop_nov[0].price
		$ShopItem.visible = false
		nov_select = 1
	else:
		return


func _on_si_button_2_button_down() -> void:
	if gamemanager.money >= shop_nov[1].price:
		gamemanager.money -= shop_nov[1].price
		$ShopItem2.visible = false
		nov_select = 2
	else:
		return
