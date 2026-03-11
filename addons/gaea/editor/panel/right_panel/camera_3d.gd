@tool
class_name GaeaEditorPreviewCamera
extends Camera3D

const SCROLL_SPEED: float = 5.0 # Speed when use scroll mouse
const ZOOM_SPEED: float = 50.0 # Speed use when is_zoom_in or is_zoom_out is true
const DEFAULT_DISTANCE: float = 5.0 # Default distance of the Node
const ROTATE_SPEED: float = 2.0
const PAN_SPEED: float = 0.25

@export var _anchor_node: Node3D

# Use to add posibility to updated zoom with external script
var is_zoom_in: bool
var is_zoom_out: bool

# Event var
var _current_rotate_input: Vector2
var _current_pan_input: Vector2
var _current_scroll_speed: float

# Transform var
var _rotation: Vector3
var _distance: float

func _ready():
	_distance = DEFAULT_DISTANCE
	_rotation = _anchor_node.transform.basis.get_rotation_quaternion().get_euler()


func _process(delta: float):
	if is_zoom_in:
		_current_scroll_speed = -1 * ZOOM_SPEED
	if is_zoom_out:
		_current_scroll_speed = 1 * ZOOM_SPEED
	_process_transformation(delta)


func _process_transformation(delta: float):
	# Update rotation
	_rotation.x += -_current_rotate_input.y * delta * ROTATE_SPEED
	_rotation.y += -_current_rotate_input.x * delta * ROTATE_SPEED
	if _rotation.x < -PI/2:
		_rotation.x = -PI/2
	if _rotation.x > PI/2:
		_rotation.x = PI/2
	_current_rotate_input = Vector2.ZERO

	# Update distance
	_distance += _current_scroll_speed * delta
	if _distance < 1:
		_distance = 1
	_current_scroll_speed = 0

	self.set_identity()
	self.translate_object_local(Vector3(0,0,_distance))

	_anchor_node.transform.basis = Basis(Quaternion.from_euler(_rotation))

	var pan_factor = delta * maxf(_distance, 1) * PAN_SPEED
	_anchor_node.position -= _anchor_node.transform.basis.x * _current_pan_input.x * pan_factor
	_anchor_node.position -= _anchor_node.transform.basis.y * -_current_pan_input.y * pan_factor
	_current_pan_input = Vector2.ZERO


func input(event: InputEvent):
	if event is InputEventMouseMotion:
		_process_mouse_rotation_event(event)
	elif event is InputEventMouseButton:
		_process_mouse_scroll_event(event)


func _process_mouse_rotation_event(e: InputEventMouseMotion):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_current_rotate_input = e.relative
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_current_pan_input = e.relative


func _process_mouse_scroll_event(e: InputEventMouseButton):
	if e.button_index == MOUSE_BUTTON_WHEEL_UP:
		_current_scroll_speed = -maxf(_distance, 1) * SCROLL_SPEED
	elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_current_scroll_speed = maxf(_distance, 1) * SCROLL_SPEED


@warning_ignore("shadowed_variable_base_class")
func set_camera_view(anchor_position: Vector3, rotation: Vector3, distance: float):
	_anchor_node.position = anchor_position
	_rotation = rotation
	_distance = distance
