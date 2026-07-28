extends Control

const M0CombatSimulationScript = preload("res://scripts/m0/M0CombatSimulation.gd")
const M0AutoplayRunnerScript = preload("res://scripts/m0/M0AutoplayRunner.gd")
const M0DebugLogScript = preload("res://scripts/m0/M0DebugLog.gd")
const M0MapViewScript = preload("res://scripts/m0/M0MapView.gd")
const INVALID_TILE = Vector2i(-1, -1)
const CARD_BUTTON_LIMIT = 10
const REWARD_BUTTON_LIMIT = 3
const ARTIFACT_BUTTON_LIMIT = 2
const SHOP_BUTTON_LIMIT = 4

var simulation: M0CombatSimulation
var debug_log: M0DebugLog
var player_count = 1
var selected_class_id = ""
var build_mode = "none"
var run_started = false
var show_debug_log = true

var status_label: Label
var tutorial_label: Label
var data_label: Label
var wave_preview_label: Label
var front_label: Label
var stack_risk_label: Label
var stats_label: Label
var round_report_label: Label
var outcome_label: Label
var resource_label: Label
var map_view: M0MapView
var tile_label: Label
var preview_label: Label
var selected_label: Label
var reward_status_label: Label
var artifact_status_label: Label
var shop_status_label: Label
var setup_summary_label: Label
var round_recap_panel: PanelContainer
var round_recap_title_label: Label
var round_recap_body_label: Label
var log_label: Label
var auto_step_toggle: CheckButton
var debug_log_toggle: CheckButton
var begin_run_button: Button
var start_wave_button: Button
var stack_wave_button: Button
var hold_stack_button: Button
var step_wave_button: Button
var discard_card_button: Button
var skip_reward_button: Button
var skip_artifact_button: Button
var skip_shop_button: Button
var class_row: HBoxContainer
var wave_timer: Timer
var player_buttons: Array[Button] = []
var class_buttons: Dictionary = {}
var build_buttons: Dictionary = {}
var card_buttons: Array[Button] = []
var reward_buttons: Array[Button] = []
var artifact_buttons: Array[Button] = []
var shop_buttons: Array[Button] = []
var hovered_tile = INVALID_TILE
var selected_tile = INVALID_TILE
var selected_card_index = -1
var preview_tile = INVALID_TILE
var preview_ok = false
var preview_reason = ""


func _ready() -> void:
	simulation = M0CombatSimulationScript.new()
	debug_log = M0DebugLogScript.new()

	_build_layout()
	_load_m0_data()
	_refresh_screen()


