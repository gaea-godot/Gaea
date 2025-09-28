@tool
class_name GaeaGraphMigration


static func migrate(data: GaeaGraph):
	if data.save_version == -1:
		_migration_step_from_beta(data)
	if data.save_version == 2:
		_migration_step_material_merge(data)
	if data.save_version <= 3:
		_migration_step_node_ids(data)
	push_warning("Gaea graph (%s) migrated from previous save file format. Please save your project and reload." % data.resource_path)


## [param node_map] Contains all migration data.
## Each key is the previous UID.
## The value can either be:
## - A String: for a simple direct mapping to a new UID.
## - An Array:
##     - First element: the new UID.
##     - Second element: the values to assign in the data array.
##     - Third element: the keys to rename in the arguments Dictionary.
static func _process_migration(data: GaeaGraph, node_map: Dictionary[String, Variant], new_save_version: int):
	for idx in data.resource_uids.size():
		var base_uid = data.resource_uids[idx].replace("uid://", "")

		if data.node_data[idx].has("data"):
			data.node_data[idx].set(&"arguments", data.node_data[idx].get("data"))
			data.node_data[idx].erase("data")

		if node_map.has(base_uid):
			var target_data = node_map.get(base_uid)
			if typeof(target_data) == TYPE_STRING:
				data.resource_uids[idx] = "uid://%s" % target_data
			else:
				# Resource UID
				data.resource_uids[idx] = "uid://%s" % target_data[0]
				# Static data to set
				if target_data.size() > 1:
					for data_key in target_data[1]:
						data.node_data[idx].set(data_key, target_data[1].get(data_key))
				# Argument keys to rename
				if target_data.size() > 2:
					for old_key in target_data[2].keys():
						var arguments: Dictionary = data.node_data[idx].get(&"arguments")
						arguments.set(target_data[2].get(old_key), arguments.get(old_key))
						arguments.erase(old_key)
	data.save_version = new_save_version


