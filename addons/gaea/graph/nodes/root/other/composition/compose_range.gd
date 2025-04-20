@tool
extends GaeaNodeResource
class_name GaeaNodeComposeRange
## Composes a range parameter from 2 numbers, [param min] and [param max].
##
## Range parameters internally have the following format:
## [codeblock]
## {
##     min: float,
##     max: float
## }
## [/codeblock]
## See [enum GaeaValue.Type].


func _get_data(output_port: GaeaNodeSlotOutput, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)
	return output_port.return_value({
		"min": _get_arg(&"min", area, generator_data),
		"max": _get_arg(&"max", area, generator_data),
	})
