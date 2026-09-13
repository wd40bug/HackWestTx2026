extends TextureRect

@onready var title_label: Label = $TitleLabel
@onready var desc_label: Label = $DescLabel

func _ready() -> void:
	hide()

func display(data: Special) -> void:
	title_label.text = data.title
	desc_label.text = data.description
	
	move_to_front()
	show()

func hide_menu() -> void:
	hide()

func _process(_delta: float) -> void:
	# Snap the menu to the mouse while visible
	if visible:
		global_position = get_global_mouse_position() + Vector2(15, 15)
