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

	var flagged_cases: Dictionary = report.get("flagged_cases", {})
	if flagged_cases.is_empty():
		push_error("[FAIL] autoplay flagged cases are missing")

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
	if not markdown_text.contains("# M0 Autoplay Report") or not markdown_text.contains("## Case Matrix") or not markdown_text.contains("## Flagged Cases"):
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
