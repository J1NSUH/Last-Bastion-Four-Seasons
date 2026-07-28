class_name M0AutoplayRunner
extends RefCounted

const M0CombatSimulationScript = preload("res://scripts/m0/M0CombatSimulation.gd")
const DEFAULT_REPORT_PATH = "user://m0_autoplay_report.json"
const DEFAULT_MARKDOWN_REPORT_PATH = "user://m0_autoplay_report.md"
const REPORT_SCHEMA_VERSION = 1
const LOW_BASE_HP_WARNING = 70
const HIGH_BASE_HIT_WARNING = 20
const CLASS_BASE_HP_SPREAD_WARNING = 20.0

const FALLBACK_CANDIDATES = [
	Vector2i(15, 10),
	Vector2i(14, 10),
	Vector2i(16, 9),
	Vector2i(17, 9),
	Vector2i(18, 10),
	Vector2i(10, 5),
	Vector2i(10, 6),
	Vector2i(9, 4),
	Vector2i(11, 4),
	Vector2i(5, 10),
	Vector2i(6, 10),
	Vector2i(4, 9),
	Vector2i(4, 11),
	Vector2i(10, 15),
	Vector2i(10, 14),
	Vector2i(9, 16),
	Vector2i(11, 16),
	Vector2i(8, 8),
	Vector2i(12, 8),
	Vector2i(8, 12),
	Vector2i(12, 12),
]

var lines: Array = []
var failures: Array = []


func run_all_player_counts() -> Dictionary:
	lines.clear()
	failures.clear()

	var profile_ids = _load_profile_ids()
	var cases: Array = []
	var summary_lines: Array = []

	for profile_id in profile_ids:
		for player_count in range(1, 5):
			var case_result = _run_player_count_case(player_count, str(profile_id))
			cases.append(case_result)
			summary_lines.append(_format_case_summary(case_result))

	return _result(cases, summary_lines)


func run_player_count(player_count: int) -> Dictionary:
	lines.clear()
	failures.clear()

	var profile_ids = _load_profile_ids()
	var cases: Array = []
	var summary_lines: Array = []

	for profile_id in profile_ids:
		var case_result = _run_player_count_case(clamp(player_count, 1, 4), str(profile_id))
		cases.append(case_result)
		summary_lines.append(_format_case_summary(case_result))

	return _result(cases, summary_lines)


func run_class_profile(class_id: String, player_count: int) -> Dictionary:
	lines.clear()
	failures.clear()

	var case_result = _run_player_count_case(clamp(player_count, 1, 4), class_id)
	return _result([case_result], [_format_case_summary(case_result)])


func _result(cases: Array, summary_lines: Array) -> Dictionary:
	var report = _build_report(cases, summary_lines, failures.duplicate())
	return {
		"ok": failures.is_empty(),
		"lines": lines.duplicate(),
		"failures": failures.duplicate(),
		"cases": cases,
		"summary_lines": summary_lines,
		"aggregate": report.get("aggregate", {}),
		"report": report,
	}


func save_report(result: Dictionary, path: String = DEFAULT_REPORT_PATH) -> Dictionary:
	var report: Dictionary = result.get("report", {})
	if report.is_empty():
		report = _build_report(
			result.get("cases", []),
			result.get("summary_lines", []),
			result.get("failures", [])
		)

	var json_text = JSON.stringify(report, "\t")
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"reason": "open_failed",
			"path": path,
			"error": error_string(FileAccess.get_open_error()),
		}

	file.store_string(json_text)
	return {
		"ok": true,
		"reason": "saved",
		"path": path,
		"characters": json_text.length(),
	}


func save_markdown_report(result: Dictionary, path: String = DEFAULT_MARKDOWN_REPORT_PATH) -> Dictionary:
	var markdown_text = build_markdown_report(result)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"reason": "open_failed",
			"path": path,
			"error": error_string(FileAccess.get_open_error()),
		}

	file.store_string(markdown_text)
	return {
		"ok": true,
		"reason": "saved",
		"path": path,
		"characters": markdown_text.length(),
	}


func save_report_bundle(result: Dictionary, label: String) -> Dictionary:
	var json_path = report_path_for_label(label)
	var markdown_path = markdown_report_path_for_label(label)
	var json_result = save_report(result, json_path)
	var markdown_result = save_markdown_report(result, markdown_path)
	return {
		"ok": bool(json_result.get("ok", false)) and bool(markdown_result.get("ok", false)),
		"reason": "saved" if bool(json_result.get("ok", false)) and bool(markdown_result.get("ok", false)) else "save_failed",
		"json": json_result,
		"markdown": markdown_result,
	}


func report_path_for_label(label: String) -> String:
	var normalized = label.to_lower().replace(" ", "_")
	if normalized.is_empty():
		return DEFAULT_REPORT_PATH

	return "user://m0_%s_report.json" % normalized


func markdown_report_path_for_label(label: String) -> String:
	var normalized = label.to_lower().replace(" ", "_")
	if normalized.is_empty():
		return DEFAULT_MARKDOWN_REPORT_PATH

	return "user://m0_%s_report.md" % normalized


