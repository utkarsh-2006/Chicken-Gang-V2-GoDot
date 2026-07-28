@tool
extends EditorScript

const MAP_PATH = "res://assets/maps/ChickenGangMap.tmx"
const SAVE_PATH = "res://scenes/environment/ChickenGangMap.tscn"

func _run() -> void:
	print("Starting TMX Compilation for Milestone 1...")
	
	var parser = XMLParser.new()
	if parser.open(MAP_PATH) != OK:
		print("Failed to open TMX")
		return
		
	var map_node = Node2D.new()
	map_node.name = "ChickenGangMap"
	
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	
	var gids = [] # Array of dicts: {firstgid, source_id, columns, image_path, tilecount}
	
	var layers = [] # Array of dicts: {name, data}
	var current_layer = null
	
	var in_data = false
	var data_content = ""
	
	var source_index = 0
	
	while parser.read() == OK:
		var type = parser.get_node_type()
		var node_name = ""
		if type == XMLParser.NODE_ELEMENT or type == XMLParser.NODE_ELEMENT_END:
			node_name = parser.get_node_name()
		
		if type == XMLParser.NODE_ELEMENT:
			if node_name == "tileset":
				var firstgid = int(parser.get_named_attribute_value("firstgid"))
				var source_tsx = parser.get_named_attribute_value("source")
				_parse_tsx(source_tsx, firstgid, source_index, tileset, gids)
				source_index += 1
				
			elif node_name == "layer":
				current_layer = {
					"name": parser.get_named_attribute_value("name"),
					"width": int(parser.get_named_attribute_value("width")),
					"height": int(parser.get_named_attribute_value("height")),
					"data": ""
				}
			elif node_name == "data":
				if parser.has_attribute("encoding") and parser.get_named_attribute_value("encoding") == "csv":
					in_data = true
					data_content = ""
		elif type == XMLParser.NODE_TEXT and in_data:
			data_content += parser.get_node_data()
		elif type == XMLParser.NODE_ELEMENT_END:
			if node_name == "data":
				in_data = false
				if current_layer != null:
					current_layer["data"] = data_content.strip_edges()
					layers.append(current_layer)
					current_layer = null
					
	# Sort gids descending so we can easily find the source
	gids.sort_custom(func(a, b): return a["firstgid"] > b["firstgid"])
	
	for layer_info in layers:
		var layer_node = TileMapLayer.new()
		# Clean name: remove spaces, capitalize words
		var c_name = layer_info["name"].capitalize().replace(" ", "")
		layer_node.name = c_name
		layer_node.tile_set = tileset
		map_node.add_child(layer_node)
		layer_node.owner = map_node
		
		var csv = layer_info["data"].replace("\n", "").replace("\r", "").split(",")
		var width = layer_info["width"]
		var height = layer_info["height"]
		
		for y in range(height):
			for x in range(width):
				var idx = y * width + x
				if idx >= csv.size():
					continue
				var csv_val = csv[idx].strip_edges()
				if csv_val == "":
					continue
				var gid = int(csv_val)
				if gid == 0:
					continue
					
				# Clear flip flags (Tiled uses top 3 bits for flips)
				var clean_gid = gid & 0x1FFFFFFF 
				
				# Find correct source
				for source_info in gids:
					if clean_gid >= source_info["firstgid"]:
						var local_id = clean_gid - source_info["firstgid"]
						var columns = source_info["columns"]
						var atlas_x = local_id % columns
						var atlas_y = local_id / columns
						layer_node.set_cell(Vector2i(x, y), source_info["source_id"], Vector2i(atlas_x, atlas_y))
						break

	var packed = PackedScene.new()
	packed.pack(map_node)
	DirAccess.make_dir_recursive_absolute("res://scenes/environment")
	ResourceSaver.save(packed, SAVE_PATH)
	print("Successfully saved to ", SAVE_PATH)

func _parse_tsx(filename: String, firstgid: int, source_id: int, tileset: TileSet, gids: Array) -> void:
	var path = "res://assets/maps/" + filename
	var parser = XMLParser.new()
	if parser.open(path) != OK:
		print("Failed to open TSX: ", path)
		return
		
	var columns = 0
	var tilecount = 0
	var img_source = ""
	
	while parser.read() == OK:
		var type = parser.get_node_type()
		var node_name = ""
		if type == XMLParser.NODE_ELEMENT or type == XMLParser.NODE_ELEMENT_END:
			node_name = parser.get_node_name()
		
		if type == XMLParser.NODE_ELEMENT:
			if node_name == "tileset":
				columns = int(parser.get_named_attribute_value("columns"))
				tilecount = int(parser.get_named_attribute_value("tilecount"))
			elif node_name == "image":
				img_source = parser.get_named_attribute_value("source")
				break
				
	gids.append({
		"firstgid": firstgid,
		"source_id": source_id,
		"columns": columns,
		"tilecount": tilecount
	})
	
	var img_path = "res://assets/maps/" + img_source
	var texture = load(img_path)
	if not texture:
		print("Failed to load texture: ", img_path)
		return
		
	var atlas = TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(32, 32)
	
	# Create tiles in the source
	for i in range(tilecount):
		var x = i % columns
		var y = i / columns
		atlas.create_tile(Vector2i(x, y))
		
	tileset.add_source(atlas, source_id)
