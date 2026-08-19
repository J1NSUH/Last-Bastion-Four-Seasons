class_name M0AlphaCoverageRunner
extends RefCounted

const M0CombatSimulationScript = preload("res://scripts/m0/M0CombatSimulation.gd")

const CLASS_IDS = [
	"guardian",
	"architect",
	"elementalist",
	"tinkerer",
]
const PLAYER_COUNTS = [1, 2, 3, 4]
const EXPECTED_DIRECTIONS = {
	1: ["east"],
	2: ["north", "east"],
	3: ["west", "north", "east"],
	4: ["west", "north", "east", "south"],
}
const REQUIRED_SIGNALS = {
	"guardian": ["taunt_applied", "guardian_hit_received", "thorns_or_guard_log"],
	"architect": ["path_changed", "full_block_rejected", "barricade_break_or_debris_log"],
	"elementalist": ["splash_damage_applied", "control_effect_applied", "invalid_target_rejected"],
	"tinkerer": ["aura_applied", "repair_or_boost_applied", "invalid_target_rejected"],
}
const HUMAN_REVIEW_PROBES = {
	"guardian": "Replay the opening contact and check whether taunt ping-pong is readable and worth discussing.",
	"architect": "Replay the first collapse and check whether barricade loss feels like a planned tactic.",
	"elementalist": "Replay a packed kill zone and check whether splash/control timing is clear without target confusion.",
	"tinkerer": "Replay a clustered defense and check whether aura value and remote repair timing are easy to notice.",
}
const RECOMMENDATION_CONTRAST_SAMPLE_LIMIT = 48

var lines: Array[String] = []
var failures: Array[String] = []


func run_all() -> Dictionary:
	lines.clear()
	failures.clear()

	var cases: Array = []
	var summary_lines: Array[String] = []
	for class_id in CLASS_IDS:
		for player_count in PLAYER_COUNTS:
			var case_result = _run_case(str(class_id), int(player_count))
			cases.append(case_result)
			summary_lines.append(_format_case_summary(case_result))
			lines.append(_format_case_line(case_result))
			if not bool(case_result.get("passed", false)):
				failures.append("%s missing %s" % [
					case_result.get("coverageRunId", "coverage_case"),
					", ".join(_string_values(case_result.get("missingSignalIds", []))),
				])

	var human_review_queue = _build_human_review_queue(cases)
	var aggregate = _aggregate(cases)
	return {
		"ok": failures.is_empty(),
		"lines": lines.duplicate(),
		"failures": failures.duplicate(),
		"cases": cases,
		"summary_lines": summary_lines,
		"aggregate": aggregate,
		"human_review_queue": human_review_queue,
		"alpha_focus_queue": human_review_queue.duplicate(true),
		"next_action_queue": _build_human_next_action_queue(human_review_queue),
		"recommendation_contrast_samples": aggregate.get("recommendation_contrast_samples", []).duplicate(true),
	}


func required_signal_ids(class_id: String) -> Array:
	return REQUIRED_SIGNALS.get(class_id, []).duplicate()


func _run_case(class_id: String, player_count: int) -> Dictionary:
	var simulation = M0CombatSimulationScript.new()
	var load_ok = simulation.load_data()
	if not load_ok:
		return _case_result(
			class_id,
			player_count,
			{},
			["data_not_loaded"],
			"load_data",
			["data_not_loaded"],
			[],
			{}
		)

	var reject_reason_ids: Array[String] = []
	var events: Array[String] = []
	var facts = {
		"path_changed": false,
		"full_block_rejected": false,
		"invalid_target_rejected": false,
		"valid_target_accepted": false,
		"control_effect_applied": false,
	}
	var failed_step_id = _validate_direction_projection(simulation, player_count, reject_reason_ids)

	if failed_step_id.is_empty():
		match class_id:
			"guardian":
				failed_step_id = _run_guardian_script(simulation, player_count, events, reject_reason_ids, facts)
			"architect":
				failed_step_id = _run_architect_script(simulation, player_count, events, reject_reason_ids, facts)
			"elementalist":
				failed_step_id = _run_elementalist_script(simulation, player_count, events, reject_reason_ids, facts)
			"tinkerer":
				failed_step_id = _run_tinkerer_script(simulation, player_count, events, reject_reason_ids, facts)
			_:
				failed_step_id = "unknown_class"
				reject_reason_ids.append("unknown_class")

	var reward_recommendation = _alpha_reward_recommendation_snapshot(simulation, player_count, class_id)
	var artifact_recommendation = _alpha_artifact_recommendation_snapshot(simulation, player_count)
	var shop_recommendation = _alpha_shop_recommendation_snapshot(simulation, player_count, class_id)
	var stats: Dictionary = simulation.get_run_stats().duplicate(true)
	var observed_signal_ids = _observed_signal_ids(class_id, stats, facts)
	var missing_signal_ids = _missing_signal_ids(required_signal_ids(class_id), observed_signal_ids)
	return _case_result(
		class_id,
		player_count,
		stats,
		observed_signal_ids,
		failed_step_id,
		reject_reason_ids,
		missing_signal_ids,
		facts,
		events,
		simulation.get_active_directions(player_count),
		reward_recommendation,
		artifact_recommendation,
		shop_recommendation
	)


func _run_guardian_script(
	simulation,
	player_count: int,
	events: Array[String],
	reject_reason_ids: Array[String],
	_facts: Dictionary
) -> String:
	var hand_result = simulation.debug_set_hand(["m0_tower_permit", "m0_barricade_kit", "m0_field_patch"])
	if not bool(hand_result.get("ok", false)):
		reject_reason_ids.append(str(hand_result.get("reason", "hand_failed")))
		return "guardian_fixed_hand"

	var barricade_result = simulation.place_structure(Vector2i(18, 10), "barricade", player_count, "")
	if not bool(barricade_result.get("ok", false)):
		reject_reason_ids.append(str(barricade_result.get("reason", "barricade_failed")))
		return "guardian_bait_barricade"

	var tower_result = simulation.place_structure(Vector2i(19, 9), "tower", player_count, "guardian")
	if not bool(tower_result.get("ok", false)):
		reject_reason_ids.append(str(tower_result.get("reason", "tower_failed")))
		return "guardian_taunt_tower"

	var spawn_result = simulation.debug_spawn_enemy(Vector2i(19, 10), 6, "east", "m0_walker")
	if not bool(spawn_result.get("ok", false)):
		reject_reason_ids.append(str(spawn_result.get("reason", "spawn_failed")))
		return "guardian_contact_spawn"

	_append_events(events, simulation.debug_run_enemy_movement())
	return ""


