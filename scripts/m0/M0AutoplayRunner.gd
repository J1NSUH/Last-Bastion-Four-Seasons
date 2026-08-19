class_name M0AutoplayRunner
extends RefCounted

const M0CombatSimulationScript = preload("res://scripts/m0/M0CombatSimulation.gd")
const DEFAULT_REPORT_PATH = "user://m0_autoplay_report.json"
const DEFAULT_MARKDOWN_REPORT_PATH = "user://m0_autoplay_report.md"
const REPORT_SCHEMA_VERSION = 3
const LOW_BASE_HP_WARNING = 70
const HIGH_BASE_HIT_WARNING = 20
const CLASS_BASE_HP_SPREAD_WARNING = 20.0
const ALPHA_FOCUS_QUEUE_LIMIT = 4
const NEXT_ACTION_QUEUE_LIMIT = 6
const DECISION_TRACE_LIMIT = 48
const BLOCKED_TRACE_CANDIDATE_LIMIT = 24
const RECOMMENDATION_CONTRAST_SAMPLE_LIMIT = 8
const REPORT_DIRECTION_ORDER = [
	"north",
	"east",
	"south",
	"west",
	"debug",
]

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
var decision_trace: Array[Dictionary] = []
var last_blocked_decision_signature = ""
var last_boss_warning_signature = ""
var boss_part_warning_stats = {
	"warnings": 0,
	"answered": 0,
	"by_reason": {},
}
var answered_boss_warning_signatures = {}


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


func run_boss_checkpoint() -> Dictionary:
	lines.clear()
	failures.clear()

	var profile_ids = _load_profile_ids()
	var target_rounds = _load_boss_checkpoint_rounds()
	var cases: Array = []
	var summary_lines: Array = []

	for profile_id in profile_ids:
		for player_count in range(1, 5):
			var case_result = _run_player_count_case(player_count, str(profile_id), target_rounds)
			cases.append(case_result)
			summary_lines.append(_format_case_summary(case_result))

	return _result(cases, summary_lines)


func run_boss_checkpoint_smoke() -> Dictionary:
	lines.clear()
	failures.clear()

	var case_result = _run_boss_smoke_case(1, "elementalist")
	return _result([case_result], [_format_case_summary(case_result)])


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


func run_class_boss_checkpoint(class_id: String, player_count: int) -> Dictionary:
	lines.clear()
	failures.clear()

	var target_rounds = _load_boss_checkpoint_rounds()
	var case_result = _run_player_count_case(clamp(player_count, 1, 4), class_id, target_rounds)
	return _result([case_result], [_format_case_summary(case_result)])


func debug_candidate_tiles_for_card(simulation, player_count: int, class_id: String, card_id: String) -> Array:
	return _candidate_tiles(simulation, player_count, class_id, card_id)


func debug_choose_reward_card(simulation, class_id: String, player_count: int = 1) -> String:
	return _choose_reward_card(simulation, class_id, player_count)


func debug_choose_artifact(simulation) -> String:
	return _choose_artifact(simulation)


func debug_choose_shop_card(simulation, class_id: String, player_count: int = 1) -> String:
	return _choose_shop_card(simulation, class_id, player_count)


func debug_card_play_budget(simulation, player_count: int) -> int:
	return _card_play_budget(simulation, player_count)


func debug_ordered_hand(simulation, class_id: String, player_count: int = 1) -> Array:
	return _ordered_hand(simulation, class_id, player_count)


func debug_decision_trace() -> Array:
	return decision_trace.duplicate(true)


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
	lines.append("- Recommendation follow rate: %s/%s (%.1f%%)" % [
		aggregate.get("recommendation_followed", 0),
		aggregate.get("recommendation_decisions", 0),
		float(aggregate.get("recommendation_follow_rate", 0.0)) * 100.0,
	])
	lines.append("- Recommendation choice split: %s" % _recommendation_choice_type_summary(aggregate))
	lines.append("- Boss part warning response: %s/%s (%.1f%%)" % [
		aggregate.get("boss_part_warning_answered", 0),
		aggregate.get("boss_part_warning_decisions", 0),
		float(aggregate.get("boss_part_warning_answer_rate", 0.0)) * 100.0,
	])
	lines.append("- Wave stack tempo moments: %s" % aggregate.get("wave_stack_tempo_moments", 0))
	lines.append("")

	lines.append("## Balance Notes")
	for note in report.get("balance_notes", []):
		lines.append("- %s" % str(note))
	lines.append("")

	_append_next_action_queue(lines, report.get("next_action_queue", []))
	_append_bucket_table(lines, "Class Results", aggregate.get("class_results", {}), "Class")
	_append_bucket_table(lines, "Player Count Results", aggregate.get("player_count_results", {}), "Players")
	_append_card_block_table(lines, aggregate.get("card_block_reasons", {}), int(aggregate.get("card_block_cases", 0)))
	_append_recommendation_table(lines, aggregate)
	_append_recommendation_contrast_samples(lines, aggregate.get("recommendation_contrast_samples", []))
	_append_boss_part_warning_table(lines, aggregate)
	_append_wave_stack_tempo_table(lines, aggregate)
	_append_case_matrix(lines, report.get("case_matrix", {}))
	_append_class_weakness_table(lines, report.get("class_weakness_summaries", []))
	_append_alpha_focus_queue(lines, report.get("alpha_focus_queue", []))
	_append_front_breakdown(lines, report.get("front_breakdown", []))
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


func _load_boss_checkpoint_rounds() -> int:
	var simulation = M0CombatSimulationScript.new()
	if not simulation.load_data():
		return 10

	return simulation.get_autoplay_boss_rounds()


func _run_player_count_case(player_count: int, class_id: String, target_rounds: int = -1) -> Dictionary:
	var failure_count_before = failures.size()
	decision_trace.clear()
	last_blocked_decision_signature = ""
	last_boss_warning_signature = ""
	_reset_boss_part_warning_stats()
	var simulation = M0CombatSimulationScript.new()
	var loaded = simulation.load_data()
	var case_name = _case_name(simulation, class_id, player_count)

	_record(loaded, "%s data loads" % case_name)
	if not loaded:
		return _case_result(simulation, player_count, class_id, false, "data_load_failed")

	case_name = _case_name(simulation, class_id, player_count)

	if not class_id.is_empty():
		var class_exists = not simulation.get_class_data(class_id).is_empty()
		_record(class_exists, "%s class profile exists" % case_name)
		if not class_exists:
			return _case_result(simulation, player_count, class_id, false, "unknown_class")

	_record(
		simulation.get_active_directions(player_count).size() == player_count,
		"%s active direction count matches" % case_name
	)

	var prepare_result = simulation.prepare_run_for_player_count(player_count)
	_record(bool(prepare_result["ok"]), "%s front seed mana prepares" % case_name)
	if not bool(prepare_result["ok"]):
		return _case_result(simulation, player_count, class_id, false, "setup_prepare_failed")

	var resolved_target_rounds = simulation.get_autoplay_rounds() if target_rounds <= 0 else target_rounds
	while simulation.get_completed_rounds() < resolved_target_rounds and not simulation.is_run_complete():
		var display_round = simulation.get_current_round()
		_play_some_cards(simulation, player_count, class_id)

		var start_result = simulation.start_wave(player_count)
		_record(bool(start_result["ok"]), "%s round %s starts" % [case_name, display_round])
		if not bool(start_result["ok"]):
			return _case_result(simulation, player_count, class_id, false, "wave_start_failed")

		_play_some_cards(simulation, player_count, class_id)
		_try_autoplay_wave_stack(simulation, player_count, resolved_target_rounds)
		var completed = _step_until_round_ends(simulation, player_count, class_id)
		_record(completed, "%s round %s ends" % [case_name, display_round])
		if not completed:
			return _case_result(simulation, player_count, class_id, false, _round_failure_reason(simulation))

		var settlement_result = _resolve_pending_autoplay_settlement(simulation, player_count, class_id, case_name, display_round)
		_record(bool(settlement_result.get("ok", false)), "%s round %s resolves settlement" % [case_name, display_round])
		if not bool(settlement_result.get("ok", false)):
			return _case_result(simulation, player_count, class_id, false, str(settlement_result.get("reason", "settlement_failed")))

	_record(simulation.get_completed_rounds() == resolved_target_rounds, "%s completes target rounds" % case_name)
	_record(int(simulation.get_run_stats().get("rounds_started", 0)) == resolved_target_rounds, "%s stats count started rounds" % case_name)
	_record(int(simulation.get_run_stats().get("rounds_completed", 0)) == resolved_target_rounds, "%s stats count completed rounds" % case_name)

	return _case_result(simulation, player_count, class_id, failures.size() == failure_count_before)


func _try_autoplay_wave_stack(simulation, player_count: int, target_rounds: int) -> void:
	if int(simulation.get_run_stats().get("wave_stacks", 0)) > 0:
		return

	var risk_report: Dictionary = simulation.get_wave_stack_risk_report(player_count)
	if not bool(risk_report.get("can_call", false)):
		return
	if str(risk_report.get("severity", "")) != "stable":
		return

	var pull_round = int(risk_report.get("round", 0))
	if pull_round <= 0 or pull_round > target_rounds:
		return

	var stack_result: Dictionary = {}
	var required_votes = max(1, simulation.get_wave_stack_required_votes(player_count))
	for _vote_index in range(required_votes):
		stack_result = simulation.stack_next_wave(player_count)
		if not bool(stack_result.get("ok", false)):
			_record_decision("wave_stack_hold", simulation, {
				"result": str(stack_result.get("reason", "blocked")),
				"risk_severity": str(risk_report.get("severity", "unknown")),
				"risk_summary": str(risk_report.get("headline", "")),
				"no_bonus_rewards": true,
			})
			return
		if str(stack_result.get("reason", "")) == "wave_stacked":
			break

	if str(stack_result.get("reason", "")) != "wave_stacked":
		_record_decision("wave_stack_vote", simulation, {
			"result": str(stack_result.get("reason", "vote_waiting")),
			"approvals": int(stack_result.get("approvals", 0)),
			"required": int(stack_result.get("required", required_votes)),
			"risk_severity": str(risk_report.get("severity", "stable")),
			"no_bonus_rewards": true,
		})
		return

	var tempo_moment: Dictionary = stack_result.get("wave_stack_tempo_moment", {})
	_record_decision("wave_stack", simulation, {
		"pulled_round": pull_round,
		"stack_depth": int(stack_result.get("stack_depth", 0)),
		"risk_severity": str(risk_report.get("severity", "stable")),
		"tempo_moment_state": str(tempo_moment.get("state", "")),
		"tempo_moment_summary": str(tempo_moment.get("summary", "")),
		"no_bonus_rewards": true,
		"forbidden_outcome_tags": tempo_moment.get("forbiddenOutcomeTags", []),
		"result": str(stack_result.get("reason", "wave_stacked")),
	})


func _resolve_pending_autoplay_settlement(
	simulation,
	player_count: int,
	class_id: String,
	case_name: String,
	display_round: int
) -> Dictionary:
	if not simulation.has_pending_reward():
		return {"ok": false, "reason": "reward_missing"}

	var resolved_any = false
	var guard = 0
	while simulation.has_pending_reward() and guard < 12:
		guard += 1
		var progressed = false

		if not simulation.get_reward_offer().is_empty():
			var reward_result = _claim_autoplay_reward(simulation, player_count, class_id)
			_record(bool(reward_result.get("ok", false)), "%s round %s claims reward" % [case_name, display_round])
			if not bool(reward_result.get("ok", false)):
				return reward_result
			progressed = true
			resolved_any = true

		if not simulation.get_artifact_offer().is_empty():
			var artifact_result = _claim_autoplay_artifact(simulation)
			_record(bool(artifact_result.get("ok", false)), "%s round %s claims artifact" % [case_name, display_round])
			if not bool(artifact_result.get("ok", false)):
				return artifact_result
			progressed = true
			resolved_any = true

		if not simulation.get_shop_offer().is_empty():
			var shop_result = _resolve_autoplay_shop(simulation, player_count, class_id)
			_record(bool(shop_result.get("ok", false)), "%s round %s resolves shop" % [case_name, display_round])
			if not bool(shop_result.get("ok", false)):
				return shop_result
			progressed = true
			resolved_any = true

		if not progressed:
			return {"ok": false, "reason": "settlement_stalled"}

	return {
		"ok": not simulation.has_pending_reward(),
		"reason": "ok" if not simulation.has_pending_reward() else "settlement_guard_limit",
		"settlement_steps": guard,
		"resolved_any": resolved_any,
	}


func _claim_autoplay_reward(simulation, player_count: int, class_id: String) -> Dictionary:
	var reward_recommendation = simulation.get_reward_recommendation_report(player_count, class_id)
	var reward_choice_type = str(reward_recommendation.get("choice_type", "card")) if bool(reward_recommendation.get("ok", false)) else "card"
	var reward_card_id = "" if reward_choice_type == "gold" else _choose_reward_card(simulation, class_id, player_count)
	var claim_result = simulation.skip_reward_offer() if reward_choice_type == "gold" else simulation.claim_reward_card(reward_card_id)
	if bool(claim_result.get("ok", false)):
		var decision = {
			"choice_type": reward_choice_type,
			"recommendation_available": bool(reward_recommendation.get("ok", false)),
			"recommended_id": str(reward_recommendation.get("card_id", "")),
			"recommended_label": str(reward_recommendation.get("label", "")),
			"recommendation_reason": str(reward_recommendation.get("reason_text", "")),
			"recommendation_detail": str(reward_recommendation.get("detail_text", "")),
			"followed_recommendation": (
				bool(reward_recommendation.get("ok", false))
				and (
					(reward_choice_type == "gold" and str(reward_recommendation.get("choice_type", "")) == "gold")
					or (reward_choice_type == "card" and reward_card_id == str(reward_recommendation.get("card_id", "")))
				)
			),
			"result": str(claim_result.get("reason", "ok")),
		}
		if reward_choice_type == "gold":
			decision["gold_gain"] = int(claim_result.get("gold_gain", 0))
			decision["gold_before"] = int(claim_result.get("gold_before", 0))
			decision["gold_after"] = int(claim_result.get("gold_after", 0))
			_record_decision("claim_reward_gold", simulation, decision)
		else:
			decision["card_id"] = reward_card_id
			decision["card_label"] = str(claim_result.get("card_label", simulation.get_card_label(reward_card_id)))
			decision["role"] = str(claim_result.get("role", ""))
			decision["rarity"] = str(claim_result.get("rarity_label", ""))
			_record_decision("claim_reward", simulation, decision)

	if not bool(claim_result.get("ok", false)):
		claim_result["reason"] = "reward_claim_failed"
	return claim_result


func _claim_autoplay_artifact(simulation) -> Dictionary:
	var artifact_recommendation = simulation.get_artifact_recommendation_report()
	var artifact_id = _choose_artifact(simulation)
	var artifact_result = simulation.claim_artifact(artifact_id)
	if bool(artifact_result.get("ok", false)):
		_record_decision("claim_artifact", simulation, {
			"artifact_id": artifact_id,
			"artifact_label": str(artifact_result.get("artifact_label", artifact_id)),
			"recommendation_available": bool(artifact_recommendation.get("ok", false)),
			"recommended_id": str(artifact_recommendation.get("artifact_id", "")),
			"recommended_label": str(artifact_recommendation.get("label", "")),
			"recommendation_reason": str(artifact_recommendation.get("reason_text", "")),
			"recommendation_detail": str(artifact_recommendation.get("detail_text", "")),
			"followed_recommendation": bool(artifact_recommendation.get("ok", false)) and artifact_id == str(artifact_recommendation.get("artifact_id", "")),
			"result": str(artifact_result.get("reason", "ok")),
		})

	if not bool(artifact_result.get("ok", false)):
		artifact_result["reason"] = "artifact_claim_failed"
	return artifact_result


func _resolve_autoplay_shop(simulation, player_count: int, class_id: String) -> Dictionary:
	var shop_recommendation = simulation.get_shop_recommendation_report(player_count, class_id)
	var shop_card_id = _choose_shop_card(simulation, class_id, player_count)
	var shop_report = simulation.get_card_removal_report(shop_card_id)
	if bool(shop_report.get("can_remove", false)):
		var shop_result = simulation.remove_shop_card(shop_card_id)
		if bool(shop_result.get("ok", false)):
			_record_decision("shop_remove", simulation, {
				"card_id": shop_card_id,
				"card_label": str(shop_result.get("card_label", simulation.get_card_label(shop_card_id))),
				"recommendation_available": bool(shop_recommendation.get("ok", false)),
				"recommended_id": str(shop_recommendation.get("card_id", "")),
				"recommended_label": str(shop_recommendation.get("label", "")),
				"recommendation_reason": str(shop_recommendation.get("reason_text", "")),
				"recommendation_detail": str(shop_recommendation.get("detail_text", "")),
				"followed_recommendation": bool(shop_recommendation.get("ok", false)) and shop_card_id == str(shop_recommendation.get("card_id", "")),
				"result": str(shop_result.get("reason", "ok")),
			})
		if not bool(shop_result.get("ok", false)):
			shop_result["reason"] = "shop_remove_failed"
		return shop_result

	var shop_skip_result = simulation.skip_shop_offer()
	if bool(shop_skip_result.get("ok", false)):
		_record_decision("shop_skip", simulation, {
			"card_id": shop_card_id,
			"card_label": simulation.get_card_label(shop_card_id),
			"recommendation_available": bool(shop_recommendation.get("ok", false)),
			"recommended_id": str(shop_recommendation.get("card_id", "")),
			"recommended_label": str(shop_recommendation.get("label", "")),
			"recommendation_reason": str(shop_recommendation.get("reason_text", "")),
			"recommendation_detail": str(shop_recommendation.get("detail_text", "")),
			"followed_recommendation": false,
			"result": str(shop_skip_result.get("reason", "ok")),
		})

	if not bool(shop_skip_result.get("ok", false)):
		shop_skip_result["reason"] = "shop_skip_failed"
	return shop_skip_result


