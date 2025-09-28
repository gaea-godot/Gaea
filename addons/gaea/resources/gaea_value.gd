@tool
class_name GaeaValue extends RefCounted
## Holds information about value types in Gaea.
##
## @tutorial(Anatomy of a Graph#Slot Types): https://gaea-godot.github.io/gaea-docs/#/2.0/tutorials/anatomy-of-a-graph?id=slot-types

enum Type {
	# Misc types
	CATEGORY = -1, ## For visual separation, doesn't get saved.
	NULL = TYPE_NIL, ## Used for invalid types.
	# Basic types from 1 to TYPE_MAX but reserved to 99
	BOOLEAN = TYPE_BOOL, ## [code]true[/code] or [code]false[/code]
	INT = TYPE_INT, ## An [code]int[/code].
	FLOAT = TYPE_FLOAT, ## A [code]float[/code].
	VECTOR2 = TYPE_VECTOR2, ## ([code]x[/code],[code]y[/code])
	VECTOR2I = TYPE_VECTOR2I, ## Like Vector2, but can only be [code]int[/code]s.
	VECTOR3 = TYPE_VECTOR3, ## ([code]x[/code],[code]y[/code], [code]z[/code])
	VECTOR3I = TYPE_VECTOR3I, ## Like Vector3, but can only be [code]int[/code]s.
	# Simple types from 100 to 199
	## Formatted the following way:
	## [codeblock]
	## {
	##     min: float,
	##     max: float
	## }
	## [/codeblock]
	RANGE = 100,
	MATERIAL = 101, ## A [GaeaMaterial].
	TEXTURE = 102, ## A [Texture].
	# Dictionary types from 200 to 299
	DATA = 200, ## A dictionary of the form [code]{Vector3i: float}[/code].
	MAP = 201, ## A dictionary of the form [code]{Vector3i: GaeaMaterial}[/code].
	# Inner types (can't be on wire) from 300 to 399
	BITMASK = 300, ## Int representing a bitmask.
	BITMASK_EXCLUSIVE = 301, ## Same as bitmask but only one bit can be active at once.
	FLAGS = 302, ## Same interface as bitmask, but returns an Array of flags.
	NEIGHBORS = 303, ## An array of offset neighbors from a center tile.
	RULES = 304, ## Rules for each cell in an area, whether it should be activate, inactive or there's no rule.
	VARIABLE_NAME = 305, ## Name for [GaeaNodeParameter]s.
}


## Returns whether [param type] accepts inputs.
static func is_wireable(type: Type) -> bool:
	return type > 0 and type < 300


## Returns [code]true[/code] if a connection of a [param from] output and a [param to] input is valid.
static func is_valid_connection(from: GaeaValue.Type, to: GaeaValue.Type) -> bool:
	return from == to or (GaeaValueCast.get_cast_methods().has(from) and GaeaValueCast.get_cast_methods().get(from).has(to))


## Returns whether [param type] can be previewed in the editor.
static func has_preview(type: Type) -> bool:
	return type == Type.MAP or type == Type.DATA


## Returns the configured color for slots of [param type].
static func get_color(type: Type) -> Color:
	return GaeaEditorSettings.get_configured_color_for_value_type(type)


## Returns the default value for [param type]. Returns [code]null[/code] if there's none.
static func get_default_value(type: Type) -> Variant:
	match type:
		# Basic types
		Type.BOOLEAN:
			return false
		Type.INT:
			return 0
		Type.FLOAT:
			return 0.0
		Type.VECTOR2:
			return Vector2.ZERO
		Type.VECTOR2I:
			return Vector2i.ZERO
		Type.VECTOR3:
			return Vector3.ZERO
		Type.VECTOR3I:
			return Vector3i.ZERO
		# Simple types
		Type.RANGE:
			return {"min": 0.0, "max": 1.0} as Dictionary[String, float]
		Type.DATA:
			return {} as Dictionary[Vector3i, float]
		Type.MAP:
			return {} as Dictionary[Vector3i, GaeaMaterial]
		# Inner types
		Type.NEIGHBORS:
			return [] as Array[Vector2i]
		Type.FLAGS:
			return [] as Array[int]
		Type.RULES:
			return {}
		# Whether or not it's collapsed.
		Type.CATEGORY:
			return false
	return null


## Returns the associated [enum Type] to [param type] of [enum Variant.Type].
static func from_variant_type(type: Variant.Type, _hint: PropertyHint = PROPERTY_HINT_NONE, hint_string: String = "") -> Type:
	match type:
		TYPE_BOOL:
			return Type.BOOLEAN
		TYPE_INT:
			return Type.INT
		TYPE_FLOAT:
			return Type.FLOAT
		TYPE_VECTOR2I:
			return Type.VECTOR2I
		TYPE_VECTOR2:
			return Type.VECTOR2
		TYPE_VECTOR3I:
			return Type.VECTOR3I
		TYPE_VECTOR3:
			return Type.VECTOR3
		TYPE_OBJECT:
			if hint_string == "GaeaMaterial":
				return Type.MATERIAL
			elif hint_string.begins_with("Texture"):
				return Type.TEXTURE
	return Type.NULL


