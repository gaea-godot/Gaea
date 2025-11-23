@tool
extends GaeaGraphNode


static var _panel_stylebox: StyleBoxFlat
static var _panel_selected_stylebox: StyleBoxFlat
static var _titlebar_stylebox: StyleBoxFlat
static var _titlebar_selected_stylebox: StyleBoxFlat


func _add_titlebar_nodes() -> void:
	if is_instance_valid(resource):
		var titlebar_hbox := get_titlebar_hbox()
		var title_label: Label = titlebar_hbox.get_child(0)
		title_label.queue_free()

		var line_edit: LineEdit = LineEdit.new()
		line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
		line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line_edit.text = graph_edit.graph.get_node_data_value(resource.id, &"title", "SubGraph")
		line_edit.flat = true
		line_edit.text_submitted.connect(
			func(new_text: String) -> void:
				graph_edit.graph.set_node_data_value(resource.id, &"title", new_text)
		)
		titlebar_hbox.add_child(line_edit)

		var open_button := Button.new()
		open_button.icon = preload("res://addons/gaea/assets/graph.svg")
		open_button.flat = true
		open_button.pressed.connect(_open)
		titlebar_hbox.add_child(open_button)
		titlebar_hbox.move_child(open_button, 0)

		super()


func _apply_style() -> void:
	_make_square.call_deferred()

	if not is_instance_valid(_panel_stylebox):
		_panel_stylebox = get_theme_stylebox("panel").duplicate()
		_panel_stylebox.border_color = _panel_stylebox.bg_color.blend(Color(resource.get_title_color(), 0.2))
		_panel_stylebox.corner_radius_bottom_right += 5
		_panel_stylebox.corner_radius_bottom_left += 5

		_panel_selected_stylebox = get_theme_stylebox("panel_selected").duplicate()
		_panel_selected_stylebox.corner_radius_bottom_right = _panel_stylebox.corner_radius_bottom_right
		_panel_selected_stylebox.corner_radius_bottom_left = _panel_stylebox.corner_radius_bottom_left

		_titlebar_stylebox = get_theme_stylebox("titlebar").duplicate()
		_titlebar_stylebox.corner_radius_top_right = _panel_stylebox.corner_radius_bottom_right
		_titlebar_stylebox.corner_radius_top_left = _panel_stylebox.corner_radius_bottom_left

		_titlebar_selected_stylebox = get_theme_stylebox("titlebar_selected").duplicate()
		_titlebar_selected_stylebox.corner_radius_top_right = _panel_stylebox.corner_radius_bottom_right
		_titlebar_selected_stylebox.corner_radius_top_left = _panel_stylebox.corner_radius_bottom_left

		_titlebar_stylebox.bg_color = _titlebar_stylebox.bg_color.blend(Color(resource.get_title_color(), 0.3))
		_titlebar_selected_stylebox.bg_color = _titlebar_stylebox.bg_color

	add_theme_stylebox_override("panel", _panel_stylebox)
	add_theme_stylebox_override("panel_selected", _panel_selected_stylebox)
	add_theme_stylebox_override("titlebar", _titlebar_stylebox)
	add_theme_stylebox_override("titlebar_selected", _titlebar_selected_stylebox)


func _make_square() -> void:
	custom_minimum_size.x = maxf(size.y, size.x)
	custom_minimum_size.y = custom_minimum_size.x


func _open() -> void:
	graph_edit.open_subgraph(resource.subgraph, graph_edit.graph)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.double_click and event.open_button_index == MOUSE_BUTTON_LEFT:
			_open()