func _run_boss_smoke_case(player_count: int, class_id: String) -> Dictionary:
	var failure_count_before = failures.size()
	decision_trace.clear()
	last_blocked_decision_signature = ""
	last_boss_warning_signature = ""
	_reset_boss_part_warning_stats()
	var simulation = M0CombatSimulationScript.new()
	var loaded = simulation.load_data()
	var case_name = "%s %sp boss smoke" % [_class_label(simulation, class_id), player_count]

	_record(loaded, "%s data loads" % case_name)
	if not loaded:
		return _case_result(simulation, player_count, class_id, false, "data_load_failed")

	case_name = "%s %sp boss smoke" % [_class_label(simulation, class_id), player_count]
	var class_exists = not simulation.get_class_data(class_id).is_empty()
	_record(class_exists, "%s class profile exists" % case_name)
	if not class_exists:
		return _case_result(simulation, player_count, class_id, false, "unknown_class")

	var prepare_result = simulation.prepare_run_for_player_count(player_count)
	_record(bool(prepare_result.get("ok", false)), "%s prepares front resources" % case_name)
	if not bool(prepare_result.get("ok", false)):
		return _case_result(simulation, player_count, class_id, false, "setup_prepare_failed")

	var target_round = _load_boss_checkpoint_rounds()
	var round_result = simulation.debug_set_round(target_round)
	_record(bool(round_result.get("ok", false)), "%s jumps to boss checkpoint round" % case_name)
	if not bool(round_result.get("ok", false)):
		return _case_result(simulation, player_count, class_id, false, "boss_round_setup_failed")

	var start_result = simulation.start_wave(player_count)
	_record(bool(start_result.get("ok", false)), "%s starts boss wave" % case_name)
	if not bool(start_result.get("ok", false)):
		return _case_result(simulation, player_count, class_id, false, "boss_wave_start_failed")

	simulation.step_wave(player_count)
	_record_boss_part_warning(simulation, player_count, "boss_smoke_spawn")
	var stats_after_spawn: Dictionary = simulation.get_run_stats()
	_record(int(stats_after_spawn.get("bosses_spawned", 0)) > 0, "%s spawns a boss" % case_name)
	if int(stats_after_spawn.get("bosses_spawned", 0)) <= 0:
		return _case_result(simulation, player_count, class_id, false, "boss_spawn_missing")

	var boss_killed = _play_boss_smoke_damage_until_kill(simulation, player_count, class_id)
	_record(boss_killed, "%s kills the smoke boss" % case_name)
	if not boss_killed:
		return _case_result(simulation, player_count, class_id, false, "boss_kill_missing")

	var reward_result = _claim_boss_smoke_rewards(simulation, player_count, class_id, target_round)
	_record(bool(reward_result.get("ok", false)), "%s claims boss reward chain" % case_name)
	if not bool(reward_result.get("ok", false)):
		return _case_result(simulation, player_count, class_id, false, str(reward_result.get("reason", "boss_reward_chain_failed")))

	var final_stats: Dictionary = simulation.get_run_stats()
	_record(int(final_stats.get("bosses_killed", 0)) > 0, "%s tracks boss kill stat" % case_name)
	_record(int(final_stats.get("artifact_rewards_taken", 0)) > 0, "%s tracks artifact claim stat" % case_name)
	_record(int(final_stats.get("shop_offers_opened", 0)) > 0, "%s tracks boss shop stat" % case_name)
	_record(int(final_stats.get("card_rewards_taken", 0)) > 0, "%s tracks card reward stat" % case_name)
	_record(int(boss_part_warning_stats.get("warnings", 0)) > 0, "%s records boss part warning" % case_name)

	return _case_result(simulation, player_count, class_id, failures.size() == failure_count_before)


func _play_boss_smoke_damage_until_kill(simulation, player_count: int, class_id: String) -> bool:
	for _hit_index in range(8):
		var boss_tile = _first_boss_tile(simulation)
		if boss_tile == Vector2i(-1, -1):
			return int(simulation.get_run_stats().get("bosses_killed", 0)) > 0

		_record_boss_part_warning(simulation, player_count, "boss_smoke_damage")
		var warning_report = simulation.get_boss_part_warning_report(player_count)
		var refill_events = simulation.debug_refill_round_resources(player_count)
		_record(refill_events.size() > 0, "boss smoke refreshes card resources")
		var hand_result = simulation.debug_set_hand(["m0_heavy_bolt"])
		if not bool(hand_result.get("ok", false)):
			return false

		var card_data = simulation.get_card_data("m0_heavy_bolt")
		var target_preview = simulation.can_play_card_at_tile("m0_heavy_bolt", boss_tile, player_count, class_id)
		if not bool(target_preview.get("ok", false)):
			return false

		var before_mana = simulation.get_mana()
		var answered_boss_warning = _card_play_answers_boss_warning(card_data, boss_tile, warning_report)
		var play_result = simulation.play_card_at_tile("m0_heavy_bolt", boss_tile, player_count, class_id)
		if not bool(play_result.get("ok", false)):
			return false

		if answered_boss_warning:
			_record_boss_part_warning_answer(simulation, warning_report)

		_record_decision("play_card", simulation, {
			"card_id": "m0_heavy_bolt",
			"card_label": str(play_result.get("card_label", simulation.get_card_label("m0_heavy_bolt"))),
			"kind": str(card_data.get("kind", "")),
			"target": _tile_key(boss_tile),
			"candidate_index": 0,
			"boss_part_focus": str(target_preview.get("boss_part_summary", "")),
			"boss_part_warning": _boss_warning_summary_for_decision(warning_report),
			"answered_boss_part_warning": answered_boss_warning,
			"before_mana": before_mana,
			"after_mana": simulation.get_mana(),
			"result": str(play_result.get("reason", "ok")),
		})

	return int(simulation.get_run_stats().get("bosses_killed", 0)) > 0


func _claim_boss_smoke_rewards(simulation, player_count: int, class_id: String, target_round: int) -> Dictionary:
	var reward_offer = simulation.debug_generate_reward_offer(target_round)
	if reward_offer.is_empty():
		return {"ok": false, "reason": "reward_offer_missing"}

	var reward_recommendation = simulation.get_reward_recommendation_report(player_count, class_id)
	var reward_choice_type = str(reward_recommendation.get("choice_type", "card")) if bool(reward_recommendation.get("ok", false)) else "card"
	var reward_card_id = "" if reward_choice_type == "gold" else _choose_reward_card(simulation, class_id, player_count)
	var claim_result = simulation.skip_reward_offer() if reward_choice_type == "gold" else simulation.claim_reward_card(reward_card_id)
	if not bool(claim_result.get("ok", false)):
		return {"ok": false, "reason": "reward_claim_failed"}

	var reward_decision = {
		"choice_type": reward_choice_type,
		"recommendation_available": bool(reward_recommendation.get("ok", false)),
		"recommended_id": str(reward_recommendation.get("card_id", "")),
		"recommended_label": str(reward_recommendation.get("label", "")),
		"recommendation_reason": str(reward_recommendation.get("reason_text", "")),
		"recommendation_detail": str(reward_recommendation.get("detail_text", "")),
		"followed_recommendation": (
			bool(reward_recommendation.get("ok", false))
			and (
				(reward_choice_type == "gold" and str(reward_recommendation.get("choice_type", "")) == "gold")
				or (reward_choice_type == "card" and reward_card_id == str(reward_recommendation.get("card_id", "")))
			)
		),
		"result": str(claim_result.get("reason", "ok")),
	}
	if reward_choice_type == "gold":
		reward_decision["gold_gain"] = int(claim_result.get("gold_gain", 0))
		reward_decision["gold_before"] = int(claim_result.get("gold_before", 0))
		reward_decision["gold_after"] = int(claim_result.get("gold_after", 0))
		_record_decision("claim_reward_gold", simulation, reward_decision)
	else:
		reward_decision["card_id"] = reward_card_id
		reward_decision["card_label"] = str(claim_result.get("card_label", simulation.get_card_label(reward_card_id)))
		reward_decision["role"] = str(claim_result.get("role", ""))
		reward_decision["rarity"] = str(claim_result.get("rarity_label", ""))
		_record_decision("claim_reward", simulation, reward_decision)

	simulation.debug_generate_artifact_offer()
	var artifact_offer = simulation.get_artifact_offer()
	if artifact_offer.is_empty():
		return {"ok": false, "reason": "artifact_offer_missing"}

	var artifact_recommendation = simulation.get_artifact_recommendation_report()
	var artifact_id = _choose_artifact(simulation)
	var artifact_result = simulation.claim_artifact(artifact_id)
	if not bool(artifact_result.get("ok", false)):
		return {"ok": false, "reason": "artifact_claim_failed"}

	_record_decision("claim_artifact", simulation, {
		"artifact_id": artifact_id,
		"artifact_label": str(artifact_result.get("artifact_label", artifact_id)),
		"recommendation_available": bool(artifact_recommendation.get("ok", false)),
		"recommended_id": str(artifact_recommendation.get("artifact_id", "")),
		"recommended_label": str(artifact_recommendation.get("label", "")),
		"recommendation_reason": str(artifact_recommendation.get("reason_text", "")),
		"recommendation_detail": str(artifact_recommendation.get("detail_text", "")),
		"followed_recommendation": bool(artifact_recommendation.get("ok", false)) and artifact_id == str(artifact_recommendation.get("artifact_id", "")),
		"result": str(artifact_result.get("reason", "ok")),
	})

	simulation.debug_set_gold(simulation.get_shop_deck_removal_gold_cost())
	simulation.debug_generate_shop_offer(target_round)
	var shop_offer = simulation.get_shop_offer()
	if shop_offer.is_empty():
		return {"ok": false, "reason": "shop_offer_missing"}

	var shop_recommendation = simulation.get_shop_recommendation_report(player_count, class_id)
	var shop_card_id = _choose_shop_card(simulation, class_id, player_count)
	var shop_result = simulation.remove_shop_card(shop_card_id)
	if not bool(shop_result.get("ok", false)):
		return {"ok": false, "reason": "shop_remove_failed"}

	_record_decision("shop_remove", simulation, {
		"card_id": shop_card_id,
		"card_label": str(shop_result.get("card_label", simulation.get_card_label(shop_card_id))),
		"recommendation_available": bool(shop_recommendation.get("ok", false)),
		"recommended_id": str(shop_recommendation.get("card_id", "")),
		"recommended_label": str(shop_recommendation.get("label", "")),
		"recommendation_reason": str(shop_recommendation.get("reason_text", "")),
		"recommendation_detail": str(shop_recommendation.get("detail_text", "")),
		"followed_recommendation": bool(shop_recommendation.get("ok", false)) and shop_card_id == str(shop_recommendation.get("card_id", "")),
		"result": str(shop_result.get("reason", "ok")),
	})

	return {"ok": true, "reason": "ok"}


func _first_boss_tile(simulation) -> Vector2i:
	var boss_tiles: Dictionary = simulation.get_boss_enemy_tiles()
	for key_value in boss_tiles.keys():
		return _tile_from_key(str(key_value))

	return Vector2i(-1, -1)


func _step_until_round_ends(simulation, player_count: int, class_id: String) -> bool:
	for _step_index in range(simulation.get_autoplay_max_steps_per_round()):
		simulation.step_wave(player_count)
		_record_boss_part_warning(simulation, player_count, "after_step")
		if simulation.wave_active:
			_play_some_cards(simulation, player_count, class_id)
		if not simulation.wave_active:
			return simulation.has_pending_reward() or simulation.is_run_complete()

	return false


func _round_failure_reason(simulation) -> String:
	if simulation.get_base_hp() <= 0:
		return "base_destroyed"
	if simulation.wave_active:
		return "wave_timeout"
	if simulation.has_pending_reward():
		return "reward_pending"
	return "round_end_failed"


func _play_some_cards(simulation, player_count: int, class_id: String) -> void:
	_record_boss_part_warning(simulation, player_count, "before_cards")
	var played = 0
	while played < _card_play_budget(simulation, player_count):
		if not _play_first_available_card(simulation, player_count, class_id):
			_record_blocked_card_play(simulation, player_count, class_id, played)
			return
		played += 1


func _card_play_budget(simulation, player_count: int) -> int:
	var normalized_player_count = clamp(player_count, 1, 4)
	return max(1, simulation.get_autoplay_cards_per_round() + normalized_player_count - 1)


func _play_first_available_card(simulation, player_count: int, class_id: String) -> bool:
	var boss_warning_report = simulation.get_boss_part_warning_report(player_count)
	for card_id in _ordered_hand(simulation, class_id, player_count):
		var card_data = simulation.get_card_data(str(card_id))
		if not simulation.card_requires_tile(str(card_id)):
			var direct_before_mana = simulation.get_mana()
			var direct_result = simulation.play_card(str(card_id), class_id)
			if bool(direct_result["ok"]):
				_record_decision("play_card", simulation, {
					"card_id": str(card_id),
					"card_label": str(direct_result.get("card_label", simulation.get_card_label(str(card_id)))),
					"kind": str(card_data.get("kind", "")),
					"target": "",
					"before_mana": direct_before_mana,
					"after_mana": simulation.get_mana(),
					"boss_part_warning": _boss_warning_summary_for_decision(boss_warning_report),
					"answered_boss_part_warning": false,
					"result": str(direct_result.get("reason", "ok")),
				})
				return true

		var candidate_index = 0
		for tile in _candidate_tiles(simulation, player_count, class_id, str(card_id)):
			var result = simulation.can_play_card_at_tile(str(card_id), tile, player_count, class_id)
			if bool(result["ok"]):
				var tile_before_mana = simulation.get_mana()
				var answered_boss_warning = _card_play_answers_boss_warning(card_data, tile, boss_warning_report)
				var play_result = simulation.play_card_at_tile(str(card_id), tile, player_count, class_id)
				if bool(play_result["ok"]):
					if answered_boss_warning:
						_record_boss_part_warning_answer(simulation, boss_warning_report)
					_record_decision("play_card", simulation, {
						"card_id": str(card_id),
						"card_label": str(play_result.get("card_label", simulation.get_card_label(str(card_id)))),
						"kind": str(card_data.get("kind", "")),
						"structure_type": str(card_data.get("structureType", "")),
						"target": _tile_key(tile),
						"candidate_index": candidate_index,
						"boss_part_focus": str(result.get("boss_part_summary", "")),
						"boss_part_warning": _boss_warning_summary_for_decision(boss_warning_report),
						"answered_boss_part_warning": answered_boss_warning,
						"before_mana": tile_before_mana,
						"after_mana": simulation.get_mana(),
						"result": str(play_result.get("reason", "ok")),
					})
					return true

				return false

			candidate_index += 1

	return false


func _record_boss_part_warning(simulation, player_count: int, context: String) -> void:
	if not bool(simulation.wave_active):
		return

	var report = simulation.get_boss_part_warning_report(player_count)
	if not bool(report.get("ok", false)):
		return

	var target_key = _boss_warning_target_key(report)
	var signature = _boss_part_warning_signature(simulation, report)
	if signature == last_boss_warning_signature:
		return

	last_boss_warning_signature = signature
	_increment_boss_part_warning_seen(report)
	_record_decision("boss_part_warning", simulation, {
		"context": context,
		"severity": str(report.get("severity", "warning")),
		"boss_part_warning": str(report.get("summary", "")),
		"target": target_key,
		"focus_part_id": str(report.get("focus_part_id", "")),
		"focus_label": str(report.get("focus_label", "")),
		"danger_part_id": str(report.get("danger_part_id", "")),
		"danger_label": str(report.get("danger_label", "")),
		"suggestion": str(report.get("suggestion", "")),
		"reason": str(report.get("reason", "boss_part_warning")),
	})


func _reset_boss_part_warning_stats() -> void:
	boss_part_warning_stats = {
		"warnings": 0,
		"answered": 0,
		"by_reason": {},
	}
	answered_boss_warning_signatures = {}


func _increment_boss_part_warning_seen(report: Dictionary) -> void:
	boss_part_warning_stats["warnings"] = int(boss_part_warning_stats.get("warnings", 0)) + 1
	var reason = str(report.get("reason", "boss_part_warning"))
	if reason.is_empty():
		reason = "boss_part_warning"
	var by_reason: Dictionary = boss_part_warning_stats.get("by_reason", {})
	_increment_count(by_reason, reason)
	boss_part_warning_stats["by_reason"] = by_reason


func _record_boss_part_warning_answer(simulation, report: Dictionary) -> void:
	var signature = _boss_part_warning_signature(simulation, report)
	if signature.is_empty() or answered_boss_warning_signatures.has(signature):
		return

	answered_boss_warning_signatures[signature] = true
	boss_part_warning_stats["answered"] = int(boss_part_warning_stats.get("answered", 0)) + 1


func _boss_part_warning_signature(simulation, report: Dictionary) -> String:
	if not bool(report.get("ok", false)):
		return ""

	return "%s|%s|%s|%s|%s|%s|%s" % [
		simulation.get_current_round(),
		simulation.get_completed_rounds(),
		report.get("enemy_id", -1),
		report.get("focus_part_id", ""),
		report.get("danger_part_id", ""),
		report.get("steps_until_pattern", report.get("steps_to_base", "")),
		_boss_warning_target_key(report),
	]


func _boss_warning_summary_for_decision(report: Dictionary) -> String:
	if not bool(report.get("ok", false)):
		return ""

	return str(report.get("summary", ""))


func _card_play_answers_boss_warning(card_data: Dictionary, tile: Vector2i, warning_report: Dictionary) -> bool:
	match str(card_data.get("kind", "")):
		"damage_enemy":
			return _tile_key(tile) == _boss_warning_target_key(warning_report)
		"repair_structure":
			return _tile_key(tile) == _boss_warning_structure_target_key(warning_report)
		"place_structure":
			return bool(warning_report.get("ok", false)) and str(card_data.get("structureType", "")) == "barricade"
		_:
			return false

	return false


func _boss_warning_target_key(report: Dictionary) -> String:
	if not bool(report.get("ok", false)):
		return ""

	var tile_value = report.get("tile", Vector2i(-1, -1))
	if typeof(tile_value) != TYPE_VECTOR2I:
		return ""

	var tile: Vector2i = tile_value
	if tile == Vector2i(-1, -1):
		return ""

	return _tile_key(tile)


func _boss_warning_structure_target_key(report: Dictionary) -> String:
	if not bool(report.get("ok", false)):
		return ""

	return str(report.get("target_key", ""))


