@tool
extends CheckBox

const CHECK = preload("uid://w7nuor02uk24")
const CROSS = preload("uid://cl81d05sq3dmb")

var current_state: bool = true

@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	add_theme_icon_override("checked", get_theme_icon("unchecked"))


func _toggled(toggled_on: bool) -> void:
	texture_rect.set_visible.call_deferred(toggled_on)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					texture_rect.texture = CHECK
					current_state = true
				MOUSE_BUTTON_RIGHT:
					texture_rect.texture = CROSS
					current_state = false


func set_state(p_pressed: bool, checked: bool) -> void:
	if checked:
		texture_rect.texture = CHECK
	else:
		texture_rect.texture = CROSS
	current_state = checked
	set_pressed(p_pressed)
	texture_rect.visible = p_pressed
