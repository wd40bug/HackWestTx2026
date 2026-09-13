@tool
extends Area2D

signal hover(item: Special)
signal unhover

@export var item_data: Special:
	set(value):
		item_data = value
		_update_visuals()

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_update_visuals()
	
	# We only want mouse interactions during actual gameplay, not while editing
	input_pickable = true
	if not Engine.is_editor_hint():
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		$CollisionShape2D.shape = RectangleShape2D.new()
		if sprite.texture:
			$CollisionShape2D.shape.size = sprite.texture.get_size()

func _update_visuals() -> void:
	# Ensure the sprite node actually exists before trying to update it
	if not is_node_ready():
		return
	
		
	if item_data and item_data.texture:
		sprite.texture = item_data.texture
		
	else:
		# Clears the image if you remove the resource
		sprite.texture = null 

func _on_mouse_entered() -> void:
	print("testing?!")
	hover.emit(item_data)

func _on_mouse_exited() -> void:
	print("testing?! but with exiting?")
	unhover.emit()
