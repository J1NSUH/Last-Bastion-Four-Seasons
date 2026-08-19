extends SceneTree

const MAIN_SCENE_PATH = "res://scenes/main/Main.tscn"

var failed = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene = load(MAIN_SCENE_PATH)
	if packed_scene == null:
		_fail("main scene loads")
		quit(1)
		return

	var scene = packed_scene.instantiate()
	if scene == null:
		_fail("main scene instantiates")
		quit(1)
		return

	root.add_child(scene)
	await process_frame
	await process_frame

	var m0_scene = scene.find_child("M0TestScene", true, false)
	_assert(m0_scene != null, "M0 test scene is present")
	if m0_scene == null:
		root.remove_child(scene)
		scene.queue_free()
		await process_frame
		quit(1)
		return

	var alpha_focus_panel = scene.find_child("AlphaFocusPanel", true, false)
	var alpha_focus_title = scene.find_child("AlphaFocusTitleLabel", true, false)
	var alpha_focus_body = scene.find_child("AlphaFocusBodyLabel", true, false)
	var alpha_focus_action = scene.find_child("AlphaFocusActionButton", true, false)
	var alpha_focus_manual_status = scene.find_child("AlphaFocusManualStatusLabel", true, false)
	var alpha_contrast_prev = scene.find_child("AlphaContrastPrevButton", true, false)
	var alpha_contrast_next = scene.find_child("AlphaContrastNextButton", true, false)
	var alpha_contrast_status = scene.find_child("AlphaContrastStatusLabel", true, false)
	var alpha_coverage_title = scene.find_child("AlphaCoverageTitleLabel", true, false)
	var alpha_coverage_body = scene.find_child("AlphaCoverageBodyLabel", true, false)
	var alpha_coverage_run = scene.find_child("RunAlphaCoverageButton", true, false)
	var alpha_coverage_open_next_manual = scene.find_child("OpenAlphaNextManualButton", true, false)
	var alpha_coverage_open_issue = scene.find_child("OpenAlphaIssueButton", true, false)
	var alpha_coverage_open_fix_lane = scene.find_child("OpenAlphaFixLaneButton", true, false)
	var alpha_coverage_open_recommendation_fix = scene.find_child("OpenAlphaRecommendationFixButton", true, false)
	var alpha_coverage_probe_fix_lane = scene.find_child("ProbeAlphaFixLaneButton", true, false)

	_assert(alpha_focus_panel != null, "alpha focus panel is present")
	_assert(alpha_focus_title != null, "alpha focus title is present")
	_assert(alpha_focus_body != null, "alpha focus body is present")
	_assert(alpha_focus_action != null, "alpha focus action button is present")
	_assert(alpha_focus_manual_status != null, "alpha focus manual review label is present")
	_assert(alpha_contrast_prev != null, "alpha contrast previous button is present")
	_assert(alpha_contrast_next != null, "alpha contrast next button is present")
	_assert(alpha_contrast_status != null, "alpha contrast status label is present")
	_assert(alpha_coverage_title != null, "alpha coverage title is present")
	_assert(alpha_coverage_body != null, "alpha coverage body is present")
	_assert(alpha_coverage_run != null, "alpha coverage run button is present")
	_assert(alpha_coverage_open_next_manual != null, "alpha coverage next manual button is present")
	_assert(alpha_coverage_open_issue != null, "alpha coverage issue button is present")
	_assert(alpha_coverage_open_fix_lane != null, "alpha coverage fix lane button is present")
	_assert(alpha_coverage_open_recommendation_fix != null, "alpha coverage recommendation fix button is present")
	_assert(alpha_coverage_probe_fix_lane != null, "alpha coverage fix lane probe button is present")

	var clear_saved_review_result: Dictionary = m0_scene._debug_clear_alpha_manual_review_save()
	_assert(bool(clear_saved_review_result.get("ok", false)), "alpha manual review save starts clean")
	await process_frame

	if alpha_coverage_title != null:
		_assert(str(alpha_coverage_title.text).contains("not run"), "alpha coverage starts idle")
	if alpha_coverage_open_next_manual != null:
		_assert(alpha_coverage_open_next_manual.disabled, "alpha coverage next manual button starts disabled")
		_assert(str(alpha_coverage_open_next_manual.text).contains("No manual"), "alpha coverage next manual button names empty state")

	if alpha_coverage_run != null:
		alpha_coverage_run.pressed.emit()
		await process_frame

	_assert(not m0_scene.run_started, "alpha coverage does not begin a run")
	_assert(bool(m0_scene.last_alpha_coverage_result.get("ok", false)), "alpha coverage stores passing result")

	if alpha_coverage_title != null:
		_assert(str(alpha_coverage_title.text).contains("PASS 16/16"), "alpha coverage panel shows passing case count")
	if alpha_coverage_body != null:
		var coverage_body_text = str(alpha_coverage_body.text)
		_assert(coverage_body_text.contains("functionality only"), "alpha coverage body states functional scope")
		_assert(coverage_body_text.contains("human alpha still required"), "alpha coverage body keeps human playtest gate")
		_assert(coverage_body_text.contains("Signals: 48/48"), "alpha coverage body shows signal count")
		_assert(coverage_body_text.contains("Recommendation choices:"), "alpha coverage body shows recommendation choice summary")
		_assert(coverage_body_text.contains("Recommendation focus:"), "alpha coverage body shows recommendation focus")
		_assert(coverage_body_text.contains("human check: choice ownership"), "alpha coverage keeps recommendation ownership gate")
		_assert(coverage_body_text.contains("Human review queue: 16 cases"), "alpha coverage body shows human review queue count")
		_assert(coverage_body_text.contains("Human review status: 0 clear / 0 issue / 16 remaining"), "alpha coverage body starts with manual review summary")
		_assert(coverage_body_text.contains("Review gaps: classes Guardian x4, Architect x4, Elementalist x4, Tinkerer x4"), "alpha coverage body summarizes remaining class gaps")
		_assert(coverage_body_text.contains("parties 1P x4, 2P x4, 3P x4, 4P x4"), "alpha coverage body summarizes remaining party gaps")
		_assert(coverage_body_text.contains("fronts east x4, north/east x4, west/north/east x4, west/north/east/south x4"), "alpha coverage body summarizes remaining front gaps")
		_assert(coverage_body_text.contains("Next priority: Architect 2P @north"), "alpha coverage body shows the highest-priority manual case")
		_assert(coverage_body_text.contains("Fix queue: 0 open"), "alpha coverage body starts with empty fix queue")

	var aggregate: Dictionary = m0_scene.last_alpha_coverage_result.get("aggregate", {})
	var summary_lines: Array = m0_scene.last_alpha_coverage_result.get("summary_lines", [])
	_assert(int(aggregate.get("case_count", 0)) == 16, "alpha coverage stores all 1p to 4p cases")
	_assert(summary_lines.size() == 16, "alpha coverage stores per-case summary lines")
	_assert(str(aggregate.get("recommendation_focus_summary", "")).contains("human check: choice ownership"), "alpha coverage stores recommendation focus")

	if alpha_focus_panel != null:
		_assert(alpha_focus_panel.visible, "alpha coverage exposes human review focus queue")
	if alpha_focus_title != null:
		_assert(str(alpha_focus_title.text).contains("Guardian 1P"), "alpha coverage focus starts from guardian solo case")
	if alpha_focus_body != null:
		var focus_body_text = str(alpha_focus_body.text)
		_assert(focus_body_text.contains("Human Gate:"), "alpha coverage focus states the human gate")
		_assert(focus_body_text.contains("Review Reason:"), "alpha coverage focus explains why the case needs review")
		_assert(focus_body_text.contains("Artifact Prep:"), "alpha coverage focus shows artifact prep context")
		_assert(focus_body_text.contains("Artifact memo"), "alpha coverage focus carries artifact next-wave memo")
		_assert(focus_body_text.contains("Recommendation Focus:"), "alpha coverage focus shows recommendation ownership context")
		_assert(focus_body_text.contains("Recommendation Contrast Sample:"), "alpha coverage focus shows browsable recommendation contrast sample")
		_assert(focus_body_text.contains("Run A:"), "alpha coverage focus shows recommendation follow branch")
		_assert(focus_body_text.contains("Run B:"), "alpha coverage focus shows recommendation alternate branch")
		_assert(focus_body_text.contains("Action Queue #1"), "alpha coverage focus includes matched next action")
	if alpha_focus_manual_status != null:
		_assert(str(alpha_focus_manual_status.text).contains("not recorded"), "alpha coverage focus starts without human review")

	var coverage_focus_marker: Dictionary = m0_scene._alpha_focus_setup_marker()
	_assert(not coverage_focus_marker.is_empty(), "alpha coverage focus exposes a first setup marker")
	if m0_scene.map_view != null:
		_assert(m0_scene.map_view.alpha_focus_direction == "east", "alpha coverage focus highlights the first review direction")
		if not coverage_focus_marker.is_empty():
			var coverage_focus_tile: Vector2i = coverage_focus_marker.get("tile", Vector2i.ZERO)
			_assert(m0_scene.map_view.debug_alpha_focus_setup_label(coverage_focus_tile) == "F", "map marks the alpha focus setup tile")

	if alpha_contrast_status != null:
		_assert(str(alpha_contrast_status.text).contains("1/"), "alpha coverage contrast browser starts on the first sample")
		_assert(not str(alpha_contrast_status.text).contains("none"), "alpha coverage contrast browser receives coverage samples")
	if alpha_contrast_next != null:
		_assert(not alpha_contrast_next.disabled, "alpha coverage contrast next enables for the focus choice set")
		alpha_contrast_next.pressed.emit()
		await process_frame
		if alpha_focus_body != null:
			_assert(str(alpha_focus_body.text).contains("Recommendation Contrast Sample: 2/"), "alpha coverage contrast next shows the second sample")
		if alpha_contrast_status != null:
			_assert(str(alpha_contrast_status.text).contains("2/"), "alpha coverage contrast status advances after next")
	if alpha_contrast_prev != null:
		alpha_contrast_prev.pressed.emit()
		await process_frame
		if alpha_focus_body != null:
			_assert(str(alpha_focus_body.text).contains("Recommendation Contrast Sample: 1/"), "alpha coverage contrast previous returns to first sample")

	if alpha_focus_action != null:
		_assert(not alpha_focus_action.disabled, "alpha coverage focus enables next action setup")
	if alpha_coverage_open_next_manual != null:
		_assert(not alpha_coverage_open_next_manual.disabled, "alpha coverage next manual button enables when review cases exist")
		_assert(str(alpha_coverage_open_next_manual.text).contains("Open priority"), "alpha coverage next manual button names priority action")
		_assert(str(alpha_coverage_open_next_manual.tooltip_text).contains("Architect 2P @north"), "alpha coverage next manual tooltip names priority case")
	if alpha_coverage_open_issue != null:
		_assert(alpha_coverage_open_issue.disabled, "alpha coverage issue button starts disabled")
	if alpha_coverage_open_fix_lane != null:
		_assert(alpha_coverage_open_fix_lane.disabled, "alpha coverage fix lane button starts disabled")
	if alpha_coverage_open_recommendation_fix != null:
		_assert(alpha_coverage_open_recommendation_fix.disabled, "alpha coverage recommendation fix button starts disabled")
	if alpha_coverage_probe_fix_lane != null:
		_assert(alpha_coverage_probe_fix_lane.disabled, "alpha coverage fix lane probe button starts disabled")

	root.remove_child(scene)
	scene.queue_free()
	await process_frame

	quit(1 if failed else 0)


func _assert(condition: bool, label: String) -> void:
	if condition:
		print("[PASS] %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	failed = true
	push_error("[FAIL] %s" % label)