func _run_architect_script(
	simulation,
	player_count: int,
	events: Array[String],
	reject_reason_ids: Array[String],
	facts: Dictionary
) -> String:
	var hand_result = simulation.debug_set_hand(["m0_barricade_kit", "m0_quick_brace", "m0_tower_permit"])
	if not bool(hand_result.get("ok", false)):
		reject_reason_ids.append(str(hand_result.get("reason", "hand_failed")))
		return "architect_fixed_hand"

	var before_path = _path_signature(simulation, player_count)
	var barricade_result = simulation.place_structure(Vector2i(18, 10), "barricade", player_count, "architect")
	if not bool(barricade_result.get("ok", false)):
		reject_reason_ids.append(str(barricade_result.get("reason", "barricade_failed")))
		return "architect_path_barricade"

	facts["path_changed"] = before_path != _path_signature(simulation, player_count)
	var spawn_result = simulation.debug_spawn_enemy(Vector2i(19, 10), 6, "east", "m0_walker")
	if not bool(spawn_result.get("ok", false)):
		reject_reason_ids.append(str(spawn_result.get("reason", "spawn_failed")))
		return "architect_break_spawn"

	for _index in range(6):
		_append_events(events, simulation.debug_run_enemy_movement())

	var full_block = _run_full_block_probe(simulation, player_count, "architect")
	var full_block_reason = str(full_block.get("reason", ""))
	if bool(full_block.get("ok", false)):
		facts["full_block_rejected"] = true
		reject_reason_ids.append(full_block_reason)
	else:
		reject_reason_ids.append(full_block_reason)
		return "architect_full_block_probe"

	return ""


func _run_elementalist_script(
	simulation,
	player_count: int,
	events: Array[String],
	reject_reason_ids: Array[String],
	facts: Dictionary
) -> String:
	var hand_result = simulation.debug_set_hand(["m0_arc_spark", "m0_tower_permit", "m0_barricade_kit"])
	if not bool(hand_result.get("ok", false)):
		reject_reason_ids.append(str(hand_result.get("reason", "hand_failed")))
		return "elementalist_fixed_hand"

	var tower_result = simulation.place_structure(Vector2i(15, 10), "tower", player_count, "elementalist")
	if not bool(tower_result.get("ok", false)):
		reject_reason_ids.append(str(tower_result.get("reason", "tower_failed")))
		return "elementalist_splash_tower"

	var primary_spawn = simulation.debug_spawn_enemy(Vector2i(18, 10), 6, "east", "m0_walker")
	var splash_spawn = simulation.debug_spawn_enemy(Vector2i(18, 11), 6, "east", "m0_walker")
	if not bool(primary_spawn.get("ok", false)) or not bool(splash_spawn.get("ok", false)):
		reject_reason_ids.append("splash_spawn_failed")
		return "elementalist_splash_spawn"

	_append_events(events, simulation.debug_run_tower_attack())
	var invalid_target = simulation.debug_card_target_condition("m0_arc_spark", Vector2i(0, 0), player_count, "elementalist")
	if str(invalid_target.get("reason", "")) == "no_enemy_at_tile":
		facts["invalid_target_rejected"] = true
		reject_reason_ids.append(str(invalid_target.get("reason", "")))
	else:
		reject_reason_ids.append(str(invalid_target.get("reason", "invalid_target_probe_failed")))
		return "elementalist_invalid_target_probe"

	var boss_spawn = simulation.debug_spawn_enemy(Vector2i(20, 10), -1, "east", "m0_colossus")
	if not bool(boss_spawn.get("ok", false)):
		reject_reason_ids.append(str(boss_spawn.get("reason", "boss_spawn_failed")))
		return "elementalist_control_spawn"

	var valid_target = simulation.debug_card_target_condition("m0_arc_spark", Vector2i(20, 10), player_count, "elementalist")
	if not bool(valid_target.get("ok", false)):
		reject_reason_ids.append(str(valid_target.get("reason", "valid_target_failed")))
		return "elementalist_valid_target_probe"
	facts["valid_target_accepted"] = true

	var play_result = simulation.play_card_at_tile("m0_arc_spark", Vector2i(20, 10), player_count, "elementalist")
	if not bool(play_result.get("ok", false)):
		reject_reason_ids.append(str(play_result.get("reason", "control_card_failed")))
		return "elementalist_control_card"
	_append_events(events, play_result.get("events", []))
	for _index in range(6):
		_append_events(events, simulation.debug_run_enemy_movement())
		if int(simulation.get_run_stats().get("boss_part_slow_waits", 0)) > 0:
			break

	facts["control_effect_applied"] = int(simulation.get_run_stats().get("boss_part_slow_waits", 0)) > 0
	if not bool(facts.get("control_effect_applied", false)):
		reject_reason_ids.append("control_effect_missing")
		return "elementalist_control_effect"

	return ""


func _run_tinkerer_script(
	simulation,
	player_count: int,
	events: Array[String],
	reject_reason_ids: Array[String],
	facts: Dictionary
) -> String:
	var hand_result = simulation.debug_set_hand(["m0_field_patch", "m0_tower_permit", "m0_barricade_kit"])
	if not bool(hand_result.get("ok", false)):
		reject_reason_ids.append(str(hand_result.get("reason", "hand_failed")))
		return "tinkerer_fixed_hand"

	var aura_tower_result = simulation.place_structure(Vector2i(15, 10), "tower", player_count, "tinkerer")
	if not bool(aura_tower_result.get("ok", false)):
		reject_reason_ids.append(str(aura_tower_result.get("reason", "aura_tower_failed")))
		return "tinkerer_aura_tower"

	var aura_spawn = simulation.debug_spawn_enemy(Vector2i(18, 10), 6, "east", "m0_walker")
	if not bool(aura_spawn.get("ok", false)):
		reject_reason_ids.append(str(aura_spawn.get("reason", "aura_spawn_failed")))
		return "tinkerer_aura_spawn"

	_append_events(events, simulation.debug_run_tower_attack())
	var repair_tower_result = simulation.place_structure(Vector2i(18, 11), "tower", player_count, "tinkerer")
	if not bool(repair_tower_result.get("ok", false)):
		reject_reason_ids.append(str(repair_tower_result.get("reason", "repair_tower_failed")))
		return "tinkerer_repair_tower"

	var repair_spawn = simulation.debug_spawn_enemy(Vector2i(19, 11), 6, "east", "m0_walker")
	if not bool(repair_spawn.get("ok", false)):
		reject_reason_ids.append(str(repair_spawn.get("reason", "repair_spawn_failed")))
		return "tinkerer_repair_spawn"

	_append_events(events, simulation.debug_run_enemy_movement())
	_append_events(events, simulation.debug_refill_round_resources(player_count))
	var invalid_target = simulation.debug_card_target_condition("m0_field_patch", Vector2i(0, 0), player_count, "tinkerer")
	if ["no_structure", "structure_not_damaged"].has(str(invalid_target.get("reason", ""))):
		facts["invalid_target_rejected"] = true
		reject_reason_ids.append(str(invalid_target.get("reason", "")))
	else:
		reject_reason_ids.append(str(invalid_target.get("reason", "invalid_target_probe_failed")))
		return "tinkerer_invalid_target_probe"

	return ""


