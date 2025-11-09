@tool
class_name GaeaRangeSlider
extends Control
# Slightly modified from
# https://github.com/detomon/godot-assorted-controls/blob/master/addons/detomon.assorted-controls/gui/range_slider/range_slider.gd

## A slider that goes from [member min_value] to [member max_value], used to adjust a range by
## moving grabbers along an axis.

## Emitted when [member min_value], [member max_value], or [member step] changes.
signal changed()
## Emitted when [member start_value] or [member end_value] changes.
signal value_changed(start_value: float, end_value: float)
## Emitted when dragging of an element starts. This is emitted before the corresponding
## [signal value_changed] signal.
signal drag_started()
## Emitted when dragging of an element ends. If [code]value_changed[/code] is true, [member start_value]
## or [member end_value] is different from the value when dragging was started.
signal drag_ended(value_changed: bool)

enum Orientation {
	NONE,
	HORIZONTAL,
	VERTICAL,
}

enum Element {
	NONE,
	GRABBER_LOW,
	GRABBER_HIGH,
	GRABBER_AREA,
}

@export_category("RangeSlider")

## RangeSlider's start value. Cannot be greater than [member end_value].
@export var start_value := 0.0: set = set_start_value
## RangeSlider's end value. Cannot be less than [member start_value].
@export var end_value := 0.0: set = set_end_value
## Minimum value. [member start_value] is clamped if less than [member min_value].
@export var min_value := 0.0: set = set_min_value
## Maximum value. [member end_value] is clamped if greater than [member max_value].
@export var max_value := 1.0: set = set_max_value
## If greater than [code]0[/code], [member start_value] and [member end_value] will always be
## rounded to a multiple of this property's value.
@export var step := 0.0: set = set_step
## If [code]true[/code], [member end_value] may be greater than [member max_value].
@export var allow_greater := false
## If [code]true[/code], [member start_value] may be less than [member min_value].
@export var allow_lesser := false
## Number of ticks displayed on the slider, including border ticks. Ticks are uniformly-distributed
## value markers.
@export_range(0, 1024) var tick_count := 0: set = set_tick_count
## If [code]true[/code], slider will display ticks for minimum and maximum values.
@export var ticks_on_borders := false: set = set_ticks_on_borders
## If [code]true[/code], the slider can be interacted with. If [code]false[/code], the value can be
## changed only by code.
@export var editable := true: set = set_editable

var _theme_cache := {
	slider_style = null,
	grabber_icon_low = null,
	grabber_icon_low_disabled = null,
	grabber_icon_low_highlight = null,
	grabber_icon_high = null,
	grabber_icon_high_disabled = null,
	grabber_icon_high_highlight = null,
	grabber_disabled = null,
	grabber_area = null,
	grabber_area_highlight = null,
	grabber_drag_margin = 0.0,
	grabber_area_drag_margin = 0.0,
	tick_icon = null,
	middle_tick = null
}
var _orientation := Orientation.NONE
var _drag_offset := Vector2.ZERO
var _drag_element := Element.NONE
var _drag_range := 0.0
var _highlight_element := Element.NONE
var _start_value_before_dragging := 0.0
var _end_value_before_dragging := 0.0
var _changing := false


func _init() -> void:
	if _orientation == Orientation.NONE:
		return

	mouse_exited.connect(_on_mouse_exited)


func _enter_tree() -> void:
	_update_theme_cache()


func _get_minimum_size() -> Vector2:
	var slider_style: StyleBox = _theme_cache.slider_style
	var grabber_icon_low: Texture2D = _theme_cache.grabber_icon_low
	var grabber_icon_high: Texture2D = _theme_cache.grabber_icon_high

	if not slider_style or not grabber_icon_low or not grabber_icon_high:
		return Vector2.ZERO

	var grabber_size_low := Vector2i(grabber_icon_low.get_size())
	var grabber_size_high := Vector2i(grabber_icon_high.get_size())
	var slider_min_size := Vector2i(slider_style.get_minimum_size())

	if _orientation == Orientation.HORIZONTAL:
		return Vector2i(
			maxi(slider_min_size.x, grabber_size_low.x + grabber_size_high.x),
			maxi(slider_min_size.y, maxi(grabber_size_low.y, grabber_size_high.y)),
		)

	return Vector2i(
		maxi(slider_min_size.x, maxi(grabber_size_low.x, grabber_size_high.x)),
		maxi(slider_min_size.y, grabber_size_low.y + grabber_size_high.y),
	)


func _draw() -> void:
	var slider_rect := _get_slider_rect()
	var grabber_area := _get_range_area_rect()

	_draw_slider(slider_rect)
	_draw_grabber_area(grabber_area)
	_draw_ticks()
	_draw_grabbers()