func _build_layout() -> void:
	var root = VBoxContainer.new()
	root.name = "M0Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	root.offset_left = 16
	root.offset_top = 16
	root.offset_right = -16
	root.offset_bottom = -16
	add_child(root)

	var header = VBoxContainer.new()
	header.name = "HUDLayer"
	header.add_theme_constant_override("separation", 4)
	root.add_child(header)

	var title = Label.new()
	title.text = "Last Bastion: Four Seasons - M0 Prototype"
	title.add_theme_font_size_override("font_size", 24)
	header.add_child(title)

	status_label = Label.new()
	header.add_child(status_label)

	tutorial_label = Label.new()
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(tutorial_label)

	data_label = Label.new()
	header.add_child(data_label)

	wave_preview_label = Label.new()
	wave_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(wave_preview_label)

	front_label = Label.new()
	header.add_child(front_label)

	stack_risk_label = Label.new()
	stack_risk_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(stack_risk_label)

	stats_label = Label.new()
	header.add_child(stats_label)

	round_report_label = Label.new()
	round_report_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(round_report_label)

	outcome_label = Label.new()
	outcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(outcome_label)

	var body = HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	root.add_child(body)

	var map_panel = PanelContainer.new()
	map_panel.name = "MapLayer"
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(map_panel)

	var map_margin = MarginContainer.new()
	map_margin.add_theme_constant_override("margin_left", 12)
	map_margin.add_theme_constant_override("margin_top", 12)
	map_margin.add_theme_constant_override("margin_right", 12)
	map_margin.add_theme_constant_override("margin_bottom", 12)
	map_panel.add_child(map_margin)

	var map_stack = VBoxContainer.new()
	map_stack.add_theme_constant_override("separation", 8)
	map_margin.add_child(map_stack)

	var map_label = Label.new()
	map_label.text = "Map"
	map_stack.add_child(map_label)

	map_view = M0MapViewScript.new()
	map_view.name = "CombatRoot"
	map_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_view.tile_clicked.connect(_on_tile_pressed)
	map_view.tile_hovered.connect(_on_tile_hovered)
	map_stack.add_child(map_view)

	var legend_label = Label.new()
	legend_label.text = "B base | N/E/S/W entrance | . path | T tower | X barricade | E enemy | > fast | # breaker | A armor | ! boss"
	map_stack.add_child(legend_label)

	var side_panel = PanelContainer.new()
	side_panel.name = "RunPanel"
	side_panel.custom_minimum_size = Vector2(400, 0)
	body.add_child(side_panel)

	var side_margin = MarginContainer.new()
	side_margin.add_theme_constant_override("margin_left", 12)
	side_margin.add_theme_constant_override("margin_top", 12)
	side_margin.add_theme_constant_override("margin_right", 12)
	side_margin.add_theme_constant_override("margin_bottom", 12)
	side_panel.add_child(side_margin)

	var side = VBoxContainer.new()
	side.add_theme_constant_override("separation", 10)
	side_margin.add_child(side)

	var setup_label = Label.new()
	setup_label.text = "Run setup"
	side.add_child(setup_label)

	setup_summary_label = Label.new()
	setup_summary_label.text = "Setup: -"
	setup_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(setup_summary_label)

	begin_run_button = Button.new()
	begin_run_button.text = "Begin run"
	begin_run_button.focus_mode = Control.FOCUS_NONE
	begin_run_button.pressed.connect(_on_begin_run_pressed)
	side.add_child(begin_run_button)

	var player_label = Label.new()
	player_label.text = "Players"
	side.add_child(player_label)

	var player_row = HBoxContainer.new()
	player_row.add_theme_constant_override("separation", 6)
	side.add_child(player_row)

	for count in range(1, 5):
		var button = Button.new()
		button.text = str(count)
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(54, 34)
		button.pressed.connect(_on_player_count_pressed.bind(count))
		player_buttons.append(button)
		player_row.add_child(button)

	var class_label = Label.new()
	class_label.text = "Lead class"
	side.add_child(class_label)

	class_row = HBoxContainer.new()
	class_row.add_theme_constant_override("separation", 6)
	side.add_child(class_row)

	var build_label = Label.new()
	build_label.text = "Build mode"
	side.add_child(build_label)

	var build_row = HBoxContainer.new()
	build_row.add_theme_constant_override("separation", 6)
	side.add_child(build_row)

	var tower_button = Button.new()
	tower_button.text = "Tower"
	tower_button.toggle_mode = true
	tower_button.focus_mode = Control.FOCUS_NONE
	tower_button.pressed.connect(_on_build_mode_pressed.bind("tower"))
	build_buttons["tower"] = tower_button
	build_row.add_child(tower_button)

	var barricade_button = Button.new()
	barricade_button.text = "Barricade"
	barricade_button.toggle_mode = true
	barricade_button.focus_mode = Control.FOCUS_NONE
	barricade_button.pressed.connect(_on_build_mode_pressed.bind("barricade"))
	build_buttons["barricade"] = barricade_button
	build_row.add_child(barricade_button)

	var remove_button = Button.new()
	remove_button.text = "Remove"
	remove_button.toggle_mode = true
	remove_button.focus_mode = Control.FOCUS_NONE
	remove_button.pressed.connect(_on_build_mode_pressed.bind("remove"))
	build_buttons["remove"] = remove_button
	build_row.add_child(remove_button)

	var cancel_build_button = Button.new()
	cancel_build_button.text = "Cancel"
	cancel_build_button.focus_mode = Control.FOCUS_NONE
	cancel_build_button.pressed.connect(_on_cancel_build_pressed)
	build_row.add_child(cancel_build_button)

	resource_label = Label.new()
	resource_label.text = "Resources: -"
	resource_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(resource_label)

	var hand_label = Label.new()
	hand_label.text = "Hand"
	side.add_child(hand_label)

	var hand_slots = VBoxContainer.new()
	hand_slots.add_theme_constant_override("separation", 4)
	side.add_child(hand_slots)

	for index in range(CARD_BUTTON_LIMIT):
		var card_button = Button.new()
		card_button.visible = false
		card_button.toggle_mode = true
		card_button.focus_mode = Control.FOCUS_NONE
		card_button.pressed.connect(_on_card_slot_pressed.bind(index))
		card_buttons.append(card_button)
		hand_slots.add_child(card_button)

	discard_card_button = Button.new()
	discard_card_button.text = "Discard selected"
	discard_card_button.focus_mode = Control.FOCUS_NONE
	discard_card_button.pressed.connect(_on_discard_selected_pressed)
	side.add_child(discard_card_button)

	var reward_label = Label.new()
	reward_label.text = "Reward"
	side.add_child(reward_label)

	reward_status_label = Label.new()
	reward_status_label.text = "Reward: -"
	reward_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(reward_status_label)

	var reward_slots = VBoxContainer.new()
	reward_slots.add_theme_constant_override("separation", 4)
	side.add_child(reward_slots)

	for index in range(REWARD_BUTTON_LIMIT):
		var reward_button = Button.new()
		reward_button.visible = false
		reward_button.custom_minimum_size = Vector2(0, 64)
		reward_button.focus_mode = Control.FOCUS_NONE
		reward_button.pressed.connect(_on_reward_button_pressed.bind(index))
		reward_buttons.append(reward_button)
		reward_slots.add_child(reward_button)

	skip_reward_button = Button.new()
	skip_reward_button.text = "Skip reward"
	skip_reward_button.visible = false
	skip_reward_button.focus_mode = Control.FOCUS_NONE
	skip_reward_button.pressed.connect(_on_skip_reward_pressed)
	reward_slots.add_child(skip_reward_button)

	var artifact_label = Label.new()
	artifact_label.text = "Artifact"
	side.add_child(artifact_label)

	artifact_status_label = Label.new()
	artifact_status_label.text = "Artifact: -"
	artifact_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(artifact_status_label)

	var artifact_slots = VBoxContainer.new()
	artifact_slots.add_theme_constant_override("separation", 4)
	side.add_child(artifact_slots)

	for index in range(ARTIFACT_BUTTON_LIMIT):
		var artifact_button = Button.new()
		artifact_button.visible = false
		artifact_button.custom_minimum_size = Vector2(0, 58)
		artifact_button.focus_mode = Control.FOCUS_NONE
		artifact_button.pressed.connect(_on_artifact_button_pressed.bind(index))
		artifact_buttons.append(artifact_button)
		artifact_slots.add_child(artifact_button)

	skip_artifact_button = Button.new()
	skip_artifact_button.text = "Skip artifact"
	skip_artifact_button.visible = false
	skip_artifact_button.focus_mode = Control.FOCUS_NONE
	skip_artifact_button.pressed.connect(_on_skip_artifact_pressed)
	artifact_slots.add_child(skip_artifact_button)

	var shop_label = Label.new()
	shop_label.text = "Shop"
	side.add_child(shop_label)

	shop_status_label = Label.new()
	shop_status_label.text = "Shop: -"
	shop_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(shop_status_label)

	var shop_slots = VBoxContainer.new()
	shop_slots.add_theme_constant_override("separation", 4)
	side.add_child(shop_slots)

	for index in range(SHOP_BUTTON_LIMIT):
		var shop_button = Button.new()
		shop_button.visible = false
		shop_button.custom_minimum_size = Vector2(0, 58)
		shop_button.focus_mode = Control.FOCUS_NONE
		shop_button.pressed.connect(_on_shop_button_pressed.bind(index))
		shop_buttons.append(shop_button)
		shop_slots.add_child(shop_button)

	skip_shop_button = Button.new()
	skip_shop_button.text = "Skip shop"
	skip_shop_button.visible = false
	skip_shop_button.focus_mode = Control.FOCUS_NONE
	skip_shop_button.pressed.connect(_on_skip_shop_pressed)
	shop_slots.add_child(skip_shop_button)

	var round_recap_label = Label.new()
	round_recap_label.text = "Round recap"
	side.add_child(round_recap_label)

	round_recap_panel = PanelContainer.new()
	round_recap_panel.visible = false
	side.add_child(round_recap_panel)

	var round_recap_margin = MarginContainer.new()
	round_recap_margin.add_theme_constant_override("margin_left", 8)
	round_recap_margin.add_theme_constant_override("margin_top", 8)
	round_recap_margin.add_theme_constant_override("margin_right", 8)
	round_recap_margin.add_theme_constant_override("margin_bottom", 8)
	round_recap_panel.add_child(round_recap_margin)

	var round_recap_stack = VBoxContainer.new()
	round_recap_stack.add_theme_constant_override("separation", 4)
	round_recap_margin.add_child(round_recap_stack)

	round_recap_title_label = Label.new()
	round_recap_title_label.text = "Round recap: -"
	round_recap_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	round_recap_stack.add_child(round_recap_title_label)

	round_recap_body_label = Label.new()
	round_recap_body_label.text = ""
	round_recap_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	round_recap_stack.add_child(round_recap_body_label)

	var action_row = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)
	side.add_child(action_row)

	auto_step_toggle = CheckButton.new()
	auto_step_toggle.text = "Auto step"
	auto_step_toggle.focus_mode = Control.FOCUS_NONE
	auto_step_toggle.button_pressed = true
	auto_step_toggle.toggled.connect(_on_auto_step_toggled)
	side.add_child(auto_step_toggle)

	start_wave_button = Button.new()
	start_wave_button.text = "Start wave"
	start_wave_button.focus_mode = Control.FOCUS_NONE
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	action_row.add_child(start_wave_button)

	stack_wave_button = Button.new()
	stack_wave_button.text = "Call next"
	stack_wave_button.focus_mode = Control.FOCUS_NONE
	stack_wave_button.pressed.connect(_on_stack_wave_pressed)
	action_row.add_child(stack_wave_button)

	hold_stack_button = Button.new()
	hold_stack_button.text = "Hold"
	hold_stack_button.focus_mode = Control.FOCUS_NONE
	hold_stack_button.pressed.connect(_on_hold_stack_vote_pressed)
	action_row.add_child(hold_stack_button)

	step_wave_button = Button.new()
	step_wave_button.text = "Step"
	step_wave_button.focus_mode = Control.FOCUS_NONE
	step_wave_button.pressed.connect(_on_step_wave_pressed)
	action_row.add_child(step_wave_button)

	var reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.pressed.connect(_on_reset_pressed)
	action_row.add_child(reset_button)

	var autoplay_case_button = Button.new()
	autoplay_case_button.text = "Auto case"
	autoplay_case_button.focus_mode = Control.FOCUS_NONE
	autoplay_case_button.pressed.connect(_on_autoplay_case_pressed)
	action_row.add_child(autoplay_case_button)

	var autoplay_button = Button.new()
	autoplay_button.text = "Auto all"
	autoplay_button.focus_mode = Control.FOCUS_NONE
	autoplay_button.pressed.connect(_on_autoplay_pressed)
	action_row.add_child(autoplay_button)

	tile_label = Label.new()
	tile_label.text = "Tile: -"
	side.add_child(tile_label)

	preview_label = Label.new()
	preview_label.text = "Preview: -"
	preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(preview_label)

	selected_label = Label.new()
	selected_label.text = "Selected: -"
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(selected_label)

	var log_row = HBoxContainer.new()
	log_row.add_theme_constant_override("separation", 6)
	side.add_child(log_row)

	var log_title = Label.new()
	log_title.text = "Activity log"
	log_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_row.add_child(log_title)

	debug_log_toggle = CheckButton.new()
	debug_log_toggle.text = "Show"
	debug_log_toggle.focus_mode = Control.FOCUS_NONE
	debug_log_toggle.button_pressed = show_debug_log
	debug_log_toggle.toggled.connect(_on_debug_log_toggled)
	log_row.add_child(debug_log_toggle)

	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(log_label)

	wave_timer = Timer.new()
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)