func _case_result(
	class_id: String,
	player_count: int,
	stats: Dictionary,
	observed_signal_ids: Array,
	failed_step_id: String,
	reject_reason_ids: Array,
	missing_signal_ids: Array,
	facts: Dictionary,
	events: Array = [],
	active_directions: Array = [],
	reward_recommendation: Dictionary = {},
	artifact_recommendation: Dictionary = {},
	shop_recommendation: Dictionary = {}
) -> Dictionary:
	var required_signals = required_signal_ids(class_id)
	var passed = failed_step_id.is_empty() and missing_signal_ids.is_empty()
	var recommendations = {
		"reward": reward_recommendation.duplicate(true),
		"artifact": artifact_recommendation.duplicate(true),
		"shop": shop_recommendation.duplicate(true),
	}
	return {
		"coverageRunId": "m0_alpha_%s_%sp" % [class_id, player_count],
		"coverageScenarioId": "m0_alpha_coverage_fixed_map",
		"classId": class_id,
		"classLabel": _class_label(class_id),
		"playerCount": player_count,
		"fixedMapId": "m0_test_data_21x21",
		"fixedHandProfileId": "%s_starting_and_core" % class_id,
		"fixedWaveProfileId": "m0_basic_trait_probe",
		"scriptedInputProfileId": "%s_%sp_script" % [class_id, player_count],
		"activeDirections": active_directions.duplicate(),
		"passed": passed,
		"failedStepId": failed_step_id,
		"requiredSignalIds": required_signals,
		"observedSignalIds": observed_signal_ids.duplicate(),
		"missingSignalIds": missing_signal_ids.duplicate(),
		"rejectReasonIds": _unique_strings(reject_reason_ids),
		"stats": stats,
		"facts": facts.duplicate(true),
		"events": _event_sample(events),
		"rewardRecommendation": reward_recommendation.duplicate(true),
		"artifactRecommendation": artifact_recommendation.duplicate(true),
		"shopRecommendation": shop_recommendation.duplicate(true),
		"recommendations": recommendations,
		"judgementScope": "functionality_only",
		"summary": _format_signal_summary(observed_signal_ids, required_signals, missing_signal_ids),
	}


func _alpha_reward_recommendation_snapshot(simulation, player_count: int, class_id: String) -> Dictionary:
	var offer = simulation.debug_generate_reward_offer(1)
	var report: Dictionary = simulation.get_reward_recommendation_report(player_count, class_id)
	var offered_card_ids = []
	for card_id in offer:
		offered_card_ids.append(str(card_id))

	return {
		"ok": bool(report.get("ok", false)),
		"choice_type": str(report.get("choice_type", "none")),
		"card_id": str(report.get("card_id", "")),
		"label": str(report.get("label", "")),
		"score": int(report.get("score", 0)),
		"reason_text": str(report.get("reason_text", "")),
		"detail_text": str(report.get("detail_text", "")),
		"summary": str(report.get("summary", "Reward recommendation: none")),
		"offer_count": offered_card_ids.size(),
		"offered_card_ids": offered_card_ids,
	}


func _alpha_artifact_recommendation_snapshot(simulation, player_count: int) -> Dictionary:
	simulation.debug_generate_artifact_offer()
	var offer = simulation.get_artifact_offer()
	var report: Dictionary = simulation.get_artifact_recommendation_report()
	var offered_artifact_ids = []
	for artifact_id in offer:
		offered_artifact_ids.append(str(artifact_id))

	var claim_report: Dictionary = {}
	var preparation_report: Dictionary = {}
	var preparation_summary = ""
	var chosen_artifact_id = str(report.get("artifact_id", ""))
	if bool(report.get("ok", false)) and not chosen_artifact_id.is_empty():
		claim_report = simulation.claim_artifact(chosen_artifact_id)
		if bool(claim_report.get("ok", false)):
			preparation_report = simulation.get_artifact_to_wave_preparation_report(player_count)
			preparation_summary = str(preparation_report.get("summary", ""))

	return {
		"ok": bool(report.get("ok", false)),
		"choice_type": "artifact" if bool(report.get("ok", false)) else "none",
		"artifact_id": str(report.get("artifact_id", "")),
		"label": str(report.get("label", "")),
		"score": int(report.get("score", 0)),
		"reason_text": str(report.get("reason_text", "")),
		"detail_text": str(report.get("detail_text", "")),
		"summary": str(report.get("summary", "Artifact recommendation: none")),
		"offer_count": offered_artifact_ids.size(),
		"offered_artifact_ids": offered_artifact_ids,
		"claim_ok": bool(claim_report.get("ok", false)),
		"claim_reason": str(claim_report.get("reason", "")),
		"preparation_summary": preparation_summary,
		"preparation_report": preparation_report.duplicate(true),
	}


func _alpha_shop_recommendation_snapshot(simulation, player_count: int, class_id: String) -> Dictionary:
	if not simulation.get_reward_offer().is_empty():
		var reward_report: Dictionary = simulation.get_reward_recommendation_report(player_count, class_id)
		if bool(reward_report.get("ok", false)) and str(reward_report.get("choice_type", "none")) == "card":
			simulation.claim_reward_card(str(reward_report.get("card_id", "")))
		else:
			simulation.skip_reward_offer()

	if not simulation.get_artifact_offer().is_empty():
		simulation.skip_artifact_offer()

	simulation.debug_set_gold(simulation.get_shop_deck_removal_gold_cost())
	simulation.debug_generate_shop_offer(10)
	var offer = simulation.get_shop_offer()
	var report: Dictionary = simulation.get_shop_recommendation_report(player_count, class_id)
	var offered_card_ids = []
	for card_id in offer:
		offered_card_ids.append(str(card_id))

	return {
		"ok": bool(report.get("ok", false)),
		"choice_type": "shop" if bool(report.get("ok", false)) else "none",
		"card_id": str(report.get("card_id", "")),
		"label": str(report.get("label", "")),
		"score": int(report.get("score", 0)),
		"reason_text": str(report.get("reason_text", "")),
		"detail_text": str(report.get("detail_text", "")),
		"summary": str(report.get("summary", "Shop recommendation: none")),
		"offer_count": offered_card_ids.size(),
		"offered_card_ids": offered_card_ids,
	}


func _observed_signal_ids(class_id: String, stats: Dictionary, facts: Dictionary) -> Array[String]:
	var observed: Array[String] = []
	for signal_id_value in required_signal_ids(class_id):
		var signal_id = str(signal_id_value)
		if _signal_observed(signal_id, class_id, stats, facts):
			observed.append(signal_id)

	return observed


func _signal_observed(signal_id: String, class_id: String, stats: Dictionary, facts: Dictionary) -> bool:
	match signal_id:
		"taunt_applied":
			return int(stats.get("class_taunt_hits", 0)) > 0
		"guardian_hit_received":
			return class_id == "guardian" and int(stats.get("structure_hits", 0)) > 0
		"thorns_or_guard_log":
			return int(stats.get("class_thorns_damage", 0)) > 0 or int(stats.get("class_taunt_hits", 0)) > 0
		"path_changed":
			return bool(facts.get("path_changed", false))
		"full_block_rejected":
			return bool(facts.get("full_block_rejected", false))
		"barricade_break_or_debris_log":
			return int(stats.get("class_explosion_damage", 0)) > 0 or int(stats.get("planned_collapses", 0)) > 0
		"splash_damage_applied":
			return int(stats.get("class_splash_damage", 0)) > 0
		"control_effect_applied":
			return bool(facts.get("control_effect_applied", false)) or int(stats.get("boss_part_slow_waits", 0)) > 0
		"invalid_target_rejected":
			return bool(facts.get("invalid_target_rejected", false))
		"aura_applied":
			return int(stats.get("class_aura_damage", 0)) > 0
		"repair_or_boost_applied":
			return int(stats.get("class_repairs", 0)) > 0 or int(stats.get("class_aura_damage", 0)) > 0
		_:
			return false