func _record_blocked_card_play(simulation, player_count: int, class_id: String, played_before_block: int) -> void:
	var report = _blocked_card_play_report(simulation, player_count, class_id, played_before_block)
	var hand_size = int(report.get("hand_size", 0))
	var enemy_count = int(report.get("enemy_count", 0))
	var boss_count = int(report.get("boss_count", 0))
	if hand_size <= 0 and enemy_count <= 0 and boss_count <= 0:
		return

	var top_reason = str(report.get("top_reason", ""))
	var signature_mana = 0 if top_reason == "hand_empty" else simulation.get_mana()
	var signature_enemy_count = 0 if top_reason == "hand_empty" else enemy_count
	var signature = "%s|%s|%s|%s|%s|%s|%s" % [
		simulation.get_current_round(),
		"wave" if bool(simulation.wave_active) else "build",
		signature_mana,
		report.get("hand_key", ""),
		top_reason,
		signature_enemy_count,
		boss_count,
	]
	if signature == last_blocked_decision_signature:
		return

	last_blocked_decision_signature = signature
	_record_decision("play_blocked", simulation, report)


func _blocked_card_play_report(simulation, player_count: int, class_id: String, played_before_block: int) -> Dictionary:
	var hand = simulation.get_hand()
	var ordered_hand = _ordered_hand(simulation, class_id, player_count)
	var reason_counts = {}
	var blocked_cards: Array[String] = []
	var hand_labels: Array[String] = []

	for card_id_value in hand:
		var card_id = str(card_id_value)
		hand_labels.append(simulation.get_card_label(card_id))

	if ordered_hand.is_empty():
		_increment_count(reason_counts, "hand_empty")

	for card_id_value in ordered_hand:
		var card_id = str(card_id_value)
		var card_data = simulation.get_card_data(card_id)
		var card_label = simulation.get_card_label(card_id)
		var card_reasons = _card_block_reason_counts(simulation, player_count, class_id, card_id, card_data)
		var top_card_reason = _top_count_key(card_reasons)
		if top_card_reason.is_empty():
			top_card_reason = "unknown"

		_increment_count(reason_counts, top_card_reason)
		if blocked_cards.size() < 5:
			blocked_cards.append("%s:%s" % [card_label, top_card_reason])

	return {
		"result": "no_playable_card",
		"played_before_block": played_before_block,
		"hand_size": hand.size(),
		"hand_key": _join_strings(hand_labels, "|"),
		"hand_labels": hand_labels,
		"blocked_cards": blocked_cards,
		"reason_counts": reason_counts,
		"top_reason": _top_count_key(reason_counts),
		"enemy_count": _active_enemy_count(simulation, player_count),
		"boss_count": _active_boss_count(simulation, player_count),
	}


func _card_block_reason_counts(simulation, player_count: int, class_id: String, card_id: String, card_data: Dictionary) -> Dictionary:
	var reason_counts = {}
	if not simulation.card_requires_tile(card_id):
		var direct_result = simulation.can_play_card(card_id, class_id)
		_increment_count(reason_counts, str(direct_result.get("reason", "unknown")))
		return reason_counts

	var candidates = _candidate_tiles(simulation, player_count, class_id, card_id)
	if candidates.is_empty():
		_increment_count(reason_counts, "no_candidates")
		return reason_counts

	var checked = 0
	for tile in candidates:
		var result = simulation.can_play_card_at_tile(card_id, tile, player_count, class_id)
		_increment_count(reason_counts, str(result.get("reason", "unknown")))
		checked += 1
		if checked >= BLOCKED_TRACE_CANDIDATE_LIMIT:
			break

	if reason_counts.is_empty():
		_increment_count(reason_counts, str(card_data.get("kind", "unknown")))

	return reason_counts


func _ordered_hand(simulation, class_id: String, player_count: int = 1) -> Array:
	var hand = simulation.get_hand()
	var priority = _card_priority(simulation, class_id)
	var ordered: Array = []
	var used_indexes = {}

	if _has_boss_part_warning(simulation, player_count):
		_append_ordered_hand_by_kind(ordered, used_indexes, hand, simulation, "damage_enemy")
		_append_ordered_hand_by_kind(ordered, used_indexes, hand, simulation, "repair_structure")
		_append_ordered_hand_by_structure_type(ordered, used_indexes, hand, simulation, "barricade")
	elif _should_prioritize_damage_cards(simulation):
		_append_ordered_hand_by_kind(ordered, used_indexes, hand, simulation, "damage_enemy")
	elif _should_prioritize_boss_delay_cards(simulation, player_count):
		_append_ordered_hand_by_structure_type(ordered, used_indexes, hand, simulation, "barricade")

	var found_priority_card = true
	while found_priority_card:
		found_priority_card = false
		for priority_card_id in priority:
			for index in range(hand.size()):
				if used_indexes.has(index):
					continue
				if str(hand[index]) == str(priority_card_id):
					ordered.append(str(hand[index]))
					used_indexes[index] = true
					found_priority_card = true
					break

	for index in range(hand.size()):
		if used_indexes.has(index):
			continue
		ordered.append(str(hand[index]))

	return ordered


func _should_prioritize_damage_cards(simulation) -> bool:
	return not simulation.debug_get_enemies().is_empty()


func _has_boss_part_warning(simulation, player_count: int) -> bool:
	var report = simulation.get_boss_part_warning_report(player_count)
	return bool(report.get("ok", false))


func _should_prioritize_boss_delay_cards(simulation, player_count: int) -> bool:
	return not bool(simulation.wave_active) and not _upcoming_boss_direction(simulation, player_count).is_empty()


func _append_ordered_hand_by_kind(ordered: Array, used_indexes: Dictionary, hand: Array, simulation, kind: String) -> void:
	while true:
		var selected_index = -1
		var selected_score = -999999
		for index in range(hand.size()):
			if used_indexes.has(index):
				continue

			var card_id = str(hand[index])
			var card = simulation.get_card_data(card_id)
			if str(card.get("kind", "")) != kind:
				continue

			var score = _reward_card_strength_score(simulation, card_id)
			if selected_index < 0 or score > selected_score:
				selected_index = index
				selected_score = score

		if selected_index < 0:
			return

		ordered.append(str(hand[selected_index]))
		used_indexes[selected_index] = true


func _append_ordered_hand_by_structure_type(
	ordered: Array,
	used_indexes: Dictionary,
	hand: Array,
	simulation,
	structure_type: String
) -> void:
	while true:
		var selected_index = -1
		var selected_score = -999999
		for index in range(hand.size()):
			if used_indexes.has(index):
				continue

			var card_id = str(hand[index])
			var card = simulation.get_card_data(card_id)
			if str(card.get("kind", "")) != "place_structure":
				continue
			if str(card.get("structureType", "")) != structure_type:
				continue

			var score = _reward_card_strength_score(simulation, card_id)
			if selected_index < 0 or score > selected_score:
				selected_index = index
				selected_score = score

		if selected_index < 0:
			return

		ordered.append(str(hand[selected_index]))
		used_indexes[selected_index] = true


func _choose_reward_card(simulation, class_id: String, player_count: int = 1) -> String:
	var offer = simulation.get_reward_offer()
	var recommendation: Dictionary = simulation.get_reward_recommendation_report(player_count, class_id)
	if bool(recommendation.get("ok", false)):
		var recommended_card_id = str(recommendation.get("card_id", ""))
		if offer.has(recommended_card_id):
			return recommended_card_id

	var coverage_card_id = _choose_damage_coverage_reward_card(simulation, offer, player_count)
	if not coverage_card_id.is_empty():
		return coverage_card_id

	for priority_card_id in _card_priority(simulation, class_id):
		if offer.has(str(priority_card_id)):
			return str(priority_card_id)

	if offer.is_empty():
		return ""

	return str(offer[0])


func _choose_artifact(simulation) -> String:
	var offer = simulation.get_artifact_offer()
	var recommendation: Dictionary = simulation.get_artifact_recommendation_report()
	if bool(recommendation.get("ok", false)):
		var recommended_artifact_id = str(recommendation.get("artifact_id", ""))
		if offer.has(recommended_artifact_id):
			return recommended_artifact_id

	if offer.is_empty():
		return ""

	return str(offer[0])


func _choose_shop_card(simulation, class_id: String, player_count: int = 1) -> String:
	var offer = simulation.get_shop_offer()
	var recommendation: Dictionary = simulation.get_shop_recommendation_report(player_count, class_id)
	if bool(recommendation.get("ok", false)):
		var recommended_card_id = str(recommendation.get("card_id", ""))
		if offer.has(recommended_card_id):
			return recommended_card_id

	if offer.is_empty():
		return ""

	return str(offer[0])


func _choose_damage_coverage_reward_card(simulation, offer: Array, player_count: int = 1) -> String:
	var best_damage_card_id = _best_offer_by_kind(simulation, offer, "damage_enemy")
	if best_damage_card_id.is_empty():
		return ""

	var damage_deck_count = _deck_kind_count(simulation, "damage_enemy")
	var target_damage_count = _target_damage_coverage_count(player_count)
	if damage_deck_count < target_damage_count:
		return best_damage_card_id

	var best_damage_card = simulation.get_card_data(best_damage_card_id)
	if damage_deck_count < max(2, target_damage_count) and int(best_damage_card.get("damage", 0)) >= 4:
		return best_damage_card_id

	return ""


func _target_damage_coverage_count(player_count: int) -> int:
	return clamp(player_count, 1, 4)


func _best_offer_by_kind(simulation, offer: Array, kind: String) -> String:
	var best_card_id = ""
	var best_score = -999999
	for card_id_value in offer:
		var card_id = str(card_id_value)
		var card = simulation.get_card_data(card_id)
		if str(card.get("kind", "")) != kind:
			continue

		var score = _reward_card_strength_score(simulation, card_id)
		if best_card_id.is_empty() or score > best_score:
			best_card_id = card_id
			best_score = score

	return best_card_id


func _reward_card_strength_score(simulation, card_id: String) -> int:
	var card = simulation.get_card_data(card_id)
	var score = 0
	match str(card.get("kind", "")):
		"damage_enemy":
			score += int(card.get("damage", 0)) * 100
		"repair_structure":
			score += int(card.get("repair", 0)) * 20
		"draw_cards":
			score += int(card.get("draw", 0)) * 50
		"place_structure":
			score += 80 if str(card.get("structureType", "")) == "tower" else 60

	score -= int(card.get("cost", 0)) * 5
	match simulation.get_card_rarity(card_id):
		"rare":
			score += 12
		"uncommon":
			score += 6

	return score


func _deck_kind_count(simulation, kind: String) -> int:
	var seen = {}
	var count = 0
	for card_id_value in simulation.get_reward_card_pool(simulation.get_max_rounds()):
		var card_id = str(card_id_value)
		if seen.has(card_id):
			continue

		seen[card_id] = true
		var card = simulation.get_card_data(card_id)
		if str(card.get("kind", "")) == kind:
			count += simulation.get_card_deck_count(card_id)

	return count


func _card_priority(simulation, class_id: String) -> Array:
	var priority: Array = simulation.get_class_autoplay_profile(class_id).get("cardPriority", [])
	var result: Array = []
	for card_id in priority:
		result.append(str(card_id))
	return result


func _candidate_tiles(simulation, player_count: int, class_id: String, card_id: String) -> Array:
	var profile = simulation.get_class_autoplay_profile(class_id)
	var tile_plan = str(profile.get("tilePlan", "killzone"))
	var card_data = simulation.get_card_data(card_id)
	var structure_type = str(card_data.get("structureType", "tower"))
	var card_kind = str(card_data.get("kind", ""))
	var candidates: Array = []
	var place_structure_card = card_kind == "place_structure"
	var boss_delay_leads = place_structure_card and _boss_delay_candidates_should_lead(simulation, player_count)
	var front_recommendation_leads = place_structure_card and _front_recommendation_should_lead(simulation, player_count)

	if card_kind == "damage_enemy":
		_append_enemy_tile_candidates(candidates, simulation, player_count, class_id)
	elif card_kind == "repair_structure":
		_append_repair_tile_candidates(candidates, simulation, player_count)
	elif boss_delay_leads:
		_append_boss_delay_candidates(candidates, simulation, player_count, structure_type)
	elif front_recommendation_leads:
		_append_front_recommendation_candidates(candidates, simulation, player_count, class_id, structure_type)

	match tile_plan:
		"guard_line":
			_append_guard_line_candidates(candidates, simulation, player_count, structure_type)
		"maze_grid":
			_append_maze_grid_candidates(candidates, simulation, player_count, structure_type)
		"cluster":
			_append_cluster_candidates(candidates, simulation, player_count, structure_type)
		_:
			_append_killzone_candidates(candidates, simulation, player_count, structure_type)

	candidates.append_array(FALLBACK_CANDIDATES)

	if place_structure_card and not boss_delay_leads:
		_append_boss_delay_candidates(candidates, simulation, player_count, structure_type)

	if place_structure_card and not front_recommendation_leads:
		_append_front_recommendation_candidates(candidates, simulation, player_count, class_id, structure_type)

	if _should_add_path_tile_candidates(card_kind, structure_type):
		for key in simulation.get_path_cells(player_count).keys():
			var tile = _tile_from_key(str(key))
			if tile != Vector2i(-1, -1):
				candidates.append(tile)

	return _unique_tiles(candidates)


func _append_enemy_tile_candidates(candidates: Array, simulation, player_count: int, class_id: String) -> void:
	var active_directions = simulation.get_active_directions(player_count)
	var prioritize_boss_targets = _should_prioritize_boss_damage_targets(class_id)
	var enemy_candidates: Array = []
	var boss_warning_tile = _boss_part_warning_target_tile(simulation, player_count)
	if boss_warning_tile != Vector2i(-1, -1):
		candidates.append(boss_warning_tile)

	for enemy in simulation.debug_get_enemies():
		if typeof(enemy) != TYPE_DICTIONARY:
			continue

		var enemy_dictionary: Dictionary = enemy
		if not active_directions.has(str(enemy_dictionary.get("direction", ""))):
			continue

		var enemy_tile = enemy_dictionary.get("tile", Vector2i(-1, -1))
		if typeof(enemy_tile) == TYPE_VECTOR2I:
			if not prioritize_boss_targets:
				candidates.append(enemy_tile)
				continue

			enemy_candidates.append({
				"tile": enemy_tile,
				"score": _enemy_target_score(simulation, enemy_dictionary),
				"id": int(enemy_dictionary.get("id", 0)),
			})

	if not prioritize_boss_targets:
		return

	enemy_candidates.sort_custom(_enemy_candidate_is_before)
	for candidate_value in enemy_candidates:
		if typeof(candidate_value) != TYPE_DICTIONARY:
			continue

		var candidate: Dictionary = candidate_value
		var tile_value = candidate.get("tile", Vector2i(-1, -1))
		if typeof(tile_value) == TYPE_VECTOR2I:
			candidates.append(tile_value)


func _boss_part_warning_target_tile(simulation, player_count: int) -> Vector2i:
	var report = simulation.get_boss_part_warning_report(player_count)
	if not bool(report.get("ok", false)):
		return Vector2i(-1, -1)

	var tile_value = report.get("tile", Vector2i(-1, -1))
	if typeof(tile_value) != TYPE_VECTOR2I:
		return Vector2i(-1, -1)

	return tile_value


func _should_prioritize_boss_damage_targets(class_id: String) -> bool:
	return class_id == "elementalist"


func _enemy_candidate_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	if int(left.get("score", 0)) != int(right.get("score", 0)):
		return int(left.get("score", 0)) > int(right.get("score", 0))

	return int(left.get("id", 0)) < int(right.get("id", 0))


func _enemy_target_score(simulation, enemy: Dictionary) -> int:
	var score = 0
	if bool(enemy.get("boss", false)):
		score += 100000

	var distance_to_base = _enemy_distance_to_base(simulation, enemy)
	if distance_to_base >= 0:
		score += max(0, 1000 - distance_to_base) * 10

	score += max(0, 200 - int(enemy.get("hp", 0)))
	return score


func _enemy_distance_to_base(simulation, enemy: Dictionary) -> int:
	var enemy_tile_value = enemy.get("tile", Vector2i(-1, -1))
	if typeof(enemy_tile_value) != TYPE_VECTOR2I:
		return -1

	var enemy_tile: Vector2i = enemy_tile_value
	var best_distance = 999999
	for base_tile_value in simulation.get_base_cells():
		if typeof(base_tile_value) != TYPE_VECTOR2I:
			continue

		var base_tile: Vector2i = base_tile_value
		var distance = abs(enemy_tile.x - base_tile.x) + abs(enemy_tile.y - base_tile.y)
		if distance < best_distance:
			best_distance = distance

	return best_distance if best_distance < 999999 else -1


func _append_repair_tile_candidates(candidates: Array, simulation, player_count: int) -> void:
	var boss_warning_structure_tile = _boss_part_warning_structure_target_tile(simulation, player_count)
	if boss_warning_structure_tile != Vector2i(-1, -1):
		candidates.append(boss_warning_structure_tile)

	for structure in simulation.get_structure_tiles().values():
		if typeof(structure) != TYPE_DICTIONARY:
			continue

		var structure_dictionary: Dictionary = structure
		var tile = structure_dictionary.get("tile", Vector2i(-1, -1))
		if typeof(tile) == TYPE_VECTOR2I:
			candidates.append(tile)


func _boss_part_warning_structure_target_tile(simulation, player_count: int) -> Vector2i:
	var report = simulation.get_boss_part_warning_report(player_count)
	var target_key = _boss_warning_structure_target_key(report)
	if target_key.is_empty():
		return Vector2i(-1, -1)

	var structure: Dictionary = simulation.get_structure_tiles().get(target_key, {})
	var tile_value = structure.get("tile", Vector2i(-1, -1))
	if typeof(tile_value) != TYPE_VECTOR2I:
		return Vector2i(-1, -1)

	return tile_value


func _should_add_path_tile_candidates(card_kind: String, structure_type: String) -> bool:
	return card_kind == "place_structure"


func _boss_delay_candidates_should_lead(simulation, player_count: int) -> bool:
	return _has_active_boss(simulation, player_count) or not _upcoming_boss_direction(simulation, player_count).is_empty()


