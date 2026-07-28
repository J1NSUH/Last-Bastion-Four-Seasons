class_name M0MapView
extends Control

signal tile_clicked(tile: Vector2i)
signal tile_hovered(tile: Vector2i)

const INVALID_TILE = Vector2i(-1, -1)
const MIN_CELL_SIZE = 8.0

var map_size = Vector2i(21, 21)
var base_cells: Array[Vector2i] = []
var entrances: Dictionary = {}
var active_directions: Array = []
var front_pressure: Dictionary = {}
var path_cells: Dictionary = {}
var tower_range_cells: Dictionary = {}
var structure_tiles: Dictionary = {}
var enemy_tiles: Dictionary = {}
var enemy_trait_tiles: Dictionary = {}
var boss_enemy_tiles: Dictionary = {}
var enemy_intent_tiles: Dictionary = {}
var card_target_tiles: Dictionary = {}
var recent_event_tiles: Dictionary = {}
var build_mode = "none"
var preview_tile = INVALID_TILE
var preview_ok = false
var preview_reason = ""
var hovered_tile = INVALID_TILE
var selected_tile = INVALID_TILE

var cell_size = 22.0
var map_origin = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(560, 560)


func set_state(
	next_map_size: Vector2i,
	next_base_cells: Array[Vector2i],
	next_entrances: Dictionary,
	next_active_directions: Array,
	next_front_pressure: Dictionary,
	next_path_cells: Dictionary,
	next_tower_range_cells: Dictionary,
	next_structure_tiles: Dictionary,
	next_enemy_tiles: Dictionary,
	next_enemy_trait_tiles: Dictionary,
	next_boss_enemy_tiles: Dictionary,
	next_enemy_intent_tiles: Dictionary,
	next_card_target_tiles: Dictionary,
	next_recent_event_tiles: Dictionary,
	next_build_mode: String,
	next_preview_tile: Vector2i,
	next_preview_ok: bool,
	next_preview_reason: String,
	next_selected_tile: Vector2i
) -> void:
	map_size = next_map_size
	base_cells = next_base_cells.duplicate()
	entrances = next_entrances.duplicate(true)
	active_directions = next_active_directions.duplicate()
	front_pressure = next_front_pressure.duplicate(true)
	path_cells = next_path_cells.duplicate(true)
	tower_range_cells = next_tower_range_cells.duplicate(true)
	structure_tiles = next_structure_tiles.duplicate(true)
	enemy_tiles = next_enemy_tiles.duplicate(true)
	enemy_trait_tiles = next_enemy_trait_tiles.duplicate(true)
	boss_enemy_tiles = next_boss_enemy_tiles.duplicate(true)
	enemy_intent_tiles = next_enemy_intent_tiles.duplicate(true)
	card_target_tiles = next_card_target_tiles.duplicate(true)
	recent_event_tiles = next_recent_event_tiles.duplicate(true)
	build_mode = next_build_mode
	preview_tile = next_preview_tile
	preview_ok = next_preview_ok
	preview_reason = next_preview_reason
	selected_tile = next_selected_tile
	_update_tooltip()
	queue_redraw()