func build_markdown_report(result: Dictionary) -> String:
	var report: Dictionary = result.get("report", {})
	if report.is_empty():
		report = _build_report(
			result.get("cases", []),
			result.get("summary_lines", []),
			result.get("failures", [])
		)

	var aggregate: Dictionary = report.get("aggregate", {})
	var lines: Array = []
	lines.append("# M0 Autoplay Report")
	lines.append("")
	lines.append("- Status: %s" % ("PASS" if bool(report.get("ok", false)) else "FAIL"))
	lines.append("- Cases: %s total, %s pass, %s fail" % [
		report.get("case_count", 0),
		report.get("pass_count", 0),
		report.get("fail_count", 0),
	])
	lines.append("- Average completed rounds: %.2f" % float(aggregate.get("average_completed_rounds", 0.0)))
	lines.append("- Average base HP: %.2f" % float(aggregate.get("average_base_hp", 0.0)))
	lines.append("")

	lines.append("## Balance Notes")
	for note in report.get("balance_notes", []):
		lines.append("- %s" % str(note))
	lines.append("")

	_append_bucket_table(lines, "Class Results", aggregate.get("class_results", {}), "Class")
	_append_bucket_table(lines, "Player Count Results", aggregate.get("player_count_results", {}), "Players")
	_append_case_matrix(lines, report.get("case_matrix", {}))
	_append_flagged_cases(lines, report.get("flagged_cases", {}))
	_append_case_snapshot(lines, "Weakest Case", report.get("weakest_case", {}))
	_append_case_snapshot(lines, "Strongest Case", report.get("strongest_case", {}))

	var failures_for_report: Array = report.get("failures", [])
	if not failures_for_report.is_empty():
		lines.append("## Failures")
		for failure in failures_for_report:
			lines.append("- %s" % str(failure))
		lines.append("")

	lines.append("## Case Summaries")
	for summary_line in report.get("summary_lines", []):
		lines.append("- `%s`" % str(summary_line).replace("`", "'"))
	lines.append("")

	return "\n".join(_string_values(lines)) + "\n"


func _load_profile_ids() -> Array:
	var simulation = M0CombatSimulationScript.new()
	if not simulation.load_data():
		return [""]

	var profile_ids = simulation.get_autoplay_class_ids()
	if profile_ids.is_empty():
		return [""]

	return profile_ids


func _run_player_count_case(player_count: int, class_id: String) -> Dictionary:
	var failure_count_before = failures.size()
	var simulation = M0CombatSimulationScript.new()
	var loaded = simulation.load_data()
	var case_name = _case_name(simulation, class_id, player_count)

	_record(loaded, "%s data loads" % case_name)
	if not loaded:
		return _case_result(simulation, player_count, class_id, false)

	case_name = _case_name(simulation, class_id, player_count)

	if not class_id.is_empty():
		var class_exists = not simulation.get_class_data(class_id).is_empty()
		_record(class_exists, "%s class profile exists" % case_name)
		if not class_exists:
			return _case_result(simulation, player_count, class_id, false)

	_record(
		simulation.get_active_directions(player_count).size() == player_count,
		"%s active direction count matches" % case_name
	)

	var target_rounds = simulation.get_autoplay_rounds()
	for round_index in range(target_rounds):
		var display_round = round_index + 1
		_play_some_cards(simulation, player_count, class_id)

		var start_result = simulation.start_wave(player_count)
		_record(bool(start_result["ok"]), "%s round %s starts" % [case_name, display_round])
		if not bool(start_result["ok"]):
			return _case_result(simulation, player_count, class_id, false)

		_play_some_cards(simulation, player_count, class_id)
		var completed = _step_until_round_ends(simulation, player_count)
		_record(completed, "%s round %s ends" % [case_name, display_round])
		if not completed:
			return _case_result(simulation, player_count, class_id, false)

		var has_reward = not simulation.get_reward_offer().is_empty()
		_record(has_reward, "%s round %s offers reward" % [case_name, display_round])
		if not has_reward:
			return _case_result(simulation, player_count, class_id, false)

		var reward_card_id = _choose_reward_card(simulation, class_id)
		var claim_result = simulation.claim_reward_card(reward_card_id)
		_record(bool(claim_result["ok"]), "%s round %s claims reward" % [case_name, display_round])
		if not bool(claim_result["ok"]):
			return _case_result(simulation, player_count, class_id, false)

		if not simulation.get_artifact_offer().is_empty():
			var artifact_id = str(simulation.get_artifact_offer()[0])
			var artifact_result = simulation.claim_artifact(artifact_id)
			_record(bool(artifact_result["ok"]), "%s round %s claims artifact" % [case_name, display_round])
			if not bool(artifact_result["ok"]):
				return _case_result(simulation, player_count, class_id, false)

		if not simulation.get_shop_offer().is_empty():
			var shop_card_id = str(simulation.get_shop_offer()[0])
			var shop_report = simulation.get_card_removal_report(shop_card_id)
			if bool(shop_report.get("can_remove", false)):
				var shop_result = simulation.remove_shop_card(shop_card_id)
				_record(bool(shop_result["ok"]), "%s round %s removes shop card" % [case_name, display_round])
				if not bool(shop_result["ok"]):
					return _case_result(simulation, player_count, class_id, false)
			else:
				var shop_skip_result = simulation.skip_shop_offer()
				_record(bool(shop_skip_result["ok"]), "%s round %s skips unaffordable shop" % [case_name, display_round])
				if not bool(shop_skip_result["ok"]):
					return _case_result(simulation, player_count, class_id, false)

	_record(simulation.get_completed_rounds() == target_rounds, "%s completes target rounds" % case_name)
	_record(int(simulation.get_run_stats().get("rounds_started", 0)) == target_rounds, "%s stats count started rounds" % case_name)
	_record(int(simulation.get_run_stats().get("rounds_completed", 0)) == target_rounds, "%s stats count completed rounds" % case_name)

	return _case_result(simulation, player_count, class_id, failures.size() == failure_count_before)


