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
	seed(seed)
	generate_chests()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

enum modifier {add, coins, daisy, multmod, weighted, none}

var mod_list = [modifier.add, modifier.coins, modifier.daisy, modifier.multmod, modifier.weighted]

var side_pool = [1, 2, 3, 4, 5, 6]

@export var mod_chance = .33

@export var tier2_chance = .33

var shopdies = []

var shopchests = []

var chestsides = []

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

func on_side_select(side):
	$ChestScreen.visible = false
	$Chest_open_info.text = "Chest side selected with side of %d and mod of %s"%[chestsides[side][0], chestsides[side][1]]

func _on_chest_1_button_button_down():
	open_chest(shopchests[0][0])

func _on_chest_2_button_button_down():
	open_chest(shopchests[1][0])


func _on_chest_screen_side_selected(side):
	on_side_select(side)

#
#func _on_item_hover(special: Special) -> void:
	#print("Hovering!!!")
	#$TextureRect.display(special)