func _append_boss_delay_candidates(candidates: Array, simulation, player_count: int, structure_type: String) -> void:
	var active_boss_directions = _active_boss_directions(simulation, player_count)
	if not active_boss_directions.is_empty():
		var active_paths_by_direction: Dictionary = simulation.get_path_cells_by_direction(player_count)
		for active_direction in active_boss_directions:
			var active_path: Array = active_paths_by_direction.get(str(active_direction), [])
			_append_path_boss_delay_candidates(candidates, active_path, str(active_direction), structure_type)
		_append_active_boss_delay_candidates(candidates, simulation, player_count, structure_type)
		return

	var direction = _upcoming_boss_direction(simulation, player_count)
	if direction.is_empty():
		return

	var paths_by_direction: Dictionary = simulation.get_path_cells_by_direction(player_count)
	var path: Array = paths_by_direction.get(direction, [])
	_append_path_boss_delay_candidates(candidates, path, direction, structure_type)


func _append_active_boss_delay_candidates(candidates: Array, simulation, player_count: int, structure_type: String) -> bool:
	var active_directions = simulation.get_active_directions(player_count)
	var enemy_tiles = {}
	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		var tile_value = enemy.get("tile", Vector2i(-1, -1))
		if typeof(tile_value) == TYPE_VECTOR2I:
			enemy_tiles[_tile_key(tile_value)] = true

	var appended = false
	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		if not bool(enemy.get("boss", false)):
			continue

		var direction = str(enemy.get("direction", ""))
		if not active_directions.has(direction):
			continue

		var boss_tile_value = enemy.get("tile", Vector2i(-1, -1))
		if typeof(boss_tile_value) != TYPE_VECTOR2I:
			continue

		for tile in _boss_delay_tiles_near_boss(boss_tile_value, direction, structure_type):
			if enemy_tiles.has(_tile_key(tile)):
				continue

			candidates.append(tile)
			appended = true

	return appended


func _has_active_boss(simulation, player_count: int) -> bool:
	return not _active_boss_directions(simulation, player_count).is_empty()


func _active_boss_directions(simulation, player_count: int) -> Array[String]:
	var active_directions = simulation.get_active_directions(player_count)
	var boss_directions: Array[String] = []
	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		var direction = str(enemy.get("direction", ""))
		if bool(enemy.get("boss", false)) and active_directions.has(direction) and not boss_directions.has(direction):
			boss_directions.append(direction)

	return boss_directions


func _active_enemy_count(simulation, player_count: int) -> int:
	var active_directions = simulation.get_active_directions(player_count)
	var count = 0
	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		if active_directions.has(str(enemy.get("direction", ""))):
			count += 1

	return count


func _active_boss_count(simulation, player_count: int) -> int:
	var active_directions = simulation.get_active_directions(player_count)
	var count = 0
	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		if bool(enemy.get("boss", false)) and active_directions.has(str(enemy.get("direction", ""))):
			count += 1

	return count


func _upcoming_boss_direction(simulation, player_count: int) -> String:
	if bool(simulation.wave_active):
		return ""

	var rows: Array = simulation.get_wave_preview_rows(player_count, 1)
	if rows.is_empty():
		return ""

	var row_value = rows[0]
	if typeof(row_value) != TYPE_DICTIONARY:
		return ""

	var row: Dictionary = row_value
	if str(row.get("boss_enemy_id", "")).is_empty():
		return ""

	var active_directions: Array = row.get("active_directions", [])
	if active_directions.is_empty():
		return ""

	return str(active_directions[0])


func _append_path_boss_delay_candidates(candidates: Array, path: Array, direction: String, structure_type: String) -> void:
	if path.size() < 4:
		return

	var preferred_indexes = _boss_delay_path_indexes(path.size())
	for index in preferred_indexes:
		if index <= 0 or index >= path.size() - 1:
			continue

		var path_tile_value = path[index]
		if typeof(path_tile_value) != TYPE_VECTOR2I:
			continue

		var path_tile: Vector2i = path_tile_value
		for offset in _boss_delay_offsets(direction, structure_type):
			candidates.append(path_tile + offset)


func _boss_delay_path_indexes(path_size: int) -> Array[int]:
	var last_open_index = max(1, path_size - 2)
	var anchor = clamp(6, 1, last_open_index)
	var indexes: Array[int] = []
	for index in [
		anchor,
		min(anchor + 1, last_open_index),
		max(anchor - 1, 1),
		min(anchor + 2, last_open_index),
		max(anchor - 2, 1),
	]:
		if not indexes.has(index):
			indexes.append(index)

	return indexes


func _boss_delay_tiles_near_boss(boss_tile: Vector2i, direction: String, structure_type: String) -> Array[Vector2i]:
	var forward = _direction_step_toward_base(direction)
	if forward == Vector2i.ZERO:
		return []

	var anchor = boss_tile + forward + forward
	var tiles: Array[Vector2i] = []
	for offset in _boss_delay_offsets(direction, structure_type):
		tiles.append(anchor + offset)

	return tiles


func _boss_delay_offsets(direction: String, structure_type: String) -> Array[Vector2i]:
	var forward = _direction_step_toward_base(direction)
	if forward == Vector2i.ZERO:
		return []

	var side = Vector2i(-forward.y, forward.x)
	if structure_type == "barricade":
		return [
			Vector2i.ZERO,
			forward,
			side,
			side * -1,
			forward + side,
			forward + side * -1,
			forward * -1,
		]

	return [
		side,
		side * -1,
		forward + side,
		forward + side * -1,
		side + side,
		(side + side) * -1,
		Vector2i.ZERO,
		forward,
	]


func _direction_step_toward_base(direction: String) -> Vector2i:
	match direction:
		"north":
			return Vector2i(0, 1)
		"east":
			return Vector2i(-1, 0)
		"south":
			return Vector2i(0, -1)
		"west":
			return Vector2i(1, 0)
		_:
			return Vector2i.ZERO


func _front_recommendation_should_lead(simulation, player_count: int) -> bool:
	if player_count < 2:
		return false

	if bool(simulation.wave_active):
		return false

	var report = simulation.get_front_defense_report(player_count)
	if not bool(report.get("ok", false)):
		return false

	var direction = str(report.get("weakest_direction", ""))
	if direction.is_empty():
		return false

	var fronts_by_direction: Dictionary = report.get("by_direction", {})
	var front_value = fronts_by_direction.get(direction, {})
	if typeof(front_value) != TYPE_DICTIONARY:
		return false

	var front: Dictionary = front_value
	var pressure: Dictionary = front.get("pressure", {})
	return int(front.get("boss_base_hits", 0)) > 0 \
		or int(front.get("base_hits", 0)) > 0 \
		or int(front.get("structures_destroyed", 0)) > 0 \
		or int(pressure.get("boss_count", 0)) > 0


func _append_front_recommendation_candidates(
	candidates: Array,
	simulation,
	player_count: int,
	class_id: String,
	structure_type: String
) -> void:
	var report = simulation.get_front_recommendation_tiles(player_count, structure_type, class_id)
	if not bool(report.get("ok", false)):
		return

	var recommendation_tiles: Dictionary = report.get("tiles", {})
	var recommendations: Array = []
	for recommendation_value in recommendation_tiles.values():
		if typeof(recommendation_value) == TYPE_DICTIONARY:
			recommendations.append(recommendation_value)

	recommendations.sort_custom(_front_recommendation_candidate_is_before)
	for recommendation_value in recommendations:
		var recommendation: Dictionary = recommendation_value
		var tile_value = recommendation.get("tile", Vector2i(-1, -1))
		if typeof(tile_value) == TYPE_VECTOR2I:
			candidates.append(tile_value)


func _front_recommendation_candidate_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	var left_score = int(left.get("path_index", 0)) * 100 + int(left.get("distance_from_path", 0))
	var right_score = int(right.get("path_index", 0)) * 100 + int(right.get("distance_from_path", 0))
	if left_score == right_score:
		return _tile_key(left.get("tile", Vector2i(-1, -1))) < _tile_key(right.get("tile", Vector2i(-1, -1)))

	return left_score < right_score


func _append_guard_line_candidates(candidates: Array, simulation, player_count: int, structure_type: String) -> void:
	for direction in simulation.get_active_directions(player_count):
		candidates.append_array(_front_candidate_tiles(str(direction), structure_type))


func _front_candidate_tiles(direction: String, structure_type: String) -> Array:
	match direction:
		"east":
			if structure_type == "barricade":
				return [Vector2i(18, 10), Vector2i(17, 10), Vector2i(16, 10), Vector2i(18, 9), Vector2i(18, 11)]
			return [Vector2i(15, 10), Vector2i(16, 9), Vector2i(16, 11), Vector2i(14, 10), Vector2i(17, 9)]
		"north":
			if structure_type == "barricade":
				return [Vector2i(10, 2), Vector2i(10, 3), Vector2i(10, 4), Vector2i(9, 3), Vector2i(11, 3)]
			return [Vector2i(10, 5), Vector2i(9, 4), Vector2i(11, 4), Vector2i(10, 6), Vector2i(8, 5)]
		"west":
			if structure_type == "barricade":
				return [Vector2i(2, 10), Vector2i(3, 10), Vector2i(4, 10), Vector2i(3, 9), Vector2i(3, 11)]
			return [Vector2i(5, 10), Vector2i(4, 9), Vector2i(4, 11), Vector2i(6, 10), Vector2i(5, 8)]
		"south":
			if structure_type == "barricade":
				return [Vector2i(10, 18), Vector2i(10, 17), Vector2i(10, 16), Vector2i(9, 17), Vector2i(11, 17)]
			return [Vector2i(10, 15), Vector2i(9, 16), Vector2i(11, 16), Vector2i(10, 14), Vector2i(12, 15)]
		_:
			return []


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


func _append_killzone_candidates(candidates: Array, simulation, player_count: int, structure_type: String) -> void:
	_append_guard_line_candidates(candidates, simulation, player_count, structure_type)

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


func _append_cluster_candidates(candidates: Array, simulation, player_count: int, structure_type: String) -> void:
	for structure in simulation.get_structure_tiles().values():
		var tile: Vector2i = structure["tile"]
		candidates.append(tile + Vector2i(1, 0))
		candidates.append(tile + Vector2i(-1, 0))
		candidates.append(tile + Vector2i(0, 1))
		candidates.append(tile + Vector2i(0, -1))

	if candidates.is_empty():
		_append_killzone_candidates(candidates, simulation, player_count, structure_type)


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
	var class_weakness_summaries = _build_class_weakness_summaries(cases)
	var alpha_focus_queue = _build_alpha_focus_queue(cases)
	var next_action_queue = _build_next_action_queue(cases, aggregate, failure_lines, flagged_cases, alpha_focus_queue)
	return {
		"schema_version": REPORT_SCHEMA_VERSION,
		"generated_at_unix": Time.get_unix_time_from_system(),
		"ok": failure_lines.is_empty(),
		"case_count": cases.size(),
		"pass_count": aggregate.get("pass_count", 0),
		"fail_count": aggregate.get("fail_count", 0),
		"failures": failure_lines.duplicate(),
		"aggregate": aggregate,
		"recommendation_contrast_samples": aggregate.get("recommendation_contrast_samples", []).duplicate(true),
		"wave_stack_tempo_samples": aggregate.get("wave_stack_tempo_samples", []).duplicate(true),
		"balance_notes": _build_balance_notes(cases, aggregate, failure_lines, weakest_case, strongest_case, flagged_cases),
		"case_matrix": _build_case_matrix(cases),
		"class_weakness_summaries": class_weakness_summaries,
		"alpha_focus_queue": alpha_focus_queue,
		"next_action_queue": next_action_queue,
		"front_breakdown": _build_front_breakdown(cases),
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
			"primary_direction": str(outcome.get("primary_direction", "")),
			"failure_reason": str(case_dictionary.get("failure_reason", "")),
			"killed": int(stats.get("killed", 0)),
			"gold_gained": int(stats.get("gold_gained", 0)),
			"shop_cards_removed": int(stats.get("shop_cards_removed", 0)),
		}
		matrix[class_key] = class_row

	return matrix


func _build_front_breakdown(cases: Array) -> Array:
	var front_breakdown: Array = []
	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		front_breakdown.append(_case_snapshot(case_dictionary, _case_margin_score(case_dictionary)))

	return front_breakdown


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


func _build_class_weakness_summaries(cases: Array) -> Array[Dictionary]:
	var grouped_cases = {}
	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		var class_key = str(case_dictionary.get("class_id", "default"))
		if class_key.is_empty():
			class_key = "default"
		var class_cases: Array = grouped_cases.get(class_key, [])
		class_cases.append(case_dictionary)
		grouped_cases[class_key] = class_cases

	var summaries: Array[Dictionary] = []
	var class_keys: Array[String] = []
	for class_key in grouped_cases.keys():
		class_keys.append(str(class_key))
	class_keys.sort()

	for class_key in class_keys:
		summaries.append(_class_weakness_summary(class_key, grouped_cases.get(class_key, [])))

	return summaries


func _build_alpha_focus_queue(cases: Array) -> Array[Dictionary]:
	var selected_by_class = {}
	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		var class_key = str(case_dictionary.get("class_id", "default"))
		if class_key.is_empty():
			class_key = "default"
		var entry = _alpha_focus_entry(case_dictionary)
		var current: Dictionary = selected_by_class.get(class_key, {})
		if current.is_empty() or _alpha_focus_entry_is_before(entry, current):
			selected_by_class[class_key] = entry

	var queue: Array[Dictionary] = []
	for entry_value in selected_by_class.values():
		if typeof(entry_value) == TYPE_DICTIONARY:
			queue.append(entry_value)

	queue.sort_custom(_alpha_focus_entry_is_before)
	if queue.size() > ALPHA_FOCUS_QUEUE_LIMIT:
		queue.resize(ALPHA_FOCUS_QUEUE_LIMIT)

	for index in range(queue.size()):
		var entry: Dictionary = queue[index]
		entry["rank"] = index + 1
		queue[index] = entry

	return queue


func _build_next_action_queue(cases: Array, aggregate: Dictionary, failure_lines: Array, flagged_cases: Dictionary, alpha_focus_queue: Array) -> Array:
	var queue: Array = []
	var seen = {}

	_append_failure_next_actions(queue, seen, cases, failure_lines)
	_append_alpha_focus_next_actions(queue, seen, alpha_focus_queue)
	_append_flagged_case_next_actions(queue, seen, flagged_cases)
	_append_aggregate_next_actions(queue, seen, aggregate)

	queue.sort_custom(_next_action_entry_is_before)
	if queue.size() > NEXT_ACTION_QUEUE_LIMIT:
		queue.resize(NEXT_ACTION_QUEUE_LIMIT)

	for index in range(queue.size()):
		var entry: Dictionary = queue[index]
		entry["rank"] = index + 1
		queue[index] = entry

	return queue


func _append_failure_next_actions(queue: Array, seen: Dictionary, cases: Array, failure_lines: Array) -> void:
	var failure_reason_counts = _failure_reason_counts(cases)
	if failure_reason_counts.is_empty() and failure_lines.is_empty():
		return

	if failure_reason_counts.is_empty():
		_append_next_action(queue, seen, {
			"key": "failure|unknown",
			"priority": 11000 + failure_lines.size() * 50,
			"severity": "fix",
			"signal": "run failure",
			"hypothesis": "Autoplay has failing checks before alpha coverage can be trusted.",
			"check": "open the failing case summary and inspect the latest decision trace",
			"metric": "%s failing check(s)" % failure_lines.size(),
			"source": "failures",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})
		return

	for reason in _sorted_count_keys(failure_reason_counts):
		var count = int(failure_reason_counts.get(reason, 0))
		_append_next_action(queue, seen, {
			"key": "failure|%s" % reason,
			"priority": 11000 + count * 50,
			"severity": "fix",
			"signal": "run failure",
			"hypothesis": "Failure reason %s is blocking alpha coverage." % reason,
			"check": _alpha_probe_for_failure(str(reason)),
			"metric": "%s case(s)" % count,
			"source": "failures",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})


func _append_alpha_focus_next_actions(queue: Array, seen: Dictionary, alpha_focus_queue: Array) -> void:
	for entry_value in alpha_focus_queue:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		var signal_text = str(entry.get("primary_signal", "representative pass"))
		var case_label = _next_action_case_label(entry)
		_append_next_action(queue, seen, {
			"key": "alpha|%s|%s|%s|%s" % [
				entry.get("class_id", "default"),
				entry.get("player_count", 0),
				entry.get("direction", ""),
				signal_text,
			],
			"priority": int(entry.get("score", 0)) + 100,
			"severity": _next_action_severity_for_signal(signal_text),
			"signal": signal_text,
			"hypothesis": "%s may reveal %s during a human replay." % [
				case_label,
				signal_text,
			],
			"check": str(entry.get("next_probe", "")),
			"metric": str(entry.get("evidence", "")),
			"source": "alpha_focus_queue",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
			"class_id": str(entry.get("class_id", "default")),
			"class_label": str(entry.get("class_label", "Default")),
			"player_count": int(entry.get("player_count", 0)),
			"direction": str(entry.get("direction", "")),
		})


func _append_flagged_case_next_actions(queue: Array, seen: Dictionary, flagged_cases: Dictionary) -> void:
	var zero_kill_cases: Array = flagged_cases.get("zero_kill_cases", [])
	if not zero_kill_cases.is_empty():
		_append_next_action(queue, seen, {
			"key": "flag|zero_kill",
			"priority": 9000 + zero_kill_cases.size() * 40,
			"severity": "fix",
			"signal": "zero kills",
			"hypothesis": "Some autoplay cases are not producing any kills.",
			"check": "verify opening damage access, card target rules, and first structure placement",
			"metric": _format_case_list(zero_kill_cases),
			"source": "flagged_cases",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})

	var low_base_hp_cases: Array = flagged_cases.get("low_base_hp_cases", [])
	if not low_base_hp_cases.is_empty():
		_append_next_action(queue, seen, {
			"key": "flag|low_base_hp",
			"priority": 8100 + low_base_hp_cases.size() * 30,
			"severity": "danger",
			"signal": "low base margin",
			"hypothesis": "Passing cases are reaching the end with too little base HP.",
			"check": "replay the weakest case and watch first contact before changing raw damage",
			"metric": _format_case_list(low_base_hp_cases),
			"source": "flagged_cases",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})

	var high_leak_cases: Array = flagged_cases.get("high_leak_cases", [])
	if not high_leak_cases.is_empty():
		_append_next_action(queue, seen, {
			"key": "flag|high_leaks",
			"priority": 7100 + high_leak_cases.size() * 30,
			"severity": "watch",
			"signal": "repeated base leaks",
			"hypothesis": "Some passing cases leak too many enemies for the intended tension curve.",
			"check": "compare slow, taunt, and first bend placement on the leaking route",
			"metric": _format_case_list(high_leak_cases),
			"source": "flagged_cases",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})


