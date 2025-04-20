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
	GRADIENT = 102, ## A [GaeaMaterialGradient].
	# Dictionary types from 200 to 299
	DATA = 200, ## A dictionary of the form [code]{Vector3i: float}[/code].
	MAP = 201, ## A dictionary of the form [code]{Vector3i: GaeaMaterial}[/code].
	# Inner types (can't be on wire) from 300 to 399
	BITMASK = 300, ## Int representing a bitmask.
	BITMASK_EXCLUSIVE = 301, ## Same as bitmask but only one bit can be active at once.
	FLAGS = 302, ## Same interface as bitmask, but returns an Array of flags.
	NEIGHBORS = 303, ## An array of offset neighbors from a center tile.
	RULES = 304, ## Rules for each cell in an area, whether it should be activate, inactive or there's no rule.
	VARIABLE_NAME = 305, ## Name for [GaeaNodeVariable]s.
}


## Returns whether [param type] accepts inputs.
static func is_wireable(type: Type) -> bool:
	return type > 0 and type < 300


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
		Type.VECTOR3:
			return Vector3.ZERO
		# Simple types
		Type.RANGE:
			return {"min": 0.0, "max": 1.0}
		Type.DATA:
			return {} as Dictionary[Vector3i, float]
		Type.MAP:
			return {} as Dictionary[Vector3i, Variant]
		# Inner types
		Type.NEIGHBORS:
			return [] as Array[Vector2i]
		Type.FLAGS:
			return [] as Array[int]
	return null


## Returns the associated [enum Type] to [param type] of [enum Variant.Type].
@warning_ignore("unused_parameter")
static func from_variant_type(type: Variant.Type, hint: PropertyHint = PROPERTY_HINT_NONE, hint_string: String = "") -> Type:
	match type:
		TYPE_INT:
			return Type.INT
		TYPE_FLOAT:
			return Type.FLOAT
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return Type.VECTOR2
		TYPE_BOOL:
			return Type.BOOLEAN
		TYPE_OBJECT:
			if hint_string == "GaeaMaterial":
				return Type.MATERIAL
			elif hint_string == "GaeaMaterialGradient":
				return Type.GRADIENT
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return Type.VECTOR3
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
		8: return GaeaValue.Type.GRADIENT
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
		Type.VECTOR2:
			return Color("00bfff") # LIGHT BLUE
		Type.VECTOR3:
			return Color("8e44ad") # MAGENTA
		# Simple types
		Type.RANGE:
			return Color("f04c7f") # PINK
		Type.MATERIAL:
			return Color("eb2f06") # RED
		Type.GRADIENT:
			return Color("4834d4") # BLURPLE
		# Dictionary types
		Type.DATA:
			return Color("f0f8ff") # WHITE
		Type.MAP:
			return Color("27ae60") # GREEN
		# Reserved for later use
		#SlotType.TEXTURE: # ORANGE
		#	return Color("e67e22")
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
		Type.VECTOR2:
			return load("uid://c8uvy6c2syjk5")
		Type.VECTOR3:
			return load("uid://bkknri7u8ghs4")
		# Simple types
		Type.RANGE:
			return load("uid://wx4ccwofr8yy")
		Type.MATERIAL:
			return load("uid://b0vqox8bodse")
		Type.GRADIENT:
			return load("uid://lx5rvgl4j7wl")
		# Dictionary types
		Type.DATA:
			return load("uid://dkccxw7yq1mth")
		Type.MAP:
			return load("uid://c2i5wqidu1r1o")
	return load("uid://by6s78k1thpy2")


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
		Type.VECTOR2:
			return load("uid://bidpo1iw1t0vt")
		Type.VECTOR3:
			return load("uid://dbvw3j8fnmhpu")
		# Simple types
		Type.RANGE:
			return load("uid://dfsmxavxasx7x")
		Type.MATERIAL:
			return load("uid://daasmk1v2rpcm")
		Type.GRADIENT:
			return load("uid://ccqq5l0ruur37")
		# Dictionary types
		Type.DATA:
			return load("uid://yo87adchyr3w")
		Type.MAP:
			return load("uid://d2rmsal7c6sdi")
	return load("uid://dqob6v3dudlri")


## Get property type hint, this is mostly used with [method Object._validate_property].
## This will modify the input property object.
static func apply_property_type_hint(property: Dictionary, type: Type) -> void:
	match type:
		GaeaValue.Type.FLOAT:
			property.type = TYPE_FLOAT
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.INT:
			property.type = TYPE_INT
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.VECTOR2:
			property.type = TYPE_VECTOR2
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.RANGE:
			property.type = TYPE_DICTIONARY
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.BITMASK, GaeaValue.Type.BITMASK_EXCLUSIVE:
			property.type = TYPE_INT
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			property.hint = PROPERTY_HINT_LAYERS_2D_PHYSICS
		GaeaValue.Type.BOOLEAN:
			property.type = TYPE_BOOL
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.FLAGS:
			property.type = TYPE_ARRAY
			property.hint = PROPERTY_HINT_TYPE_STRING
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			property.hint_string = "%d:" % [TYPE_INT]
		GaeaValue.Type.VECTOR3:
			property.type = TYPE_VECTOR3
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.NEIGHBORS:
			property.type = TYPE_ARRAY
			property.hint = PROPERTY_HINT_TYPE_STRING
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			property.hint_string = "%d:" % [TYPE_VECTOR2I]
		GaeaValue.Type.DATA:
			property.type = TYPE_DICTIONARY
			property.hint = PROPERTY_HINT_DICTIONARY_TYPE
			property.hint_string = "%d:;%d:" % [TYPE_VECTOR3I, TYPE_FLOAT]
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.MAP:
			property.type = TYPE_DICTIONARY
			property.hint = PROPERTY_HINT_DICTIONARY_TYPE
			property.hint_string = "%d:" % [TYPE_VECTOR3I]
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		GaeaValue.Type.CATEGORY:
			property.usage = PROPERTY_USAGE_NONE


