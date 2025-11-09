@tool
extends Control


signal cell_pressed

const CELL_SIZE := Vector2(24, 24)

const CHECK = preload("uid://w7nuor02uk24")
const CROSS = preload("uid://cl81d05sq3dmb")


## If [code]true[/code], each cell can only be checked or not. If [code]false[/code], each cell can either
## be checked, crossed, or empty.
@export var simple: bool = true
@export var show_origin: bool = false
@export var circumference: int = 3 :
	set(value):
		circumference = value
		custom_minimum_size = circumference * CELL_SIZE
		queue_redraw()
@export var z_slider: VSlider


var _states: Dictionary[Vector3i, bool] : set = set_states, get = get_states
var _checkbox_icon: Texture2D
var _current_z: int = 0 :
	set(value):
		_current_z = value
		queue_redraw()


func _ready() -> void:
	_checkbox_icon = get_theme_icon(&"unchecked", &"CheckBox")
	z_slider.value = 0
	z_slider.min_value = -roundi((float(circumference) * 0.5) - 1)
	z_slider.max_value = roundi(float(circumference) * 0.5) - 1
	z_slider.value_changed.connect(func(value: float): _current_z = roundi(value))

	mouse_exited.connect(queue_redraw)



func set_pressed(cells: Array) -> void:
	cells = Array(cells, TYPE_VECTOR3I, &"", null)
	for cell in cells:
		_states[cell] = true


func get_pressed_cells() -> Array[Vector3i]:
	return _states.keys() as Array[Vector3i]


func set_states(states: Dictionary) -> void:
	_states = Dictionary(states, TYPE_VECTOR3I, &"", null, TYPE_BOOL, &"", null)


func get_states() -> Dictionary[Vector3i, bool]:
	return _states


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		tooltip_text = ""
		if not simple:
			tooltip_text = "Left click to set to true, right click to set to false.\n"
		var cell := _to_relative(_point_to_cell(event.position))
		tooltip_text += str(cell)
		queue_redraw()

	if event is InputEventMouseButton:
		if event.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			return

		if event.pressed:
			var cell := _to_relative(_point_to_cell(event.position))
			if _states.has(cell):
				_states.erase(cell)
				queue_redraw()
				cell_pressed.emit()
				return

			if simple:
				_states[cell] = true
			else:
				if event.button_index == MOUSE_BUTTON_LEFT:
					_states[cell] = true
				elif event.button_index == MOUSE_BUTTON_RIGHT:
					_states[cell] = false
			queue_redraw()
			cell_pressed.emit()


func _point_to_cell(point: Vector2) -> Vector2i:
	return point / CELL_SIZE


func _to_relative(cell: Vector2i) -> Vector3i:
	return Vector3i(
		cell.x - floori(float(circumference) * 0.5),
		cell.y - floori(float(circumference) * 0.5),
		_current_z
	)


func _draw() -> void:
	var cell_mouse_pos := _to_relative(_point_to_cell(get_local_mouse_position()))
	for x in circumference:
		for y in circumference:
			var color := Color.GRAY
			var cell := Vector2i(x, y)
			var relative_cell := _to_relative(cell)
			var icon: Texture2D = null
			var rect: Rect2 = Rect2(Vector2(cell) * CELL_SIZE, CELL_SIZE)

			if relative_cell == cell_mouse_pos:
				color = color.lightened(0.85)

			if _states.has(relative_cell):
				if _states.get(relative_cell) == true:
					icon = CHECK
				else:
					icon = CROSS

			if relative_cell == Vector3i.ZERO:
				if not show_origin:
					continue

				# Origin point
				if not is_instance_valid(icon): # Hide when it's checked/crossed because it looks ugly.
					draw_circle(
						Vector2(cell) * CELL_SIZE + (CELL_SIZE * 0.5),
						CELL_SIZE.x * 0.1,
						Color(color, 0.5),
						true, -1.0, true
					)
			draw_texture_rect(_checkbox_icon, rect, false, color)

			if is_instance_valid(icon):
				draw_texture_rect(
					icon,
					Rect2(Vector2(cell) * CELL_SIZE + Vector2(2, 2), CELL_SIZE - Vector2(4, 4)),
					false
				)