func _step_until_round_ends(simulation, player_count: int) -> bool:
	for _step_index in range(simulation.get_autoplay_max_steps_per_round()):
		simulation.step_wave(player_count)
		if not simulation.wave_active:
			return simulation.has_pending_reward() or simulation.is_run_complete()

	return false


func _play_some_cards(simulation, player_count: int, class_id: String) -> void:
	var played = 0
	while played < simulation.get_autoplay_cards_per_round():
		if not _play_first_available_card(simulation, player_count, class_id):
			return
		played += 1


func _play_first_available_card(simulation, player_count: int, class_id: String) -> bool:
	for card_id in _ordered_hand(simulation, class_id):
		if not simulation.card_requires_tile(str(card_id)):
			var direct_result = simulation.play_card(str(card_id), class_id)
			if bool(direct_result["ok"]):
				return true

		for tile in _candidate_tiles(simulation, player_count, class_id, str(card_id)):
			var result = simulation.can_play_card_at_tile(str(card_id), tile, player_count, class_id)
			if bool(result["ok"]):
				var play_result = simulation.play_card_at_tile(str(card_id), tile, player_count, class_id)
				return bool(play_result["ok"])

	return false


func _ordered_hand(simulation, class_id: String) -> Array:
	var hand = simulation.get_hand()
	var priority = _card_priority(simulation, class_id)
	var ordered: Array = []
	var used_indexes = {}

	for priority_card_id in priority:
		for index in range(hand.size()):
			if used_indexes.has(index):
				continue
			if str(hand[index]) == str(priority_card_id):
				ordered.append(str(hand[index]))
				used_indexes[index] = true

	for index in range(hand.size()):
		if used_indexes.has(index):
			continue
		ordered.append(str(hand[index]))

	return ordered


func _choose_reward_card(simulation, class_id: String) -> String:
	var offer = simulation.get_reward_offer()
	for priority_card_id in _card_priority(simulation, class_id):
		if offer.has(str(priority_card_id)):
			return str(priority_card_id)

	if offer.is_empty():
		return ""

	return str(offer[0])


func _card_priority(simulation, class_id: String) -> Array:
	var priority: Array = simulation.get_class_autoplay_profile(class_id).get("cardPriority", [])
	var result: Array = []
	for card_id in priority:
		result.append(str(card_id))
	return result


func _candidate_tiles(simulation, player_count: int, class_id: String, card_id: String) -> Array:
	var profile = simulation.get_class_autoplay_profile(class_id)
	var tile_plan = str(profile.get("tilePlan", "killzone"))
	var structure_type = str(simulation.get_card_data(card_id).get("structureType", "tower"))
	var candidates: Array = []

	match tile_plan:
		"guard_line":
			_append_guard_line_candidates(candidates, simulation, player_count, structure_type)
		"maze_grid":
			_append_maze_grid_candidates(candidates, simulation, player_count, structure_type)
		"cluster":
			_append_cluster_candidates(candidates, simulation, structure_type)
		_:
			_append_killzone_candidates(candidates, structure_type)

	candidates.append_array(FALLBACK_CANDIDATES)
	for key in simulation.get_path_cells(player_count).keys():
		var tile = _tile_from_key(str(key))
		if tile != Vector2i(-1, -1):
			candidates.append(tile)

	return _unique_tiles(candidates)


func _append_guard_line_candidates(candidates: Array, simulation, player_count: int, structure_type: String) -> void:
	for direction in simulation.get_active_directions(player_count):
		match str(direction):
			"east":
				if structure_type == "barricade":
					candidates.append_array([Vector2i(18, 10), Vector2i(17, 10), Vector2i(16, 10), Vector2i(18, 9), Vector2i(18, 11)])
				else:
					candidates.append_array([Vector2i(15, 10), Vector2i(16, 9), Vector2i(16, 11), Vector2i(14, 10), Vector2i(17, 9)])
			"north":
				if structure_type == "barricade":
					candidates.append_array([Vector2i(10, 2), Vector2i(10, 3), Vector2i(10, 4), Vector2i(9, 3), Vector2i(11, 3)])
				else:
					candidates.append_array([Vector2i(10, 5), Vector2i(9, 4), Vector2i(11, 4), Vector2i(10, 6), Vector2i(8, 5)])
			"west":
				if structure_type == "barricade":
					candidates.append_array([Vector2i(2, 10), Vector2i(3, 10), Vector2i(4, 10), Vector2i(3, 9), Vector2i(3, 11)])
				else:
					candidates.append_array([Vector2i(5, 10), Vector2i(4, 9), Vector2i(4, 11), Vector2i(6, 10), Vector2i(5, 8)])
			"south":
				if structure_type == "barricade":
					candidates.append_array([Vector2i(10, 18), Vector2i(10, 17), Vector2i(10, 16), Vector2i(9, 17), Vector2i(11, 17)])
				else:
					candidates.append_array([Vector2i(10, 15), Vector2i(9, 16), Vector2i(11, 16), Vector2i(10, 14), Vector2i(12, 15)])


