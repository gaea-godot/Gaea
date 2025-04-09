extends TextureRect


const SIZE = Vector2(128, 24)

var gradient: GaeaMaterialGradient


func _ready() -> void:
	custom_minimum_size = SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = get_combined_minimum_size()
	tooltip_text = "Color used is the GaeaMaterial's preview_color"


func update() -> void:
	var image: Image = Image.create_empty(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	for idx: int in gradient.points.size():
		var start_offset: float = gradient.points.get(idx).get(&"offset", 0.0)
		var end_offset: float
		if idx - 1 < 0:
			end_offset = 1.0
		else:
			end_offset = gradient.points.get(idx - 1).get(&"offset", 0.0)
		var gaea_material: GaeaMaterial = gradient.points.get(idx).get(&"material", null)
		var color: Color = Color.TRANSPARENT if not is_instance_valid(gaea_material) else gaea_material.preview_color

		image.fill_rect(Rect2(
				Vector2(start_offset * SIZE.x, 0.0),
				Vector2(((end_offset + 0.005) - start_offset) * SIZE.x, SIZE.y)
			),
			color)
	texture = ImageTexture.create_from_image(image)
