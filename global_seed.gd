class_name Global_seed
extends Node

var seed: int = 123456
var random_seed = RandomNumberGenerator.new()

func set_seed(new_seed: int):
	seed(seed)