func _gui_input(event: InputEvent) -> void:
	if not editable:
		return

	var drag_element := _drag_element
	var highlight_element := _highlight_element

	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			var element := _get_element_at_point(event.position)

			if element != Element.NONE:
				drag_element = element
			highlight_element = drag_element

		else:
			drag_element = Element.NONE

			# Mouse was released outside of control.
			if not Rect2(Vector2.ZERO, size).has_point(event.position):
				highlight_element = Element.NONE

	elif event is InputEventMouseMotion:
		match _drag_element:
			Element.NONE:
				# Highlight element under mouse when not dragging.
				highlight_element = _get_element_at_point(event.position)

			Element.GRABBER_LOW:
				start_value = _point_to_value(event.position + _drag_offset)

			Element.GRABBER_HIGH:
				end_value = _point_to_value(event.position + _drag_offset)

			Element.GRABBER_AREA:
				var low := _point_to_value(event.position + _drag_offset)
				if not allow_greater:
					low = minf(low, max_value - _drag_range)
				if not allow_lesser:
					low = maxf(low, min_value)
				var high := low + _drag_range

				set_range(low, high)

	_set_drag_element(drag_element)
	_set_highlight_element(highlight_element)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			_update_theme_cache()


func set_start_value(value: float) -> void:
	if value == start_value:
		return

	if _changing:
		start_value = value
	else:
		set_range(value, maxf(value, end_value))


func set_end_value(value: float) -> void:
	if value == end_value:
		return

	if _changing:
		end_value = value
	else:
		set_range(minf(start_value, value), value)


func set_min_value(value: float) -> void:
	if value == min_value:
		return

	if _changing:
		min_value = value
	else:
		_set_bounds(value, max_value)


func set_max_value(value: float) -> void:
	if value == max_value:
		return

	if _changing:
		max_value = value
	else:
		_set_bounds(min_value, value)


func set_step(value: float) -> void:
	if value == step:
		return

	step = maxf(0.0, value)
	changed.emit()


func set_tick_count(value: int) -> void:
	tick_count = clampi(value, 0, 1024)
	queue_redraw()


func set_ticks_on_borders(value: bool) -> void:
	ticks_on_borders = value
	queue_redraw()


func set_editable(new_value: bool) -> void:
	editable = new_value
	if not editable:
		_set_drag_element(Element.NONE)
		_set_highlight_element(Element.NONE)


## Sets [member start_value] and [member end_value].
func set_range(start: float, end: float, do_signal: bool = true) -> void:
	# Clamp range at maximum value.
	if not allow_greater:
		start = minf(start, max_value)
		end = minf(end, max_value)
	# Clamp range at minimum value.
	if not allow_lesser:
		start = maxf(start, min_value)
		end = maxf(end, min_value)

	# Do not allow range ends to cross.
	start = minf(start, end)
	end = maxf(start, end)
	start = snappedf(start, step)
	end = snappedf(end, step)

	if start != start_value or end != end_value:
		_changing = true
		start_value = start
		end_value = end
		_changing = false
		if do_signal:
			value_changed.emit(start_value, end_value)
		queue_redraw()


func _draw_slider(slider_rect: Rect2) -> void:
	var slider: StyleBox = _theme_cache.slider_style
	draw_style_box(slider, Rect2i(slider_rect))





func _draw_grabber_area(grabber_area: Rect2) -> void:
	var area_style := _get_grabber_area_style()
	draw_style_box(area_style, Rect2i(grabber_area))

	var middle_tick: StyleBox = _theme_cache.middle_tick
	var min_size := middle_tick.get_minimum_size()
	draw_style_box(
		middle_tick,
		Rect2i(
			Vector2(grabber_area.get_center().x - (min_size.x * 0.5), grabber_area.position.y),
			Vector2(4, grabber_area.size.y)
		)
	)


