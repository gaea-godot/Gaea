@tool
class_name GaeaEditorGeneratorButtons
extends PanelContainer

var generator: GaeaGenerator

var _generate_button: Button
var _clear_button: Button

var _generate_icon: Texture2D
var _clear_icon: Texture2D
var _cancel_icon: Texture2D

var _generating: bool = false

var _gen_pressed_call = _generate.bind(true)
var _gen_started_call = _generate.bind(false)
var _gen_finished_call = reset.unbind(1)


func _enter_tree() -> void:
	_generate_icon = get_theme_icon(&"Reload", &"EditorIcons")
	_clear_icon = get_theme_icon(&"Remove", &"EditorIcons")
	_cancel_icon = get_theme_icon(&"Stop", &"EditorIcons")

	var vbox := VBoxContainer.new()
	add_child(vbox)

	_generate_button = Button.new()
	_generate_button.text = "Generate"
	_generate_button.icon = _generate_icon
	_generate_button.pressed.connect(_gen_pressed_call)
	generator.generation_started.connect(_gen_started_call)
	generator.generation_finished.connect(_gen_finished_call)
	vbox.add_child(_generate_button)

	_clear_button = Button.new()
	_clear_button.text = "Clear"
	_clear_button.icon = _clear_icon
	_clear_button.pressed.connect(_clear)
	generator.generation_cancelled.connect(reset)
	vbox.add_child(_clear_button)


func _exit_tree() -> void:
	_generate_button.pressed.disconnect(_gen_pressed_call)
	generator.generation_started.disconnect(_gen_started_call)
	generator.generation_finished.disconnect(_gen_finished_call)
	_clear_button.pressed.disconnect(_clear)
	generator.generation_cancelled.disconnect(reset)


func _generate(do_generate: bool = true) -> void:
	_generating = true
	_generate_button.disabled = true
	_clear_button.text = "Cancel"
	_clear_button.icon = _cancel_icon
	if do_generate:
		generator.generate()


func _clear() -> void:
	if _generating:
		generator.cancel_generation()
	else:
		generator.request_reset()


func reset() -> void:
	_generating = false
	_generate_button.disabled = false
	_clear_button.text = "Clear"
	_clear_button.icon = _clear_icon