func _load_m0_data() -> void:
	if simulation.load_data():
		player_count = simulation.get_default_player_count()
		_ensure_selected_class_id()
		run_started = false
		show_debug_log = simulation.get_show_debug_logs_default()
		_rebuild_class_buttons()
		wave_timer.wait_time = simulation.get_auto_step_interval()
		debug_log.push("m0_test_data.json loaded: %s" % simulation.describe_loaded_data())
	else:
		selected_class_id = ""
		run_started = false
		show_debug_log = true
		debug_log.push("Data load failed: %s" % simulation.last_error)


func _refresh_screen() -> void:
	_refresh_run_setup()
	_refresh_player_buttons()
	_refresh_class_buttons()
	_refresh_build_buttons()
	_refresh_cards()
	_refresh_rewards()
	_refresh_status()
	_refresh_round_recap()
	_refresh_map_view()
	_refresh_preview_labels()
	_refresh_selected_tile()
	_refresh_log()


func _refresh_run_setup() -> void:
	if setup_summary_label == null:
		return

	if not simulation.is_loaded():
		setup_summary_label.text = "Setup: data not loaded"
		if begin_run_button != null:
			begin_run_button.disabled = true
			begin_run_button.text = "Begin run"
		return

	_ensure_selected_class_id()
	setup_summary_label.text = "Setup: %s" % simulation.get_run_setup_summary(player_count, selected_class_id)
	if begin_run_button != null:
		begin_run_button.disabled = run_started
		begin_run_button.text = "Run active" if run_started else "Begin run"


func _refresh_player_buttons() -> void:
	for index in range(player_buttons.size()):
		player_buttons[index].button_pressed = index + 1 == player_count
		player_buttons[index].disabled = run_started or not simulation.is_loaded()


func _refresh_class_buttons() -> void:
	if class_row == null:
		return

	if not simulation.is_loaded():
		for class_id in class_buttons.keys():
			var button: Button = class_buttons[class_id]
			button.disabled = true
		return

	if class_buttons.is_empty():
		_rebuild_class_buttons()

	_ensure_selected_class_id()
	for class_id in class_buttons.keys():
		var button: Button = class_buttons[class_id]
		button.disabled = run_started
		button.button_pressed = str(class_id) == selected_class_id


func _rebuild_class_buttons() -> void:
	if class_row == null or not simulation.is_loaded():
		return

	for child in class_row.get_children():
		child.queue_free()

	class_buttons.clear()
	for class_id in simulation.get_autoplay_class_ids():
		var class_id_text = str(class_id)
		var button = Button.new()
		button.text = simulation.get_class_label(class_id_text)
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_class_pressed.bind(class_id_text))
		class_buttons[class_id_text] = button
		class_row.add_child(button)


func _refresh_build_buttons() -> void:
	for mode in build_buttons.keys():
		var button: Button = build_buttons[mode]
		button.disabled = not run_started or simulation.wave_active
		button.button_pressed = mode == build_mode


func _refresh_cards() -> void:
	if resource_label == null:
		return

	if not simulation.is_loaded():
		resource_label.text = "Resources: -"
		for button in card_buttons:
			button.visible = false
		if discard_card_button != null:
			discard_card_button.disabled = true
		return

	if not run_started:
		resource_label.text = "Resources: begin the run to draw your opening hand"
		for button in card_buttons:
			button.visible = false
			button.button_pressed = false
		if discard_card_button != null:
			discard_card_button.disabled = true
		return

	var hand = simulation.get_hand()
	if selected_card_index >= hand.size():
		selected_card_index = -1

	resource_label.text = "Resources: %s\n%s" % [
		simulation.get_resource_summary(),
		simulation.get_deck_cycle_summary(),
	]

	for index in range(card_buttons.size()):
		var button: Button = card_buttons[index]
		if index >= hand.size():
			button.visible = false
			button.button_pressed = false
			continue

		var card_id = str(hand[index])
		var card = simulation.get_card_data(card_id)
		var cost = int(card.get("cost", 0))
		button.visible = true
		button.text = "%s [%s]" % [card.get("label", card_id), cost]
		button.disabled = false
		button.button_pressed = index == selected_card_index

	if discard_card_button != null:
		discard_card_button.disabled = _selected_card_id().is_empty() or simulation.get_discard_charges() <= 0


