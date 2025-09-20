@tool
class_name GridMapGaeaMaterial
extends GaeaMaterial
## Resource used to tell the [GridMapGaeaRenderer] which item from a [GridMap] to place.


## The index of the item in the [MeshLibrary].
@export var item_idx: int = 0
## The orientation of the item. For valid orientation values, see [method GridMap.get_orthogonal_index_from_basis].
@export var orientation: int = 0


func _is_sampled() -> bool:
	return false


func _is_data() -> bool:
	return true
