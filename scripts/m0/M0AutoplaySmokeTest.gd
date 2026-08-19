extends SceneTree

const M0AutoplayRunnerScript = preload("res://scripts/m0/M0AutoplayRunner.gd")


func _init() -> void:
	var runner = M0AutoplayRunnerScript.new()
	var result = runner.run_all_player_counts()
	var aggregate: Dictionary = result.get("aggregate", {})
	var report: Dictionary = result.get("report", {})
	var aggregate_ok = int(aggregate.get("case_count", 0)) > 0

	if not aggregate_ok:
		push_error("[FAIL] autoplay aggregate has no cases")

	if report.is_empty():
		push_error("[FAIL] autoplay report is missing")

	if report.get("case_matrix", {}).is_empty():
		push_error("[FAIL] autoplay case matrix is missing")

	if report.get("balance_notes", []).is_empty():
		push_error("[FAIL] autoplay balance notes are missing")

	var next_action_queue: Array = report.get("next_action_queue", [])
	if next_action_queue.is_empty():
		push_error("[FAIL] autoplay next action queue is missing")
	else:
		if next_action_queue.size() > 6:
			push_error("[FAIL] autoplay next action queue is too large")
		for action_value in next_action_queue:
			if typeof(action_value) != TYPE_DICTIONARY:
				continue

			var action: Dictionary = action_value
			if int(action.get("rank", 0)) <= 0:
				push_error("[FAIL] autoplay next action has no rank")
			if str(action.get("severity", "")).is_empty():
				push_error("[FAIL] autoplay next action has no severity")
			if str(action.get("hypothesis", "")).is_empty():
				push_error("[FAIL] autoplay next action has no hypothesis")
			if str(action.get("check", "")).is_empty():
				push_error("[FAIL] autoplay next action has no check")
			if str(action.get("metric", "")).is_empty():
				push_error("[FAIL] autoplay next action has no metric")
			if str(action.get("source", "")).is_empty():
				push_error("[FAIL] autoplay next action has no source")

	var class_weakness_summaries: Array = report.get("class_weakness_summaries", [])
	if class_weakness_summaries.is_empty():
		push_error("[FAIL] autoplay class weakness summaries are missing")
	else:
		for summary_value in class_weakness_summaries:
			if typeof(summary_value) != TYPE_DICTIONARY:
				continue

			var summary: Dictionary = summary_value
			if str(summary.get("primary_signal", "")).is_empty():
				push_error("[FAIL] autoplay class weakness summary has no signal")
			if str(summary.get("evidence", "")).is_empty():
				push_error("[FAIL] autoplay class weakness summary has no evidence")
			if str(summary.get("next_probe", "")).is_empty():
				push_error("[FAIL] autoplay class weakness summary has no next probe")

	var alpha_focus_queue: Array = report.get("alpha_focus_queue", [])
	if alpha_focus_queue.is_empty():
		push_error("[FAIL] autoplay alpha focus queue is missing")
	else:
		for entry_value in alpha_focus_queue:
			if typeof(entry_value) != TYPE_DICTIONARY:
				continue

			var entry: Dictionary = entry_value
			if int(entry.get("rank", 0)) <= 0:
				push_error("[FAIL] autoplay alpha focus entry has no rank")
			if str(entry.get("primary_signal", "")).is_empty():
				push_error("[FAIL] autoplay alpha focus entry has no signal")
			if str(entry.get("evidence", "")).is_empty():
				push_error("[FAIL] autoplay alpha focus entry has no evidence")
			if str(entry.get("next_probe", "")).is_empty():
				push_error("[FAIL] autoplay alpha focus entry has no next probe")
			var cards: Array = entry.get("analysis_cards", [])
			if cards.is_empty() or cards.size() > 3:
				push_error("[FAIL] autoplay alpha focus entry has invalid analysis cards")

	var recommendation_decisions = int(aggregate.get("recommendation_decisions", 0))
	var recommendation_followed = int(aggregate.get("recommendation_followed", 0))
	if recommendation_decisions <= 0:
		push_error("[FAIL] autoplay recommendation decisions are missing")
	if recommendation_followed != recommendation_decisions:
		push_error("[FAIL] autoplay did not follow every available recommendation")
	if aggregate.get("recommendation_by_action", {}).is_empty():
		push_error("[FAIL] autoplay recommendation action breakdown is missing")
	var recommendation_by_choice_type: Dictionary = aggregate.get("recommendation_by_choice_type", {})
	if recommendation_by_choice_type.is_empty():
		push_error("[FAIL] autoplay recommendation choice-type breakdown is missing")
	if not recommendation_by_choice_type.has("card"):
		push_error("[FAIL] autoplay recommendation choice-type breakdown is missing card choices")
	var recommendation_contrast_samples: Array = aggregate.get("recommendation_contrast_samples", [])
	if recommendation_contrast_samples.is_empty():
		push_error("[FAIL] autoplay recommendation contrast samples are missing")
	else:
		var first_contrast_sample: Dictionary = recommendation_contrast_samples[0]
		if str(first_contrast_sample.get("prompt", "")).is_empty():
			push_error("[FAIL] autoplay recommendation contrast sample has no prompt")
		if not str(first_contrast_sample.get("prompt", "")).contains("Run A:"):
			push_error("[FAIL] autoplay recommendation contrast sample has no Run A prompt")
		if str(first_contrast_sample.get("recommendation_reason", "")).is_empty():
			push_error("[FAIL] autoplay recommendation contrast sample has no recommendation reason")
	if int(aggregate.get("recommendation_contrast_sample_count", 0)) != recommendation_contrast_samples.size():
		push_error("[FAIL] autoplay recommendation contrast sample count is inconsistent")
	if report.get("recommendation_contrast_samples", []).is_empty():
		push_error("[FAIL] autoplay report exposes no top-level recommendation contrast samples")

	var wave_stack_tempo_moment_count = int(aggregate.get("wave_stack_tempo_moments", 0))
	var wave_stack_tempo_samples: Array = aggregate.get("wave_stack_tempo_samples", [])
	if wave_stack_tempo_moment_count <= 0:
		push_error("[FAIL] autoplay wave stack tempo moments are missing")
	if wave_stack_tempo_samples.is_empty():
		push_error("[FAIL] autoplay wave stack tempo samples are missing")
	else:
		var first_tempo_sample: Dictionary = wave_stack_tempo_samples[0]
		if str(first_tempo_sample.get("state", "")).is_empty():
			push_error("[FAIL] autoplay wave stack tempo sample has no state")
		if not str(first_tempo_sample.get("summary", "")).contains("moment_wave_stack_tempo"):
			push_error("[FAIL] autoplay wave stack tempo sample has no moment summary")
		if not str(first_tempo_sample.get("summary", "")).contains("No bonus rewards"):
			push_error("[FAIL] autoplay wave stack tempo sample loses no-bonus guardrail")
	if report.get("wave_stack_tempo_samples", []).is_empty():
		push_error("[FAIL] autoplay report exposes no top-level wave stack tempo samples")
	if aggregate.get("wave_stack_tempo_states", {}).is_empty():
		push_error("[FAIL] autoplay wave stack tempo states are missing")

	var cases: Array = result.get("cases", [])
	if cases.is_empty():
		push_error("[FAIL] autoplay cases are missing")
	else:
		var first_case: Dictionary = cases[0]
		var decision_trace: Array = first_case.get("decision_trace", [])
		if decision_trace.is_empty():
			push_error("[FAIL] autoplay decision trace is missing")
		else:
			var first_decision: Dictionary = decision_trace[0]
			if str(first_decision.get("summary", "")).is_empty():
				push_error("[FAIL] autoplay decision trace summary is missing")
		var saw_followed_recommendation = false
		var saw_wave_stack_decision = false
		for case_value in cases:
			if typeof(case_value) != TYPE_DICTIONARY:
				continue

			var case_dictionary: Dictionary = case_value
			if int(case_dictionary.get("stats", {}).get("wave_stack_tempo_moments", 0)) > 0:
				var tempo_moment: Dictionary = case_dictionary.get("wave_stack_tempo_moment", {})
				if str(tempo_moment.get("event", "")) != "moment_wave_stack_tempo":
					push_error("[FAIL] autoplay case tempo moment uses the wrong event id")
			for decision_value in case_dictionary.get("decision_trace", []):
				if typeof(decision_value) != TYPE_DICTIONARY:
					continue

				var decision: Dictionary = decision_value
				if str(decision.get("action", "")) == "wave_stack":
					saw_wave_stack_decision = true
				if not bool(decision.get("recommendation_available", false)):
					continue
				if str(decision.get("recommendation_reason", "")).is_empty():
					push_error("[FAIL] autoplay recommendation decision has no reason")
				if ["claim_reward", "claim_reward_gold"].has(str(decision.get("action", ""))) and str(decision.get("recommendation_detail", "")).is_empty():
					push_error("[FAIL] autoplay reward recommendation decision has no detail")
				if bool(decision.get("followed_recommendation", false)):
					saw_followed_recommendation = true
		if not saw_followed_recommendation:
			push_error("[FAIL] autoplay never records a followed recommendation")
		if not saw_wave_stack_decision:
			push_error("[FAIL] autoplay never records a wave stack decision")

	var flagged_cases: Dictionary = report.get("flagged_cases", {})
	if flagged_cases.is_empty():
		push_error("[FAIL] autoplay flagged cases are missing")

	var zero_kill_cases: Array = flagged_cases.get("zero_kill_cases", [])
	if not zero_kill_cases.is_empty():
		push_error("[FAIL] autoplay still has zero-kill cases")

	for line in result["lines"]:
		print(line)

	for line in result["summary_lines"]:
		print(line)

	print("[REPORT] cases=%s pass=%s fail=%s avg_rounds=%s" % [
		aggregate.get("case_count", 0),
		aggregate.get("pass_count", 0),
		aggregate.get("fail_count", 0),
		aggregate.get("average_completed_rounds", 0.0),
	])

	var markdown_text = runner.build_markdown_report(result)
	if not markdown_text.contains("# M0 Autoplay Report") \
		or not markdown_text.contains("## Card Play Blockers") \
		or not markdown_text.contains("## Next Action Queue") \
		or not markdown_text.contains("## Recommendation Decisions") \
		or not markdown_text.contains("## Recommendation Contrast Samples") \
		or not markdown_text.contains("## Wave Stack Tempo Moments") \
		or not markdown_text.contains("No bonus rewards") \
		or not markdown_text.contains("Choice type") \
		or not markdown_text.contains("Run A:") \
		or not markdown_text.contains("## Boss Part Warnings") \
		or not markdown_text.contains("## Case Matrix") \
		or not markdown_text.contains("## Class Weakness Signals") \
		or not markdown_text.contains("## Alpha Focus Queue") \
		or not markdown_text.contains("## Flagged Cases") \
		or not markdown_text.contains("Recent decisions"):
		push_error("[FAIL] autoplay markdown report is malformed")

	var save_result = runner.save_report_bundle(result, "autoplay_smoke")
	if bool(save_result.get("ok", false)):
		var json_result: Dictionary = save_result.get("json", {})
		var markdown_result: Dictionary = save_result.get("markdown", {})
		print("[REPORT] saved %s and %s" % [
			json_result.get("path", "user://m0_autoplay_smoke_report.json"),
			markdown_result.get("path", "user://m0_autoplay_smoke_report.md"),
		])
	else:
		push_error("[FAIL] autoplay report save failed: %s" % save_result.get("reason", "unknown"))

	if not bool(result["ok"]):
		for failure in result["failures"]:
			push_error("[FAIL] %s" % failure)

	var report_ok = not report.is_empty() and bool(save_result.get("ok", false)) and not report.get("case_matrix", {}).is_empty()
	quit(0 if bool(result["ok"]) and aggregate_ok and report_ok else 1)