func _missing_signal_ids(required_signals: Array, observed_signals: Array[String]) -> Array[String]:
	var missing: Array[String] = []
	for signal_id_value in required_signals:
		var signal_id = str(signal_id_value)
		if not observed_signals.has(signal_id):
			missing.append(signal_id)

	return missing


func _validate_direction_projection(simulation, player_count: int, reject_reason_ids: Array[String]) -> String:
	var actual = simulation.get_active_directions(player_count)
	var expected: Array = EXPECTED_DIRECTIONS.get(player_count, [])
	if actual != expected:
		reject_reason_ids.append("direction_projection_mismatch")
		return "direction_projection"

	for direction in ["west", "north", "east", "south"]:
		if expected.has(direction):
			continue
		if actual.has(direction):
			reject_reason_ids.append("inactive_direction_enabled_%s" % direction)
			return "inactive_direction_projection"

	return ""


func _run_full_block_probe(simulation, player_count: int, class_id: String) -> Dictionary:
	var final_tile = Vector2i(8, 10)
	for tile in _base_ring_tiles():
		if tile == final_tile:
			continue

		var result = simulation.debug_place_structure(tile, "barricade", class_id)
		if not bool(result.get("ok", false)) and str(result.get("reason", "")) != "tile_occupied":
			return {
				"ok": false,
				"reason": str(result.get("reason", "ring_seed_failed")),
			}

	var full_block_result = simulation.can_place_structure(final_tile, "barricade", player_count, class_id)
	var reason = str(full_block_result.get("reason", ""))
	return {
		"ok": reason.begins_with("would_fully_block"),
		"reason": reason,
	}


func _base_ring_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for y in range(8, 13):
		for x in range(8, 13):
			if x >= 9 and x <= 11 and y >= 9 and y <= 11:
				continue

			tiles.append(Vector2i(x, y))

	return tiles


func _path_signature(simulation, player_count: int) -> String:
	var paths: Dictionary = simulation.get_path_cells_by_direction(player_count)
	var parts = []
	for direction_value in simulation.get_active_directions(player_count):
		var direction = str(direction_value)
		var path: Array = paths.get(direction, [])
		var tile_parts: Array[String] = []
		for tile_value in path:
			if typeof(tile_value) == TYPE_VECTOR2I:
				tile_parts.append(_tile_key(tile_value))

		parts.append("%s:%s" % [direction, ">".join(tile_parts)])

	return "|".join(parts)


func _aggregate(cases: Array) -> Dictionary:
	var pass_count = 0
	var required_signal_count = 0
	var observed_signal_count = 0
	var missing_signal_ids: Array[String] = []
	var reject_reason_ids: Array[String] = []
	var by_class = {}
	var recommendation_by_choice_type = {}
	var recommendation_by_class = {}
	var recommendation_by_player_count = {}
	var recommendation_by_front = {}
	var recommendation_contrast_samples: Array = []

	for case_value in cases:
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_result: Dictionary = case_value
		if bool(case_result.get("passed", false)):
			pass_count += 1

		var required_signals: Array = case_result.get("requiredSignalIds", [])
		var observed_signals: Array = case_result.get("observedSignalIds", [])
		required_signal_count += required_signals.size()
		observed_signal_count += observed_signals.size()
		missing_signal_ids.append_array(_string_values(case_result.get("missingSignalIds", [])))
		reject_reason_ids.append_array(_string_values(case_result.get("rejectReasonIds", [])))

		var class_id = str(case_result.get("classId", "unknown"))
		var class_entry: Dictionary = by_class.get(class_id, {
			"case_count": 0,
			"pass_count": 0,
			"missing_signal_ids": [],
		})
		class_entry["case_count"] = int(class_entry.get("case_count", 0)) + 1
		if bool(case_result.get("passed", false)):
			class_entry["pass_count"] = int(class_entry.get("pass_count", 0)) + 1
		var class_missing: Array = class_entry.get("missing_signal_ids", [])
		class_missing.append_array(_string_values(case_result.get("missingSignalIds", [])))
		class_entry["missing_signal_ids"] = _unique_strings(class_missing)
		by_class[class_id] = class_entry
		for recommendation_value in _recommendation_values_for_case(case_result):
			_add_recommendation_choice_type(recommendation_by_choice_type, recommendation_value)
			_add_recommendation_group(recommendation_by_class, class_id, _class_label(class_id), recommendation_value)
			var player_key = "%sP" % int(case_result.get("playerCount", 0))
			_add_recommendation_group(recommendation_by_player_count, player_key, player_key, recommendation_value)
			var front_key = _front_text(_string_values(case_result.get("activeDirections", [])))
			_add_recommendation_group(recommendation_by_front, front_key, front_key, recommendation_value)
		_append_recommendation_contrast_samples_for_case(recommendation_contrast_samples, case_result)

	var recommendation_focus = _recommendation_focus_report(
		recommendation_by_choice_type,
		recommendation_by_class,
		recommendation_by_player_count,
		recommendation_by_front
	)
	return {
		"case_count": cases.size(),
		"pass_count": pass_count,
		"fail_count": cases.size() - pass_count,
		"required_signal_count": required_signal_count,
		"observed_signal_count": observed_signal_count,
		"missing_signal_ids": _unique_strings(missing_signal_ids),
		"reject_reason_ids": _unique_strings(reject_reason_ids),
		"by_class": by_class,
		"recommendation_by_choice_type": recommendation_by_choice_type,
		"recommendation_by_class": recommendation_by_class,
		"recommendation_by_player_count": recommendation_by_player_count,
		"recommendation_by_front": recommendation_by_front,
		"recommendation_focus": recommendation_focus,
		"recommendation_choice_summary": _format_recommendation_choice_summary(recommendation_by_choice_type),
		"recommendation_class_summary": _format_recommendation_group_summary(recommendation_by_class, CLASS_IDS),
		"recommendation_party_summary": _format_recommendation_group_summary(recommendation_by_player_count, ["1P", "2P", "3P", "4P"]),
		"recommendation_front_summary": _format_recommendation_group_summary(recommendation_by_front, [
			"east",
			"north/east",
			"west/north/east",
			"west/north/east/south",
		]),
		"recommendation_focus_summary": _format_recommendation_focus_summary(recommendation_focus),
		"recommendation_contrast_samples": recommendation_contrast_samples.duplicate(true),
		"recommendation_contrast_sample_count": recommendation_contrast_samples.size(),
		"scope": "functionality_only",
	}


func _recommendation_values_for_case(case_result: Dictionary) -> Array:
	var values = []
	var recommendations_value = case_result.get("recommendations", {})
	if typeof(recommendations_value) == TYPE_DICTIONARY:
		var recommendations: Dictionary = recommendations_value
		for key in ["reward", "artifact", "shop"]:
			var recommendation_value = recommendations.get(key, {})
			if typeof(recommendation_value) == TYPE_DICTIONARY:
				values.append(recommendation_value)

	if values.is_empty():
		for key in ["rewardRecommendation", "artifactRecommendation", "shopRecommendation"]:
			var recommendation_value = case_result.get(key, {})
			if typeof(recommendation_value) == TYPE_DICTIONARY:
				values.append(recommendation_value)

	return values