func _draw() -> void:
	_update_metrics()
	draw_rect(Rect2(map_origin, Vector2(cell_size * map_size.x, cell_size * map_size.y)), Color(0.07, 0.08, 0.09))

	for y in range(map_size.y):
		for x in range(map_size.x):
			var tile = Vector2i(x, y)
			_draw_tile(tile)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var tile = _tile_from_position(event.position)
		if tile != hovered_tile:
			hovered_tile = tile
			tile_hovered.emit(tile)
			_update_tooltip()
			queue_redraw()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked_tile = _tile_from_position(event.position)
			if _is_valid_tile(clicked_tile):
				tile_clicked.emit(clicked_tile)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw_tile(tile: Vector2i) -> void:
	var key = _tile_key(tile)
	var rect = Rect2(_tile_position(tile), Vector2(cell_size - 1.0, cell_size - 1.0))
	var color = Color(0.12, 0.14, 0.15)
	var label = ""

	if path_cells.has(key):
		color = Color(0.15, 0.25, 0.18)

	if tower_range_cells.has(key):
		color = Color(0.22, 0.21, 0.13)

	if base_cells.has(tile):
		color = Color(0.45, 0.12, 0.14)
		label = "B"

	for direction in entrances.keys():
		var coord: Array = entrances[direction]
		if tile == Vector2i(int(coord[0]), int(coord[1])):
			var direction_text = str(direction)
			label = direction_text.substr(0, 1).to_upper()
			if active_directions.has(direction_text):
				var pressure: Dictionary = front_pressure.get(direction_text, {})
				color = _front_pressure_color(str(pressure.get("severity", "idle")))
			else:
				color = Color(0.26, 0.27, 0.29)
			break

	if structure_tiles.has(key):
		var structure: Dictionary = structure_tiles[key]
		if structure["type"] == "tower":
			color = Color(0.50, 0.42, 0.12)
			label = "T"
		else:
			color = Color(0.34, 0.24, 0.18)
			label = "X"

	if enemy_tiles.has(key):
		var enemy_trait: Dictionary = enemy_trait_tiles.get(key, {})
		if boss_enemy_tiles.has(key):
			color = Color(0.48, 0.10, 0.42)
		else:
			color = _enemy_trait_color(str(enemy_trait.get("primary", "standard")))
		var default_enemy_label = "E" if int(enemy_tiles[key]) == 1 else str(enemy_tiles[key])
		label = str(enemy_trait.get("label", default_enemy_label))

	if tile == preview_tile and build_mode != "none":
		if build_mode == "remove":
			color = Color(0.45, 0.18, 0.52) if preview_ok else Color(0.28, 0.11, 0.18)
			label = "-"
		else:
			color = Color(0.15, 0.46, 0.26) if preview_ok else Color(0.60, 0.13, 0.12)
			label = "?"

	if recent_event_tiles.has(key):
		color = _event_color(str(recent_event_tiles[key]), color)

	if tile == hovered_tile:
		color = color.lightened(0.18)

	draw_rect(rect, color)
	draw_rect(rect, Color(0.25, 0.28, 0.30), false, 1.0)

	if card_target_tiles.has(key):
		var card_target: Dictionary = card_target_tiles[key]
		if bool(card_target.get("valid", false)):
			var target_rect = Rect2(rect.position + Vector2(2.0, 2.0), rect.size - Vector2(4.0, 4.0))
			draw_rect(target_rect, Color(0.24, 0.86, 0.43), false, 2.0)
			if label.is_empty():
				label = "+"
		elif bool(card_target.get("show_invalid", false)):
			var dot_size = max(2.0, cell_size * 0.14)
			var dot_rect = Rect2(rect.get_center() - Vector2(dot_size, dot_size) * 0.5, Vector2(dot_size, dot_size))
			draw_rect(dot_rect, Color(0.58, 0.12, 0.13))

	if tile == selected_tile:
		var selected_rect = Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
		draw_rect(selected_rect, Color(0.95, 0.92, 0.62), false, 2.0)

	if enemy_intent_tiles.has(key):
		var intent: Dictionary = enemy_intent_tiles[key]
		var intent_rect = Rect2(rect.position + Vector2(3.0, 3.0), rect.size - Vector2(6.0, 6.0))
		draw_rect(intent_rect, _intent_color(str(intent.get("severity", "move"))), false, 2.0)
		if label.is_empty():
			label = _intent_label(str(intent.get("severity", "move")))

	if not label.is_empty() and cell_size >= 16.0:
		var font = get_theme_default_font()
		var font_size = max(10, int(cell_size * 0.52))
		var text_position = rect.position + Vector2(0, (cell_size + font_size * 0.45) * 0.5)
		draw_string(
			font,
			text_position,
			label,
			HORIZONTAL_ALIGNMENT_CENTER,
			cell_size,
			font_size,
			Color(0.92, 0.94, 0.95)
		)


func _update_metrics() -> void:
	if map_size.x <= 0 or map_size.y <= 0:
		map_size = Vector2i(1, 1)

	cell_size = floor(min(size.x / float(map_size.x), size.y / float(map_size.y)))
	cell_size = max(MIN_CELL_SIZE, cell_size)

	var map_pixel_size = Vector2(cell_size * map_size.x, cell_size * map_size.y)
	map_origin = (size - map_pixel_size) * 0.5


func _tile_from_position(position: Vector2) -> Vector2i:
	_update_metrics()
	var local = position - map_origin
	if local.x < 0.0 or local.y < 0.0:
		return INVALID_TILE

	var tile = Vector2i(int(floor(local.x / cell_size)), int(floor(local.y / cell_size)))
	if not _is_valid_tile(tile):
		return INVALID_TILE

	return tile


func _tile_position(tile: Vector2i) -> Vector2:
	return map_origin + Vector2(tile.x * cell_size, tile.y * cell_size)