func _refresh_rewards() -> void:
	if reward_buttons.is_empty():
		return

	if not simulation.is_loaded():
		if reward_status_label != null:
			reward_status_label.text = "Reward: -"
		if artifact_status_label != null:
			artifact_status_label.text = "Artifact: -"
		if shop_status_label != null:
			shop_status_label.text = "Shop: -"
		for button in reward_buttons:
			button.visible = false
		for button in artifact_buttons:
			button.visible = false
			button.tooltip_text = ""
		for button in shop_buttons:
			button.visible = false
			button.tooltip_text = ""
		if skip_reward_button != null:
			skip_reward_button.visible = false
		if skip_artifact_button != null:
			skip_artifact_button.visible = false
		if skip_shop_button != null:
			skip_shop_button.visible = false
		return

	if not run_started:
		if reward_status_label != null:
			reward_status_label.text = "Reward: begin the run first"
		if artifact_status_label != null:
			artifact_status_label.text = "Artifact: begin the run first"
		if shop_status_label != null:
			shop_status_label.text = "Shop: begin the run first"
		for button in reward_buttons:
			button.visible = false
			button.tooltip_text = ""
		for button in artifact_buttons:
			button.visible = false
			button.tooltip_text = ""
		for button in shop_buttons:
			button.visible = false
			button.tooltip_text = ""
		if skip_reward_button != null:
			skip_reward_button.visible = false
		if skip_artifact_button != null:
			skip_artifact_button.visible = false
		if skip_shop_button != null:
			skip_shop_button.visible = false
		return

	var offer = simulation.get_reward_offer()
	if reward_status_label != null:
		reward_status_label.text = simulation.get_reward_offer_summary()

	for index in range(reward_buttons.size()):
		var button: Button = reward_buttons[index]
		if index >= offer.size():
			button.visible = false
			button.tooltip_text = ""
			continue

		var card_id = str(offer[index])
		var report = simulation.get_card_reward_report(card_id)
		button.visible = true
		button.text = "%s [%s] cost %s %s\n%s\nCopies: %s -> %s" % [
			report.get("label", card_id),
			report.get("rarity_label", "Common"),
			report.get("cost", 0),
			report.get("role", "Card"),
			report.get("effect", ""),
			report.get("deck_count", 0),
			int(report.get("deck_count", 0)) + 1,
		]
		button.tooltip_text = "%s | unlock %s | %s | %s" % [
			report.get("rarity_label", "Common"),
			report.get("unlock", "R1+"),
			report.get("deck_zone_summary", ""),
			report.get("claim_preview", "Adds to discard pile."),
		]

	if skip_reward_button != null:
		skip_reward_button.visible = not offer.is_empty()

	var artifact_offer = simulation.get_artifact_offer()
	for index in range(artifact_buttons.size()):
		var button: Button = artifact_buttons[index]
		if index >= artifact_offer.size():
			button.visible = false
			button.tooltip_text = ""
			continue

		var artifact_id = str(artifact_offer[index])
		var report = simulation.get_artifact_reward_report(artifact_id)
		button.visible = true
		button.text = "%s\nParty passive: %s" % [
			report.get("label", artifact_id),
			report.get("effect", ""),
		]
		button.tooltip_text = "equipped %s | %s" % [
			report.get("equipped_count", 0),
			"already equipped" if bool(report.get("equipped", false)) else "new artifact",
		]

	if skip_artifact_button != null:
		skip_artifact_button.visible = not artifact_offer.is_empty()
	if artifact_status_label != null:
		if artifact_offer.is_empty():
			artifact_status_label.text = "Artifact: equipped %s" % simulation.get_equipped_artifact_summary()
		else:
			artifact_status_label.text = simulation.get_artifact_offer_summary()

	var shop_offer = simulation.get_shop_offer()
	if shop_status_label != null:
		shop_status_label.text = simulation.get_shop_offer_summary()

	for index in range(shop_buttons.size()):
		var button: Button = shop_buttons[index]
		if index >= shop_offer.size():
			button.visible = false
			button.tooltip_text = ""
			continue

		var shop_card_id = str(shop_offer[index])
		var shop_report = simulation.get_card_removal_report(shop_card_id)
		button.visible = true
		button.text = "Remove %s [%s] %sg\n%s\nCopies: %s -> %s" % [
			shop_report.get("label", shop_card_id),
			shop_report.get("rarity_label", "Common"),
			shop_report.get("gold_cost", 0),
			shop_report.get("effect", ""),
			shop_report.get("deck_count", 0),
			shop_report.get("deck_count_after", 0),
		]
		button.disabled = not bool(shop_report.get("can_remove", false))
		button.tooltip_text = "%s | gold %s -> %s | %s | %s" % [
			shop_report.get("role", "Card"),
			shop_report.get("gold", 0),
			shop_report.get("gold_after", 0),
			shop_report.get("deck_zone_summary", ""),
			shop_report.get("removal_preview", ""),
		]

	if skip_shop_button != null:
		skip_shop_button.visible = not shop_offer.is_empty()


func _refresh_status() -> void:
	if not simulation.is_loaded():
		status_label.text = "Data not loaded."
		tutorial_label.visible = false
		tutorial_label.text = "Tutorial: -"
		data_label.text = simulation.last_error
		wave_preview_label.text = "Next waves: -"
		front_label.text = "Fronts: -"
		stack_risk_label.text = "Stack risk: -"
		stats_label.text = "Stats: -"
		round_report_label.text = "Last round: -"
		outcome_label.text = "Outcome: -"
		if stack_wave_button != null:
			stack_wave_button.disabled = true
		if hold_stack_button != null:
			hold_stack_button.disabled = true
		if start_wave_button != null:
			start_wave_button.disabled = true
		if step_wave_button != null:
			step_wave_button.disabled = true
		return

	var active_directions = simulation.get_active_directions(player_count)
	if not run_started:
		status_label.text = "Setup: choose players and lead class, then begin the run."
		tutorial_label.visible = false
		tutorial_label.text = "Tutorial: -"
		data_label.text = simulation.get_run_setup_summary(player_count, selected_class_id)
		wave_preview_label.text = simulation.get_next_wave_preview_summary(player_count)
		front_label.text = "Front preview: %s" % simulation.get_front_pressure_summary(player_count)
		stack_risk_label.text = "Stack risk: locked until the run begins"
		stats_label.text = "Stats: -"
		round_report_label.text = "Last round: -"
		outcome_label.text = "Outcome: -"
		if stack_wave_button != null:
			stack_wave_button.disabled = true
			stack_wave_button.tooltip_text = "Begin the run before calling extra waves."
		if hold_stack_button != null:
			hold_stack_button.disabled = true
			hold_stack_button.tooltip_text = "No active vote."
		if start_wave_button != null:
			start_wave_button.disabled = true
			start_wave_button.tooltip_text = "Begin the run first."
		if step_wave_button != null:
			step_wave_button.disabled = true
		return

	var round_label = simulation.get_active_round() if simulation.wave_active else simulation.get_current_round()
	_ensure_selected_class_id()
	status_label.text = "Round: %s/%s | Completed: %s | Players: %s | Active directions: %s | Autoplay class: %s | Build mode: %s" % [
		round_label,
		simulation.get_max_rounds(),
		simulation.get_completed_rounds(),
		player_count,
		_join_values(active_directions),
		_class_label(selected_class_id),
		build_mode,
	]
	var tutorial_hint = simulation.get_tutorial_hint(player_count)
	tutorial_label.visible = bool(tutorial_hint.get("visible", false))
	tutorial_label.text = simulation.get_tutorial_summary(player_count)
	data_label.text = "%s | %s | %s" % [
		simulation.get_wave_summary(),
		simulation.get_wave_stack_summary(),
		simulation.get_wave_stack_vote_summary(player_count),
	]
	wave_preview_label.text = simulation.get_next_wave_preview_summary(player_count)
	front_label.text = "%s | %s" % [
		simulation.get_front_pressure_summary(player_count),
		simulation.get_enemy_intent_summary(player_count),
	]
	stack_risk_label.text = "Stack risk: %s" % simulation.get_wave_stack_risk_summary(player_count)
	stats_label.text = simulation.get_run_stats_summary()
	round_report_label.text = simulation.get_last_round_summary()
	outcome_label.text = "Outcome: %s" % simulation.get_run_outcome_summary(player_count)
	if stack_wave_button != null:
		var stack_check = simulation.can_stack_next_wave(player_count)
		stack_wave_button.disabled = not bool(stack_check.get("ok", false))
		stack_wave_button.text = "Approve" if simulation.has_active_wave_stack_vote() and player_count > 1 else "Call next"
		stack_wave_button.tooltip_text = simulation.get_wave_stack_risk_summary(player_count)
	if hold_stack_button != null:
		hold_stack_button.disabled = not simulation.has_active_wave_stack_vote()
		hold_stack_button.tooltip_text = simulation.get_wave_stack_vote_summary(player_count)
	if start_wave_button != null:
		start_wave_button.disabled = simulation.wave_active or simulation.has_pending_reward() or simulation.is_run_complete()
		start_wave_button.tooltip_text = "Start the next wave." if not start_wave_button.disabled else "Resolve the current state first."
	if step_wave_button != null:
		step_wave_button.disabled = not simulation.wave_active