func _draw_ticks() -> void:
	if tick_count < 2:
		return

	var rect := Rect2(Vector2.ZERO, size)
	var grabber_icon_low := _get_grabber_icon(Element.GRABBER_LOW)
	var grabber_icon_high := _get_grabber_icon(Element.GRABBER_HIGH)
	var grabber_size_low := grabber_icon_low.get_size()
	var grabber_size_high := grabber_icon_high.get_size()
	var tick_icon: Texture2D = _theme_cache.tick_icon
	var tick_size := tick_icon.get_size()

	var slider: StyleBox = _theme_cache.slider_style
	var slider_rect := Rect2(Vector2.ZERO, slider.get_minimum_size())

	match _orientation:
		Orientation.HORIZONTAL:
			slider_rect.size.x = rect.size.x
			slider_rect.position.y = (rect.size.y - slider_rect.size.y) * 0.5

			rect.position.x = grabber_size_low.x
			rect.position.y = slider_rect.position.y
			rect.end.x = size.x - grabber_size_high.x

			for i in tick_count:
				if not ticks_on_borders and (i == 0 or i + 1 == tick_count):
					continue

				var x := float(i) / float(tick_count - 1) * rect.size.x
				var tick_position := rect.position + Vector2(x - tick_size.x * 0.5, 0.0)

				draw_texture(tick_icon, Vector2i(tick_position))

		Orientation.VERTICAL:
			slider_rect.size.y = rect.size.y
			slider_rect.position.x = (rect.size.x - slider_rect.size.x) * 0.5

			rect.position.y = grabber_size_low.y
			rect.position.x = slider_rect.position.x
			rect.end.y = size.y - grabber_size_high.y

			for i in tick_count:
				if not ticks_on_borders and (i == 0 or i + 1 == tick_count):
					continue

				var y := float(i) / float(tick_count - 1) * rect.size.y
				var tick_position := rect.position + Vector2(0.0, y - tick_size.y * 0.5)

				draw_texture(tick_icon, Vector2i(tick_position))


func _draw_grabbers() -> void:
	var grabber_icon_low := _get_grabber_icon(Element.GRABBER_LOW)
	var grabber_icon_high := _get_grabber_icon(Element.GRABBER_HIGH)
	var grabber_rect_low := _get_grabber_rect(Element.GRABBER_LOW)
	var grabber_rect_high := _get_grabber_rect(Element.GRABBER_HIGH)

	draw_texture(
		grabber_icon_low,
		grabber_rect_low.position,
		Color.WHITE if _highlight_element == Element.GRABBER_LOW else Color.DARK_GRAY
	)
	draw_texture(
		grabber_icon_high,
		grabber_rect_high.position,
		Color.WHITE if _highlight_element == Element.GRABBER_HIGH else Color.DARK_GRAY
		)


func _update_theme_cache() -> void:
	var theme_type := &"Editor"
	var theme_type_fallback := &"HSlider"

	_theme_cache.slider_style = _theme_stylebox_get_or_fallback(&"slider", theme_type, theme_type_fallback)
	var middle_tick := StyleBoxLine.new()
	middle_tick.color = Color(Color.WHITE, 0.75)
	middle_tick.thickness = 2
	middle_tick.vertical = true
	middle_tick.grow_begin = 0.0
	middle_tick.grow_end = 0.0
	_theme_cache.middle_tick = middle_tick


	_theme_cache.grabber_icon_low = get_theme_icon(&"RangeSliderLeft", &"EditorIcons")
	_theme_cache.grabber_icon_low_disabled = get_theme_icon(&"grabber_low_disabled", theme_type)
	_theme_cache.grabber_icon_low_highlight = get_theme_icon(&"RangeSliderLeft", &"EditorIcons")
	_theme_cache.grabber_icon_high = get_theme_icon(&"RangeSliderRight", &"EditorIcons")
	_theme_cache.grabber_icon_high_disabled = get_theme_icon(&"grabber_high_disabled", theme_type)
	_theme_cache.grabber_icon_high_highlight = get_theme_icon(&"RangeSliderRight", &"EditorIcons")

	_theme_cache.grabber_area = get_theme_stylebox(&"grabber_area", &"HSlider")
	_theme_cache.grabber_area_highlight = _theme_cache.grabber_area.duplicate()
	_theme_cache.grabber_area_highlight.bg_color = _theme_cache.grabber_area_highlight.bg_color.lightened(0.25)
	_theme_cache.grabber_drag_margin = get_theme_constant(&"grabber_drag_margin", theme_type)
	_theme_cache.grabber_area_drag_margin = get_theme_constant(&"grabber_area_drag_margin", theme_type)

	_theme_cache.tick_icon = _theme_icon_get_or_fallback(&"tick", theme_type, theme_type_fallback)


func _theme_icon_get_or_fallback(icon_name: StringName, theme_type: StringName, theme_type_fallback: StringName) -> Texture2D:
	if has_theme_icon(name, theme_type):
		return get_theme_icon(icon_name, theme_type)

	return get_theme_icon(icon_name, theme_type_fallback)


func _theme_stylebox_get_or_fallback(icon_name: StringName, theme_type: StringName, theme_type_fallback: StringName) -> StyleBox:
	if has_theme_stylebox(name, theme_type):
		return get_theme_stylebox(icon_name, theme_type)

	return get_theme_stylebox(icon_name, theme_type_fallback)


