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

	var resource_label = scene.find_child("ResourceStatusLabel", true, false)
	var stack_risk_label = scene.find_child("StackRiskLabel", true, false)
	var tactical_hint_label = scene.find_child("WaveTacticalHintLabel", true, false)
	var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
	var wave_preview_label = scene.find_child("WavePreviewLabel", true, false)
	var call_next_button = scene.find_child("CallNextButton", true, false)
	var use_best_target_button = scene.find_child("UseBestTargetButton", true, false)

	_assert(resource_label != null, "resource status label is present")
	_assert(stack_risk_label != null, "stack risk label is present")
	_assert(tactical_hint_label != null, "wave tactical hint label is present")
	_assert(wave_readiness_label != null, "wave readiness label is present")
	_assert(wave_preview_label != null, "wave preview label is present")
	_assert(call_next_button != null, "pull next wave button is present")
	_assert(use_best_target_button != null, "use best target button is present")

	m0_scene._on_begin_run_pressed()
	await process_frame
	_assert(m0_scene.run_started, "wave tempo test begins a run")

	if stack_risk_label != null:
		var setup_pull_text = str(stack_risk_label.text)
		_assert(setup_pull_text.contains("Pull tempo:"), "setup pull guidance is visible")
		_assert(setup_pull_text.contains("start the current wave"), "setup pull guidance asks for current wave first")
		_assert(setup_pull_text.contains("No bonus rewards"), "setup pull guidance rejects bonus reward copy")
	if call_next_button != null:
		_assert(str(call_next_button.tooltip_text).contains("start the current wave"), "pull button tooltip explains inactive-wave timing")

	var opening_best_report = m0_scene._best_target_action_report()
	_assert(bool(opening_best_report.get("ok", false)), "opening quick hand action is available")
	_assert(str(opening_best_report.get("summary", "")).contains("Spawn answer"), "opening quick action explains spawn response")
	if use_best_target_button != null:
		var structure_count_before = m0_scene.simulation.get_structure_tiles().size()
		use_best_target_button.pressed.emit()
		await process_frame
		_assert(m0_scene.simulation.get_structure_tiles().size() > structure_count_before, "opening quick action places the recommended structure")
		_assert(m0_scene._selected_card_id().is_empty(), "opening quick action clears selected card")
		_assert(m0_scene.build_mode == "none", "opening quick action returns to neutral mode")

	if wave_readiness_label != null:
		var covered_ready_text = str(wave_readiness_label.text)
		_assert(covered_ready_text.contains("east OK"), "opening placement covers the solo east front")
		_assert(covered_ready_text.contains("Next: start wave"), "wave readiness returns to start wave after setup")

	m0_scene._on_start_wave_pressed()
	m0_scene.wave_timer.stop()
	await process_frame
	_assert(m0_scene.simulation.wave_active, "wave starts for tempo pull test")

	var wave_started_log_text = m0_scene.debug_log.to_text_filtered("system", false)
	_assert(wave_started_log_text.contains("wave_started:"), "wave start records a wave trace")
	_assert(wave_started_log_text.contains("activeDirections=east"), "wave trace keeps locked solo direction")
	_assert(wave_started_log_text.contains("previewCardId=wave_preview_card_day_001"), "wave trace records preview card id")
	_assert(wave_started_log_text.contains("intent=intent_route_read"), "wave trace records wave intent")

	if wave_preview_label != null:
		_assert(str(wave_preview_label.text).contains("Spawn queue"), "active wave preview shows remaining spawn queue")
	if tactical_hint_label != null:
		_assert(str(tactical_hint_label.text).contains("Spawn response: next east Walker now"), "active tactical hint names the next spawn response")
	if stack_risk_label != null:
		var active_pull_text = str(stack_risk_label.text)
		_assert(active_pull_text.contains("Pull tempo:"), "active wave keeps pull tempo guidance")
		_assert(active_pull_text.contains("shorten downtime"), "active pull guidance frames wave stacking as downtime compression")
		_assert(active_pull_text.contains("next east Walker now"), "active pull guidance names the live spawn response")
	if call_next_button != null:
		var active_pull_tooltip = str(call_next_button.tooltip_text)
		_assert(active_pull_tooltip.contains("Pull tempo:"), "active pull button tooltip keeps tempo guidance")
		_assert(active_pull_tooltip.contains("shorten downtime"), "active pull button tooltip avoids growth framing")

	if m0_scene.map_view != null:
		_assert(m0_scene.map_view.debug_spawn_warning_label(Vector2i(20, 10)) == ">", "map keeps the next active spawn warning on east entrance")

	if call_next_button != null:
		call_next_button.pressed.emit()
		await process_frame
		if stack_risk_label != null:
			var pulled_stack_text = str(stack_risk_label.text)
			_assert(pulled_stack_text.contains("Pull impact:"), "stack risk label shows post-pull impact")
			_assert(pulled_stack_text.contains("pulled R2"), "post-pull impact names the pulled round")
			_assert(pulled_stack_text.contains("active queue R1+R2"), "post-pull impact names the active queue")
			_assert(pulled_stack_text.contains("moment_wave_stack_tempo:"), "post-pull impact opens the wave stack tempo moment")
			_assert(pulled_stack_text.contains("No bonus rewards"), "post-pull impact keeps no bonus copy")
		if tactical_hint_label != null:
			_assert(str(tactical_hint_label.text).contains("Pull impact:"), "tactical hint shows post-pull impact")
			_assert(str(tactical_hint_label.text).contains("moment_wave_stack_tempo:"), "tactical hint shows the wave stack tempo moment")
		var pull_log_text = m0_scene.debug_log.to_text_filtered("all", false)
		_assert(pull_log_text.contains("Pull impact:"), "pull action records post-pull impact in the log")
		_assert(pull_log_text.contains("moment_wave_stack_tempo:"), "pull action records wave stack tempo moment in the log")

	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_arc_spark"]).get("ok", false)), "combat follow-up damage hand can be set")
	_assert(bool(m0_scene.simulation.debug_set_draw_pile(["m0_barricade_kit"]).get("ok", false)), "combat follow-up draw pile can be set")
	_assert(bool(m0_scene.simulation.debug_set_draw_gauge(1).get("ok", false)), "combat follow-up draw gauge can be primed")
	_assert(bool(m0_scene.simulation.debug_set_mana(1).get("ok", false)), "combat follow-up mana can be set")
	_assert(bool(m0_scene.simulation.debug_spawn_enemy(Vector2i(12, 10), 2, "east", "m0_walker").get("ok", false)), "combat follow-up enemy can be spawned")
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

	if use_best_target_button != null:
		var enemy_count_before_card = m0_scene.simulation.debug_get_enemies().size()
		use_best_target_button.pressed.emit()
		await process_frame
		_assert(m0_scene.simulation.debug_get_enemies().size() < enemy_count_before_card, "use best target plays the tactical damage card into the live threat")
		_assert(m0_scene._selected_card_id().is_empty(), "tactical quick action clears selected card after play")
		_assert(m0_scene.build_mode == "none", "tactical quick action returns to neutral mode")

	_assert(m0_scene.debug_log.to_text_filtered("all", false).contains("Combat follow-up:"), "combat kill records a follow-up hand plan")
	var post_kill_best_report = m0_scene._best_target_action_report()
	_assert(bool(post_kill_best_report.get("ok", false)), "combat follow-up opens a quick hand action")
	_assert(str(post_kill_best_report.get("card_id", "")) == "m0_barricade_kit", "combat follow-up quick action matches the drawn affordable card")
	if use_best_target_button != null:
		_assert(str(use_best_target_button.text).contains("Combat follow-up"), "use best target marks the combat follow-up action")
		_assert(str(use_best_target_button.tooltip_text).contains("Combat follow-up"), "use best target tooltip repeats the combat follow-up")
	if resource_label != null:
		var combat_gains_text = str(resource_label.text)
		_assert(combat_gains_text.contains("Combat gains:"), "resource status shows combat gains after a kill")
		_assert(combat_gains_text.contains("Hand pressure:"), "resource status keeps hand pressure visible during combat")
		_assert(combat_gains_text.contains("last kill"), "combat gains summary names the last kill")
		_assert(combat_gains_text.contains("+1 mana"), "combat gains summary shows kill mana")

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
