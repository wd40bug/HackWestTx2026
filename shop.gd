extends Node2D

var seed = 1234

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
	seed(seed)
	generate_items()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

enum modifier {add, coins, daisy, multmod, weighted, none}

var mod_list = [modifier.add, modifier.coins, modifier.daisy, modifier.multmod, modifier.weighted]

var side_pool = [1, 2, 3, 4, 5, 6]

var mod_chance = .33

var tier2_chance = .33

var shopsides = []

var shopchests = []

func generate_side():
	var side = side_pool[randi() % side_pool.size()]
	var side_mod = modifier.none
	var side_price = 3
	if(randf() < mod_chance):
		side_price += 3
		side_mod = mod_list[randi() % mod_list.size()]
	return [side, side_mod, side_price]

func generate_chest():
	var chest = "tier 1"
	var chestprice = 5
	if(randf() < tier2_chance):
		chest = "tier 2"
		chestprice += 3
	return [chest, chestprice]

func generate_items():
	shopsides = [generate_side(), generate_side()]
	shopchests = [generate_chest(), generate_chest()]
		
	$ShopDice/ShopDie1/Side_num.texture = load(num_images[shopsides[0][0] - 1])
	if shopsides[0][1] != modifier.none:
		$ShopDice/ShopDie1/Side_mod.texture = load(mod_images[shopsides[0][1]])
	
	$ShopDice/ShopDie2/Side_num.texture = load(num_images[shopsides[1][0] - 1])
	if shopsides[1][1] != modifier.none:
		$ShopDice/ShopDie2/Side_mod.texture = load(mod_images[shopsides[1][1]])
	if shopchests[0][0] == "tier 1":
		$Chests/Chest1.texture = load("res://Assets/Shop Assets/Chest3.png")
	else:
		$Chests/Chest1.texture = load("res://Assets/Shop Assets/Chest5.png")
		
	if shopchests[1][0] == "tier 1":
		$Chests/Chest2.texture = load("res://Assets/Shop Assets/Chest3.png")
	else:
		$Chests/Chest2.texture = load("res://Assets/Shop Assets/Chest5.png")
		
	$ShopDice/ShopDie1/Price.text = "$%d" %shopsides[0][2]
	$ShopDice/ShopDie2/Price.text = "$%d" %shopsides[1][2]
	
	$Chests/Chest1/Price.text = "$%d" %shopchests[0][1]
	$Chests/Chest2/Price.text = "$%d" %shopchests[1][1]
