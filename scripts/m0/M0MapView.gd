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
var front_defense: Dictionary = {}
var path_cells: Dictionary = {}
var tower_range_cells: Dictionary = {}
var structure_tiles: Dictionary = {}
var enemy_tiles: Dictionary = {}
var enemy_trait_tiles: Dictionary = {}
var boss_enemy_tiles: Dictionary = {}
var enemy_intent_tiles: Dictionary = {}
var card_target_tiles: Dictionary = {}
var front_recommendation_tiles: Dictionary = {}
var recent_event_tiles: Dictionary = {}
var boss_warning_tiles: Dictionary = {}
var spawn_warning_tiles: Dictionary = {}
var tactical_threat: Dictionary = {}
var confirmed_risk_ping: Dictionary = {}
var alpha_focus_direction = ""
var alpha_focus_setup_marker: Dictionary = {}
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
	next_front_defense: Dictionary,
	next_path_cells: Dictionary,
	next_tower_range_cells: Dictionary,
	next_structure_tiles: Dictionary,
	next_enemy_tiles: Dictionary,
	next_enemy_trait_tiles: Dictionary,
	next_boss_enemy_tiles: Dictionary,
	next_enemy_intent_tiles: Dictionary,
	next_card_target_tiles: Dictionary,
	next_front_recommendation_tiles: Dictionary,
	next_recent_event_tiles: Dictionary,
	next_boss_warning_tiles: Dictionary,
	next_spawn_warning_tiles: Dictionary,
	next_tactical_threat: Dictionary,
	next_confirmed_risk_ping: Dictionary,
	next_alpha_focus_direction: String,
	next_alpha_focus_setup_marker: Dictionary,
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
	front_defense = next_front_defense.duplicate(true)
	path_cells = next_path_cells.duplicate(true)
	tower_range_cells = next_tower_range_cells.duplicate(true)
	structure_tiles = next_structure_tiles.duplicate(true)
	enemy_tiles = next_enemy_tiles.duplicate(true)
	enemy_trait_tiles = next_enemy_trait_tiles.duplicate(true)
	boss_enemy_tiles = next_boss_enemy_tiles.duplicate(true)
	enemy_intent_tiles = next_enemy_intent_tiles.duplicate(true)
	card_target_tiles = next_card_target_tiles.duplicate(true)
	front_recommendation_tiles = next_front_recommendation_tiles.duplicate(true)
	recent_event_tiles = next_recent_event_tiles.duplicate(true)
	boss_warning_tiles = next_boss_warning_tiles.duplicate(true)
	spawn_warning_tiles = next_spawn_warning_tiles.duplicate(true)
	tactical_threat = next_tactical_threat.duplicate(true)
	confirmed_risk_ping = next_confirmed_risk_ping.duplicate(true)
	alpha_focus_direction = next_alpha_focus_direction
	alpha_focus_setup_marker = next_alpha_focus_setup_marker.duplicate(true)
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
	var entrance_direction = ""

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
			entrance_direction = direction_text
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
	_draw_front_defense_overlay(rect, entrance_direction)
	_draw_alpha_focus_overlay(rect, entrance_direction)
	if spawn_warning_tiles.has(key):
		var spawn_warning: Dictionary = spawn_warning_tiles[key]
		_draw_spawn_warning_overlay(rect, spawn_warning)
		if label.is_empty() or (not enemy_tiles.has(key) and not structure_tiles.has(key) and ["N", "E", "S", "W"].has(label)):
			label = _spawn_warning_tile_label(spawn_warning)
	_draw_event_badge(rect, str(recent_event_tiles.get(key, "")))

	if card_target_tiles.has(key):
		var card_target: Dictionary = card_target_tiles[key]
		if bool(card_target.get("valid", false)):
			var target_rect = Rect2(rect.position + Vector2(2.0, 2.0), rect.size - Vector2(4.0, 4.0))
			draw_rect(target_rect, _card_target_border_color(card_target), false, 2.0)
			if label.is_empty():
				label = _tile_guidance_label(tile, label)
		elif bool(card_target.get("show_invalid", false)):
			var dot_size = max(2.0, cell_size * 0.14)
			var dot_rect = Rect2(rect.get_center() - Vector2(dot_size, dot_size) * 0.5, Vector2(dot_size, dot_size))
			draw_rect(dot_rect, Color(0.58, 0.12, 0.13))

	if front_recommendation_tiles.has(key):
		var recommendation_inset = min(5.0, max(2.0, cell_size * 0.18))
		var recommendation_rect = Rect2(
			rect.position + Vector2(recommendation_inset, recommendation_inset),
			rect.size - Vector2(recommendation_inset * 2.0, recommendation_inset * 2.0)
		)
		draw_rect(recommendation_rect, _recommendation_border_color(key), false, max(2.0, cell_size * 0.09))
		if label.is_empty() or label == "+":
			label = _tile_guidance_label(tile, label)

	if boss_warning_tiles.has(key):
		var boss_warning: Dictionary = boss_warning_tiles[key]
		_draw_boss_warning_overlay(rect, boss_warning)
		if label.is_empty() or ["+", "R", "*", "W"].has(label):
			label = _tile_guidance_label(tile, label)

	if _is_alpha_focus_setup_tile(key):
		_draw_alpha_focus_setup_overlay(rect)
		if label.is_empty() or ["+", "R", "*", "W"].has(label):
			label = _alpha_focus_setup_label()

	if tile == selected_tile:
		var selected_rect = Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
		draw_rect(selected_rect, Color(0.95, 0.92, 0.62), false, 2.0)

	if enemy_intent_tiles.has(key):
		var intent: Dictionary = enemy_intent_tiles[key]
		var intent_rect = Rect2(rect.position + Vector2(3.0, 3.0), rect.size - Vector2(6.0, 6.0))
		draw_rect(intent_rect, _intent_color(str(intent.get("severity", "move"))), false, 2.0)
		if label.is_empty():
			label = _intent_label(str(intent.get("severity", "move")))

	if _is_tactical_threat_tile(key):
		_draw_tactical_threat_pin(rect)
		label = "!" if label.is_empty() else "%s!" % label

	if _is_confirmed_risk_ping_tile(key):
		_draw_confirmed_risk_ping_pin(rect)
		label = _confirmed_risk_ping_label()

	if _front_needs_minimum_defense(entrance_direction):
		label = "!" if label.is_empty() else "%s!" % label

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
		var event_type = str(recent_event_tiles[key])
		parts.append("event %s" % _event_summary(event_type))

	if enemy_intent_tiles.has(key):
		var intent: Dictionary = enemy_intent_tiles[key]
		parts.append("intent %s" % intent.get("summary", "unknown"))
	if _is_tactical_threat_tile(key):
		parts.append("tactical threat %s" % tactical_threat.get("headline", tactical_threat.get("summary", "watch this tile")))
	if _is_confirmed_risk_ping_tile(key):
		parts.append("confirmed ping %s" % confirmed_risk_ping.get("candidate_label", "Ping"))
		var ping_reason = str(confirmed_risk_ping.get("reason", ""))
		if not ping_reason.is_empty():
			parts.append("ping reason %s" % ping_reason)

	if card_target_tiles.has(key):
		var card_target: Dictionary = card_target_tiles[key]
		var target_text = "ok" if bool(card_target.get("valid", false)) else "blocked %s" % card_target.get("reason", "unknown")
		parts.append("card target %s" % target_text)
		var boss_part_summary = str(card_target.get("boss_part_summary", ""))
		if not boss_part_summary.is_empty():
			parts.append(boss_part_summary)
	if front_recommendation_tiles.has(key):
		var recommendation: Dictionary = front_recommendation_tiles[key]
		parts.append("%s %s" % [
			_recommendation_tooltip_prefix(key),
			recommendation.get("summary", "-"),
		])
		var why = str(recommendation.get("why", ""))
		if not why.is_empty():
			parts.append("why %s" % why)
	if boss_warning_tiles.has(key):
		var boss_warning: Dictionary = boss_warning_tiles[key]
		parts.append("boss warning %s" % boss_warning.get("summary", "-"))
		var suggestion = str(boss_warning.get("suggestion", ""))
		if not suggestion.is_empty():
			parts.append("response %s" % suggestion)
	if spawn_warning_tiles.has(key):
		var spawn_warning: Dictionary = spawn_warning_tiles[key]
		parts.append("spawn warning %s" % spawn_warning.get("summary", "-"))
		var direction_role = str(spawn_warning.get("directionRole", ""))
		if not direction_role.is_empty() and direction_role != "any":
			parts.append("spawn role %s" % direction_role)
		var status = str(spawn_warning.get("status", ""))
		if not status.is_empty():
			parts.append("spawn status %s" % status)

	var entrance_direction = _entrance_direction_for_tile(hovered_tile)
	if not entrance_direction.is_empty() and front_pressure.has(entrance_direction):
		var pressure: Dictionary = front_pressure.get(entrance_direction, {})
		parts.append("front %s" % pressure.get("summary", "clear"))
	if not entrance_direction.is_empty() and front_defense.has(entrance_direction):
		var defense: Dictionary = front_defense.get(entrance_direction, {})
		parts.append("defense %s" % defense.get("summary", "-"))
	if _is_alpha_focus_direction(entrance_direction):
		parts.append("alpha focus selected for next balance probe")
	if _is_alpha_focus_setup_tile(key):
		parts.append("alpha focus setup %s" % alpha_focus_setup_marker.get("summary", "first setup candidate"))
		var setup_reason = str(alpha_focus_setup_marker.get("why", ""))
		if not setup_reason.is_empty():
			parts.append("setup reason %s" % setup_reason)

	if hovered_tile == preview_tile and build_mode != "none":
		parts.append("preview %s" % ("ok" if preview_ok else preview_reason))

	tooltip_text = " | ".join(parts)