func _recommendations_dictionary_for_case(case_result: Dictionary) -> Dictionary:
	var result = {}
	var recommendations_value = case_result.get("recommendations", {})
	if typeof(recommendations_value) == TYPE_DICTIONARY:
		var recommendations: Dictionary = recommendations_value
		for key in ["reward", "artifact", "shop"]:
			var recommendation_value = recommendations.get(key, {})
			if typeof(recommendation_value) == TYPE_DICTIONARY:
				result[key] = recommendation_value

	for fallback_pair in [
		["reward", "rewardRecommendation"],
		["artifact", "artifactRecommendation"],
		["shop", "shopRecommendation"],
	]:
		var result_key = str(fallback_pair[0])
		if result.has(result_key):
			continue

		var recommendation_value = case_result.get(str(fallback_pair[1]), {})
		if typeof(recommendation_value) == TYPE_DICTIONARY:
			result[result_key] = recommendation_value

	return result


func _add_recommendation_group(grouped: Dictionary, group_key: String, group_label: String, recommendation_value) -> void:
	if group_key.is_empty():
		group_key = "unknown"
	if group_label.is_empty():
		group_label = group_key

	var entry: Dictionary = grouped.get(group_key, {
		"label": group_label,
		"cases": 0,
		"by_choice_type": {},
	})
	entry["label"] = group_label
	entry["cases"] = int(entry.get("cases", 0)) + 1
	var by_choice_type: Dictionary = entry.get("by_choice_type", {})
	_add_recommendation_choice_type(by_choice_type, recommendation_value)
	entry["by_choice_type"] = by_choice_type
	grouped[group_key] = entry


func _add_recommendation_choice_type(by_choice_type: Dictionary, recommendation_value) -> void:
	if typeof(recommendation_value) != TYPE_DICTIONARY:
		return

	var recommendation: Dictionary = recommendation_value
	var choice_type = str(recommendation.get("choice_type", "none"))
	if choice_type.is_empty():
		choice_type = "none"

	var entry: Dictionary = by_choice_type.get(choice_type, {
		"cases": 0,
		"ok": 0,
		"labels": {},
	})
	entry["cases"] = int(entry.get("cases", 0)) + 1
	if bool(recommendation.get("ok", false)):
		entry["ok"] = int(entry.get("ok", 0)) + 1

	var label = str(recommendation.get("label", ""))
	if label.is_empty():
		label = choice_type
	var labels: Dictionary = entry.get("labels", {})
	labels[label] = int(labels.get(label, 0)) + 1
	entry["labels"] = labels
	by_choice_type[choice_type] = entry


func _format_recommendation_choice_summary(by_choice_type: Dictionary) -> String:
	if by_choice_type.is_empty():
		return "none"

	var parts = []
	for choice_type in _sorted_recommendation_choice_keys(by_choice_type):
		var entry: Dictionary = by_choice_type.get(choice_type, {})
		parts.append("%s %s cases%s" % [
			choice_type,
			entry.get("cases", 0),
			_format_recommendation_label_sample(entry.get("labels", {})),
		])

	return ", ".join(parts)


func _format_recommendation_group_summary(grouped: Dictionary, preferred_order: Array) -> String:
	if grouped.is_empty():
		return "none"

	var parts = []
	for group_key in _sorted_group_keys(grouped, preferred_order):
		var entry: Dictionary = grouped.get(group_key, {})
		parts.append("%s %s" % [
			entry.get("label", group_key),
			_format_recommendation_choice_count_summary(entry.get("by_choice_type", {})),
		])

	return "; ".join(parts)


func _recommendation_focus_report(
	by_choice_type: Dictionary,
	by_class: Dictionary,
	by_player_count: Dictionary,
	by_front: Dictionary
) -> Dictionary:
	var top_choice = _top_recommendation_choice_entry(by_choice_type)
	if top_choice.is_empty():
		return {}

	return {
		"ok": true,
		"total_cases": _recommendation_case_total(by_choice_type),
		"choice_type": str(top_choice.get("choice_type", "none")),
		"choice_cases": int(top_choice.get("cases", 0)),
		"choice_label_sample": str(top_choice.get("label_sample", "")),
		"top_class": _top_recommendation_group_entry(by_class, CLASS_IDS),
		"top_party": _top_recommendation_group_entry(by_player_count, ["1P", "2P", "3P", "4P"]),
		"top_front": _top_recommendation_group_entry(by_front, [
			"east",
			"north/east",
			"west/north/east",
			"west/north/east/south",
		]),
	}


func _format_recommendation_focus_summary(report: Dictionary) -> String:
	if report.is_empty():
		return "none"

	var label_sample = str(report.get("choice_label_sample", ""))
	var label_text = "" if label_sample.is_empty() else " %s" % label_sample
	return "choice %s %s/%s cases%s | class %s | party %s | front %s | human check: choice ownership" % [
		report.get("choice_type", "none"),
		report.get("choice_cases", 0),
		report.get("total_cases", 0),
		label_text,
		_format_recommendation_focus_group(report.get("top_class", {})),
		_format_recommendation_focus_group(report.get("top_party", {})),
		_format_recommendation_focus_group(report.get("top_front", {})),
	]


func _top_recommendation_choice_entry(by_choice_type: Dictionary) -> Dictionary:
	if by_choice_type.is_empty():
		return {}

	var best_key = ""
	var best_cases = -1
	var best_labels = {}
	for key_value in _sorted_recommendation_choice_keys(by_choice_type):
		var key = str(key_value)
		var entry: Dictionary = by_choice_type.get(key, {})
		var cases = int(entry.get("cases", 0))
		if best_key.is_empty() or cases > best_cases:
			best_key = key
			best_cases = cases
			best_labels = entry.get("labels", {})

	if best_key.is_empty():
		return {}

	return {
		"choice_type": best_key,
		"cases": best_cases,
		"label_sample": _format_recommendation_label_sample(best_labels),
	}


func _top_recommendation_group_entry(grouped: Dictionary, preferred_order: Array) -> Dictionary:
	if grouped.is_empty():
		return {}

	var best_key = ""
	var best_label = ""
	var best_cases = -1
	var best_choice_summary = ""
	for key_value in _sorted_group_keys(grouped, preferred_order):
		var key = str(key_value)
		var entry: Dictionary = grouped.get(key, {})
		var cases = int(entry.get("cases", 0))
		if best_key.is_empty() or cases > best_cases:
			best_key = key
			best_label = str(entry.get("label", key))
			best_cases = cases
			best_choice_summary = _format_recommendation_choice_count_summary(entry.get("by_choice_type", {}))

	if best_key.is_empty():
		return {}

	return {
		"key": best_key,
		"label": best_label,
		"cases": best_cases,
		"choice_summary": best_choice_summary,
	}


func _format_recommendation_focus_group(group_value) -> String:
	if typeof(group_value) != TYPE_DICTIONARY:
		return "none"

	var group: Dictionary = group_value
	if group.is_empty():
		return "none"

	return "%s %s cases (%s)" % [
		group.get("label", "group"),
		group.get("cases", 0),
		group.get("choice_summary", "none"),
	]


