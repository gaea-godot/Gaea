@tool
extends TextureRect


const RESOLUTION: Vector2i = Vector2i(64, 64)

var selected_output: StringName = &""
var node: GaeaGraphNode
var slider_container: HBoxContainer
var slider: HSlider
var slider_label: SpinBox


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	expand_mode = EXPAND_FIT_HEIGHT
	stretch_mode = STRETCH_SCALE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	slider_container = HBoxContainer.new()

	slider_label = SpinBox.new()
	slider_label.step = 0.01
	slider_label.min_value = 0.0
	slider_label.max_value = 1.0

	slider = HSlider.new()
	slider.step = 0.001
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider_label.value_changed.connect(slider.set_value_no_signal)
	slider_label.value_changed.connect(update.unbind(1))
	slider.value_changed.connect(update.unbind(1))
	slider.value_changed.connect(slider_label.set_value_no_signal)
	slider.allow_greater = true
	slider.allow_lesser = true

	slider_label.allow_greater = true
	slider_label.allow_lesser = true

	slider_container.add_child(slider)
	slider_container.add_child(slider_label)

	get_parent().add_child(slider_container)

	texture = ImageTexture.create_from_image(Image.create_empty(RESOLUTION.x, RESOLUTION.y, true, Image.FORMAT_RGBA8))


func toggle(for_output: StringName) -> void:
	if not get_parent().visible:
		get_parent().show()
		slider_container.visible = node.resource.get_output_port_type(for_output) == GaeaValue.Type.DATA
		selected_output = for_output
		update()
	else:
		if selected_output == for_output:
			selected_output = &""
		get_parent().hide()

	node.auto_shrink.call_deferred()


func update() -> void:
	if not is_visible_in_tree():
		return

	var resolution: Vector2i = RESOLUTION
	if is_instance_valid(node.generator):
		resolution = resolution.min(Vector2i(node.generator.world_size.x, node.generator.world_size.y))

	var data: Dictionary = node.resource.traverse(
		selected_output,
		AABB(Vector3.ZERO, Vector3(resolution.x, resolution.y, 1)),
		node.generator.data
	).get("value", {})

	node.generator.data.cache.clear()

	var image: Image = Image.create_empty(resolution.x, resolution.y, true, Image.FORMAT_RGBA8)
	for x: int in resolution.x:
		for y: int in resolution.y:
			var color: Color
			var value = data.get(Vector3i(x, y, 0))
			if value == null:
				continue
			match node.resource.get_output_port_type(selected_output):
				GaeaValue.Type.DATA:
					if typeof(value) != TYPE_FLOAT or is_nan(value):
						continue
					color = Color(value, value, value, 1.0 if value >= slider.value else 0.0)
				GaeaValue.Type.MAP:
					if value is not GaeaMaterial or not is_instance_valid(value):
						continue
					color = value.preview_color
				_:
					continue
			image.set_pixelv(Vector2i(x, y), color)

	texture = ImageTexture.create_from_image(image)