func _tile_key(tile: Vector2i) -> String:
	return "%s,%s" % [tile.x, tile.y]


func _tile_text(tile: Vector2i) -> String:
	return "(%s, %s)" % [tile.x, tile.y]


func debug_tile_guidance_label(tile: Vector2i) -> String:
	return _tile_guidance_label(tile, "")


func debug_event_label(event_type: String) -> String:
	return _event_label(event_type)


func debug_tactical_threat_label(tile: Vector2i) -> String:
	return "!" if _is_tactical_threat_tile(_tile_key(tile)) else ""


func debug_confirmed_risk_ping_label(tile: Vector2i) -> String:
	return _confirmed_risk_ping_label() if _is_confirmed_risk_ping_tile(_tile_key(tile)) else ""


func debug_boss_warning_label(tile: Vector2i) -> String:
	var key = _tile_key(tile)
	if not boss_warning_tiles.has(key):
		return ""

	return _boss_warning_tile_label(boss_warning_tiles[key])


func debug_spawn_warning_label(tile: Vector2i) -> String:
	var key = _tile_key(tile)
	if not spawn_warning_tiles.has(key):
		return ""

	return _spawn_warning_tile_label(spawn_warning_tiles[key])


func debug_alpha_focus_label(direction: String) -> String:
	return "F" if _is_alpha_focus_direction(direction) else ""