func _append_maze_grid_candidates(candidates: Array, simulation, player_count: int, structure_type: String) -> void:
	for key in simulation.get_path_cells(player_count).keys():
		var tile = _tile_from_key(str(key))
		if tile == Vector2i(-1, -1):
			continue

		if structure_type == "barricade":
			candidates.append(tile)
		else:
			candidates.append(tile + Vector2i(0, -1))
			candidates.append(tile + Vector2i(0, 1))
			candidates.append(tile + Vector2i(-1, 0))
			candidates.append(tile + Vector2i(1, 0))


func _append_killzone_candidates(candidates: Array, structure_type: String) -> void:
	if structure_type == "barricade":
		candidates.append_array([
			Vector2i(12, 10),
			Vector2i(8, 10),
			Vector2i(10, 8),
			Vector2i(10, 12),
			Vector2i(13, 10),
			Vector2i(7, 10),
			Vector2i(10, 7),
			Vector2i(10, 13),
		])
		return

	candidates.append_array([
		Vector2i(15, 10),
		Vector2i(10, 5),
		Vector2i(5, 10),
		Vector2i(10, 15),
		Vector2i(8, 8),
		Vector2i(12, 8),
		Vector2i(8, 12),
		Vector2i(12, 12),
	])


func _append_cluster_candidates(candidates: Array, simulation, structure_type: String) -> void:
	for structure in simulation.get_structure_tiles().values():
		var tile: Vector2i = structure["tile"]
		candidates.append(tile + Vector2i(1, 0))
		candidates.append(tile + Vector2i(-1, 0))
		candidates.append(tile + Vector2i(0, 1))
		candidates.append(tile + Vector2i(0, -1))

	if candidates.is_empty():
		_append_killzone_candidates(candidates, structure_type)


func _unique_tiles(candidates: Array) -> Array:
	var seen = {}
	var result: Array = []

	for tile in candidates:
		if typeof(tile) != TYPE_VECTOR2I:
			continue

		var vector_tile: Vector2i = tile
		var key = _tile_key(vector_tile)
		if seen.has(key):
			continue

		seen[key] = true
		result.append(vector_tile)

	return result


func _tile_from_key(key: String) -> Vector2i:
	var parts = key.split(",")
	if parts.size() < 2:
		return Vector2i(-1, -1)
	return Vector2i(int(parts[0]), int(parts[1]))


func _build_report(cases: Array, summary_lines: Array, failure_lines: Array) -> Dictionary:
	var aggregate = _aggregate_cases(cases)
	var weakest_case = _pick_margin_case(cases, true)
	var strongest_case = _pick_margin_case(cases, false)
	var flagged_cases = _build_flagged_cases(cases)
	return {
		"schema_version": REPORT_SCHEMA_VERSION,
		"generated_at_unix": Time.get_unix_time_from_system(),
		"ok": failure_lines.is_empty(),
		"case_count": cases.size(),
		"pass_count": aggregate.get("pass_count", 0),
		"fail_count": aggregate.get("fail_count", 0),
		"failures": failure_lines.duplicate(),
		"aggregate": aggregate,
		"balance_notes": _build_balance_notes(cases, aggregate, failure_lines, weakest_case, strongest_case, flagged_cases),
		"case_matrix": _build_case_matrix(cases),
		"flagged_cases": flagged_cases,
		"weakest_case": weakest_case,
		"strongest_case": strongest_case,
		"summary_lines": summary_lines.duplicate(),
		"cases": cases.duplicate(true),
	}


func _build_case_matrix(cases: Array) -> Dictionary:
	var matrix = {}
	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		var class_key = str(case_dictionary.get("class_id", "default"))
		if class_key.is_empty():
			class_key = "default"
		var player_key = "%sp" % int(case_dictionary.get("player_count", 0))
		var stats: Dictionary = case_dictionary.get("stats", {})
		var outcome: Dictionary = case_dictionary.get("outcome", {})
		var class_row: Dictionary = matrix.get(class_key, {})
		class_row[player_key] = {
			"ok": bool(case_dictionary.get("ok", false)),
			"class_label": str(case_dictionary.get("class_label", class_key)),
			"completed_rounds": int(case_dictionary.get("completed_rounds", 0)),
			"base_hp": int(case_dictionary.get("base_hp", 0)),
			"focus": str(outcome.get("focus", "unknown")),
			"killed": int(stats.get("killed", 0)),
			"gold_gained": int(stats.get("gold_gained", 0)),
			"shop_cards_removed": int(stats.get("shop_cards_removed", 0)),
		}
		matrix[class_key] = class_row

	return matrix


