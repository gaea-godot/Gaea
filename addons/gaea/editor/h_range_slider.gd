@tool
extends "res://addons/gaea/editor/range_slider.gd"

## A horizontal [RangeSlider] that goes from left ([member min_value]) to right ([member max_value]),
## used to adjust a range by moving grabbers along a horizontal axis.


func _init() -> void:
	_orientation = Orientation.HORIZONTAL
	super()