func debug_alpha_focus_setup_label(tile: Vector2i) -> String:
	return _alpha_focus_setup_label() if _is_alpha_focus_setup_tile(_tile_key(tile)) else ""


func _tile_guidance_label(tile: Vector2i, fallback_label: String) -> String:
	var key = _tile_key(tile)
	if boss_warning_tiles.has(key):
		return _boss_warning_tile_label(boss_warning_tiles[key])
	if _is_boss_part_card_target(key):
		return "W"
	if _is_rebuild_recommendation(key):
		return "B"
	if _is_recommended_valid_target(key):
		return "R"
	if _is_valid_card_target(key):
		return "+"
	if front_recommendation_tiles.has(key):
		return "*"
	return fallback_label


func _is_valid_card_target(key: String) -> bool:
	if not card_target_tiles.has(key):
		return false

	var card_target: Dictionary = card_target_tiles[key]
	return bool(card_target.get("valid", false))


func _is_boss_part_card_target(key: String) -> bool:
	if not _is_valid_card_target(key):
		return false

	var card_target: Dictionary = card_target_tiles[key]
	return not str(card_target.get("boss_part_label", "")).is_empty()


func _is_recommended_valid_target(key: String) -> bool:
	return front_recommendation_tiles.has(key) and _is_valid_card_target(key)


