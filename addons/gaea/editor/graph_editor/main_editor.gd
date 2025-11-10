@tool
class_name GaeaMainEditor
extends Control

## Emitted when the about popup is requested.
@warning_ignore("unused_signal")
signal about_popup_request()
signal popup_create_node_request()
signal popup_create_node_and_connect_node_request(node: GaeaGraphNode, type: GaeaValue.Type)

signal popup_node_context_menu_at_mouse_request(selected_nodes: Array)
signal popup_link_context_menu_at_mouse_request(connection: Dictionary)

signal node_selected_for_creation(resource: GaeaNodeResource)
signal special_node_selected_for_creation(id: StringName)
signal new_reroute_requested(connection: Dictionary)


@export var gaea_panel: GaeaPanel
@export var graph_edit: GaeaGraphEdit
@export var about_window: AcceptDialog
@export var no_data: CenterContainer
@export var create_node_popup: GaeaPopupCreateNode
@export var node_context_menu: GaeaPopupNodeContextMenu
@export var link_context_menu: GaeaPopupLinkContextMenu



## Local position on [GraphEdit] for a node that may be created in the future.
var node_creation_target: Vector2 = Vector2.ZERO
var created_node_connect_to: GaeaGraphNode = null
var created_node_connect_to_port: int = -1
var dragged_from_left: bool = false



func _ready() -> void:
	node_selected_for_creation.connect(graph_edit._on_node_selected_for_creation)
	new_reroute_requested.connect(graph_edit._on_new_reroute_requested)
	special_node_selected_for_creation.connect(graph_edit._on_special_node_selected_for_creation)

	popup_create_node_request.connect(create_node_popup._on_popup_create_node_request)
	popup_create_node_and_connect_node_request.connect(create_node_popup._on_popup_create_node_and_connect_node_request)
	special_node_selected_for_creation.connect(create_node_popup._on_special_node_selected_for_creation)

	popup_node_context_menu_at_mouse_request.connect(node_context_menu._on_popup_node_context_menu_at_mouse_request)

	popup_link_context_menu_at_mouse_request.connect(link_context_menu._on_popup_link_context_menu_at_mouse_request)

#region TODO

	#_about_button.icon = EditorInterface.get_base_control().get_theme_icon(
	#	&"NodeInfo", &"EditorIcons"
	#)

#endregion



static func clamp_popup_in_window(popup: Window, main_window: Window) -> void:
	var window_rect = Rect2i(main_window.position, main_window.size)
	var inner_rect = Rect2i(popup.position, popup.size)
	if inner_rect.position.x < window_rect.position.x:
		popup.position.x = window_rect.position.x
	elif inner_rect.position.x + inner_rect.size.x > window_rect.position.x + window_rect.size.x:
		popup.position.x = window_rect.position.x + window_rect.size.x - inner_rect.size.x

	if inner_rect.position.y < window_rect.position.y:
		popup.position.y = window_rect.position.y
	elif inner_rect.position.y + inner_rect.size.y > window_rect.position.y + window_rect.size.y:
		popup.position.y = window_rect.position.y + window_rect.size.y - inner_rect.size.y




func _on_new_data_button_pressed() -> void:
	pass
	#graph = GaeaGraph.new()


func _on_test_button_pressed() -> void:
	#var graph = load("uid://dowa1yikrbcdj").duplicate(true)
	var graph = load("uid://3ogbw502hfvu")

	if graph.resource_local_to_scene:
		graph._setup_local_to_scene()
	graph_edit.unpopulate()
	graph_edit.populate(graph)
