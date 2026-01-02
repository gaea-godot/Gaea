@tool
class_name GaeaCheckableCell
extends Control

signal cell_pressed

enum CheckMode {
	BOOLEAN,   # checked / unchecked
	TRISTATE,  # checked / crossed / empty
}

enum CoordinateFormat {
	ALIGNED_3D,
	ALIGNED_2D,
	VERTICAL_OFFSET_2D,
	HORIZONTAL_OFFSET_2D,
}

const CELL_SIZE := Vector2(24, 24)

const CHECK = preload("uid://w7nuor02uk24")
const CROSS = preload("uid://cl81d05sq3dmb")


## If [code]CheckMode.BOOLEAN[/code], each cell can only be checked or not. If [code]CheckMode.TRISTATE[/code], each cell can either
## be checked, crossed, or empty.
@export var check_mode: CheckMode = CheckMode.BOOLEAN:
	set(value):
		check_mode = value
		_remove_invalid_states()
		queue_redraw()

## Defines how cells are interpreted and displayed relative to the reference origin.
@export var coordinate_format: CoordinateFormat = CoordinateFormat.ALIGNED_3D:
	set(value):
		coordinate_format = value
		if is_instance_valid(z_slider):
			z_slider.visible = coordinate_format == CoordinateFormat.ALIGNED_3D
		_remove_invalid_states()
		queue_redraw()

## If [code]true[/code], show origin cell.
@export var show_origin: bool = false:
	set(value):
		show_origin = value
		_remove_invalid_states()
		queue_redraw()

## Defines the radius of the checkbox grid around the origin cell.
@export var radius: int = 2:
	set(value):
		radius = maxi(value, 1)
		custom_minimum_size = (radius * 2 + 1) * CELL_SIZE
		if is_instance_valid(z_slider):
			z_slider.tick_count = (radius * 2 + 1)
			z_slider.min_value = -radius
			z_slider.max_value = radius
		_remove_invalid_states()
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
	_remove_invalid_states()


func get_states() -> Dictionary[Vector3i, bool]:
	return _states


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		tooltip_text = ""
		if check_mode == CheckMode.TRISTATE:
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

			match check_mode:
				CheckMode.BOOLEAN:
					_states[cell] = true
				CheckMode.TRISTATE:
					if event.button_index == MOUSE_BUTTON_LEFT:
						_states[cell] = true
					elif event.button_index == MOUSE_BUTTON_RIGHT:
						_states[cell] = false
			queue_redraw()
			cell_pressed.emit()


func _point_to_cell(point: Vector2) -> Vector2i:
	var first_row_parity: int = radius % 2
	match coordinate_format:
		CoordinateFormat.HORIZONTAL_OFFSET_2D:
			if ceili(point.y / CELL_SIZE.y) % 2 == first_row_parity:
				point.x -= CELL_SIZE.x / 2
		CoordinateFormat.VERTICAL_OFFSET_2D:
			if ceili(point.x / CELL_SIZE.x) % 2 == first_row_parity:
				point.y -= CELL_SIZE.y / 2
	return point / CELL_SIZE


func _to_relative(cell: Vector2i) -> Vector3i:
	return Vector3i(
		cell.x - radius,
		cell.y - radius,
		_current_z
	)


func _get_valid_cells() -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	var circumference: int = (radius * 2) + 1
	for x in circumference:
		for y in circumference:
			list.append(Vector2i(x, y))
	if not show_origin:
		list.erase(Vector2i(radius, radius))
	return list


func _remove_invalid_states() -> void:
	if _states.is_empty():
		return
	var changed: bool = false
	var valid_cells: Array = _get_valid_cells().map(_to_relative)
	for cell in _states.keys():
		if not valid_cells.has(cell):
			_states.erase(cell)
			changed = true
	if changed:
		cell_pressed.emit()


func _draw() -> void:
	var cell_mouse_pos: Vector3i = _to_relative(_point_to_cell(get_local_mouse_position()))
	var circumference: int = (radius * 2) + 1
	var first_row_parity: int = radius % 2

	for cell: Vector2i in _get_valid_cells():
		var color := Color.GRAY
		var relative_cell := _to_relative(cell)
		var icon: Texture2D = null
		var rect: Rect2 = Rect2(Vector2(cell) * CELL_SIZE, CELL_SIZE)

		match coordinate_format:
			CoordinateFormat.HORIZONTAL_OFFSET_2D:
				if cell.y % 2 != first_row_parity:
					if cell.x == circumference - 1:
						continue
					rect.position.x += CELL_SIZE.x * 0.5
			CoordinateFormat.VERTICAL_OFFSET_2D:
				if cell.x % 2 != first_row_parity:
					if cell.y == circumference - 1:
						continue
					rect.position.y += CELL_SIZE.y * 0.5

		if relative_cell == cell_mouse_pos:
			color = color.lightened(0.85)

		if _states.has(relative_cell):
			if _states.get(relative_cell) == true:
				icon = CHECK
			else:
				icon = CROSS

		draw_texture_rect(_checkbox_icon, rect, false, color)

		if is_instance_valid(icon):
			draw_texture_rect(
				icon,
				Rect2(rect.position + Vector2(2, 2), CELL_SIZE - Vector2(4, 4)),
				false
			)

	# Origin point
	if _current_z == 0 and not _states.has(_to_relative(Vector2(radius, radius))):
		draw_circle(
			Vector2(radius, radius) * CELL_SIZE + (CELL_SIZE * 0.5),
			CELL_SIZE.x * 0.1,
			Color(Color.GRAY, 0.5),
			true, -1.0, true
		)
