@tool
extends TextureRect


const SIZE = Vector2i(128, 32)
const CHECKERBOARD_SIZE = Vector2i(16, 16)

var gradient: GradientGaeaMaterial


func _ready() -> void:
	custom_minimum_size = SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	focus_mode = Control.FOCUS_NONE
	tooltip_text = "Color used is the GaeaMaterial's preview_color"


func update() -> void:
	var image: Image = Image.create_empty(SIZE.x, SIZE.y, false, Image.FORMAT_RGB8)
	for x in roundi(float(SIZE.x) / CHECKERBOARD_SIZE.x):
		for y in roundi(float(SIZE.y) / CHECKERBOARD_SIZE.y):
			image.fill_rect(Rect2i(
					Vector2i(x, y) * CHECKERBOARD_SIZE,
					CHECKERBOARD_SIZE
				),
				Color.GRAY if (x % 2 == y % 2) else Color.DIM_GRAY
			)

	for idx: int in gradient.points.size():
		var start_offset: float = gradient.points.get(idx).get(&"offset", 0.0)
		var end_offset: float
		if idx + 1 >= gradient.points.size():
			end_offset = 1.0
		else:
			end_offset = gradient.points.get(idx + 1).get(&"offset", 0.0)
		var gaea_material: GaeaMaterial = gradient.points.get(idx).get(&"material", null)
		if not is_instance_valid(gaea_material):
			continue
		var color: Color = Color.TRANSPARENT if not is_instance_valid(gaea_material) else gaea_material.preview_color

		image.fill_rect(Rect2(
				Vector2(start_offset * SIZE.x, 0.0).round(),
				Vector2(((end_offset + 0.005) - start_offset) * SIZE.x, SIZE.y).round()
			),
			color)

	texture = ImageTexture.create_from_image(image)