func _append_aggregate_next_actions(queue: Array, seen: Dictionary, aggregate: Dictionary) -> void:
	var card_block_reasons: Dictionary = aggregate.get("card_block_reasons", {})
	if not card_block_reasons.is_empty():
		_append_next_action(queue, seen, {
			"key": "aggregate|card_blockers",
			"priority": 5200 + _direction_count_total(card_block_reasons) * 10,
			"severity": "watch",
			"signal": "card play blockers",
			"hypothesis": "Blocked card plays may be hiding hand, mana, or target readability issues.",
			"check": "inspect mana, draw, and target availability before card power tuning",
			"metric": _format_counts(card_block_reasons),
			"source": "aggregate",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})

	var recommendation_decisions = int(aggregate.get("recommendation_decisions", 0))
	var recommendation_followed = int(aggregate.get("recommendation_followed", 0))
	if recommendation_decisions > 0 and recommendation_followed < recommendation_decisions:
		_append_next_action(queue, seen, {
			"key": "aggregate|recommendation_mismatch",
			"priority": 4800 + (recommendation_decisions - recommendation_followed) * 20,
			"severity": "watch",
			"signal": "recommendation mismatch",
			"hypothesis": "Autoplay is ignoring some recommendation-backed choices.",
			"check": "compare fallback choice with reward, artifact, and shop recommendation reports",
			"metric": "%s | %s" % [
				"followed %s/%s" % [recommendation_followed, recommendation_decisions],
				_recommendation_choice_type_summary(aggregate),
			],
			"source": "aggregate",
			"document": "docs/UX_AND_SCREEN_FLOWS.md",
		})

	var wave_stack_tempo_moments = int(aggregate.get("wave_stack_tempo_moments", 0))
	if wave_stack_tempo_moments > 0:
		_append_next_action(queue, seen, {
			"key": "aggregate|wave_stack_tempo",
			"priority": 4200 + wave_stack_tempo_moments * 20,
			"severity": "observe",
			"signal": "wave stack tempo",
			"hypothesis": "Pulled waves need a human read as pacing pressure, not reward efficiency.",
			"check": "review moment_wave_stack_tempo samples and verify the pull reduced waiting without forcing bonus expectations",
			"metric": "%s moment(s) | states %s | hold tags %s" % [
				wave_stack_tempo_moments,
				_format_counts(aggregate.get("wave_stack_tempo_states", {})),
				_format_counts(aggregate.get("wave_stack_tempo_hold_tags", {})),
			],
			"source": "aggregate",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})

	var recommendation_contrast_samples: Array = aggregate.get("recommendation_contrast_samples", [])
	if not recommendation_contrast_samples.is_empty():
		_append_next_action(queue, seen, {
			"key": "aggregate|recommendation_contrast_samples",
			"priority": 3900 + min(recommendation_contrast_samples.size(), RECOMMENDATION_CONTRAST_SAMPLE_LIMIT) * 10,
			"severity": "observe",
			"signal": "recommendation contrast",
			"hypothesis": "Recommendation-backed choices need a human Run A/Run B read before tuning rewards or shops.",
			"check": "review recommendation contrast samples and confirm each suggestion remains a discussion prompt",
			"metric": "%s sample(s) | %s" % [
				recommendation_contrast_samples.size(),
				_recommendation_choice_type_summary(aggregate),
			],
			"source": "aggregate",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})

	var boss_warning_decisions = int(aggregate.get("boss_part_warning_decisions", 0))
	var boss_warning_answered = int(aggregate.get("boss_part_warning_answered", 0))
	if boss_warning_decisions > 0 and boss_warning_answered < boss_warning_decisions:
		_append_next_action(queue, seen, {
			"key": "aggregate|boss_warning_gap",
			"priority": 6800 + (boss_warning_decisions - boss_warning_answered) * 30,
			"severity": "danger",
			"signal": "boss warning gap",
			"hypothesis": "Boss part warnings may be visible but not consistently actionable.",
			"check": "replay boss warning cases and inspect damage, repair, and delay options before tuning boss HP",
			"metric": "answered %s/%s" % [boss_warning_answered, boss_warning_decisions],
			"source": "aggregate",
			"document": "docs/UX_AND_SCREEN_FLOWS.md",
		})

	var class_results: Dictionary = aggregate.get("class_results", {})
	var class_spread = _bucket_average_base_hp_spread(class_results)
	if float(class_spread.get("spread", 0.0)) >= CLASS_BASE_HP_SPREAD_WARNING:
		_append_next_action(queue, seen, {
			"key": "aggregate|class_spread",
			"priority": 4300 + int(float(class_spread.get("spread", 0.0))),
			"severity": "watch",
			"signal": "class spread",
			"hypothesis": "Class outcomes are spreading enough to require a targeted comparison pass.",
			"check": "compare highest and lowest class cases before changing shared enemy stats",
			"metric": "%.1f HP spread: %s highest, %s lowest" % [
				float(class_spread.get("spread", 0.0)),
				class_spread.get("highest_key", "unknown"),
				class_spread.get("lowest_key", "unknown"),
			],
			"source": "aggregate",
			"document": "docs/PLAYTEST_AND_BALANCE.md",
		})


func _append_next_action(queue: Array, seen: Dictionary, action: Dictionary) -> void:
	var key = str(action.get("key", ""))
	if key.is_empty():
		key = "%s|%s" % [
			action.get("signal", "action"),
			action.get("metric", ""),
		]
	if seen.has(key):
		return

	seen[key] = true
	action["rank"] = 0
	queue.append(action)


func _next_action_entry_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	var left_priority = int(left.get("priority", 0))
	var right_priority = int(right.get("priority", 0))
	if left_priority != right_priority:
		return left_priority > right_priority

	return str(left.get("hypothesis", "")) < str(right.get("hypothesis", ""))


func _next_action_case_label(entry: Dictionary) -> String:
	var direction = str(entry.get("direction", entry.get("primary_direction", "")))
	var direction_text = "" if direction.is_empty() else "@%s" % direction
	return "%s %sP%s" % [
		entry.get("class_label", "Default"),
		entry.get("player_count", 0),
		direction_text,
	]


func _next_action_severity_for_signal(signal_text: String) -> String:
	if signal_text == "run failure":
		return "fix"
	if ["low base margin", "boss warning gap"].has(signal_text):
		return "danger"
	if signal_text == "representative pass":
		return "observe"
	return "watch"


func _alpha_focus_entry(case_result: Dictionary) -> Dictionary:
	var focus_signal = _alpha_focus_signal(case_result)
	var stats: Dictionary = case_result.get("stats", {})
	var outcome: Dictionary = case_result.get("outcome", {})
	var direction = str(focus_signal.get("direction", outcome.get("primary_direction", "")))
	var entry = {
		"rank": 0,
		"class_id": str(case_result.get("class_id", "default")),
		"class_label": str(case_result.get("class_label", "Default")),
		"player_count": int(case_result.get("player_count", 0)),
		"completed_rounds": int(case_result.get("completed_rounds", 0)),
		"base_hp": int(case_result.get("base_hp", 0)),
		"ok": bool(case_result.get("ok", false)),
		"failure_reason": str(case_result.get("failure_reason", "")),
		"primary_signal": str(focus_signal.get("primary_signal", "representative pass")),
		"evidence": str(focus_signal.get("evidence", "")),
		"next_probe": str(focus_signal.get("next_probe", "")),
		"direction": direction,
		"outcome_focus": str(outcome.get("focus", "unknown")),
		"base_hits": int(stats.get("base_hits", 0)),
		"structures_destroyed": int(stats.get("structures_destroyed", 0)),
		"planned_collapses": int(stats.get("planned_collapses", 0)),
		"planned_collapse_damage": int(stats.get("planned_collapse_damage", 0)),
		"score": int(focus_signal.get("score", 0)),
	}
	entry["analysis_cards"] = _alpha_focus_analysis_cards(entry)
	return entry


func _alpha_focus_signal(case_result: Dictionary) -> Dictionary:
	var stats: Dictionary = case_result.get("stats", {})
	var outcome: Dictionary = case_result.get("outcome", {})
	var base_hp = int(case_result.get("base_hp", 0))
	var completed_rounds = int(case_result.get("completed_rounds", 0))
	var base_hits = int(stats.get("base_hits", 0))
	var base_damage = int(stats.get("base_damage", 0))
	var structures_destroyed = int(stats.get("structures_destroyed", 0))
	var planned_collapses = int(stats.get("planned_collapses", 0))
	var planned_collapse_damage = int(stats.get("planned_collapse_damage", 0))
	var unplanned_structures_destroyed = max(0, structures_destroyed - planned_collapses)
	var direction = _top_count_key(stats.get("base_hits_by_direction", {}))
	if direction.is_empty():
		direction = str(outcome.get("primary_direction", ""))
	var card_block_reasons = _case_card_block_reason_counts(case_result)
	var recommendation_stats = _case_recommendation_stats(case_result)
	var recommendation_decisions = int(recommendation_stats.get("decisions", 0))
	var recommendation_followed = int(recommendation_stats.get("followed", 0))
	var base_score = max(0, 100 - base_hp) + base_hits * 12 + unplanned_structures_destroyed * 8 + planned_collapses * 2

	if not bool(case_result.get("ok", false)):
		var failure_reason = str(case_result.get("failure_reason", "check_failed"))
		return {
			"primary_signal": "run failure",
			"evidence": "failed at R%s, HP %s, reason %s" % [
				completed_rounds,
				base_hp,
				failure_reason,
			],
			"next_probe": _alpha_probe_for_failure(failure_reason),
			"direction": direction,
			"score": 10000 + base_score,
		}
	if base_hp < LOW_BASE_HP_WARNING:
		return {
			"primary_signal": "low base margin",
			"evidence": "HP %s with %s base hit(s)%s" % [
				base_hp,
				base_hits,
				" on %s" % direction if not direction.is_empty() else "",
			],
			"next_probe": "watch first contact and route extension before changing raw damage",
			"direction": direction,
			"score": 8000 + (LOW_BASE_HP_WARNING - base_hp) * 30 + base_score,
		}
	if base_hits >= HIGH_BASE_HIT_WARNING:
		return {
			"primary_signal": "repeated base leaks",
			"evidence": "%s base hit(s), %s damage%s" % [
				base_hits,
				base_damage,
				" on %s" % direction if not direction.is_empty() else "",
			],
			"next_probe": "test slow, taunt, or the first bend on the leaking route",
			"direction": direction,
			"score": 7000 + base_hits * 20 + base_score,
		}
	if unplanned_structures_destroyed >= 4:
		var lost_direction = _top_count_key(stats.get("structures_destroyed_by_direction", {}))
		if not lost_direction.is_empty():
			direction = lost_direction
		return {
			"primary_signal": "structure churn",
			"evidence": "%s unplanned structure(s) destroyed%s" % [
				unplanned_structures_destroyed,
				" near %s" % direction if not direction.is_empty() else "",
			],
			"next_probe": "split throwaway barricades from protected towers in the opening plan",
			"direction": direction,
			"score": 6000 + unplanned_structures_destroyed * 25 + base_score,
		}
	if planned_collapses >= 4:
		var planned_direction = _top_count_key(stats.get("planned_collapses_by_direction", {}))
		if not planned_direction.is_empty():
			direction = planned_direction
		return {
			"primary_signal": "planned collapse dependency",
			"evidence": "%s planned collapse(s), %s damage%s" % [
				planned_collapses,
				planned_collapse_damage,
				" near %s" % direction if not direction.is_empty() else "",
			],
			"next_probe": "verify rebuild timing before reducing architect barricade value",
			"direction": direction,
			"score": 5600 + planned_collapses * 12 + base_score,
		}
	if not card_block_reasons.is_empty():
		var top_block_reason = _top_count_key(card_block_reasons)
		return {
			"primary_signal": "card play blockers",
			"evidence": "blocked by %s (%s)" % [
				top_block_reason,
				_format_counts(card_block_reasons),
			],
			"next_probe": "inspect mana, draw, and target availability before card power tuning",
			"direction": direction,
			"score": 5000 + _direction_count_total(card_block_reasons) * 10 + base_score,
		}
	if recommendation_decisions > 0 and recommendation_followed < recommendation_decisions:
		return {
			"primary_signal": "recommendation mismatch",
			"evidence": "followed %s/%s recommendation-backed choice(s)" % [
				recommendation_followed,
				recommendation_decisions,
			],
			"next_probe": "compare fallback choice with reward, artifact, and shop reports",
			"direction": direction,
			"score": 4000 + base_score,
		}

	return {
		"primary_signal": "representative pass",
		"evidence": "R%s, HP %s, %s kill(s), %s base hit(s)" % [
			completed_rounds,
			base_hp,
			stats.get("killed", 0),
			base_hits,
		],
		"next_probe": "use this case for class feel and readability checks",
		"direction": direction,
		"score": base_score,
	}


func _alpha_probe_for_failure(failure_reason: String) -> String:
	if ["reward_missing", "reward_claim_failed"].has(failure_reason):
		return "inspect reward settlement before wave pacing changes"
	if failure_reason == "artifact_claim_failed":
		return "inspect artifact offer and equipped artifact state"
	if ["shop_remove_failed", "shop_skip_failed"].has(failure_reason):
		return "inspect shop affordability and deck removal state"
	if failure_reason == "wave_start_failed":
		return "inspect pending rewards and active direction setup"
	if ["round_timeout", "wave_timeout"].has(failure_reason):
		return "inspect pathing, last enemy cleanup, and blocked card decisions"
	return "replay this case and inspect the latest decision trace"


func _alpha_focus_analysis_cards(entry: Dictionary) -> Array[Dictionary]:
	var case_label = "%s %sP" % [
		entry.get("class_label", "Default"),
		entry.get("player_count", 0),
	]
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " on %s" % direction
	return [
		{
			"slot": "result",
			"title": "Result",
			"body": "%s reached R%s with HP %s%s." % [
				case_label,
				entry.get("completed_rounds", 0),
				entry.get("base_hp", 0),
				direction_text,
			],
		},
		{
			"slot": "cause",
			"title": "Cause",
			"body": "%s: %s." % [
				entry.get("primary_signal", "signal"),
				entry.get("evidence", ""),
			],
		},
		{
			"slot": "next",
			"title": "Next Probe",
			"body": str(entry.get("next_probe", "")),
		},
	]


func _alpha_focus_entry_is_before(left_value, right_value) -> bool:
	var left: Dictionary = left_value
	var right: Dictionary = right_value
	var left_score = int(left.get("score", 0))
	var right_score = int(right.get("score", 0))
	if left_score == right_score:
		var left_label = "%s-%s" % [
			left.get("class_label", ""),
			left.get("player_count", 0),
		]
		var right_label = "%s-%s" % [
			right.get("class_label", ""),
			right.get("player_count", 0),
		]
		return left_label < right_label

	return left_score > right_score


func _class_weakness_summary(class_id: String, cases: Array) -> Dictionary:
	var class_label = class_id
	var case_count = 0
	var fail_count = 0
	var completed_rounds_total = 0
	var base_hp_total = 0
	var lowest_base_hp = 0
	var shortest_completed_rounds = 0
	var first_case = true
	var base_hits_total = 0
	var base_damage_total = 0
	var structures_destroyed_total = 0
	var planned_collapses_total = 0
	var planned_collapse_damage_total = 0
	var killed_total = 0
	var boss_base_hits_total = 0
	var focus_counts = {}
	var primary_direction_counts = {}
	var base_hits_by_direction = {}
	var structures_destroyed_by_direction = {}
	var planned_collapses_by_direction = {}
	var card_block_reasons = {}
	var card_block_cases = 0
	var recommendation_decisions = 0
	var recommendation_followed = 0
	var warning_cases: Array = []

	for case_value in cases:
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_value
		class_label = str(case_dictionary.get("class_label", class_label))
		case_count += 1
		if not bool(case_dictionary.get("ok", false)):
			fail_count += 1

		var completed_rounds = int(case_dictionary.get("completed_rounds", 0))
		var base_hp = int(case_dictionary.get("base_hp", 0))
		completed_rounds_total += completed_rounds
		base_hp_total += base_hp
		if first_case or base_hp < lowest_base_hp:
			lowest_base_hp = base_hp
		if first_case or completed_rounds < shortest_completed_rounds:
			shortest_completed_rounds = completed_rounds
		first_case = false

		var stats: Dictionary = case_dictionary.get("stats", {})
		base_hits_total += int(stats.get("base_hits", 0))
		base_damage_total += int(stats.get("base_damage", 0))
		structures_destroyed_total += int(stats.get("structures_destroyed", 0))
		planned_collapses_total += int(stats.get("planned_collapses", 0))
		planned_collapse_damage_total += int(stats.get("planned_collapse_damage", 0))
		killed_total += int(stats.get("killed", 0))
		boss_base_hits_total += _direction_count_total(stats.get("boss_base_hits_by_direction", {}))
		_add_count_totals(base_hits_by_direction, _dictionary_value(stats.get("base_hits_by_direction", {})))
		_add_count_totals(structures_destroyed_by_direction, _dictionary_value(stats.get("structures_destroyed_by_direction", {})))
		_add_count_totals(planned_collapses_by_direction, _dictionary_value(stats.get("planned_collapses_by_direction", {})))

		var outcome: Dictionary = case_dictionary.get("outcome", {})
		_increment_count(focus_counts, str(outcome.get("focus", "unknown")))
		var primary_direction = str(outcome.get("primary_direction", ""))
		if not primary_direction.is_empty():
			_increment_count(primary_direction_counts, primary_direction)

		var case_card_block_reasons = _case_card_block_reason_counts(case_dictionary)
		if not case_card_block_reasons.is_empty():
			card_block_cases += 1
			_add_count_totals(card_block_reasons, case_card_block_reasons)

		var recommendation_stats = _case_recommendation_stats(case_dictionary)
		recommendation_decisions += int(recommendation_stats.get("decisions", 0))
		recommendation_followed += int(recommendation_stats.get("followed", 0))

		if (not bool(case_dictionary.get("ok", false))) or base_hp < LOW_BASE_HP_WARNING or int(stats.get("base_hits", 0)) >= HIGH_BASE_HIT_WARNING:
			warning_cases.append("%sP R%s HP%s" % [
				case_dictionary.get("player_count", 0),
				completed_rounds,
				base_hp,
			])

	var summary = {
		"class_id": class_id,
		"class_label": class_label,
		"case_count": case_count,
		"fail_count": fail_count,
		"average_completed_rounds": float(completed_rounds_total) / float(max(1, case_count)),
		"average_base_hp": float(base_hp_total) / float(max(1, case_count)),
		"lowest_base_hp": lowest_base_hp,
		"shortest_completed_rounds": shortest_completed_rounds,
		"base_hits": base_hits_total,
		"base_damage": base_damage_total,
		"structures_destroyed": structures_destroyed_total,
		"planned_collapses": planned_collapses_total,
		"planned_collapse_damage": planned_collapse_damage_total,
		"killed": killed_total,
		"boss_base_hits": boss_base_hits_total,
		"focus_counts": focus_counts,
		"primary_direction_counts": primary_direction_counts,
		"base_hits_by_direction": base_hits_by_direction,
		"structures_destroyed_by_direction": structures_destroyed_by_direction,
		"planned_collapses_by_direction": planned_collapses_by_direction,
		"card_block_reasons": card_block_reasons,
		"card_block_cases": card_block_cases,
		"recommendation_decisions": recommendation_decisions,
		"recommendation_followed": recommendation_followed,
		"warning_cases": warning_cases,
	}
	_apply_class_weakness_labels(summary)
	return summary


