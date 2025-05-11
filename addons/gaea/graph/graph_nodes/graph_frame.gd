class_name GaeaGraphFrame
extends GraphFrame


func _ready() -> void:
	if title.is_empty():
		title = "Title"
	size = Vector2(512, 256)
	name = name.replace("@", "_")
	autoshrink_changed.connect(_on_autoshrink_changed.unbind(1))


func _on_autoshrink_changed() -> void:
	resizable = not autoshrink_enabled


func start_rename(gaea_panel: Control) -> void:
	var line_edit: LineEdit = LineEdit.new()
	line_edit.text = title
	line_edit.select_all_on_focus = true
	line_edit.expand_to_text_length = true
	line_edit.position = gaea_panel.get_local_mouse_position()
	line_edit.text_submitted.connect(set_title)
	line_edit.text_submitted.connect(line_edit.queue_free.unbind(1), CONNECT_DEFERRED)
	line_edit.focus_exited.connect(line_edit.queue_free)
	gaea_panel.add_child(line_edit)
	line_edit.grab_click_focus()
	line_edit.grab_focus()


func start_tint_color_change(gaea_panel: Control) -> void:
		var _popup: PopupPanel = PopupPanel.new()
		_popup.position = gaea_panel.get_global_mouse_position() as Vector2i

		var vbox_container: VBoxContainer = VBoxContainer.new()

		var color_picker: ColorPicker = ColorPicker.new()
		color_picker.color_changed.connect(set_tint_color)
		color_picker.color = tint_color

		var ok_button: Button = Button.new()
		ok_button.text = "OK"
		ok_button.pressed.connect(_popup.queue_free)

		vbox_container.add_child(color_picker)
		vbox_container.add_child(ok_button)

		_popup.add_child(vbox_container)

		gaea_panel.add_child(_popup)
		_popup.popup()


## Returns the data to be saved to [GaeaGraph]. Includes [member GraphFrame.title], [member GraphFrame.tint_color], [member GraphFrame.autoshrink_enabled], etc.
func get_save_data() -> Dictionary:
	return {
		&"title": title,
		&"tint_color": tint_color,
		&"tint_color_enabled": tint_color_enabled,
		&"position": position_offset,
		&"attached": get_parent().get_attached_nodes_of_frame(name),
		&"size": size,
		&"autoshrink": autoshrink_enabled,
		&"name": name
	}

## Loads data with the same format as seen in [method get_save_data].
func load_save_data(saved_data: Dictionary) -> void:
	title = saved_data.get(&"title", "Frame")
	position_offset = saved_data.get(&"position", Vector2.ZERO)
	size = saved_data.get(&"size", Vector2(512, 256))
	tint_color = saved_data.get(&"tint_color", tint_color)
	tint_color_enabled = saved_data.get(&"tint_color_enabled", false)
	name = saved_data.get_or_add(&"name", name)
	autoshrink_enabled = saved_data.get(&"autoshrink", true)
