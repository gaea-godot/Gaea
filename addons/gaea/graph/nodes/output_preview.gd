@tool
extends "res://addons/gaea/graph/nodes/preview_texture.gd"


const CHECKERBOARD_SIZE: Vector2i = Vector2i(16, 16)

var generator: GaeaGenerator


func _ready() -> void:
	type = GaeaGraphNode.SlotTypes.MAP_DATA
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reset_texture()


func reset_texture() -> void:
	var image: Image = Image.create_empty(RESOLUTION.x, RESOLUTION.y, false, Image.FORMAT_RGBA8)
	for x in ceili(RESOLUTION.x / CHECKERBOARD_SIZE.x):
		for y in ceili(RESOLUTION.y / CHECKERBOARD_SIZE.y):
			image.fill_rect(Rect2i(
					Vector2i(x, y) * CHECKERBOARD_SIZE,
					CHECKERBOARD_SIZE
				),
				Color.GRAY if (x % 2 == y % 2) else Color.DIM_GRAY
			)
	texture = ImageTexture.create_from_image(image)


func _on_generation_finished(grid: GaeaGrid) -> void:
	var combined_layers: Dictionary

	for layer_idx in grid.get_layers_count():
		var layer: Dictionary = grid.get_layer(layer_idx)
		for cell in layer:
			if is_instance_valid(layer.get(cell)):
				combined_layers.set(cell, layer.get(cell))

	var resolution: Vector2i = RESOLUTION
	if is_instance_valid(generator):
		resolution = Vector2i(generator.world_size.x, generator.world_size.y)
	_draw_grid(combined_layers, resolution)
