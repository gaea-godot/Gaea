class_name GaeaGraphFrame
extends GraphFrame

## ID of the frame
var id: int

## Reference to the parent GaeaGraphEdit
var graph_edit: GaeaGraphEdit


func _ready() -> void:
	if title.is_empty():
		title = "Title"
	size = Vector2(512, 256)
	autoshrink_changed.connect(_on_autoshrink_changed.unbind(1))
	dragged.connect(_on_dragged)


func _on_autoshrink_changed() -> void:
	resizable = not autoshrink_enabled
	graph_edit.graph.set_node_data_value(id, &"autoshrink", autoshrink_enabled)


func _on_dragged(_from: Vector2, to: Vector2) -> void:
	graph_edit.graph.set_node_position(id, to)


func start_rename(gaea_panel: GaeaPanel) -> void:
	var line_edit: LineEdit = LineEdit.new()
	line_edit.text = title
	line_edit.select_all_on_focus = true
	line_edit.expand_to_text_length = true
	line_edit.position = gaea_panel.get_local_mouse_position()
	line_edit.text_submitted.connect(_on_rename_text_submitted, CONNECT_ONE_SHOT)
	line_edit.text_submitted.connect(line_edit.queue_free.unbind(1), CONNECT_DEFERRED)
	line_edit.focus_exited.connect(line_edit.queue_free)
	gaea_panel.add_child(line_edit)
	line_edit.grab_click_focus()
	line_edit.grab_focus()


func _on_rename_text_submitted(new_text: String) -> void:
	set_title(new_text)
	graph_edit.graph.set_node_data_value(id, &"title", title)


func start_tint_color_change(gaea_panel: Control) -> void:
	var popup: PopupPanel = PopupPanel.new()
	popup.position = gaea_panel.get_global_mouse_position() as Vector2i

	var vbox_container: VBoxContainer = VBoxContainer.new()

	var color_picker: ColorPicker = ColorPicker.new()
	color_picker.color_changed.connect(_on_color_changed)
	color_picker.color = tint_color

	var ok_button: Button = Button.new()
	ok_button.text = "OK"
	ok_button.pressed.connect(popup.queue_free)

	vbox_container.add_child(color_picker)
	vbox_container.add_child(ok_button)

	popup.add_child(vbox_container)

	gaea_panel.add_child(popup)
	popup.popup()


func _on_color_changed(new_color: Color) -> void:
	set_tint_color(new_color)
	graph_edit.graph.set_node_data_value(id, &"tint_color", new_color)


## Loads data with the same format as seen in [method get_save_data].
func load_save_data(saved_data: Dictionary) -> void:
	title = saved_data.get(&"title", "Title")
	position_offset = saved_data.get(&"position", Vector2.ZERO)
	size = saved_data.get(&"size", Vector2(512, 256))
	tint_color = saved_data.get(&"tint_color", tint_color)
	tint_color_enabled = saved_data.get(&"tint_color_enabled", false)
	autoshrink_enabled = saved_data.get(&"autoshrink", true)
