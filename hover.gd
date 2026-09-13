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
		var mouse = get_global_mouse_position()
		var screen = get_viewport_rect().size
		
		global_position = mouse + Vector2(15, 15)
		
		if global_position.x + size.x > screen.x:
			global_position.x = mouse.x - size.x - 15
		
		if global_position.y + size.y > screen.y:
			global_position.y = mouse.y - size.y - 15