func _set_bounds(low: float, high: float) -> void:
	low = minf(low, high)
	high = maxf(low, high)

	if low != min_value or high != max_value:
		_changing = true
		min_value = low
		max_value = high
		_changing = false
		set_range(start_value, end_value)
		changed.emit()
		queue_redraw()


func _get_slider_rect() -> Rect2i:
	var rect := Rect2(Vector2.ZERO, size)
	var slider_rect := Rect2(Vector2.ZERO, size - Vector2(0.0, 4.0))

	match _orientation:
		Orientation.HORIZONTAL:
			slider_rect.size.x = rect.size.x
			slider_rect.position.y = (rect.size.y - slider_rect.size.y) * 0.5

		Orientation.VERTICAL:
			slider_rect.size.y = rect.size.y
			slider_rect.position.x = (rect.size.x - slider_rect.size.x) * 0.5

	return slider_rect


func _get_grabber_icon(element: Element) -> Texture2D:
	match element:
		Element.GRABBER_LOW:
			if not editable:
				return _theme_cache.grabber_icon_low_disabled

			if _highlight_element == Element.GRABBER_LOW:
				return _theme_cache.grabber_icon_low_highlight

			return _theme_cache.grabber_icon_low

		Element.GRABBER_HIGH:
			if not editable:
				return _theme_cache.grabber_icon_high_disabled

			if _highlight_element == Element.GRABBER_HIGH:
				return _theme_cache.grabber_icon_high_highlight

			return _theme_cache.grabber_icon_high

	return null


func _get_grabber_area_style() -> StyleBox:
	if _highlight_element == Element.GRABBER_AREA:
		return _theme_cache.grabber_area_highlight

	return _theme_cache.grabber_area


func _get_grabber_rect(element: Element) -> Rect2i:
	var grabber_icon_low := _get_grabber_icon(Element.GRABBER_LOW)
	var grabber_icon_high := _get_grabber_icon(Element.GRABBER_HIGH)
	var grabber_size_low := grabber_icon_low.get_size()
	var grabber_size_high := grabber_icon_high.get_size()
	var grabber_rect := Rect2i()
	var drag_area := Vector2.ZERO

	match _orientation:
		Orientation.HORIZONTAL:
			drag_area = size - Vector2(grabber_size_low.x + grabber_size_high.x, grabber_size_low.y)

		Orientation.VERTICAL:
			drag_area = size - Vector2(grabber_size_low.x, grabber_size_low.y + grabber_size_high.y)

	match element:
		Element.GRABBER_LOW:
			var offset := clampf(remap(start_value, min_value, max_value, 0.0, 1.0), 0.0, 1.0) \
				if not is_equal_approx(min_value, max_value) \
				else max_value

			match _orientation:
				Orientation.HORIZONTAL:
					grabber_rect.position = Vector2i(drag_area * Vector2(offset, 0.5))

				Orientation.VERTICAL:
					grabber_rect.position = Vector2i(drag_area * Vector2(0.5, 1.0 - offset) + Vector2(0.0, grabber_size_high.y))

			grabber_rect.size = Vector2i(grabber_size_low)

		Element.GRABBER_HIGH:
			var offset := clampf(remap(end_value, min_value, max_value, 0.0, 1.0), 0.0, 1.0) \
				if not is_equal_approx(min_value, max_value) \
				else max_value

			match _orientation:
				Orientation.HORIZONTAL:
					grabber_rect.position = Vector2i(drag_area * Vector2(offset, 0.5) + Vector2(grabber_size_low.x, 0.0))

				Orientation.VERTICAL:
					grabber_rect.position = Vector2i(drag_area * Vector2(0.5, 1.0 - offset))

			grabber_rect.size = Vector2i(grabber_size_high)

	return grabber_rect


func _get_grabber_hit_area(element: Element) -> Rect2:
	var rect := _get_grabber_rect(element)
	var margin: int = _theme_cache.grabber_drag_margin

	match element:
		Element.GRABBER_LOW:
			rect = rect.grow_individual(margin, 0, margin, margin)

		Element.GRABBER_HIGH:
			rect = rect.grow_individual(0, margin, margin, margin)

	return rect