func _refresh_round_recap() -> void:
	if round_recap_panel == null:
		return

	if not simulation.is_loaded() or not run_started:
		round_recap_panel.visible = false
		if round_recap_title_label != null:
			round_recap_title_label.text = "Round recap: -"
		if round_recap_body_label != null:
			round_recap_body_label.text = ""
		return

	var report = simulation.get_last_round_panel_report(player_count)
	if not bool(report.get("ok", false)):
		round_recap_panel.visible = false
		if round_recap_title_label != null:
			round_recap_title_label.text = "Round recap: -"
		if round_recap_body_label != null:
			round_recap_body_label.text = ""
		return

	round_recap_panel.visible = true
	if round_recap_title_label != null:
		round_recap_title_label.text = "%s - %s" % [
			report.get("title", "Round recap"),
			report.get("headline", "-"),
		]
	if round_recap_body_label != null:
		var lines = PackedStringArray()
		var report_lines: Array = report.get("lines", [])
		for line in report_lines:
			var line_text = str(line)
			if not line_text.is_empty():
				lines.append(line_text)
		round_recap_body_label.text = "\n".join(lines)


func _refresh_map_view() -> void:
	if not simulation.is_loaded():
		return

	var map_size = simulation.get_map_size()
	var base_cells = simulation.get_base_cells()
	var entrances = simulation.get_entrances()
	var active_directions = simulation.get_active_directions(player_count)
	var front_pressure = simulation.get_front_pressure_by_direction(player_count)
	var path_cells = simulation.get_path_cells(player_count)
	var tower_preview_tile = preview_tile if build_mode == "tower" and preview_ok else INVALID_TILE
	var tower_range_cells = simulation.get_tower_range_cells(tower_preview_tile)
	var structure_tiles = simulation.get_structure_tiles()
	var enemy_tiles = simulation.get_enemy_tiles()
	var enemy_trait_tiles = simulation.get_enemy_trait_tiles()
	var boss_enemy_tiles = simulation.get_boss_enemy_tiles()
	var enemy_intent_tiles = simulation.get_enemy_intent_tiles(player_count)
	var card_target_tiles = _selected_card_target_tiles()
	var recent_event_tiles = simulation.get_recent_event_tiles()

	map_view.set_state(
		map_size,
		base_cells,
		entrances,
		active_directions,
		front_pressure,
		path_cells,
		tower_range_cells,
		structure_tiles,
		enemy_tiles,
		enemy_trait_tiles,
		boss_enemy_tiles,
		enemy_intent_tiles,
		card_target_tiles,
		recent_event_tiles,
		build_mode,
		preview_tile,
		preview_ok,
		preview_reason,
		selected_tile
	)


func _refresh_log() -> void:
	if log_label == null:
		return

	if debug_log_toggle != null:
		debug_log_toggle.button_pressed = show_debug_log

	log_label.visible = show_debug_log
	log_label.text = debug_log.to_text() if show_debug_log else ""


func _refresh_preview_labels() -> void:
	var selected_card_id = _selected_card_id()
	if not _is_valid_hovered_tile():
		tile_label.text = "Tile: -"
	else:
		tile_label.text = "Tile: %s" % _tile_text(hovered_tile)

	if not run_started:
		preview_label.text = "Preview: begin the run to build or play cards"
	elif not selected_card_id.is_empty() and simulation.card_requires_tile(selected_card_id) and not _is_valid_hovered_tile():
		preview_label.text = "Preview: %s" % simulation.get_card_target_summary(selected_card_id, player_count, selected_class_id)
	elif simulation.wave_active and selected_card_id.is_empty():
		preview_label.text = "Preview: wave active"
	elif build_mode == "none":
		preview_label.text = "Preview: no build mode"
	elif not _is_valid_hovered_tile():
		preview_label.text = "Preview: outside map"
	elif preview_ok:
		if build_mode == "remove":
			preview_label.text = "Preview: structure can be removed at %s" % _tile_text(preview_tile)
		elif not _selected_card_id().is_empty():
			var card = simulation.get_card_data(_selected_card_id())
			preview_label.text = "Preview: %s can be played at %s" % [
				card.get("label", _selected_card_id()),
				_tile_text(preview_tile),
			]
		else:
			preview_label.text = "Preview: %s can be placed at %s" % [build_mode, _tile_text(preview_tile)]
	else:
		preview_label.text = "Preview: %s" % preview_reason


func _refresh_selected_tile() -> void:
	if selected_label == null:
		return

	if not _is_valid_tile(selected_tile):
		selected_label.text = "Selected: -"
		return

	if not run_started:
		selected_label.text = "Selected: %s\nSetup preview only" % _tile_text(selected_tile)
		return

	var report = simulation.get_tile_report(selected_tile, player_count)
	if not bool(report["ok"]):
		selected_label.text = "Selected: %s" % report["reason"]
		return

	selected_label.text = _format_tile_report(report)


func _on_player_count_pressed(count: int) -> void:
	if run_started:
		debug_log.push("Player count is locked after the run begins. Reset to change setup.")
		_refresh_log()
		return

	_clear_preview()
	selected_card_index = -1
	player_count = count
	simulation.reset_run()
	debug_log.push("Player count set to %s. Active directions: %s" % [
		player_count,
		_join_values(simulation.get_active_directions(player_count)),
	])
	_refresh_screen()


func _on_begin_run_pressed() -> void:
	if not simulation.is_loaded():
		debug_log.push("Cannot begin run: data is not loaded.")
		_refresh_log()
		return

	_ensure_selected_class_id()
	var setup_report = simulation.get_run_setup_report(player_count, selected_class_id)
	if not bool(setup_report.get("ok", false)):
		debug_log.push("Run setup rejected: %s." % setup_report.get("reason", "unknown"))
		_refresh_screen()
		return

	wave_timer.stop()
	simulation.reset_run()
	run_started = true
	build_mode = "none"
	selected_card_index = -1
	hovered_tile = INVALID_TILE
	selected_tile = INVALID_TILE
	_clear_preview()
	debug_log.clear()
	debug_log.push("Run started: %s." % setup_report.get("summary", ""))
	debug_log.push("Opening hand ready. Build the first kill zone, then start wave 1.")
	_refresh_screen()