func _build_flagged_cases(cases: Array) -> Dictionary:
	var zero_kill_cases: Array = []
	var high_leak_cases: Array = []
	var low_base_hp_cases: Array = []

	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		var stats: Dictionary = case_dictionary.get("stats", {})
		var snapshot = _case_snapshot(case_dictionary, _case_margin_score(case_dictionary))
		if int(stats.get("killed", 0)) <= 0:
			zero_kill_cases.append(snapshot)
		if int(stats.get("base_hits", 0)) >= HIGH_BASE_HIT_WARNING:
			high_leak_cases.append(snapshot)
		if int(case_dictionary.get("base_hp", 0)) < LOW_BASE_HP_WARNING:
			low_base_hp_cases.append(snapshot)

	return {
		"zero_kill_cases": zero_kill_cases,
		"high_leak_cases": high_leak_cases,
		"low_base_hp_cases": low_base_hp_cases,
	}


func _build_balance_notes(cases: Array, aggregate: Dictionary, failure_lines: Array, weakest_case: Dictionary, strongest_case: Dictionary, flagged_cases: Dictionary) -> Array[String]:
	var notes: Array[String] = []
	if cases.is_empty():
		notes.append("No autoplay cases ran.")
		return notes

	if not failure_lines.is_empty():
		notes.append("%s failing check(s) need attention before alpha testing." % failure_lines.size())

	if not weakest_case.is_empty():
		notes.append("Lowest margin: %s %sp, completed %s round(s), base HP %s, outcome %s." % [
			weakest_case.get("class_label", "Default"),
			weakest_case.get("player_count", 0),
			weakest_case.get("completed_rounds", 0),
			weakest_case.get("base_hp", 0),
			weakest_case.get("outcome_focus", "unknown"),
		])
		if int(weakest_case.get("base_hp", 0)) < LOW_BASE_HP_WARNING:
			notes.append("Lowest margin is below %s base HP; review its opening tile plan or starting deck." % LOW_BASE_HP_WARNING)

	if not strongest_case.is_empty():
		notes.append("Highest margin: %s %sp, completed %s round(s), base HP %s." % [
			strongest_case.get("class_label", "Default"),
			strongest_case.get("player_count", 0),
			strongest_case.get("completed_rounds", 0),
			strongest_case.get("base_hp", 0),
		])

	var zero_kill_cases: Array = flagged_cases.get("zero_kill_cases", [])
	if not zero_kill_cases.is_empty():
		notes.append("Zero-kill cases found: %s. Check autoplay card priority, tile plan, or early damage access." % _format_case_list(zero_kill_cases))

	var high_leak_cases: Array = flagged_cases.get("high_leak_cases", [])
	if not high_leak_cases.is_empty():
		notes.append("High-leak cases found: %s. These pass but leak too much pressure in early rounds." % _format_case_list(high_leak_cases))

	var class_results: Dictionary = aggregate.get("class_results", {})
	var class_spread = _bucket_average_base_hp_spread(class_results)
	if float(class_spread.get("spread", 0.0)) >= CLASS_BASE_HP_SPREAD_WARNING:
		notes.append("Class spread is %.1f base HP: %s is highest, %s is lowest." % [
			class_spread.get("spread", 0.0),
			class_spread.get("highest_key", "unknown"),
			class_spread.get("lowest_key", "unknown"),
		])

	if notes.is_empty():
		notes.append("No immediate autoplay balance warnings.")

	return notes


func _format_case_list(case_snapshots: Array) -> String:
	var parts = PackedStringArray()
	for case_snapshot in case_snapshots:
		if typeof(case_snapshot) != TYPE_DICTIONARY:
			continue
		var case_dictionary: Dictionary = case_snapshot
		parts.append("%s %sp" % [
			case_dictionary.get("class_label", "Default"),
			case_dictionary.get("player_count", 0),
		])

	if parts.is_empty():
		return "none"

	return ", ".join(parts)


func _bucket_average_base_hp_spread(bucket: Dictionary) -> Dictionary:
	var lowest_key = ""
	var highest_key = ""
	var lowest_value = 0.0
	var highest_value = 0.0
	var first = true

	for key in bucket.keys():
		var entry: Dictionary = bucket.get(key, {})
		var average = float(entry.get("average_base_hp", 0.0))
		if first or average < lowest_value:
			lowest_key = str(key)
			lowest_value = average
		if first or average > highest_value:
			highest_key = str(key)
			highest_value = average
		first = false

	return {
		"lowest_key": lowest_key,
		"lowest_value": lowest_value,
		"highest_key": highest_key,
		"highest_value": highest_value,
		"spread": highest_value - lowest_value if not first else 0.0,
	}


func _pick_margin_case(cases: Array, lowest: bool) -> Dictionary:
	var selected: Dictionary = {}
	var selected_score = 0.0

	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		var score = _case_margin_score(case_dictionary)
		if selected.is_empty() or (lowest and score < selected_score) or ((not lowest) and score > selected_score):
			selected = _case_snapshot(case_dictionary, score)
			selected_score = score

	return selected


