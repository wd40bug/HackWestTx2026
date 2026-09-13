extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass

enum side {side1, side2, side3, side4, side5}

signal side_selected()

func _on_die_1_button_button_down():
	side_selected.emit(side.side1)


func _on_die_2_button_button_down():
	side_selected.emit(side.side2)


func _on_die_3_button_button_down():
	side_selected.emit(side.side3)


func _on_die_4_button_button_down():
	side_selected.emit(side.side4)


func _on_die_5_button_button_down():
	side_selected.emit(side.side5)
