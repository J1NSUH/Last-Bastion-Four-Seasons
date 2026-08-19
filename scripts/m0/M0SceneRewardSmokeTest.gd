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

	var action_status_label = scene.find_child("ActionStatusLabel", true, false)
	var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
	_assert(action_status_label != null, "action status label is present")
	_assert(wave_readiness_label != null, "wave readiness label is present")

	_assert(bool(m0_scene._debug_clear_alpha_manual_review_save().get("ok", false)), "alpha manual review save starts clean")
	m0_scene._on_begin_run_pressed()
	await process_frame
	_assert(m0_scene.run_started, "reward UI test begins a run")

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