func _case_margin_score(case_result: Dictionary) -> float:
	var ok_bonus = 100000.0 if bool(case_result.get("ok", false)) else 0.0
	return ok_bonus + float(case_result.get("completed_rounds", 0)) * 1000.0 + float(case_result.get("base_hp", 0))


func _case_snapshot(case_result: Dictionary, score: float) -> Dictionary:
	var stats: Dictionary = case_result.get("stats", {})
	var outcome: Dictionary = case_result.get("outcome", {})
	return {
		"ok": bool(case_result.get("ok", false)),
		"class_id": str(case_result.get("class_id", "default")),
		"class_label": str(case_result.get("class_label", "Default")),
		"player_count": int(case_result.get("player_count", 0)),
		"completed_rounds": int(case_result.get("completed_rounds", 0)),
		"base_hp": int(case_result.get("base_hp", 0)),
		"outcome_focus": str(outcome.get("focus", "unknown")),
		"killed": int(stats.get("killed", 0)),
		"base_hits": int(stats.get("base_hits", 0)),
		"structures_destroyed": int(stats.get("structures_destroyed", 0)),
		"gold_gained": int(stats.get("gold_gained", 0)),
		"score": score,
	}


func _aggregate_cases(cases: Array) -> Dictionary:
	var aggregate = {
		"case_count": cases.size(),
		"pass_count": 0,
		"fail_count": 0,
		"completed_rounds_total": 0,
		"base_hp_total": 0,
		"average_completed_rounds": 0.0,
		"average_base_hp": 0.0,
		"focus_counts": {},
		"class_results": {},
		"player_count_results": {},
		"stat_totals": {},
	}

	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		var ok = bool(case_dictionary.get("ok", false))
		if ok:
			aggregate["pass_count"] = int(aggregate.get("pass_count", 0)) + 1
		else:
			aggregate["fail_count"] = int(aggregate.get("fail_count", 0)) + 1

		var completed_rounds = int(case_dictionary.get("completed_rounds", 0))
		var base_hp = int(case_dictionary.get("base_hp", 0))
		aggregate["completed_rounds_total"] = int(aggregate.get("completed_rounds_total", 0)) + completed_rounds
		aggregate["base_hp_total"] = int(aggregate.get("base_hp_total", 0)) + base_hp

		var outcome: Dictionary = case_dictionary.get("outcome", {})
		var focus = str(outcome.get("focus", "unknown"))
		var focus_counts: Dictionary = aggregate["focus_counts"]
		_increment_count(focus_counts, focus)
		aggregate["focus_counts"] = focus_counts

		var class_key = str(case_dictionary.get("class_id", "default"))
		if class_key.is_empty():
			class_key = "default"
		var class_results: Dictionary = aggregate["class_results"]
		_add_case_to_bucket(class_results, class_key, case_dictionary)
		aggregate["class_results"] = class_results

		var player_key = str(case_dictionary.get("player_count", 0))
		var player_count_results: Dictionary = aggregate["player_count_results"]
		_add_case_to_bucket(player_count_results, player_key, case_dictionary)
		aggregate["player_count_results"] = player_count_results

		var stat_totals: Dictionary = aggregate["stat_totals"]
		_add_stat_totals(stat_totals, case_dictionary.get("stats", {}))
		aggregate["stat_totals"] = stat_totals

	var case_count = max(1, cases.size())
	aggregate["average_completed_rounds"] = float(aggregate.get("completed_rounds_total", 0)) / float(case_count)
	aggregate["average_base_hp"] = float(aggregate.get("base_hp_total", 0)) / float(case_count)
	return aggregate


func _add_case_to_bucket(bucket: Dictionary, key: String, case_result: Dictionary) -> void:
	var entry: Dictionary = bucket.get(key, {
		"case_count": 0,
		"pass_count": 0,
		"fail_count": 0,
		"completed_rounds_total": 0,
		"base_hp_total": 0,
		"average_completed_rounds": 0.0,
		"average_base_hp": 0.0,
		"focus_counts": {},
	})

	entry["case_count"] = int(entry.get("case_count", 0)) + 1
	if bool(case_result.get("ok", false)):
		entry["pass_count"] = int(entry.get("pass_count", 0)) + 1
	else:
		entry["fail_count"] = int(entry.get("fail_count", 0)) + 1

	entry["completed_rounds_total"] = int(entry.get("completed_rounds_total", 0)) + int(case_result.get("completed_rounds", 0))
	entry["base_hp_total"] = int(entry.get("base_hp_total", 0)) + int(case_result.get("base_hp", 0))
	var entry_case_count = max(1, int(entry.get("case_count", 0)))
	entry["average_completed_rounds"] = float(entry.get("completed_rounds_total", 0)) / float(entry_case_count)
	entry["average_base_hp"] = float(entry.get("base_hp_total", 0)) / float(entry_case_count)

	var outcome: Dictionary = case_result.get("outcome", {})
	var focus_counts: Dictionary = entry.get("focus_counts", {})
	_increment_count(focus_counts, str(outcome.get("focus", "unknown")))
	entry["focus_counts"] = focus_counts
	bucket[key] = entry