func _recommendation_case_total(by_choice_type: Dictionary) -> int:
	var total = 0
	for entry_value in by_choice_type.values():
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		total += int(entry.get("cases", 0))

	return total


func _format_recommendation_choice_count_summary(by_choice_type_value) -> String:
	if typeof(by_choice_type_value) != TYPE_DICTIONARY:
		return "none"

	var by_choice_type: Dictionary = by_choice_type_value
	if by_choice_type.is_empty():
		return "none"

	var parts = []
	for choice_type in _sorted_recommendation_choice_keys(by_choice_type):
		var entry: Dictionary = by_choice_type.get(choice_type, {})
		parts.append("%s %s cases" % [choice_type, entry.get("cases", 0)])

	return ", ".join(parts)


func _sorted_group_keys(grouped: Dictionary, preferred_order: Array) -> Array:
	var result = []
	for preferred_value in preferred_order:
		var preferred_key = str(preferred_value)
		if grouped.has(preferred_key):
			result.append(preferred_key)

	var remaining = []
	for key_value in grouped.keys():
		var key = str(key_value)
		if not result.has(key):
			remaining.append(key)
	remaining.sort()
	result.append_array(remaining)
	return result


func _format_recommendation_label_sample(label_counts_value) -> String:
	if typeof(label_counts_value) != TYPE_DICTIONARY:
		return ""

	var label_counts: Dictionary = label_counts_value
	if label_counts.is_empty():
		return ""

	var parts: Array[String] = []
	for label in _sorted_recommendation_choice_keys(label_counts):
		parts.append("%s x%s" % [label, label_counts.get(label, 0)])
		if parts.size() >= 2:
			break

	return " (%s)" % ", ".join(parts)


func _sorted_recommendation_choice_keys(dictionary: Dictionary) -> Array:
	var preferred_order = ["card", "gold", "artifact", "shop", "none", "other"]
	var result = []
	for preferred_key in preferred_order:
		if dictionary.has(preferred_key):
			result.append(preferred_key)

	var remaining = []
	for key_value in dictionary.keys():
		var key = str(key_value)
		if not result.has(key):
			remaining.append(key)
	remaining.sort()
	result.append_array(remaining)
	return result


func _build_human_review_queue(cases: Array) -> Array:
	var queue: Array = []
	for case_value in cases:
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_result: Dictionary = case_value
		queue.append(_build_human_review_entry(case_result))

	queue.sort_custom(_human_review_entry_is_before)
	for index in range(queue.size()):
		var entry_value = queue[index]
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		entry["rank"] = index + 1
		queue[index] = entry

	return queue


func _build_human_review_entry(case_result: Dictionary) -> Dictionary:
	var class_id = str(case_result.get("classId", ""))
	var player_count = int(case_result.get("playerCount", 0))
	var active_directions = _string_values(case_result.get("activeDirections", []))
	var direction = "" if active_directions.is_empty() else str(active_directions[0])
	var passed = bool(case_result.get("passed", false))
	var required_signals = _string_values(case_result.get("requiredSignalIds", []))
	var observed_signals = _string_values(case_result.get("observedSignalIds", []))
	var missing_signals = _string_values(case_result.get("missingSignalIds", []))
	var reward_recommendation: Dictionary = case_result.get("rewardRecommendation", {})
	var recommendations = _recommendations_dictionary_for_case(case_result)
	var recommendation_set_summary = _recommendation_set_review_text(recommendations)
	var artifact_recommendation: Dictionary = case_result.get("artifactRecommendation", {})
	var artifact_preparation_summary = _artifact_preparation_review_text(artifact_recommendation)
	var review_priority = _human_review_priority_report(
		class_id,
		player_count,
		passed,
		missing_signals,
		active_directions,
		recommendations
	)
	var front_text = _front_text(active_directions)
	var signal_text = "%s/%s signals" % [observed_signals.size(), required_signals.size()]
	var status_text = "PASS" if passed else "FAIL"
	var evidence = "%s, %s, fronts %s" % [status_text, signal_text, front_text]
	if not passed:
		evidence = "%s, missing %s, failed step %s" % [
			status_text,
			_format_id_list(missing_signals),
			case_result.get("failedStepId", "unknown"),
		]

	var next_probe = _human_review_probe_text(class_id, passed, missing_signals)
	var recommendation_focus_summary = _reward_recommendation_focus_text(reward_recommendation, front_text)
	var recommendation_contrast_probe = _reward_recommendation_contrast_probe_text(reward_recommendation, front_text)
	return {
		"rank": 0,
		"class_id": class_id,
		"class_label": case_result.get("classLabel", _class_label(class_id)),
		"player_count": player_count,
		"direction": direction,
		"active_directions": active_directions,
		"primary_signal": "human_alpha_review" if passed else "coverage_failure",
		"evidence": evidence,
		"next_probe": next_probe,
		"completed_rounds": 0,
		"base_hp": 0,
		"coverage_run_id": case_result.get("coverageRunId", ""),
		"coverage_passed": passed,
		"review_priority_score": int(review_priority.get("score", 0)),
		"review_priority_reason": str(review_priority.get("reason", "")),
		"recommendation_choice_type": str(reward_recommendation.get("choice_type", "none")),
		"recommendation_label": str(reward_recommendation.get("label", "")),
		"recommendation_summary": str(reward_recommendation.get("summary", "")),
		"recommendation_reason": str(reward_recommendation.get("reason_text", "")),
		"recommendation_detail": str(reward_recommendation.get("detail_text", "")),
		"recommendations": recommendations.duplicate(true),
		"recommendation_set_summary": recommendation_set_summary,
		"artifact_preparation_summary": artifact_preparation_summary,
		"recommendation_focus_summary": recommendation_focus_summary,
		"recommendation_contrast_probe": recommendation_contrast_probe,
		"required_signal_ids": required_signals,
		"observed_signal_ids": observed_signals,
		"missing_signal_ids": missing_signals,
		"analysis_cards": [
			{
				"title": "Coverage",
				"body": "%s on %sP, fronts %s, %s observed." % [
					status_text,
					player_count,
					front_text,
					signal_text,
				],
			},
			{
				"title": "Human Gate",
				"body": "Function smoke only. Human alpha still checks readability, fun, and table talk.",
			},
			{
				"title": "Review Reason",
				"body": str(review_priority.get("reason", "")),
			},
			{
				"title": "Reward Lens",
				"body": _reward_recommendation_review_text(reward_recommendation),
			},
			{
				"title": "Choice Set",
				"body": recommendation_set_summary,
			},
			{
				"title": "Artifact Prep",
				"body": artifact_preparation_summary,
			},
			{
				"title": "Recommendation Focus",
				"body": recommendation_focus_summary,
			},
			{
				"title": "Recommendation Contrast",
				"body": recommendation_contrast_probe,
			},
			{
				"title": "Next Probe",
				"body": next_probe,
			},
		],
	}