func _get_range_area_rect() -> Rect2:
	var rect := Rect2(Vector2.ZERO, size)
	#var slider: StyleBox = _theme_cache.slider_style
	var slider_rect := Rect2(Vector2.ZERO, size - Vector2(0.0, 6.0))
	var grabber_rect_low := _get_grabber_rect(Element.GRABBER_LOW)
	var grabber_rect_high := _get_grabber_rect(Element.GRABBER_HIGH)

	match _orientation:
		Orientation.HORIZONTAL:
			slider_rect.size.x = rect.size.x
			slider_rect.position.y = (rect.size.y - slider_rect.size.y) * 0.5

			var grabber_area := slider_rect
			grabber_area.position.x = grabber_rect_low.get_center().x
			grabber_area.end.x = grabber_rect_high.get_center().x

			return grabber_area

		Orientation.VERTICAL:
			slider_rect.size.y = rect.size.y
			slider_rect.position.x = (rect.size.x - slider_rect.size.x) * 0.5

			var grabber_area := slider_rect
			grabber_area.position.y = grabber_rect_high.get_center().y
			grabber_area.end.y = grabber_rect_low.get_center().y

			return grabber_area

	return Rect2i()


func _get_range_hit_area() -> Rect2:
	var rect := _get_range_area_rect()
	var margin: int = _theme_cache.grabber_area_drag_margin
	rect = rect.grow(margin)

	return rect


func _get_element_at_point(point: Vector2) -> Element:
	var grabber_rect_low := _get_grabber_hit_area(Element.GRABBER_LOW)
	var grabber_rect_high := _get_grabber_hit_area(Element.GRABBER_HIGH)
	var range_rect := _get_range_hit_area()

	if grabber_rect_low.has_point(point):
		var rect := Rect2(_get_grabber_rect(Element.GRABBER_LOW))

		match _orientation:
			Orientation.HORIZONTAL:
				# Relative to right side of grabber.
				_drag_offset = rect.position + rect.size * Vector2(1.0, 0.5) - point

			Orientation.VERTICAL:
				# Relative to top side of grabber.
				_drag_offset = rect.position + rect.size * Vector2(0.5, 0.0) - point

		return Element.GRABBER_LOW

	if grabber_rect_high.has_point(point):
		var rect := Rect2(_get_grabber_rect(Element.GRABBER_HIGH))

		match _orientation:
			Orientation.HORIZONTAL:
				# Relative to left side of grabber.
				_drag_offset = rect.position + rect.size * Vector2(0.0, 0.5) - point

			Orientation.VERTICAL:
				# Relative to bottom side of grabber.
				_drag_offset = rect.position + rect.size * Vector2(0.5, 1.0) - point

		return Element.GRABBER_HIGH

	if range_rect.has_point(point):
		var rect := Rect2(_get_grabber_rect(Element.GRABBER_LOW))
		_drag_range = end_value - start_value

		match _orientation:
			Orientation.HORIZONTAL:
				# Relative to right side of grabber.
				_drag_offset = rect.position + rect.size * Vector2(1.0, 0.5) - point

			Orientation.VERTICAL:
				# Relative to top side of grabber.
				_drag_offset = rect.position + rect.size * Vector2(0.5, 0.0) - point

		return Element.GRABBER_AREA

	return Element.NONE


func _set_drag_element(value: Element) -> void:
	if value == _drag_element:
		return

	_drag_element = value

	if _drag_element:
		_start_value_before_dragging = start_value
		_end_value_before_dragging = end_value
		drag_started.emit()

	else:
		var has_changed := start_value != _start_value_before_dragging \
			or end_value != _end_value_before_dragging
		drag_ended.emit(has_changed)

	queue_redraw()


func _set_highlight_element(value: Element) -> void:
	if value == _highlight_element:
		return

	_highlight_element = value
	queue_redraw()


func _point_to_value(point: Vector2) -> float:
	var grabber_icon_low := _get_grabber_icon(Element.GRABBER_LOW)
	var grabber_icon_high := _get_grabber_icon(Element.GRABBER_HIGH)
	var grabber_size_low := grabber_icon_low.get_size()
	var grabber_size_high := grabber_icon_high.get_size()
	var value := 0.0

	match _orientation:
		Orientation.HORIZONTAL:
			var value_rect_size := Vector2(size.x - grabber_size_low.x - grabber_size_high.x, size.y)
			var value_rect := Rect2(Vector2(grabber_size_low.x, 0.0), value_rect_size)
			value = remap(point.x, value_rect.position.x, value_rect.end.x, min_value, max_value)

		Orientation.VERTICAL:
			var value_rect_size := Vector2(size.x, size.y - grabber_size_low.y - grabber_size_high.y)
			var value_rect := Rect2(Vector2(0.0, grabber_size_low.y), value_rect_size)
			value = remap(point.y, value_rect.position.y, value_rect.end.y, max_value, min_value)

	return value


func _on_mouse_exited() -> void:
	if _drag_element == Element.NONE:
		_set_highlight_element(Element.NONE)
		queue_redraw()