func _add_stat_totals(stat_totals: Dictionary, stats: Dictionary) -> void:
	for stat_key in _tracked_stat_keys():
		stat_totals[stat_key] = int(stat_totals.get(stat_key, 0)) + int(stats.get(stat_key, 0))


func _tracked_stat_keys() -> Array[String]:
	return [
		"spawned",
		"killed",
		"base_hits",
		"base_damage",
		"bosses_spawned",
		"bosses_killed",
		"boss_phase_triggers",
		"boss_pulse_damage",
		"boss_siege_triggers",
		"boss_siege_damage",
		"structures_destroyed",
		"cards_played",
		"mana_spent",
		"card_rewards_taken",
		"artifact_rewards_taken",
		"shop_cards_removed",
		"gold_gained",
		"gold_spent",
		"wave_stacks",
		"stack_rejections",
	]


func _append_bucket_table(lines: Array, title: String, bucket: Dictionary, key_label: String) -> void:
	lines.append("## %s" % title)
	if bucket.is_empty():
		lines.append("No data.")
		lines.append("")
		return

	lines.append("| %s | Cases | Pass | Fail | Avg rounds | Avg base HP | Focus |" % key_label)
	lines.append("| --- | ---: | ---: | ---: | ---: | ---: | --- |")
	for key in bucket.keys():
		var entry: Dictionary = bucket.get(key, {})
		lines.append("| %s | %s | %s | %s | %.2f | %.2f | %s |" % [
			_markdown_cell(str(key)),
			entry.get("case_count", 0),
			entry.get("pass_count", 0),
			entry.get("fail_count", 0),
			float(entry.get("average_completed_rounds", 0.0)),
			float(entry.get("average_base_hp", 0.0)),
			_markdown_cell(_format_counts(entry.get("focus_counts", {}))),
		])
	lines.append("")


func _append_case_matrix(lines: Array, matrix: Dictionary) -> void:
	lines.append("## Case Matrix")
	if matrix.is_empty():
		lines.append("No data.")
		lines.append("")
		return

	lines.append("| Class | 1p | 2p | 3p | 4p |")
	lines.append("| --- | --- | --- | --- | --- |")
	for class_key in matrix.keys():
		var row: Dictionary = matrix.get(class_key, {})
		lines.append("| %s | %s | %s | %s | %s |" % [
			_markdown_cell(_matrix_class_label(class_key, row)),
			_markdown_cell(_format_matrix_cell(row.get("1p", {}))),
			_markdown_cell(_format_matrix_cell(row.get("2p", {}))),
			_markdown_cell(_format_matrix_cell(row.get("3p", {}))),
			_markdown_cell(_format_matrix_cell(row.get("4p", {}))),
		])
	lines.append("")


func _append_flagged_cases(lines: Array, flagged_cases: Dictionary) -> void:
	lines.append("## Flagged Cases")
	if flagged_cases.is_empty():
		lines.append("No flagged cases.")
		lines.append("")
		return

	var rows: Array = []
	_append_flagged_case_rows(rows, "Zero kills", flagged_cases.get("zero_kill_cases", []))
	_append_flagged_case_rows(rows, "High leaks", flagged_cases.get("high_leak_cases", []))
	_append_flagged_case_rows(rows, "Low base HP", flagged_cases.get("low_base_hp_cases", []))
	if rows.is_empty():
		lines.append("No flagged cases.")
		lines.append("")
		return

	lines.append("| Flag | Case | Base HP | Kills | Base hits | Structures lost |")
	lines.append("| --- | --- | ---: | ---: | ---: | ---: |")
	for row in rows:
		lines.append(str(row))
	lines.append("")


func _append_flagged_case_rows(rows: Array, flag_label: String, case_snapshots: Array) -> void:
	for case_snapshot in case_snapshots:
		if typeof(case_snapshot) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_snapshot
		rows.append("| %s | %s %sp | %s | %s | %s | %s |" % [
			_markdown_cell(flag_label),
			_markdown_cell(str(case_dictionary.get("class_label", "Default"))),
			case_dictionary.get("player_count", 0),
			case_dictionary.get("base_hp", 0),
			case_dictionary.get("killed", 0),
			case_dictionary.get("base_hits", 0),
			case_dictionary.get("structures_destroyed", 0),
		])


func _append_case_snapshot(lines: Array, title: String, case_snapshot: Dictionary) -> void:
	lines.append("## %s" % title)
	if case_snapshot.is_empty():
		lines.append("No data.")
		lines.append("")
		return

	lines.append("- Case: %s %sp" % [
		case_snapshot.get("class_label", "Default"),
		case_snapshot.get("player_count", 0),
	])
	lines.append("- Result: %s, completed %s round(s), base HP %s" % [
		"PASS" if bool(case_snapshot.get("ok", false)) else "FAIL",
		case_snapshot.get("completed_rounds", 0),
		case_snapshot.get("base_hp", 0),
	])
	lines.append("- Pressure: focus %s, base hits %s, structures lost %s, kills %s, gold %s" % [
		case_snapshot.get("outcome_focus", "unknown"),
		case_snapshot.get("base_hits", 0),
		case_snapshot.get("structures_destroyed", 0),
		case_snapshot.get("killed", 0),
		case_snapshot.get("gold_gained", 0),
	])
	lines.append("")


