class_name Global_seed
extends Node

var seed: int = 123456
var random_seed = RandomNumberGenerator.new()
var man_seed = 0

func set_seed(new_seed: int):
	man_seed = 1
	seed(new_seed)


func _on_line_edit_text_submitted(new_text: String) -> void:
	set_seed(int(new_text))
	

func _on_button_pressed() -> void:
	if man_seed == 0:
		seed(random_seed.randi())