func _build_human_next_action_queue(review_queue: Array) -> Array:
	var action_queue: Array = []
	for entry_value in review_queue:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		var passed = bool(entry.get("coverage_passed", false))
		action_queue.append({
			"rank": int(entry.get("rank", 0)),
			"severity": "watch" if passed else "danger",
			"signal": entry.get("primary_signal", "human_alpha_review"),
			"hypothesis": "%s %sP needs human alpha review after coverage %s." % [
				entry.get("class_label", "Class"),
				entry.get("player_count", 0),
				"PASS" if passed else "FAIL",
			],
			"check": entry.get("next_probe", ""),
			"metric": entry.get("evidence", ""),
			"review_priority_score": int(entry.get("review_priority_score", 0)),
			"review_priority_reason": str(entry.get("review_priority_reason", "")),
			"recommendation_choice_type": str(entry.get("recommendation_choice_type", "none")),
			"recommendation_label": str(entry.get("recommendation_label", "")),
			"recommendation_set_summary": str(entry.get("recommendation_set_summary", "")),
			"artifact_preparation_summary": _artifact_preparation_review_text(_recommendation_from_set(entry.get("recommendations", {}), "artifact")),
			"source": "alpha_coverage_runner",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
			"class_id": entry.get("class_id", ""),
			"class_label": entry.get("class_label", "Class"),
			"player_count": int(entry.get("player_count", 0)),
			"direction": entry.get("direction", ""),
		})

	return action_queue


func _human_review_priority_report(
	class_id: String,
	player_count: int,
	passed: bool,
	missing_signals: Array,
	active_directions: Array,
	recommendations: Dictionary
) -> Dictionary:
	var score = 0
	var reasons = []
	if passed:
		score += 10
		reasons.append("functional pass still needs a human readability check")
	else:
		score += 100
		reasons.append("coverage is missing %s" % _format_id_list(missing_signals))

	if player_count > 1:
		score += 10
		reasons.append("%s fronts must be discussed together" % _front_text(active_directions))
	else:
		score += 4
		reasons.append("solo east translation must stay readable")

	match class_id:
		"guardian":
			score += 8
			reasons.append("taunt ping-pong must read as a deliberate tank choice")
		"architect":
			score += 12
			reasons.append("collapse and debris must read as tactics, not failure")
		"elementalist":
			score += 10
			reasons.append("area damage and control timing must be visible")
		"tinkerer":
			score += 10
			reasons.append("aura and repair timing must be noticeable")

	var reward_recommendation = _recommendation_from_set(recommendations, "reward")
	var choice_type = str(reward_recommendation.get("choice_type", "none"))
	if not bool(reward_recommendation.get("ok", false)) or choice_type == "none":
		score += 8
		reasons.append("reward recommendation is missing")
	elif choice_type == "gold":
		score += 6
		reasons.append("gold skip wording must not read as a penalty")
	else:
		reasons.append("reward recommendation samples %s" % str(reward_recommendation.get("label", choice_type)))

	var artifact_recommendation = _recommendation_from_set(recommendations, "artifact")
	if not bool(artifact_recommendation.get("ok", false)):
		score += 4
		reasons.append("artifact recommendation is missing")
	else:
		reasons.append("artifact recommendation samples %s" % str(artifact_recommendation.get("label", "artifact")))

	var shop_recommendation = _recommendation_from_set(recommendations, "shop")
	if not bool(shop_recommendation.get("ok", false)):
		score += 4
		reasons.append("shop trim recommendation is missing")
	else:
		reasons.append("shop recommendation samples %s" % str(shop_recommendation.get("label", "shop")))

	return {
		"score": score,
		"reason": "; ".join(reasons),
	}


func _recommendation_from_set(recommendations: Dictionary, key: String) -> Dictionary:
	var recommendation_value = recommendations.get(key, {})
	if typeof(recommendation_value) != TYPE_DICTIONARY:
		return {}

	return recommendation_value


func _recommendation_set_review_text(recommendations: Dictionary) -> String:
	if recommendations.is_empty():
		return "No recommendation samples."

	var parts = []
	parts.append("Reward: %s" % _short_recommendation_review_text(_recommendation_from_set(recommendations, "reward")))
	parts.append("Artifact: %s" % _short_recommendation_review_text(_recommendation_from_set(recommendations, "artifact")))
	parts.append("Shop: %s" % _short_recommendation_review_text(_recommendation_from_set(recommendations, "shop")))
	return " | ".join(parts)


func _short_recommendation_review_text(recommendation: Dictionary) -> String:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return "none"

	var choice_type = str(recommendation.get("choice_type", "none"))
	var label = str(recommendation.get("label", choice_type))
	var reason = str(recommendation.get("reason_text", ""))
	if label.is_empty():
		label = choice_type
	if reason.is_empty():
		return "%s %s" % [choice_type, label]

	return "%s %s - %s" % [choice_type, label, reason]


func _artifact_preparation_review_text(recommendation: Dictionary) -> String:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return "No artifact preparation sample."

	var summary = str(recommendation.get("preparation_summary", ""))
	if not summary.is_empty():
		return "%s Human check: did the passive change the next setup conversation?" % summary

	var label = str(recommendation.get("label", recommendation.get("artifact_id", "artifact")))
	if bool(recommendation.get("claim_ok", false)):
		return "Artifact %s equipped. Human check: did the passive change the next setup conversation?" % label

	return "Artifact %s sampled but not equipped in coverage. Human check: verify the next-wave prep memo manually." % label


func _reward_recommendation_review_text(recommendation: Dictionary) -> String:
	if recommendation.is_empty():
		return "No reward recommendation sample."

	var choice_type = str(recommendation.get("choice_type", "none"))
	var label = str(recommendation.get("label", choice_type))
	var reason = str(recommendation.get("reason_text", ""))
	if label.is_empty():
		label = choice_type
	if reason.is_empty():
		return "%s choice: %s." % [choice_type, label]

	return "%s choice: %s - %s." % [choice_type, label, reason]


func _reward_recommendation_focus_text(recommendation: Dictionary, front_text: String) -> String:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return "No recommendation focus. Human check: choice ownership."

	var choice_type = str(recommendation.get("choice_type", "none"))
	var label = str(recommendation.get("label", choice_type))
	if label.is_empty():
		label = choice_type

	var reason = str(recommendation.get("reason_text", ""))
	var detail = _compact_recommendation_detail(str(recommendation.get("detail_text", "")), 2)
	var parts = PackedStringArray()
	parts.append("%s choice: %s" % [choice_type, label])
	if not reason.is_empty():
		parts.append("Reason: %s" % reason)
	if not detail.is_empty():
		parts.append("Why now: %s" % detail)
	if not front_text.is_empty():
		parts.append("Fronts: %s" % front_text)
	parts.append("Human check: choice ownership")
	return " | ".join(parts)


func _reward_recommendation_contrast_probe_text(recommendation: Dictionary, front_text: String) -> String:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return "Compare any safe card pick with taking gold. Check whether the choice feels owned, not automated."

	var choice_type = str(recommendation.get("choice_type", "none"))
	var label = str(recommendation.get("label", choice_type))
	if label.is_empty():
		label = choice_type

	var front_suffix = "" if front_text.is_empty() else " on %s fronts" % front_text
	if choice_type == "gold":
		return "Run A: take %s. Run B: take the clearest role card instead%s. Check whether gold reads as a normal choice, not a skipped reward." % [
			label,
			front_suffix,
		]
	if choice_type == "card":
		return "Run A: take %s. Run B: take gold or a non-suggested card instead%s. Check whether the recommendation helps discussion without becoming an auto-pick." % [
			label,
			front_suffix,
		]

	return "Run A: follow %s. Run B: choose another safe option%s. Check whether the recommendation supports discussion without replacing it." % [
		label,
		front_suffix,
	]