func _is_rebuild_recommendation(key: String) -> bool:
	if not front_recommendation_tiles.has(key):
		return false

	var recommendation: Dictionary = front_recommendation_tiles[key]
	if bool(recommendation.get("rebuild", false)):
		return true
	return str(recommendation.get("intent", "")).begins_with("rebuild")


func _recommendation_tooltip_prefix(key: String) -> String:
	if _is_rebuild_recommendation(key):
		return "rebuild target"
	return "recommended target" if _is_recommended_valid_target(key) else "recommended"


func _card_target_border_color(card_target: Dictionary) -> Color:
	if not str(card_target.get("boss_part_label", "")).is_empty():
		return Color(1.00, 0.66, 0.22)

	return Color(0.24, 0.86, 0.43)


func _recommendation_border_color(key: String) -> Color:
	if _is_rebuild_recommendation(key):
		return Color(0.98, 0.55, 0.20)
	if _is_recommended_valid_target(key):
		return Color(0.96, 0.78, 0.18)
	return Color(0.28, 0.84, 0.92)


func _is_tactical_threat_tile(key: String) -> bool:
	if tactical_threat.is_empty():
		return false

	var tile = tactical_threat.get("tile", INVALID_TILE)
	return typeof(tile) == TYPE_VECTOR2I and _tile_key(tile) == key


func _is_confirmed_risk_ping_tile(key: String) -> bool:
	if confirmed_risk_ping.is_empty():
		return false

	var tile = confirmed_risk_ping.get("tile", INVALID_TILE)
	return typeof(tile) == TYPE_VECTOR2I and _tile_key(tile) == key


func _confirmed_risk_ping_label() -> String:
	var label = str(confirmed_risk_ping.get("label", "P"))
	return "P" if label.is_empty() else label.substr(0, 1).to_upper()


func _draw_confirmed_risk_ping_pin(rect: Rect2) -> void:
	var color = Color(0.32, 0.86, 1.00)
	var border_rect = Rect2(rect.position + Vector2(0.5, 0.5), rect.size - Vector2(1.0, 1.0))
	draw_rect(border_rect, color, false, max(2.0, cell_size * 0.18))

	var badge_size = min(max(10.0, cell_size * 0.42), rect.size.x * 0.54)
	var badge_rect = Rect2(
		rect.position + Vector2(rect.size.x - badge_size - 2.0, rect.size.y - badge_size - 2.0),
		Vector2(badge_size, badge_size)
	)
	draw_rect(badge_rect, color.darkened(0.22))
	draw_rect(badge_rect, Color(0.03, 0.05, 0.06), false, 1.0)

	if cell_size < 14.0:
		return

	var font = get_theme_default_font()
	var font_size = max(8, int(badge_size * 0.68))
	var text_position = badge_rect.position + Vector2(0.0, (badge_size + font_size * 0.45) * 0.5)
	draw_string(
		font,
		text_position,
		_confirmed_risk_ping_label(),
		HORIZONTAL_ALIGNMENT_CENTER,
		badge_size,
		font_size,
		Color(0.96, 0.98, 1.0)
	)