func _on_class_pressed(class_id: String) -> void:
	if not simulation.is_loaded():
		return

	if run_started:
		debug_log.push("Lead class is locked after the run begins. Reset to change setup.")
		_refresh_log()
		return

	if selected_class_id == class_id:
		_refresh_class_buttons()
		return

	selected_class_id = class_id
	debug_log.push("Autoplay class set to %s." % _class_label(selected_class_id))
	_refresh_screen()


func _on_build_mode_pressed(mode: String) -> void:
	if not run_started:
		debug_log.push("Build mode locked: begin the run first.")
		_refresh_log()
		return

	if build_mode == mode:
		_cancel_build_mode("Build mode canceled.")
	else:
		_set_build_mode(mode)


func _on_card_slot_pressed(index: int) -> void:
	if not simulation.is_loaded():
		return

	if not run_started:
		debug_log.push("Card play locked: begin the run first.")
		_refresh_log()
		return

	var hand = simulation.get_hand()
	if index < 0 or index >= hand.size():
		return

	if selected_card_index == index:
		selected_card_index = -1
		build_mode = "none"
		_clear_preview()
		debug_log.push("Card selection cleared.")
		_refresh_screen()
		return

	selected_card_index = index
	var card_id = str(hand[index])
	var card = simulation.get_card_data(card_id)
	_clear_preview()

	if not simulation.card_requires_tile(card_id):
		var play_result = simulation.play_card(card_id, selected_class_id)
		if bool(play_result["ok"]):
			debug_log.push("Played %s. Mana: %s." % [play_result["card_label"], simulation.get_mana()])
			for event in play_result["events"]:
				debug_log.push(event)
			selected_card_index = -1
			build_mode = "none"
		else:
			debug_log.push("Card rejected: %s." % play_result["reason"])

		_refresh_screen()
		return

	build_mode = str(card.get("structureType", "card"))
	debug_log.push("Card selected: %s." % card.get("label", card_id))
	_refresh_screen()


func _on_discard_selected_pressed() -> void:
	if not run_started:
		debug_log.push("Discard locked: begin the run first.")
		_refresh_log()
		return

	var card_id = _selected_card_id()
	if card_id.is_empty():
		debug_log.push("Discard rejected: no card selected.")
		_refresh_screen()
		return

	var result = simulation.discard_card(card_id)
	if bool(result["ok"]):
		for event in result["events"]:
			debug_log.push(event)
		selected_card_index = -1
		build_mode = "none"
		_clear_preview()
	else:
		debug_log.push("Discard rejected: %s." % result["reason"])

	_refresh_screen()


func _on_reward_button_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Reward locked: begin the run first.")
		_refresh_log()
		return

	var offer = simulation.get_reward_offer()
	if index < 0 or index >= offer.size():
		return

	var card_id = str(offer[index])
	var result = simulation.claim_reward_card(card_id)
	if bool(result["ok"]):
		debug_log.push("Reward claimed: %s [%s]. %s Copies: %s -> %s. Added to %s." % [
			result["card_label"],
			result.get("rarity_label", "Common"),
			result.get("effect", ""),
			result.get("deck_count_before", 0),
			result.get("deck_count_after", 0),
			result.get("destination", "discard"),
		])
		debug_log.push("Reward deck change: %s -> %s. %s" % [
			result.get("card_before_summary", ""),
			result.get("card_after_summary", ""),
			result.get("deck_after_summary", ""),
		])
	else:
		debug_log.push("Reward rejected: %s." % result["reason"])

	_refresh_screen()


func _on_skip_reward_pressed() -> void:
	if not run_started:
		debug_log.push("Reward skip locked: begin the run first.")
		_refresh_log()
		return

	var result = simulation.skip_reward_offer()
	if bool(result["ok"]):
		debug_log.push("Reward skipped.")
	else:
		debug_log.push("Reward skip rejected: %s." % result["reason"])

	_refresh_screen()


func _on_artifact_button_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Artifact locked: begin the run first.")
		_refresh_log()
		return

	var offer = simulation.get_artifact_offer()
	if index < 0 or index >= offer.size():
		return

	var artifact_id = str(offer[index])
	var result = simulation.claim_artifact(artifact_id)
	if bool(result["ok"]):
		debug_log.push("Artifact equipped: %s. %s Equipped: %s -> %s." % [
			result["artifact_label"],
			result.get("effect", ""),
			result.get("equipped_count_before", 0),
			result.get("equipped_count_after", 0),
		])
	else:
		debug_log.push("Artifact rejected: %s." % result["reason"])

	_refresh_screen()


func _on_skip_artifact_pressed() -> void:
	if not run_started:
		debug_log.push("Artifact skip locked: begin the run first.")
		_refresh_log()
		return

	var result = simulation.skip_artifact_offer()
	if bool(result["ok"]):
		debug_log.push("Artifact skipped.")
	else:
		debug_log.push("Artifact skip rejected: %s." % result["reason"])

	_refresh_screen()


func _on_shop_button_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Shop locked: begin the run first.")
		_refresh_log()
		return

	var offer = simulation.get_shop_offer()
	if index < 0 or index >= offer.size():
		return

	var card_id = str(offer[index])
	var result = simulation.remove_shop_card(card_id)
	if bool(result["ok"]):
		selected_card_index = -1
		build_mode = "none"
		_clear_preview()
		debug_log.push("Shop removed: %s [%s] from %s. Gold: %s -> %s. Copies: %s -> %s." % [
			result.get("card_label", card_id),
			result.get("rarity_label", "Common"),
			result.get("removed_from", "?"),
			result.get("gold_before", 0),
			result.get("gold_after", 0),
			result.get("deck_count_before", 0),
			result.get("deck_count_after", 0),
		])
		debug_log.push("Shop deck change: %s -> %s. %s" % [
			result.get("card_before_summary", ""),
			result.get("card_after_summary", ""),
			result.get("deck_after_summary", ""),
		])
	else:
		debug_log.push("Shop rejected: %s." % result["reason"])

	_refresh_screen()


func _on_skip_shop_pressed() -> void:
	if not run_started:
		debug_log.push("Shop skip locked: begin the run first.")
		_refresh_log()
		return

	var result = simulation.skip_shop_offer()
	if bool(result["ok"]):
		debug_log.push("Shop skipped.")
	else:
		debug_log.push("Shop skip rejected: %s." % result["reason"])

	_refresh_screen()


func _on_start_wave_pressed() -> void:
	if not simulation.is_loaded():
		debug_log.push("Cannot start wave: data is not loaded.")
		_refresh_log()
		return

	if not run_started:
		debug_log.push("Cannot start wave: begin the run first.")
		_refresh_log()
		return

	var result = simulation.start_wave(player_count)
	if bool(result["ok"]):
		for event in result["events"]:
			debug_log.push(event)
		if auto_step_toggle.button_pressed:
			wave_timer.start()
		else:
			debug_log.push("Auto step is off. Use Step to advance the wave.")
	else:
		debug_log.push("Wave rejected: %s" % result["reason"])

	_refresh_screen()