#region Data casting methods
## Return the castable types, the inner array is a tuple with [code][from, to][/code]. Both of [enum Type].
static func get_cast_list() -> Array[Array]:
	var casts: Array[Array] = []

	casts.append([GaeaValue.Type.RANGE, GaeaValue.Type.VECTOR2])

	casts.append([GaeaValue.Type.FLOAT, GaeaValue.Type.VECTOR2])
	casts.append([GaeaValue.Type.FLOAT, GaeaValue.Type.VECTOR3])
	casts.append([GaeaValue.Type.FLOAT, GaeaValue.Type.BOOLEAN])
	casts.append([GaeaValue.Type.FLOAT, GaeaValue.Type.INT])

	casts.append([GaeaValue.Type.INT, GaeaValue.Type.VECTOR2])
	casts.append([GaeaValue.Type.INT, GaeaValue.Type.VECTOR3])
	casts.append([GaeaValue.Type.INT, GaeaValue.Type.BOOLEAN])
	casts.append([GaeaValue.Type.INT, GaeaValue.Type.FLOAT])

	casts.append([GaeaValue.Type.VECTOR2, GaeaValue.Type.RANGE])
	casts.append([GaeaValue.Type.VECTOR2, GaeaValue.Type.VECTOR3])
	casts.append([GaeaValue.Type.VECTOR2, GaeaValue.Type.FLOAT])
	casts.append([GaeaValue.Type.VECTOR2, GaeaValue.Type.INT])
	casts.append([GaeaValue.Type.VECTOR3, GaeaValue.Type.VECTOR2])
	casts.append([GaeaValue.Type.VECTOR3, GaeaValue.Type.FLOAT])
	casts.append([GaeaValue.Type.VECTOR3, GaeaValue.Type.INT])

	casts.append([GaeaValue.Type.BOOLEAN, GaeaValue.Type.FLOAT])
	casts.append([GaeaValue.Type.BOOLEAN, GaeaValue.Type.INT])
	casts.append([GaeaValue.Type.BOOLEAN, GaeaValue.Type.VECTOR2])
	casts.append([GaeaValue.Type.BOOLEAN, GaeaValue.Type.VECTOR3])

	return casts

## Transforms [param value] from [param from_type] to [param to_type]. If there's no way to do so,
## produces an error.
static func cast_value(from_type: GaeaValue.Type, to_type: GaeaValue.Type, value: Variant) -> Variant:
	match [from_type, to_type]:
		#region Range -> Any
		[GaeaValue.Type.RANGE, GaeaValue.Type.VECTOR2]:
			return Vector2(
				value.get("min"), value.get("max")
			)
		#endregion

		#region Number -> Any
		[GaeaValue.Type.FLOAT, GaeaValue.Type.VECTOR2]:
			return Vector2(
				value, value
			)
		[GaeaValue.Type.FLOAT, GaeaValue.Type.VECTOR3]:
			return Vector3(
				value, value, value
			)
		[GaeaValue.Type.FLOAT, GaeaValue.Type.BOOLEAN]:
			return bool(value)
		#endregion

		#region Vector -> Any
		[GaeaValue.Type.VECTOR2, GaeaValue.Type.RANGE]:
			return {
				"min": value.x, "max": value.y
			}
		[GaeaValue.Type.VECTOR2, GaeaValue.Type.VECTOR3]:
			return Vector3(
				value.x, value.y, 0.0
			)
		[GaeaValue.Type.VECTOR3, GaeaValue.Type.VECTOR2]:
			return Vector2(
				value.x, value.y
			)
		[GaeaValue.Type.VECTOR2, GaeaValue.Type.FLOAT],\
		[GaeaValue.Type.VECTOR3, GaeaValue.Type.FLOAT]:
			return value.x
		#endregion

		#region Boolean -> Any
		[GaeaValue.Type.BOOLEAN, GaeaValue.Type.FLOAT]:
			return float(value)
		[GaeaValue.Type.BOOLEAN, GaeaValue.Type.VECTOR2]:
			return Vector2(float(value), float(value))
		[GaeaValue.Type.BOOLEAN, GaeaValue.Type.VECTOR3]:
			return Vector3(float(value), float(value), float(value))
		#endregion

	printerr("Could not get data from previous node, missing cast method from %s to %s" % [
		GaeaValue.Type.find_key(from_type),
		GaeaValue.Type.find_key(to_type),
	])
	return {}
#endregion