func _apply_class_weakness_labels(summary: Dictionary) -> void:
	var fail_count = int(summary.get("fail_count", 0))
	var case_count = max(1, int(summary.get("case_count", 0)))
	var lowest_base_hp = int(summary.get("lowest_base_hp", 0))
	var base_hits = int(summary.get("base_hits", 0))
	var structures_destroyed = int(summary.get("structures_destroyed", 0))
	var planned_collapses = int(summary.get("planned_collapses", 0))
	var planned_collapse_damage = int(summary.get("planned_collapse_damage", 0))
	var unplanned_structures_destroyed = max(0, structures_destroyed - planned_collapses)
	var card_block_cases = int(summary.get("card_block_cases", 0))
	var recommendation_decisions = int(summary.get("recommendation_decisions", 0))
	var recommendation_followed = int(summary.get("recommendation_followed", 0))
	var top_direction = _top_count_key(summary.get("base_hits_by_direction", {}))
	if top_direction.is_empty():
		top_direction = _top_count_key(summary.get("primary_direction_counts", {}))

	if fail_count > 0:
		summary["primary_signal"] = "run failure"
		summary["evidence"] = "%s/%s case(s) failed, lowest HP %s" % [fail_count, case_count, lowest_base_hp]
		summary["next_probe"] = "replay the failed case and inspect the last pending reward or wave start"
	elif lowest_base_hp < LOW_BASE_HP_WARNING:
		summary["primary_signal"] = "low base margin"
		summary["evidence"] = "lowest HP %s, base hits %s%s" % [
			lowest_base_hp,
			base_hits,
			" at %s" % top_direction if not top_direction.is_empty() else "",
		]
		summary["next_probe"] = "check first contact timing and route extension on the pressured front"
	elif base_hits >= HIGH_BASE_HIT_WARNING:
		summary["primary_signal"] = "repeated base leaks"
		summary["evidence"] = "base hits %s%s, damage %s" % [
			base_hits,
			" at %s" % top_direction if not top_direction.is_empty() else "",
			summary.get("base_damage", 0),
		]
		summary["next_probe"] = "test slow, taunt, or early bend placement on the leaking route"
	elif unplanned_structures_destroyed >= case_count * 4:
		summary["primary_signal"] = "structure churn"
		summary["evidence"] = "unplanned structures lost %s across %s case(s)" % [unplanned_structures_destroyed, case_count]
		summary["next_probe"] = "separate throwaway barricades from protected towers in the opening plan"
	elif planned_collapses >= case_count * 4:
		summary["primary_signal"] = "planned collapse dependency"
		summary["evidence"] = "%s planned collapse(s), %s damage across %s case(s)" % [
			planned_collapses,
			planned_collapse_damage,
			case_count,
		]
		summary["next_probe"] = "verify rebuild timing before reducing architect barricade value"
	elif card_block_cases > 0:
		var top_block_reason = _top_count_key(summary.get("card_block_reasons", {}))
		summary["primary_signal"] = "card play blockers"
		summary["evidence"] = "%s case(s) saw blockers%s" % [
			card_block_cases,
			": %s" % top_block_reason if not top_block_reason.is_empty() else "",
		]
		summary["next_probe"] = "inspect mana, draw, and target availability before changing card power"
	elif recommendation_decisions > 0 and recommendation_followed < recommendation_decisions:
		summary["primary_signal"] = "recommendation mismatch"
		summary["evidence"] = "followed %s/%s recommendation-backed choices" % [
			recommendation_followed,
			recommendation_decisions,
		]
		summary["next_probe"] = "compare autoplay choice fallback with reward and shop recommendation reports"
	else:
		summary["primary_signal"] = "no urgent weakness"
		summary["evidence"] = "avg HP %.1f, base hits %s, structures lost %s" % [
			float(summary.get("average_base_hp", 0.0)),
			base_hits,
			structures_destroyed,
		]
		summary["next_probe"] = "use human alpha time on readability and class feel"


func _build_balance_notes(cases: Array, aggregate: Dictionary, failure_lines: Array, weakest_case: Dictionary, strongest_case: Dictionary, flagged_cases: Dictionary) -> Array[String]:
	var notes: Array[String] = []
	if cases.is_empty():
		notes.append("No autoplay cases ran.")
		return notes

	if not failure_lines.is_empty():
		notes.append("%s failing check(s) need attention before alpha testing." % failure_lines.size())
		var failure_reason_counts = _failure_reason_counts(cases)
		if not failure_reason_counts.is_empty():
			notes.append("Failure reasons: %s." % _format_counts(failure_reason_counts))

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

	var card_block_reasons: Dictionary = aggregate.get("card_block_reasons", {})
	if not card_block_reasons.is_empty():
		notes.append("Card play blockers: %s." % _format_counts(card_block_reasons))
		if int(card_block_reasons.get("hand_empty", 0)) > 0:
			notes.append("Hand-empty blockers appear in %s case(s); review draw pacing, reward destination, or autoplay card spend before tuning raw damage." % aggregate.get("card_block_cases", 0))

	var recommendation_decisions = int(aggregate.get("recommendation_decisions", 0))
	var recommendation_followed = int(aggregate.get("recommendation_followed", 0))
	if recommendation_decisions > 0 and recommendation_followed < recommendation_decisions:
		notes.append("Autoplay followed %s/%s available recommendations (%s); inspect recommendation decisions before trusting aggregate balance." % [
			recommendation_followed,
			recommendation_decisions,
			_recommendation_choice_type_summary(aggregate),
		])
	elif recommendation_decisions > 0:
		notes.append("Autoplay followed all %s available recommendations (%s)." % [
			recommendation_decisions,
			_recommendation_choice_type_summary(aggregate),
		])

	var recommendation_contrast_sample_count = int(aggregate.get("recommendation_contrast_sample_count", 0))
	if recommendation_contrast_sample_count > 0:
		notes.append("Recommendation contrast samples captured: %s. Use Run A/Run B prompts to check that suggestions remain discussion starters." % recommendation_contrast_sample_count)

	var wave_stack_tempo_moments = int(aggregate.get("wave_stack_tempo_moments", 0))
	if wave_stack_tempo_moments > 0:
		notes.append("Wave stack tempo moments captured: %s (%s). Read these as pacing pressure only; do not convert them into gold, rarity, or card-choice bonuses." % [
			wave_stack_tempo_moments,
			_format_counts(aggregate.get("wave_stack_tempo_states", {})),
		])

	var boss_warning_decisions = int(aggregate.get("boss_part_warning_decisions", 0))
	var boss_warning_answered = int(aggregate.get("boss_part_warning_answered", 0))
	if boss_warning_decisions > 0 and boss_warning_answered < boss_warning_decisions:
		notes.append("Boss part warnings answered %s/%s; inspect boss warning decisions before tuning boss HP." % [
			boss_warning_answered,
			boss_warning_decisions,
		])
	elif boss_warning_decisions > 0:
		notes.append("Autoplay answered all %s recorded boss part warnings." % boss_warning_decisions)

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


func _failure_reason_counts(cases: Array) -> Dictionary:
	var counts = {}
	for case_result in cases:
		if typeof(case_result) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_result
		if bool(case_dictionary.get("ok", false)):
			continue

		var reason = str(case_dictionary.get("failure_reason", "check_failed"))
		if reason.is_empty():
			reason = "check_failed"
		_increment_count(counts, reason)
	return counts


func _case_card_block_reason_counts(case_result: Dictionary) -> Dictionary:
	var counts = {}
	var trace: Array = case_result.get("decision_trace", [])
	for decision_value in trace:
		if typeof(decision_value) != TYPE_DICTIONARY:
			continue

		var decision: Dictionary = decision_value
		if str(decision.get("action", "")) != "play_blocked":
			continue

		var reason = str(decision.get("top_reason", "unknown"))
		if reason.is_empty():
			reason = "unknown"
		_increment_count(counts, reason)

	return counts


func _case_recommendation_stats(case_result: Dictionary) -> Dictionary:
	var stats = {
		"decisions": 0,
		"followed": 0,
		"by_action": {},
		"by_choice_type": {},
		"contrast_samples": [],
	}
	var trace: Array = case_result.get("decision_trace", [])
	for decision_value in trace:
		if typeof(decision_value) != TYPE_DICTIONARY:
			continue

		var decision: Dictionary = decision_value
		if not bool(decision.get("recommendation_available", false)):
			continue

		stats["decisions"] = int(stats.get("decisions", 0)) + 1
		if bool(decision.get("followed_recommendation", false)):
			stats["followed"] = int(stats.get("followed", 0)) + 1

		var action = str(decision.get("action", "decision"))
		if action.is_empty():
			action = "decision"
		var by_action: Dictionary = stats["by_action"]
		var action_stats: Dictionary = by_action.get(action, {
			"decisions": 0,
			"followed": 0,
		})
		action_stats["decisions"] = int(action_stats.get("decisions", 0)) + 1
		if bool(decision.get("followed_recommendation", false)):
			action_stats["followed"] = int(action_stats.get("followed", 0)) + 1
		by_action[action] = action_stats
		stats["by_action"] = by_action

		var choice_type = _recommendation_choice_type_for_decision(decision)
		var by_choice_type: Dictionary = stats["by_choice_type"]
		var choice_stats: Dictionary = by_choice_type.get(choice_type, {
			"decisions": 0,
			"followed": 0,
		})
		choice_stats["decisions"] = int(choice_stats.get("decisions", 0)) + 1
		if bool(decision.get("followed_recommendation", false)):
			choice_stats["followed"] = int(choice_stats.get("followed", 0)) + 1
		by_choice_type[choice_type] = choice_stats
		stats["by_choice_type"] = by_choice_type

		var contrast_samples: Array = stats.get("contrast_samples", [])
		if contrast_samples.size() < RECOMMENDATION_CONTRAST_SAMPLE_LIMIT:
			contrast_samples.append(_recommendation_contrast_sample(case_result, decision, choice_type))
		stats["contrast_samples"] = contrast_samples

	return stats


func _case_wave_stack_tempo_moment(case_result: Dictionary) -> Dictionary:
	var moment_value = case_result.get("wave_stack_tempo_moment", {})
	if typeof(moment_value) == TYPE_DICTIONARY:
		var moment: Dictionary = moment_value
		if bool(moment.get("ok", false)) and str(moment.get("event", "")) == "moment_wave_stack_tempo":
			return moment.duplicate(true)

	var trace: Array = case_result.get("decision_trace", [])
	for index in range(trace.size() - 1, -1, -1):
		var decision_value = trace[index]
		if typeof(decision_value) != TYPE_DICTIONARY:
			continue

		var decision: Dictionary = decision_value
		if str(decision.get("action", "")) != "wave_stack":
			continue

		return {
			"ok": true,
			"event": "moment_wave_stack_tempo",
			"state": str(decision.get("tempo_moment_state", "watching")),
			"summary": str(decision.get("tempo_moment_summary", "")),
			"pulledRounds": [int(decision.get("pulled_round", 0))],
			"stackDepth": int(decision.get("stack_depth", 0)),
			"holdTags": [],
			"noBonusRewards": true,
			"tempoOnly": true,
		}

	return {}


func _wave_stack_tempo_sample(case_result: Dictionary, moment: Dictionary) -> Dictionary:
	var stats: Dictionary = case_result.get("stats", {})
	var outcome: Dictionary = case_result.get("outcome", {})
	return {
		"class_id": str(case_result.get("class_id", "default")),
		"class_label": str(case_result.get("class_label", "Default")),
		"player_count": int(case_result.get("player_count", 0)),
		"completed_rounds": int(case_result.get("completed_rounds", 0)),
		"base_hp": int(case_result.get("base_hp", 0)),
		"primary_direction": str(moment.get("primaryDirection", outcome.get("primary_direction", ""))),
		"state": str(moment.get("state", "unknown")),
		"pulled_rounds": _string_values(moment.get("pulledRounds", [])),
		"stack_depth": int(moment.get("stackDepth", 0)),
		"base_damage_delta": int(moment.get("baseDamageDelta", 0)),
		"base_hits_delta": int(moment.get("baseHitsDelta", 0)),
		"structures_destroyed_delta": int(moment.get("structuresDestroyedDelta", 0)),
		"hold_tags": _string_values(moment.get("holdTags", [])),
		"summary": str(moment.get("summary", "")),
		"no_bonus_rewards": bool(moment.get("noBonusRewards", true)),
		"tempo_only": bool(moment.get("tempoOnly", true)),
		"case_wave_stack_count": int(stats.get("wave_stacks", 0)),
	}


func _recommendation_contrast_sample(case_result: Dictionary, decision: Dictionary, choice_type: String) -> Dictionary:
	var chosen_label = _decision_chosen_label(decision, choice_type)
	var recommended_label = _decision_recommended_label(decision, choice_type)
	var followed = bool(decision.get("followed_recommendation", false))
	var run_a = chosen_label
	var run_b = _recommendation_alternate_label(decision, choice_type)
	if not followed and not recommended_label.is_empty():
		run_b = recommended_label

	var reason = str(decision.get("recommendation_reason", ""))
	var detail = _compact_decision_detail(str(decision.get("recommendation_detail", "")), 2)
	return {
		"class_id": str(case_result.get("class_id", "default")),
		"class_label": str(case_result.get("class_label", "Default")),
		"player_count": int(case_result.get("player_count", 0)),
		"round": int(decision.get("round", 0)),
		"action": str(decision.get("action", "")),
		"choice_type": choice_type,
		"followed_recommendation": followed,
		"chosen_label": chosen_label,
		"recommended_label": recommended_label,
		"alternate_label": run_b,
		"recommendation_reason": reason,
		"recommendation_detail": detail,
		"prompt": "Run A: %s. Run B: %s. Check whether this stays a table discussion, not an auto-pick." % [
			run_a,
			run_b,
		],
	}


func _decision_chosen_label(decision: Dictionary, choice_type: String) -> String:
	match str(decision.get("action", "")):
		"claim_reward":
			return str(decision.get("card_label", decision.get("card_id", "card")))
		"claim_reward_gold":
			return "take gold +%s" % int(decision.get("gold_gain", 0))
		"claim_artifact":
			return str(decision.get("artifact_label", decision.get("artifact_id", "artifact")))
		"shop_remove":
			return "remove %s" % str(decision.get("card_label", decision.get("card_id", "card")))
		"shop_skip":
			return "skip shop"
		_:
			return choice_type


func _decision_recommended_label(decision: Dictionary, choice_type: String) -> String:
	var label = str(decision.get("recommended_label", ""))
	if label.is_empty():
		label = str(decision.get("recommended_id", ""))
	if label.is_empty():
		label = choice_type
	if choice_type == "gold" and not label.to_lower().contains("gold"):
		return "take %s" % label
	if choice_type == "shop" and str(decision.get("action", "")) != "shop_skip":
		return "remove %s" % label
	return label


func _recommendation_alternate_label(decision: Dictionary, choice_type: String) -> String:
	match choice_type:
		"gold":
			return "take the clearest role card"
		"card":
			return "take gold or another offered card"
		"artifact":
			return "equip the other artifact or skip"
		"shop":
			return "save gold or remove another offered card"
		_:
			var recommended_label = _decision_recommended_label(decision, choice_type)
			return "choose a safe alternative to %s" % recommended_label


func _compact_decision_detail(detail_text: String, limit: int) -> String:
	if detail_text.is_empty():
		return ""

	var parts = detail_text.split("|", false)
	if parts.size() <= limit:
		return detail_text

	var compact_parts = PackedStringArray()
	for index in range(min(limit, parts.size())):
		compact_parts.append(str(parts[index]).strip_edges())
	return " | ".join(compact_parts)


func _add_recommendation_contrast_samples(target: Array, source_value) -> void:
	if typeof(source_value) != TYPE_ARRAY:
		return

	var source: Array = source_value
	for sample_value in source:
		if target.size() >= RECOMMENDATION_CONTRAST_SAMPLE_LIMIT:
			return
		if typeof(sample_value) == TYPE_DICTIONARY:
			var sample: Dictionary = sample_value
			target.append(sample.duplicate(true))


