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
	var use_best_target_button = scene.find_child("UseBestTargetButton", true, false)
	var risk_ping_button = scene.find_child("RiskPingButton0", true, false)
	_assert(tactical_hint_label != null, "wave tactical hint label is present")
	_assert(use_best_target_button != null, "use best target button is present")
	_assert(risk_ping_button != null, "first risk ping button is present")

	m0_scene.selected_class_id = "architect"
	m0_scene._on_begin_run_pressed()
	await process_frame
	_assert(m0_scene.run_started, "planned collapse test begins an architect run")
	_assert(m0_scene.selected_class_id == "architect", "planned collapse test keeps architect class")

	var setup_report = m0_scene._setup_plan_action_report()
	var collapse_tile: Vector2i = setup_report.get("tile", Vector2i(14, 14))
	if not m0_scene._is_valid_tile(collapse_tile):
		collapse_tile = Vector2i(14, 14)

	_assert(bool(m0_scene.simulation.debug_place_structure(collapse_tile, "barricade", "architect").get("ok", false)), "planned collapse barricade can be placed")
	var collapse_structure: Dictionary = m0_scene.simulation.get_structure_tiles().get(m0_scene._tile_key(collapse_tile), {})
	var collapse_damage_needed = max(0, int(collapse_structure.get("hp", 0)) - 7)
	_assert(bool(m0_scene.simulation.debug_damage_structure(collapse_tile, collapse_damage_needed).get("ok", false)), "planned collapse barricade can be set near breaking")
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
	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_field_patch"]).get("ok", false)), "planned collapse repair-only hand can be set")
	_assert(bool(m0_scene.simulation.debug_spawn_enemy(breaker_spawn, 8, "east", "m0_breaker").get("ok", false)), "planned collapse breaker can be spawned")
	m0_scene._refresh_screen()
	await process_frame

	var collapse_line = m0_scene._structure_threat_timing_line()
	_assert(collapse_line.contains("will break"), "structure threat line warns before the next hit breaks a structure")
	_assert(collapse_line.contains("planned collapse"), "structure threat line explains architect planned collapse value")
	if tactical_hint_label != null:
		var tactical_text = str(tactical_hint_label.text)
		_assert(tactical_text.contains("planned collapse"), "tactical hint repeats planned collapse value")
		_assert(tactical_text.contains("Risk pings:"), "tactical hint keeps risk ping context during planned collapse")
		_assert(tactical_text.contains("candidate only"), "risk ping wording stays candidate-only during planned collapse")
		_assert(tactical_text.contains("Hold sacrifice") or tactical_text.contains("Rear rebuild"), "planned collapse risk pings include sacrifice or rebuild choices")
	if risk_ping_button != null:
		_assert(risk_ping_button.visible, "risk ping button appears for planned collapse")
		_assert(str(risk_ping_button.text).contains("Hold sacrifice") or str(risk_ping_button.text).contains("Rear rebuild"), "risk ping button shows a planned collapse choice")

	var planned_hold_report = m0_scene._best_target_action_report()
	_assert(not bool(planned_hold_report.get("ok", false)), "quick hand action holds repair that would erase planned collapse")
	_assert(str(planned_hold_report.get("reason", "")) == "planned_collapse_preserved", "quick hand action explains planned collapse preservation")
	if use_best_target_button != null:
		_assert(use_best_target_button.disabled, "use best target button disables when only repair would erase planned collapse")
		_assert(str(use_best_target_button.tooltip_text).contains("planned collapse"), "use best target tooltip explains the held repair")

	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_field_patch", "m0_arc_spark"]).get("ok", false)), "planned collapse mixed hand can be set")
	m0_scene.selected_card_index = -1
	m0_scene._refresh_screen()
	await process_frame
	var planned_damage_report = m0_scene._best_target_action_report()
	_assert(bool(planned_damage_report.get("ok", false)), "quick hand action still finds a non-repair answer during planned collapse")
	_assert(str(planned_damage_report.get("card_id", "")) == "m0_arc_spark", "quick hand action prefers damage over erasing planned collapse")
	_assert(planned_damage_report.get("tile", Vector2i.ZERO) == breaker_spawn, "quick hand action aims damage at the attacker preserving collapse")
	_assert(bool(planned_damage_report.get("tactical", false)), "planned collapse damage answer is marked tactical")

	_assert(bool(m0_scene.simulation.debug_set_hand(["m0_field_patch"]).get("ok", false)), "planned collapse repair selected hand can be set")
	m0_scene.selected_card_index = -1
	m0_scene._refresh_screen()
	await process_frame
	m0_scene._on_card_slot_pressed(0)
	await process_frame
	var repair_selected_label = scene.find_child("SelectedCardStatusLabel", true, false)
	_assert(repair_selected_label != null, "planned collapse selected card label is present")
	if repair_selected_label != null:
		_assert(str(repair_selected_label.text).contains("planned collapse"), "repair card timing warns that repair prevents planned collapse")

	m0_scene.selected_tile = collapse_tile
	m0_scene._refresh_selected_tile()
	await process_frame
	if m0_scene.selected_label != null:
		_assert(str(m0_scene.selected_label.text).contains("planned collapse"), "selected structure report includes planned collapse risk")

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