func _draw_boss_warning_overlay(rect: Rect2, warning: Dictionary) -> void:
	var color = _boss_warning_color(warning)
	var border_width = max(2.0, cell_size * 0.12)
	var warning_rect = Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
	draw_rect(warning_rect, color, false, border_width)

	var inner_inset = min(7.0, max(3.0, cell_size * 0.22))
	var inner_rect = Rect2(
		rect.position + Vector2(inner_inset, inner_inset),
		rect.size - Vector2(inner_inset * 2.0, inner_inset * 2.0)
	)
	draw_rect(inner_rect, color.lightened(0.22), false, max(1.0, cell_size * 0.06))


func _boss_warning_color(warning: Dictionary) -> Color:
	match str(warning.get("kind", "")):
		"focus":
			return Color(0.98, 0.34, 0.86)
		"structure":
			return Color(1.00, 0.62, 0.20)
		"delay":
			return Color(0.26, 0.78, 0.96)
		_:
			return Color(0.92, 0.90, 0.38)


func _boss_warning_tile_label(warning: Dictionary) -> String:
	var label = str(warning.get("label", ""))
	if not label.is_empty():
		return label

	match str(warning.get("kind", "")):
		"focus":
			return "W"
		"structure":
			return "!"
		"delay":
			return "D"
		_:
			return "!"


func _draw_spawn_warning_overlay(rect: Rect2, warning: Dictionary) -> void:
	var color = _spawn_warning_color(warning)
	var border_rect = Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
	draw_rect(border_rect, color, false, max(2.0, cell_size * 0.13))

	if cell_size < 14.0:
		return

	var badge_size = min(max(8.0, cell_size * 0.36), rect.size.x * 0.46)
	var badge_rect = Rect2(
		rect.position + Vector2((rect.size.x - badge_size) * 0.5, rect.size.y - badge_size - 2.0),
		Vector2(badge_size, badge_size)
	)
	draw_rect(badge_rect, color.darkened(0.20))
	draw_rect(badge_rect, Color(0.04, 0.05, 0.06), false, 1.0)

	var font = get_theme_default_font()
	var font_size = max(8, int(badge_size * 0.70))
	var text_position = badge_rect.position + Vector2(0.0, (badge_size + font_size * 0.45) * 0.5)
	draw_string(
		font,
		text_position,
		_spawn_warning_tile_label(warning),
		HORIZONTAL_ALIGNMENT_CENTER,
		badge_size,
		font_size,
		Color(0.96, 0.97, 0.98)
	)


func _spawn_warning_color(warning: Dictionary) -> Color:
	match str(warning.get("severity", "notice")):
		"boss":
			return Color(0.92, 0.24, 0.82)
		"critical":
			return Color(0.98, 0.20, 0.18)
		"warning":
			return Color(0.98, 0.58, 0.16)
		_:
			return Color(0.26, 0.72, 0.96)


func _spawn_warning_tile_label(warning: Dictionary) -> String:
	var label = str(warning.get("label", ""))
	if not label.is_empty():
		return label.substr(0, 2).to_upper()

	var status = str(warning.get("status", ""))
	if status == "next":
		return ">"
	return "Q"


func _draw_tactical_threat_pin(rect: Rect2) -> void:
	var color = _tactical_threat_color(str(tactical_threat.get("severity", "watch")))
	var outer_rect = Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
	var inner_inset = min(6.0, max(3.0, cell_size * 0.20))
	var inner_rect = Rect2(
		rect.position + Vector2(inner_inset, inner_inset),
		rect.size - Vector2(inner_inset * 2.0, inner_inset * 2.0)
	)
	draw_rect(outer_rect, color, false, max(2.0, cell_size * 0.14))
	draw_rect(inner_rect, color.lightened(0.20), false, max(1.0, cell_size * 0.07))


