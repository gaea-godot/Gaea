@tool
extends "res://addons/gaea/graph/nodes/preview_texture.gd"


const CHECKERBOARD_SIZE: Vector2i = Vector2i(8, 8)

@onready var layer_selection: OptionButton = %PreviewLayerSelection
@onready var type_selection: OptionButton = %PreviewTypeSelection
@onready var tertiary_axis_spin_box: SpinBox = %PreviewTertiaryAxisSpinBox


var generator: GaeaGenerator

@onready var bg: TextureRect = $BG


func _ready() -> void:
	type = GaeaGraphNode.SlotTypes.MAP_DATA
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reset_texture()

	var image: Image = Image.create_empty(RESOLUTION.x, RESOLUTION.y, false, Image.FORMAT_RGBA8)
	for x in ceili(RESOLUTION.x / CHECKERBOARD_SIZE.x):
		for y in ceili(RESOLUTION.y / CHECKERBOARD_SIZE.y):
			image.fill_rect(Rect2i(
					Vector2i(x, y) * CHECKERBOARD_SIZE,
					CHECKERBOARD_SIZE
				),
				Color.GRAY if (x % 2 == y % 2) else Color.DIM_GRAY
			)
	bg.texture = ImageTexture.create_from_image(image)


func reset_texture() -> void:
	texture = null


func _on_generation_finished(grid: GaeaGrid) -> void:
	var resolution: Vector2i = RESOLUTION * 2
	axis = type_selection.selected
	if is_instance_valid(generator):
		resolution = Vector2i(
			mini(generator.world_size.x, resolution.x),
			mini(generator.world_size.y if axis == Axis.XY else generator.world_size.z, resolution.y)
		)

	tertiary_axis_spin_box.value = clampi(
		tertiary_axis_spin_box.value,
		0,
		(generator.world_size.z if axis == Axis.XY else generator.world_size.y) - 1
	)

	tertiary_axis = tertiary_axis_spin_box.value
	if layer_selection.selected != 0:
		_draw_grid(grid.get_layer(layer_selection.selected - 1), resolution)
	else:
		var combined_layers: Dictionary

		for layer_idx in grid.get_layers_count():
			var layer: Dictionary = grid.get_layer(layer_idx)
			for cell in layer:
				if is_instance_valid(layer.get(cell)):
					combined_layers.set(cell, layer.get(cell))
		_draw_grid(combined_layers, resolution)
