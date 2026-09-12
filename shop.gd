extends Node2D

var rng = RandomNumberGenerator.new()

var num_images = (
	["res://Assets/Dice Assetes/One.png",
	"res://Assets/Dice Assetes/Two.png",
	"res://Assets/Dice Assetes/Three.png",
	"res://Assets/Dice Assetes/Four.png",
	"res://Assets/Dice Assetes/Five.png",
	"res://Assets/Dice Assetes/Six.png"])
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.seed = 12345
	generate_items()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var modifiers = ["weighted", "pointup", "multup", "steel"]

var side_pool = [1, 2, 3, 4, 5, 6]

var mod_chance = .33

var tier2_chance = .33

var shopsides = []

var shopchests = []

func generate_side():
	var side = side_pool[randi() % side_pool.size()]
	var side_mod = "none"
	if(randf() < mod_chance):
		side_mod = modifiers[randi() % modifiers.size()]
	return [side, side_mod]

func generate_chest():
	var chest = "tier 1"
	if(randf() < tier2_chance):
		chest = "tier 2"
	return chest

func generate_items():
	shopsides = [generate_side(), generate_side()]
	shopchests = [generate_chest(), generate_chest()]
	
	$ShopDice/ShopDie1/Side_num.texture = num_images[shopsides[0][0]]
	$ShopDice/ShopDie1/Side_mod.texture = num_images[shopsides[0][1]]
	
	$ShopDice/ShopDie2/Side_num.texture = num_images[shopsides[1][0]]
	$ShopDice/ShopDie2/Side_mod.texture = num_images[shopsides[1][1]]

	
