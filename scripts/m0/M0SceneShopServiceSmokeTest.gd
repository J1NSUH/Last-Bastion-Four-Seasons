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

	m0_scene._on_begin_run_pressed()
	await process_frame
	_assert(m0_scene.run_started, "shop service UI test begins a run")

	m0_scene.simulation.debug_generate_shop_offer(10)
	_assert(bool(m0_scene.simulation.debug_set_base_hp(95).get("ok", false)), "shop service UI test can damage the base")
	_assert(bool(m0_scene.simulation.debug_set_gold(4).get("ok", false)), "shop service UI test can fund base recovery")
	m0_scene._refresh_screen()
	await process_frame

	_assert(m0_scene.simulation.get_shop_service_offer().has("m0_restore_base_3"), "shop service offer includes base recovery")
	var restore_option_index = _shop_option_index_for_service(m0_scene, "m0_restore_base_3")
	_assert(restore_option_index >= 0, "restore service option index is available")
	var restore_option = scene.find_child("ShopOption%s" % restore_option_index, true, false)
	_assert(restore_option != null, "restore service button is present")
	if restore_option != null:
		_assert(restore_option.visible, "restore service button is visible")
		_assert(not restore_option.disabled, "restore service button is enabled")
		_assert(str(restore_option.text).contains("Buy"), "restore service button shows buy action")
		_assert(str(restore_option.text).contains("Restore Base"), "restore service button names base recovery")
		_assert(str(restore_option.tooltip_text).contains("Service"), "restore service tooltip marks service type")
		_assert(str(restore_option.tooltip_text).contains("Ready"), "restore service tooltip shows ready state")
		restore_option.pressed.emit()
		await process_frame

		_assert(m0_scene.simulation.get_base_hp() == 98, "restore service button heals base hp")
		_assert(m0_scene.simulation.get_shop_offer().is_empty(), "restore service button clears deck trim offers")
		_assert(m0_scene.simulation.get_shop_service_offer().is_empty(), "restore service button clears service offers")
		var service_log = m0_scene.debug_log.to_text_filtered("", false)
		_assert(service_log.contains("Shop service bought:"), "restore service button logs purchase")
		_assert(service_log.contains("Shop choice trace:"), "restore service button records choice trace")
		var wave_preview_label = scene.find_child("WavePreviewLabel", true, false)
		var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
		_assert(wave_preview_label != null, "wave preview label is present after shop service")
		_assert(wave_readiness_label != null, "wave readiness label is present after shop service")
		if wave_preview_label != null:
			_assert(str(wave_preview_label.text).contains("Maintenance memo"), "wave preview carries shop service into next wave")
			_assert(str(wave_preview_label.text).contains("Restore Base"), "wave preview names the bought service")
		if wave_readiness_label != null:
			_assert(str(wave_readiness_label.text).contains("Maintenance memo"), "wave readiness carries shop service into next wave")
			_assert(str(wave_readiness_label.text).contains("base 95 -> 98"), "wave readiness shows base recovery effect")

	m0_scene._on_reset_pressed()
	await process_frame
	m0_scene._on_player_count_pressed(2)
	await process_frame
	m0_scene._on_begin_run_pressed()
	await process_frame
	_assert(m0_scene.run_started and m0_scene.player_count == 2, "shop service vote UI test begins a two-player run")
	m0_scene.simulation.debug_generate_shop_offer(10)
	_assert(bool(m0_scene.simulation.debug_set_base_hp(95).get("ok", false)), "shop service vote UI test can damage the base")
	_assert(bool(m0_scene.simulation.debug_set_gold(4).get("ok", false)), "shop service vote UI test can fund base recovery")
	m0_scene._refresh_screen()
	await process_frame

	var multi_restore_option_index = _shop_option_index_for_service(m0_scene, "m0_restore_base_3")
	_assert(multi_restore_option_index >= 0, "two-player restore service option index is available")
	var multi_restore_option = scene.find_child("ShopOption%s" % multi_restore_option_index, true, false)
	_assert(multi_restore_option != null, "two-player restore service button is present")
	if multi_restore_option != null:
		_assert(not multi_restore_option.disabled, "two-player restore service button starts enabled")
		multi_restore_option.pressed.emit()
		await process_frame

		_assert(m0_scene.simulation.has_active_shop_purchase_vote(), "first two-player restore click opens a shop vote")
		_assert(m0_scene.simulation.get_base_hp() == 95, "shop vote start does not heal base immediately")
		_assert(str(multi_restore_option.text).contains("Approve Buy"), "active shop vote button changes to approve buy")
		_assert(str(multi_restore_option.text).contains("Vote 1/2"), "active shop vote button shows approval count")
		_assert(str(multi_restore_option.tooltip_text).contains("Active vote"), "active shop vote tooltip explains vote state")
		_assert(str(m0_scene.shop_status_label.text).contains("Shop vote:"), "shop status label shows the active vote")
		_assert(str(m0_scene.skip_shop_button.text).contains("Hold shop vote"), "skip shop button becomes hold vote during active vote")
		var vote_start_log = m0_scene.debug_log.to_text_filtered("", false)
		_assert(vote_start_log.contains("Shop purchase vote started"), "shop vote start is logged")
		_assert(vote_start_log.contains("shop_purchase_vote:"), "shop vote trace is logged")

		multi_restore_option.pressed.emit()
		await process_frame

		_assert(not m0_scene.simulation.has_active_shop_purchase_vote(), "second two-player restore click clears the shop vote")
		_assert(m0_scene.simulation.get_base_hp() == 98, "passed shop vote buys restore service")
		var vote_pass_log = m0_scene.debug_log.to_text_filtered("", false)
		_assert(vote_pass_log.contains("Shop purchase vote passed"), "shop vote pass is logged")
		_assert(vote_pass_log.contains("Shop service bought:"), "shop purchase occurs after vote pass")

	m0_scene._on_reset_pressed()
	await process_frame
	m0_scene._on_begin_run_pressed()
	await process_frame
	_assert(m0_scene.run_started, "reactivation shop service UI test begins a fresh run")
	_seed_dormant_artifact(m0_scene)
	m0_scene.simulation.debug_generate_shop_offer(10)
	_assert(m0_scene.simulation.get_shop_service_offer().has("m0_reactivate_dormant_artifact"), "reactivation service appears when dormant artifacts exist")
	_assert(bool(m0_scene.simulation.debug_set_boss_shards(1).get("ok", false)), "reactivation service UI test can fund boss shards")
	m0_scene._refresh_screen()
	await process_frame

	var reactivation_option_index = _shop_option_index_for_service(m0_scene, "m0_reactivate_dormant_artifact")
	_assert(reactivation_option_index >= 0, "reactivation service option index is available")
	var reactivation_option = scene.find_child("ShopOption%s" % reactivation_option_index, true, false)
	_assert(reactivation_option != null, "reactivation service button is present")
	if reactivation_option != null:
		_assert(reactivation_option.visible, "reactivation service button is visible")
		_assert(reactivation_option.disabled, "reactivation service waits for a dormant target")
		_assert(str(reactivation_option.text).contains("Boss shards"), "reactivation service button shows boss shard cost")
		_assert(str(reactivation_option.text).contains("Action:"), "reactivation service button shows artifact action cost")
		_assert(str(reactivation_option.text).contains("Reactivate Dormant"), "reactivation service button names dormant reactivation")
		_assert(str(reactivation_option.text).contains("Choose dormant"), "reactivation service button asks for a dormant target")
		var dormant_option = scene.find_child("ShopReactivateDormantOption0", true, false)
		_assert(dormant_option != null, "reactivation dormant target button is present")
		if dormant_option != null:
			_assert(dormant_option.visible, "reactivation dormant target button is visible")
			_assert(str(dormant_option.text).contains("Effect off -> on"), "reactivation dormant target button explains effect state")
			dormant_option.pressed.emit()
			await process_frame

		_assert(reactivation_option.disabled, "reactivation service waits for a swap target when artifact slots are full")
		_assert(str(reactivation_option.text).contains("Choose swap"), "reactivation service button asks for an equipped swap target")
		var replace_option = scene.find_child("ShopReactivateReplaceOption0", true, false)
		_assert(replace_option != null, "reactivation equipped swap button is present")
		if replace_option != null:
			_assert(replace_option.visible, "reactivation equipped swap button is visible")
			_assert(str(replace_option.text).contains("Reactivate"), "reactivation equipped swap button names the returning artifact")
			replace_option.pressed.emit()
			await process_frame

		_assert(not reactivation_option.disabled, "reactivation service button is enabled after both targets are chosen")
		_assert(str(reactivation_option.tooltip_text).contains("boss shard"), "reactivation service tooltip shows boss shard cost")
		_assert(str(reactivation_option.tooltip_text).contains("artifact action"), "reactivation service tooltip shows artifact action cost")
		reactivation_option.pressed.emit()
		await process_frame

		_assert(m0_scene.simulation.get_boss_shards() == 0, "reactivation service button spends boss shard")
		_assert(m0_scene.simulation.get_artifact_actions_remaining() == 0, "reactivation service button spends artifact action")
		var reactivation_report: Dictionary = m0_scene.simulation.get_last_shop_report()
		_assert(str(reactivation_report.get("service_type", "")) == "reactivate_dormant_artifact", "reactivation service stores last shop report")
		_assert(not str(reactivation_report.get("reactivated_artifact_label", "")).is_empty(), "reactivation report names restored artifact")
		var reactivation_log = m0_scene.debug_log.to_text_filtered("", false)
		_assert(reactivation_log.contains("Boss shards: 1 -> 0"), "reactivation service logs boss shard spend")
		_assert(reactivation_log.contains("Artifact action: 1 -> 0"), "reactivation service logs artifact action spend")
		_assert(reactivation_log.contains("reactivated"), "reactivation service logs restored artifact")
		var reactivation_wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
		_assert(reactivation_wave_readiness_label != null, "wave readiness label is present after reactivation")
		if reactivation_wave_readiness_label != null:
			_assert(str(reactivation_wave_readiness_label.text).contains("Maintenance memo"), "wave readiness carries reactivation service into next wave")
			_assert(str(reactivation_wave_readiness_label.text).contains("boss shards 1 -> 0"), "wave readiness shows boss shard spend")

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


func _shop_option_index_for_service(m0_scene, service_id: String) -> int:
	var option_reports = m0_scene.simulation.get_shop_option_reports(m0_scene.player_count, m0_scene.selected_class_id)
	for index in range(option_reports.size()):
		var report: Dictionary = option_reports[index]
		if str(report.get("service_id", "")) == service_id:
			return index

	return -1


func _seed_dormant_artifact(m0_scene) -> void:
	m0_scene.simulation.debug_generate_artifact_offer()
	_assert(bool(m0_scene.simulation.claim_artifact("m0_deep_pockets").get("ok", false)), "reactivation seed equips first artifact")
	m0_scene.simulation.debug_generate_artifact_offer()
	_assert(bool(m0_scene.simulation.claim_artifact("m0_seed_core").get("ok", false)), "reactivation seed equips second artifact")
	m0_scene.simulation.debug_generate_artifact_offer()
	_assert(bool(m0_scene.simulation.claim_artifact("m0_mana_coil").get("ok", false)), "reactivation seed equips third artifact")
	m0_scene.simulation.debug_generate_artifact_offer()
	_assert(bool(m0_scene.simulation.replace_artifact("m0_deep_pockets", "m0_draw_lens").get("ok", false)), "reactivation seed creates a dormant artifact")
