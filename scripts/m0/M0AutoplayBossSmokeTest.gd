extends SceneTree

const M0AutoplayRunnerScript = preload("res://scripts/m0/M0AutoplayRunner.gd")


func _init() -> void:
	var runner = M0AutoplayRunnerScript.new()
	var result = runner.run_boss_checkpoint_smoke()
	var aggregate: Dictionary = result.get("aggregate", {})
	var report: Dictionary = result.get("report", {})
	var stat_totals: Dictionary = aggregate.get("stat_totals", {})
	var case_count = int(aggregate.get("case_count", 0))
	var boss_spawned = int(stat_totals.get("bosses_spawned", 0))
	var boss_killed = int(stat_totals.get("bosses_killed", 0))
	var artifacts_taken = int(stat_totals.get("artifact_rewards_taken", 0))
	var shop_opened = int(stat_totals.get("shop_offers_opened", 0))
	var cards_taken = int(stat_totals.get("card_rewards_taken", 0))
	var boss_warning_decisions = int(aggregate.get("boss_part_warning_decisions", 0))
	var recommendation_by_choice_type: Dictionary = aggregate.get("recommendation_by_choice_type", {})
	var recommendation_contrast_samples: Array = aggregate.get("recommendation_contrast_samples", [])

	if case_count <= 0:
		push_error("[FAIL] boss autoplay aggregate has no cases")

	if report.is_empty():
		push_error("[FAIL] boss autoplay report is missing")

	if boss_spawned <= 0:
		push_error("[FAIL] boss autoplay never spawned a boss")

	if boss_killed <= 0:
		push_error("[FAIL] boss autoplay never killed a boss")

	if artifacts_taken <= 0:
		push_error("[FAIL] boss autoplay never claimed an artifact")

	if shop_opened <= 0:
		push_error("[FAIL] boss autoplay never opened a boss shop")

	if cards_taken <= 0:
		push_error("[FAIL] boss autoplay never claimed card rewards")

	if boss_warning_decisions <= 0:
		push_error("[FAIL] boss autoplay never recorded boss part warnings")

	if not recommendation_by_choice_type.has("artifact"):
		push_error("[FAIL] boss autoplay recommendation breakdown is missing artifact choices")

	if not recommendation_by_choice_type.has("shop"):
		push_error("[FAIL] boss autoplay recommendation breakdown is missing shop choices")

	if not _has_contrast_choice_type(recommendation_contrast_samples, "artifact"):
		push_error("[FAIL] boss autoplay contrast samples are missing artifact choices")

	if not _has_contrast_choice_type(recommendation_contrast_samples, "shop"):
		push_error("[FAIL] boss autoplay contrast samples are missing shop choices")

	var failed_case_has_trace = false
	var blocked_trace_found = false
	for case_value in result.get("cases", []):
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_result: Dictionary = case_value
		if bool(case_result.get("ok", false)):
			continue

		var decision_trace: Array = case_result.get("decision_trace", [])
		if not decision_trace.is_empty():
			failed_case_has_trace = true

		for decision_value in decision_trace:
			if typeof(decision_value) != TYPE_DICTIONARY:
				continue

			var decision: Dictionary = decision_value
			if str(decision.get("action", "")) == "play_blocked":
				blocked_trace_found = true
				break

	if int(aggregate.get("fail_count", 0)) > 0 and not failed_case_has_trace:
		push_error("[FAIL] boss autoplay failed cases have no decision trace")

	if int(aggregate.get("fail_count", 0)) > 0 and not blocked_trace_found:
		push_error("[FAIL] boss autoplay failed cases have no blocked-card trace")

	var markdown_text = runner.build_markdown_report(result)
	if not markdown_text.contains("# M0 Autoplay Report") \
		or not markdown_text.contains("## Card Play Blockers") \
		or not markdown_text.contains("## Recommendation Contrast Samples") \
		or not markdown_text.contains("## Boss Part Warnings") \
		or not markdown_text.contains("Run A:") \
		or not markdown_text.contains("boss=1/1") \
		or not markdown_text.contains("Recent decisions"):
		push_error("[FAIL] boss autoplay markdown report is malformed")

	var save_result = runner.save_report_bundle(result, "autoplay_boss_smoke")
	if bool(save_result.get("ok", false)):
		var json_result: Dictionary = save_result.get("json", {})
		var markdown_result: Dictionary = save_result.get("markdown", {})
		print("[REPORT] saved %s and %s" % [
			json_result.get("path", "user://m0_autoplay_boss_smoke_report.json"),
			markdown_result.get("path", "user://m0_autoplay_boss_smoke_report.md"),
		])
	else:
		push_error("[FAIL] boss autoplay report save failed: %s" % save_result.get("reason", "unknown"))

	print("[DIAG] boss checkpoint cases=%s pass=%s fail=%s boss=%s/%s artifacts=%s shops=%s card_rewards=%s warnings=%s/%s" % [
		case_count,
		aggregate.get("pass_count", 0),
		aggregate.get("fail_count", 0),
		boss_spawned,
		boss_killed,
		artifacts_taken,
		shop_opened,
		cards_taken,
		aggregate.get("boss_part_warning_answered", 0),
		boss_warning_decisions,
	])

	for line in result.get("summary_lines", []):
		print(line)

	for failure in result.get("failures", []):
		print("[DIAG] %s" % failure)

	var ok = case_count > 0 \
		and boss_spawned > 0 \
		and boss_killed > 0 \
		and artifacts_taken > 0 \
		and shop_opened > 0 \
		and cards_taken > 0 \
		and bool(save_result.get("ok", false))
	quit(0 if ok else 1)


func _has_contrast_choice_type(samples: Array, choice_type: String) -> bool:
	for sample_value in samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue

		var sample: Dictionary = sample_value
		if str(sample.get("choice_type", "")) == choice_type:
			return true

	return false