## Migrate data from rework [url=https://github.com/gaea-godot/gaea/pull/344]#344[/url].
static func _migration_step_from_beta(data: GaeaGraph):
	var node_map: Dictionary[String, Variant] = {
		"bbkdvyxkj2slo": "dol7xviglksx4", #output_node_resource.tres
		"kdn03ei2yp6e": "bgqqucap4kua4", #reroute_node_resource.tres

		"b2bpg5nt6l31": "bq3vxxpkxn5ds", #root/conditional/constants/bool_constant.tres
		"c1k7e0whh2ewx": "cq66v7je7qj85", #root/scalar/constants/float_constant.tres
		"cql58fvdlebeu": "c2336gqnb6ym3", #root/scalar/constants/int_constant.tres
		"cs1wgu81ww5lr": "qmbp427uv8sx", #root/vector/constants/vector2_constant.tres
		"n2su2s1w248e": "bqn35k1o7lpso", #root/vector/constants/vector3_constant.tres

		"cta2ipm8oe120": "coltk43t8om1t", #root/conditional/variables/bool_variable.tres
		"ce7tbrfosey37": "ry32fdv76f2o", #root/scalar/variables/float_variable.tres
		"37ihrctuxf3": "buonx1umcjin8", #root/scalar/variables/int_variable.tres
		"dwpdb8ltkg43a": "b3up843psvqnl", #root/vector/variables/vector2i_variable.tres
		"bf3aefanhvr6l": "p8ajvshxenm3", #root/vector/variables/vector2_variable.tres
		"btf8xr1jdb3xf": "dcdrs7xlfy83j", #root/vector/variables/vector3i_variable.tres
		"dskijywvj2y8d": "dul1tbuy0b13a", #root/vector/variables/vector3_variable.tres
		"r4woxxrppbhr": "cumythno5ccu3", #root/resources/variables/material_gradient_variable.tres
		"byrhtfsduac1x": "cqs1w714pbfql", #root/resources/variables/material_variable.tres

		"ch7u7802bkv3v": "b7naniphpp341", #root/data/basic/fill.tres
		"pisw6udylbhn": "741f2tjbjf7c", #root/data/border/border.tres
		"bjgl7hlbbjuws": "dnj3grm2qv20y", #root/data/filters/distance_filter.tres
		"dvk2wlxbo4wyv": "craai02gndxaq", #root/data/filters/flags_filter.tres
		"cu6746ccrvp44": "b38syakgm25ya", #root/data/filters/random_filter.tres
		"cunarm8apr55l": "d3ahx5mfke6wg", #root/data/filters/threshold_filter.tres

		"b1vj6la3lmq5f": ["0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.COMPLEMENT]}], #root/data/functions/data_complement.tres
		"c4ks3ukknfqkm": ["0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.DIFFERENCE]}], #root/data/functions/data_difference.tres
		"bekpvvtetmvgm": ["0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.INTERSECTION]}], #root/data/functions/data_intersection.tres
		"4ybwu0m8kw1a": ["0vv1gfyt6147", {&"enums": [GaeaNodeSetOp.Operation.UNION]}], #root/data/functions/data_union.tres

		"blm6fqdfqa5bh": "cgnbu4kly4sls", #root/data/generation/falloff.tres
		"b7ad0bauchvyu": ["blx812352t3jj", {&"enums": [GaeaNodeFloorWalker.AxisType.XY]}], #root/data/generation/floor_walker_xy.tres
		"nh1dr3qjpivi": ["blx812352t3jj", {&"enums": [GaeaNodeFloorWalker.AxisType.XZ]}], #root/data/generation/floor_walker_xz.tres
		"bh1u4kqfvh0fy": "d0bgv7yf1t1m6", #root/data/generation/snake_path_2d.tres

		"dhey5y1gvfgxg": "cgjyi804j05dy", #root/data/noise/simplex_smooth_2D.tres
		"bumgueaiw5d1f": "c3xxswfpt3mny", #root/data/noise/simplex_smooth_3D.tres

		"b5x1wxss4spod": ["c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.ADD]}, {&"value": &"b"}], #root/data/operations/add.tres
		"b3q8md2biskfq": ["c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.SUBTRACT]}, {&"value": &"b"}], #root/data/operations/substract.tres
		"coi1put8oap60": ["c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.MULTIPLY]}, {&"value": &"b"}], #root/data/operations/multiply.tres
		"d4f3kftfw2inw": ["c441lj0bi6eyn", {&"enums": [GaeaNodeNumOp.Operation.DIVIDE]}, {&"value": &"b"}], #root/data/operations/divide.tres

		"drhtdob82hwua": ["dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.ADD]}], #root/data/operations/add_datas.tres
		"bb81ds61i41r1": ["dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.SUBTRACT]}], #root/data/operations/substract_datas.tres
		"dv5677k1v6n": ["dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.MULTIPLY]}], #root/data/operations/multiply_datas.tres
		"f6ycpjqowl41": ["dxsow1o2b4tm3", {&"enums": [GaeaNodeDatasOp.Operation.DIVIDE]}], #root/data/operations/divide_datas.tres

		"dyk8vkdntdudc": ["fc8vogh4mvhw", {&"enums": [GaeaNodeInput.InputVar.WORLD_SIZE]}], #root/input/world_size.tres

		"40kjl8ojif34": "coh5skum82ue3", #root/map/filters/random_filter.tres

		"dp08ix2q7gxas": ["d2f6bjkxcn7jl", {&"enums": [GaeaNodeSetOp.Operation.DIFFERENCE]}], #root/map/functions/map_difference.tres
		"c3kfx8jda3ghq": ["d2f6bjkxcn7jl", {&"enums": [GaeaNodeSetOp.Operation.INTERSECTION]}], #root/map/functions/map_intersection.tres
		"dtgm8q3pqox6c": ["d2f6bjkxcn7jl", {&"enums": [GaeaNodeSetOp.Operation.UNION]}], #root/map/functions/map_union.tres

		"dnr2f2kgvmyjd": "dux0bq53p61ls", #root/map/mappers/basic_mapper.tres
		"dpienqmp335jg": "bdwxrdlr0267t", #root/map/mappers/flags_mapper.tres
		"dvedjf7t120jr": "c4yhilhmhasb2", #root/map/mappers/gradient_mapper.tres
		"conft7neua4ww": "djjvx650evm0n", #root/map/mappers/threshold_mapper.tres
		"6tctdjrjbard": "cd25npsj1ey2n", #root/map/mappers/value_mapper.tres
		"c2u75oyoi2lne": "br8gcsyc04ksj", #root/map/placing/rules_placer.tres
		"buu32u5bluejt": "bjmyuomcmtwq6", #root/map/random/random_scatter.tres

		"dtc6nrgjvi8pw": ["yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.ADD]}], #root/scalar/operations/add.tres
		"167vhd3o81mk": ["yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.SUBTRACT]}], #root/scalar/operations/substract.tres
		"rcvehn8ulhem": ["yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.MULTIPLY]}], #root/scalar/operations/multiply.tres
		"cs35p7d6oiu4w": ["yu78bj4he27g", {&"enums": [GaeaNodeNumOp.Operation.DIVIDE]}], #root/scalar/operations/divide.tres

		"bmjbf86en6cas": "m0m4x6trd11h", #root/other/composition/compose_range.tres
		"dv28660onn7fl": ["c1koyt7wh4c4v", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2]}], #root/vector/composition/compose_vector2.tres
		"dfjr83x416ec4": ["c1koyt7wh4c4v", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3]}], #root/vector/composition/compose_vector3.tres
		"o054c8xv8xb": ["b1vu2sfwynxql", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2]}], #root/vector/decomposition/decompose_vector2.tres
		"evg3g607sf40": ["b1vu2sfwynxql", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3]}], #root/vector/decomposition/decompose_vector3.tres

		"cm0wp1if8nc6k": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2, GaeaNodeVectorOp.Operation.ADD]}], #root/vector/operations/add_vector2.tres
		"bq878twqcc5f": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3, GaeaNodeVectorOp.Operation.ADD]}], #root/vector/operations/add_vector3.tres
		"d20pwbkvqkqnq": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2, GaeaNodeVectorOp.Operation.SUBTRACT]}], #root/vector/operations/substract_vector2.tres
		"boe1a3sogwvyw": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3, GaeaNodeVectorOp.Operation.SUBTRACT]}], #root/vector/operations/substract_vector3.tres
		"cktjgkxfx8pyh": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2, GaeaNodeVectorOp.Operation.MULTIPLY]}], #root/vector/operations/multiply_vector2.tres
		"cq0gpnw7juqpk": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3, GaeaNodeVectorOp.Operation.MULTIPLY]}], #root/vector/operations/multiply_vector3.tres
		"cgd05tlepxucw": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR2, GaeaNodeVectorOp.Operation.DIVIDE]}], #root/vector/operations/divide_vector2.tres
		"hut3x2e74y85": ["bclwjwmoudxkh", {&"enums": [GaeaNodeVectorBase.VectorType.VECTOR3, GaeaNodeVectorOp.Operation.DIVIDE]}], #root/vector/operations/divide_vector3.tres
	}
	_process_migration(data, node_map, 2)


