extends SceneTree

const MAIN_SCENE_PATH = "res://scenes/main/Main.tscn"
const M0MapViewScript = preload("res://scripts/m0/M0MapView.gd")

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
	if m0_scene != null:
		_assert(m0_scene._round_recap_badge_for_focus("leak") == "LEAK", "round recap leak focus has a badge")
		_assert(m0_scene._round_recap_badge_for_focus("collapse") == "BREAK", "round recap collapse focus has a badge")
		_assert(m0_scene._round_recap_badge_for_focus("planned_collapse") == "TACTIC", "round recap planned collapse focus has a badge")
		_assert(m0_scene._round_recap_badge_for_focus("boss_clear") == "BOSS", "round recap boss focus has a badge")
	var front_label = scene.find_child("FrontStatusLabel", true, false)
	_assert(front_label != null, "front status label is present")
	if front_label != null:
		var label_text = str(front_label.text)
		_assert(label_text.contains("Front preview"), "front status shows pressure preview")
		_assert(label_text.contains("Defense fronts"), "front status shows defense summary")
	var stack_risk_label = scene.find_child("StackRiskLabel", true, false)
	_assert(stack_risk_label != null, "stack risk label is present")
	if stack_risk_label != null:
		_assert(str(stack_risk_label.text).contains("locked"), "stack risk label explains setup lock")
	var resource_label = scene.find_child("ResourceStatusLabel", true, false)
	_assert(resource_label != null, "resource status label is present")
	if resource_label != null:
		_assert(str(resource_label.text).contains("Round prep"), "resource status shows round preparation")
	var action_status_label = scene.find_child("ActionStatusLabel", true, false)
	_assert(action_status_label != null, "action status label is present")
	if action_status_label != null:
		_assert(str(action_status_label.text).contains("Begin run first"), "action status explains setup lock")
	var wave_preview_label = scene.find_child("WavePreviewLabel", true, false)
	_assert(wave_preview_label != null, "wave preview label is present")
	if wave_preview_label != null:
		var setup_wave_preview_text = str(wave_preview_label.text)
		_assert(setup_wave_preview_text.contains("Wave plan:"), "wave preview shows the next wave plan")
		_assert(setup_wave_preview_text.contains("Route Read"), "wave preview shows the scheduled wave intent")
		_assert(setup_wave_preview_text.contains("prep path_read"), "wave preview shows data-driven prep tags")
		_assert(setup_wave_preview_text.contains("Spawn timing R1"), "wave preview shows spawn timing")
		_assert(setup_wave_preview_text.contains("0s east Walker"), "wave preview spawn timing names the first packet")
	if m0_scene != null and m0_scene.map_view != null:
		_assert(m0_scene.map_view.debug_spawn_warning_label(Vector2i(20, 10)) == ">", "map marks the next solo east spawn at the active entrance")
		_assert(m0_scene.map_view.debug_spawn_warning_label(Vector2i(10, 0)).is_empty(), "map does not warn inactive north entrance in solo")
	var tactical_hint_label = scene.find_child("WaveTacticalHintLabel", true, false)
	_assert(tactical_hint_label != null, "wave tactical hint label is present")
	if tactical_hint_label != null:
		_assert(str(tactical_hint_label.text).contains("begin the run first"), "wave tactical hint explains setup lock")
	var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
	_assert(wave_readiness_label != null, "wave readiness label is present")
	if wave_readiness_label != null:
		_assert(str(wave_readiness_label.text).contains("begin the run first"), "wave readiness explains setup lock")
	var log_filter_option = scene.find_child("LogFilterOption", true, false)
	_assert(log_filter_option != null, "activity log filter option is present")
	var important_log_toggle = scene.find_child("ImportantLogToggle", true, false)
	_assert(important_log_toggle != null, "important activity toggle is present")
	var activity_log_label = scene.find_child("ActivityLogLabel", true, false)
	_assert(activity_log_label != null, "activity log label is present")
	var use_best_target_button = scene.find_child("UseBestTargetButton", true, false)
	_assert(use_best_target_button != null, "use best target button is present")
	var setup_plan_button = scene.find_child("UseSetupPlanButton", true, false)
	_assert(setup_plan_button != null, "use setup plan button is present")
	var call_next_button = scene.find_child("CallNextButton", true, false)
	_assert(call_next_button != null, "pull next wave button is present")
	if call_next_button != null:
		_assert(str(call_next_button.text).contains("Pull next wave"), "pull next wave button uses tempo copy")
	var hold_stack_button = scene.find_child("HoldStackButton", true, false)
	_assert(hold_stack_button != null, "hold pull button is present")
	if hold_stack_button != null:
		_assert(str(hold_stack_button.text).contains("Hold pull"), "hold pull button uses tempo copy")
	var risk_ping_button = scene.find_child("RiskPingButton0", true, false)
	_assert(risk_ping_button != null, "first risk ping button is present")
	if risk_ping_button != null:
		_assert(not risk_ping_button.visible, "risk ping button starts hidden before a live threat")
	if m0_scene != null and activity_log_label != null:
		m0_scene.debug_log.clear()
		m0_scene.debug_log.push("Walker spawned at east.")
		m0_scene.debug_log.push("Reward claimed: Arc Spark.")
		m0_scene.show_debug_log = true
		m0_scene.log_filter_category = "reward"
		m0_scene._refresh_log()
		await process_frame
		var reward_log_text = str(activity_log_label.text)
		_assert(reward_log_text.contains("Reward claimed"), "activity log reward filter shows reward entries")
		_assert(not reward_log_text.contains("Walker spawned"), "activity log reward filter hides combat entries")
		m0_scene.log_filter_category = "all"
		m0_scene.show_important_logs_only = true
		m0_scene._refresh_log()
		await process_frame
		var important_log_text = str(activity_log_label.text)
		_assert(important_log_text.contains("Reward claimed"), "activity log important filter keeps key choices")
		_assert(not important_log_text.contains("Walker spawned"), "activity log important filter hides routine combat")
		var focus_text = m0_scene._format_autoplay_focus_entry({
			"rank": 1,
			"class_label": "Guardian",
			"player_count": 1,
			"direction": "east",
			"primary_signal": "low base margin",
			"evidence": "HP 64 with 3 base hits",
			"next_probe": "watch first contact",
		})
		_assert(focus_text.contains("Alpha focus #1"), "autoplay focus entry formats rank")
		_assert(focus_text.contains("Next:"), "autoplay focus entry includes next probe")
		var alpha_focus_panel = scene.find_child("AlphaFocusPanel", true, false)
		var alpha_focus_title = scene.find_child("AlphaFocusTitleLabel", true, false)
		var alpha_focus_body = scene.find_child("AlphaFocusBodyLabel", true, false)
		var alpha_focus_prev = scene.find_child("AlphaFocusPrevButton", true, false)
		var alpha_focus_next = scene.find_child("AlphaFocusNextButton", true, false)
		var alpha_contrast_prev = scene.find_child("AlphaContrastPrevButton", true, false)
		var alpha_contrast_next = scene.find_child("AlphaContrastNextButton", true, false)
		var alpha_contrast_status = scene.find_child("AlphaContrastStatusLabel", true, false)
		var alpha_focus_action = scene.find_child("AlphaFocusActionButton", true, false)
		var alpha_focus_apply = scene.find_child("AlphaFocusApplyButton", true, false)
		var alpha_focus_probe = scene.find_child("AlphaFocusProbeButton", true, false)
		var alpha_focus_probe_status = scene.find_child("AlphaFocusProbeStatusLabel", true, false)
		var alpha_focus_manual_status = scene.find_child("AlphaFocusManualStatusLabel", true, false)
		var alpha_issue_tag = scene.find_child("AlphaIssueTagOption", true, false)
		var alpha_recommendation_contrast = scene.find_child("AlphaRecommendationContrastOption", true, false)
		var alpha_recommendation_auto_pick = scene.find_child("AlphaRecommendationFixAutoPickCheck", true, false)
		var alpha_recommendation_alt_hidden = scene.find_child("AlphaRecommendationFixAltHiddenCheck", true, false)
		var alpha_recommendation_talk_blocked = scene.find_child("AlphaRecommendationFixTalkBlockedCheck", true, false)
		var alpha_focus_mark_clear = scene.find_child("AlphaFocusMarkClearButton", true, false)
		var alpha_focus_mark_issue = scene.find_child("AlphaFocusMarkIssueButton", true, false)
		var alpha_coverage_panel = scene.find_child("AlphaCoveragePanel", true, false)
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
		_assert(alpha_focus_prev != null, "alpha focus previous button is present")
		_assert(alpha_focus_next != null, "alpha focus next button is present")
		_assert(alpha_contrast_prev != null, "alpha contrast previous button is present")
		_assert(alpha_contrast_next != null, "alpha contrast next button is present")
		_assert(alpha_contrast_status != null, "alpha contrast status label is present")
		_assert(alpha_focus_action != null, "alpha focus action button is present")
		_assert(alpha_focus_apply != null, "alpha focus setup button is present")
		_assert(alpha_focus_probe != null, "alpha focus probe button is present")
		_assert(alpha_focus_probe_status != null, "alpha focus probe compare label is present")
		_assert(alpha_focus_manual_status != null, "alpha focus manual review label is present")
		_assert(alpha_issue_tag != null, "alpha issue tag option is present")
		_assert(alpha_recommendation_contrast != null, "alpha recommendation contrast option is present")
		_assert(alpha_recommendation_auto_pick != null, "alpha recommendation auto-pick check is present")
		_assert(alpha_recommendation_alt_hidden != null, "alpha recommendation alternate hidden check is present")
		_assert(alpha_recommendation_talk_blocked != null, "alpha recommendation talk blocked check is present")
		_assert(alpha_focus_mark_clear != null, "alpha focus mark clear button is present")
		_assert(alpha_focus_mark_issue != null, "alpha focus mark issue button is present")
		_assert(alpha_coverage_panel != null, "alpha coverage panel is present")
		_assert(alpha_coverage_title != null, "alpha coverage title is present")
		_assert(alpha_coverage_body != null, "alpha coverage body is present")
		_assert(alpha_coverage_run != null, "alpha coverage run button is present")
		_assert(alpha_coverage_open_next_manual != null, "alpha coverage next manual button is present")
		_assert(alpha_coverage_open_issue != null, "alpha coverage open issue button is present")
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
				_assert(coverage_body_text.contains("card"), "alpha coverage body includes card recommendation choices")
				_assert(coverage_body_text.contains("Recommendation by class:"), "alpha coverage body shows class recommendation split")
				_assert(coverage_body_text.contains("Recommendation by party:"), "alpha coverage body shows party recommendation split")
				_assert(coverage_body_text.contains("Recommendation by front:"), "alpha coverage body shows front recommendation split")
				_assert(coverage_body_text.contains("Recommendation focus:"), "alpha coverage body shows recommendation focus")
				_assert(coverage_body_text.contains("human check: choice ownership"), "alpha coverage recommendation focus keeps human ownership gate")
				_assert(coverage_body_text.contains("Human review queue: 16 cases"), "alpha coverage body shows human review queue count")
				_assert(coverage_body_text.contains("Human review status: 0 clear / 0 issue / 16 remaining"), "alpha coverage body starts with manual review summary")
				_assert(coverage_body_text.contains("Review gaps: classes Guardian x4, Architect x4, Elementalist x4, Tinkerer x4"), "alpha coverage body summarizes remaining class gaps")
				_assert(coverage_body_text.contains("parties 1P x4, 2P x4, 3P x4, 4P x4"), "alpha coverage body summarizes remaining party gaps")
				_assert(coverage_body_text.contains("fronts east x4, north/east x4, west/north/east x4, west/north/east/south x4"), "alpha coverage body summarizes remaining front gaps")
				_assert(coverage_body_text.contains("Priority spread: high 9 / medium 6 / low 1"), "alpha coverage body summarizes manual priority spread")
				_assert(coverage_body_text.contains("top class Architect"), "alpha coverage body summarizes top priority class")
				_assert(coverage_body_text.contains("top front north/east"), "alpha coverage body summarizes top priority front")
				_assert(coverage_body_text.contains("Priority lane: Architect + north/east"), "alpha coverage body summarizes priority lane")
				_assert(coverage_body_text.contains("start Architect 2P @north"), "alpha coverage body summarizes priority lane start case")
				_assert(coverage_body_text.contains("Next priority: Architect 2P @north"), "alpha coverage body shows the highest-priority manual case")
				_assert(coverage_body_text.contains("score"), "alpha coverage body shows manual priority score")
				_assert(coverage_body_text.contains("Fix queue: 0 open"), "alpha coverage body starts with empty fix queue")
				_assert(coverage_body_text.contains("Guardian 1P"), "alpha coverage body lists class cases")
			if alpha_coverage_open_next_manual != null:
				_assert(not alpha_coverage_open_next_manual.disabled, "alpha coverage next manual button enables when review cases exist")
				_assert(str(alpha_coverage_open_next_manual.text).contains("Open priority"), "alpha coverage next manual button names priority action")
				_assert(str(alpha_coverage_open_next_manual.tooltip_text).contains("Architect 2P @north"), "alpha coverage next manual tooltip names priority case")
				_assert(str(alpha_coverage_open_next_manual.tooltip_text).contains("score"), "alpha coverage next manual tooltip names priority score")
			if alpha_coverage_open_issue != null:
				_assert(alpha_coverage_open_issue.disabled, "alpha coverage issue button starts disabled")
				_assert(str(alpha_coverage_open_issue.text).contains("No issue"), "alpha coverage issue button names empty state")
			if alpha_coverage_open_fix_lane != null:
				_assert(alpha_coverage_open_fix_lane.disabled, "alpha coverage fix lane button starts disabled")
				_assert(str(alpha_coverage_open_fix_lane.text).contains("No fix lane"), "alpha coverage fix lane button names empty state")
			if alpha_coverage_open_recommendation_fix != null:
				_assert(alpha_coverage_open_recommendation_fix.disabled, "alpha coverage recommendation fix button starts disabled")
				_assert(str(alpha_coverage_open_recommendation_fix.text).contains("No rec fix"), "alpha coverage recommendation fix button names empty state")
			if alpha_recommendation_auto_pick != null:
				_assert(alpha_recommendation_auto_pick.disabled, "recommendation fix auto-pick check starts disabled")
			if alpha_recommendation_alt_hidden != null:
				_assert(alpha_recommendation_alt_hidden.disabled, "recommendation fix alternate hidden check starts disabled")
			if alpha_recommendation_talk_blocked != null:
				_assert(alpha_recommendation_talk_blocked.disabled, "recommendation fix talk blocked check starts disabled")
			if alpha_coverage_probe_fix_lane != null:
				_assert(alpha_coverage_probe_fix_lane.disabled, "alpha coverage fix lane probe button starts disabled")
				_assert(str(alpha_coverage_probe_fix_lane.text).contains("No fix probe"), "alpha coverage fix lane probe button names empty state")
			var stored_coverage_aggregate: Dictionary = m0_scene.last_alpha_coverage_result.get("aggregate", {})
			var stored_coverage_summary_lines: Array = m0_scene.last_alpha_coverage_result.get("summary_lines", [])
			_assert(int(stored_coverage_aggregate.get("case_count", 0)) == 16, "alpha coverage stores all 1p to 4p cases")
			_assert(stored_coverage_summary_lines.size() == 16, "alpha coverage stores per-case summary lines")
			_assert(str(stored_coverage_aggregate.get("recommendation_focus_summary", "")).contains("human check: choice ownership"), "alpha coverage stores recommendation focus")
			if alpha_focus_panel != null:
				_assert(alpha_focus_panel.visible, "alpha coverage exposes human review focus queue")
			if alpha_focus_title != null:
				_assert(str(alpha_focus_title.text).contains("Guardian 1P"), "alpha coverage focus starts from guardian solo case")
			var coverage_focus_marker: Dictionary = m0_scene._alpha_focus_setup_marker()
			_assert(not coverage_focus_marker.is_empty(), "alpha coverage focus exposes a first setup marker")
			if alpha_focus_body != null:
				var coverage_focus_text = str(alpha_focus_body.text)
				_assert(coverage_focus_text.contains("Human Gate:"), "alpha coverage focus states the human gate")
				_assert(coverage_focus_text.contains("Review Reason:"), "alpha coverage focus explains why the case needs review")
				_assert(coverage_focus_text.contains("Reward Lens:"), "alpha coverage focus shows reward recommendation context")
				_assert(coverage_focus_text.contains("Recommendation Focus:"), "alpha coverage focus shows recommendation ownership context")
				_assert(coverage_focus_text.contains("Human check: choice ownership"), "alpha coverage focus keeps recommendation ownership gate")
				_assert(coverage_focus_text.contains("Recommendation Contrast:"), "alpha coverage focus shows recommendation contrast probe")
				_assert(coverage_focus_text.contains("Recommendation Contrast Sample:"), "alpha coverage focus shows browsable recommendation contrast sample")
				_assert(coverage_focus_text.contains("Run A:"), "alpha coverage focus shows recommendation follow branch")
				_assert(coverage_focus_text.contains("Run B:"), "alpha coverage focus shows recommendation alternate branch")
				_assert(coverage_focus_text.contains("Score"), "alpha coverage focus shows review priority score")
				_assert(coverage_focus_text.contains("Action Queue #1"), "alpha coverage focus includes matched next action")
				_assert(coverage_focus_text.contains("Reason:"), "alpha coverage focus action explains review priority reason")
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
			if m0_scene.map_view != null:
				_assert(m0_scene.map_view.alpha_focus_direction == "east", "alpha coverage focus highlights the first review direction")
				if not coverage_focus_marker.is_empty():
					var coverage_focus_tile: Vector2i = coverage_focus_marker.get("tile", Vector2i.ZERO)
					_assert(m0_scene.map_view.debug_alpha_focus_setup_label(coverage_focus_tile) == "F", "map marks the alpha focus setup tile")
			if alpha_focus_manual_status != null:
				_assert(str(alpha_focus_manual_status.text).contains("not recorded"), "alpha coverage focus starts without human review")
			if alpha_issue_tag != null:
				var front_confusion_index = m0_scene._alpha_issue_tag_index("front_confusion")
				alpha_issue_tag.select(front_confusion_index)
				alpha_issue_tag.item_selected.emit(front_confusion_index)
			if alpha_recommendation_contrast != null:
				var alternate_clearer_index = m0_scene._alpha_recommendation_contrast_index("alternate_clearer")
				alpha_recommendation_contrast.select(alternate_clearer_index)
				alpha_recommendation_contrast.item_selected.emit(alternate_clearer_index)
			if alpha_recommendation_auto_pick != null:
				_assert(not alpha_recommendation_auto_pick.disabled, "recommendation fix auto-pick check enables for unclear recommendation contrast")
				alpha_recommendation_auto_pick.button_pressed = true
				alpha_recommendation_auto_pick.toggled.emit(true)
			if alpha_recommendation_alt_hidden != null:
				_assert(not alpha_recommendation_alt_hidden.disabled, "recommendation fix alternate hidden check enables for unclear recommendation contrast")
				alpha_recommendation_alt_hidden.button_pressed = true
				alpha_recommendation_alt_hidden.toggled.emit(true)
			if alpha_recommendation_talk_blocked != null:
				_assert(not alpha_recommendation_talk_blocked.disabled, "recommendation fix talk blocked check enables for unclear recommendation contrast")
			if alpha_focus_mark_issue != null:
				alpha_focus_mark_issue.pressed.emit()
				await process_frame
				if alpha_focus_title != null:
					_assert(str(alpha_focus_title.text).contains("ISSUE"), "manual issue review marks the focus title")
				if alpha_focus_body != null:
					var issue_focus_body_text = str(alpha_focus_body.text)
					_assert(issue_focus_body_text.contains("Human Review: ISSUE"), "manual issue review marks the focus body")
					_assert(issue_focus_body_text.contains("Front confusion"), "manual issue review body shows issue tag")
					_assert(issue_focus_body_text.contains("Rec: Alternate clearer"), "manual issue review body shows recommendation contrast result")
					_assert(issue_focus_body_text.contains("Rec checks: Auto-pick, Alt hidden"), "manual issue review body shows recommendation checklist summary")
					_assert(issue_focus_body_text.contains("Recommendation Fix Detail: Alternate clearer -> soften recommendation wording"), "manual issue review body shows recommendation fix detail")
					_assert(issue_focus_body_text.contains("Recommendation Fix Checks: Auto-pick, Alt hidden"), "manual issue review body shows recommendation fix checklist detail")
					_assert(issue_focus_body_text.contains("Recommendation Rewrite Preset: Consider"), "manual issue review body shows recommendation rewrite preset")
					_assert(issue_focus_body_text.contains("is still valid if the table wants flexibility"), "manual issue review body keeps recommendation preset as a table choice")
					_assert(issue_focus_body_text.contains("Recommendation Source:"), "manual issue review body shows recommendation source detail")
					_assert(issue_focus_body_text.contains("Recommendation Rewrite Check:"), "manual issue review body shows recommendation rewrite check")
				if alpha_focus_manual_status != null:
					_assert(str(alpha_focus_manual_status.text).contains("ISSUE"), "manual issue review updates the status label")
					_assert(str(alpha_focus_manual_status.text).contains("Front confusion"), "manual issue review status shows issue tag")
					_assert(str(alpha_focus_manual_status.text).contains("Rec: Alternate clearer"), "manual issue review status shows recommendation contrast result")
					_assert(str(alpha_focus_manual_status.text).contains("Rec checks: Auto-pick, Alt hidden"), "manual issue review status shows recommendation checklist summary")
				if alpha_coverage_body != null:
					var issue_coverage_text = str(alpha_coverage_body.text)
					_assert(issue_coverage_text.contains("Human review status: 0 clear / 1 issue / 15 remaining"), "alpha coverage summary counts manual issue")
					_assert(issue_coverage_text.contains("Review gaps:"), "alpha coverage summary keeps gap summary after manual issue")
					_assert(issue_coverage_text.contains("Guardian x3"), "alpha coverage summary reduces the marked class gap")
					_assert(issue_coverage_text.contains("Priority spread: high 9 / medium 6 / low 0"), "alpha coverage summary removes marked issue from priority spread")
					_assert(issue_coverage_text.contains("Priority lane: Architect + north/east"), "alpha coverage summary keeps priority lane after manual issue")
					_assert(issue_coverage_text.contains("Fix queue: 1 open"), "alpha coverage summary counts open fix queue")
					_assert(issue_coverage_text.contains("Recommendation contrast: Alternate clearer x1"), "alpha coverage summary counts recommendation contrast result")
					_assert(issue_coverage_text.contains("Recommendation wording queue: 1 open"), "alpha coverage summary counts recommendation wording queue")
					_assert(issue_coverage_text.contains("Recommendation wording fix: Alternate clearer x1 -> soften recommendation wording"), "alpha coverage summary recommends a recommendation wording fix")
					_assert(issue_coverage_text.contains("Recommendation wording case: Guardian 1P @east [Front confusion]"), "alpha coverage summary lists recommendation wording case")
					_assert(issue_coverage_text.contains("Recommendation wording priority: Auto-pick x1 -> soften directive tone"), "alpha coverage summary shows top recommendation wording priority")
					_assert(issue_coverage_text.contains("Recommendation wording checks: Auto-pick x1, Alt hidden x1"), "alpha coverage summary counts recommendation wording checklist")
					_assert(issue_coverage_text.contains("Issue tags: Front confusion x1"), "alpha coverage summary counts issue tags")
					_assert(issue_coverage_text.contains("Fix recommendation: Front confusion x1 -> check active-front highlights"), "alpha coverage summary recommends a fix lane")
					_assert(issue_coverage_text.contains("Fix lane case: Guardian 1P @east [Front confusion]"), "alpha coverage summary lists fix lane case")
					_assert(issue_coverage_text.contains("Fix lane probe: not run"), "alpha coverage summary starts fix lane probe as not run")
					_assert(issue_coverage_text.contains("Fix lane priority: WATCH"), "alpha coverage summary starts fix lane priority as watch")
					_assert(issue_coverage_text.contains("Issue cases: Guardian 1P @east [Front confusion]"), "alpha coverage summary lists issue case with tag")
				if alpha_coverage_open_issue != null:
					_assert(not alpha_coverage_open_issue.disabled, "alpha coverage issue button enables when issue exists")
				if alpha_coverage_open_fix_lane != null:
					_assert(not alpha_coverage_open_fix_lane.disabled, "alpha coverage fix lane button enables when issue exists")
					_assert(str(alpha_coverage_open_fix_lane.tooltip_text).contains("Front confusion x1"), "alpha coverage fix lane button names the top tag")
				if alpha_coverage_open_recommendation_fix != null:
					_assert(not alpha_coverage_open_recommendation_fix.disabled, "alpha coverage recommendation fix button enables when recommendation wording issue exists")
					_assert(str(alpha_coverage_open_recommendation_fix.tooltip_text).contains("Alternate clearer x1"), "alpha coverage recommendation fix button names the top contrast")
				if alpha_coverage_probe_fix_lane != null:
					_assert(not alpha_coverage_probe_fix_lane.disabled, "alpha coverage fix lane probe button enables when issue exists")
					_assert(str(alpha_coverage_probe_fix_lane.tooltip_text).contains("Front confusion x1"), "alpha coverage fix lane probe button names the top tag")
				if alpha_focus_next != null:
					alpha_focus_next.pressed.emit()
					await process_frame
					if alpha_focus_title != null:
						_assert(str(alpha_focus_title.text).contains("Architect 2P"), "alpha focus can move away from marked issue")
				if alpha_coverage_open_fix_lane != null:
					alpha_coverage_open_fix_lane.pressed.emit()
					await process_frame
					if alpha_focus_title != null:
						var reopened_fix_lane_title = str(alpha_focus_title.text)
						_assert(reopened_fix_lane_title.contains("Guardian 1P"), "alpha coverage fix lane button returns to top tag issue")
						_assert(reopened_fix_lane_title.contains("ISSUE"), "alpha coverage fix lane button returns to marked issue")
				if alpha_focus_next != null:
					alpha_focus_next.pressed.emit()
					await process_frame
					if alpha_focus_title != null:
						_assert(str(alpha_focus_title.text).contains("Architect 2P"), "alpha focus can move away again before opening first issue")
				if alpha_coverage_open_issue != null:
					alpha_coverage_open_issue.pressed.emit()
					await process_frame
					if alpha_focus_title != null:
						var reopened_issue_title = str(alpha_focus_title.text)
						_assert(reopened_issue_title.contains("Guardian 1P"), "alpha coverage issue button returns to issue case")
						_assert(reopened_issue_title.contains("ISSUE"), "alpha coverage issue button returns to marked issue")
				if alpha_focus_next != null:
					alpha_focus_next.pressed.emit()
					await process_frame
					if alpha_focus_title != null:
						_assert(str(alpha_focus_title.text).contains("Architect 2P"), "alpha focus can move away before opening recommendation fix")
				if alpha_coverage_open_recommendation_fix != null:
					alpha_coverage_open_recommendation_fix.pressed.emit()
					await process_frame
					if alpha_focus_title != null:
						var reopened_recommendation_fix_title = str(alpha_focus_title.text)
						_assert(reopened_recommendation_fix_title.contains("Guardian 1P"), "alpha coverage recommendation fix button returns to recommendation wording case")
						_assert(reopened_recommendation_fix_title.contains("ISSUE"), "alpha coverage recommendation fix button returns to marked recommendation issue")
					if alpha_focus_body != null:
						var reopened_recommendation_fix_body = str(alpha_focus_body.text)
						_assert(reopened_recommendation_fix_body.contains("Recommendation Fix Detail: Alternate clearer -> soften recommendation wording"), "alpha coverage recommendation fix button opens case with recommendation fix detail")
						_assert(reopened_recommendation_fix_body.contains("Recommendation Fix Checks: Auto-pick, Alt hidden"), "alpha coverage recommendation fix button opens case with recommendation fix checklist detail")
						_assert(reopened_recommendation_fix_body.contains("Recommendation Rewrite Preset: Consider"), "alpha coverage recommendation fix button opens case with recommendation rewrite preset")
						_assert(reopened_recommendation_fix_body.contains("Recommendation Rewrite Check:"), "alpha coverage recommendation fix button opens case with rewrite check")
				m0_scene._record_alpha_probe_result(m0_scene._selected_alpha_focus_entry(), 99, 999)
				m0_scene._refresh_alpha_focus_panel()
				m0_scene._refresh_alpha_coverage_panel()
				await process_frame
				if alpha_coverage_body != null:
					var probe_coverage_text = str(alpha_coverage_body.text)
					_assert(probe_coverage_text.contains("Fix lane probe: BETTER"), "alpha coverage summary shows fix lane probe status")
					_assert(probe_coverage_text.contains("Fix lane priority: CLEAR CANDIDATE"), "alpha coverage summary marks better fix lane as clear candidate")
					_assert(probe_coverage_text.contains("R99 HP 999"), "alpha coverage summary shows fix lane probe comparison")
				if alpha_focus_mark_clear != null:
					_assert(str(alpha_focus_mark_clear.text).contains("Confirm clear"), "alpha focus clear button becomes a confirmation for improved issues")
					_assert(str(alpha_focus_mark_clear.tooltip_text).contains("Probe improved"), "alpha focus clear button explains improved issue confirmation")
				if alpha_focus_manual_status != null:
					_assert(str(alpha_focus_manual_status.text).contains("Clear candidate"), "alpha focus manual status labels improved issue as a clear candidate")
				var issue_review_log_text = m0_scene.debug_log.to_text_filtered("system", false)
				_assert(issue_review_log_text.contains("Human review marked ISSUE [Front confusion]"), "manual issue review records a tagged system log")
				_assert(issue_review_log_text.contains("Recommendation contrast: Alternate clearer"), "manual issue review records recommendation contrast log")
				_assert(issue_review_log_text.contains("Recommendation checks: Auto-pick, Alt hidden"), "manual issue review records recommendation checklist log")
				_assert(issue_review_log_text.contains("Human review summary: 0 clear, 1 issue, 15 remaining."), "manual issue review logs summary")
				_assert(issue_review_log_text.contains("Tags: Front confusion x1."), "manual issue review logs tag summary")
				_assert(issue_review_log_text.contains("Recommendation contrast: Alternate clearer x1."), "manual issue review logs recommendation contrast summary")
				_assert(issue_review_log_text.contains("Recommendation wording fix: Alternate clearer x1 -> soften recommendation wording"), "manual issue review logs recommendation wording fix")
				_assert(issue_review_log_text.contains("Recommendation wording priority: Auto-pick x1 -> soften directive tone"), "manual issue review logs recommendation wording priority")
				_assert(issue_review_log_text.contains("Recommendation wording checks: Auto-pick x1, Alt hidden x1."), "manual issue review logs recommendation wording checklist summary")
				_assert(issue_review_log_text.contains("Fix: Front confusion x1 -> check active-front highlights"), "manual issue review logs fix recommendation")
				_assert(issue_review_log_text.contains("Alpha fix lane opened: Guardian 1P @east. Front confusion x1 -> check active-front highlights"), "alpha coverage fix lane button logs opened fix lane")
				_assert(issue_review_log_text.contains("Alpha issue opened: Guardian 1P @east."), "alpha coverage issue button logs opened issue")
				_assert(issue_review_log_text.contains("Alpha recommendation wording fix opened: Guardian 1P @east. Alternate clearer x1 -> soften recommendation wording"), "alpha coverage recommendation fix button logs opened recommendation wording fix")
				var tagged_issue_result = m0_scene._alpha_focus_manual_review_result_for_entry(m0_scene._selected_alpha_focus_entry())
				_assert(str(tagged_issue_result.get("issue_tag_id", "")) == "front_confusion", "manual issue review stores issue tag id")
				_assert(str(tagged_issue_result.get("recommendation_contrast_id", "")) == "alternate_clearer", "manual issue review stores recommendation contrast id")
				var tagged_issue_checks: Array = tagged_issue_result.get("recommendation_fix_check_ids", [])
				_assert(tagged_issue_checks.has("auto_pick"), "manual issue review stores auto-pick recommendation check")
				_assert(tagged_issue_checks.has("alternate_hidden"), "manual issue review stores alternate hidden recommendation check")
				var issue_review_order: Array = m0_scene._alpha_focus_review_order()
				if not issue_review_order.is_empty():
					var first_issue_review: Dictionary = issue_review_order[0]
					_assert(int(first_issue_review.get("index", -1)) == m0_scene.selected_autoplay_focus_index, "manual issue review is prioritized first")
				m0_scene.alpha_focus_manual_review_results.clear()
				m0_scene._set_autoplay_focus_queue({
					"alpha_focus_queue": m0_scene.last_alpha_coverage_result.get("alpha_focus_queue", []),
					"next_action_queue": m0_scene.last_alpha_coverage_result.get("next_action_queue", []),
				})
				await process_frame
				if alpha_focus_body != null:
					_assert(str(alpha_focus_body.text).contains("Human Review: ISSUE [Front confusion]"), "manual issue reload restores issue tag")
					_assert(str(alpha_focus_body.text).contains("Rec: Alternate clearer"), "manual issue reload restores recommendation contrast")
					_assert(str(alpha_focus_body.text).contains("Rec checks: Auto-pick, Alt hidden"), "manual issue reload restores recommendation checklist")
					_assert(str(alpha_focus_body.text).contains("Recommendation Fix Detail: Alternate clearer -> soften recommendation wording"), "manual issue reload restores recommendation fix detail")
					_assert(str(alpha_focus_body.text).contains("Recommendation Fix Checks: Auto-pick, Alt hidden"), "manual issue reload restores recommendation fix checklist detail")
					_assert(str(alpha_focus_body.text).contains("Recommendation Rewrite Preset: Consider"), "manual issue reload restores recommendation rewrite preset")
				if alpha_coverage_body != null:
					_assert(str(alpha_coverage_body.text).contains("Issue cases: Guardian 1P @east [Front confusion]"), "manual issue reload restores tagged issue summary")
					_assert(str(alpha_coverage_body.text).contains("Issue tags: Front confusion x1"), "manual issue reload restores tag count summary")
					_assert(str(alpha_coverage_body.text).contains("Recommendation contrast: Alternate clearer x1"), "manual issue reload restores recommendation contrast summary")
					_assert(str(alpha_coverage_body.text).contains("Recommendation wording queue: 1 open"), "manual issue reload restores recommendation wording queue")
					_assert(str(alpha_coverage_body.text).contains("Recommendation wording fix: Alternate clearer x1 -> soften recommendation wording"), "manual issue reload restores recommendation wording fix")
					_assert(str(alpha_coverage_body.text).contains("Recommendation wording case: Guardian 1P @east [Front confusion]"), "manual issue reload restores recommendation wording case")
					_assert(str(alpha_coverage_body.text).contains("Recommendation wording priority: Auto-pick x1 -> soften directive tone"), "manual issue reload restores recommendation wording priority")
					_assert(str(alpha_coverage_body.text).contains("Recommendation wording checks: Auto-pick x1, Alt hidden x1"), "manual issue reload restores recommendation wording checklist summary")
					_assert(str(alpha_coverage_body.text).contains("Fix recommendation: Front confusion x1 -> check active-front highlights"), "manual issue reload restores fix recommendation")
					_assert(str(alpha_coverage_body.text).contains("Fix lane case: Guardian 1P @east [Front confusion]"), "manual issue reload restores fix lane case")
					_assert(str(alpha_coverage_body.text).contains("Fix lane probe: not run"), "manual issue reload resets transient fix lane probe status")
					_assert(str(alpha_coverage_body.text).contains("Fix lane priority: WATCH"), "manual issue reload resets transient fix lane priority")
			if alpha_focus_mark_clear != null:
				m0_scene._record_alpha_probe_result(m0_scene._selected_alpha_focus_entry(), 99, 999)
				m0_scene._refresh_alpha_focus_panel()
				m0_scene._refresh_alpha_coverage_panel()
				await process_frame
				_assert(str(alpha_focus_mark_clear.text).contains("Confirm clear"), "manual clear review requires confirmation for an improved issue")
				if alpha_recommendation_contrast != null:
					var follow_clearer_index = m0_scene._alpha_recommendation_contrast_index("follow_clearer")
					alpha_recommendation_contrast.select(follow_clearer_index)
					alpha_recommendation_contrast.item_selected.emit(follow_clearer_index)
				alpha_focus_mark_clear.pressed.emit()
				await process_frame
				if alpha_focus_title != null:
					_assert(str(alpha_focus_title.text).contains("CLEAR"), "manual clear review marks the focus title")
				if alpha_focus_body != null:
					_assert(str(alpha_focus_body.text).contains("Human Review: CLEAR"), "manual clear review marks the focus body")
					_assert(not str(alpha_focus_body.text).contains("Human Review: CLEAR [Front confusion]"), "manual clear review clears issue tag from body")
					_assert(str(alpha_focus_body.text).contains("Rec: Follow clearer"), "manual clear review body shows recommendation contrast result")
					_assert(not str(alpha_focus_body.text).contains("Rec checks:"), "manual clear review body clears recommendation checklist summary")
					_assert(not str(alpha_focus_body.text).contains("Recommendation Fix Detail:"), "manual clear review body does not show recommendation fix detail")
					_assert(not str(alpha_focus_body.text).contains("Recommendation Fix Checks:"), "manual clear review body does not show recommendation fix checklist detail")
					_assert(not str(alpha_focus_body.text).contains("Recommendation Rewrite Preset:"), "manual clear review body does not show recommendation rewrite preset")
				if alpha_focus_manual_status != null:
					_assert(str(alpha_focus_manual_status.text).contains("CLEAR"), "manual clear review updates the status label")
					_assert(str(alpha_focus_manual_status.text).contains("Rec: Follow clearer"), "manual clear review status shows recommendation contrast result")
					_assert(not str(alpha_focus_manual_status.text).contains("Rec checks:"), "manual clear review status clears recommendation checklist summary")
				_assert(str(alpha_focus_mark_clear.text).contains("Mark clear"), "manual clear review restores the standard clear button after confirmation")
				if alpha_coverage_body != null:
					var clear_coverage_text = str(alpha_coverage_body.text)
					_assert(clear_coverage_text.contains("Human review status: 1 clear / 0 issue / 15 remaining"), "alpha coverage summary counts manual clear")
					_assert(clear_coverage_text.contains("Review gaps:"), "alpha coverage summary keeps gap summary after manual clear")
					_assert(clear_coverage_text.contains("Priority spread: high 9 / medium 6 / low 0"), "alpha coverage summary removes manual clear from priority spread")
					_assert(clear_coverage_text.contains("Priority lane: Architect + north/east"), "alpha coverage summary keeps priority lane after manual clear")
					_assert(clear_coverage_text.contains("Fix queue: 0 open"), "alpha coverage summary clears open fix queue")
					_assert(clear_coverage_text.contains("Recommendation contrast: Follow clearer x1"), "alpha coverage summary counts clear recommendation contrast")
					_assert(not clear_coverage_text.contains("Recommendation wording fix:"), "alpha coverage summary does not flag clear recommendation wording")
					_assert(not clear_coverage_text.contains("Recommendation wording priority:"), "alpha coverage summary clears recommendation wording priority")
					_assert(not clear_coverage_text.contains("Recommendation wording checks:"), "alpha coverage summary clears recommendation wording checklist")
					_assert(clear_coverage_text.contains("Next priority: Architect 2P @north"), "alpha coverage summary keeps next priority after manual clear")
					_assert(clear_coverage_text.contains("Next manual: Architect 2P @north"), "alpha coverage summary lists next manual case")
				if alpha_coverage_open_issue != null:
					_assert(alpha_coverage_open_issue.disabled, "alpha coverage issue button disables after issue is cleared")
				if alpha_coverage_open_fix_lane != null:
					_assert(alpha_coverage_open_fix_lane.disabled, "alpha coverage fix lane button disables after issue is cleared")
				if alpha_coverage_open_recommendation_fix != null:
					_assert(alpha_coverage_open_recommendation_fix.disabled, "alpha coverage recommendation fix button disables after clear follow result")
				if alpha_recommendation_auto_pick != null:
					_assert(alpha_recommendation_auto_pick.disabled, "recommendation fix auto-pick check disables after clear follow result")
				if alpha_coverage_probe_fix_lane != null:
					_assert(alpha_coverage_probe_fix_lane.disabled, "alpha coverage fix lane probe button disables after issue is cleared")
				if alpha_coverage_open_next_manual != null:
					_assert(not alpha_coverage_open_next_manual.disabled, "alpha coverage next manual button stays enabled while remaining cases exist")
					_assert(str(alpha_coverage_open_next_manual.text).contains("Open priority"), "alpha coverage next manual button keeps priority wording")
					_assert(str(alpha_coverage_open_next_manual.tooltip_text).contains("Architect 2P @north"), "alpha coverage next manual button keeps priority target")
					alpha_coverage_open_next_manual.pressed.emit()
					await process_frame
					if alpha_focus_title != null:
						_assert(str(alpha_focus_title.text).contains("Architect 2P"), "alpha coverage next manual button opens the next unreviewed case")
				var clear_review_log_text = m0_scene.debug_log.to_text_filtered("system", false)
				_assert(clear_review_log_text.contains("Clear candidate confirmed: Guardian 1P @east."), "manual clear review logs clear candidate confirmation")
				_assert(clear_review_log_text.contains("Recommendation contrast: Follow clearer x1."), "manual clear review logs clear recommendation contrast summary")
				_assert(clear_review_log_text.contains("Alpha next manual opened: Architect 2P @north."), "alpha coverage next manual button logs opened case")
				_assert(clear_review_log_text.contains("Human review saved: user://m0_alpha_manual_reviews.json"), "manual clear review saves to user storage")
				_assert(m0_scene.alpha_focus_manual_review_results.size() == 1, "manual clear review has one in-memory saved case")
				m0_scene.alpha_focus_manual_review_results.clear()
				m0_scene._set_autoplay_focus_queue({
					"alpha_focus_queue": m0_scene.last_alpha_coverage_result.get("alpha_focus_queue", []),
					"next_action_queue": m0_scene.last_alpha_coverage_result.get("next_action_queue", []),
				})
				await process_frame
				if alpha_focus_title != null:
					_assert(str(alpha_focus_title.text).contains("CLEAR"), "manual review reload restores clear title")
				if alpha_coverage_body != null:
					var reloaded_coverage_text = str(alpha_coverage_body.text)
					_assert(reloaded_coverage_text.contains("Human review status: 1 clear / 0 issue / 15 remaining"), "manual review reload restores coverage summary")
					_assert(reloaded_coverage_text.contains("Recommendation contrast: Follow clearer x1"), "manual review reload restores clear recommendation contrast")
					_assert(not reloaded_coverage_text.contains("Recommendation wording fix:"), "manual review reload does not add recommendation wording fix for clear follow result")
					_assert(not reloaded_coverage_text.contains("Recommendation wording priority:"), "manual review reload does not add recommendation wording priority for clear follow result")
					_assert(not reloaded_coverage_text.contains("Recommendation wording checks:"), "manual review reload does not add recommendation wording checklist for clear follow result")
				var restore_log_text = m0_scene.debug_log.to_text_filtered("system", false)
				_assert(restore_log_text.contains("Human review restored: 1 saved cases."), "manual review reload records restore log")
				var reset_saved_review_result: Dictionary = m0_scene._debug_clear_alpha_manual_review_save()
				_assert(bool(reset_saved_review_result.get("ok", false)), "alpha manual review save is cleaned after persistence test")
				await process_frame
		m0_scene._set_autoplay_focus_queue({
			"alpha_focus_queue": [
				{
					"rank": 1,
					"class_id": "guardian",
					"class_label": "Guardian",
					"player_count": 1,
					"direction": "east",
					"primary_signal": "low base margin",
					"evidence": "HP 64 with 3 base hits",
					"next_probe": "watch first contact",
					"completed_rounds": 2,
					"base_hp": 64,
					"analysis_cards": [
						{"title": "Result", "body": "Guardian 1P reached R2 with HP 64."},
						{"title": "Cause", "body": "low base margin."},
						{"title": "Next Probe", "body": "watch first contact"},
					],
				},
				{
					"rank": 2,
					"class_id": "architect",
					"class_label": "Architect",
					"player_count": 2,
					"direction": "north",
					"primary_signal": "structure churn",
					"evidence": "4 structures destroyed",
					"next_probe": "split throwaway barricades",
					"completed_rounds": 2,
					"base_hp": 80,
					"analysis_cards": [
						{"title": "Result", "body": "Architect 2P reached R2 with HP 80."},
						{"title": "Cause", "body": "structure churn."},
						{"title": "Next Probe", "body": "split throwaway barricades"},
					],
				},
			],
			"next_action_queue": [
				{
					"rank": 1,
					"severity": "danger",
					"signal": "low base margin",
					"hypothesis": "Guardian 1P@east may reveal low base margin during a human replay.",
					"check": "watch first contact",
					"metric": "HP 64 with 3 base hits",
					"source": "alpha_focus_queue",
					"document": "docs/PLAYTEST_AND_BALANCE.md",
					"class_id": "guardian",
					"class_label": "Guardian",
					"player_count": 1,
					"direction": "east",
				},
				{
					"rank": 2,
					"severity": "watch",
					"signal": "structure churn",
					"hypothesis": "Architect 2P@north may reveal structure churn during a human replay.",
					"check": "split throwaway barricades",
					"metric": "4 structures destroyed",
					"source": "alpha_focus_queue",
					"document": "docs/PLAYTEST_AND_BALANCE.md",
					"class_id": "architect",
					"class_label": "Architect",
					"player_count": 2,
					"direction": "north",
				},
			],
			"recommendation_contrast_samples": [
				{
					"class_id": "guardian",
					"class_label": "Guardian",
					"player_count": 1,
					"round": 2,
					"choice_type": "card",
					"followed_recommendation": true,
					"chosen_label": "Arc Spark",
					"recommended_label": "Arc Spark",
					"alternate_label": "take gold or another offered card",
					"recommendation_reason": "fills opening damage",
					"recommendation_detail": "Deck: 12 cards | Gold: 48",
					"prompt": "Run A: Arc Spark. Run B: take gold or another offered card. Check whether this stays a table discussion, not an auto-pick.",
				},
				{
					"class_id": "guardian",
					"class_label": "Guardian",
					"player_count": 1,
					"round": 2,
					"choice_type": "shop",
					"followed_recommendation": true,
					"chosen_label": "remove Tower Permit",
					"recommended_label": "Tower Permit",
					"alternate_label": "save gold or remove another offered card",
					"recommendation_reason": "trims duplicate setup",
					"recommendation_detail": "Deck: 14 cards | Gold: 55",
					"prompt": "Run A: remove Tower Permit. Run B: save gold or remove another offered card. Check whether this stays a table discussion, not an auto-pick.",
				},
			],
		})
		await process_frame
		if alpha_focus_panel != null:
			_assert(alpha_focus_panel.visible, "alpha focus panel is visible after autoplay report")
		if m0_scene.map_view != null:
			_assert(m0_scene.map_view.alpha_focus_direction == "east", "map highlights first alpha focus direction")
			_assert(m0_scene.map_view.debug_alpha_focus_label("east") == "F", "map focus badge labels selected direction")
			var first_focus_marker: Dictionary = m0_scene._alpha_focus_setup_marker()
			_assert(not first_focus_marker.is_empty(), "alpha focus queue exposes first setup marker")
			if not first_focus_marker.is_empty():
				var first_focus_tile: Vector2i = first_focus_marker.get("tile", Vector2i.ZERO)
				_assert(m0_scene.map_view.debug_alpha_focus_setup_label(first_focus_tile) == "F", "map labels the first focus setup tile")
		if alpha_focus_title != null:
			_assert(str(alpha_focus_title.text).contains("Guardian 1P"), "alpha focus panel shows first queued case")
		if alpha_focus_body != null:
			_assert(str(alpha_focus_body.text).contains("Result:"), "alpha focus panel shows analysis cards")
			_assert(str(alpha_focus_body.text).contains("Next Probe:"), "alpha focus panel shows next probe card")
			_assert(str(alpha_focus_body.text).contains("Recommendation Contrast Sample:"), "alpha focus panel shows autoplay recommendation contrast sample")
			_assert(str(alpha_focus_body.text).contains("Run A: Arc Spark"), "alpha focus panel shows autoplay recommendation follow branch")
			_assert(str(alpha_focus_body.text).contains("Run B: take gold"), "alpha focus panel shows autoplay recommendation alternate branch")
			_assert(str(alpha_focus_body.text).contains("fills opening damage"), "alpha focus panel shows autoplay recommendation reason")
			_assert(str(alpha_focus_body.text).contains("Review Priority: UNTESTED"), "alpha focus body marks untested focus priority")
			_assert(str(alpha_focus_body.text).contains("Action Queue #1"), "alpha focus body shows matched next action")
			_assert(str(alpha_focus_body.text).contains("Metric: HP 64"), "alpha focus body shows next action metric")
		if alpha_contrast_status != null:
			_assert(str(alpha_contrast_status.text).contains("1/2"), "alpha contrast status starts on the first sample")
		if alpha_contrast_next != null:
			_assert(not alpha_contrast_next.disabled, "alpha contrast next button enables when multiple samples exist")
			alpha_contrast_next.pressed.emit()
			await process_frame
			if alpha_focus_body != null:
				_assert(str(alpha_focus_body.text).contains("Run A: remove Tower Permit"), "alpha contrast next shows the next recommendation sample")
				_assert(str(alpha_focus_body.text).contains("trims duplicate setup"), "alpha contrast next shows the next recommendation reason")
			if alpha_contrast_status != null:
				_assert(str(alpha_contrast_status.text).contains("2/2"), "alpha contrast status advances to the second sample")
		if alpha_contrast_prev != null:
			_assert(not alpha_contrast_prev.disabled, "alpha contrast previous button enables when multiple samples exist")
			alpha_contrast_prev.pressed.emit()
			await process_frame
			if alpha_focus_body != null:
				_assert(str(alpha_focus_body.text).contains("Run A: Arc Spark"), "alpha contrast previous returns to the first recommendation sample")
		if alpha_focus_action != null:
			_assert(not alpha_focus_action.disabled, "alpha focus action button enables for matched next action")
			_assert(str(alpha_focus_action.tooltip_text).contains("watch first contact"), "alpha focus action button previews the next action check")
			alpha_focus_action.pressed.emit()
			await process_frame
			_assert(not m0_scene.run_started, "alpha focus action setup does not begin a run")
			_assert(m0_scene.player_count == 1, "alpha focus action setup applies queued player count")
			_assert(m0_scene.selected_class_id == "guardian", "alpha focus action setup applies queued class")
			_assert(m0_scene.build_mode == "tower", "alpha focus action setup previews the first defense structure")
			_assert(m0_scene._is_valid_tile(m0_scene.preview_tile), "alpha focus action setup selects a preview tile")
			_assert(m0_scene.selected_tile == m0_scene.preview_tile, "alpha focus action setup selects the preview tile for inspection")
			_assert(str(m0_scene.preview_label.text).contains("action setup recommends"), "alpha focus action setup explains the setup preview")
			if m0_scene.map_view != null:
				_assert(m0_scene.map_view.preview_tile == m0_scene.preview_tile, "map receives the next action setup preview tile")
			var next_action_log_text = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(next_action_log_text.contains("Next action setup applied"), "alpha focus action setup records a system log")
			_assert(next_action_log_text.contains("Preview:"), "alpha focus action setup log records the first setup preview")
		if alpha_focus_probe_status != null:
			_assert(str(alpha_focus_probe_status.text).contains("start a probe"), "alpha focus probe compare prompts replay")
		if alpha_focus_next != null:
			alpha_focus_next.pressed.emit()
			await process_frame
			if alpha_focus_title != null:
				_assert(str(alpha_focus_title.text).contains("Architect 2P"), "alpha focus next button advances focus case")
			if alpha_focus_body != null:
				_assert(str(alpha_focus_body.text).contains("Action Queue #2"), "alpha focus next button shows the matched next action")
				_assert(str(alpha_focus_body.text).contains("split throwaway barricades"), "alpha focus next action shows its check")
			if alpha_focus_action != null:
				_assert(not alpha_focus_action.disabled, "alpha focus action button stays enabled for next matched action")
				_assert(str(alpha_focus_action.tooltip_text).contains("split throwaway barricades"), "alpha focus action button updates to the next matched action")
			if m0_scene.map_view != null:
				_assert(m0_scene.map_view.alpha_focus_direction == "north", "map follows alpha focus next selection")
				var next_focus_marker: Dictionary = m0_scene._alpha_focus_setup_marker()
				_assert(not next_focus_marker.is_empty(), "alpha focus next case exposes setup marker")
				if not next_focus_marker.is_empty():
					var next_focus_tile: Vector2i = next_focus_marker.get("tile", Vector2i.ZERO)
					_assert(m0_scene.map_view.debug_alpha_focus_setup_label(next_focus_tile) == "F", "map follows alpha focus setup marker after next")
		if alpha_focus_apply != null:
			alpha_focus_apply.pressed.emit()
			await process_frame
			_assert(m0_scene.player_count == 2, "alpha focus setup applies queued player count")
			_assert(m0_scene.selected_class_id == "architect", "alpha focus setup applies queued class")
			_assert(m0_scene.build_mode == "barricade", "alpha focus setup previews the class opening structure")
			_assert(m0_scene._is_valid_tile(m0_scene.preview_tile), "alpha focus setup selects the first setup tile")
			_assert(m0_scene.selected_tile == m0_scene.preview_tile, "alpha focus setup selects the setup tile for inspection")
			_assert(str(m0_scene.preview_label.text).contains("action setup recommends"), "alpha focus setup explains the setup preview")
			if m0_scene.map_view != null:
				_assert(m0_scene.map_view.preview_tile == m0_scene.preview_tile, "map receives the alpha focus setup preview tile")
		if alpha_focus_prev != null:
			alpha_focus_prev.pressed.emit()
			await process_frame
			_assert(m0_scene.build_mode == "none", "alpha focus navigation clears stale setup preview")
		if alpha_focus_apply != null:
			alpha_focus_apply.pressed.emit()
			await process_frame
			_assert(m0_scene.player_count == 1, "alpha focus setup can restore first queued player count")
			_assert(m0_scene.selected_class_id == "guardian", "alpha focus setup can restore first queued class")
			_assert(m0_scene.build_mode == "tower", "alpha focus restored setup previews the first class structure")
			_assert(m0_scene._is_valid_tile(m0_scene.preview_tile), "alpha focus restored setup selects the first setup tile")
			if m0_scene.map_view != null:
				_assert(m0_scene.map_view.alpha_focus_direction == "east", "map returns to restored alpha focus direction")
				var restored_focus_marker: Dictionary = m0_scene._alpha_focus_setup_marker()
				_assert(not restored_focus_marker.is_empty(), "alpha focus restored case exposes setup marker")
				if not restored_focus_marker.is_empty():
					var restored_focus_tile: Vector2i = restored_focus_marker.get("tile", Vector2i.ZERO)
					_assert(m0_scene.map_view.debug_alpha_focus_setup_label(restored_focus_tile) == "F", "map returns to restored alpha focus setup marker")
		if alpha_focus_probe != null:
			alpha_focus_probe.pressed.emit()
			await process_frame
			_assert(m0_scene.run_started, "alpha focus probe begins a replay run")
			_assert(m0_scene.player_count == 1, "alpha focus probe keeps selected player count")
			_assert(m0_scene.selected_class_id == "guardian", "alpha focus probe keeps selected class")
			_assert(not m0_scene.simulation.wave_active, "alpha focus probe finishes the opening wave")
			_assert(m0_scene.simulation.get_completed_rounds() >= 1, "alpha focus probe records the first completed wave")
			_assert(m0_scene.simulation.has_pending_reward(), "alpha focus probe stops at the reward decision")
			_assert(alpha_focus_probe.disabled, "alpha focus probe locks after run begins")
			if alpha_focus_apply != null:
				_assert(alpha_focus_apply.disabled, "alpha focus setup locks after probe begins")
			if alpha_focus_probe_status != null:
				var probe_text = str(alpha_focus_probe_status.text)
				_assert(probe_text.contains("Probe compare"), "alpha focus probe shows compare status")
				_assert(probe_text.contains("R1/2"), "alpha focus probe compare shows first wave progress")
				_assert(probe_text.contains("Probe boss response: none recorded yet"), "alpha focus probe shows no boss response yet")
			if alpha_focus_body != null:
				var probe_body_text = str(alpha_focus_body.text)
				_assert(probe_body_text.contains("Coverage Signals:"), "alpha focus body shows coverage signal summary")
				_assert(probe_body_text.contains("taunt_applied"), "alpha focus body shows the guardian taunt coverage signal")
				_assert(probe_body_text.contains("Boss Response: none recorded yet"), "alpha focus body shows no boss response yet")
			var guardian_probe_result = m0_scene._alpha_focus_probe_result_for_entry(m0_scene.active_alpha_probe_entry)
			var guardian_signal_report: Dictionary = guardian_probe_result.get("signal_report", {})
			var guardian_required_signals: Array = guardian_signal_report.get("required_signals", [])
			var guardian_observed_signals: Array = guardian_signal_report.get("observed_signals", [])
			_assert(guardian_required_signals.has("taunt_applied"), "alpha focus probe stores required guardian coverage signals")
			_assert(guardian_observed_signals.has("taunt_applied"), "alpha focus probe stores observed guardian taunt signal")
			var probe_system_log_text = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(probe_system_log_text.contains("Alpha focus probe result"), "alpha focus probe logs the first wave result")
			_assert(probe_system_log_text.contains("placed"), "alpha focus probe result includes opening setup count")
			_assert(probe_system_log_text.contains("Coverage Signals:"), "alpha focus probe result log includes coverage signal summary")
			m0_scene.last_boss_warning_response_line = "Boss warning response: Arc Spark -> Boss answer at (20, 10). Legs opens Front. break Legs to open Front before the gaze repeats"
			m0_scene._refresh_alpha_focus_panel()
			await process_frame
			if alpha_focus_probe_status != null:
				_assert(str(alpha_focus_probe_status.text).contains("Boss answer"), "alpha focus probe shows recent boss response")
			if alpha_focus_body != null:
				_assert(str(alpha_focus_body.text).contains("Boss Response: Arc Spark -> Boss answer"), "alpha focus body shows recent boss response")
			m0_scene.last_boss_warning_response_line = ""
			m0_scene._refresh_alpha_focus_panel()
			await process_frame
			if alpha_focus_title != null:
				_assert(str(alpha_focus_title.text).contains("PROBING"), "alpha focus title marks active probe")
			if alpha_focus_body != null:
				_assert(str(alpha_focus_body.text).contains("Probe Result:"), "alpha focus body shows probe result line")
				_assert(str(alpha_focus_body.text).contains("Review Priority: PROBING"), "alpha focus body marks active probe priority")
			var finished_compare = m0_scene._format_alpha_probe_completed_status({
				"class_label": "Guardian",
				"player_count": 1,
				"direction": "east",
				"completed_rounds": 1,
				"base_hp": 24,
			}, 1, 27)
			_assert(finished_compare.contains("+3"), "alpha focus completed compare shows positive delta")
			_assert(finished_compare.contains("better"), "alpha focus completed compare labels improvement")
			m0_scene._record_alpha_probe_result(m0_scene.active_alpha_probe_entry, 2, 67)
			m0_scene._refresh_alpha_focus_panel()
			await process_frame
			if alpha_focus_title != null:
				_assert(str(alpha_focus_title.text).contains("BETTER"), "alpha focus title marks improved probe result")
			if alpha_focus_body != null:
				var improved_body = str(alpha_focus_body.text)
				_assert(improved_body.contains("Probe Result: BETTER"), "alpha focus body labels improved probe result")
				_assert(improved_body.contains("Review Priority: BETTER"), "alpha focus body updates review priority after improvement")
				_assert(improved_body.contains("+3"), "alpha focus body includes probe delta")
			var review_order: Array = m0_scene._alpha_focus_review_order()
			if not review_order.is_empty():
				var first_review: Dictionary = review_order[0]
				_assert(int(first_review.get("index", -1)) == 1, "alpha focus review order promotes untested cases above improved cases")
			if alpha_focus_next != null:
				alpha_focus_next.pressed.emit()
				await process_frame
				if alpha_focus_title != null:
					_assert(str(alpha_focus_title.text).contains("Architect 2P"), "alpha focus next follows review priority order")
			_assert(m0_scene._probe_result_status(0) == "recheck", "alpha focus unchanged probe is marked for recheck")
		if alpha_coverage_probe_fix_lane != null:
			m0_scene._on_reset_pressed()
			await process_frame
			var clear_pin_review_result: Dictionary = m0_scene._debug_clear_alpha_manual_review_save()
			_assert(bool(clear_pin_review_result.get("ok", false)), "alpha fix lane pin test starts with clean save")
			await process_frame
			m0_scene._set_autoplay_focus_queue({
				"alpha_focus_queue": [
					{
						"rank": 1,
						"class_id": "guardian",
						"class_label": "Guardian",
						"player_count": 1,
						"direction": "east",
						"primary_signal": "low base margin",
						"evidence": "HP 64 with 3 base hits",
						"next_probe": "watch first contact",
						"completed_rounds": 2,
						"base_hp": 64,
					},
					{
						"rank": 2,
						"class_id": "architect",
						"class_label": "Architect",
						"player_count": 2,
						"direction": "north",
						"primary_signal": "structure churn",
						"evidence": "4 structures destroyed",
						"next_probe": "split throwaway barricades",
						"completed_rounds": 2,
						"base_hp": 80,
					},
				],
				"next_action_queue": [],
			})
			m0_scene.last_alpha_coverage_result = {
				"ok": true,
				"aggregate": {
					"case_count": 2,
					"pass_count": 2,
					"required_signal_count": 0,
					"observed_signal_count": 0,
				},
				"human_review_queue": m0_scene.last_autoplay_focus_queue.duplicate(true),
				"summary_lines": [],
			}
			m0_scene._refresh_screen()
			await process_frame
			if alpha_issue_tag != null:
				var pin_tag_index = m0_scene._alpha_issue_tag_index("front_confusion")
				alpha_issue_tag.select(pin_tag_index)
				alpha_issue_tag.item_selected.emit(pin_tag_index)
			if alpha_focus_mark_issue != null:
				alpha_focus_mark_issue.pressed.emit()
				await process_frame
				m0_scene.selected_autoplay_focus_index = 1
				m0_scene._refresh_screen()
				await process_frame
				if alpha_issue_tag != null:
					alpha_issue_tag.select(m0_scene._alpha_issue_tag_index("front_confusion"))
					alpha_issue_tag.item_selected.emit(m0_scene._alpha_issue_tag_index("front_confusion"))
				alpha_focus_mark_issue.pressed.emit()
				await process_frame
			var pinned_entry: Dictionary = m0_scene.last_autoplay_focus_queue[1]
			m0_scene._record_alpha_probe_result(pinned_entry, 2, 80)
			m0_scene._refresh_screen()
			await process_frame
			if alpha_coverage_body != null:
				var pinned_fix_lane_text = str(alpha_coverage_body.text)
				_assert(pinned_fix_lane_text.contains("Issue tags: Front confusion x2"), "alpha coverage summary counts two same-tag issues")
				_assert(pinned_fix_lane_text.contains("Fix lane case: Architect 2P @north [Front confusion]"), "alpha coverage summary pins recheck fix lane case")
				_assert(pinned_fix_lane_text.contains("Fix lane probe: RECHECK"), "alpha coverage summary shows pinned recheck status")
				_assert(pinned_fix_lane_text.contains("Fix lane priority: PINNED - RECHECK"), "alpha coverage summary marks recheck fix lane as pinned")
			var pinned_review_order: Array = m0_scene._alpha_focus_review_order()
			if not pinned_review_order.is_empty():
				var pinned_first_review: Dictionary = pinned_review_order[0]
				_assert(int(pinned_first_review.get("index", -1)) == 1, "alpha focus review order pins recheck issue first")
			if alpha_coverage_open_fix_lane != null:
				alpha_coverage_open_fix_lane.pressed.emit()
				await process_frame
				if alpha_focus_title != null:
					_assert(str(alpha_focus_title.text).contains("Architect 2P"), "open fix lane jumps to pinned recheck case")
			var clean_pin_review_result: Dictionary = m0_scene._debug_clear_alpha_manual_review_save()
			_assert(bool(clean_pin_review_result.get("ok", false)), "alpha fix lane pin test cleans saved reviews")
			m0_scene._on_reset_pressed()
			await process_frame
			m0_scene._set_autoplay_focus_queue({
				"alpha_focus_queue": [
					{
						"rank": 1,
						"class_id": "guardian",
						"class_label": "Guardian",
						"player_count": 1,
						"direction": "east",
						"primary_signal": "low base margin",
						"evidence": "HP 64 with 3 base hits",
						"next_probe": "watch first contact",
						"completed_rounds": 2,
						"base_hp": 64,
					},
				],
				"next_action_queue": [],
			})
			await process_frame
			if alpha_issue_tag != null:
				var fix_probe_tag_index = m0_scene._alpha_issue_tag_index("front_confusion")
				alpha_issue_tag.select(fix_probe_tag_index)
				alpha_issue_tag.item_selected.emit(fix_probe_tag_index)
			if alpha_focus_mark_issue != null:
				alpha_focus_mark_issue.pressed.emit()
				await process_frame
			_assert(not alpha_coverage_probe_fix_lane.disabled, "alpha fix lane probe enables after tagged issue")
			alpha_coverage_probe_fix_lane.pressed.emit()
			await process_frame
			_assert(m0_scene.run_started, "alpha fix lane probe begins a replay run")
			_assert(m0_scene.player_count == 1, "alpha fix lane probe applies the issue player count")
			_assert(m0_scene.selected_class_id == "guardian", "alpha fix lane probe applies the issue class")
			_assert(not m0_scene.simulation.wave_active, "alpha fix lane probe finishes the opening wave")
			_assert(m0_scene.simulation.get_completed_rounds() >= 1, "alpha fix lane probe records the first completed wave")
			_assert(alpha_coverage_probe_fix_lane.disabled, "alpha fix lane probe locks after run begins")
			_assert(str(alpha_coverage_probe_fix_lane.text).contains("Reset first"), "alpha fix lane probe asks for reset after run begins")
			var fix_lane_probe_log_text = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(fix_lane_probe_log_text.contains("Alpha fix lane probe result"), "alpha fix lane probe records result log")
			_assert(fix_lane_probe_log_text.contains("Alpha fix lane probe result (Front confusion x1"), "alpha fix lane probe result records recommendation context")
			var clear_fix_probe_review_result: Dictionary = m0_scene._debug_clear_alpha_manual_review_save()
			_assert(bool(clear_fix_probe_review_result.get("ok", false)), "alpha fix lane probe save is cleaned after test")
			m0_scene._on_reset_pressed()
			await process_frame
		m0_scene.debug_log.clear()
		m0_scene.debug_log.push(focus_text, "system")
		m0_scene._refresh_log()
		await process_frame
		var important_focus_text = str(activity_log_label.text)
		_assert(important_focus_text.contains("Alpha focus"), "activity log important filter keeps alpha focus entries")
		m0_scene.show_important_logs_only = false
		m0_scene._refresh_log()
		if alpha_focus_action != null:
			m0_scene._on_reset_pressed()
			await process_frame
			m0_scene._set_autoplay_focus_queue({
				"alpha_focus_queue": [
					{
						"rank": 1,
						"class_id": "guardian",
						"class_label": "Guardian",
						"player_count": 1,
						"direction": "east",
						"primary_signal": "low base margin",
						"evidence": "HP 64 with 3 base hits",
						"next_probe": "watch first contact",
						"completed_rounds": 2,
						"base_hp": 64,
					},
				],
				"next_action_queue": [
					{
						"rank": 1,
						"severity": "danger",
						"signal": "low base margin",
						"hypothesis": "Guardian 1P@east may reveal low base margin during a human replay.",
						"check": "watch first contact",
						"metric": "HP 64 with 3 base hits",
						"source": "alpha_focus_queue",
						"document": "docs/PLAYTEST_AND_BALANCE.md",
						"class_id": "guardian",
						"class_label": "Guardian",
						"player_count": 1,
						"direction": "east",
					},
				],
			})
			await process_frame
			alpha_focus_action.pressed.emit()
			await process_frame
			var action_preview_before_begin = m0_scene.preview_tile
			_assert(m0_scene._is_valid_tile(action_preview_before_begin), "alpha focus action has a setup preview before begin run")
			m0_scene._on_begin_run_pressed()
			await process_frame
			_assert(m0_scene.run_started, "begin run starts after alpha action setup")
			_assert(m0_scene.build_mode == "tower", "begin run restores the action setup structure preview")
			_assert(m0_scene._is_valid_tile(m0_scene.preview_tile), "begin run restores the action setup preview tile")
			_assert(m0_scene.selected_tile == m0_scene.preview_tile, "begin run keeps the restored preview tile selected")
			_assert(str(m0_scene.preview_label.text).contains("can be placed"), "begin run shows the restored setup preview")
			var restored_action_preview_tile = m0_scene.preview_tile
			_assert(str(setup_plan_button.text).contains(m0_scene._tile_text(restored_action_preview_tile)), "setup plan button names the restored action preview tile")
			if m0_scene.map_view != null:
				_assert(m0_scene.map_view.preview_tile == m0_scene.preview_tile, "map keeps the restored action setup preview tile")
			setup_plan_button.pressed.emit()
			await process_frame
			_assert(m0_scene.simulation.get_structure_tiles().has(m0_scene._tile_key(restored_action_preview_tile)), "setup plan places the restored action preview tile")
			var restored_preview_log_text = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(restored_preview_log_text.contains("Action setup preview restored"), "begin run records restored action setup preview")
			m0_scene._on_reset_pressed()
			await process_frame
	if m0_scene != null:
		m0_scene._on_begin_run_pressed()
		await process_frame
		var locked_run_snapshot: Dictionary = m0_scene.run_config_lock_snapshot
		_assert(not locked_run_snapshot.is_empty(), "begin run creates a run config lock snapshot")
		_assert(int(locked_run_snapshot.get("playerCountAtStart", 0)) == 1, "run config lock stores player count at start")
		_assert(locked_run_snapshot.get("activeDirections", []) == ["east"], "run config lock stores active directions")
		_assert(str(locked_run_snapshot.get("scalingProfileId", "")).contains("1p"), "run config lock stores scaling profile")
		_assert(locked_run_snapshot.get("immutableFields", []).has("activeDirections"), "run config lock marks active directions immutable")
		var run_lock_log_text = m0_scene.debug_log.to_text_filtered("system", false)
		_assert(run_lock_log_text.contains("run_state_locked:"), "begin run records run_state_locked trace")
		_assert(run_lock_log_text.contains("playerCountAtStart=1"), "run_state_locked trace records locked player count")
		_assert(run_lock_log_text.contains("activeDirections=east"), "run_state_locked trace records locked directions")
		var unlocked_player_count = m0_scene.player_count
		m0_scene.player_count = 4
		m0_scene._refresh_screen()
		await process_frame
		if m0_scene.status_label != null:
			var locked_status_text = str(m0_scene.status_label.text)
			_assert(locked_status_text.contains("Players: 1"), "run HUD keeps locked player count after setup mutation")
			_assert(locked_status_text.contains("Active directions: east"), "run HUD keeps locked active directions after setup mutation")
		if m0_scene.map_view != null:
			_assert(m0_scene.map_view.active_directions == ["east"], "map keeps locked active directions after setup mutation")
		m0_scene.player_count = unlocked_player_count
		m0_scene._refresh_screen()
		await process_frame
		if resource_label != null:
			var hand_plan_text = str(resource_label.text)
			_assert(hand_plan_text.contains("Hand plan:"), "resource status shows hand plan summary after run start")
			_assert(hand_plan_text.contains("Class effects:"), "resource status shows class effect summary after run start")
			_assert(hand_plan_text.contains("Hand pressure:"), "resource status shows hand pressure summary after run start")
			_assert(hand_plan_text.contains("Economy:"), "resource status shows economy summary after run start")
			_assert(hand_plan_text.contains("shop trim gold"), "resource status connects gold to shop trim")
			_assert(hand_plan_text.contains("ready"), "hand plan counts ready hand cards")
			_assert(hand_plan_text.contains("best"), "hand plan names the recommended hand action")
		if stack_risk_label != null:
			var pull_check_text = str(stack_risk_label.text)
			_assert(pull_check_text.contains("Pull check:"), "stack risk label shows pull decision summary after run start")
			_assert(pull_check_text.contains("Watch:"), "stack risk label shows pull watch labels")
			_assert(pull_check_text.contains("Pull tempo:"), "stack risk label shows pull tempo guidance after run start")
			_assert(pull_check_text.contains("start the current wave"), "pull tempo asks to start the current wave before pulling")
			_assert(pull_check_text.contains("No bonus rewards"), "stack risk label rejects bonus reward copy")
		if call_next_button != null:
			var pull_setup_tooltip = str(call_next_button.tooltip_text)
			_assert(pull_setup_tooltip.contains("Pull tempo:"), "pull button tooltip shows pull tempo guidance after run start")
			_assert(pull_setup_tooltip.contains("start the current wave"), "pull button tooltip explains inactive-wave pull timing")
		if action_status_label != null:
			_assert(str(action_status_label.text).contains("Start wave=Ready"), "action status shows start wave readiness")
			_assert(str(action_status_label.text).contains("Step=Wave not active"), "action status shows inactive step state")
		if wave_readiness_label != null:
			var ready_text = str(wave_readiness_label.text)
			_assert(ready_text.contains("ready for R1"), "wave readiness reports ready round")
			_assert(ready_text.contains("Front check:"), "wave readiness reports front check")
			_assert(ready_text.contains("Maintenance: clear"), "wave readiness shows maintenance clear state")
			_assert(ready_text.contains("shop trim gold"), "wave readiness shows maintenance economy context")
			_assert(ready_text.contains("Front detail:"), "wave readiness shows per-front detail")
			_assert(ready_text.contains("east GAP"), "wave readiness marks uncovered active front")
			_assert(ready_text.contains("Wave plan: R1 Route Read"), "wave readiness shows the scheduled wave plan")
			_assert(ready_text.contains("Spawn timing R1"), "wave readiness shows spawn timing")
			_assert(ready_text.contains("Spawn response:"), "wave readiness shows the next spawn response")
			_assert(ready_text.contains("next east Walker"), "wave readiness response names the next active spawn")
			_assert(ready_text.contains("shown route"), "wave readiness includes the wave intent question")
			_assert(ready_text.contains("cover east"), "wave readiness suggests covering the weakest front before starting")
		if tactical_hint_label != null:
			var tactical_text = str(tactical_hint_label.text)
			_assert(tactical_text.contains("Tactics: idle"), "wave tactical hint idles before wave start")
			_assert(tactical_text.contains("Wave plan: R1 Route Read"), "wave tactical hint shows the scheduled wave plan")
			_assert(tactical_text.contains("Spawn timing R1"), "wave tactical hint shows spawn timing before wave start")
			_assert(tactical_text.contains("Spawn response:"), "wave tactical hint shows the next spawn response")
			_assert(tactical_text.contains("next east Walker"), "wave tactical hint response names the next active spawn")
		if use_best_target_button != null:
			var opening_best_report = m0_scene._best_target_action_report()
			_assert(bool(opening_best_report.get("ok", false)), "best target suggests an opening hand action before manual card selection")
			_assert(str(opening_best_report.get("intent", "")) == "card", "opening best target is a hand card action")
			_assert(int(opening_best_report.get("card_index", -1)) >= 0, "opening best target records the hand card index")
			_assert(str(opening_best_report.get("summary", "")).contains("Spawn answer"), "opening best target explains the spawn response match")
			_assert(not use_best_target_button.disabled, "use best target button enables for opening hand recommendation")
			_assert(str(use_best_target_button.text).contains("Use"), "use best target button previews opening hand action")
			_assert(str(use_best_target_button.tooltip_text).contains("Spawn answer"), "use best target tooltip explains the spawn response match")
		var card_slot = scene.find_child("HandCardSlot0", true, false)
		_assert(card_slot != null, "first hand card slot is present")
		if card_slot != null:
			_assert(card_slot.visible, "first hand card slot is visible after run start")
			_assert(str(card_slot.text).contains("Target"), "hand card button shows concise target state")
			_assert(str(card_slot.text).contains("Spawn answer"), "hand card button marks the spawn response answer")
			var tooltip_text = str(card_slot.tooltip_text)
			_assert(tooltip_text.contains("Effect:"), "hand card tooltip shows effect")
			_assert(tooltip_text.contains("Targets:"), "hand card tooltip shows targeting summary")
			_assert(tooltip_text.contains("Spawn answer"), "hand card tooltip explains the spawn response answer")
			m0_scene._on_card_slot_pressed(0)
			await process_frame
			var selected_card_label = scene.find_child("SelectedCardStatusLabel", true, false)
			_assert(selected_card_label != null, "selected card status label is present")
			if selected_card_label != null:
				var selected_card_text = str(selected_card_label.text)
				_assert(selected_card_text.contains("Selected card:"), "selected card status shows card header")
				_assert(selected_card_text.contains("choose a highlighted tile"), "selected card status explains tile targeting")
				_assert(selected_card_text.contains("Targets:"), "selected card status shows target summary")
			if use_best_target_button != null:
				var best_target_report = m0_scene._best_target_action_report()
				_assert(bool(best_target_report.get("ok", false)), "best target report is ready for selected target card")
				_assert(not use_best_target_button.disabled, "use best target button enables for selected target card")
				_assert(str(use_best_target_button.text).contains("Use"), "use best target button shows the action")
			m0_scene.selected_card_index = -1
			_assert(bool(m0_scene.simulation.debug_set_hand(["m0_arc_spark"]).get("ok", false)), "waiting damage hand can be set")
			_assert(bool(m0_scene.simulation.debug_set_mana(4).get("ok", false)), "waiting damage mana can be set")
			m0_scene._refresh_screen()
			await process_frame
			_assert(str(card_slot.text).contains("Wait enemy"), "damage card button explains it is waiting for an enemy")
			_assert(str(card_slot.tooltip_text).contains("no enemy is targetable"), "damage card tooltip explains missing enemy target")
			if resource_label != null:
				_assert(str(resource_label.text).contains("best wait for enemy"), "hand plan explains waiting for enemy target")
			m0_scene._on_card_slot_pressed(0)
			await process_frame
			var wait_enemy_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
			if wait_enemy_selected_label != null:
				_assert(str(wait_enemy_selected_label.text).contains("wait for an enemy target"), "selected damage card explains enemy wait state")
			_assert(bool(m0_scene.simulation.debug_spawn_enemy(Vector2i(12, 10), 2, "east", "m0_walker").get("ok", false)), "waiting damage enemy can be spawned")
			m0_scene.selected_card_index = -1
			m0_scene._refresh_screen()
			await process_frame
			_assert(str(card_slot.text).contains("Target"), "damage card becomes targetable when an enemy appears")
			if resource_label != null:
				_assert(str(resource_label.text).contains("Ready now: Arc Spark"), "hand plan shows a ready cue when an enemy target appears")
			_assert(m0_scene.debug_log.to_text_filtered("system", false).contains("Hand cue: Ready now: Arc Spark"), "ready enemy cue is recorded in the system log")
			_assert(bool(m0_scene.simulation.debug_place_structure(Vector2i(14, 14), "tower", m0_scene.selected_class_id).get("ok", false)), "waiting repair structure can be placed")
			_assert(bool(m0_scene.simulation.debug_set_hand(["m0_field_patch"]).get("ok", false)), "waiting repair hand can be set")
			m0_scene.selected_card_index = -1
			m0_scene._refresh_screen()
			await process_frame
			_assert(str(card_slot.text).contains("Wait damage"), "repair card button explains it is waiting for structure damage")
			_assert(str(card_slot.tooltip_text).contains("repair works after"), "repair card tooltip explains damage wait")
			m0_scene._on_card_slot_pressed(0)
			await process_frame
			var wait_repair_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
			if wait_repair_selected_label != null:
				_assert(str(wait_repair_selected_label.text).contains("wait for a damaged structure"), "selected repair card explains damage wait state")
			_assert(bool(m0_scene.simulation.debug_damage_structure(Vector2i(14, 14), 2).get("ok", false)), "waiting repair structure can be damaged")
			m0_scene.selected_card_index = -1
			m0_scene._refresh_screen()
			await process_frame
			_assert(str(card_slot.text).contains("Target"), "repair card becomes targetable when structure damage appears")
			if resource_label != null:
				_assert(str(resource_label.text).contains("Ready now: Field Patch"), "hand plan shows a ready cue when repair target appears")
			_assert(m0_scene.debug_log.to_text_filtered("system", false).contains("Hand cue: Ready now: Field Patch"), "ready repair cue is recorded in the system log")
		var discard_button = scene.find_child("DiscardSelectedButton", true, false)
		_assert(discard_button != null, "discard selected button is present")
		if discard_button != null:
			var playable_pressure_hand = []
			for playable_pressure_index in range(m0_scene.simulation.get_max_hand_size()):
				playable_pressure_hand.append("m0_arc_spark")
			m0_scene.selected_card_index = -1
			_assert(bool(m0_scene.simulation.debug_set_hand(playable_pressure_hand).get("ok", false)), "playable pressure hand can be set")
			_assert(bool(m0_scene.simulation.debug_set_draw_pile(["m0_quick_think"]).get("ok", false)), "playable pressure draw pile can be set")
			_assert(bool(m0_scene.simulation.debug_set_mana(4).get("ok", false)), "playable pressure mana can be set")
			m0_scene._refresh_screen()
			await process_frame
			_assert(discard_button.disabled, "discard button stays disabled when a pressured hand has playable cards")
			_assert(str(discard_button.text).contains("Play to open slot"), "discard button asks to play first during playable pressure")
			_assert(str(discard_button.tooltip_text).contains("play it first"), "discard button tooltip explains playable pressure priority")
			var pressure_hand = []
			for pressure_index in range(m0_scene.simulation.get_max_hand_size()):
				pressure_hand.append("m0_tower_permit")
			m0_scene.selected_card_index = -1
			_assert(bool(m0_scene.simulation.debug_set_hand(pressure_hand).get("ok", false)), "pressure discard hand can be set")
			_assert(bool(m0_scene.simulation.debug_set_draw_pile(["m0_quick_think"]).get("ok", false)), "pressure discard draw pile can be set")
			_assert(bool(m0_scene.simulation.debug_set_mana(0).get("ok", false)), "pressure discard mana can be set")
			m0_scene._refresh_screen()
			await process_frame
			_assert(not discard_button.disabled, "discard button enables for hand pressure suggestion")
			_assert(str(discard_button.text).contains("Discard pressure"), "discard button names the pressure discard")
			_assert(str(discard_button.tooltip_text).contains("Hand pressure"), "discard button tooltip includes hand pressure context")
			_assert(str(discard_button.tooltip_text).contains("Pressure discard"), "discard button tooltip explains pressure discard")
			if card_slot != null:
				_assert(str(card_slot.text).contains("Pressure pick"), "pressure discard candidate is marked on the hand card")
				_assert(str(card_slot.tooltip_text).contains("opens 1 hand slot"), "pressure discard candidate tooltip explains the slot value")
				m0_scene._on_card_slot_pressed(0)
				await process_frame
				var pressure_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
				if pressure_selected_label != null:
					_assert(str(pressure_selected_label.text).contains("pressure pick"), "selected pressure discard candidate explains its discard role")
					_assert(str(pressure_selected_label.text).contains("opens 1 hand slot"), "selected pressure discard candidate explains hand room")
			m0_scene.selected_card_index = -1
			_assert(bool(m0_scene.simulation.debug_set_hand(["m0_tower_permit", "m0_barricade_kit"]).get("ok", false)), "discard suggestion hand can be set")
			_assert(bool(m0_scene.simulation.debug_set_mana(0).get("ok", false)), "discard suggestion mana can be set")
			m0_scene._refresh_screen()
			await process_frame
			_assert(not discard_button.disabled, "discard button enables for emergency stuck hand suggestion")
			_assert(str(discard_button.text).contains("Discard suggested"), "discard button names the suggested emergency discard")
			_assert(str(discard_button.tooltip_text).contains("Emergency discard"), "discard button tooltip explains emergency discard")
			if card_slot != null:
				_assert(str(card_slot.text).contains("Discard pick"), "emergency discard candidate is marked on the hand card")
				_assert(str(card_slot.tooltip_text).contains("stuck-hand candidate"), "emergency discard candidate tooltip explains the stuck hand value")
				m0_scene._on_card_slot_pressed(0)
				await process_frame
				var emergency_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
				if emergency_selected_label != null:
					_assert(str(emergency_selected_label.text).contains("emergency pick"), "selected emergency discard candidate explains its discard role")
					_assert(str(emergency_selected_label.text).contains("stuck-hand candidate"), "selected emergency discard candidate explains the stuck hand value")
				m0_scene.selected_card_index = -1
				m0_scene._refresh_screen()
				await process_frame
			var hand_count_before_discard = m0_scene.simulation.get_hand().size()
			discard_button.pressed.emit()
			await process_frame
			_assert(m0_scene.simulation.get_mana() == m0_scene.simulation.get_discard_mana_gain(), "suggested discard restores emergency mana")
			_assert(m0_scene.simulation.get_hand().size() == hand_count_before_discard - 1, "suggested discard removes one hand card")
			_assert(m0_scene.simulation.get_discard_charges() == 0, "suggested discard consumes the discard use")
			_assert(m0_scene.debug_log.to_text_filtered("all", false).contains("Emergency discard used"), "suggested discard records an emergency log")
			_assert(m0_scene.debug_log.to_text_filtered("all", false).contains("Discard follow-up:"), "suggested discard records a follow-up hand plan")
			_assert(m0_scene.debug_log.to_text_filtered("all", false).contains("after +1 mana"), "suggested discard follow-up explains the mana result")
			if use_best_target_button != null:
				var post_discard_best_report = m0_scene._best_target_action_report()
				_assert(bool(post_discard_best_report.get("ok", false)), "discard follow-up opens a quick hand action")
				_assert(str(post_discard_best_report.get("card_id", "")) == "m0_barricade_kit", "discard follow-up quick action matches the newly affordable card")
				_assert(str(use_best_target_button.text).contains("Follow-up"), "use best target marks the discard follow-up action")
				_assert(str(use_best_target_button.tooltip_text).contains("Discard follow-up"), "use best target tooltip repeats the discard follow-up")
		m0_scene.simulation.debug_generate_reward_offer(1)
		m0_scene._refresh_screen()
		await process_frame
		if action_status_label != null:
			_assert(str(action_status_label.text).contains("Resolve reward"), "action status explains pending reward lock")
		if wave_readiness_label != null:
			var reward_ready_text = str(wave_readiness_label.text)
			_assert(reward_ready_text.contains("resolve card reward"), "wave readiness points to pending card reward")
			_assert(reward_ready_text.contains("Maintenance:"), "wave readiness keeps maintenance line during reward")
		var reward_option = scene.find_child("RewardOption0", true, false)
		_assert(reward_option != null, "reward option button is present")
		if reward_option != null:
			_assert(reward_option.visible, "reward option button is visible")
			_assert(str(reward_option.text).contains("Take"), "reward option shows take action")
			_assert(str(reward_option.tooltip_text).contains("Take:"), "reward option tooltip explains claim")
			_assert(str(reward_option.text).contains("Suggested"), "reward option marks the suggested pick")
			_assert(str(reward_option.tooltip_text).contains("Suggested:"), "reward option tooltip explains suggestion")
			_assert(str(reward_option.tooltip_text).contains("Why now:"), "reward option tooltip explains recommendation context")
			_assert(str(reward_option.tooltip_text).contains("Gold option:"), "reward option tooltip compares gold choice")
			_assert(not str(reward_option.tooltip_text).contains("Discussion prompt:"), "reward option tooltip does not show alpha rewrite prompt without alpha issue")
			m0_scene._set_autoplay_focus_queue({
				"alpha_focus_queue": [
					{
						"rank": 1,
						"class_id": "guardian",
						"class_label": "Guardian",
						"player_count": 1,
						"direction": "east",
						"primary_signal": "reward wording",
						"evidence": "suggestion reads like an auto-pick",
						"next_probe": "check reward wording",
						"completed_rounds": 1,
						"base_hp": 30,
					},
				],
				"next_action_queue": [],
			})
			var reward_ui_focus_entry: Dictionary = m0_scene.last_autoplay_focus_queue[0]
			var reward_ui_focus_key = m0_scene._alpha_focus_entry_key(reward_ui_focus_entry)
			m0_scene.alpha_focus_manual_review_results[reward_ui_focus_key] = {
				"status": "manual_issue",
				"badge": "ISSUE",
				"summary": "needs recommendation wording pass",
				"class_id": "guardian",
				"class_label": "Guardian",
				"player_count": 1,
				"direction": "east",
				"issue_tag_id": "untagged",
				"issue_tag_label": "",
				"recommendation_contrast_id": "alternate_clearer",
				"recommendation_contrast_label": "Alternate clearer",
				"recommendation_fix_check_ids": ["auto_pick"],
				"recommendation_fix_check_text": "Auto-pick",
			}
			m0_scene._refresh_screen()
			await process_frame
			reward_option = scene.find_child("RewardOption0", true, false)
			_assert(str(reward_option.tooltip_text).contains("Discussion prompt:"), "reward option tooltip shows alpha rewrite prompt after auto-pick issue")
			_assert(str(reward_option.tooltip_text).contains("is still valid if the table wants flexibility"), "reward option rewrite prompt keeps table choice visible")
		var take_gold_button = scene.find_child("RewardTakeGoldButton", true, false)
		_assert(take_gold_button != null, "reward gold button is present")
		if take_gold_button != null:
			_assert(take_gold_button.visible, "reward gold button is visible")
			_assert(str(take_gold_button.text).contains("Take gold"), "reward gold button shows the gold choice")
			_assert(str(take_gold_button.tooltip_text).contains("normal reward choice"), "reward gold tooltip avoids loss wording")
			_assert(str(take_gold_button.tooltip_text).contains("shop trim"), "reward gold tooltip shows shop trim progress")
			var reward_gold_before = m0_scene.simulation.get_gold()
			take_gold_button.pressed.emit()
			await process_frame
			_assert(m0_scene.simulation.get_gold() == reward_gold_before + m0_scene.simulation.get_card_reward_gold(), "reward gold button increases gold")
			_assert(m0_scene.simulation.get_reward_offer().is_empty(), "reward gold button resolves the reward offer")
			_assert(m0_scene.debug_log.to_text_filtered("reward", false).contains("Reward gold taken"), "reward gold button records a reward log")
			_assert(m0_scene.debug_log.to_text_filtered("system", false).contains("Reward economy"), "reward gold button records economy context")
			var reward_choice_trace_log = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(reward_choice_trace_log.contains("Reward choice trace:"), "reward gold button records a choice trace")
			_assert(reward_choice_trace_log.contains("picked Take gold"), "reward gold choice trace records the selected option")
			_assert(reward_choice_trace_log.contains("reward_choice_locked:"), "reward gold button records a reward choice lock trace")
			_assert(reward_choice_trace_log.contains("choice=decline_for_gold"), "reward gold choice lock trace records decline choice")
			_assert(reward_choice_trace_log.contains("forbiddenLockTags"), "reward gold choice lock trace records forbidden lock tags")
			_assert(bool(m0_scene.simulation.debug_set_hand([
				"m0_arc_spark",
				"m0_field_patch",
				"m0_quick_think",
				"m0_tower_permit",
				"m0_barricade_kit",
			]).get("ok", false)), "stable reward gold UI hand can be arranged")
			_assert(bool(m0_scene.simulation.debug_set_draw_pile([
				"m0_arc_spark",
				"m0_tower_permit",
				"m0_barricade_kit",
				"m0_quick_brace",
			]).get("ok", false)), "stable reward gold UI draw pile can be arranged")
			_assert(bool(m0_scene.simulation.debug_set_gold(
				m0_scene.simulation.get_shop_deck_removal_gold_cost() - m0_scene.simulation.get_card_reward_gold()
			).get("ok", false)), "stable reward gold UI gold can be set near shop trim")
			m0_scene.simulation.debug_generate_reward_offer(5)
			m0_scene._refresh_screen()
			await process_frame
			var stable_reward_option = scene.find_child("RewardOption0", true, false)
			if stable_reward_option != null:
				_assert(not str(stable_reward_option.text).contains("Suggested"), "stable reward gold UI does not mark a card as suggested")
			var stable_take_gold_button = scene.find_child("RewardTakeGoldButton", true, false)
			_assert(stable_take_gold_button != null, "stable reward gold UI button is present")
			if stable_take_gold_button != null:
				_assert(str(stable_take_gold_button.text).contains("Suggested"), "stable reward gold UI marks gold as suggested")
				_assert(str(stable_take_gold_button.tooltip_text).contains("Why now:"), "stable reward gold UI explains why gold is suggested")
				_assert(str(stable_take_gold_button.tooltip_text).contains("funds the next shop trim"), "stable reward gold UI explains shop trim timing")
				_assert(str(stable_take_gold_button.tooltip_text).contains("Discussion prompt:"), "stable reward gold UI shows alpha rewrite prompt")
				_assert(str(stable_take_gold_button.tooltip_text).contains("a clear role card is still valid"), "stable reward gold rewrite prompt keeps card alternate visible")
				stable_take_gold_button.pressed.emit()
				await process_frame
				_assert(m0_scene.simulation.get_reward_offer().is_empty(), "stable suggested reward gold resolves the reward offer")
				var stable_reward_trace_log = m0_scene.debug_log.to_text_filtered("system", false)
				_assert(stable_reward_trace_log.contains("Reward choice trace: followed suggestion"), "stable reward gold records a followed suggestion trace")
				_assert(stable_reward_trace_log.contains("reward_choice_locked:"), "stable reward gold records a choice lock trace")
		m0_scene.simulation.debug_generate_artifact_offer()
		m0_scene._refresh_screen()
		await process_frame
		var artifact_option = scene.find_child("ArtifactOption0", true, false)
		_assert(artifact_option != null, "artifact option button is present")
		if artifact_option != null:
			_assert(artifact_option.visible, "artifact option button is visible")
			_assert(str(artifact_option.text).contains("Equip"), "artifact option shows equip action")
			_assert(str(artifact_option.tooltip_text).contains("party passive"), "artifact option tooltip explains passive")
		var artifact_recommendation = m0_scene.simulation.get_artifact_recommendation_report()
		if bool(artifact_recommendation.get("ok", false)):
			_assert(str(artifact_recommendation.get("detail_text", "")).contains("Equipped:"), "artifact recommendation report includes equipped context")
			_assert(str(artifact_recommendation.get("detail_text", "")).contains("Effect:"), "artifact recommendation report includes effect context")
			var suggested_artifact_option = scene.find_child("ArtifactOption%s" % int(artifact_recommendation.get("index", 0)), true, false)
			_assert(suggested_artifact_option != null, "suggested artifact option button is present")
			if suggested_artifact_option != null:
				_assert(str(suggested_artifact_option.text).contains("Suggested"), "artifact option marks the suggested pick")
				_assert(str(suggested_artifact_option.tooltip_text).contains("Suggested:"), "artifact option tooltip explains suggestion")
				_assert(str(suggested_artifact_option.tooltip_text).contains("Why now:"), "artifact option tooltip explains recommendation context")
				_assert(str(suggested_artifact_option.tooltip_text).contains("Effect:"), "artifact option tooltip includes artifact effect context")
				_assert(str(suggested_artifact_option.tooltip_text).contains("Discussion prompt:"), "artifact option tooltip shows alpha rewrite prompt")
				_assert(str(suggested_artifact_option.tooltip_text).contains("the other artifact or skipping for now is still valid"), "artifact rewrite prompt keeps alternate visible")
				suggested_artifact_option.pressed.emit()
				await process_frame
				var artifact_choice_trace_log = m0_scene.debug_log.to_text_filtered("system", false)
				_assert(artifact_choice_trace_log.contains("Artifact choice trace:"), "artifact choice records a choice trace")
				_assert(artifact_choice_trace_log.contains("followed suggestion"), "artifact choice trace records followed suggestion state")
				_assert(artifact_choice_trace_log.contains("Why now:"), "artifact choice trace keeps recommendation context")
		m0_scene.simulation.debug_generate_shop_offer(10)
		m0_scene.simulation.debug_set_gold(m0_scene.simulation.get_shop_deck_removal_gold_cost())
		m0_scene._refresh_screen()
		await process_frame
		var shop_option = scene.find_child("ShopOption0", true, false)
		_assert(shop_option != null, "shop option button is present")
		if shop_option != null:
			_assert(shop_option.visible, "shop option button is visible")
			_assert(str(shop_option.text).contains("Remove"), "shop option shows remove action")
			_assert(str(shop_option.tooltip_text).contains("Blocked:") or str(shop_option.tooltip_text).contains("Ready"), "shop option tooltip shows availability")
		var shop_recommendation = m0_scene.simulation.get_shop_recommendation_report(m0_scene.player_count, m0_scene.selected_class_id)
		if bool(shop_recommendation.get("ok", false)):
			_assert(str(shop_recommendation.get("detail_text", "")).contains("Deck:"), "shop recommendation report includes deck context")
			_assert(str(shop_recommendation.get("detail_text", "")).contains("Gold:"), "shop recommendation report includes gold context")
			var suggested_shop_option = scene.find_child("ShopOption%s" % int(shop_recommendation.get("index", 0)), true, false)
			_assert(suggested_shop_option != null, "suggested shop option button is present")
			if suggested_shop_option != null:
				_assert(str(suggested_shop_option.text).contains("Suggested"), "shop option marks the suggested trim")
				_assert(str(suggested_shop_option.tooltip_text).contains("Suggested:"), "shop option tooltip explains suggestion")
				_assert(str(suggested_shop_option.tooltip_text).contains("Why now:"), "shop option tooltip explains recommendation context")
				_assert(str(suggested_shop_option.tooltip_text).contains("Gold:"), "shop option tooltip includes shop gold context")
				_assert(str(suggested_shop_option.tooltip_text).contains("Discussion prompt:"), "shop option tooltip shows alpha rewrite prompt")
				_assert(str(suggested_shop_option.tooltip_text).contains("saving gold for a later trim is still valid"), "shop rewrite prompt keeps economy alternate visible")
				suggested_shop_option.pressed.emit()
				await process_frame
				var shop_choice_trace_log = m0_scene.debug_log.to_text_filtered("system", false)
				_assert(shop_choice_trace_log.contains("Shop choice trace:"), "shop choice records a choice trace")
				_assert(shop_choice_trace_log.contains("followed suggestion"), "shop choice trace records followed suggestion state")
				_assert(shop_choice_trace_log.contains("Why now:"), "shop choice trace keeps recommendation context")

	if m0_scene != null and use_best_target_button != null:
		m0_scene._on_reset_pressed()
		await process_frame
		m0_scene._on_begin_run_pressed()
		await process_frame
		var quick_action_report = m0_scene._best_target_action_report()
		_assert(bool(quick_action_report.get("ok", false)), "quick hand action is available after a fresh reset")
		var quick_structure_count_before = m0_scene.simulation.get_structure_tiles().size()
		use_best_target_button.pressed.emit()
		await process_frame
		_assert(m0_scene.simulation.get_structure_tiles().size() > quick_structure_count_before, "use best target plays the recommended opening structure card")
		_assert(m0_scene._selected_card_id().is_empty(), "quick hand action clears selected card after play")
		_assert(m0_scene.build_mode == "none", "quick hand action returns to neutral build mode")
		if wave_readiness_label != null:
			var covered_ready_text = str(wave_readiness_label.text)
			_assert(covered_ready_text.contains("east OK"), "wave readiness marks covered front after quick hand action")
			_assert(covered_ready_text.contains("Next: start wave"), "wave readiness returns to start wave once the active front is covered")
		m0_scene._on_start_wave_pressed()
		m0_scene.wave_timer.stop()
		await process_frame
		var wave_started_log_text = m0_scene.debug_log.to_text_filtered("system", false)
		_assert(wave_started_log_text.contains("wave_started:"), "start wave records wave_started trace")
		_assert(wave_started_log_text.contains("playerCountAtStart=1"), "wave_started trace keeps locked player count")
		_assert(wave_started_log_text.contains("activeDirections=east"), "wave_started trace keeps locked active directions")
		_assert(wave_started_log_text.contains("directions=east"), "wave_started trace records actual spawn directions")
		_assert(wave_started_log_text.contains("previewCardId=wave_preview_card_day_001"), "wave_started trace records preview card id")
		_assert(wave_started_log_text.contains("intent=intent_route_read"), "wave_started trace records wave intent id")
		_assert(wave_started_log_text.contains("role=swarm"), "wave_started trace records preview card role")
		if wave_preview_label != null:
			_assert(str(wave_preview_label.text).contains("Spawn queue"), "active wave preview shows remaining spawn queue")
		if tactical_hint_label != null:
			var active_tactical_text = str(tactical_hint_label.text)
			_assert(active_tactical_text.contains("Spawn response: next east Walker now"), "wave tactical hint shows active spawn response timing")
		if stack_risk_label != null:
			var active_pull_check_text = str(stack_risk_label.text)
			_assert(active_pull_check_text.contains("Pull tempo:"), "stack risk label keeps pull tempo guidance during an active wave")
			_assert(active_pull_check_text.contains("next east Walker now"), "active pull tempo names the live spawn response")
			_assert(active_pull_check_text.contains("shorten downtime"), "active pull tempo frames pulling as downtime compression")
		if call_next_button != null:
			var active_pull_tooltip = str(call_next_button.tooltip_text)
			_assert(active_pull_tooltip.contains("Pull tempo:"), "pull button tooltip keeps pull tempo guidance during an active wave")
			_assert(active_pull_tooltip.contains("shorten downtime"), "pull button tooltip frames pulling as downtime compression")
		if m0_scene.map_view != null:
			_assert(m0_scene.map_view.debug_spawn_warning_label(Vector2i(20, 10)) == ">", "map keeps the next active spawn warning on the east entrance")
		if call_next_button != null:
			call_next_button.pressed.emit()
			await process_frame
			if stack_risk_label != null:
				var pulled_stack_text = str(stack_risk_label.text)
				_assert(pulled_stack_text.contains("Pull impact:"), "stack risk label shows post-pull impact after pulling a wave")
				_assert(pulled_stack_text.contains("pulled R2"), "post-pull impact names the pulled round")
				_assert(pulled_stack_text.contains("active queue R1+R2"), "post-pull impact names the active queue")
				_assert(pulled_stack_text.contains("moment_wave_stack_tempo:"), "stack risk label opens the wave stack tempo moment after pulling")
				_assert(pulled_stack_text.contains("No bonus rewards"), "post-pull impact keeps no bonus copy")
			if tactical_hint_label != null:
				_assert(str(tactical_hint_label.text).contains("Pull impact:"), "tactical hint shows post-pull impact after pulling a wave")
				_assert(str(tactical_hint_label.text).contains("moment_wave_stack_tempo:"), "tactical hint shows the wave stack tempo moment after pulling")
			var pull_log_text = m0_scene.debug_log.to_text_filtered("all", false)
			_assert(pull_log_text.contains("Pull impact:"), "pull action records post-pull impact in the log")
			_assert(pull_log_text.contains("moment_wave_stack_tempo:"), "pull action records wave stack tempo moment in the log")
		_assert(bool(m0_scene.simulation.debug_set_hand(["m0_arc_spark"]).get("ok", false)), "combat follow-up damage hand can be set")
		_assert(bool(m0_scene.simulation.debug_set_draw_pile(["m0_barricade_kit"]).get("ok", false)), "combat follow-up draw pile can be set")
		_assert(bool(m0_scene.simulation.debug_set_draw_gauge(1).get("ok", false)), "combat follow-up draw gauge can be primed")
		_assert(bool(m0_scene.simulation.debug_set_mana(1).get("ok", false)), "combat follow-up mana can be set")
		m0_scene.simulation.debug_spawn_enemy(Vector2i(12, 10), 2, "east", "m0_walker")
		m0_scene._refresh_screen()
		await process_frame
		var combat_best_report = m0_scene._best_target_action_report()
		_assert(bool(combat_best_report.get("ok", false)), "combat best target is available for a live threat")
		_assert(str(combat_best_report.get("card_id", "")) == "m0_arc_spark", "combat best target selects the damage card answer")
		_assert(combat_best_report.get("tile", Vector2i.ZERO) == Vector2i(12, 10), "combat best target aims at the threatening enemy source tile")
		_assert(bool(combat_best_report.get("tactical", false)), "combat best target marks the tactical threat match")
		_assert(str(combat_best_report.get("summary", "")).contains("Spawn answer"), "combat best target explains the active spawn response match")
		if m0_scene.map_view != null:
			_assert(m0_scene.map_view.debug_tactical_threat_label(Vector2i(11, 10)) == "!", "map marks the imminent base hit tile during combat")
		var enemy_count_before_card = m0_scene.simulation.debug_get_enemies().size()
		use_best_target_button.pressed.emit()
		await process_frame
		_assert(m0_scene.simulation.debug_get_enemies().size() < enemy_count_before_card, "use best target plays the tactical damage card into the live threat")
		_assert(m0_scene._selected_card_id().is_empty(), "tactical quick action clears selected card after play")
		_assert(m0_scene.build_mode == "none", "tactical quick action returns to neutral build mode")
		_assert(m0_scene.debug_log.to_text_filtered("all", false).contains("Combat follow-up:"), "combat kill records a follow-up hand plan")
		var post_kill_best_report = m0_scene._best_target_action_report()
		_assert(bool(post_kill_best_report.get("ok", false)), "combat follow-up opens a quick hand action")
		_assert(str(post_kill_best_report.get("card_id", "")) == "m0_barricade_kit", "combat follow-up quick action matches the drawn affordable card")
		_assert(str(use_best_target_button.text).contains("Combat follow-up"), "use best target marks the combat follow-up action")
		_assert(str(use_best_target_button.tooltip_text).contains("Combat follow-up"), "use best target tooltip repeats the combat follow-up")
		if resource_label != null:
			var combat_gains_text = str(resource_label.text)
			_assert(combat_gains_text.contains("Combat gains:"), "resource status shows combat gains after a kill")
			_assert(combat_gains_text.contains("Hand pressure:"), "resource status keeps hand pressure visible during combat")
			_assert(combat_gains_text.contains("last kill"), "combat gains summary names the last kill")
			_assert(combat_gains_text.contains("+1 mana"), "combat gains summary shows kill mana")
		var repair_tile = Vector2i(14, 14)
		m0_scene.simulation.debug_place_structure(repair_tile, "barricade", m0_scene.selected_class_id)
		m0_scene.simulation.debug_set_hand(["m0_field_patch"])
		m0_scene.simulation.debug_spawn_enemy(Vector2i(14, 15), 6, "east", "m0_walker")
		m0_scene._refresh_screen()
		await process_frame
		m0_scene._on_card_slot_pressed(0)
		await process_frame
		var repair_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
		_assert(repair_selected_label != null, "repair selected card status label is present")
		if repair_selected_label != null:
			var repair_wait_text = str(repair_selected_label.text)
			_assert(repair_wait_text.contains("hold until after hit"), "repair card explains waiting for incoming structure damage")
		if wave_readiness_label != null:
			_assert(str(wave_readiness_label.text).contains("hold until after hit"), "wave readiness repeats repair hold timing")
		if tactical_hint_label != null:
			var repair_risk_ping_text = str(tactical_hint_label.text)
			_assert(repair_risk_ping_text.contains("Risk pings:"), "tactical hint shows risk ping candidates during structure threat")
			_assert(repair_risk_ping_text.contains("Repair request"), "risk ping candidates include repair request for structure threat")
			_assert(repair_risk_ping_text.contains("candidate only"), "risk ping candidates are not auto-confirmed")
		if risk_ping_button != null:
			_assert(risk_ping_button.visible, "risk ping button appears during structure threat")
			_assert(str(risk_ping_button.text).contains("Repair request"), "risk ping button shows the first candidate")
			_assert(str(risk_ping_button.tooltip_text).contains("Confirm risk ping"), "risk ping button tooltip explains confirmation")
			_assert(not m0_scene.debug_log.to_text_filtered("system", false).contains("Risk ping confirmed"), "risk ping candidate is not logged before pressing")
			risk_ping_button.pressed.emit()
			await process_frame
			var confirmed_ping_log = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(confirmed_ping_log.contains("Risk ping confirmed: Repair request"), "risk ping button confirms the candidate into the log")
			_assert(m0_scene.debug_log.to_text_filtered("all", true).contains("Risk ping confirmed"), "confirmed risk ping is important in the activity log")
			_assert(m0_scene.map_view.debug_confirmed_risk_ping_label(repair_tile) == "P", "confirmed risk ping marks the target tile on the map")
		if m0_scene.map_view != null:
			_assert(m0_scene.map_view.debug_tactical_threat_label(repair_tile) == "!", "map marks the threatened structure for repair timing")
		m0_scene.simulation.debug_damage_structure(repair_tile, 6)
		m0_scene._refresh_screen()
		await process_frame
		var repair_best_report = m0_scene._best_target_action_report()
		_assert(bool(repair_best_report.get("ok", false)), "repair best target becomes available once the threatened structure is damaged")
		_assert(str(repair_best_report.get("card_id", "")) == "m0_field_patch", "repair best target keeps the repair card")
		_assert(repair_best_report.get("tile", Vector2i.ZERO) == repair_tile, "repair best target aims at the damaged threatened structure")
		_assert(bool(repair_best_report.get("tactical", false)), "repair best target marks the tactical repair match")
		var structure_before_repair: Dictionary = m0_scene.simulation.get_structure_tiles().get(m0_scene._tile_key(repair_tile), {})
		var hp_before_repair = int(structure_before_repair.get("hp", 0))
		use_best_target_button.pressed.emit()
		await process_frame
		var structure_after_repair: Dictionary = m0_scene.simulation.get_structure_tiles().get(m0_scene._tile_key(repair_tile), {})
		_assert(int(structure_after_repair.get("hp", 0)) > hp_before_repair, "use best target repairs the damaged threatened structure")
		_assert(m0_scene._selected_card_id().is_empty(), "repair quick action clears selected card after play")

		m0_scene._on_reset_pressed()
		await process_frame
		m0_scene._on_begin_run_pressed()
		await process_frame
		m0_scene._on_start_wave_pressed()
		m0_scene.wave_timer.stop()
		await process_frame
		var boss_warning_structure_tile = Vector2i(18, 9)
		_assert(bool(m0_scene.simulation.debug_place_structure(boss_warning_structure_tile, "tower", m0_scene.selected_class_id).get("ok", false)), "boss warning UI target structure can be placed")
		_assert(bool(m0_scene.simulation.debug_set_hand(["m0_arc_spark"]).get("ok", false)), "boss warning UI damage hand can be set")
		_assert(bool(m0_scene.simulation.debug_spawn_enemy(Vector2i(18, 10), 6, "east", "m0_walker").get("ok", false)), "boss warning UI normal enemy can be spawned")
		_assert(bool(m0_scene.simulation.debug_spawn_enemy(Vector2i(20, 10), -1, "east", "m0_colossus").get("ok", false)), "boss warning UI boss can be spawned")
		m0_scene._refresh_screen()
		await process_frame
		var boss_warning_report = m0_scene.simulation.get_boss_part_warning_report(m0_scene.player_count)
		_assert(bool(boss_warning_report.get("ok", false)), "boss warning UI scenario exposes a boss part warning")
		m0_scene.active_alpha_probe_entry = {
			"rank": 1,
			"class_id": m0_scene.selected_class_id,
			"class_label": m0_scene._class_label(m0_scene.selected_class_id),
			"player_count": m0_scene.player_count,
			"direction": "east",
			"primary_signal": "boss warning",
			"completed_rounds": 2,
			"base_hp": 64,
		}
		m0_scene.last_boss_warning_response_line = ""
		var pending_probe_status = m0_scene._format_alpha_probe_status()
		_assert(pending_probe_status.contains("pending"), "alpha focus probe shows pending boss warning")
		_assert(pending_probe_status.contains("Legs"), "alpha focus probe names the pending boss part")
		var pending_boss_response_line = m0_scene._alpha_focus_boss_response_line(m0_scene.active_alpha_probe_entry)
		_assert(pending_boss_response_line.contains("pending"), "alpha focus body line shows pending boss warning")
		var boss_warning_card_slot = scene.find_child("HandCardSlot0", true, false)
		_assert(boss_warning_card_slot != null, "boss warning hand card slot is present")
		if boss_warning_card_slot != null:
			_assert(str(boss_warning_card_slot.text).contains("Boss answer"), "damage card button labels the boss warning answer")
			_assert(str(boss_warning_card_slot.tooltip_text).contains("Boss response:"), "damage card tooltip explains the boss warning answer")
		if m0_scene.map_view != null:
			_assert(m0_scene.map_view.debug_boss_warning_label(Vector2i(20, 10)) == "W", "map marks the warned boss part")
			_assert(m0_scene.map_view.debug_boss_warning_label(boss_warning_structure_tile) == "!", "map marks the boss warning structure target")
			var delay_tile_marked = false
			for warning_value in m0_scene.map_view.boss_warning_tiles.values():
				if typeof(warning_value) == TYPE_DICTIONARY:
					var warning_entry: Dictionary = warning_value
					if str(warning_entry.get("kind", "")) == "delay":
						delay_tile_marked = true
						break
			_assert(delay_tile_marked, "map marks boss warning delay candidates")
		var boss_damage_best_report = m0_scene._best_target_action_report()
		_assert(bool(boss_damage_best_report.get("ok", false)), "quick hand action is available for boss part warning damage")
		_assert(str(boss_damage_best_report.get("card_id", "")) == "m0_arc_spark", "quick hand action keeps the damage card for boss part warning")
		_assert(boss_damage_best_report.get("tile", Vector2i.ZERO) == Vector2i(20, 10), "quick hand action targets the warned boss before normal enemies")
		_assert(bool(boss_damage_best_report.get("tactical", false)), "boss part warning damage is marked tactical")
		_assert(str(boss_damage_best_report.get("summary", "")).contains("Boss warning response"), "boss part warning damage explains the warning response")
		use_best_target_button.pressed.emit()
		await process_frame
		var boss_warning_log_text = m0_scene.debug_log.to_text_filtered("combat", true)
		_assert(boss_warning_log_text.contains("Boss warning response"), "important combat log records the boss warning response")
		_assert(boss_warning_log_text.contains("Boss answer"), "important combat log records the boss warning response type")
		var answered_probe_status = m0_scene._format_alpha_probe_status()
		_assert(answered_probe_status.contains("Boss answer"), "alpha focus probe replaces pending boss warning after response")
		m0_scene.active_alpha_probe_entry.clear()

		_assert(bool(m0_scene.simulation.debug_damage_structure(boss_warning_structure_tile, 2).get("ok", false)), "boss warning UI structure can be damaged")
		_assert(bool(m0_scene.simulation.debug_set_hand(["m0_field_patch"]).get("ok", false)), "boss warning UI repair hand can be set")
		m0_scene.selected_card_index = -1
		m0_scene._refresh_screen()
		await process_frame
		boss_warning_card_slot = scene.find_child("HandCardSlot0", true, false)
		if boss_warning_card_slot != null:
			_assert(str(boss_warning_card_slot.text).contains("Repair target"), "repair card button labels the boss warning repair")
			_assert(str(boss_warning_card_slot.tooltip_text).contains("Boss response:"), "repair card tooltip explains the boss warning repair")
		var boss_repair_best_report = m0_scene._best_target_action_report()
		_assert(bool(boss_repair_best_report.get("ok", false)), "quick hand action is available for boss warning repair")
		_assert(str(boss_repair_best_report.get("card_id", "")) == "m0_field_patch", "quick hand action chooses repair when boss warning target is damaged")
		_assert(boss_repair_best_report.get("tile", Vector2i.ZERO) == boss_warning_structure_tile, "quick hand action repairs the boss warning target structure")
		_assert(bool(boss_repair_best_report.get("tactical", false)), "boss warning repair is marked tactical")
		m0_scene._on_card_slot_pressed(0)
		await process_frame
		if repair_selected_label != null:
			_assert(str(repair_selected_label.text).contains("boss warning target"), "repair selected card timing explains boss warning repair")

		_assert(bool(m0_scene.simulation.debug_set_hand(["m0_barricade_kit"]).get("ok", false)), "boss warning UI barricade hand can be set")
		m0_scene.selected_card_index = -1
		m0_scene._refresh_screen()
		await process_frame
		boss_warning_card_slot = scene.find_child("HandCardSlot0", true, false)
		if boss_warning_card_slot != null:
			_assert(str(boss_warning_card_slot.text).contains("Delay option"), "barricade card button labels the boss warning delay")
			_assert(str(boss_warning_card_slot.tooltip_text).contains("Boss response:"), "barricade card tooltip explains the boss warning delay")
		var boss_delay_best_report = m0_scene._best_target_action_report()
		_assert(bool(boss_delay_best_report.get("ok", false)), "quick hand action is available for boss warning delay")
		_assert(str(boss_delay_best_report.get("card_id", "")) == "m0_barricade_kit", "quick hand action chooses barricade when boss warning needs delay")
		_assert(bool(boss_delay_best_report.get("tactical", false)), "boss warning barricade delay is marked tactical")
		_assert(str(boss_delay_best_report.get("summary", "")).contains("Boss warning response"), "boss warning barricade delay explains the warning response")

		m0_scene._on_reset_pressed()
		await process_frame
		m0_scene.selected_class_id = "architect"
		m0_scene._on_begin_run_pressed()
		await process_frame
		var setup_report = m0_scene._setup_plan_action_report()
		var collapse_tile: Vector2i = setup_report.get("tile", Vector2i(14, 14))
		if not m0_scene._is_valid_tile(collapse_tile):
			collapse_tile = Vector2i(14, 14)
		m0_scene.simulation.debug_place_structure(collapse_tile, "barricade", "architect")
		var collapse_structure: Dictionary = m0_scene.simulation.get_structure_tiles().get(m0_scene._tile_key(collapse_tile), {})
		var collapse_damage_needed = max(0, int(collapse_structure.get("hp", 0)) - 7)
		m0_scene.simulation.debug_damage_structure(collapse_tile, collapse_damage_needed)
		m0_scene._refresh_screen()
		await process_frame
		if m0_scene.auto_step_toggle != null:
			m0_scene.auto_step_toggle.button_pressed = false
		m0_scene.wave_timer.stop()
		m0_scene._on_start_wave_pressed()
		m0_scene.wave_timer.stop()
		await process_frame
		var breaker_spawn = collapse_tile + Vector2i(0, 1)
		if not m0_scene._is_valid_tile(breaker_spawn):
			breaker_spawn = collapse_tile + Vector2i(0, -1)
		m0_scene.simulation.debug_set_hand(["m0_field_patch"])
		m0_scene.simulation.debug_spawn_enemy(breaker_spawn, 8, "east", "m0_breaker")
		m0_scene._refresh_screen()
		await process_frame
		var collapse_line = m0_scene._structure_threat_timing_line()
		_assert(collapse_line.contains("will break"), "structure threat line warns before the next hit breaks a structure")
		_assert(collapse_line.contains("planned collapse"), "structure threat line explains architect planned collapse value")
		if tactical_hint_label != null:
			_assert(str(tactical_hint_label.text).contains("planned collapse"), "tactical hint repeats planned collapse value")
		var planned_hold_report = m0_scene._best_target_action_report()
		_assert(not bool(planned_hold_report.get("ok", false)), "quick hand action holds repair that would erase planned collapse")
		_assert(str(planned_hold_report.get("reason", "")) == "planned_collapse_preserved", "quick hand action explains planned collapse preservation")
		if use_best_target_button != null:
			_assert(use_best_target_button.disabled, "use best target button disables when only repair would erase planned collapse")
			_assert(str(use_best_target_button.tooltip_text).contains("planned collapse"), "use best target tooltip explains the held repair")
		m0_scene.simulation.debug_set_hand(["m0_field_patch", "m0_arc_spark"])
		m0_scene.selected_card_index = -1
		m0_scene._refresh_screen()
		await process_frame
		var planned_damage_report = m0_scene._best_target_action_report()
		_assert(bool(planned_damage_report.get("ok", false)), "quick hand action still finds a non-repair answer during planned collapse")
		_assert(str(planned_damage_report.get("card_id", "")) == "m0_arc_spark", "quick hand action prefers damage over erasing planned collapse")
		_assert(planned_damage_report.get("tile", Vector2i.ZERO) == breaker_spawn, "quick hand action aims damage at the attacker preserving collapse")
		_assert(bool(planned_damage_report.get("tactical", false)), "planned collapse damage answer is marked tactical")
		m0_scene.simulation.debug_set_hand(["m0_field_patch"])
		m0_scene.selected_card_index = -1
		m0_scene._refresh_screen()
		await process_frame
		m0_scene._on_card_slot_pressed(0)
		await process_frame
		if repair_selected_label != null:
			_assert(str(repair_selected_label.text).contains("planned collapse"), "repair card timing warns that repair prevents planned collapse")
		m0_scene.selected_tile = collapse_tile
		m0_scene._refresh_selected_tile()
		await process_frame
		if m0_scene.selected_label != null:
			_assert(str(m0_scene.selected_label.text).contains("planned collapse"), "selected structure report includes planned collapse risk")

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
