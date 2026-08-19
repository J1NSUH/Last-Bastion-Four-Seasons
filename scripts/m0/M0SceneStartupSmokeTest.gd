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
		_assert(not str(stack_risk_label.text).contains("bonus"), "stack risk label avoids bonus wording before run")

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
		_assert(setup_wave_preview_text.contains("Spawn timing R1"), "wave preview shows spawn timing")
		_assert(setup_wave_preview_text.contains("0s east Walker"), "wave preview spawn timing names the first packet")

	var tactical_hint_label = scene.find_child("WaveTacticalHintLabel", true, false)
	_assert(tactical_hint_label != null, "wave tactical hint label is present")
	if tactical_hint_label != null:
		_assert(str(tactical_hint_label.text).contains("begin the run first"), "wave tactical hint explains setup lock")

	var wave_readiness_label = scene.find_child("WaveReadinessLabel", true, false)
	_assert(wave_readiness_label != null, "wave readiness label is present")
	if wave_readiness_label != null:
		_assert(str(wave_readiness_label.text).contains("begin the run first"), "wave readiness explains setup lock")

	var call_next_button = scene.find_child("CallNextButton", true, false)
	_assert(call_next_button != null, "pull next wave button is present")
	if call_next_button != null:
		_assert(str(call_next_button.text).contains("Pull next wave"), "pull next wave button uses tempo copy")

	var hold_stack_button = scene.find_child("HoldStackButton", true, false)
	_assert(hold_stack_button != null, "hold pull button is present")
	if hold_stack_button != null:
		_assert(str(hold_stack_button.text).contains("Hold pull"), "hold pull button uses tempo copy")

	if m0_scene != null and m0_scene.map_view != null:
		_assert(m0_scene.map_view.debug_spawn_warning_label(Vector2i(20, 10)) == ">", "map marks the next solo east spawn at the active entrance")
		_assert(m0_scene.map_view.debug_spawn_warning_label(Vector2i(10, 0)).is_empty(), "map does not warn inactive north entrance in solo")

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