func _matrix_class_label(class_key: String, row: Dictionary) -> String:
	for entry in row.values():
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var entry_dictionary: Dictionary = entry
		var label = str(entry_dictionary.get("class_label", ""))
		if not label.is_empty():
			return label
	return class_key


func _format_matrix_cell(entry) -> String:
	if typeof(entry) != TYPE_DICTIONARY:
		return "-"

	var case_entry: Dictionary = entry
	return "%s R%s HP%s %s" % [
		"PASS" if bool(case_entry.get("ok", false)) else "FAIL",
		case_entry.get("completed_rounds", 0),
		case_entry.get("base_hp", 0),
		case_entry.get("focus", "unknown"),
	]


func _format_counts(counts: Dictionary) -> String:
	if counts.is_empty():
		return "-"

	var parts = PackedStringArray()
	for key in counts.keys():
		parts.append("%s=%s" % [key, counts.get(key, 0)])
	return ", ".join(parts)


func _markdown_cell(value: String) -> String:
	return value.replace("|", "/").replace("\n", " ")


func _increment_count(counts: Dictionary, key: String) -> void:
	counts[key] = int(counts.get(key, 0)) + 1


func _case_result(simulation, player_count: int, class_id: String, ok: bool) -> Dictionary:
	var outcome = simulation.get_run_outcome_report(player_count)
	outcome["details"] = _string_values(outcome.get("details", []))
	return {
		"ok": ok,
		"player_count": player_count,
		"class_id": class_id,
		"class_label": _class_label(simulation, class_id),
		"current_round": simulation.get_current_round(),
		"completed_rounds": simulation.get_completed_rounds(),
		"base_hp": simulation.get_base_hp(),
		"reward_pending": simulation.has_pending_reward(),
		"outcome": outcome,
		"stats": simulation.get_run_stats().duplicate(true),
	}


func _string_values(values) -> Array:
	var result: Array = []
	for value in values:
		result.append(str(value))
	return result


func _format_case_summary(case_result: Dictionary) -> String:
	var stats: Dictionary = case_result.get("stats", {})
	var outcome: Dictionary = case_result.get("outcome", {})
	return "[CASE] %s %sp ok=%s completed=%s current=%s base_hp=%s spawned=%s boss=%s/%s phase=%s pulse=%s siege=%s/%s killed=%s rewards=%s/%s artifacts=%s/%s shop_removed=%s gold=%s/%s break=%s/%s stacks=%s depth=%s card_fx=%s/%s/%s class_fx=%s/%s/%s/%s taunt=%s repairs=%s outcome=%s next=%s" % [
		case_result.get("class_label", "Default"),
		case_result.get("player_count", 0),
		case_result.get("ok", false),
		case_result.get("completed_rounds", 0),
		case_result.get("current_round", 0),
		case_result.get("base_hp", 0),
		stats.get("spawned", 0),
		stats.get("bosses_spawned", 0),
		stats.get("bosses_killed", 0),
		stats.get("boss_phase_triggers", 0),
		stats.get("boss_pulse_damage", 0),
		stats.get("boss_siege_triggers", 0),
		stats.get("boss_siege_damage", 0),
		stats.get("killed", 0),
		stats.get("card_rewards_taken", 0),
		stats.get("card_rewards_offered", 0),
		stats.get("artifact_rewards_taken", 0),
		stats.get("artifact_rewards_offered", 0),
		stats.get("shop_cards_removed", 0),
		stats.get("gold_gained", 0),
		stats.get("gold_spent", 0),
		stats.get("break_targets_found", 0),
		stats.get("break_path_steps", 0),
		stats.get("wave_stacks", 0),
		stats.get("max_wave_stack_depth", 0),
		stats.get("card_damage_dealt", 0),
		stats.get("card_repairs", 0),
		stats.get("card_effect_draws", 0),
		stats.get("class_thorns_damage", 0),
		stats.get("class_explosion_damage", 0),
		stats.get("class_splash_damage", 0),
		stats.get("class_aura_damage", 0),
		stats.get("class_taunt_hits", 0),
		stats.get("class_repairs", 0),
		outcome.get("focus", "unknown"),
		outcome.get("next_suggestion", "-"),
	]


func _case_name(simulation, class_id: String, player_count: int) -> String:
	return "%s %sp" % [_class_label(simulation, class_id), player_count]


func _class_label(simulation, class_id: String) -> String:
	if class_id.is_empty():
		return "Default"
	return simulation.get_class_label(class_id)


func _record(condition: bool, label: String) -> void:
	if condition:
		lines.append("[PASS] %s" % label)
	else:
		lines.append("[FAIL] %s" % label)
		failures.append(label)


func _tile_key(tile: Vector2i) -> String:
	return "%s,%s" % [tile.x, tile.y]