## Migrate data for material merge [url=https://github.com/gaea-godot/gaea/pull/359]#359[/url].
static func _migration_step_material_merge(data: GaeaGraph):
	var node_map: Dictionary[String, Variant] = {
		"cumythno5ccu3": "cqs1w714pbfql", #root/resources/variables/gradient_parameter.gd
		"c4yhilhmhasb2": "dux0bq53p61ls", #root/map/mappers/gradient_mapper.gd
	}
	_process_migration(data, node_map, 3)


## Migrate data for new saving system [url=https://github.com/gaea-godot/gaea/pull/435]#435[/url].
static func _migration_step_node_ids(data: GaeaGraph):
	if not data.node_data.is_empty():
		for idx in data.node_data.size():
			var _node_data = data.node_data[idx]
			var _resource: GaeaNodeResource = load(data.resource_uids[idx]).new()
			var _position: Vector2 = _node_data.get("position", Vector2.ZERO)
			data.add_node(_resource, _position, idx)
			data.set_node_data_value(idx, &"salt", _node_data.get(&"salt", data.get_node_data(idx)[&"salt"]))
			for arg_name: StringName in _node_data.get(&"arguments", {}):
				var _value: Variant = _node_data.get(&"arguments").get(arg_name)
				data.set_node_argument(idx, arg_name, _value)

			for enum_idx: int in _node_data.get(&"enums", []).size():
				data.set_node_enum(idx, enum_idx, _node_data.get(&"enums")[enum_idx])

			if _node_data.has("type"):
				data.set_node_data_value(idx, &"reroute_type", _node_data.get("type"))

	if not data.connections.is_empty():
		for connection in data.connections:
			data.force_connect_nodes(
				connection["from_node"],
				connection["from_port"],
				connection["to_node"],
				connection["to_port"]
			)
	for param in data.parameters.keys():
		data.add_parameter(param, data.paramaters[param])

	data.connections.clear()
	data.parameters.clear()

	var _frames: Dictionary[int, Dictionary]
	for frame_data: Dictionary in data.other.get(&"frames", []):
		var _frame_id: int = data.add_frame(frame_data[&"position"])
		data.set_node_data_value(_frame_id, &"tint_color_enabled", frame_data.get(&"tint_color_enabled", false))
		data.set_node_data_value(_frame_id, &"tint_color", frame_data.get(&"tint_color", Color("4d4d4dbf")))
		data.set_node_data_value(_frame_id, &"autoshrink", frame_data.get(&"autoshrink", true))
		data.set_node_data_value(_frame_id, &"title", frame_data.get(&"title", "Title"))
		_frames[_frame_id] = frame_data


	for frame_id in _frames.keys():
		var _frame_data := _frames[frame_id]
		for attached_name: StringName in _frame_data.get(&"attached"):
			var node_data_idx: int = data.node_data.find_custom(
				func(node_data: Dictionary): return node_data.get(&"name", &"") == attached_name
			)
			if node_data_idx != -1:
				var id: int = data._node_data.find_key(data._node_data.values()[node_data_idx])
				data.attach_node_to_frame(id, frame_id)
			else:
				var _frame_data_idx: int = _frames.values().find_custom(
					func(node_data: Dictionary): return node_data.get(&"name", &"") == attached_name
				)
				var _other_frame_id: int = _frames.keys()[_frame_data_idx]
				if _other_frame_id != -1:
					data.attach_node_to_frame(_other_frame_id, frame_id)

	data.other.clear()
	data.save_version = 4