func _case_boss_part_warning_stats(case_result: Dictionary) -> Dictionary:
	var stored_stats: Dictionary = case_result.get("boss_part_warning_stats", {})
	if not stored_stats.is_empty():
		return {
			"warnings": int(stored_stats.get("warnings", 0)),
			"answered": int(stored_stats.get("answered", 0)),
			"by_reason": _dictionary_value(stored_stats.get("by_reason", {})),
		}

	var stats = {
		"warnings": 0,
		"answered": 0,
		"by_reason": {},
	}
	var trace: Array = case_result.get("decision_trace", [])
	for decision_value in trace:
		if typeof(decision_value) != TYPE_DICTIONARY:
			continue

		var decision: Dictionary = decision_value
		var action = str(decision.get("action", ""))
		if action == "boss_part_warning":
			stats["warnings"] = int(stats.get("warnings", 0)) + 1
			var reason = str(decision.get("reason", "boss_part_warning"))
			if reason.is_empty():
				reason = "boss_part_warning"
			var by_reason: Dictionary = stats.get("by_reason", {})
			_increment_count(by_reason, reason)
			stats["by_reason"] = by_reason
		elif action == "play_card" and bool(decision.get("answered_boss_part_warning", false)):
			stats["answered"] = int(stats.get("answered", 0)) + 1

	return stats


