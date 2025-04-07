@tool
extends GaeaGraphNode

const _RerouteResource = preload("uid://bgqqucap4kua4")
const _Slot = preload("uid://dgb4blornaq38")
var slot: _Slot

func initialize() -> void:
	if not is_instance_valid(resource):
		return
	title = resource.title
	resource.node = self


	var slot_resource = GaeaNodeSlot.new()
	slot_resource.left_enabled = true
	slot_resource.left_type = resource.type
	slot_resource.right_enabled = true
	slot_resource.right_type = resource.type
	slot = slot_resource.get_node(self, 0)
	add_child(slot)
	
	set_slot(0,
		true, resource.type, GaeaGraphNode.get_color_from_type(resource.type),
		true, resource.type, GaeaGraphNode.get_color_from_type(resource.type),
		GaeaGraphNode.get_icon_from_type(resource.type),
		GaeaGraphNode.get_icon_from_type(resource.type),
	)



func update_slot() -> void:
	slot.left_type = resource.type
	slot.right_type = resource.type
	set_slot_type_left(0, resource.type)
	set_slot_type_right(0, resource.type)