func _append_recommendation_contrast_samples_for_case(target: Array, case_result: Dictionary) -> void:
	if target.size() >= RECOMMENDATION_CONTRAST_SAMPLE_LIMIT:
		return

	var recommendations = _recommendations_dictionary_for_case(case_result)
	for choice_key in ["reward", "artifact", "shop"]:
		if target.size() >= RECOMMENDATION_CONTRAST_SAMPLE_LIMIT:
			return

		var recommendation = _recommendation_from_set(recommendations, choice_key)
		var sample = _recommendation_contrast_sample_for_case(case_result, choice_key, recommendation)
		if not sample.is_empty():
			target.append(sample)


func _recommendation_contrast_sample_for_case(case_result: Dictionary, choice_key: String, recommendation: Dictionary) -> Dictionary:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return {}

	var active_directions = _string_values(case_result.get("activeDirections", []))
	var direction = "" if active_directions.is_empty() else str(active_directions[0])
	var choice_type = str(recommendation.get("choice_type", choice_key))
	if choice_type.is_empty() or choice_type == "none":
		choice_type = choice_key

	var label = _recommendation_label_for_contrast(choice_key, choice_type, recommendation)
	var run_a = _recommendation_follow_label_for_contrast(choice_key, choice_type, label)
	var run_b = _recommendation_alternate_label_for_contrast(choice_key, choice_type)
	var reason = str(recommendation.get("reason_text", ""))
	var detail = _compact_recommendation_detail(str(recommendation.get("detail_text", "")), 2)
	return {
		"class_id": str(case_result.get("classId", "")),
		"class_label": str(case_result.get("classLabel", _class_label(str(case_result.get("classId", ""))))),
		"player_count": int(case_result.get("playerCount", 0)),
		"direction": direction,
		"active_directions": active_directions,
		"round": 0,
		"action": "alpha_coverage_%s_recommendation" % choice_key,
		"choice_key": choice_key,
		"choice_type": choice_type,
		"followed_recommendation": true,
		"chosen_label": run_a,
		"recommended_label": label,
		"alternate_label": run_b,
		"recommendation_reason": reason,
		"recommendation_detail": detail,
		"prompt": "Run A: %s. Run B: %s. Check whether this stays a table discussion, not an auto-pick." % [
			run_a,
			run_b,
		],
	}


func _recommendation_label_for_contrast(choice_key: String, choice_type: String, recommendation: Dictionary) -> String:
	var label = str(recommendation.get("label", ""))
	if label.is_empty():
		match choice_key:
			"artifact":
				label = str(recommendation.get("artifact_id", ""))
			_:
				label = str(recommendation.get("card_id", ""))
	if label.is_empty():
		label = choice_type
	return label


func _recommendation_follow_label_for_contrast(choice_key: String, choice_type: String, label: String) -> String:
	match choice_key:
		"artifact":
			return "equip %s" % label
		"shop":
			return label if label.to_lower().begins_with("remove ") else "remove %s" % label
		_:
			if choice_type == "gold":
				return label if label.to_lower().begins_with("take ") else "take %s" % label
			return "take %s" % label


func _recommendation_alternate_label_for_contrast(choice_key: String, choice_type: String) -> String:
	match choice_key:
		"artifact":
			return "equip another artifact or skip"
		"shop":
			return "save gold or remove another offered card"
		_:
			if choice_type == "gold":
				return "take the clearest role card"
			return "take gold or a non-suggested card"


func _compact_recommendation_detail(detail_text: String, limit: int) -> String:
	if detail_text.is_empty():
		return ""

	var parts = detail_text.split("|", false)
	if parts.size() <= limit:
		return detail_text

	var compact_parts = PackedStringArray()
	for index in range(min(limit, parts.size())):
		compact_parts.append(str(parts[index]).strip_edges())
	return " | ".join(compact_parts)


func _human_review_entry_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	if bool(left.get("coverage_passed", false)) != bool(right.get("coverage_passed", false)):
		return not bool(left.get("coverage_passed", false))
	if int(left.get("player_count", 0)) != int(right.get("player_count", 0)):
		return int(left.get("player_count", 0)) < int(right.get("player_count", 0))

	return _class_order_index(str(left.get("class_id", ""))) < _class_order_index(str(right.get("class_id", "")))


func _class_order_index(class_id: String) -> int:
	for index in range(CLASS_IDS.size()):
		if str(CLASS_IDS[index]) == class_id:
			return index

	return CLASS_IDS.size()


func _human_review_probe_text(class_id: String, passed: bool, missing_signals: Array) -> String:
	if not passed:
		return "Fix missing coverage signals first: %s." % _format_id_list(missing_signals)

	return str(HUMAN_REVIEW_PROBES.get(class_id, "Replay this class and check whether the player-facing choices are readable."))


func _front_text(active_directions: Array) -> String:
	if active_directions.is_empty():
		return "none"

	return "/".join(_string_values(active_directions))


func _format_case_line(case_result: Dictionary) -> String:
	var status = "PASS" if bool(case_result.get("passed", false)) else "FAIL"
	return "[%s] %s %sP signals %s/%s missing=%s reasons=%s" % [
		status,
		case_result.get("classLabel", case_result.get("classId", "Class")),
		case_result.get("playerCount", 0),
		case_result.get("observedSignalIds", []).size(),
		case_result.get("requiredSignalIds", []).size(),
		_format_id_list(case_result.get("missingSignalIds", [])),
		_format_id_list(case_result.get("rejectReasonIds", [])),
	]


func _format_case_summary(case_result: Dictionary) -> String:
	return "%s %sP %s" % [
		case_result.get("classLabel", case_result.get("classId", "Class")),
		case_result.get("playerCount", 0),
		case_result.get("summary", ""),
	]


func _format_signal_summary(observed_signals: Array, required_signals: Array, missing_signals: Array) -> String:
	return "Coverage Signals: %s/%s observed [%s]; missing [%s]." % [
		observed_signals.size(),
		required_signals.size(),
		_format_id_list(observed_signals),
		_format_id_list(missing_signals),
	]


func _format_id_list(values: Array) -> String:
	if values.is_empty():
		return "none"

	return ", ".join(_string_values(values))


func _event_sample(events: Array, limit: int = 12) -> Array[String]:
	var result: Array[String] = []
	for event_value in events:
		if result.size() >= limit:
			break

		result.append(str(event_value))

	return result


func _append_events(target: Array[String], source: Array) -> void:
	for event_value in source:
		target.append(str(event_value))


func _unique_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text = str(value)
		if text.is_empty() or result.has(text):
			continue

		result.append(text)

	return result


func _string_values(values) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))

	return result


func _class_label(class_id: String) -> String:
	match class_id:
		"guardian":
			return "Guardian"
		"architect":
			return "Architect"
		"elementalist":
			return "Elementalist"
		"tinkerer":
			return "Tinkerer"
		_:
			return class_id


func _tile_key(tile: Vector2i) -> String:
	return "%s,%s" % [tile.x, tile.y]