func _on_stack_wave_pressed() -> void:
	if not simulation.is_loaded():
		debug_log.push("Cannot call next wave: data is not loaded.")
		_refresh_log()
		return

	if not run_started:
		debug_log.push("Cannot call next wave: begin the run first.")
		_refresh_log()
		return

	debug_log.push("Stack risk before call: %s" % simulation.get_wave_stack_risk_summary(player_count))
	var result = simulation.stack_next_wave(player_count)
	if bool(result["ok"]):
		for event in result.get("events", []):
			debug_log.push(str(event))
	else:
		debug_log.push("Wave stack rejected: %s." % result["reason"])

	_refresh_screen()


func _on_hold_stack_vote_pressed() -> void:
	if not simulation.is_loaded():
		debug_log.push("Cannot hold wave stack vote: data is not loaded.")
		_refresh_log()
		return

	if not run_started:
		debug_log.push("Cannot hold wave stack vote: begin the run first.")
		_refresh_log()
		return

	var result = simulation.hold_wave_stack_vote()
	if bool(result["ok"]):
		for event in result.get("events", []):
			debug_log.push(str(event))
	else:
		debug_log.push("Wave stack vote hold rejected: %s." % result["reason"])

	_refresh_screen()


func _on_step_wave_pressed() -> void:
	if not run_started:
		debug_log.push("No active run to step.")
		_refresh_log()
		return

	if not simulation.wave_active:
		debug_log.push("No active wave to step.")
		_refresh_log()
		return

	_run_wave_step()


func _on_autoplay_case_pressed() -> void:
	wave_timer.stop()
	_ensure_selected_class_id()

	if selected_class_id.is_empty():
		debug_log.push("Autoplay case rejected: no class profile loaded.")
		_refresh_log()
		return

	var runner: M0AutoplayRunner = M0AutoplayRunnerScript.new()
	var result = runner.run_class_profile(selected_class_id, player_count)
	_push_autoplay_result("Autoplay case", result)
	_refresh_screen()


func _on_autoplay_pressed() -> void:
	wave_timer.stop()

	var runner: M0AutoplayRunner = M0AutoplayRunnerScript.new()
	var result = runner.run_all_player_counts()
	_push_autoplay_result("Autoplay all", result)
	_refresh_screen()


func _push_autoplay_result(label: String, result: Dictionary) -> void:
	var state = "PASS" if bool(result["ok"]) else "FAIL"
	debug_log.push("%s result: %s." % [label, state])
	var aggregate: Dictionary = result.get("aggregate", {})
	if not aggregate.is_empty():
		debug_log.push("%s aggregate: pass=%s fail=%s avg_rounds=%.2f avg_base=%.2f." % [
			label,
			aggregate.get("pass_count", 0),
			aggregate.get("fail_count", 0),
			aggregate.get("average_completed_rounds", 0.0),
			aggregate.get("average_base_hp", 0.0),
		])

	var report: Dictionary = result.get("report", {})
	for note in report.get("balance_notes", []):
		debug_log.push("Autoplay note: %s" % str(note))

	for summary_line in result["summary_lines"]:
		debug_log.push(str(summary_line))

	var output_lines: Array = result["lines"]
	var start_index = max(0, output_lines.size() - 12)
	for index in range(start_index, output_lines.size()):
		debug_log.push(str(output_lines[index]))

	if not bool(result["ok"]):
		for failure in result["failures"]:
			debug_log.push("Autoplay failure: %s" % failure)

	var runner: M0AutoplayRunner = M0AutoplayRunnerScript.new()
	var save_result = runner.save_report_bundle(result, label)
	var json_result: Dictionary = save_result.get("json", {})
	var markdown_result: Dictionary = save_result.get("markdown", {})
	if bool(save_result.get("ok", false)):
		debug_log.push("Autoplay reports saved: %s (%s chars), %s (%s chars)." % [
			json_result.get("path", runner.report_path_for_label(label)),
			json_result.get("characters", 0),
			markdown_result.get("path", runner.markdown_report_path_for_label(label)),
			markdown_result.get("characters", 0),
		])
	else:
		debug_log.push("Autoplay report save failed: %s json=%s markdown=%s." % [
			save_result.get("reason", "unknown"),
			json_result.get("reason", "unknown"),
			markdown_result.get("reason", "unknown"),
		])


func _on_cancel_build_pressed() -> void:
	_cancel_build_mode("Build mode canceled.")


func _on_auto_step_toggled(enabled: bool) -> void:
	if not simulation.is_loaded():
		return

	if enabled:
		debug_log.push("Auto step enabled.")
		if simulation.wave_active:
			wave_timer.start()
	else:
		debug_log.push("Auto step disabled.")
		wave_timer.stop()

	_refresh_log()


func _on_debug_log_toggled(enabled: bool) -> void:
	show_debug_log = enabled
	_refresh_log()


func _on_wave_timer_timeout() -> void:
	_run_wave_step()


func _run_wave_step() -> void:
	if not run_started:
		return

	var events = simulation.step_wave(player_count)
	for event in events:
		debug_log.push(event)

	if not simulation.wave_active:
		wave_timer.stop()

	_refresh_screen()


func _on_reset_pressed() -> void:
	wave_timer.stop()
	hovered_tile = INVALID_TILE
	selected_tile = INVALID_TILE
	selected_card_index = -1
	build_mode = "none"
	_clear_preview()
	player_count = simulation.get_default_player_count() if simulation.is_loaded() else 1
	run_started = false
	debug_log.clear()

	if simulation.is_loaded():
		simulation.reset_run()
		debug_log.push("M0 scene reset.")
		debug_log.push("m0_test_data.json ready: %s" % simulation.describe_loaded_data())
	else:
		debug_log.push("M0 scene reset. Data is not loaded.")

	_refresh_screen()


func _on_tile_hovered(tile: Vector2i) -> void:
	hovered_tile = tile

	if not simulation.is_loaded():
		_clear_preview()
		_refresh_screen()
		return

	if not run_started:
		_clear_preview()
		_refresh_screen()
		return

	if build_mode == "none" and _selected_card_id().is_empty():
		_clear_preview()
		_refresh_screen()
		return

	if simulation.wave_active and _selected_card_id().is_empty():
		_clear_preview()
		_refresh_screen()
		return

	preview_tile = tile
	var result = {}
	if build_mode == "remove":
		result = simulation.can_remove_structure(tile)
	elif not _selected_card_id().is_empty():
		result = simulation.can_play_card_at_tile(_selected_card_id(), tile, player_count, selected_class_id)
	else:
		result = simulation.can_place_structure(tile, build_mode, player_count, selected_class_id)
	preview_ok = bool(result["ok"])
	preview_reason = str(result["reason"])
	_refresh_screen()