func _tactical_threat_color(severity: String) -> Color:
	match severity:
		"base":
			return Color(0.98, 0.08, 0.18)
		"boss":
			return Color(0.94, 0.26, 0.82)
		"structure", "break":
			return Color(0.96, 0.56, 0.14)
		"advance":
			return Color(0.34, 0.82, 0.96)
		_:
			return Color(0.92, 0.90, 0.38)


func _is_alpha_focus_direction(direction: String) -> bool:
	return not direction.is_empty() and direction == alpha_focus_direction


func _is_alpha_focus_setup_tile(key: String) -> bool:
	if alpha_focus_setup_marker.is_empty():
		return false

	var tile = alpha_focus_setup_marker.get("tile", INVALID_TILE)
	return typeof(tile) == TYPE_VECTOR2I and _tile_key(tile) == key


func _alpha_focus_setup_label() -> String:
	var label = str(alpha_focus_setup_marker.get("label", "F"))
	return "F" if label.is_empty() else label.substr(0, 1).to_upper()


func _draw_alpha_focus_setup_overlay(rect: Rect2) -> void:
	var color = Color(0.48, 0.78, 1.00)
	var marker_inset = min(5.0, max(2.0, cell_size * 0.16))
	var marker_rect = Rect2(
		rect.position + Vector2(marker_inset, marker_inset),
		rect.size - Vector2(marker_inset * 2.0, marker_inset * 2.0)
	)
	draw_rect(marker_rect, color, false, max(2.0, cell_size * 0.10))
	if cell_size < 14.0:
		return

	var badge_size = min(max(8.0, cell_size * 0.36), rect.size.x * 0.46)
	var badge_rect = Rect2(
		rect.position + Vector2(2.0, rect.size.y - badge_size - 2.0),
		Vector2(badge_size, badge_size)
	)
	draw_rect(badge_rect, Color(0.09, 0.28, 0.54))
	draw_rect(badge_rect, Color(0.04, 0.05, 0.06), false, 1.0)

	var font = get_theme_default_font()
	var font_size = max(8, int(badge_size * 0.70))
	var text_position = badge_rect.position + Vector2(0.0, (badge_size + font_size * 0.45) * 0.5)
	draw_string(
		font,
		text_position,
		_alpha_focus_setup_label(),
		HORIZONTAL_ALIGNMENT_CENTER,
		badge_size,
		font_size,
		Color(0.96, 0.97, 0.98)
	)


func _draw_alpha_focus_overlay(rect: Rect2, direction: String) -> void:
	if not _is_alpha_focus_direction(direction):
		return

	var border_rect = Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
	draw_rect(border_rect, Color(0.38, 0.72, 1.0), false, max(2.0, cell_size * 0.16))
	if cell_size < 14.0:
		return

	var badge_size = min(max(8.0, cell_size * 0.34), rect.size.x * 0.42)
	var badge_rect = Rect2(
		rect.position + Vector2(rect.size.x - badge_size - 2.0, 2.0),
		Vector2(badge_size, badge_size)
	)
	draw_rect(badge_rect, Color(0.10, 0.32, 0.58))
	draw_rect(badge_rect, Color(0.04, 0.05, 0.06), false, 1.0)

	var font = get_theme_default_font()
	var font_size = max(8, int(badge_size * 0.70))
	var text_position = badge_rect.position + Vector2(0.0, (badge_size + font_size * 0.45) * 0.5)
	draw_string(
		font,
		text_position,
		"F",
		HORIZONTAL_ALIGNMENT_CENTER,
		badge_size,
		font_size,
		Color(0.96, 0.97, 0.98)
	)


