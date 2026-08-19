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

	var tactical_hint_label = scene.find_child("WaveTacticalHintLabel", true, false)
	var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
	var use_best_target_button = scene.find_child("UseBestTargetButton", true, false)
	var risk_ping_button = scene.find_child("RiskPingButton0", true, false)

	_assert(tactical_hint_label != null, "wave tactical hint label is present")
	_assert(wave_readiness_label != null, "wave readiness label is present")
	_assert(use_best_target_button != null, "use best target button is present")
	_assert(risk_ping_button != null, "first risk ping button is present")
	if risk_ping_button != null:
		_assert(not risk_ping_button.visible, "risk ping button starts hidden before a live threat")

	m0_scene._on_begin_run_pressed()
	await process_frame
	m0_scene._on_start_wave_pressed()
	m0_scene.wave_timer.stop()
	await process_frame

	_run_repair_risk_ping_checks(scene, m0_scene, tactical_hint_label, wave_readiness_label, use_best_target_button, risk_ping_button)
	_run_boss_warning_checks(scene, m0_scene, use_best_target_button)

	root.remove_child(scene)
	scene.queue_free()
	await process_frame

	quit(1 if failed else 0)


func _run_repair_risk_ping_checks(
	scene: Node,
	m0_scene,
	tactical_hint_label,
	wave_readiness_label,
	use_best_target_button,
	risk_ping_button
) -> void:
	var repair_tile = Vector2i(14, 14)
	_assert(bool(m0_scene.simulation.debug_place_structure(repair_tile, "barricade", m0_scene.selected_class_id).get("ok", false)), "repair timing target structure can be placed")
	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_field_patch"]).get("ok", false)), "repair timing hand can be set")
	_assert(bool(m0_scene.simulation.debug_spawn_enemy(Vector2i(14, 15), 6, "east", "m0_walker").get("ok", false)), "repair timing enemy can be spawned")
	m0_scene._refresh_screen()
	await process_frame
	m0_scene._on_card_slot_pressed(0)
	await process_frame

	var repair_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
	_assert(repair_selected_label != null, "repair selected card status label is present")
	if repair_selected_label != null:
		_assert(str(repair_selected_label.text).contains("hold until after hit"), "repair card explains waiting for incoming structure damage")
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

	_assert(bool(m0_scene.simulation.debug_damage_structure(repair_tile, 6).get("ok", false)), "repair target structure can be damaged")
	m0_scene._refresh_screen()
	await process_frame

	var repair_best_report = m0_scene._best_target_action_report()
	_assert(bool(repair_best_report.get("ok", false)), "repair best target becomes available once the threatened structure is damaged")
	_assert(str(repair_best_report.get("card_id", "")) == "m0_field_patch", "repair best target keeps the repair card")
	_assert(repair_best_report.get("tile", Vector2i.ZERO) == repair_tile, "repair best target aims at the damaged threatened structure")
	_assert(bool(repair_best_report.get("tactical", false)), "repair best target marks the tactical repair match")

	if use_best_target_button != null:
		var structure_before_repair: Dictionary = m0_scene.simulation.get_structure_tiles().get(m0_scene._tile_key(repair_tile), {})
		var hp_before_repair = int(structure_before_repair.get("hp", 0))
		use_best_target_button.pressed.emit()
		await process_frame
		var structure_after_repair: Dictionary = m0_scene.simulation.get_structure_tiles().get(m0_scene._tile_key(repair_tile), {})
		_assert(int(structure_after_repair.get("hp", 0)) > hp_before_repair, "use best target repairs the damaged threatened structure")
		_assert(m0_scene._selected_card_id().is_empty(), "repair quick action clears selected card after play")


func _run_boss_warning_checks(scene: Node, m0_scene, use_best_target_button) -> void:
	m0_scene._on_reset_pressed()
	await process_frame
	m0_scene._on_begin_run_pressed()
	await process_frame
	m0_scene._on_start_wave_pressed()
	m0_scene.wave_timer.stop()
	await process_frame

	var boss_warning_structure_tile = Vector2i(18, 9)
	_assert(bool(m0_scene.simulation.debug_place_structure(boss_warning_structure_tile, "tower", m0_scene.selected_class_id).get("ok", false)), "boss warning target structure can be placed")
	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_arc_spark"]).get("ok", false)), "boss warning damage hand can be set")
	_assert(bool(m0_scene.simulation.debug_spawn_enemy(Vector2i(18, 10), 6, "east", "m0_walker").get("ok", false)), "boss warning normal enemy can be spawned")
	_assert(bool(m0_scene.simulation.debug_spawn_enemy(Vector2i(20, 10), -1, "east", "m0_colossus").get("ok", false)), "boss warning boss can be spawned")
	m0_scene._refresh_screen()
	await process_frame

	var boss_warning_report = m0_scene.simulation.get_boss_part_warning_report(m0_scene.player_count)
	_assert(bool(boss_warning_report.get("ok", false)), "boss warning scenario exposes a boss part warning")

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

	if use_best_target_button != null:
		use_best_target_button.pressed.emit()
		await process_frame
		var boss_warning_log_text = m0_scene.debug_log.to_text_filtered("combat", true)
		_assert(boss_warning_log_text.contains("Boss warning response"), "important combat log records the boss warning response")
		_assert(boss_warning_log_text.contains("Boss answer"), "important combat log records the boss warning response type")
		var answered_probe_status = m0_scene._format_alpha_probe_status()
		_assert(answered_probe_status.contains("Boss answer"), "alpha focus probe replaces pending boss warning after response")
	m0_scene.active_alpha_probe_entry.clear()

	_assert(bool(m0_scene.simulation.debug_damage_structure(boss_warning_structure_tile, 2).get("ok", false)), "boss warning target structure can be damaged")
	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_field_patch"]).get("ok", false)), "boss warning repair hand can be set")
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
	var repair_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
	if repair_selected_label != null:
		_assert(str(repair_selected_label.text).contains("boss warning target"), "repair selected card timing explains boss warning repair")

	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_barricade_kit"]).get("ok", false)), "boss warning barricade hand can be set")
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


func _assert(condition: bool, label: String) -> void:
	if condition:
		print("[PASS] %s" % label)
	else:
		_fail(label)


func _fail(label: String) -> void:
	failed = true
	push_error("[FAIL] %s" % label)
