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

	_assert(bool(m0_scene._debug_clear_alpha_manual_review_save().get("ok", false)), "shop artifact test starts with clean alpha review data")
	_seed_alpha_recommendation_issue(m0_scene)
	m0_scene._on_begin_run_pressed()
	await process_frame
	_assert(m0_scene.run_started, "shop artifact UI test begins a run")

	m0_scene.simulation.debug_generate_artifact_offer()
	m0_scene._refresh_screen()
	await process_frame
	_assert(not m0_scene.simulation.get_artifact_offer().is_empty(), "artifact offer can be generated")

	var artifact_option = scene.find_child("ArtifactOption0", true, false)
	_assert(artifact_option != null, "artifact option button is present")
	if artifact_option != null:
		_assert(artifact_option.visible, "artifact option button is visible")
		_assert(str(artifact_option.text).contains("Equip"), "artifact option shows equip action")
		_assert(str(artifact_option.tooltip_text).contains("party passive"), "artifact option tooltip explains passive")

	var artifact_recommendation = m0_scene.simulation.get_artifact_recommendation_report()
	_assert(bool(artifact_recommendation.get("ok", false)), "artifact recommendation is available")
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
			_assert(m0_scene.simulation.get_artifact_offer().is_empty(), "suggested artifact choice resolves the artifact offer")
			var artifact_choice_trace_log = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(artifact_choice_trace_log.contains("Artifact choice trace:"), "artifact choice records a choice trace")
			_assert(artifact_choice_trace_log.contains("followed suggestion"), "artifact choice trace records followed suggestion state")
			_assert(artifact_choice_trace_log.contains("Why now:"), "artifact choice trace keeps recommendation context")
			var wave_preview_label = scene.find_child("WavePreviewLabel", true, false)
			var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
			_assert(wave_preview_label != null, "wave preview label is present after artifact choice")
			_assert(wave_readiness_label != null, "wave readiness label is present after artifact choice")
			if wave_preview_label != null:
				_assert(str(wave_preview_label.text).contains("Artifact memo"), "wave preview carries artifact choice into next wave")
				_assert(str(wave_preview_label.text).contains(str(artifact_recommendation.get("label", ""))), "wave preview names the equipped artifact")
			if wave_readiness_label != null:
				_assert(str(wave_readiness_label.text).contains("Artifact memo"), "wave readiness carries artifact choice into next wave")
				_assert(str(wave_readiness_label.text).contains("Next R"), "wave readiness ties artifact memo to the next round")

	m0_scene.simulation.debug_generate_artifact_offer()
	m0_scene._refresh_screen()
	await process_frame
	_assert(m0_scene.simulation.get_artifact_offer().has("m0_mana_coil"), "artifact replacement test can offer a third passive")
	_assert(bool(m0_scene.simulation.claim_artifact("m0_mana_coil").get("ok", false)), "artifact replacement test equips the second passive")
	m0_scene.simulation.debug_generate_artifact_offer()
	m0_scene._refresh_screen()
	await process_frame
	_assert(m0_scene.simulation.get_artifact_offer().has("m0_draw_lens"), "artifact replacement test can offer a final slot passive")
	_assert(bool(m0_scene.simulation.claim_artifact("m0_draw_lens").get("ok", false)), "artifact replacement test fills the artifact slots")
	m0_scene.simulation.debug_generate_artifact_offer()
	m0_scene._refresh_screen()
	await process_frame
	var full_slot_option = scene.find_child("ArtifactOption0", true, false)
	_assert(full_slot_option != null, "full-slot artifact option is present")
	if full_slot_option != null:
		_assert(str(full_slot_option.text).contains("Replace"), "full-slot artifact option asks for replacement")
		var keep_current_button = scene.find_child("ArtifactKeepCurrentButton", true, false)
		_assert(keep_current_button != null, "artifact keep-current button is present")
		if keep_current_button != null:
			_assert(keep_current_button.visible, "artifact keep-current button is visible beside a full-slot offer")
			_assert(str(keep_current_button.text).contains("Keep current"), "artifact keep-current button names the neutral choice")
		full_slot_option.pressed.emit()
		await process_frame
		var replace_option = scene.find_child("ArtifactReplaceOption0", true, false)
		_assert(replace_option != null, "artifact replacement target button is present")
		if replace_option != null:
			_assert(replace_option.visible, "artifact replacement target button becomes visible")
			_assert(str(replace_option.text).contains("Replace"), "artifact replacement target button names replacement")
			_assert(str(replace_option.tooltip_text).contains("becomes dormant"), "artifact replacement tooltip explains dormant move")
			if keep_current_button != null:
				_assert(str(keep_current_button.text).contains("Decline"), "artifact keep-current button names the declined full-slot offer")
				_assert(str(keep_current_button.tooltip_text).contains("valid"), "artifact keep-current tooltip frames no-change as valid")
			var replaced_artifact_id = str(m0_scene.simulation.get_equipped_artifacts()[0])
			replace_option.pressed.emit()
			await process_frame
			_assert(m0_scene.simulation.get_artifact_offer().is_empty(), "artifact replacement resolves the offer")
			_assert(m0_scene.simulation.get_dormant_artifacts().has(replaced_artifact_id), "artifact replacement moves chosen equipped artifact to dormant")
			var artifact_replace_log = m0_scene.debug_log.to_text("all", false)
			_assert(artifact_replace_log.contains("Artifact replaced:"), "artifact replacement writes a visible log")

	m0_scene.simulation.debug_generate_artifact_offer()
	m0_scene._refresh_screen()
	await process_frame
	var keep_offer_option = scene.find_child("ArtifactOption0", true, false)
	var keep_current_after_replace = scene.find_child("ArtifactKeepCurrentButton", true, false)
	_assert(keep_offer_option != null, "post-replacement artifact option is present")
	if keep_offer_option != null:
		keep_offer_option.pressed.emit()
		await process_frame
		_assert(keep_current_after_replace != null, "post-replacement keep-current button is present")
		if keep_current_after_replace != null:
			_assert(keep_current_after_replace.visible, "post-replacement keep-current button is visible")
			keep_current_after_replace.pressed.emit()
			await process_frame
			_assert(m0_scene.simulation.get_artifact_offer().is_empty(), "keep-current artifact choice resolves the offer")
			_assert(str(m0_scene.simulation.get_last_artifact_report().get("artifact_action_type", "")) == "skip", "keep-current artifact choice stores a skip report")
			var artifact_keep_log = m0_scene.debug_log.to_text("all", false)
			_assert(artifact_keep_log.contains("Artifact kept current:"), "keep-current artifact choice writes a visible log")

	m0_scene.simulation.debug_generate_artifact_offer()
	m0_scene._refresh_screen()
	await process_frame
	var second_replace_offer_option = scene.find_child("ArtifactOption0", true, false)
	_assert(second_replace_offer_option != null, "second replacement artifact option is present")
	if second_replace_offer_option != null:
		second_replace_offer_option.pressed.emit()
		await process_frame
		var second_replace_option = scene.find_child("ArtifactReplaceOption0", true, false)
		_assert(second_replace_option != null, "second artifact replacement target button is present")
		if second_replace_option != null:
			_assert(not second_replace_option.disabled, "second artifact replacement target is enabled while dormant storage has room")
			second_replace_option.pressed.emit()
			await process_frame
			var filled_slot_report: Dictionary = m0_scene.simulation.get_artifact_slot_report()
			_assert(
				int(filled_slot_report.get("dormant_count", 0)) == int(filled_slot_report.get("dormant_limit", 0)),
				"second replacement fills dormant artifact storage"
			)

	m0_scene.simulation.debug_generate_artifact_offer()
	m0_scene._refresh_screen()
	await process_frame
	var release_offer_option = scene.find_child("ArtifactOption0", true, false)
	_assert(release_offer_option != null, "release-required artifact option is present")
	if release_offer_option != null:
		release_offer_option.pressed.emit()
		await process_frame
		var blocked_replace_option = scene.find_child("ArtifactReplaceOption0", true, false)
		var release_option = scene.find_child("ArtifactReleaseOption0", true, false)
		_assert(blocked_replace_option != null, "release-required replacement target button is present")
		_assert(release_option != null, "dormant release option button is present")
		if blocked_replace_option != null:
			_assert(blocked_replace_option.disabled, "replacement target waits for a dormant release when storage is full")
			_assert(str(blocked_replace_option.tooltip_text).contains("Release one dormant artifact first"), "blocked replacement tooltip asks for a release")
		if release_option != null:
			_assert(release_option.visible, "dormant release option is visible")
			_assert(str(release_option.text).contains("Release"), "dormant release option names the release action")
			_assert(str(release_option.tooltip_text).contains("no refund"), "dormant release tooltip states no refund")
			release_option.pressed.emit()
			await process_frame
			_assert(str(release_option.text).contains("Selected release"), "dormant release option marks the selected release")
			if blocked_replace_option != null:
				_assert(not blocked_replace_option.disabled, "replacement target unlocks after selecting a dormant release")
				blocked_replace_option.pressed.emit()
				await process_frame
				var release_replace_report: Dictionary = m0_scene.simulation.get_last_artifact_report()
				_assert(bool(release_replace_report.get("dormant_released", false)), "released replacement report records dormant release")
				var artifact_release_log = m0_scene.debug_log.to_text("all", false)
				_assert(artifact_release_log.contains("released with no refund"), "released replacement writes a no-refund log")

	m0_scene.simulation.debug_generate_shop_offer(10)
	_assert(bool(m0_scene.simulation.debug_set_gold(m0_scene.simulation.get_shop_deck_removal_gold_cost()).get("ok", false)), "shop artifact test can fund one deck trim")
	m0_scene._refresh_screen()
	await process_frame
	_assert(not m0_scene.simulation.get_shop_offer().is_empty(), "shop offer can be generated")

	var shop_option = scene.find_child("ShopOption0", true, false)
	_assert(shop_option != null, "shop option button is present")
	if shop_option != null:
		_assert(shop_option.visible, "shop option button is visible")
		_assert(str(shop_option.text).contains("Remove"), "shop option shows remove action")
		_assert(str(shop_option.tooltip_text).contains("Blocked:") or str(shop_option.tooltip_text).contains("Ready"), "shop option tooltip shows availability")

	var shop_recommendation = m0_scene.simulation.get_shop_recommendation_report(m0_scene.player_count, m0_scene.selected_class_id)
	_assert(bool(shop_recommendation.get("ok", false)), "shop recommendation is available")
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
			_assert(m0_scene.simulation.get_shop_offer().is_empty(), "suggested shop choice resolves the shop offer")
			var shop_choice_trace_log = m0_scene.debug_log.to_text_filtered("system", false)
			_assert(shop_choice_trace_log.contains("Shop choice trace:"), "shop choice records a choice trace")
			_assert(shop_choice_trace_log.contains("followed suggestion"), "shop choice trace records followed suggestion state")
			_assert(shop_choice_trace_log.contains("Why now:"), "shop choice trace keeps recommendation context")

	root.remove_child(scene)
	scene.queue_free()
	await process_frame

	quit(1 if failed else 0)


func _seed_alpha_recommendation_issue(m0_scene) -> void:
	m0_scene._set_autoplay_focus_queue({
		"alpha_focus_queue": [
			{
				"rank": 1,
				"class_id": "guardian",
				"class_label": "Guardian",
				"player_count": 1,
				"direction": "east",
				"primary_signal": "shop artifact wording",
				"evidence": "suggestion reads like an auto-pick",
				"next_probe": "check choice wording",
				"completed_rounds": 10,
				"base_hp": 30,
			},
		],
		"next_action_queue": [],
	})
	var focus_entry: Dictionary = m0_scene.last_autoplay_focus_queue[0]
	var focus_key = m0_scene._alpha_focus_entry_key(focus_entry)
	m0_scene.alpha_focus_manual_review_results[focus_key] = {
		"status": "manual_issue",
		"badge": "ISSUE",
		"summary": "recommendation wording needs softer alternatives",
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


func _assert(condition: bool, label: String) -> void:
	if condition:
		print("[PASS] %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	failed = true
	push_error("[FAIL] %s" % label)