func _is_valid_tile(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < map_size.x and tile.y < map_size.y


func _update_tooltip() -> void:
	if not _is_valid_tile(hovered_tile):
		tooltip_text = ""
		return

	var parts = PackedStringArray()
	var key = _tile_key(hovered_tile)
	parts.append("tile %s" % _tile_text(hovered_tile))

	if structure_tiles.has(key):
		var structure: Dictionary = structure_tiles[key]
		parts.append("%s hp %s/%s" % [
			structure["type"],
			structure["hp"],
			structure["max_hp"],
		])

	if enemy_tiles.has(key):
		parts.append("enemies %s" % enemy_tiles[key])
		var enemy_trait: Dictionary = enemy_trait_tiles.get(key, {})
		var trait_summary = str(enemy_trait.get("summary", ""))
		if not trait_summary.is_empty() and trait_summary != "Standard":
			parts.append("traits %s" % trait_summary)
		if boss_enemy_tiles.has(key):
			parts.append("bosses %s" % boss_enemy_tiles[key])

	if recent_event_tiles.has(key):
		parts.append("event %s" % recent_event_tiles[key])

	if enemy_intent_tiles.has(key):
		var intent: Dictionary = enemy_intent_tiles[key]
		parts.append("intent %s" % intent.get("summary", "unknown"))

	if card_target_tiles.has(key):
		var card_target: Dictionary = card_target_tiles[key]
		var target_text = "ok" if bool(card_target.get("valid", false)) else "blocked %s" % card_target.get("reason", "unknown")
		parts.append("card target %s" % target_text)

	var entrance_direction = _entrance_direction_for_tile(hovered_tile)
	if not entrance_direction.is_empty() and front_pressure.has(entrance_direction):
		var pressure: Dictionary = front_pressure.get(entrance_direction, {})
		parts.append("front %s" % pressure.get("summary", "clear"))

	if hovered_tile == preview_tile and build_mode != "none":
		parts.append("preview %s" % ("ok" if preview_ok else preview_reason))

	tooltip_text = " | ".join(parts)


func _tile_key(tile: Vector2i) -> String:
	return "%s,%s" % [tile.x, tile.y]


func _tile_text(tile: Vector2i) -> String:
	return "(%s, %s)" % [tile.x, tile.y]


func _entrance_direction_for_tile(tile: Vector2i) -> String:
	for direction in entrances.keys():
		var coord: Array = entrances[direction]
		if tile == Vector2i(int(coord[0]), int(coord[1])):
			return str(direction)
	return ""


func _front_pressure_color(severity: String) -> Color:
	match severity:
		"critical":
			return Color(0.76, 0.08, 0.16)
		"danger":
			return Color(0.72, 0.28, 0.12)
		"watch":
			return Color(0.58, 0.47, 0.12)
		_:
			return Color(0.10, 0.42, 0.56)


func _intent_color(severity: String) -> Color:
	match severity:
		"base":
			return Color(0.95, 0.08, 0.18)
		"siege":
			return Color(0.92, 0.20, 0.78)
		"attack":
			return Color(0.95, 0.72, 0.18)
		"break":
			return Color(0.92, 0.42, 0.12)
		"wait":
			return Color(0.48, 0.50, 0.54)
		_:
			return Color(0.42, 0.68, 0.86)


func _intent_label(severity: String) -> String:
	match severity:
		"base", "siege", "attack":
			return "!"
		"break":
			return "#"
		"wait":
			return "."
		_:
			return ">"


func _enemy_trait_color(primary: String) -> Color:
	match primary:
		"boss":
			return Color(0.48, 0.10, 0.42)
		"breaker":
			return Color(0.66, 0.33, 0.12)
		"armor":
			return Color(0.38, 0.46, 0.52)
		"fast":
			return Color(0.14, 0.52, 0.56)
		_:
			return Color(0.62, 0.18, 0.18)


func _event_color(event_type: String, fallback: Color) -> Color:
	match event_type:
		"attack":
			return Color(0.78, 0.65, 0.16)
		"hit", "structure_hit":
			return Color(0.78, 0.31, 0.13)
		"kill", "structure_destroyed":
			return Color(0.72, 0.12, 0.10)
		"structure_removed":
			return Color(0.45, 0.18, 0.52)
		"base_damage":
			return Color(0.75, 0.08, 0.18)
		"spawn":
			return Color(0.34, 0.55, 0.78)
		"break_path":
			return Color(0.65, 0.42, 0.12)
		"fast_move":
			return Color(0.12, 0.62, 0.64)
		"boss_siege":
			return Color(0.84, 0.22, 0.70)
		"boss_pulse":
			return Color(0.72, 0.16, 0.58)
		_:
			return fallback.lightened(0.12)