func _add_count_totals(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		target[key] = int(target.get(key, 0)) + int(source.get(key, 0))


func _add_recommendation_action_totals(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		var source_entry: Dictionary = source.get(key, {})
		var target_entry: Dictionary = target.get(key, {
			"decisions": 0,
			"followed": 0,
			"follow_rate": 0.0,
		})
		target_entry["decisions"] = int(target_entry.get("decisions", 0)) + int(source_entry.get("decisions", 0))
		target_entry["followed"] = int(target_entry.get("followed", 0)) + int(source_entry.get("followed", 0))
		var decisions = max(1, int(target_entry.get("decisions", 0)))
		target_entry["follow_rate"] = float(target_entry.get("followed", 0)) / float(decisions)
		target[key] = target_entry


func _recommendation_choice_type_for_decision(decision: Dictionary) -> String:
	var choice_type = str(decision.get("choice_type", ""))
	if not choice_type.is_empty():
		return choice_type

	match str(decision.get("action", "")):
		"claim_reward":
			return "card"
		"claim_reward_gold":
			return "gold"
		"claim_artifact":
			return "artifact"
		"shop_remove", "shop_skip":
			return "shop"
		_:
			return "other"


func _recommendation_choice_type_summary(aggregate: Dictionary) -> String:
	var by_choice_type: Dictionary = aggregate.get("recommendation_by_choice_type", {})
	if by_choice_type.is_empty():
		return "none"

	var parts = PackedStringArray()
	for key in _sorted_choice_type_keys(by_choice_type):
		var entry: Dictionary = by_choice_type.get(key, {})
		parts.append("%s %s/%s" % [
			key,
			entry.get("followed", 0),
			entry.get("decisions", 0),
		])

	return ", ".join(parts)


func _sorted_choice_type_keys(by_choice_type: Dictionary) -> Array[String]:
	var preferred_order = ["card", "gold", "artifact", "shop", "other"]
	var keys: Array[String] = []
	for preferred_key in preferred_order:
		if by_choice_type.has(preferred_key):
			keys.append(preferred_key)
	for key in by_choice_type.keys():
		var key_text = str(key)
		if not keys.has(key_text):
			keys.append(key_text)
	return keys


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
	var boss_warning_stats = _case_boss_part_warning_stats(case_result)
	var tempo_moment = _case_wave_stack_tempo_moment(case_result)
	return {
		"ok": bool(case_result.get("ok", false)),
		"class_id": str(case_result.get("class_id", "default")),
		"class_label": str(case_result.get("class_label", "Default")),
		"player_count": int(case_result.get("player_count", 0)),
		"completed_rounds": int(case_result.get("completed_rounds", 0)),
		"base_hp": int(case_result.get("base_hp", 0)),
		"outcome_focus": str(outcome.get("focus", "unknown")),
		"primary_direction": str(outcome.get("primary_direction", "")),
		"failure_reason": str(case_result.get("failure_reason", "")),
		"killed": int(stats.get("killed", 0)),
		"base_hits": int(stats.get("base_hits", 0)),
		"structures_destroyed": int(stats.get("structures_destroyed", 0)),
		"planned_collapses": int(stats.get("planned_collapses", 0)),
		"planned_collapse_damage": int(stats.get("planned_collapse_damage", 0)),
		"gold_gained": int(stats.get("gold_gained", 0)),
		"base_hits_by_direction": _dictionary_value(stats.get("base_hits_by_direction", {})),
		"boss_base_hits_by_direction": _dictionary_value(stats.get("boss_base_hits_by_direction", {})),
		"base_damage_by_direction": _dictionary_value(stats.get("base_damage_by_direction", {})),
		"structures_destroyed_by_direction": _dictionary_value(stats.get("structures_destroyed_by_direction", {})),
		"planned_collapses_by_direction": _dictionary_value(stats.get("planned_collapses_by_direction", {})),
		"planned_collapse_damage_by_direction": _dictionary_value(stats.get("planned_collapse_damage_by_direction", {})),
		"boss_part_warnings": int(boss_warning_stats.get("warnings", 0)),
		"boss_part_warning_answered": int(boss_warning_stats.get("answered", 0)),
		"wave_stack_tempo_state": str(tempo_moment.get("state", "")),
		"wave_stack_tempo_summary": str(tempo_moment.get("summary", "")),
		"decision_trace": _decision_trace_snapshot(case_result.get("decision_trace", []), 8),
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
		"card_block_reasons": {},
		"card_block_cases": 0,
		"recommendation_decisions": 0,
		"recommendation_followed": 0,
		"recommendation_follow_rate": 0.0,
		"recommendation_by_action": {},
		"recommendation_by_choice_type": {},
		"recommendation_contrast_samples": [],
		"recommendation_contrast_sample_count": 0,
		"boss_part_warning_decisions": 0,
		"boss_part_warning_answered": 0,
		"boss_part_warning_answer_rate": 0.0,
		"boss_part_warning_by_reason": {},
		"wave_stack_tempo_moments": 0,
		"wave_stack_tempo_states": {},
		"wave_stack_tempo_hold_tags": {},
		"wave_stack_tempo_samples": [],
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

		var case_card_block_reasons = _case_card_block_reason_counts(case_dictionary)
		if not case_card_block_reasons.is_empty():
			aggregate["card_block_cases"] = int(aggregate.get("card_block_cases", 0)) + 1
			var aggregate_card_block_reasons: Dictionary = aggregate["card_block_reasons"]
			_add_count_totals(aggregate_card_block_reasons, case_card_block_reasons)
			aggregate["card_block_reasons"] = aggregate_card_block_reasons

		var recommendation_stats = _case_recommendation_stats(case_dictionary)
		aggregate["recommendation_decisions"] = int(aggregate.get("recommendation_decisions", 0)) + int(recommendation_stats.get("decisions", 0))
		aggregate["recommendation_followed"] = int(aggregate.get("recommendation_followed", 0)) + int(recommendation_stats.get("followed", 0))
		var aggregate_recommendation_by_action: Dictionary = aggregate["recommendation_by_action"]
		_add_recommendation_action_totals(aggregate_recommendation_by_action, recommendation_stats.get("by_action", {}))
		aggregate["recommendation_by_action"] = aggregate_recommendation_by_action
		var aggregate_recommendation_by_choice_type: Dictionary = aggregate["recommendation_by_choice_type"]
		_add_recommendation_action_totals(aggregate_recommendation_by_choice_type, recommendation_stats.get("by_choice_type", {}))
		aggregate["recommendation_by_choice_type"] = aggregate_recommendation_by_choice_type
		var aggregate_recommendation_contrast_samples: Array = aggregate["recommendation_contrast_samples"]
		_add_recommendation_contrast_samples(aggregate_recommendation_contrast_samples, recommendation_stats.get("contrast_samples", []))
		aggregate["recommendation_contrast_samples"] = aggregate_recommendation_contrast_samples

		var boss_warning_stats = _case_boss_part_warning_stats(case_dictionary)
		aggregate["boss_part_warning_decisions"] = int(aggregate.get("boss_part_warning_decisions", 0)) + int(boss_warning_stats.get("warnings", 0))
		aggregate["boss_part_warning_answered"] = int(aggregate.get("boss_part_warning_answered", 0)) + int(boss_warning_stats.get("answered", 0))
		var aggregate_boss_warning_reasons: Dictionary = aggregate["boss_part_warning_by_reason"]
		_add_count_totals(aggregate_boss_warning_reasons, boss_warning_stats.get("by_reason", {}))
		aggregate["boss_part_warning_by_reason"] = aggregate_boss_warning_reasons

		var tempo_moment = _case_wave_stack_tempo_moment(case_dictionary)
		if not tempo_moment.is_empty():
			var tempo_count = max(1, int(case_dictionary.get("stats", {}).get("wave_stack_tempo_moments", 0)))
			aggregate["wave_stack_tempo_moments"] = int(aggregate.get("wave_stack_tempo_moments", 0)) + tempo_count
			var tempo_states: Dictionary = aggregate["wave_stack_tempo_states"]
			_increment_count(tempo_states, str(tempo_moment.get("state", "unknown")))
			aggregate["wave_stack_tempo_states"] = tempo_states
			var tempo_hold_tags: Dictionary = aggregate["wave_stack_tempo_hold_tags"]
			for tag_value in tempo_moment.get("holdTags", []):
				_increment_count(tempo_hold_tags, str(tag_value))
			aggregate["wave_stack_tempo_hold_tags"] = tempo_hold_tags
			var tempo_samples: Array = aggregate["wave_stack_tempo_samples"]
			if tempo_samples.size() < RECOMMENDATION_CONTRAST_SAMPLE_LIMIT:
				tempo_samples.append(_wave_stack_tempo_sample(case_dictionary, tempo_moment))
			aggregate["wave_stack_tempo_samples"] = tempo_samples

	var case_count = max(1, cases.size())
	aggregate["average_completed_rounds"] = float(aggregate.get("completed_rounds_total", 0)) / float(case_count)
	aggregate["average_base_hp"] = float(aggregate.get("base_hp_total", 0)) / float(case_count)
	var recommendation_decisions = max(1, int(aggregate.get("recommendation_decisions", 0)))
	aggregate["recommendation_follow_rate"] = float(aggregate.get("recommendation_followed", 0)) / float(recommendation_decisions)
	aggregate["recommendation_contrast_sample_count"] = aggregate.get("recommendation_contrast_samples", []).size()
	var boss_warning_decisions = max(1, int(aggregate.get("boss_part_warning_decisions", 0)))
	aggregate["boss_part_warning_answer_rate"] = float(aggregate.get("boss_part_warning_answered", 0)) / float(boss_warning_decisions)
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
		"card_block_reasons": {},
		"card_block_cases": 0,
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

	var card_block_reasons = _case_card_block_reason_counts(case_result)
	if not card_block_reasons.is_empty():
		entry["card_block_cases"] = int(entry.get("card_block_cases", 0)) + 1
		var entry_card_block_reasons: Dictionary = entry.get("card_block_reasons", {})
		_add_count_totals(entry_card_block_reasons, card_block_reasons)
		entry["card_block_reasons"] = entry_card_block_reasons
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
		"boss_part_damage",
		"boss_parts_destroyed",
		"boss_part_draws",
		"boss_part_slow_waits",
		"boss_phase_triggers",
		"boss_pulse_damage",
		"boss_siege_triggers",
		"boss_siege_damage",
		"structures_destroyed",
		"planned_collapses",
		"planned_collapse_damage",
		"cards_played",
		"mana_spent",
		"round_seed_cards_drawn",
		"card_rewards_taken",
		"artifact_rewards_taken",
		"shop_offers_opened",
		"shop_cards_removed",
		"gold_gained",
		"gold_spent",
		"front_seed_mana_gained",
		"wave_stacks",
		"wave_stack_tempo_moments",
		"stack_rejections",
	]


func _append_next_action_queue(lines: Array, queue: Array) -> void:
	lines.append("## Next Action Queue")
	if queue.is_empty():
		lines.append("No next action candidates.")
		lines.append("")
		return

	lines.append("| # | Severity | Signal | Hypothesis | Check | Metric | Source |")
	lines.append("| ---: | --- | --- | --- | --- | --- | --- |")
	for entry_value in queue:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		lines.append("| %s | %s | %s | %s | %s | %s | %s |" % [
			entry.get("rank", 0),
			_markdown_cell(str(entry.get("severity", "watch"))),
			_markdown_cell(str(entry.get("signal", "signal"))),
			_markdown_cell(str(entry.get("hypothesis", ""))),
			_markdown_cell(str(entry.get("check", ""))),
			_markdown_cell(str(entry.get("metric", ""))),
			_markdown_cell("%s / %s" % [
				entry.get("source", "report"),
				entry.get("document", "docs/PLAYTEST_AND_BALANCE.md"),
			]),
		])
	lines.append("")


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


func _append_card_block_table(lines: Array, card_block_reasons: Dictionary, card_block_cases: int) -> void:
	lines.append("## Card Play Blockers")
	if card_block_reasons.is_empty():
		lines.append("No blocked card-play decisions.")
		lines.append("")
		return

	lines.append("- Cases with blockers: %s" % card_block_cases)
	lines.append("")
	lines.append("| Reason | Count |")
	lines.append("| --- | ---: |")
	for reason in _sorted_count_keys(card_block_reasons):
		lines.append("| %s | %s |" % [
			_markdown_cell(str(reason)),
			card_block_reasons.get(reason, 0),
		])
	lines.append("")


func _append_recommendation_table(lines: Array, aggregate: Dictionary) -> void:
	lines.append("## Recommendation Decisions")
	var total_decisions = int(aggregate.get("recommendation_decisions", 0))
	if total_decisions <= 0:
		lines.append("No recommendation-backed decisions.")
		lines.append("")
		return

	lines.append("- Followed: %s/%s (%.1f%%)" % [
		aggregate.get("recommendation_followed", 0),
		total_decisions,
		float(aggregate.get("recommendation_follow_rate", 0.0)) * 100.0,
	])
	lines.append("")
	lines.append("| Action | Decisions | Followed | Rate |")
	lines.append("| --- | ---: | ---: | ---: |")
	var by_action: Dictionary = aggregate.get("recommendation_by_action", {})
	var keys: Array[String] = []
	for key in by_action.keys():
		keys.append(str(key))
	keys.sort()
	for key in keys:
		var entry: Dictionary = by_action.get(key, {})
		lines.append("| %s | %s | %s | %.1f%% |" % [
			_markdown_cell(key),
			entry.get("decisions", 0),
			entry.get("followed", 0),
			float(entry.get("follow_rate", 0.0)) * 100.0,
		])
	lines.append("")

	var by_choice_type: Dictionary = aggregate.get("recommendation_by_choice_type", {})
	if not by_choice_type.is_empty():
		lines.append("| Choice type | Decisions | Followed | Rate |")
		lines.append("| --- | ---: | ---: | ---: |")
		var choice_keys: Array[String] = []
		for key in by_choice_type.keys():
			choice_keys.append(str(key))
		choice_keys.sort()
		for key in choice_keys:
			var entry: Dictionary = by_choice_type.get(key, {})
			lines.append("| %s | %s | %s | %.1f%% |" % [
				_markdown_cell(key),
				entry.get("decisions", 0),
				entry.get("followed", 0),
				float(entry.get("follow_rate", 0.0)) * 100.0,
			])
		lines.append("")


func _append_recommendation_contrast_samples(lines: Array, samples_value) -> void:
	lines.append("## Recommendation Contrast Samples")
	if typeof(samples_value) != TYPE_ARRAY:
		lines.append("No recommendation contrast samples.")
		lines.append("")
		return

	var samples: Array = samples_value
	if samples.is_empty():
		lines.append("No recommendation contrast samples.")
		lines.append("")
		return

	lines.append("| Case | Choice | Followed | Recommendation | Contrast prompt | Why now |")
	lines.append("| --- | --- | --- | --- | --- | --- |")
	for sample_value in samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue

		var sample: Dictionary = sample_value
		lines.append("| %s %sP R%s | %s | %s | %s | %s | %s |" % [
			_markdown_cell(str(sample.get("class_label", "Default"))),
			sample.get("player_count", 0),
			sample.get("round", 0),
			_markdown_cell(str(sample.get("choice_type", "choice"))),
			"yes" if bool(sample.get("followed_recommendation", false)) else "no",
			_markdown_cell(str(sample.get("recommendation_reason", ""))),
			_markdown_cell(str(sample.get("prompt", ""))),
			_markdown_cell(str(sample.get("recommendation_detail", ""))),
		])
	lines.append("")


func _append_boss_part_warning_table(lines: Array, aggregate: Dictionary) -> void:
	lines.append("## Boss Part Warnings")
	var total_warnings = int(aggregate.get("boss_part_warning_decisions", 0))
	if total_warnings <= 0:
		lines.append("No boss part warnings recorded.")
		lines.append("")
		return

	lines.append("- Answered by damage card: %s/%s (%.1f%%)" % [
		aggregate.get("boss_part_warning_answered", 0),
		total_warnings,
		float(aggregate.get("boss_part_warning_answer_rate", 0.0)) * 100.0,
	])
	lines.append("")
	lines.append("| Reason | Count |")
	lines.append("| --- | ---: |")
	var by_reason: Dictionary = aggregate.get("boss_part_warning_by_reason", {})
	for reason in _sorted_count_keys(by_reason):
		lines.append("| %s | %s |" % [
			_markdown_cell(str(reason)),
			by_reason.get(reason, 0),
		])
	lines.append("")


func _append_wave_stack_tempo_table(lines: Array, aggregate: Dictionary) -> void:
	lines.append("## Wave Stack Tempo Moments")
	var moment_count = int(aggregate.get("wave_stack_tempo_moments", 0))
	if moment_count <= 0:
		lines.append("No wave stack tempo moments recorded.")
		lines.append("")
		return

	lines.append("- Captured: %s moment(s)" % moment_count)
	lines.append("- States: %s" % _format_counts(aggregate.get("wave_stack_tempo_states", {})))
	lines.append("- Hold tags: %s" % _format_counts(aggregate.get("wave_stack_tempo_hold_tags", {})))
	lines.append("- Guardrail: tempo pressure only. No bonus rewards, rarity boosts, gold boosts, or extra card choices.")
	lines.append("")

	var samples: Array = aggregate.get("wave_stack_tempo_samples", [])
	if samples.is_empty():
		return

	lines.append("| Case | State | Damage | Hold tags | Summary |")
	lines.append("| --- | --- | --- | --- | --- |")
	for sample_value in samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue

		var sample: Dictionary = sample_value
		var damage_text = "+%s base, +%s leaks, +%s structures" % [
			sample.get("base_damage_delta", 0),
			sample.get("base_hits_delta", 0),
			sample.get("structures_destroyed_delta", 0),
		]
		var hold_tags = sample.get("hold_tags", [])
		var hold_text = "none" if hold_tags.is_empty() else ", ".join(_string_values(hold_tags))
		lines.append("| %s %sP | %s | %s | %s | %s |" % [
			_markdown_cell(str(sample.get("class_label", "Default"))),
			sample.get("player_count", 0),
			_markdown_cell(str(sample.get("state", "unknown"))),
			_markdown_cell(damage_text),
			_markdown_cell(hold_text),
			_markdown_cell(str(sample.get("summary", ""))),
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


func _append_class_weakness_table(lines: Array, summaries: Array) -> void:
	lines.append("## Class Weakness Signals")
	if summaries.is_empty():
		lines.append("No class weakness data.")
		lines.append("")
		return

	lines.append("| Class | Cases | Signal | Evidence | Next probe |")
	lines.append("| --- | ---: | --- | --- | --- |")
	for summary_value in summaries:
		if typeof(summary_value) != TYPE_DICTIONARY:
			continue

		var summary: Dictionary = summary_value
		lines.append("| %s | %s | %s | %s | %s |" % [
			_markdown_cell(str(summary.get("class_label", summary.get("class_id", "Class")))),
			summary.get("case_count", 0),
			_markdown_cell(str(summary.get("primary_signal", "unknown"))),
			_markdown_cell(str(summary.get("evidence", ""))),
			_markdown_cell(str(summary.get("next_probe", ""))),
		])
	lines.append("")


func _append_alpha_focus_queue(lines: Array, queue: Array) -> void:
	lines.append("## Alpha Focus Queue")
	if queue.is_empty():
		lines.append("No alpha focus cases.")
		lines.append("")
		return

	lines.append("| # | Case | Signal | Evidence | Next probe |")
	lines.append("| ---: | --- | --- | --- | --- |")
	for entry_value in queue:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		lines.append("| %s | %s %sP | %s | %s | %s |" % [
			entry.get("rank", 0),
			_markdown_cell(str(entry.get("class_label", "Default"))),
			entry.get("player_count", 0),
			_markdown_cell(str(entry.get("primary_signal", ""))),
			_markdown_cell(str(entry.get("evidence", ""))),
			_markdown_cell(str(entry.get("next_probe", ""))),
		])
	lines.append("")

	for entry_value in queue:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		lines.append("- Review cards: %s %sP" % [
			entry.get("class_label", "Default"),
			entry.get("player_count", 0),
		])
		var cards: Array = entry.get("analysis_cards", [])
		for card_value in cards:
			if typeof(card_value) != TYPE_DICTIONARY:
				continue

			var card: Dictionary = card_value
			lines.append("  - %s: %s" % [
				card.get("title", "Card"),
				card.get("body", ""),
			])
	lines.append("")


func _append_front_breakdown(lines: Array, front_breakdown: Array) -> void:
	lines.append("## Front Breakdown")
	if front_breakdown.is_empty():
		lines.append("No data.")
		lines.append("")
		return

	lines.append("| Case | Result | Primary | Base hits | Boss hits | Base damage | Structures lost | Planned collapse |")
	lines.append("| --- | --- | --- | --- | --- | --- | --- | --- |")
	for case_snapshot in front_breakdown:
		if typeof(case_snapshot) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_snapshot
		lines.append("| %s %sp | %s | %s | %s | %s | %s | %s | %s |" % [
			_markdown_cell(str(case_dictionary.get("class_label", "Default"))),
			case_dictionary.get("player_count", 0),
			_markdown_cell(_format_case_result_label(case_dictionary)),
			_markdown_cell(_format_primary_direction(case_dictionary)),
			_markdown_cell(_format_direction_counts(case_dictionary.get("base_hits_by_direction", {}))),
			_markdown_cell(_format_direction_counts(case_dictionary.get("boss_base_hits_by_direction", {}))),
			_markdown_cell(_format_direction_counts(case_dictionary.get("base_damage_by_direction", {}))),
			_markdown_cell(_format_direction_counts(case_dictionary.get("structures_destroyed_by_direction", {}))),
			_markdown_cell(_format_direction_counts(case_dictionary.get("planned_collapses_by_direction", {}))),
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

	lines.append("| Flag | Case | Primary | Base HP | Kills | Base hits | Structures lost |")
	lines.append("| --- | --- | --- | ---: | ---: | --- | --- |")
	for row in rows:
		lines.append(str(row))
	lines.append("")


func _append_flagged_case_rows(rows: Array, flag_label: String, case_snapshots: Array) -> void:
	for case_snapshot in case_snapshots:
		if typeof(case_snapshot) != TYPE_DICTIONARY:
			continue

		var case_dictionary: Dictionary = case_snapshot
		rows.append("| %s | %s %sp | %s | %s | %s | %s | %s |" % [
			_markdown_cell(flag_label),
			_markdown_cell(str(case_dictionary.get("class_label", "Default"))),
			case_dictionary.get("player_count", 0),
			_markdown_cell(_format_primary_direction(case_dictionary)),
			case_dictionary.get("base_hp", 0),
			case_dictionary.get("killed", 0),
			_markdown_cell(_format_direction_counts(case_dictionary.get("base_hits_by_direction", {}))),
			_markdown_cell(_format_direction_counts(case_dictionary.get("structures_destroyed_by_direction", {}))),
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
	if not bool(case_snapshot.get("ok", false)):
		lines.append("- Failure reason: %s" % case_snapshot.get("failure_reason", "check_failed"))
	lines.append("- Pressure: focus %s, base hits %s, structures lost %s, kills %s, gold %s" % [
		case_snapshot.get("outcome_focus", "unknown"),
		case_snapshot.get("base_hits", 0),
		case_snapshot.get("structures_destroyed", 0),
		case_snapshot.get("killed", 0),
		case_snapshot.get("gold_gained", 0),
	])
	lines.append("- Fronts: primary %s, hits %s, boss hits %s, damage %s, lost %s" % [
		_format_primary_direction(case_snapshot),
		_format_direction_counts(case_snapshot.get("base_hits_by_direction", {})),
		_format_direction_counts(case_snapshot.get("boss_base_hits_by_direction", {})),
		_format_direction_counts(case_snapshot.get("base_damage_by_direction", {})),
		_format_direction_counts(case_snapshot.get("structures_destroyed_by_direction", {})),
	])
	if int(case_snapshot.get("boss_part_warnings", 0)) > 0:
		lines.append("- Boss part warnings: answered %s/%s" % [
			case_snapshot.get("boss_part_warning_answered", 0),
			case_snapshot.get("boss_part_warnings", 0),
		])
	var trace: Array = case_snapshot.get("decision_trace", [])
	if not trace.is_empty():
		lines.append("- Recent decisions:")
		for decision_value in trace:
			if typeof(decision_value) != TYPE_DICTIONARY:
				continue

			var decision: Dictionary = decision_value
			lines.append("  - %s" % decision.get("summary", decision.get("action", "decision")))
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
	var focus = _format_focus_with_direction(
		str(case_entry.get("focus", "unknown")),
		str(case_entry.get("primary_direction", ""))
	)
	var failure_suffix = ""
	if not bool(case_entry.get("ok", false)):
		failure_suffix = " %s" % case_entry.get("failure_reason", "check_failed")
	return "%s R%s HP%s %s%s" % [
		"PASS" if bool(case_entry.get("ok", false)) else "FAIL",
		case_entry.get("completed_rounds", 0),
		case_entry.get("base_hp", 0),
		focus,
		failure_suffix,
	]


func _format_case_result_label(case_snapshot: Dictionary) -> String:
	var status = "PASS" if bool(case_snapshot.get("ok", false)) else "FAIL"
	if bool(case_snapshot.get("ok", false)):
		return status

	var reason = str(case_snapshot.get("failure_reason", "check_failed"))
	if reason.is_empty():
		reason = "check_failed"
	return "%s %s" % [status, reason]


func _format_primary_direction(case_snapshot: Dictionary) -> String:
	var direction = str(case_snapshot.get("primary_direction", ""))
	if direction.is_empty():
		return "-"
	return direction


func _format_focus_with_direction(focus: String, direction: String) -> String:
	if direction.is_empty():
		return focus
	return "%s@%s" % [focus, direction]


func _format_direction_counts(bucket_value) -> String:
	var bucket = _dictionary_value(bucket_value)
	if bucket.is_empty():
		return "-"

	var parts = PackedStringArray()
	var used_keys = {}
	for direction in REPORT_DIRECTION_ORDER:
		if not bucket.has(direction):
			continue

		var amount = int(bucket.get(direction, 0))
		if amount == 0:
			continue

		parts.append("%s=%s" % [direction, amount])
		used_keys[direction] = true

	for key in bucket.keys():
		var key_text = str(key)
		if used_keys.has(key_text):
			continue

		var amount = int(bucket.get(key, 0))
		if amount == 0:
			continue

		parts.append("%s=%s" % [key_text, amount])

	if parts.is_empty():
		return "-"
	return ", ".join(parts)


func _direction_count_total(bucket_value) -> int:
	var bucket = _dictionary_value(bucket_value)
	var total = 0
	for value in bucket.values():
		total += int(value)
	return total


func _dictionary_value(value) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return value.duplicate(true)


func _format_counts(counts: Dictionary) -> String:
	if counts.is_empty():
		return "-"

	var parts = PackedStringArray()
	for key in _sorted_count_keys(counts):
		parts.append("%s=%s" % [key, counts.get(key, 0)])
	return ", ".join(parts)


func _sorted_count_keys(counts: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key in counts.keys():
		keys.append(str(key))

	keys.sort_custom(func(left: String, right: String) -> bool:
		var left_count = int(counts.get(left, 0))
		var right_count = int(counts.get(right, 0))
		if left_count == right_count:
			return left < right
		return left_count > right_count
	)
	return keys


func _top_count_key(counts: Dictionary) -> String:
	var best_key = ""
	var best_count = -1
	for key in counts.keys():
		var key_text = str(key)
		var amount = int(counts.get(key, 0))
		if best_key.is_empty() or amount > best_count:
			best_key = key_text
			best_count = amount

	return best_key


func _join_strings(values: Array, separator: String) -> String:
	var parts = PackedStringArray()
	for value in values:
		parts.append(str(value))

	return separator.join(parts)


func _markdown_cell(value: String) -> String:
	return value.replace("|", "/").replace("\n", " ")


func _increment_count(counts: Dictionary, key: String) -> void:
	counts[key] = int(counts.get(key, 0)) + 1


func _case_result(simulation, player_count: int, class_id: String, ok: bool, failure_reason: String = "") -> Dictionary:
	var outcome = simulation.get_run_outcome_report(player_count)
	outcome["details"] = _string_values(outcome.get("details", []))
	var wave_stack_tempo_moment: Dictionary = simulation.get_wave_stack_tempo_moment_report()
	if not bool(wave_stack_tempo_moment.get("ok", false)):
		wave_stack_tempo_moment = {}
	var resolved_failure_reason = "" if ok else failure_reason
	if not ok and resolved_failure_reason.is_empty():
		resolved_failure_reason = _round_failure_reason(simulation)
	return {
		"ok": ok,
		"failure_reason": resolved_failure_reason,
		"player_count": player_count,
		"class_id": class_id,
		"class_label": _class_label(simulation, class_id),
		"current_round": simulation.get_current_round(),
		"completed_rounds": simulation.get_completed_rounds(),
		"base_hp": simulation.get_base_hp(),
		"reward_pending": simulation.has_pending_reward(),
		"outcome": outcome,
		"stats": simulation.get_run_stats().duplicate(true),
		"wave_stack_tempo_moment": wave_stack_tempo_moment.duplicate(true),
		"decision_trace": decision_trace.duplicate(true),
		"boss_part_warning_stats": boss_part_warning_stats.duplicate(true),
	}


func _string_values(values) -> Array:
	var result: Array = []
	for value in values:
		result.append(str(value))
	return result


func _decision_trace_snapshot(trace_value, limit: int) -> Array:
	if typeof(trace_value) != TYPE_ARRAY:
		return []

	var trace: Array = trace_value
	var result: Array = []
	var start_index = max(0, trace.size() - max(1, limit))
	for index in range(start_index, trace.size()):
		var decision_value = trace[index]
		if typeof(decision_value) == TYPE_DICTIONARY:
			var decision: Dictionary = decision_value
			result.append(decision.duplicate(true))

	return result


func _format_case_summary(case_result: Dictionary) -> String:
	var stats: Dictionary = case_result.get("stats", {})
	var outcome: Dictionary = case_result.get("outcome", {})
	return "[CASE] %s %sp ok=%s reason=%s completed=%s current=%s base_hp=%s spawned=%s boss=%s/%s phase=%s pulse=%s siege=%s/%s killed=%s rewards=%s/%s artifacts=%s/%s shop_removed=%s gold=%s/%s seed_bonus=%s break=%s/%s stacks=%s depth=%s tempo_moments=%s card_fx=%s/%s/%s class_fx=%s/%s/%s/%s taunt=%s repairs=%s outcome=%s next=%s" % [
		case_result.get("class_label", "Default"),
		case_result.get("player_count", 0),
		case_result.get("ok", false),
		case_result.get("failure_reason", ""),
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
		stats.get("front_seed_mana_gained", 0),
		stats.get("break_targets_found", 0),
		stats.get("break_path_steps", 0),
		stats.get("wave_stacks", 0),
		stats.get("max_wave_stack_depth", 0),
		stats.get("wave_stack_tempo_moments", 0),
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


func _record_decision(action: String, simulation, details: Dictionary) -> void:
	var entry = {
		"action": action,
		"round": simulation.get_current_round(),
		"completed_rounds": simulation.get_completed_rounds(),
		"stage": "wave" if bool(simulation.wave_active) else "build",
		"mana": simulation.get_mana(),
		"hand_size": simulation.get_hand().size(),
	}
	for key in details.keys():
		entry[key] = details[key]

	entry["summary"] = _decision_summary(entry)
	decision_trace.append(entry)
	while decision_trace.size() > DECISION_TRACE_LIMIT:
		decision_trace.pop_front()


func _decision_summary(entry: Dictionary) -> String:
	var prefix = "R%s %s" % [entry.get("round", 0), entry.get("stage", "build")]
	match str(entry.get("action", "")):
		"play_card":
			var target = str(entry.get("target", ""))
			var target_text = "" if target.is_empty() else " at %s" % target
			var boss_focus = str(entry.get("boss_part_focus", ""))
			var boss_focus_text = "" if boss_focus.is_empty() or boss_focus.ends_with("none") else " | %s" % boss_focus
			var boss_warning_answer_text = " | answered boss warning" if bool(entry.get("answered_boss_part_warning", false)) else ""
			return "%s play %s%s mana %s>%s%s%s" % [
				prefix,
				entry.get("card_label", entry.get("card_id", "card")),
				target_text,
				entry.get("before_mana", "?"),
				entry.get("after_mana", "?"),
				boss_focus_text,
				boss_warning_answer_text,
			]
		"boss_part_warning":
			return "%s boss warning %s" % [
				prefix,
				entry.get("boss_part_warning", entry.get("reason", "boss_part_warning")),
			]
		"wave_stack":
			return "%s pull R%s depth %s | %s" % [
				prefix,
				entry.get("pulled_round", "?"),
				entry.get("stack_depth", "?"),
				entry.get("tempo_moment_summary", "moment_wave_stack_tempo"),
			]
		"wave_stack_hold":
			return "%s hold pull: %s" % [
				prefix,
				entry.get("result", "blocked"),
			]
		"wave_stack_vote":
			return "%s pull vote %s/%s: %s" % [
				prefix,
				entry.get("approvals", 0),
				entry.get("required", 0),
				entry.get("result", "vote_waiting"),
			]
		"play_blocked":
			return "%s blocked cards: %s (hand %s, mana %s, enemies %s, bosses %s)" % [
				prefix,
				entry.get("top_reason", "unknown"),
				entry.get("hand_size", 0),
				entry.get("mana", "?"),
				entry.get("enemy_count", 0),
				entry.get("boss_count", 0),
			]
		"claim_reward":
			return "%s reward %s [%s/%s]%s" % [
				prefix,
				entry.get("card_label", entry.get("card_id", "card")),
				entry.get("rarity", "-"),
				entry.get("role", "-"),
				_recommendation_summary_suffix(entry),
			]
		"claim_reward_gold":
			return "%s reward gold +%s (%s>%s)%s" % [
				prefix,
				entry.get("gold_gain", 0),
				entry.get("gold_before", "?"),
				entry.get("gold_after", "?"),
				_recommendation_summary_suffix(entry),
			]
		"claim_artifact":
			return "%s artifact %s%s" % [
				prefix,
				entry.get("artifact_label", entry.get("artifact_id", "artifact")),
				_recommendation_summary_suffix(entry),
			]
		"shop_remove":
			return "%s shop remove %s%s" % [
				prefix,
				entry.get("card_label", entry.get("card_id", "card")),
				_recommendation_summary_suffix(entry),
			]
		"shop_skip":
			return "%s shop skip %s" % [
				prefix,
				entry.get("card_label", entry.get("card_id", "card")),
			]
		_:
			return "%s %s" % [prefix, entry.get("action", "decision")]


func _recommendation_summary_suffix(entry: Dictionary) -> String:
	if not bool(entry.get("recommendation_available", false)):
		return ""

	var reason = str(entry.get("recommendation_reason", ""))
	var reason_text = "" if reason.is_empty() else ": %s" % reason
	if bool(entry.get("followed_recommendation", false)):
		return " | suggested%s" % reason_text

	var recommended_label = str(entry.get("recommended_label", entry.get("recommended_id", "")))
	if recommended_label.is_empty():
		recommended_label = "other"
	return " | suggested %s%s" % [
		recommended_label,
		reason_text,
	]


func _record(condition: bool, label: String) -> void:
	if condition:
		lines.append("[PASS] %s" % label)
	else:
		lines.append("[FAIL] %s" % label)
		failures.append(label)


func _tile_key(tile: Vector2i) -> String:
	return "%s,%s" % [tile.x, tile.y]