## Used to convert old GaeaGraphNode.SlotTypes to new [enum Type].
## @deprecated
## Should be removed in the 2.0 release.
static func from_old_slot_type(old_type: int) -> GaeaValue.Type:
	match old_type:
		0: return GaeaValue.Type.DATA
		1: return GaeaValue.Type.MAP
		2: return GaeaValue.Type.MATERIAL
		3: return GaeaValue.Type.VECTOR2
		4: return GaeaValue.Type.FLOAT
		5: return GaeaValue.Type.RANGE
		6: return GaeaValue.Type.BOOLEAN
		7: return GaeaValue.Type.VECTOR3
		-1: return GaeaValue.Type.NULL
	return GaeaValue.Type.NULL


## Returns the default color for slots of [param type].
static func get_default_color(type: Type) -> Color:
	match type:
		# Basic types
		Type.BOOLEAN:
			return Color("ffdd59") # YELLOW
		Type.INT, Type.FLOAT:
			return Color("a0a0a0") # GRAY
		Type.VECTOR2I, Type.VECTOR2:
			return Color("00bfff") # LIGHT BLUE
		Type.VECTOR3I, Type.VECTOR3:
			return Color("8e44ad") # MAGENTA
		# Simple types
		Type.RANGE:
			return Color("f04c7f") # PINK
		Type.MATERIAL:
			return Color("eb2f06") # RED
		# Dictionary types
		Type.DATA:
			return Color("f0f8ff") # WHITE
		Type.MAP:
			return Color("27ae60") # GREEN
		Type.TEXTURE:
			return Color("e67e22") # ORANGE
	return Color.WHITE


## Returns the icon associated [param type] to be used in the 'Create Node' pop-up.
static func get_display_icon(type: Type) -> Texture2D:
	match type:
		# Basic types
		Type.BOOLEAN:
			return load("uid://0l53mu4blspj")
		Type.INT:
			return load("uid://bilsfh3nrbhkl")
		Type.FLOAT:
			return load("uid://baw7ye0h4xdcx")
		Type.VECTOR2I:
			return load("uid://bpel4ys42dkjc")
		Type.VECTOR2:
			return load("uid://c8uvy6c2syjk5")
		Type.VECTOR3I:
			return load("uid://cd0polwxfqhyi")
		Type.VECTOR3:
			return load("uid://bkknri7u8ghs4")
		# Simple types
		Type.RANGE:
			return load("uid://wx4ccwofr8yy")
		Type.MATERIAL:
			return load("uid://b0vqox8bodse")
		Type.TEXTURE:
			var editor_interface = Engine.get_singleton("EditorInterface")
			return editor_interface.get_base_control().get_theme_icon(&"Image", &"EditorIcons")
		# Dictionary types
		Type.DATA:
			return load("uid://dkccxw7yq1mth")
		Type.MAP:
			return load("uid://c2i5wqidu1r1o")
	return null


## Returns the configured icon for slots of [param type].
static func get_slot_icon(type: Type) -> Texture2D:
	return GaeaEditorSettings.get_configured_icon_for_value_type(type)


## Returns the default icon for slots of [param type].
static func get_default_slot_icon(type: Type) -> Texture2D:
	match type:
		# Basic types
		Type.BOOLEAN:
			return load("uid://4b3i1xqd4052")
		Type.INT, Type.FLOAT:
			return load("uid://dqob6v3dudlri")
		Type.VECTOR2I, Type.VECTOR2:
			return load("uid://bidpo1iw1t0vt")
		Type.VECTOR3I, Type.VECTOR3:
			return load("uid://dbvw3j8fnmhpu")
		# Simple types
		Type.RANGE:
			return load("uid://dfsmxavxasx7x")
		Type.MATERIAL:
			return load("uid://daasmk1v2rpcm")
		Type.TEXTURE:
			return load("uid://ccqq5l0ruur37")
		# Dictionary types
		Type.DATA:
			return load("uid://yo87adchyr3w")
		Type.MAP:
			return load("uid://d2rmsal7c6sdi")
	return load("uid://dqob6v3dudlri")


static func get_editor_for_type(for_type: GaeaValue.Type) -> PackedScene:
	match for_type:
		GaeaValue.Type.FLOAT, GaeaValue.Type.INT:
			return preload("uid://dp7blnx7abb5e")
		GaeaValue.Type.VECTOR2, GaeaValue.Type.VECTOR2I, GaeaValue.Type.VECTOR3, GaeaValue.Type.VECTOR3I:
			return preload("uid://mlwupvg8a886")
		GaeaValue.Type.VARIABLE_NAME:
			return preload("uid://bn8i1l4q13pdw")
		GaeaValue.Type.RANGE:
			return preload("uid://t4osuglcgg6l")
		GaeaValue.Type.BITMASK, GaeaValue.Type.BITMASK_EXCLUSIVE, GaeaValue.Type.FLAGS:
			return preload("uid://chdg8ey4ln8d1")
		GaeaValue.Type.CATEGORY:
			return preload("uid://x6n8ylnxoyno")
		GaeaValue.Type.BOOLEAN:
			return preload("uid://byaonbbfa2bx8")
		GaeaValue.Type.NEIGHBORS:
			return preload("uid://d11yc7l6sneof")
		GaeaValue.Type.RULES:
			return preload("uid://dy4n2a5hkaxsb")
	return preload("uid://i2nwlab8rau")
