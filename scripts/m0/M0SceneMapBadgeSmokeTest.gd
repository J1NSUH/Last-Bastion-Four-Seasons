extends SceneTree

const M0MapViewScript = preload("res://scripts/m0/M0MapView.gd")

var failed = false


func _init() -> void:
	var map_view = M0MapViewScript.new()
	map_view.card_target_tiles = {
		"1,1": {"valid": true},
		"2,1": {"valid": true},
		"6,1": {
			"valid": true,
			"boss_part_label": "Legs",
			"boss_part_summary": "Boss focus: Legs 4/4 - slows stride",
		},
	}
	map_view.front_recommendation_tiles = {
		"1,1": {"summary": "best shared tile"},
		"3,1": {"summary": "front recommendation"},
		"4,2": {"summary": "rebuild pocket", "intent": "rebuild_planned_collapse", "rebuild": true},
	}
	map_view.boss_warning_tiles = {
		"7,1": {"kind": "focus", "label": "W", "summary": "warned boss part"},
		"8,1": {"kind": "structure", "label": "!", "summary": "threatened structure"},
		"9,1": {"kind": "delay", "label": "D", "summary": "delay candidate"},
	}
	map_view.spawn_warning_tiles = {
		"10,1": {"label": ">", "status": "next", "severity": "warning", "summary": "0s north Skitter"},
		"11,1": {"status": "queued", "severity": "notice", "summary": "5s east Walker"},
	}
	map_view.tactical_threat = {
		"tile": Vector2i(4, 1),
		"severity": "base",
		"headline": "Enemy Walker will hit base",
	}
	map_view.confirmed_risk_ping = {
		"tile": Vector2i(5, 1),
		"label": "P",
		"candidate_label": "Focus fire",
		"reason": "test ping",
	}
	map_view.alpha_focus_direction = "east"
	map_view.alpha_focus_setup_marker = {
		"tile": Vector2i(4, 2),
		"label": "F",
		"summary": "Guardian 1P setup",
		"why": "test focus setup",
	}

	_assert(map_view.debug_tile_guidance_label(Vector2i(1, 1)) == "R", "map guidance labels recommended card targets")
	_assert(map_view.debug_tile_guidance_label(Vector2i(2, 1)) == "+", "map guidance labels valid card targets")
	_assert(map_view.debug_tile_guidance_label(Vector2i(3, 1)) == "*", "map guidance labels standalone recommendations")
	_assert(map_view.debug_tile_guidance_label(Vector2i(4, 2)) == "B", "map guidance labels rebuild recommendations")
	_assert(map_view.debug_tile_guidance_label(Vector2i(6, 1)) == "W", "map guidance labels boss part targets")
	_assert(map_view.debug_boss_warning_label(Vector2i(7, 1)) == "W", "map warning labels warned boss parts")
	_assert(map_view.debug_boss_warning_label(Vector2i(8, 1)) == "!", "map warning labels threatened structures")
	_assert(map_view.debug_boss_warning_label(Vector2i(9, 1)) == "D", "map warning labels delay candidates")
	_assert(map_view.debug_spawn_warning_label(Vector2i(10, 1)) == ">", "map spawn warning labels the next packet")
	_assert(map_view.debug_spawn_warning_label(Vector2i(11, 1)) == "Q", "map spawn warning labels queued packets")
	_assert(map_view.debug_spawn_warning_label(Vector2i(12, 1)).is_empty(), "map spawn warning ignores unmarked tiles")
	_assert(map_view.debug_tactical_threat_label(Vector2i(4, 1)) == "!", "map guidance labels tactical threat tiles")
	_assert(map_view.debug_tactical_threat_label(Vector2i(5, 1)).is_empty(), "map guidance ignores non-threat tactical tiles")
	_assert(map_view.debug_confirmed_risk_ping_label(Vector2i(5, 1)) == "P", "map guidance labels confirmed risk ping tiles")
	_assert(map_view.debug_confirmed_risk_ping_label(Vector2i(6, 1)).is_empty(), "map guidance ignores non-ping tiles")
	_assert(map_view.debug_alpha_focus_setup_label(Vector2i(4, 2)) == "F", "map guidance labels alpha focus setup tiles")
	_assert(map_view.debug_alpha_focus_setup_label(Vector2i(4, 3)).is_empty(), "map guidance ignores non-focus setup tiles")
	_assert(map_view.debug_alpha_focus_label("east") == "F", "map alpha focus labels selected front")
	_assert(map_view.debug_alpha_focus_label("north").is_empty(), "map alpha focus ignores unselected fronts")
	_assert(map_view.debug_event_label("spawn") == "S", "map event badge labels spawns")
	_assert(map_view.debug_event_label("hit") == "H", "map event badge labels hits")
	_assert(map_view.debug_event_label("kill") == "K", "map event badge labels kills")
	_assert(map_view.debug_event_label("base_damage") == "B", "map event badge labels base damage")
	_assert(map_view.debug_event_label("boss_pulse") == "P", "map event badge labels boss pulses")
	_assert(map_view.debug_event_label("boss_siege") == "G", "map event badge labels boss gaze")
	_assert(map_view.debug_event_label("boss_slow") == "L", "map event badge labels boss slow steps")
	var gap_width = map_view._front_defense_border_width({"needs_minimum_defense": true})
	var covered_width = map_view._front_defense_border_width({"structure_count": 1})
	_assert(gap_width > covered_width, "front defense gap border is stronger than covered border")
	_assert(map_view._front_needs_minimum_defense("east") == false, "front defense marker ignores missing data")
	map_view.free()

	quit(1 if failed else 0)


func _assert(condition: bool, label: String) -> void:
	if condition:
		print("[PASS] %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	failed = true
	push_error("[FAIL] %s" % label)