func _on_tile_pressed(tile: Vector2i) -> void:
	selected_tile = tile
	if not run_started:
		debug_log.push("Tile selected %s. Begin the run before building or playing cards." % _tile_text(tile))
		_refresh_screen()
		return

	var selected_card_id = _selected_card_id()

	if simulation.wave_active and selected_card_id.is_empty():
		debug_log.push("Tile selected %s. Build changes are locked during an active wave." % _tile_text(tile))
		_refresh_screen()
		return

	if build_mode == "none":
		debug_log.push("Tile selected %s." % _tile_text(tile))
		_refresh_screen()
		return

	if build_mode == "remove":
		if simulation.wave_active:
			debug_log.push("Remove rejected at %s: wave_active." % _tile_text(tile))
			_refresh_screen()
			return

		var remove_result = simulation.remove_structure(tile)
		if bool(remove_result["ok"]):
			debug_log.push("Structure removed at %s." % _tile_text(tile))
			_clear_preview()
		else:
			debug_log.push("Remove rejected at %s: %s." % [_tile_text(tile), remove_result["reason"]])

		_refresh_screen()
		return

	if not selected_card_id.is_empty():
		var play_result = simulation.play_card_at_tile(selected_card_id, tile, player_count, selected_class_id)
		if bool(play_result["ok"]):
			debug_log.push("Played %s at %s. Mana: %s." % [
				play_result["card_label"],
				_tile_text(tile),
				simulation.get_mana(),
			])
			for event in play_result["events"]:
				debug_log.push(event)
			selected_card_index = -1
			build_mode = "none"
			_clear_preview()
		else:
			debug_log.push("Card rejected at %s: %s." % [_tile_text(tile), play_result["reason"]])

		_refresh_screen()
		return

	var result = simulation.place_structure(tile, build_mode, player_count, selected_class_id)
	if bool(result["ok"]):
		debug_log.push("%s placed at %s." % [build_mode.capitalize(), _tile_text(tile)])
		_clear_preview()
	else:
		debug_log.push("Placement rejected at %s: %s." % [_tile_text(tile), result["reason"]])

	_refresh_screen()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return

	var key_event = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if not run_started:
		if key_event.keycode == KEY_SPACE:
			_on_begin_run_pressed()
		return

	match key_event.keycode:
		KEY_T:
			_set_build_mode("tower")
		KEY_B:
			_set_build_mode("barricade")
		KEY_R:
			_set_build_mode("remove")
		KEY_D:
			_on_discard_selected_pressed()
		KEY_N:
			_on_stack_wave_pressed()
		KEY_H:
			_on_hold_stack_vote_pressed()
		KEY_ESCAPE:
			_cancel_build_mode("Build mode canceled.")
		KEY_SPACE:
			if simulation.wave_active:
				_on_step_wave_pressed()
			else:
				_on_start_wave_pressed()


func _set_build_mode(mode: String, write_log = true) -> void:
	if not ["none", "tower", "barricade", "remove"].has(mode):
		return

	if not run_started:
		if write_log:
			debug_log.push("Build mode locked: begin the run first.")
			_refresh_log()
		return

	if simulation.wave_active and mode != "none":
		if write_log:
			debug_log.push("Build mode locked during an active wave. Use structure cards instead.")
			_refresh_log()
		return

	build_mode = mode
	selected_card_index = -1
	_clear_preview()

	if write_log:
		if build_mode == "none":
			debug_log.push("Build mode cleared.")
		else:
			debug_log.push("Build mode selected: %s" % build_mode)

	_refresh_screen()


func _cancel_build_mode(message: String) -> void:
	if build_mode == "none":
		debug_log.push("No build mode selected.")
	else:
		build_mode = "none"
		selected_card_index = -1
		_clear_preview()
		debug_log.push(message)

	_refresh_screen()


func _format_tile_report(report: Dictionary) -> String:
	var lines = PackedStringArray()
	var tile: Vector2i = report["tile"]
	lines.append("Selected: %s" % _tile_text(tile))

	if bool(report["is_base"]):
		lines.append("Base")

	var entrance_direction = str(report["entrance_direction"])
	if not entrance_direction.is_empty():
		var entrance_state = "active" if bool(report["active_entrance"]) else "inactive"
		lines.append("Entrance: %s (%s)" % [entrance_direction, entrance_state])
		var front_pressure: Dictionary = report.get("front_pressure", {})
		if not front_pressure.is_empty():
			lines.append("Front: %s" % front_pressure.get("summary", "clear"))

	if bool(report["on_path"]):
		lines.append("Path: active route")

	if bool(report["in_tower_range"]):
		lines.append("Tower range: yes")

	var structure: Dictionary = report["structure"]
	if not structure.is_empty():
		var owner_class_id = str(structure.get("class_id", ""))
		var owner_label = ""
		if not owner_class_id.is_empty():
			owner_label = " / %s" % _class_label(owner_class_id)

		lines.append("Structure: %s%s HP %s/%s" % [
			structure["type"],
			owner_label,
			structure["hp"],
			structure["max_hp"],
		])

	if int(report["enemy_count"]) > 0:
		lines.append("Enemies: %s (%s)" % [report["enemy_count"], report["enemy_summary"]])
		var enemy_traits = str(report.get("enemy_traits", ""))
		if not enemy_traits.is_empty() and enemy_traits != "Standard":
			lines.append("Enemy traits: %s" % enemy_traits)

	var card_target = _selected_card_target_at(tile)
	if not card_target.is_empty():
		var card_target_text = "ok" if bool(card_target.get("valid", false)) else "blocked: %s" % card_target.get("reason", "unknown")
		lines.append("Card target: %s" % card_target_text)

	var enemy_intent: Dictionary = report.get("enemy_intent", {})
	if not enemy_intent.is_empty():
		lines.append("Intent: %s" % enemy_intent.get("summary", "unknown"))

	var event = str(report["event"])
	if not event.is_empty():
		lines.append("Event: %s" % event)

	if lines.size() == 1:
		lines.append("Empty ground")

	return "\n".join(lines)


func _selected_card_id() -> String:
	if selected_card_index < 0 or not simulation.is_loaded():
		return ""

	var hand = simulation.get_hand()
	if selected_card_index >= hand.size():
		return ""

	return str(hand[selected_card_index])


func _selected_card_target_tiles() -> Dictionary:
	var card_id = _selected_card_id()
	if card_id.is_empty() or not simulation.card_requires_tile(card_id):
		return {}

	var report = simulation.get_card_target_tiles(card_id, player_count, selected_class_id)
	if not bool(report.get("ok", false)):
		return {}

	return report.get("tiles", {})


func _selected_card_target_at(tile: Vector2i) -> Dictionary:
	var target_tiles = _selected_card_target_tiles()
	return target_tiles.get(_tile_key(tile), {})


func _clear_preview() -> void:
	preview_tile = INVALID_TILE
	preview_ok = false
	preview_reason = ""


func _is_valid_hovered_tile() -> bool:
	return _is_valid_tile(hovered_tile)


func _is_valid_tile(tile: Vector2i) -> bool:
	if not simulation.is_loaded():
		return false

	var map_size = simulation.get_map_size()
	return tile.x >= 0 and tile.y >= 0 and tile.x < map_size.x and tile.y < map_size.y


func _ensure_selected_class_id() -> void:
	if not simulation.is_loaded():
		selected_class_id = ""
		return

	var class_ids = simulation.get_autoplay_class_ids()
	if class_ids.is_empty():
		selected_class_id = ""
		return

	if selected_class_id.is_empty() or not class_ids.has(selected_class_id):
		selected_class_id = str(class_ids[0])


func _class_label(class_id: String) -> String:
	if not simulation.is_loaded() or class_id.is_empty():
		return "-"

	return simulation.get_class_label(class_id)


func _tile_text(tile: Vector2i) -> String:
	return "(%s, %s)" % [tile.x, tile.y]


func _join_values(values: Array) -> String:
	var parts = PackedStringArray()
	for value in values:
		parts.append(str(value))
	return ", ".join(parts)
