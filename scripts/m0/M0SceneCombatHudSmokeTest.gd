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
	var action_status_label = scene.find_child("ActionStatusLabel", true, false)
	var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
	var tactical_hint_label = scene.find_child("WaveTacticalHintLabel", true, false)
	var call_next_button = scene.find_child("CallNextButton", true, false)
	var use_best_target_button = scene.find_child("UseBestTargetButton", true, false)

	_assert(resource_label != null, "resource status label is present")
	_assert(stack_risk_label != null, "stack risk label is present")
	_assert(action_status_label != null, "action status label is present")
	_assert(wave_readiness_label != null, "wave readiness label is present")
	_assert(tactical_hint_label != null, "wave tactical hint label is present")
	_assert(call_next_button != null, "pull next wave button is present")
	_assert(use_best_target_button != null, "use best target button is present")

	m0_scene._on_begin_run_pressed()
	await process_frame

	_assert(m0_scene.run_started, "begin run starts the M0 scene")
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
		var action_text = str(action_status_label.text)
		_assert(action_text.contains("Start wave=Ready"), "action status shows start wave readiness")
		_assert(action_text.contains("Step=Wave not active"), "action status shows inactive step state")

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