func _draw_event_badge(rect: Rect2, event_type: String) -> void:
	if event_type.is_empty() or cell_size < 14.0:
		return

	var badge_label = _event_label(event_type)
	if badge_label.is_empty():
		return

	var badge_size = min(max(8.0, cell_size * 0.36), rect.size.x * 0.46)
	var badge_rect = Rect2(rect.position + Vector2(2.0, 2.0), Vector2(badge_size, badge_size))
	var badge_color = _event_color(event_type, Color(0.30, 0.32, 0.34))
	draw_rect(badge_rect, badge_color)
	draw_rect(badge_rect, Color(0.04, 0.05, 0.06), false, 1.0)

	var font = get_theme_default_font()
	var font_size = max(8, int(badge_size * 0.70))
	var text_position = badge_rect.position + Vector2(0.0, (badge_size + font_size * 0.45) * 0.5)
	draw_string(
		font,
		text_position,
		badge_label,
		HORIZONTAL_ALIGNMENT_CENTER,
		badge_size,
		font_size,
		Color(0.96, 0.97, 0.98)
	)


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


func _draw_front_defense_overlay(rect: Rect2, direction: String) -> void:
	if direction.is_empty() or not active_directions.has(direction) or not front_defense.has(direction):
		return

	var defense: Dictionary = front_defense.get(direction, {})
	var border_color = _front_defense_border_color(defense)
	var border_width = _front_defense_border_width(defense)
	var border_rect = Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
	draw_rect(border_rect, border_color, false, border_width)


func _front_needs_minimum_defense(direction: String) -> bool:
	if direction.is_empty() or not front_defense.has(direction):
		return false

	var defense: Dictionary = front_defense.get(direction, {})
	return bool(defense.get("needs_minimum_defense", false))


func _front_defense_border_color(defense: Dictionary) -> Color:
	if bool(defense.get("needs_minimum_defense", false)):
		return Color(0.96, 0.78, 0.18)
	if int(defense.get("critical_count", 0)) > 0:
		return Color(0.95, 0.30, 0.18)
	if int(defense.get("damaged_count", 0)) > 0 or int(defense.get("pressure_rank", 0)) >= 2:
		return Color(0.93, 0.55, 0.18)
	return Color(0.18, 0.78, 0.68)


func _front_defense_border_width(defense: Dictionary) -> float:
	if bool(defense.get("needs_minimum_defense", false)):
		return max(2.0, cell_size * 0.14)
	if int(defense.get("critical_count", 0)) > 0 or int(defense.get("pressure_rank", 0)) >= 2:
		return max(2.0, cell_size * 0.11)
	return max(1.0, cell_size * 0.07)


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
		"boss_slow":
			return Color(0.18, 0.56, 0.78)
		_:
			return fallback.lightened(0.12)


func _event_label(event_type: String) -> String:
	match event_type:
		"spawn":
			return "S"
		"attack":
			return "A"
		"hit", "structure_hit":
			return "H"
		"kill", "structure_destroyed":
			return "K"
		"structure_removed":
			return "-"
		"base_damage":
			return "B"
		"break_path":
			return "#"
		"fast_move":
			return "F"
		"boss_siege":
			return "G"
		"boss_pulse":
			return "P"
		"boss_slow":
			return "L"
		"explosion":
			return "X"
		"card_repair":
			return "R"
		"debug_spawn", "debug_structure":
			return "D"
		_:
			return "!"


func _event_summary(event_type: String) -> String:
	match event_type:
		"spawn":
			return "spawn (S)"
		"attack":
			return "tower attack (A)"
		"hit":
			return "enemy hit (H)"
		"structure_hit":
			return "structure hit (H)"
		"kill":
			return "enemy killed (K)"
		"structure_destroyed":
			return "structure destroyed (K)"
		"structure_removed":
			return "structure removed (-)"
		"base_damage":
			return "base damage (B)"
		"break_path":
			return "path break (#)"
		"fast_move":
			return "fast move (F)"
		"boss_siege":
			return "boss gaze (G)"
		"boss_pulse":
			return "boss pulse (P)"
		"boss_slow":
			return "boss slowed (L)"
		"explosion":
			return "explosion (X)"
		"card_repair":
			return "card repair (R)"
		"debug_spawn":
			return "debug spawn (D)"
		"debug_structure":
			return "debug structure (D)"
		_:
			return "%s (!)" % event_type
