extends Control

const M0CombatSimulationScript = preload("res://scripts/m0/M0CombatSimulation.gd")
const M0AutoplayRunnerScript = preload("res://scripts/m0/M0AutoplayRunner.gd")
const M0AlphaCoverageRunnerScript = preload("res://scripts/m0/M0AlphaCoverageRunner.gd")
const M0DebugLogScript = preload("res://scripts/m0/M0DebugLog.gd")
const M0MapViewScript = preload("res://scripts/m0/M0MapView.gd")
const INVALID_TILE = Vector2i(-1, -1)
const CARD_BUTTON_LIMIT = 10
const REWARD_BUTTON_LIMIT = 3
const ARTIFACT_BUTTON_LIMIT = 2
const ARTIFACT_REPLACE_BUTTON_LIMIT = 4
const ARTIFACT_RELEASE_BUTTON_LIMIT = 2
const SHOP_BUTTON_LIMIT = 8
const SHOP_REACTIVATE_DORMANT_BUTTON_LIMIT = 2
const SHOP_REACTIVATE_REPLACE_BUTTON_LIMIT = 4
const RISK_PING_BUTTON_LIMIT = 4
const LOG_FILTER_CATEGORIES = ["all", "combat", "reward", "setup", "system"]
const LOG_FILTER_LABELS = ["All", "Combat", "Reward", "Setup", "System"]
const AUTOPLAY_FOCUS_LOG_LIMIT = 4
const AUTOPLAY_NEXT_ACTION_LOG_LIMIT = 3
const ALPHA_MANUAL_REVIEW_SAVE_FILENAME = "m0_alpha_manual_reviews.json"
const ALPHA_MANUAL_REVIEW_SAVE_PATH = "user://m0_alpha_manual_reviews.json"
const ALPHA_MANUAL_REVIEW_SAVE_VERSION = 1
const ALPHA_ISSUE_TAG_IDS = ["untagged", "ui_unclear", "class_gimmick_weak", "front_confusion", "pacing_drag", "bug"]
const ALPHA_ISSUE_TAG_LABELS = ["No tag", "UI unclear", "Class weak", "Front confusion", "Pacing", "Bug"]
const ALPHA_ISSUE_TAG_FIX_RECOMMENDATIONS = {
	"untagged": "add a cause tag before choosing a fix lane",
	"ui_unclear": "check target labels, disabled button reasons, and activity log wording first",
	"class_gimmick_weak": "replay the class loop and make its signature action more noticeable first",
	"front_confusion": "check active-front highlights, entrance labels, and setup hints first",
	"pacing_drag": "check wave timing, call-next friction, and slow hand steps first",
	"bug": "fix blocking behavior before another alpha pass",
}
const ALPHA_RECOMMENDATION_CONTRAST_IDS = ["not_checked", "follow_clearer", "alternate_clearer", "both_clear", "both_unclear"]
const ALPHA_RECOMMENDATION_CONTRAST_LABELS = ["Rec not checked", "Follow clearer", "Alternate clearer", "Both clear", "Both unclear"]
const ALPHA_RECOMMENDATION_CONTRAST_FIX_IDS = ["alternate_clearer", "both_unclear"]
const ALPHA_RECOMMENDATION_CONTRAST_FIX_RECOMMENDATIONS = {
	"alternate_clearer": "soften recommendation wording and expose the alternate tradeoff first",
	"both_unclear": "rewrite recommendation detail and contrast labels before another alpha pass",
}
const ALPHA_RECOMMENDATION_FIX_CHECK_IDS = ["auto_pick", "alternate_hidden", "discussion_blocked"]
const ALPHA_RECOMMENDATION_FIX_CHECK_LABELS = ["Auto-pick", "Alt hidden", "Talk blocked"]
const ALPHA_RECOMMENDATION_FIX_CHECK_PRIORITY_ACTIONS = {
	"auto_pick": "soften directive tone and label it as a discussion prompt",
	"alternate_hidden": "show the alternate option's upside beside the suggestion",
	"discussion_blocked": "rewrite the suggestion as a table question before another alpha pass",
}

var simulation
var debug_log
var player_count = 1
var selected_class_id = ""
var build_mode = "none"
var run_started = false
var run_config_lock_snapshot: Dictionary = {}
var show_debug_log = true
var log_filter_category = "all"
var show_important_logs_only = false

var status_label: Label
var tutorial_label: Label
var data_label: Label
var wave_preview_label: Label
var front_label: Label
var stack_risk_label: Label
var tactical_hint_label: Label
var risk_ping_row: HBoxContainer
var action_status_label: Label
var wave_readiness_label: Label
var stats_label: Label
var round_report_label: Label
var outcome_label: Label
var resource_label: Label
var map_view
var tile_label: Label
var preview_label: Label
var selected_card_label: Label
var selected_label: Label
var reward_status_label: Label
var artifact_status_label: Label
var shop_status_label: Label
var setup_summary_label: Label
var round_recap_panel: PanelContainer
var round_recap_title_label: Label
var round_recap_body_label: Label
var alpha_focus_panel: PanelContainer
var alpha_focus_title_label: Label
var alpha_focus_body_label: Label
var alpha_focus_prev_button: Button
var alpha_focus_next_button: Button
var alpha_focus_contrast_prev_button: Button
var alpha_focus_contrast_status_label: Label
var alpha_focus_contrast_next_button: Button
var alpha_focus_apply_button: Button
var alpha_focus_probe_button: Button
var alpha_focus_action_button: Button
var alpha_focus_probe_status_label: Label
var alpha_focus_manual_status_label: Label
var alpha_focus_issue_tag_option: OptionButton
var alpha_focus_recommendation_contrast_option: OptionButton
var alpha_focus_recommendation_fix_check_buttons: Array[CheckButton] = []
var alpha_focus_mark_clear_button: Button
var alpha_focus_mark_issue_button: Button
var alpha_coverage_panel: PanelContainer
var alpha_coverage_title_label: Label
var alpha_coverage_body_label: Label
var alpha_coverage_run_button: Button
var alpha_coverage_open_next_manual_button: Button
var alpha_coverage_open_issue_button: Button
var alpha_coverage_open_fix_lane_button: Button
var alpha_coverage_open_recommendation_fix_button: Button
var alpha_coverage_probe_fix_lane_button: Button
var log_label: Label
var auto_step_toggle: CheckButton
var debug_log_toggle: CheckButton
var log_filter_option: OptionButton
var important_log_toggle: CheckButton
var use_best_target_button: Button
var setup_plan_button: Button
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
var artifact_replace_buttons: Array[Button] = []
var artifact_release_buttons: Array[Button] = []
var shop_buttons: Array[Button] = []
var shop_reactivate_dormant_buttons: Array[Button] = []
var shop_reactivate_replace_buttons: Array[Button] = []
var risk_ping_buttons: Array[Button] = []
var hovered_tile = INVALID_TILE
var selected_tile = INVALID_TILE
var selected_card_index = -1
var selected_artifact_replacement_offer_id = ""
var selected_dormant_artifact_release_id = ""
var selected_shop_reactivation_dormant_artifact_id = ""
var selected_shop_reactivation_replaced_artifact_id = ""
var preview_tile = INVALID_TILE
var preview_ok = false
var preview_reason = ""
var last_hand_state_snapshot: Dictionary = {}
var last_hand_ready_cue = ""
var last_discard_follow_up_card_id = ""
var last_discard_follow_up_card_index = -1
var last_discard_follow_up_summary = ""
var last_combat_follow_up_card_id = ""
var last_combat_follow_up_card_index = -1
var last_combat_follow_up_summary = ""
var last_combat_follow_up_report_key = ""
var confirmed_risk_ping_marker: Dictionary = {}
var last_autoplay_focus_queue: Array = []
var last_autoplay_next_action_queue: Array = []
var last_autoplay_recommendation_contrast_samples: Array = []
var selected_autoplay_focus_index = 0
var selected_autoplay_recommendation_contrast_index = 0
var active_alpha_probe_entry: Dictionary = {}
var alpha_focus_probe_results: Dictionary = {}
var alpha_focus_manual_review_results: Dictionary = {}
var selected_alpha_issue_tag_id = "untagged"
var selected_alpha_recommendation_contrast_id = "not_checked"
var selected_alpha_recommendation_fix_check_ids: Array[String] = []
var last_alpha_coverage_result: Dictionary = {}
var last_boss_warning_response_line = ""
var card_target_report_cache: Dictionary = {}


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
	wave_preview_label.name = "WavePreviewLabel"
	wave_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(wave_preview_label)

	front_label = Label.new()
	front_label.name = "FrontStatusLabel"
	front_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(front_label)

	stack_risk_label = Label.new()
	stack_risk_label.name = "StackRiskLabel"
	stack_risk_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(stack_risk_label)

	tactical_hint_label = Label.new()
	tactical_hint_label.name = "WaveTacticalHintLabel"
	tactical_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(tactical_hint_label)

	risk_ping_row = HBoxContainer.new()
	risk_ping_row.name = "RiskPingRow"
	risk_ping_row.add_theme_constant_override("separation", 6)
	header.add_child(risk_ping_row)
	for index in range(RISK_PING_BUTTON_LIMIT):
		var risk_ping_button = Button.new()
		risk_ping_button.name = "RiskPingButton%s" % index
		risk_ping_button.text = "Ping"
		risk_ping_button.focus_mode = Control.FOCUS_NONE
		risk_ping_button.visible = false
		risk_ping_button.pressed.connect(_on_risk_ping_button_pressed.bind(index))
		risk_ping_buttons.append(risk_ping_button)
		risk_ping_row.add_child(risk_ping_button)

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
	legend_label.text = "B base | N/E/S/W entrance | T tower | X barricade | E enemy | + target | W boss warning | D delay | R recommended target | * recommendation | F alpha focus/front setup | event badge S/H/K/B/P/G/L | > next spawn/fast | Q queued spawn | # breaker | A armor | ! danger"
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
	begin_run_button.name = "BeginRunButton"
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
	resource_label.name = "ResourceStatusLabel"
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
		card_button.name = "HandCardSlot%s" % index
		card_button.visible = false
		card_button.toggle_mode = true
		card_button.focus_mode = Control.FOCUS_NONE
		card_button.pressed.connect(_on_card_slot_pressed.bind(index))
		card_buttons.append(card_button)
		hand_slots.add_child(card_button)

	discard_card_button = Button.new()
	discard_card_button.name = "DiscardSelectedButton"
	discard_card_button.text = "Discard selected"
	discard_card_button.focus_mode = Control.FOCUS_NONE
	discard_card_button.pressed.connect(_on_discard_selected_pressed)
	side.add_child(discard_card_button)

	selected_card_label = Label.new()
	selected_card_label.name = "SelectedCardStatusLabel"
	selected_card_label.text = "Selected card: -"
	selected_card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(selected_card_label)

	use_best_target_button = Button.new()
	use_best_target_button.name = "UseBestTargetButton"
	use_best_target_button.text = "Use best target"
	use_best_target_button.focus_mode = Control.FOCUS_NONE
	use_best_target_button.pressed.connect(_on_use_best_target_pressed)
	side.add_child(use_best_target_button)

	setup_plan_button = Button.new()
	setup_plan_button.name = "UseSetupPlanButton"
	setup_plan_button.text = "Use setup plan"
	setup_plan_button.focus_mode = Control.FOCUS_NONE
	setup_plan_button.tooltip_text = "Place the first recommended structure on uncovered active fronts."
	setup_plan_button.pressed.connect(_on_setup_plan_pressed)
	side.add_child(setup_plan_button)

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
		reward_button.name = "RewardOption%s" % index
		reward_button.visible = false
		reward_button.custom_minimum_size = Vector2(0, 64)
		reward_button.focus_mode = Control.FOCUS_NONE
		reward_button.pressed.connect(_on_reward_button_pressed.bind(index))
		reward_buttons.append(reward_button)
		reward_slots.add_child(reward_button)

	skip_reward_button = Button.new()
	skip_reward_button.name = "RewardTakeGoldButton"
	skip_reward_button.text = "Take gold"
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
		artifact_button.name = "ArtifactOption%s" % index
		artifact_button.visible = false
		artifact_button.custom_minimum_size = Vector2(0, 72)
		artifact_button.focus_mode = Control.FOCUS_NONE
		artifact_button.pressed.connect(_on_artifact_button_pressed.bind(index))
		artifact_buttons.append(artifact_button)
		artifact_slots.add_child(artifact_button)

	for index in range(ARTIFACT_REPLACE_BUTTON_LIMIT):
		var replace_button = Button.new()
		replace_button.name = "ArtifactReplaceOption%s" % index
		replace_button.visible = false
		replace_button.custom_minimum_size = Vector2(0, 58)
		replace_button.focus_mode = Control.FOCUS_NONE
		replace_button.pressed.connect(_on_artifact_replace_button_pressed.bind(index))
		artifact_replace_buttons.append(replace_button)
		artifact_slots.add_child(replace_button)

	for index in range(ARTIFACT_RELEASE_BUTTON_LIMIT):
		var release_button = Button.new()
		release_button.name = "ArtifactReleaseOption%s" % index
		release_button.visible = false
		release_button.custom_minimum_size = Vector2(0, 52)
		release_button.focus_mode = Control.FOCUS_NONE
		release_button.pressed.connect(_on_artifact_release_button_pressed.bind(index))
		artifact_release_buttons.append(release_button)
		artifact_slots.add_child(release_button)

	skip_artifact_button = Button.new()
	skip_artifact_button.name = "ArtifactKeepCurrentButton"
	skip_artifact_button.text = "Keep current artifacts"
	skip_artifact_button.visible = false
	skip_artifact_button.custom_minimum_size = Vector2(0, 46)
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
		shop_button.name = "ShopOption%s" % index
		shop_button.visible = false
		shop_button.custom_minimum_size = Vector2(0, 66)
		shop_button.focus_mode = Control.FOCUS_NONE
		shop_button.pressed.connect(_on_shop_button_pressed.bind(index))
		shop_buttons.append(shop_button)
		shop_slots.add_child(shop_button)

	for index in range(SHOP_REACTIVATE_DORMANT_BUTTON_LIMIT):
		var dormant_button = Button.new()
		dormant_button.name = "ShopReactivateDormantOption%s" % index
		dormant_button.visible = false
		dormant_button.custom_minimum_size = Vector2(0, 48)
		dormant_button.focus_mode = Control.FOCUS_NONE
		dormant_button.pressed.connect(_on_shop_reactivation_dormant_pressed.bind(index))
		shop_reactivate_dormant_buttons.append(dormant_button)
		shop_slots.add_child(dormant_button)

	for index in range(SHOP_REACTIVATE_REPLACE_BUTTON_LIMIT):
		var replace_button = Button.new()
		replace_button.name = "ShopReactivateReplaceOption%s" % index
		replace_button.visible = false
		replace_button.custom_minimum_size = Vector2(0, 48)
		replace_button.focus_mode = Control.FOCUS_NONE
		replace_button.pressed.connect(_on_shop_reactivation_replace_pressed.bind(index))
		shop_reactivate_replace_buttons.append(replace_button)
		shop_slots.add_child(replace_button)

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
	round_recap_title_label.name = "RoundRecapTitleLabel"
	round_recap_title_label.text = "Round recap: -"
	round_recap_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	round_recap_stack.add_child(round_recap_title_label)

	round_recap_body_label = Label.new()
	round_recap_body_label.name = "RoundRecapBodyLabel"
	round_recap_body_label.text = ""
	round_recap_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	round_recap_stack.add_child(round_recap_body_label)

	var alpha_focus_label = Label.new()
	alpha_focus_label.text = "Alpha focus"
	side.add_child(alpha_focus_label)

	alpha_focus_panel = PanelContainer.new()
	alpha_focus_panel.name = "AlphaFocusPanel"
	alpha_focus_panel.visible = false
	side.add_child(alpha_focus_panel)

	var alpha_focus_margin = MarginContainer.new()
	alpha_focus_margin.add_theme_constant_override("margin_left", 8)
	alpha_focus_margin.add_theme_constant_override("margin_top", 8)
	alpha_focus_margin.add_theme_constant_override("margin_right", 8)
	alpha_focus_margin.add_theme_constant_override("margin_bottom", 8)
	alpha_focus_panel.add_child(alpha_focus_margin)

	var alpha_focus_stack = VBoxContainer.new()
	alpha_focus_stack.add_theme_constant_override("separation", 4)
	alpha_focus_margin.add_child(alpha_focus_stack)

	var alpha_focus_nav = HBoxContainer.new()
	alpha_focus_nav.add_theme_constant_override("separation", 6)
	alpha_focus_stack.add_child(alpha_focus_nav)

	alpha_focus_prev_button = Button.new()
	alpha_focus_prev_button.name = "AlphaFocusPrevButton"
	alpha_focus_prev_button.text = "<"
	alpha_focus_prev_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_prev_button.pressed.connect(_on_alpha_focus_prev_pressed)
	alpha_focus_nav.add_child(alpha_focus_prev_button)

	alpha_focus_title_label = Label.new()
	alpha_focus_title_label.name = "AlphaFocusTitleLabel"
	alpha_focus_title_label.text = "Alpha focus: -"
	alpha_focus_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alpha_focus_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	alpha_focus_nav.add_child(alpha_focus_title_label)

	alpha_focus_next_button = Button.new()
	alpha_focus_next_button.name = "AlphaFocusNextButton"
	alpha_focus_next_button.text = ">"
	alpha_focus_next_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_next_button.pressed.connect(_on_alpha_focus_next_pressed)
	alpha_focus_nav.add_child(alpha_focus_next_button)

	alpha_focus_body_label = Label.new()
	alpha_focus_body_label.name = "AlphaFocusBodyLabel"
	alpha_focus_body_label.text = ""
	alpha_focus_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alpha_focus_stack.add_child(alpha_focus_body_label)

	var alpha_focus_contrast_nav = HBoxContainer.new()
	alpha_focus_contrast_nav.name = "AlphaContrastNav"
	alpha_focus_contrast_nav.add_theme_constant_override("separation", 6)
	alpha_focus_stack.add_child(alpha_focus_contrast_nav)

	alpha_focus_contrast_prev_button = Button.new()
	alpha_focus_contrast_prev_button.name = "AlphaContrastPrevButton"
	alpha_focus_contrast_prev_button.text = "<"
	alpha_focus_contrast_prev_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_contrast_prev_button.tooltip_text = "Show the previous recommendation contrast sample for this focus case."
	alpha_focus_contrast_prev_button.pressed.connect(_on_alpha_contrast_prev_pressed)
	alpha_focus_contrast_nav.add_child(alpha_focus_contrast_prev_button)

	alpha_focus_contrast_status_label = Label.new()
	alpha_focus_contrast_status_label.name = "AlphaContrastStatusLabel"
	alpha_focus_contrast_status_label.text = "Contrast sample: -"
	alpha_focus_contrast_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alpha_focus_contrast_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	alpha_focus_contrast_nav.add_child(alpha_focus_contrast_status_label)

	alpha_focus_contrast_next_button = Button.new()
	alpha_focus_contrast_next_button.name = "AlphaContrastNextButton"
	alpha_focus_contrast_next_button.text = ">"
	alpha_focus_contrast_next_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_contrast_next_button.tooltip_text = "Show the next recommendation contrast sample for this focus case."
	alpha_focus_contrast_next_button.pressed.connect(_on_alpha_contrast_next_pressed)
	alpha_focus_contrast_nav.add_child(alpha_focus_contrast_next_button)

	alpha_focus_action_button = Button.new()
	alpha_focus_action_button.name = "AlphaFocusActionButton"
	alpha_focus_action_button.text = "Use action"
	alpha_focus_action_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_action_button.tooltip_text = "Apply the selected action queue case without changing balance data."
	alpha_focus_action_button.pressed.connect(_on_alpha_focus_action_pressed)
	alpha_focus_stack.add_child(alpha_focus_action_button)

	alpha_focus_apply_button = Button.new()
	alpha_focus_apply_button.name = "AlphaFocusApplyButton"
	alpha_focus_apply_button.text = "Use setup"
	alpha_focus_apply_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_apply_button.tooltip_text = "Apply this focus case's player count and lead class before beginning a run."
	alpha_focus_apply_button.pressed.connect(_on_alpha_focus_apply_pressed)
	alpha_focus_stack.add_child(alpha_focus_apply_button)

	alpha_focus_probe_button = Button.new()
	alpha_focus_probe_button.name = "AlphaFocusProbeButton"
	alpha_focus_probe_button.text = "Run probe"
	alpha_focus_probe_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_probe_button.tooltip_text = "Apply this focus case, place the opening defense, and run one wave."
	alpha_focus_probe_button.pressed.connect(_on_alpha_focus_probe_pressed)
	alpha_focus_stack.add_child(alpha_focus_probe_button)

	alpha_focus_probe_status_label = Label.new()
	alpha_focus_probe_status_label.name = "AlphaFocusProbeStatusLabel"
	alpha_focus_probe_status_label.text = ""
	alpha_focus_probe_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alpha_focus_stack.add_child(alpha_focus_probe_status_label)

	alpha_focus_manual_status_label = Label.new()
	alpha_focus_manual_status_label.name = "AlphaFocusManualStatusLabel"
	alpha_focus_manual_status_label.text = "Human review: -"
	alpha_focus_manual_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alpha_focus_stack.add_child(alpha_focus_manual_status_label)

	var alpha_focus_manual_row = HBoxContainer.new()
	alpha_focus_manual_row.add_theme_constant_override("separation", 6)
	alpha_focus_stack.add_child(alpha_focus_manual_row)

	alpha_focus_issue_tag_option = OptionButton.new()
	alpha_focus_issue_tag_option.name = "AlphaIssueTagOption"
	alpha_focus_issue_tag_option.focus_mode = Control.FOCUS_NONE
	alpha_focus_issue_tag_option.tooltip_text = "Choose a short reason tag before marking an issue."
	for label in ALPHA_ISSUE_TAG_LABELS:
		alpha_focus_issue_tag_option.add_item(label)
	alpha_focus_issue_tag_option.item_selected.connect(_on_alpha_issue_tag_selected)
	alpha_focus_manual_row.add_child(alpha_focus_issue_tag_option)

	alpha_focus_recommendation_contrast_option = OptionButton.new()
	alpha_focus_recommendation_contrast_option.name = "AlphaRecommendationContrastOption"
	alpha_focus_recommendation_contrast_option.focus_mode = Control.FOCUS_NONE
	alpha_focus_recommendation_contrast_option.tooltip_text = "Record which recommendation contrast branch was clearer during human review."
	for label in ALPHA_RECOMMENDATION_CONTRAST_LABELS:
		alpha_focus_recommendation_contrast_option.add_item(label)
	alpha_focus_recommendation_contrast_option.item_selected.connect(_on_alpha_recommendation_contrast_selected)
	alpha_focus_manual_row.add_child(alpha_focus_recommendation_contrast_option)

	var alpha_focus_recommendation_fix_check_row = HBoxContainer.new()
	alpha_focus_recommendation_fix_check_row.add_theme_constant_override("separation", 6)
	alpha_focus_stack.add_child(alpha_focus_recommendation_fix_check_row)
	for index in range(ALPHA_RECOMMENDATION_FIX_CHECK_IDS.size()):
		var check_id = str(ALPHA_RECOMMENDATION_FIX_CHECK_IDS[index])
		var recommendation_fix_check = CheckButton.new()
		recommendation_fix_check.name = _alpha_recommendation_fix_check_node_name(check_id)
		recommendation_fix_check.text = _alpha_recommendation_fix_check_label(check_id)
		recommendation_fix_check.focus_mode = Control.FOCUS_NONE
		recommendation_fix_check.tooltip_text = _alpha_recommendation_fix_check_tooltip(check_id)
		recommendation_fix_check.toggled.connect(_on_alpha_recommendation_fix_check_toggled.bind(check_id))
		alpha_focus_recommendation_fix_check_buttons.append(recommendation_fix_check)
		alpha_focus_recommendation_fix_check_row.add_child(recommendation_fix_check)

	alpha_focus_mark_clear_button = Button.new()
	alpha_focus_mark_clear_button.name = "AlphaFocusMarkClearButton"
	alpha_focus_mark_clear_button.text = "Mark clear"
	alpha_focus_mark_clear_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_mark_clear_button.tooltip_text = "Mark this focus case as checked by a human alpha pass."
	alpha_focus_mark_clear_button.pressed.connect(_on_alpha_focus_mark_clear_pressed)
	alpha_focus_manual_row.add_child(alpha_focus_mark_clear_button)

	alpha_focus_mark_issue_button = Button.new()
	alpha_focus_mark_issue_button.name = "AlphaFocusMarkIssueButton"
	alpha_focus_mark_issue_button.text = "Mark issue"
	alpha_focus_mark_issue_button.focus_mode = Control.FOCUS_NONE
	alpha_focus_mark_issue_button.tooltip_text = "Mark this focus case as needing a design or usability fix."
	alpha_focus_mark_issue_button.pressed.connect(_on_alpha_focus_mark_issue_pressed)
	alpha_focus_manual_row.add_child(alpha_focus_mark_issue_button)

	var alpha_coverage_label = Label.new()
	alpha_coverage_label.text = "Alpha coverage"
	side.add_child(alpha_coverage_label)

	alpha_coverage_panel = PanelContainer.new()
	alpha_coverage_panel.name = "AlphaCoveragePanel"
	side.add_child(alpha_coverage_panel)

	var alpha_coverage_margin = MarginContainer.new()
	alpha_coverage_margin.add_theme_constant_override("margin_left", 8)
	alpha_coverage_margin.add_theme_constant_override("margin_top", 8)
	alpha_coverage_margin.add_theme_constant_override("margin_right", 8)
	alpha_coverage_margin.add_theme_constant_override("margin_bottom", 8)
	alpha_coverage_panel.add_child(alpha_coverage_margin)

	var alpha_coverage_stack = VBoxContainer.new()
	alpha_coverage_stack.add_theme_constant_override("separation", 4)
	alpha_coverage_margin.add_child(alpha_coverage_stack)

	alpha_coverage_title_label = Label.new()
	alpha_coverage_title_label.name = "AlphaCoverageTitleLabel"
	alpha_coverage_title_label.text = "Alpha coverage: not run"
	alpha_coverage_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alpha_coverage_stack.add_child(alpha_coverage_title_label)

	alpha_coverage_body_label = Label.new()
	alpha_coverage_body_label.name = "AlphaCoverageBodyLabel"
	alpha_coverage_body_label.text = "Functional class checks are ready."
	alpha_coverage_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alpha_coverage_stack.add_child(alpha_coverage_body_label)

	alpha_coverage_run_button = Button.new()
	alpha_coverage_run_button.name = "RunAlphaCoverageButton"
	alpha_coverage_run_button.text = "Run coverage"
	alpha_coverage_run_button.focus_mode = Control.FOCUS_NONE
	alpha_coverage_run_button.tooltip_text = "Run fixed class smoke checks without changing the current run."
	alpha_coverage_run_button.pressed.connect(_on_alpha_coverage_run_pressed)
	alpha_coverage_stack.add_child(alpha_coverage_run_button)

	alpha_coverage_open_next_manual_button = Button.new()
	alpha_coverage_open_next_manual_button.name = "OpenAlphaNextManualButton"
	alpha_coverage_open_next_manual_button.text = "Open next manual"
	alpha_coverage_open_next_manual_button.focus_mode = Control.FOCUS_NONE
	alpha_coverage_open_next_manual_button.tooltip_text = "Jump to the next unreviewed human alpha case."
	alpha_coverage_open_next_manual_button.pressed.connect(_on_alpha_coverage_open_next_manual_pressed)
	alpha_coverage_stack.add_child(alpha_coverage_open_next_manual_button)

	alpha_coverage_open_issue_button = Button.new()
	alpha_coverage_open_issue_button.name = "OpenAlphaIssueButton"
	alpha_coverage_open_issue_button.text = "Open issue"
	alpha_coverage_open_issue_button.focus_mode = Control.FOCUS_NONE
	alpha_coverage_open_issue_button.tooltip_text = "Jump to the first human review case marked as an issue."
	alpha_coverage_open_issue_button.pressed.connect(_on_alpha_coverage_open_issue_pressed)
	alpha_coverage_stack.add_child(alpha_coverage_open_issue_button)

	alpha_coverage_open_fix_lane_button = Button.new()
	alpha_coverage_open_fix_lane_button.name = "OpenAlphaFixLaneButton"
	alpha_coverage_open_fix_lane_button.text = "Open fix lane"
	alpha_coverage_open_fix_lane_button.focus_mode = Control.FOCUS_NONE
	alpha_coverage_open_fix_lane_button.tooltip_text = "Jump to the representative case for the top issue tag."
	alpha_coverage_open_fix_lane_button.pressed.connect(_on_alpha_coverage_open_fix_lane_pressed)
	alpha_coverage_stack.add_child(alpha_coverage_open_fix_lane_button)

	alpha_coverage_open_recommendation_fix_button = Button.new()
	alpha_coverage_open_recommendation_fix_button.name = "OpenAlphaRecommendationFixButton"
	alpha_coverage_open_recommendation_fix_button.text = "Open rec fix"
	alpha_coverage_open_recommendation_fix_button.focus_mode = Control.FOCUS_NONE
	alpha_coverage_open_recommendation_fix_button.tooltip_text = "Jump to the representative case for the top recommendation wording issue."
	alpha_coverage_open_recommendation_fix_button.pressed.connect(_on_alpha_coverage_open_recommendation_fix_pressed)
	alpha_coverage_stack.add_child(alpha_coverage_open_recommendation_fix_button)

	alpha_coverage_probe_fix_lane_button = Button.new()
	alpha_coverage_probe_fix_lane_button.name = "ProbeAlphaFixLaneButton"
	alpha_coverage_probe_fix_lane_button.text = "Probe fix lane"
	alpha_coverage_probe_fix_lane_button.focus_mode = Control.FOCUS_NONE
	alpha_coverage_probe_fix_lane_button.tooltip_text = "Jump to the top fix lane and run its opening probe."
	alpha_coverage_probe_fix_lane_button.pressed.connect(_on_alpha_coverage_probe_fix_lane_pressed)
	alpha_coverage_stack.add_child(alpha_coverage_probe_fix_lane_button)

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
	start_wave_button.name = "StartWaveButton"
	start_wave_button.text = "Start wave"
	start_wave_button.focus_mode = Control.FOCUS_NONE
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	action_row.add_child(start_wave_button)

	stack_wave_button = Button.new()
	stack_wave_button.name = "CallNextButton"
	stack_wave_button.text = "Pull next wave"
	stack_wave_button.focus_mode = Control.FOCUS_NONE
	stack_wave_button.pressed.connect(_on_stack_wave_pressed)
	action_row.add_child(stack_wave_button)

	hold_stack_button = Button.new()
	hold_stack_button.name = "HoldStackButton"
	hold_stack_button.text = "Hold pull"
	hold_stack_button.focus_mode = Control.FOCUS_NONE
	hold_stack_button.pressed.connect(_on_hold_stack_vote_pressed)
	action_row.add_child(hold_stack_button)

	step_wave_button = Button.new()
	step_wave_button.name = "StepWaveButton"
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

	action_status_label = Label.new()
	action_status_label.name = "ActionStatusLabel"
	action_status_label.text = "Actions: -"
	action_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(action_status_label)

	wave_readiness_label = Label.new()
	wave_readiness_label.name = "WaveReadinessLabel"
	wave_readiness_label.text = "Wave readiness: -"
	wave_readiness_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(wave_readiness_label)

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

	log_filter_option = OptionButton.new()
	log_filter_option.name = "LogFilterOption"
	log_filter_option.tooltip_text = "Choose which activity type to show."
	log_filter_option.focus_mode = Control.FOCUS_NONE
	for label in LOG_FILTER_LABELS:
		log_filter_option.add_item(label)
	log_filter_option.item_selected.connect(_on_log_filter_selected)
	log_row.add_child(log_filter_option)

	important_log_toggle = CheckButton.new()
	important_log_toggle.name = "ImportantLogToggle"
	important_log_toggle.text = "Important"
	important_log_toggle.tooltip_text = "Show only activity that needs attention."
	important_log_toggle.focus_mode = Control.FOCUS_NONE
	important_log_toggle.button_pressed = show_important_logs_only
	important_log_toggle.toggled.connect(_on_important_log_toggled)
	log_row.add_child(important_log_toggle)

	log_label = Label.new()
	log_label.name = "ActivityLogLabel"
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
		run_config_lock_snapshot.clear()
		show_debug_log = simulation.get_show_debug_logs_default()
		_clear_autoplay_focus_queue()
		_clear_hand_ready_cue()
		_clear_discard_follow_up()
		_clear_combat_follow_up()
		_rebuild_class_buttons()
		wave_timer.wait_time = simulation.get_auto_step_interval()
		debug_log.push("m0_test_data.json loaded: %s" % simulation.describe_loaded_data())
	else:
		selected_class_id = ""
		run_started = false
		run_config_lock_snapshot.clear()
		show_debug_log = true
		_clear_autoplay_focus_queue()
		_clear_hand_ready_cue()
		_clear_discard_follow_up()
		_clear_combat_follow_up()
		debug_log.push("Data load failed: %s" % simulation.last_error)


func _refresh_screen() -> void:
	card_target_report_cache.clear()
	_refresh_run_setup()
	_refresh_player_buttons()
	_refresh_class_buttons()
	_refresh_build_buttons()
	_refresh_cards()
	_refresh_selected_card()
	_refresh_use_best_target_button()
	_refresh_setup_plan_button()
	_refresh_rewards()
	_refresh_status()
	_refresh_tactical_hint()
	_refresh_risk_ping_buttons()
	_refresh_wave_readiness()
	_refresh_round_recap()
	_refresh_alpha_focus_panel()
	_refresh_alpha_coverage_panel()
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
	if run_started and not run_config_lock_snapshot.is_empty():
		setup_summary_label.text = "Setup locked: %s" % _run_config_lock_summary()
	else:
		setup_summary_label.text = "Setup: %s" % simulation.get_run_setup_summary(player_count, selected_class_id)
	if begin_run_button != null:
		begin_run_button.disabled = run_started
		begin_run_button.text = "Run active" if run_started else "Begin run"


func _build_run_config_lock_snapshot(setup_report: Dictionary) -> Dictionary:
	var locked_player_count = clamp(int(setup_report.get("player_count", player_count)), 1, 4)
	var active_directions = _string_values_from_array(setup_report.get("active_directions", []))
	if active_directions.is_empty() and simulation.is_loaded():
		active_directions = _string_values_from_array(simulation.get_active_directions(locked_player_count))
	var class_id = str(setup_report.get("class_id", selected_class_id))
	return {
		"ok": true,
		"playerCountAtStart": locked_player_count,
		"activeDirections": active_directions,
		"scalingProfileId": "m0_active_fronts_%sp" % locked_player_count,
		"seed": "m0_local_debug_seed",
		"selectedMode": "m0_prototype",
		"leadClassId": class_id,
		"classIdsByPlayer": [class_id],
		"classLabel": str(setup_report.get("class_label", _class_label(class_id))),
		"lockedAtLocal": Time.get_time_string_from_system(),
		"immutableFields": [
			"playerCountAtStart",
			"activeDirections",
			"scalingProfileId",
			"seed",
			"selectedMode",
			"classIdsByPlayer",
		],
	}


func _run_player_count() -> int:
	if run_started and not run_config_lock_snapshot.is_empty():
		return clamp(int(run_config_lock_snapshot.get("playerCountAtStart", player_count)), 1, 4)

	return clamp(player_count, 1, 4)


func _run_active_directions() -> Array:
	if run_started and not run_config_lock_snapshot.is_empty():
		var locked_directions = _string_values_from_array(run_config_lock_snapshot.get("activeDirections", []))
		if not locked_directions.is_empty():
			return locked_directions

	if not simulation.is_loaded():
		return []

	return _string_values_from_array(simulation.get_active_directions(_run_player_count()))


func _run_config_lock_summary() -> String:
	if run_config_lock_snapshot.is_empty():
		return "not locked"

	return "%sP | fronts: %s | class: %s | scaling: %s" % [
		_run_player_count(),
		_join_values(_run_active_directions()),
		run_config_lock_snapshot.get("classLabel", _class_label(str(run_config_lock_snapshot.get("leadClassId", selected_class_id)))),
		run_config_lock_snapshot.get("scalingProfileId", "m0_active_fronts"),
	]


func _run_config_lock_telemetry_summary() -> String:
	if run_config_lock_snapshot.is_empty():
		return "missing"

	return "playerCountAtStart=%s activeDirections=%s scalingProfileId=%s seed=%s selectedMode=%s classIdsByPlayer=%s" % [
		_run_player_count(),
		_join_values(_run_active_directions()),
		run_config_lock_snapshot.get("scalingProfileId", "m0_active_fronts"),
		run_config_lock_snapshot.get("seed", "unknown"),
		run_config_lock_snapshot.get("selectedMode", "unknown"),
		_join_values(_string_values_from_array(run_config_lock_snapshot.get("classIdsByPlayer", []))),
	]


func _format_wave_started_lock_trace(result: Dictionary) -> String:
	var wave_report: Dictionary = result.get("wave_started", {})
	var directions = _string_values_from_array(wave_report.get("directions", result.get("directions", [])))
	var enemy_groups = _string_values_from_array(wave_report.get("enemyGroups", result.get("enemyGroups", [])))
	var preview_card: Dictionary = wave_report.get("previewCard", {})
	return "wave_started: day=%s playerCountAtStart=%s activeDirections=%s directions=%s enemyGroups=%s previewCardId=%s intent=%s role=%s" % [
		wave_report.get("day", simulation.get_active_round()),
		_run_player_count(),
		_join_values(_run_active_directions()),
		_join_values(directions),
		_join_values(enemy_groups),
		wave_report.get("previewCardId", ""),
		preview_card.get("waveIntentId", "-"),
		preview_card.get("primaryEnemyRole", "-"),
	]


func _format_wave_stack_contract_trace(result: Dictionary) -> String:
	var stack_report: Dictionary = result.get("wave_stack", {})
	if stack_report.is_empty():
		return "wave_stacked: contract missing"

	var active_directions = _string_values_from_array(stack_report.get("activeDirections", []))
	var directions = _string_values_from_array(stack_report.get("directions", []))
	var stacked_rounds = _string_values_from_array(stack_report.get("stackedRounds", []))
	var settlement_batch: Dictionary = stack_report.get("settlementBatch", {})
	var reward_packet_ids = _string_values_from_array(settlement_batch.get("rewardPacketIds", []))
	var forbidden_reward_fields = _string_values_from_array(stack_report.get("forbiddenRewardFields", []))
	var preview_card: Dictionary = stack_report.get("previewCard", {})
	return "wave_stacked: pulledRound=%s stackDepth=%s activeDirections=%s directions=%s stackedRounds=%s previewCardId=%s intent=%s role=%s settlementPackets=%s noBonusRewards=%s forbiddenRewardFields=%s" % [
		stack_report.get("pulledRound", result.get("round", "?")),
		stack_report.get("stackDepth", result.get("stack_depth", "?")),
		_join_values(active_directions),
		_join_values(directions),
		_join_values(stacked_rounds),
		stack_report.get("previewCardId", ""),
		preview_card.get("waveIntentId", "-"),
		preview_card.get("primaryEnemyRole", "-"),
		_join_values(reward_packet_ids),
		stack_report.get("noBonusRewards", true),
		_join_values(forbidden_reward_fields),
	]


func _format_wave_stack_vote_session_trace(result: Dictionary) -> String:
	var vote_session: Dictionary = result.get("voteSession", {})
	if vote_session.is_empty():
		return "wave_stack_vote: session missing"

	var candidate_spawn_plan_ids = _string_values_from_array(vote_session.get("candidateSpawnPlanIds", []))
	var preview_card_ids = _string_values_from_array(vote_session.get("previewCardIds", []))
	var yes_player_ids = _string_values_from_array(vote_session.get("yesPlayerIds", []))
	var hold_player_ids = _string_values_from_array(vote_session.get("holdPlayerIds", []))
	var forbidden_reward_fields = _string_values_from_array(vote_session.get("forbiddenRewardFields", []))
	return "wave_stack_vote: id=%s action=%s consent=%s yes=%s hold=%s candidateSpawnPlanIds=%s previewCardIds=%s timeoutAction=%s noBonusRewards=%s forbiddenRewardFields=%s" % [
		vote_session.get("id", ""),
		vote_session.get("resolvedAction", "open"),
		vote_session.get("requiredConsentMode", ""),
		_join_values(yes_player_ids),
		_join_values(hold_player_ids),
		_join_values(candidate_spawn_plan_ids),
		_join_values(preview_card_ids),
		vote_session.get("timeoutAction", "hold"),
		vote_session.get("noBonusRewards", true),
		_join_values(forbidden_reward_fields),
	]


func _format_shop_purchase_vote_session_trace(result: Dictionary) -> String:
	var vote_session: Dictionary = result.get("voteSession", {})
	if vote_session.is_empty():
		return "shop_purchase_vote: session missing"

	var yes_player_ids = _string_values_from_array(vote_session.get("yesPlayerIds", []))
	var hold_player_ids = _string_values_from_array(vote_session.get("holdPlayerIds", []))
	return "shop_purchase_vote: id=%s action=%s consent=%s yes=%s hold=%s option=%s label=%s goldCost=%s bossShardCost=%s artifactActionCost=%s timeoutAction=%s default=%s" % [
		vote_session.get("id", ""),
		vote_session.get("resolvedAction", "open"),
		vote_session.get("requiredConsentMode", ""),
		_join_values(yes_player_ids),
		_join_values(hold_player_ids),
		vote_session.get("optionKey", ""),
		vote_session.get("label", ""),
		vote_session.get("goldCost", 0),
		vote_session.get("bossShardCost", 0),
		vote_session.get("artifactActionCost", 0),
		vote_session.get("timeoutAction", "decline"),
		vote_session.get("timeoutDefaultResult", "no_purchase"),
	]


func _format_reward_choice_lock_trace(result: Dictionary) -> String:
	var lock: Dictionary = result.get("rewardChoiceLock", {})
	if lock.is_empty():
		return "reward_choice_locked: lock missing"

	var forbidden_lock_tags = _string_values_from_array(lock.get("forbiddenLockTags", []))
	return "reward_choice_locked: id=%s packet=%s batch=%s player=%s choice=%s card=%s gold=%s temporary=%s noBonusRewards=%s forbiddenLockTags=%s" % [
		lock.get("id", ""),
		lock.get("rewardPacketId", ""),
		lock.get("settlementBatchId", ""),
		lock.get("playerId", "player_1"),
		lock.get("choiceType", ""),
		lock.get("chosenCardId", ""),
		lock.get("declineGoldAdded", 0),
		lock.get("isTemporary", false),
		lock.get("noBonusRewards", true),
		_join_values(forbidden_lock_tags),
	]


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
		_clear_hand_ready_cue()
		resource_label.text = "Resources: -"
		for button in card_buttons:
			button.visible = false
		if discard_card_button != null:
			_refresh_discard_button()
		return

	if not run_started:
		_clear_hand_ready_cue()
		resource_label.text = "Resources: begin the run to draw your opening hand\n%s" % simulation.get_round_preparation_summary(player_count)
		for button in card_buttons:
			button.visible = false
			button.button_pressed = false
		if discard_card_button != null:
			_refresh_discard_button()
		return

	var hand = simulation.get_hand()
	if selected_card_index >= hand.size():
		selected_card_index = -1

	_update_hand_ready_cue(hand)
	var discard_report = _discard_action_report()
	resource_label.text = "Resources: %s\n%s\n%s\n%s\n%s\n%s\n%s\n%s" % [
		simulation.get_resource_summary(),
		simulation.get_last_kill_resource_summary(),
		simulation.get_class_effect_summary(),
		simulation.get_hand_pressure_summary(),
		simulation.get_deck_cycle_summary(),
		simulation.get_economy_summary(),
		simulation.get_round_preparation_summary(player_count),
		_hand_plan_summary(),
	]

	for index in range(card_buttons.size()):
		var button: Button = card_buttons[index]
		if index >= hand.size():
			button.visible = false
			button.button_pressed = false
			button.tooltip_text = ""
			continue

		var card_id = str(hand[index])
		var card = simulation.get_card_data(card_id)
		var cost = int(card.get("cost", 0))
		button.visible = true
		button.text = "%s [%s] - %s" % [
			card.get("label", card_id),
			cost,
			_card_button_state_label(card_id, index, discard_report),
		]
		button.disabled = false
		button.button_pressed = index == selected_card_index
		button.tooltip_text = _card_button_tooltip(card_id, index, discard_report)

	_refresh_discard_button()


func _refresh_selected_card() -> void:
	if selected_card_label == null:
		return

	if not simulation.is_loaded():
		selected_card_label.text = "Selected card: -"
		return

	if not run_started:
		selected_card_label.text = "Selected card: begin the run first"
		return

	var hand = simulation.get_hand()
	if hand.is_empty():
		selected_card_label.text = "Selected card: hand empty\nStart the next wave to receive round prep draw."
		return

	var card_id = _selected_card_id()
	if card_id.is_empty():
		selected_card_label.text = "Selected card: none\nChoose a hand card to preview its role, effect, and targets."
		return

	selected_card_label.text = _selected_card_status_text(card_id)


func _refresh_use_best_target_button() -> void:
	if use_best_target_button == null:
		return

	var report = _best_target_action_report()
	report = _best_target_report_with_discard_follow_up(report)
	report = _best_target_report_with_combat_follow_up(report)
	use_best_target_button.disabled = not bool(report.get("ok", false))
	use_best_target_button.text = str(report.get("button_text", "Use best target"))
	use_best_target_button.tooltip_text = str(report.get("summary", report.get("reason", "")))


func _refresh_discard_button() -> void:
	if discard_card_button == null:
		return

	var report = _discard_action_report()
	discard_card_button.disabled = not bool(report.get("ok", false))
	discard_card_button.text = str(report.get("button_text", "Discard selected"))
	discard_card_button.tooltip_text = str(report.get("summary", report.get("reason", "")))


func _refresh_setup_plan_button() -> void:
	if setup_plan_button == null:
		return

	var report = _setup_plan_action_report()
	setup_plan_button.disabled = not bool(report.get("ok", false))
	setup_plan_button.text = str(report.get("button_text", "Use setup plan"))
	setup_plan_button.tooltip_text = str(report.get("summary", report.get("reason", "")))


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
		for button in artifact_replace_buttons:
			button.visible = false
			button.tooltip_text = ""
		for button in artifact_release_buttons:
			button.visible = false
			button.tooltip_text = ""
		for button in shop_buttons:
			button.visible = false
			button.tooltip_text = ""
		_reset_shop_reactivation_buttons()
		if skip_reward_button != null:
			skip_reward_button.visible = false
		if skip_artifact_button != null:
			skip_artifact_button.visible = false
		selected_artifact_replacement_offer_id = ""
		selected_dormant_artifact_release_id = ""
		_clear_shop_reactivation_selection()
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
		for button in artifact_replace_buttons:
			button.visible = false
			button.tooltip_text = ""
		for button in artifact_release_buttons:
			button.visible = false
			button.tooltip_text = ""
		for button in shop_buttons:
			button.visible = false
			button.tooltip_text = ""
		_reset_shop_reactivation_buttons()
		if skip_reward_button != null:
			skip_reward_button.visible = false
		if skip_artifact_button != null:
			skip_artifact_button.visible = false
		selected_artifact_replacement_offer_id = ""
		selected_dormant_artifact_release_id = ""
		_clear_shop_reactivation_selection()
		if skip_shop_button != null:
			skip_shop_button.visible = false
		return

	var offer = simulation.get_reward_offer()
	var reward_recommendation = simulation.get_reward_recommendation_report(player_count, selected_class_id)
	if reward_status_label != null:
		reward_status_label.text = simulation.get_reward_offer_summary(player_count, selected_class_id)

	for index in range(reward_buttons.size()):
		var button: Button = reward_buttons[index]
		if index >= offer.size():
			button.visible = false
			button.tooltip_text = ""
			continue

		var card_id = str(offer[index])
		var report = simulation.get_card_reward_report(card_id)
		var recommended = (
			bool(reward_recommendation.get("ok", false))
			and str(reward_recommendation.get("choice_type", "card")) == "card"
			and str(reward_recommendation.get("card_id", "")) == card_id
		)
		if recommended:
			report["recommended"] = true
			report["recommendation_reason"] = reward_recommendation.get("reason_text", "")
			report["recommendation_detail"] = reward_recommendation.get("detail_text", "")
			report["recommendation_summary"] = reward_recommendation.get("summary", "")
			report["recommendation_rewrite_preset"] = _alpha_reward_recommendation_rewrite_preset_text(reward_recommendation)
		button.visible = true
		button.text = _reward_button_text(report)
		button.tooltip_text = _reward_button_tooltip(report)

	if skip_reward_button != null:
		skip_reward_button.visible = not offer.is_empty()
		if offer.is_empty():
			skip_reward_button.tooltip_text = ""
		else:
			var card_reward_gold = simulation.get_card_reward_gold()
			if card_reward_gold > 0:
				skip_reward_button.text = "Take gold +%s" % card_reward_gold
			else:
				skip_reward_button.text = "Take gold"
			var gold_recommended = bool(reward_recommendation.get("ok", false)) and str(reward_recommendation.get("choice_type", "")) == "gold"
			var gold_recommendation_text = ""
			if gold_recommended:
				skip_reward_button.text = "Suggested %s" % skip_reward_button.text
				gold_recommendation_text = " Suggested: %s | Why now: %s" % [
					reward_recommendation.get("reason_text", "keeps the deck lean"),
					reward_recommendation.get("detail_text", simulation.get_card_reward_gold_choice_summary()),
				]
				var gold_rewrite_preset = _alpha_reward_recommendation_rewrite_preset_text(reward_recommendation)
				if not gold_rewrite_preset.is_empty():
					gold_recommendation_text += " | Discussion prompt: %s" % gold_rewrite_preset
			skip_reward_button.tooltip_text = "Take gold instead of adding a card. This is a normal reward choice. %s%s" % [
				simulation.get_card_reward_gold_choice_summary(),
				gold_recommendation_text,
			]

	var artifact_offer = simulation.get_artifact_offer()
	if artifact_offer.is_empty() or not artifact_offer.has(selected_artifact_replacement_offer_id):
		selected_artifact_replacement_offer_id = ""
		selected_dormant_artifact_release_id = ""
	var artifact_recommendation = simulation.get_artifact_recommendation_report()
	for index in range(artifact_buttons.size()):
		var button: Button = artifact_buttons[index]
		if index >= artifact_offer.size():
			button.visible = false
			button.tooltip_text = ""
			continue

		var artifact_id = str(artifact_offer[index])
		var report = simulation.get_artifact_reward_report(artifact_id)
		var artifact_recommended = bool(artifact_recommendation.get("ok", false)) and str(artifact_recommendation.get("artifact_id", "")) == artifact_id
		if artifact_recommended:
			report["recommended"] = true
			report["recommendation_reason"] = artifact_recommendation.get("reason_text", "")
			report["recommendation_detail"] = artifact_recommendation.get("detail_text", "")
			report["recommendation_summary"] = artifact_recommendation.get("summary", "")
			report["recommendation_rewrite_preset"] = _alpha_artifact_recommendation_rewrite_preset_text(artifact_recommendation)
		button.visible = true
		button.text = _artifact_button_text(report)
		button.disabled = not bool(report.get("can_claim", true))
		button.tooltip_text = _artifact_button_tooltip(report)

	_refresh_artifact_replace_buttons()
	_refresh_artifact_release_buttons()

	if skip_artifact_button != null:
		skip_artifact_button.visible = not artifact_offer.is_empty()
		if artifact_offer.is_empty():
			skip_artifact_button.text = "Keep current artifacts"
			skip_artifact_button.tooltip_text = ""
		elif selected_artifact_replacement_offer_id.is_empty():
			skip_artifact_button.text = "Keep current artifacts"
			skip_artifact_button.tooltip_text = "Close this artifact offer without changing party passives. This is a normal choice. %s" % simulation.get_artifact_loadout_summary()
		else:
			var declined_artifact_label = simulation.get_artifact_label(selected_artifact_replacement_offer_id)
			var release_note = ""
			if not selected_dormant_artifact_release_id.is_empty():
				release_note = " No dormant artifact is released."
			skip_artifact_button.text = "Keep current\nDecline %s" % declined_artifact_label
			skip_artifact_button.tooltip_text = "Keep the current equipped artifacts and decline %s.%s This is valid when the new passive does not fit the next pressure. %s" % [
				declined_artifact_label,
				release_note,
				simulation.get_artifact_loadout_summary(),
			]
	if artifact_status_label != null:
		if artifact_offer.is_empty():
			artifact_status_label.text = "Artifact: %s" % simulation.get_artifact_loadout_summary()
		else:
			artifact_status_label.text = simulation.get_artifact_offer_summary()

	var shop_options = simulation.get_shop_option_reports(player_count, selected_class_id)
	var shop_recommendation = simulation.get_shop_recommendation_report(player_count, selected_class_id)
	if shop_status_label != null:
		shop_status_label.text = simulation.get_shop_offer_summary(player_count, selected_class_id)
	_refresh_shop_reactivation_buttons(shop_options)

	for index in range(shop_buttons.size()):
		var button: Button = shop_buttons[index]
		if index >= shop_options.size():
			button.visible = false
			button.tooltip_text = ""
			continue

		var shop_report: Dictionary = shop_options[index]
		if str(shop_report.get("service_type", "")) == "reactivate_dormant_artifact":
			shop_report = _shop_reactivation_report_for_button(shop_report)
		var shop_recommended = bool(shop_recommendation.get("ok", false)) and int(shop_recommendation.get("index", -1)) == index
		if shop_recommended:
			shop_report["recommended"] = true
			shop_report["recommendation_reason"] = shop_recommendation.get("reason_text", "")
			shop_report["recommendation_detail"] = shop_recommendation.get("detail_text", "")
			shop_report["recommendation_summary"] = shop_recommendation.get("summary", "")
			shop_report["recommendation_rewrite_preset"] = _alpha_shop_recommendation_rewrite_preset_text(shop_recommendation)
		shop_report = _shop_vote_report_for_button(shop_report)
		button.visible = true
		button.text = _shop_button_text(shop_report)
		button.disabled = not bool(shop_report.get("can_buy", shop_report.get("can_remove", false)))
		button.tooltip_text = _shop_button_tooltip(shop_report)

	if skip_shop_button != null:
		skip_shop_button.visible = simulation.has_open_shop_offer()
		if simulation.has_active_shop_purchase_vote():
			skip_shop_button.text = "Hold shop vote"
			skip_shop_button.tooltip_text = "Close the active shop vote without spending gold, boss shards, artifact action, or purchase limit. %s" % simulation.get_shop_purchase_vote_summary(player_count)
		else:
			skip_shop_button.text = "Skip shop"
			skip_shop_button.tooltip_text = "Leave this shop without a purchase."


func _refresh_artifact_replace_buttons() -> void:
	for button in artifact_replace_buttons:
		button.visible = false
		button.disabled = false
		button.tooltip_text = ""

	if artifact_replace_buttons.is_empty():
		return
	if selected_artifact_replacement_offer_id.is_empty():
		return
	if not simulation.get_artifact_offer().has(selected_artifact_replacement_offer_id):
		selected_artifact_replacement_offer_id = ""
		selected_dormant_artifact_release_id = ""
		return

	var slot_report: Dictionary = simulation.get_artifact_slot_report()
	if not bool(slot_report.get("slots_full", false)):
		return

	var equipped_artifacts = simulation.get_equipped_artifacts()
	var dormant_artifacts = simulation.get_dormant_artifacts()
	if not selected_dormant_artifact_release_id.is_empty() and not dormant_artifacts.has(selected_dormant_artifact_release_id):
		selected_dormant_artifact_release_id = ""
	var new_label = simulation.get_artifact_label(selected_artifact_replacement_offer_id)
	var new_effect = simulation.get_artifact_effect_summary(selected_artifact_replacement_offer_id)
	var dormant_full = bool(slot_report.get("dormant_full", false))
	var release_ready = dormant_full and not selected_dormant_artifact_release_id.is_empty()
	var release_label = simulation.get_artifact_label(selected_dormant_artifact_release_id) if release_ready else ""
	var action_available = simulation.get_artifact_actions_remaining() > 0
	for index in range(artifact_replace_buttons.size()):
		var button: Button = artifact_replace_buttons[index]
		if index >= equipped_artifacts.size():
			continue

		var old_artifact_id = str(equipped_artifacts[index])
		var old_label = simulation.get_artifact_label(old_artifact_id)
		button.visible = true
		button.text = "Replace %s\nEquip %s" % [
			old_label,
			new_label,
		]
		button.disabled = (not action_available) or (dormant_full and not release_ready)
		var state_text = "Ready: %s becomes dormant." % old_label
		if not action_available:
			state_text = "Blocked: artifact action already used this maintenance."
		elif dormant_full and release_ready:
			state_text = "Ready: %s becomes dormant, %s is released with no refund." % [
				old_label,
				release_label,
			]
		elif dormant_full:
			state_text = "Blocked: dormant storage full. Release one dormant artifact first, or keep current."
		button.tooltip_text = "%s Equip %s. New passive: %s | %s" % [
			state_text,
			new_label,
			new_effect,
			slot_report.get("summary", simulation.get_artifact_loadout_summary()),
		]


func _refresh_artifact_release_buttons() -> void:
	for button in artifact_release_buttons:
		button.visible = false
		button.disabled = false
		button.tooltip_text = ""

	if artifact_release_buttons.is_empty():
		return
	if selected_artifact_replacement_offer_id.is_empty():
		return
	if not simulation.get_artifact_offer().has(selected_artifact_replacement_offer_id):
		selected_dormant_artifact_release_id = ""
		return

	var slot_report: Dictionary = simulation.get_artifact_slot_report()
	if not bool(slot_report.get("slots_full", false)) or not bool(slot_report.get("dormant_full", false)):
		selected_dormant_artifact_release_id = ""
		return

	var dormant_artifacts = simulation.get_dormant_artifacts()
	if not selected_dormant_artifact_release_id.is_empty() and not dormant_artifacts.has(selected_dormant_artifact_release_id):
		selected_dormant_artifact_release_id = ""

	for index in range(artifact_release_buttons.size()):
		var button: Button = artifact_release_buttons[index]
		if index >= dormant_artifacts.size():
			continue

		var dormant_artifact_id = str(dormant_artifacts[index])
		var dormant_label = simulation.get_artifact_label(dormant_artifact_id)
		var selected_prefix = "Selected release" if selected_dormant_artifact_release_id == dormant_artifact_id else "Release"
		button.visible = true
		button.text = "%s %s\nFree dormant slot" % [
			selected_prefix,
			dormant_label,
		]
		button.tooltip_text = "Release %s with no refund, then choose which equipped artifact becomes dormant. Current: %s" % [
			dormant_label,
			slot_report.get("summary", simulation.get_artifact_loadout_summary()),
		]


func _clear_shop_reactivation_selection() -> void:
	selected_shop_reactivation_dormant_artifact_id = ""
	selected_shop_reactivation_replaced_artifact_id = ""


func _reset_shop_reactivation_buttons() -> void:
	for button in shop_reactivate_dormant_buttons:
		button.visible = false
		button.disabled = false
		button.tooltip_text = ""
	for button in shop_reactivate_replace_buttons:
		button.visible = false
		button.disabled = false
		button.tooltip_text = ""


func _shop_reactivation_service_report_from_options(shop_options: Array) -> Dictionary:
	for option in shop_options:
		if typeof(option) != TYPE_DICTIONARY:
			continue

		var report: Dictionary = option
		if str(report.get("shop_option_type", "")) == "service" and str(report.get("service_type", "")) == "reactivate_dormant_artifact":
			return report.duplicate(true)

	return {}


func _refresh_shop_reactivation_buttons(shop_options: Array) -> void:
	_reset_shop_reactivation_buttons()
	if not run_started or not simulation.has_open_shop_offer():
		_clear_shop_reactivation_selection()
		return

	var service_report = _shop_reactivation_service_report_from_options(shop_options)
	if service_report.is_empty():
		_clear_shop_reactivation_selection()
		return

	var dormant_artifacts = simulation.get_dormant_artifacts()
	var equipped_artifacts = simulation.get_equipped_artifacts()
	if not selected_shop_reactivation_dormant_artifact_id.is_empty() and not dormant_artifacts.has(selected_shop_reactivation_dormant_artifact_id):
		_clear_shop_reactivation_selection()
	if not selected_shop_reactivation_replaced_artifact_id.is_empty() and not equipped_artifacts.has(selected_shop_reactivation_replaced_artifact_id):
		selected_shop_reactivation_replaced_artifact_id = ""

	var slot_report: Dictionary = simulation.get_artifact_slot_report()
	var slots_full = bool(slot_report.get("slots_full", false))
	if not slots_full:
		selected_shop_reactivation_replaced_artifact_id = ""

	var cost_text = "%s boss shard, artifact action %s/%s" % [
		service_report.get("boss_shard_cost", 0),
		simulation.get_artifact_actions_remaining(),
		simulation.get_artifact_action_limit(),
	]
	for index in range(shop_reactivate_dormant_buttons.size()):
		var button: Button = shop_reactivate_dormant_buttons[index]
		if index >= dormant_artifacts.size():
			continue

		var dormant_artifact_id = str(dormant_artifacts[index])
		var dormant_label = simulation.get_artifact_label(dormant_artifact_id)
		var dormant_effect = simulation.get_artifact_effect_summary(dormant_artifact_id)
		var selected_prefix = "Selected dormant" if selected_shop_reactivation_dormant_artifact_id == dormant_artifact_id else "Reactivate"
		button.visible = true
		button.text = "%s %s\nEffect off -> on" % [
			selected_prefix,
			dormant_label,
		]
		button.tooltip_text = "Choose %s for dormant reactivation. Passive: %s | Cost: %s. %s" % [
			dormant_label,
			dormant_effect,
			cost_text,
			slot_report.get("summary", simulation.get_artifact_loadout_summary()),
		]

	if selected_shop_reactivation_dormant_artifact_id.is_empty() or not dormant_artifacts.has(selected_shop_reactivation_dormant_artifact_id):
		return
	if not slots_full:
		return

	var dormant_label = simulation.get_artifact_label(selected_shop_reactivation_dormant_artifact_id)
	for index in range(shop_reactivate_replace_buttons.size()):
		var button: Button = shop_reactivate_replace_buttons[index]
		if index >= equipped_artifacts.size():
			continue

		var equipped_artifact_id = str(equipped_artifacts[index])
		var equipped_label = simulation.get_artifact_label(equipped_artifact_id)
		var equipped_effect = simulation.get_artifact_effect_summary(equipped_artifact_id)
		var selected_prefix = "Selected swap" if selected_shop_reactivation_replaced_artifact_id == equipped_artifact_id else "Make dormant"
		button.visible = true
		button.text = "%s %s\nReactivate %s" % [
			selected_prefix,
			equipped_label,
			dormant_label,
		]
		button.tooltip_text = "Choose %s to become dormant while %s returns to the equipped loadout. Current passive: %s | %s" % [
			equipped_label,
			dormant_label,
			equipped_effect,
			slot_report.get("summary", simulation.get_artifact_loadout_summary()),
		]


func _shop_reactivation_report_for_button(shop_report: Dictionary) -> Dictionary:
	if str(shop_report.get("service_type", "")) != "reactivate_dormant_artifact":
		return shop_report

	var service_id = str(shop_report.get("service_id", ""))
	var report = simulation.get_shop_service_report(
		service_id,
		selected_shop_reactivation_dormant_artifact_id,
		selected_shop_reactivation_replaced_artifact_id
	)
	report["shop_option_index"] = shop_report.get("shop_option_index", -1)
	var recommendation_keys = [
		"recommended",
		"recommendation_reason",
		"recommendation_detail",
		"recommendation_summary",
		"recommendation_rewrite_preset",
	]
	for key in recommendation_keys:
		if shop_report.has(key):
			report[key] = shop_report[key]

	var current_reason = str(report.get("reason", "ok"))
	var dormant_artifacts = simulation.get_dormant_artifacts()
	if current_reason != "artifact_action_unavailable" and selected_shop_reactivation_dormant_artifact_id.is_empty() and not dormant_artifacts.is_empty():
		report["can_buy"] = false
		report["reason"] = "reactivation_dormant_target_required"
		report["purchase_preview"] = "Choose a dormant artifact first, then buy this service. %s" % simulation.get_artifact_loadout_summary()
		report["dormant_artifact_id"] = ""
		report["dormant_artifact_label"] = ""
		report["dormant_artifact_effect"] = ""
		report["replaced_artifact_id"] = ""
		report["replaced_artifact_label"] = ""
		report["replaced_artifact_effect"] = ""
		return report

	var slot_report: Dictionary = simulation.get_artifact_slot_report()
	current_reason = str(report.get("reason", "ok"))
	if current_reason != "artifact_action_unavailable" and bool(slot_report.get("slots_full", false)) and selected_shop_reactivation_replaced_artifact_id.is_empty():
		report["can_buy"] = false
		report["reason"] = "reactivation_swap_target_required"
		report["purchase_preview"] = "Choose which equipped artifact becomes dormant, then buy this service. %s" % slot_report.get("summary", simulation.get_artifact_loadout_summary())

	return report


func _shop_reactivation_selection_ready(shop_report: Dictionary) -> bool:
	if str(shop_report.get("service_type", "")) != "reactivate_dormant_artifact":
		return true
	if selected_shop_reactivation_dormant_artifact_id.is_empty():
		return false
	if not simulation.get_dormant_artifacts().has(selected_shop_reactivation_dormant_artifact_id):
		return false

	var slot_report: Dictionary = simulation.get_artifact_slot_report()
	if bool(slot_report.get("slots_full", false)):
		return not selected_shop_reactivation_replaced_artifact_id.is_empty() and simulation.get_equipped_artifacts().has(selected_shop_reactivation_replaced_artifact_id)

	return selected_shop_reactivation_replaced_artifact_id.is_empty()


func _shop_vote_report_for_button(shop_report: Dictionary) -> Dictionary:
	if not simulation.has_active_shop_purchase_vote():
		return shop_report

	var report = shop_report.duplicate(true)
	var vote_session = simulation.get_active_shop_purchase_vote_session()
	var option_key = simulation.get_shop_purchase_option_key(
		report,
		selected_shop_reactivation_dormant_artifact_id,
		selected_shop_reactivation_replaced_artifact_id
	)
	var active_key = str(vote_session.get("optionKey", ""))
	var vote_summary = simulation.get_shop_purchase_vote_summary(player_count)
	report["shop_vote_summary"] = vote_summary
	report["shop_vote_approvals"] = vote_session.get("approvals", 0)
	report["shop_vote_required"] = vote_session.get("required", simulation.get_shop_purchase_required_votes(player_count))
	report["shop_vote_session_id"] = vote_session.get("id", "")
	if not option_key.is_empty() and option_key == active_key:
		report["shop_vote_active"] = true
		return report

	report["shop_vote_blocked"] = true
	report["shop_vote_active"] = false
	report["can_buy"] = false
	report["can_remove"] = false
	report["reason"] = "shop_vote_active"
	return report


func _refresh_status() -> void:
	if not simulation.is_loaded():
		status_label.text = "Data not loaded."
		tutorial_label.visible = false
		tutorial_label.text = "Tutorial: -"
		data_label.text = simulation.last_error
		wave_preview_label.text = "Next waves: -"
		front_label.text = "Fronts: -"
		stack_risk_label.text = "Stack risk: -"
		_refresh_action_status()
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

	var active_player_count = _run_player_count()
	var active_directions = _run_active_directions()
	if not run_started:
		status_label.text = "Setup: choose players and lead class, then begin the run."
		tutorial_label.visible = false
		tutorial_label.text = "Tutorial: -"
		data_label.text = simulation.get_run_setup_summary(player_count, selected_class_id)
		wave_preview_label.text = _wave_preview_text(player_count)
		front_label.text = "Front preview: %s\n%s" % [
			simulation.get_front_pressure_summary(player_count),
			simulation.get_front_defense_summary(player_count),
		]
		stack_risk_label.text = "Stack risk: locked until the run begins"
		_refresh_action_status()
		stats_label.text = "Stats: -"
		round_report_label.text = "Last round: -"
		outcome_label.text = "Outcome: -"
		if stack_wave_button != null:
			stack_wave_button.disabled = true
			stack_wave_button.tooltip_text = "Begin the run before pulling extra waves."
		if hold_stack_button != null:
			hold_stack_button.disabled = true
			hold_stack_button.tooltip_text = "No active vote."
		if start_wave_button != null:
			start_wave_button.disabled = true
			start_wave_button.tooltip_text = "Begin the run first."
		if step_wave_button != null:
			step_wave_button.disabled = true
			step_wave_button.tooltip_text = _step_action_state()
		return

	var round_label = simulation.get_active_round() if simulation.wave_active else simulation.get_current_round()
	_ensure_selected_class_id()
	status_label.text = "Round: %s/%s | Completed: %s | Players: %s | Active directions: %s | Autoplay class: %s | Build mode: %s" % [
		round_label,
		simulation.get_max_rounds(),
		simulation.get_completed_rounds(),
		active_player_count,
		_join_values(active_directions),
		_class_label(selected_class_id),
		build_mode,
	]
	var tutorial_hint = simulation.get_tutorial_hint(active_player_count)
	tutorial_label.visible = bool(tutorial_hint.get("visible", false))
	tutorial_label.text = simulation.get_tutorial_summary(active_player_count)
	data_label.text = "%s | %s | %s" % [
		simulation.get_wave_summary(),
		simulation.get_wave_stack_summary(),
		simulation.get_wave_stack_vote_summary(active_player_count),
	]
	wave_preview_label.text = _wave_preview_text(active_player_count)
	var front_lines = PackedStringArray()
	front_lines.append(simulation.get_front_pressure_summary(active_player_count))
	front_lines.append(simulation.get_front_defense_summary(active_player_count))
	var recommendation_summary = _active_front_recommendation_summary()
	if not recommendation_summary.is_empty():
		front_lines.append(recommendation_summary)
	front_lines.append(simulation.get_enemy_intent_summary(active_player_count))
	var boss_part_summary = simulation.get_boss_part_summary()
	if not boss_part_summary.ends_with("none"):
		front_lines.append(boss_part_summary)
	front_label.text = "\n".join(front_lines)
	var pull_tempo_line = _wave_pull_tempo_line(active_player_count)
	var pull_impact_line = simulation.get_wave_stack_impact_summary(active_player_count)
	var stack_tempo_moment_line = simulation.get_wave_stack_tempo_moment_summary()
	var stack_risk_lines = PackedStringArray()
	stack_risk_lines.append(simulation.get_wave_pull_decision_summary(active_player_count))
	if not pull_tempo_line.is_empty():
		stack_risk_lines.append(pull_tempo_line)
	if not pull_impact_line.is_empty():
		stack_risk_lines.append(pull_impact_line)
	if not stack_tempo_moment_line.is_empty():
		stack_risk_lines.append(stack_tempo_moment_line)
	stack_risk_lines.append("Stack risk: %s" % simulation.get_wave_stack_risk_summary(active_player_count))
	stack_risk_label.text = "\n".join(stack_risk_lines)
	stats_label.text = simulation.get_run_stats_summary()
	round_report_label.text = simulation.get_last_round_summary()
	outcome_label.text = "Outcome: %s" % simulation.get_run_outcome_summary(active_player_count)
	if stack_wave_button != null:
		var stack_check = simulation.can_stack_next_wave(active_player_count)
		stack_wave_button.disabled = not bool(stack_check.get("ok", false))
		stack_wave_button.text = simulation.get_wave_stack_action_label(active_player_count)
		var pull_tooltip_lines = PackedStringArray()
		pull_tooltip_lines.append(_call_next_action_state())
		pull_tooltip_lines.append(simulation.get_wave_pull_decision_summary(active_player_count))
		if not pull_tempo_line.is_empty():
			pull_tooltip_lines.append(pull_tempo_line)
		if not pull_impact_line.is_empty():
			pull_tooltip_lines.append(pull_impact_line)
		if not stack_tempo_moment_line.is_empty():
			pull_tooltip_lines.append(stack_tempo_moment_line)
		pull_tooltip_lines.append(simulation.get_wave_stack_risk_summary(active_player_count))
		stack_wave_button.tooltip_text = "\n".join(pull_tooltip_lines)
	if hold_stack_button != null:
		hold_stack_button.disabled = not simulation.has_active_wave_stack_vote()
		hold_stack_button.tooltip_text = "%s\n%s" % [
			_hold_action_state(),
			simulation.get_wave_stack_vote_summary(active_player_count),
		]
	if start_wave_button != null:
		var start_check = simulation.can_start_wave(active_player_count)
		start_wave_button.disabled = not bool(start_check.get("ok", false))
		start_wave_button.tooltip_text = "%s\n%s\n%s\n%s" % [
			_start_wave_action_state(),
			simulation.get_maintenance_check_summary(active_player_count),
			_front_readiness_detail_line(),
			_wave_readiness_next_step(start_check),
		]
	if step_wave_button != null:
		step_wave_button.disabled = not simulation.wave_active
		step_wave_button.tooltip_text = _step_action_state()
	_refresh_action_status()


func _refresh_action_status() -> void:
	if action_status_label == null:
		return

	action_status_label.text = _action_status_text()


func _refresh_tactical_hint() -> void:
	if tactical_hint_label == null:
		return

	tactical_hint_label.text = _tactical_hint_text()


func _refresh_risk_ping_buttons() -> void:
	if risk_ping_row == null:
		return

	var report = simulation.get_risk_ping_report(_run_player_count(), selected_class_id)
	var candidates: Array = report.get("candidates", []) if bool(report.get("ok", false)) else []
	var show_buttons = run_started and not ["idle", "clear"].has(str(report.get("state", ""))) and not candidates.is_empty()
	risk_ping_row.visible = show_buttons

	for index in range(risk_ping_buttons.size()):
		var button: Button = risk_ping_buttons[index]
		var has_candidate = show_buttons and index < candidates.size() and typeof(candidates[index]) == TYPE_DICTIONARY
		button.visible = has_candidate
		button.disabled = not has_candidate
		if not has_candidate:
			button.text = "Ping"
			button.tooltip_text = "No risk ping candidate."
			continue

		var candidate: Dictionary = candidates[index]
		button.text = str(candidate.get("label", "Ping"))
		button.tooltip_text = "Confirm risk ping: %s\nSource: %s\nReason: %s\nCandidate only until pressed." % [
			candidate.get("label", "Ping"),
			report.get("source_label", "-"),
			candidate.get("reason", "-"),
		]


func _refresh_wave_readiness() -> void:
	if wave_readiness_label == null:
		return

	wave_readiness_label.text = _wave_readiness_text()


func _tactical_hint_text() -> String:
	if not simulation.is_loaded():
		return "Tactics: data missing"
	if not run_started:
		return "Tactics: begin the run first"

	var lines = PackedStringArray()
	lines.append(simulation.get_wave_tactical_summary(player_count, selected_class_id))
	lines.append(_wave_plan_line(_run_player_count()))
	lines.append(_wave_spawn_timing_line(_run_player_count()))
	var spawn_response_line = _spawn_response_line(_run_player_count())
	if not spawn_response_line.is_empty():
		lines.append(spawn_response_line)
	var stack_impact_line = simulation.get_wave_stack_impact_summary(_run_player_count())
	if not stack_impact_line.is_empty():
		lines.append(stack_impact_line)
	var stack_tempo_moment_line = simulation.get_wave_stack_tempo_moment_summary()
	if not stack_tempo_moment_line.is_empty():
		lines.append(stack_tempo_moment_line)
	var boss_part_summary = simulation.get_boss_part_summary()
	if not boss_part_summary.ends_with("none"):
		lines.append(boss_part_summary)
	var boss_part_warning = simulation.get_boss_part_warning_summary(player_count)
	if not boss_part_warning.ends_with("none"):
		lines.append(boss_part_warning)
	var structure_threat_line = _structure_threat_timing_line()
	if not structure_threat_line.is_empty():
		lines.append(structure_threat_line)
	var rebuild_line = _rebuild_after_collapse_line()
	if not rebuild_line.is_empty():
		lines.append(rebuild_line)
	var risk_ping_line = _risk_ping_candidate_line()
	if not risk_ping_line.is_empty():
		lines.append(risk_ping_line)
	return "\n".join(lines)


func _risk_ping_candidate_line() -> String:
	var report = simulation.get_risk_ping_report(player_count, selected_class_id)
	if not bool(report.get("ok", false)):
		return str(report.get("summary", "Risk pings: data missing"))

	if ["idle", "clear"].has(str(report.get("state", ""))):
		return ""

	return str(report.get("summary", "Risk pings: -"))


func _active_tactical_threat_marker() -> Dictionary:
	if not simulation.is_loaded() or not run_started:
		return {}

	var report = simulation.get_wave_tactical_report(_run_player_count(), selected_class_id)
	if str(report.get("state", "")) != "active":
		return {}

	var threat: Dictionary = report.get("threat", {})
	if threat.is_empty():
		return {}

	var tile = threat.get("tile", INVALID_TILE)
	if typeof(tile) != TYPE_VECTOR2I or not _is_valid_tile(tile):
		return {}

	return {
		"tile": tile,
		"source_tile": threat.get("source_tile", tile),
		"severity": report.get("severity", "watch"),
		"headline": report.get("headline", "Tactical threat"),
		"suggestion": report.get("suggestion", ""),
		"summary": report.get("summary", ""),
	}


func _confirmed_risk_ping_marker() -> Dictionary:
	if confirmed_risk_ping_marker.is_empty():
		return {}

	var tile_value = confirmed_risk_ping_marker.get("tile", INVALID_TILE)
	if typeof(tile_value) != TYPE_VECTOR2I:
		return {}

	if not _is_valid_tile(tile_value):
		return {}

	return confirmed_risk_ping_marker.duplicate(true)


func _active_structure_threat_report() -> Dictionary:
	if not simulation.is_loaded() or not run_started:
		return {}

	var report = simulation.get_wave_tactical_report(player_count, selected_class_id)
	if str(report.get("state", "")) != "active":
		return {}

	var threat: Dictionary = report.get("threat", {})
	var action = str(threat.get("action", ""))
	if not ["attack_structure", "boss_siege"].has(action):
		return {}

	var tile_value = threat.get("tile", INVALID_TILE)
	if typeof(tile_value) != TYPE_VECTOR2I:
		return {}

	var target_tile: Vector2i = tile_value
	if not _is_valid_tile(target_tile):
		return {}

	var structures: Dictionary = simulation.get_structure_tiles()
	var structure: Dictionary = structures.get(_tile_key(target_tile), {})
	if structure.is_empty():
		return {}

	var incoming_damage = _incoming_structure_damage_for_threat(threat)
	var hp = int(structure.get("hp", 0))
	var max_hp = int(structure.get("max_hp", 0))
	var remaining_hp = max(0, hp - incoming_damage)
	var will_break = incoming_damage > 0 and remaining_hp <= 0
	var collapse_damage = _planned_collapse_damage_for_structure(structure)
	var planned_collapse = will_break and collapse_damage > 0
	var summary = _format_structure_threat_summary(target_tile, incoming_damage, hp, remaining_hp, planned_collapse, collapse_damage)
	return {
		"ok": true,
		"action": action,
		"tile": target_tile,
		"structure": structure,
		"incoming_damage": incoming_damage,
		"hp": hp,
		"max_hp": max_hp,
		"remaining_hp": remaining_hp,
		"will_break": will_break,
		"planned_collapse": planned_collapse,
		"collapse_damage": collapse_damage,
		"summary": summary,
	}


func _incoming_structure_damage_for_threat(threat: Dictionary) -> int:
	var enemy_data = simulation.get_enemy_data(str(threat.get("enemy_id", "")))
	match str(threat.get("action", "")):
		"boss_siege":
			return max(0, int(enemy_data.get("siegeGazeDamage", 0)))
		"attack_structure":
			return max(0, int(enemy_data.get("structureDamage", 0)))
		_:
			return 0


func _planned_collapse_damage_for_structure(structure: Dictionary) -> int:
	if str(structure.get("type", "")) != "barricade":
		return 0

	var effects = simulation.get_class_effects(str(structure.get("class_id", "")))
	return max(0, int(effects.get("barricadeDeathDamage", 0)))


func _format_structure_threat_summary(
	tile: Vector2i,
	incoming_damage: int,
	hp: int,
	remaining_hp: int,
	planned_collapse: bool,
	collapse_damage: int
) -> String:
	if incoming_damage <= 0:
		return "Break risk: %s is targeted; incoming damage unknown." % _tile_text(tile)
	if remaining_hp > 0:
		return "Break risk: %s survives next hit %s -> %s." % [
			_tile_text(tile),
			hp,
			remaining_hp,
		]
	if planned_collapse:
		return "Break risk: %s will break for %s; planned collapse deals %s area damage." % [
			_tile_text(tile),
			incoming_damage,
			collapse_damage,
		]
	return "Break risk: %s will break for %s; repair, block, or replace soon." % [
		_tile_text(tile),
		incoming_damage,
	]


func _structure_threat_timing_line() -> String:
	var report = _active_structure_threat_report()
	if report.is_empty():
		return ""

	return str(report.get("summary", ""))


func _rebuild_after_collapse_line() -> String:
	var report = simulation.get_last_round_report()
	if not bool(report.get("ok", false)):
		return ""

	if not ["collapse", "planned_collapse"].has(str(report.get("focus", ""))):
		return ""

	var summary = simulation.get_front_recommendation_summary(player_count, "barricade", selected_class_id)
	if not summary.begins_with("Rebuild recommendation:"):
		return ""

	return "Rebuild: %s" % summary.trim_prefix("Rebuild recommendation: ").strip_edges()


func _action_status_text() -> String:
	return "Actions: Start wave=%s | Pull next=%s | Hold pull=%s | Step=%s" % [
		_start_wave_action_state(),
		_call_next_action_state(),
		_hold_action_state(),
		_step_action_state(),
	]


func _start_wave_action_state() -> String:
	if not simulation.is_loaded():
		return "Data missing"
	if not run_started:
		return "Begin run first"

	var start_check = simulation.can_start_wave(_run_player_count())
	if bool(start_check.get("ok", false)):
		return "Ready"

	return _short_action_reason(str(start_check.get("reason", "blocked")))


func _call_next_action_state() -> String:
	if not simulation.is_loaded():
		return "Data missing"
	if not run_started:
		return "Begin run first"

	var active_player_count = _run_player_count()
	var stack_check = simulation.can_stack_next_wave(active_player_count)
	if bool(stack_check.get("ok", false)):
		return "Approve pull" if simulation.has_active_wave_stack_vote() and active_player_count > 1 else "Ready"

	return _short_action_reason(str(stack_check.get("reason", "blocked")))


func _wave_pull_tempo_line(target_player_count: int) -> String:
	var report = _wave_pull_tempo_report(target_player_count)
	if report.is_empty():
		return ""

	return str(report.get("summary", ""))


func _wave_pull_tempo_report(target_player_count: int) -> Dictionary:
	if not simulation.is_loaded():
		return {}
	if not run_started:
		return {
			"ok": false,
			"state": "setup_locked",
			"summary": "Pull tempo: begin the run first.",
		}
	if not simulation.wave_active:
		return {
			"ok": false,
			"state": "start_wave_first",
			"summary": "Pull tempo: start the current wave first; pulling only shortens active-wave downtime.",
		}

	var stack_check = simulation.can_stack_next_wave(target_player_count)
	if not bool(stack_check.get("ok", false)):
		var reason = str(stack_check.get("reason", "blocked"))
		return {
			"ok": false,
			"state": "blocked",
			"reason": reason,
			"summary": "Pull tempo: blocked - %s." % _wave_pull_tempo_block_reason(reason),
		}

	var response = _spawn_response_report(target_player_count)
	if response.is_empty():
		return {
			"ok": true,
			"state": "ready",
			"summary": "Pull tempo: ready - no spawn queue is visible; pull only to shorten downtime.",
		}

	var row: Dictionary = response.get("row", {})
	var front_entry: Dictionary = response.get("front", {})
	var direction = str(response.get("direction", "front"))
	var role = _spawn_response_role(row)
	var threat_text = _wave_pull_tempo_threat_text(direction, row)
	var state = "ready"
	var reason_text = ""

	if bool(front_entry.get("needs_minimum_defense", false)):
		state = "hold"
		reason_text = "%s and %s is uncovered" % [threat_text, direction]
	elif int(front_entry.get("critical_count", 0)) > 0:
		state = "hold"
		reason_text = "%s while %s has critical structures; repair before adding another queue" % [threat_text, direction]
	elif int(front_entry.get("damaged_count", 0)) > 0:
		state = "prepare"
		reason_text = "%s while %s is damaged; repair or replace before pulling" % [threat_text, direction]
	elif int(front_entry.get("pressure_rank", 0)) >= 2:
		state = "prepare"
		reason_text = "%s and %s is already hot; pull after one answer is ready" % [threat_text, direction]
	elif ["boss", "structure_break", "short"].has(role):
		state = "prepare"
		reason_text = "%s threatens structures on %s; pull after repair or rebuild is ready" % [threat_text, direction]
	elif role == "fast":
		state = "prepare"
		reason_text = "%s reaches %s quickly; pull after slow, taunt, or focus fire is ready" % [threat_text, direction]
	else:
		reason_text = "%s is covered; %s is manageable, so pull only to shorten downtime" % [direction, threat_text]

	return {
		"ok": true,
		"state": state,
		"direction": direction,
		"role": role,
		"summary": "Pull tempo: %s - %s." % [state, reason_text],
	}


func _wave_pull_tempo_block_reason(reason: String) -> String:
	match reason:
		"reward_pending":
			return "resolve the current reward before changing the wave queue"
		"wave_not_active":
			return "start the current wave first"
		"stack_limit_reached":
			return "the current pull limit is full"
		"no_next_round":
			return "no later round remains"
		"no_active_direction":
			return "no active front is available"
		"data_not_loaded":
			return "data is missing"
		_:
			return _short_block_reason(reason)


func _wave_pull_tempo_threat_text(direction: String, row: Dictionary) -> String:
	var enemy_label = str(row.get("enemyLabel", row.get("enemyId", "enemy")))
	return "next %s %s %s" % [
		direction,
		enemy_label,
		_spawn_response_timing_text(row),
	]


func _hold_action_state() -> String:
	if not simulation.is_loaded():
		return "Data missing"
	if not run_started:
		return "Begin run first"
	if simulation.has_active_wave_stack_vote():
		return "Ready"
	return "No vote"


func _step_action_state() -> String:
	if not simulation.is_loaded():
		return "Data missing"
	if not run_started:
		return "Begin run first"
	return "Ready" if simulation.wave_active else "Wave not active"


func _short_action_reason(reason: String) -> String:
	match reason:
		"reward_pending":
			return "Resolve reward"
		"wave_not_active":
			return "Wave not active"
		"stack_limit_reached":
			return "Stack limit"
		"no_next_round":
			return "No next round"
		"no_active_direction":
			return "No active front"
		"data_not_loaded":
			return "Data missing"
		_:
			return _short_block_reason(reason)


func _wave_readiness_text() -> String:
	if not simulation.is_loaded():
		return "Wave readiness: data missing"
	if not run_started:
		return "Wave readiness: begin the run first"

	var lines = PackedStringArray()
	var active_player_count = _run_player_count()
	var start_report = simulation.can_start_wave(active_player_count)
	if bool(start_report.get("ok", false)):
		lines.append("Wave readiness: ready for R%s" % start_report.get("round", simulation.get_current_round()))
	else:
		lines.append("Wave readiness: blocked - %s" % _short_action_reason(str(start_report.get("reason", "blocked"))))

	lines.append("Front check: %s" % _front_readiness_line())
	lines.append(_wave_plan_line(active_player_count))
	lines.append(_wave_spawn_timing_line(active_player_count))
	var spawn_response_line = _spawn_response_line(active_player_count)
	if not spawn_response_line.is_empty():
		lines.append(spawn_response_line)
	lines.append(simulation.get_maintenance_check_summary(active_player_count))
	var front_detail_line = _front_readiness_detail_line()
	if not front_detail_line.is_empty():
		lines.append(front_detail_line)
	var intent_line = _intent_readiness_line()
	if not intent_line.is_empty():
		lines.append(intent_line)
	lines.append("Next: %s" % _wave_readiness_next_step(start_report))
	return "\n".join(lines)


func _wave_preview_text(active_player_count: int) -> String:
	var lines = PackedStringArray()
	lines.append(simulation.get_next_wave_preview_summary(active_player_count))
	lines.append(_wave_plan_line(active_player_count))
	lines.append(_wave_spawn_timing_line(active_player_count))
	var artifact_to_wave_line = simulation.get_artifact_to_wave_preparation_summary(active_player_count)
	if not artifact_to_wave_line.is_empty():
		lines.append(artifact_to_wave_line)
	var shop_to_wave_line = simulation.get_shop_to_wave_preparation_summary(active_player_count)
	if not shop_to_wave_line.is_empty():
		lines.append(shop_to_wave_line)
	return "\n".join(lines)


func _front_readiness_line() -> String:
	var report = simulation.get_front_defense_report(_run_player_count())
	if not bool(report.get("ok", false)):
		return _short_action_reason(str(report.get("reason", "blocked")))

	var weak_parts = PackedStringArray()
	var damaged_parts = PackedStringArray()
	for front in report.get("fronts", []):
		if typeof(front) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = front
		var direction = str(entry.get("direction", "?"))
		if bool(entry.get("needs_minimum_defense", false)):
			weak_parts.append("%s %s/%s" % [
				direction,
				entry.get("structure_count", 0),
				entry.get("minimum_structure_count", 1),
			])
		elif int(entry.get("critical_count", 0)) > 0:
			damaged_parts.append("%s critical" % direction)
		elif int(entry.get("damaged_count", 0)) > 0:
			damaged_parts.append("%s damaged" % direction)

	if not weak_parts.is_empty():
		return "needs setup: %s" % " | ".join(weak_parts)
	if not damaged_parts.is_empty():
		return "repair soon: %s" % " | ".join(damaged_parts)

	return "covered"


func _wave_plan_line(target_player_count: int, round_number: int = -1) -> String:
	if not simulation.is_loaded():
		return "Wave plan: data missing"

	var target_round = int(round_number)
	if target_round <= 0:
		target_round = simulation.get_active_round() if simulation.wave_active else simulation.get_current_round()

	var spawn_plan = simulation.get_wave_spawn_plan_report(target_player_count, target_round)
	if not bool(spawn_plan.get("ok", false)):
		return "Wave plan: unavailable - %s" % spawn_plan.get("reason", "unknown")

	var wave_intent: Dictionary = spawn_plan.get("waveIntent", {})
	var directions = _string_values_from_array(spawn_plan.get("directions", []))
	var prep_tags = _string_values_from_array(spawn_plan.get("previewResponseTags", []))
	var prep_text = ""
	if not prep_tags.is_empty():
		prep_text = " | prep %s" % _join_values(prep_tags)

	return "Wave plan: R%s %s from %s | packets %s | %s%s" % [
		target_round,
		wave_intent.get("label", spawn_plan.get("waveIntentId", "intent")),
		_join_values(directions),
		spawn_plan.get("spawnPacketCount", 0),
		wave_intent.get("question", "-"),
		prep_text,
	]


func _wave_spawn_timing_line(target_player_count: int, round_number: int = -1) -> String:
	if not simulation.is_loaded():
		return "Spawn timing: data missing"

	if simulation.wave_active:
		return simulation.get_active_wave_spawn_timeline_summary(target_player_count, 3)

	var target_round = int(round_number)
	if target_round <= 0:
		target_round = simulation.get_current_round()

	return simulation.get_wave_spawn_timeline_summary(target_player_count, target_round, 3)


func _spawn_response_line(target_player_count: int) -> String:
	var report = _spawn_response_report(target_player_count)
	if report.is_empty():
		return ""

	return str(report.get("summary", ""))


func _spawn_response_report(target_player_count: int) -> Dictionary:
	if not simulation.is_loaded() or not run_started:
		return {}

	var active_directions = _run_active_directions()
	if active_directions.is_empty():
		return {}

	var row_limit = max(4, active_directions.size() * 2)
	var timeline_report = simulation.get_active_wave_spawn_timeline_report(target_player_count, row_limit) if simulation.wave_active else simulation.get_wave_spawn_timeline_report(target_player_count, simulation.get_current_round(), row_limit)
	if not bool(timeline_report.get("ok", false)):
		return {}

	var row = _first_spawn_response_row(timeline_report.get("rows", []), active_directions)
	if row.is_empty():
		return {}

	var direction = _first_spawn_response_direction(row, active_directions)
	if direction.is_empty():
		return {}

	var front_entry = _front_defense_entry_for_direction(target_player_count, direction)
	var structure_type = _spawn_response_structure_type(row, front_entry)
	var target_text = _spawn_response_target_text(target_player_count, direction, structure_type)
	var action_text = _spawn_response_action_text(direction, row, front_entry, target_text)
	var enemy_label = str(row.get("enemyLabel", row.get("enemyId", "enemy")))
	var summary = "Spawn response: next %s %s %s; %s" % [
		direction,
		enemy_label,
		_spawn_response_timing_text(row),
		action_text,
	]
	return {
		"ok": true,
		"direction": direction,
		"row": row,
		"front": front_entry,
		"structure_type": structure_type,
		"target_text": target_text,
		"summary": summary,
	}


func _first_spawn_response_row(rows_value, active_directions: Array) -> Dictionary:
	if typeof(rows_value) != TYPE_ARRAY:
		return {}

	for row_value in rows_value:
		if typeof(row_value) != TYPE_DICTIONARY:
			continue

		var row: Dictionary = row_value
		if not _first_spawn_response_direction(row, active_directions).is_empty():
			return row

	return {}


func _first_spawn_response_direction(row: Dictionary, active_directions: Array) -> String:
	for direction in _string_values_from_array(row.get("directions", [])):
		if active_directions.has(direction):
			return direction

	return ""


func _front_defense_entry_for_direction(target_player_count: int, direction: String) -> Dictionary:
	var report = simulation.get_front_defense_report(target_player_count)
	if not bool(report.get("ok", false)):
		return {}

	var by_direction: Dictionary = report.get("by_direction", {})
	return by_direction.get(direction, {})


func _spawn_response_structure_type(row: Dictionary, front_entry: Dictionary) -> String:
	if bool(front_entry.get("needs_minimum_defense", false)):
		var setup_sequence = _setup_plan_structure_sequence()
		if not setup_sequence.is_empty():
			return str(setup_sequence[0])

	match _spawn_response_role(row):
		"boss", "structure_break", "fast", "short":
			return "barricade"
		_:
			return "tower"


func _spawn_response_target_text(target_player_count: int, direction: String, structure_type: String) -> String:
	if structure_type.is_empty():
		return ""

	var recommendation_report = simulation.get_front_recommendation_tiles(target_player_count, structure_type, selected_class_id)
	if not bool(recommendation_report.get("ok", false)):
		return structure_type.capitalize()

	var tiles: Dictionary = recommendation_report.get("tiles", {})
	for key_value in _sorted_tile_keys_by_position(tiles):
		var key = str(key_value)
		var recommendation: Dictionary = tiles.get(key, {})
		if str(recommendation.get("direction", "")) != direction:
			continue

		var tile_value = recommendation.get("tile", _tile_from_key(key))
		var tile = tile_value if typeof(tile_value) == TYPE_VECTOR2I else _tile_from_key(key)
		if _is_valid_tile(tile):
			return "%s at %s" % [structure_type.capitalize(), _tile_text(tile)]

	return structure_type.capitalize()


func _spawn_response_action_text(direction: String, row: Dictionary, front_entry: Dictionary, target_text: String) -> String:
	if simulation.wave_active:
		match _spawn_response_role(row):
			"boss":
				return "hold damage or delay cards for %s" % direction
			"structure_break", "short":
				return "watch the first structure on %s and keep repair or rebuild ready" % direction
			"fast":
				return "hold slow, taunt, or focus fire for %s" % direction
			"armored", "slow":
				return "keep sustained tower damage on %s" % direction
			_:
				return "keep the %s kill zone firing" % direction

	if bool(front_entry.get("needs_minimum_defense", false)):
		if not target_text.is_empty():
			return "cover %s with %s before start" % [direction, target_text]
		return "cover %s before start" % direction
	if int(front_entry.get("critical_count", 0)) > 0:
		return "repair critical %s structures before start" % direction
	if int(front_entry.get("damaged_count", 0)) > 0:
		return "repair damaged %s structures before start" % direction

	match _spawn_response_role(row):
		"boss":
			return "prepare delay and boss-part focus on %s" % direction
		"structure_break", "short":
			return "choose which %s structure may break, then prepare a rear rebuild" % direction
		"fast":
			return "prepare a short-path slow or taunt answer on %s" % direction
		"armored", "slow":
			return "stretch %s path for sustained damage" % direction
		"killzone":
			return "compress %s path into the first kill zone" % direction
		_:
			return "keep %s covered before pulling extra waves" % direction


func _spawn_response_role(row: Dictionary) -> String:
	var enemy_role = str(row.get("enemyRole", ""))
	var direction_role = str(row.get("directionRole", ""))
	if enemy_role == "boss" or direction_role == "boss":
		return "boss"
	if enemy_role == "structure_break":
		return "structure_break"
	if enemy_role == "fast" or direction_role == "fast":
		return "fast"
	if enemy_role == "armored":
		return "armored"
	if ["short", "slow", "killzone"].has(direction_role):
		return direction_role
	return enemy_role if not enemy_role.is_empty() else "swarm"


func _spawn_response_timing_text(row: Dictionary) -> String:
	var seconds = max(0.0, float(row.get("firstSpawnTimeSeconds", 0.0)))
	if simulation.wave_active and seconds <= 0.01:
		return "now"
	return "at %s" % _format_seconds_label(seconds)


func _format_seconds_label(seconds: float) -> String:
	if abs(seconds - round(seconds)) < 0.01:
		return "%ss" % int(round(seconds))

	return "%.1fs" % seconds


func _front_readiness_detail_line() -> String:
	var report = simulation.get_front_defense_report(player_count)
	if not bool(report.get("ok", false)):
		return ""

	var parts = PackedStringArray()
	for front in report.get("fronts", []):
		if typeof(front) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = front
		parts.append(_front_readiness_detail_for_entry(entry))

	if parts.is_empty():
		return ""

	return "Front detail: %s" % " | ".join(parts)


func _front_readiness_detail_for_entry(entry: Dictionary) -> String:
	var status = _front_readiness_status_code(entry)
	return "%s %s %s/%s T%s X%s hp%s pressure %s" % [
		entry.get("direction", "?"),
		status,
		entry.get("structure_count", 0),
		entry.get("minimum_structure_count", 1),
		entry.get("tower_count", 0),
		entry.get("barricade_count", 0),
		entry.get("total_hp", 0),
		entry.get("pressure_severity", "idle"),
	]


func _front_readiness_status_code(entry: Dictionary) -> String:
	if bool(entry.get("needs_minimum_defense", false)):
		return "GAP"
	if int(entry.get("critical_count", 0)) > 0:
		return "CRIT"
	if int(entry.get("damaged_count", 0)) > 0:
		return "DMG"
	if int(entry.get("pressure_rank", 0)) >= 2:
		return "HOT"
	return "OK"


func _front_readiness_attention_step() -> String:
	var report = simulation.get_front_defense_report(player_count)
	if not bool(report.get("ok", false)):
		return ""

	var priority: Array = report.get("priority_directions", [])
	var by_direction: Dictionary = report.get("by_direction", {})
	for direction_value in priority:
		var direction = str(direction_value)
		var entry: Dictionary = by_direction.get(direction, {})
		if entry.is_empty():
			continue

		if bool(entry.get("needs_minimum_defense", false)):
			return "cover %s first or start wave if testing risk" % direction
		if int(entry.get("critical_count", 0)) > 0:
			return "repair %s critical structures before expanding" % direction
		if int(entry.get("damaged_count", 0)) > 0:
			return "repair %s soon or start wave carefully" % direction
		if int(entry.get("pressure_rank", 0)) >= 2:
			return "watch %s pressure before pulling extra waves" % direction

	return ""


func _intent_readiness_line() -> String:
	var selected_card_id = _selected_card_id()
	if not selected_card_id.is_empty():
		var card = simulation.get_card_data(selected_card_id)
		var target_report = _best_target_action_report()
		var timing_line = _selected_card_timing_line(selected_card_id)
		if bool(target_report.get("ok", false)):
			var timing_suffix = ""
			if not timing_line.is_empty():
				timing_suffix = " | %s" % timing_line
			return "Intent: %s ready at %s%s" % [
				card.get("label", selected_card_id),
				_tile_text(target_report.get("tile", INVALID_TILE)),
				timing_suffix,
			]

		if not timing_line.is_empty():
			return "Intent: %s selected, %s" % [
				card.get("label", selected_card_id),
				timing_line,
			]

		return "Intent: %s selected, %s" % [
			card.get("label", selected_card_id),
			_short_action_reason(str(target_report.get("reason", "blocked"))),
		]

	if ["tower", "barricade"].has(build_mode):
		var build_report = _best_target_action_report()
		if bool(build_report.get("ok", false)):
			return "Intent: build %s at %s" % [
				build_mode,
				_tile_text(build_report.get("tile", INVALID_TILE)),
			]

		return "Intent: build %s, %s" % [
			build_mode,
			_short_action_reason(str(build_report.get("reason", "blocked"))),
		]

	if build_mode == "remove":
		return "Intent: remove mode selected"

	return "Intent: no card or build mode selected"


func _wave_readiness_next_step(start_report: Dictionary) -> String:
	if simulation.wave_active:
		return "step the active wave"
	if simulation.has_pending_reward():
		var maintenance_report = simulation.get_maintenance_check_report(_run_player_count())
		return str(maintenance_report.get("next_step", "resolve reward"))
	if simulation.is_run_complete():
		return "reset or review the result"
	if bool(start_report.get("ok", false)):
		var attention_step = _front_readiness_attention_step()
		if not attention_step.is_empty():
			return attention_step
		return "start wave"

	var reason = str(start_report.get("reason", "blocked"))
	if reason.begins_with("no_path_from_"):
		return "open a path from %s" % reason.substr("no_path_from_".length())
	if not _front_readiness_line().begins_with("covered"):
		return "place a tower or barricade on weak fronts"

	return _short_action_reason(reason)


func _refresh_round_recap() -> void:
	if round_recap_panel == null:
		return

	if not simulation.is_loaded() or not run_started:
		round_recap_panel.visible = false
		_apply_round_recap_style("none")
		if round_recap_title_label != null:
			round_recap_title_label.text = "Round recap: -"
		if round_recap_body_label != null:
			round_recap_body_label.text = ""
		return

	var report = simulation.get_last_round_panel_report(player_count)
	if not bool(report.get("ok", false)):
		round_recap_panel.visible = false
		_apply_round_recap_style("none")
		if round_recap_title_label != null:
			round_recap_title_label.text = "Round recap: -"
		if round_recap_body_label != null:
			round_recap_body_label.text = ""
		return

	round_recap_panel.visible = true
	var focus = str(report.get("focus", "stable"))
	_apply_round_recap_style(focus)
	if round_recap_title_label != null:
		round_recap_title_label.text = "[%s] %s - %s" % [
			_round_recap_badge_for_focus(focus),
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


func _apply_round_recap_style(focus: String) -> void:
	if round_recap_panel == null:
		return

	var color = _round_recap_color_for_focus(focus)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.10)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	round_recap_panel.add_theme_stylebox_override("panel", style)

	if round_recap_title_label != null:
		round_recap_title_label.add_theme_color_override("font_color", color.lightened(0.25))
	if round_recap_body_label != null:
		round_recap_body_label.add_theme_color_override("font_color", Color(0.88, 0.91, 0.92))


func _round_recap_badge_for_focus(focus: String) -> String:
	match focus:
		"failed":
			return "FAIL"
		"leak", "front_leak":
			return "LEAK"
		"collapse", "structure_collapse":
			return "BREAK"
		"planned_collapse":
			return "TACTIC"
		"stack_clear":
			return "STACK"
		"boss_clear":
			return "BOSS"
		"stable":
			return "HOLD"
		_:
			return "INFO"


func _round_recap_color_for_focus(focus: String) -> Color:
	match focus:
		"failed":
			return Color(0.88, 0.18, 0.20)
		"leak", "front_leak":
			return Color(0.95, 0.58, 0.18)
		"collapse", "structure_collapse":
			return Color(0.82, 0.42, 0.16)
		"planned_collapse":
			return Color(0.18, 0.68, 0.76)
		"stack_clear":
			return Color(0.18, 0.68, 0.76)
		"boss_clear":
			return Color(0.70, 0.38, 0.86)
		"stable":
			return Color(0.20, 0.72, 0.48)
		_:
			return Color(0.45, 0.52, 0.58)


func _refresh_map_view() -> void:
	if not simulation.is_loaded():
		return

	var map_size = simulation.get_map_size()
	var base_cells = simulation.get_base_cells()
	var entrances = simulation.get_entrances()
	var active_player_count = _run_player_count()
	var active_directions = _run_active_directions()
	var front_pressure = simulation.get_front_pressure_by_direction(active_player_count)
	var front_defense_report = simulation.get_front_defense_report(active_player_count)
	var front_defense: Dictionary = front_defense_report.get("by_direction", {}) if bool(front_defense_report.get("ok", false)) else {}
	var path_cells = simulation.get_path_cells(active_player_count)
	var tower_preview_tile = preview_tile if build_mode == "tower" and preview_ok else INVALID_TILE
	var tower_range_cells = simulation.get_tower_range_cells(tower_preview_tile)
	var structure_tiles = simulation.get_structure_tiles()
	var enemy_tiles = simulation.get_enemy_tiles()
	var enemy_trait_tiles = simulation.get_enemy_trait_tiles()
	var boss_enemy_tiles = simulation.get_boss_enemy_tiles()
	var enemy_intent_tiles = simulation.get_enemy_intent_tiles(active_player_count)
	var card_target_tiles = _selected_card_target_tiles()
	var front_recommendation_tiles = _visible_front_recommendation_tiles()
	var recent_event_tiles = simulation.get_recent_event_tiles()
	var boss_warning_tiles = _boss_warning_map_tiles()
	var spawn_warning_tiles = _spawn_warning_map_tiles(active_player_count, active_directions)
	var tactical_threat = _active_tactical_threat_marker()
	var confirmed_risk_ping = _confirmed_risk_ping_marker()
	var alpha_focus_direction = _selected_alpha_focus_direction()
	var alpha_focus_setup_marker = _alpha_focus_setup_marker()

	map_view.set_state(
		map_size,
		base_cells,
		entrances,
		active_directions,
		front_pressure,
		front_defense,
		path_cells,
		tower_range_cells,
		structure_tiles,
		enemy_tiles,
		enemy_trait_tiles,
		boss_enemy_tiles,
		enemy_intent_tiles,
		card_target_tiles,
		front_recommendation_tiles,
		recent_event_tiles,
		boss_warning_tiles,
		spawn_warning_tiles,
		tactical_threat,
		confirmed_risk_ping,
		alpha_focus_direction,
		alpha_focus_setup_marker,
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
		debug_log_toggle.set_pressed_no_signal(show_debug_log)
	if log_filter_option != null:
		log_filter_option.select(_log_filter_index_for_category(log_filter_category))
	if important_log_toggle != null:
		important_log_toggle.set_pressed_no_signal(show_important_logs_only)

	log_label.visible = show_debug_log
	if not show_debug_log:
		log_label.text = ""
		return

	var filtered_log = debug_log.to_text_filtered(log_filter_category, show_important_logs_only)
	log_label.text = filtered_log if not filtered_log.is_empty() else "No matching activity yet."


func _log_filter_index_for_category(category: String) -> int:
	var normalized_category = category.to_lower()
	for index in range(LOG_FILTER_CATEGORIES.size()):
		if str(LOG_FILTER_CATEGORIES[index]) == normalized_category:
			return index

	return 0


func _log_category_for_filter_index(index: int) -> String:
	if index >= 0 and index < LOG_FILTER_CATEGORIES.size():
		return str(LOG_FILTER_CATEGORIES[index])

	return "all"


func _refresh_preview_labels() -> void:
	var selected_card_id = _selected_card_id()
	if not _is_valid_hovered_tile():
		tile_label.text = "Tile: -"
	else:
		tile_label.text = "Tile: %s" % _tile_text(hovered_tile)

	if not run_started and _is_valid_tile(preview_tile) and ["tower", "barricade"].has(build_mode):
		var recommendation_suffix = _preview_recommendation_suffix()
		preview_label.text = "Preview: action setup recommends %s at %s%s. Begin run to place it." % [
			build_mode,
			_tile_text(preview_tile),
			recommendation_suffix,
		]
	elif not run_started:
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
		var recommendation_suffix = _preview_recommendation_suffix()
		if build_mode == "remove":
			preview_label.text = "Preview: structure can be removed at %s" % _tile_text(preview_tile)
		elif not _selected_card_id().is_empty():
			var card = simulation.get_card_data(_selected_card_id())
			preview_label.text = "Preview: %s can be played at %s%s" % [
				card.get("label", _selected_card_id()),
				_tile_text(preview_tile),
				recommendation_suffix,
			]
		else:
			preview_label.text = "Preview: %s can be placed at %s%s" % [
				build_mode,
				_tile_text(preview_tile),
				recommendation_suffix,
			]
	else:
		preview_label.text = "Preview: %s" % preview_reason


func _preview_recommendation_suffix() -> String:
	if not _is_valid_tile(preview_tile):
		return ""

	var recommendation = _active_front_recommendation_at(preview_tile)
	if recommendation.is_empty():
		return ""

	var why = str(recommendation.get("why", recommendation.get("summary", "")))
	if why.is_empty():
		return ""

	return " | Recommended: %s" % why


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
	_clear_discard_follow_up()
	_clear_combat_follow_up()
	confirmed_risk_ping_marker.clear()
	selected_card_index = -1
	selected_artifact_replacement_offer_id = ""
	selected_dormant_artifact_release_id = ""
	_clear_shop_reactivation_selection()
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
	var restore_action_setup_preview = _has_action_setup_preview()
	run_config_lock_snapshot = _build_run_config_lock_snapshot(setup_report)
	simulation.reset_run()
	var prepare_result = simulation.prepare_run_for_player_count(player_count)
	run_started = true
	build_mode = "none"
	selected_card_index = -1
	selected_artifact_replacement_offer_id = ""
	selected_dormant_artifact_release_id = ""
	_clear_shop_reactivation_selection()
	_clear_hand_ready_cue()
	_clear_discard_follow_up()
	_clear_combat_follow_up()
	confirmed_risk_ping_marker.clear()
	hovered_tile = INVALID_TILE
	selected_tile = INVALID_TILE
	last_boss_warning_response_line = ""
	_clear_preview()
	debug_log.clear()
	debug_log.push("Run started: %s." % setup_report.get("summary", ""))
	debug_log.push("Run state locked: %s." % _run_config_lock_summary(), "system")
	debug_log.push("run_state_locked: %s." % _run_config_lock_telemetry_summary(), "system")
	if bool(prepare_result.get("ok", false)) and int(prepare_result.get("gained", 0)) > 0:
		debug_log.push("Active front seed mana prepared: +%s mana." % prepare_result.get("gained", 0))
	debug_log.push("Opening hand ready. Build the first kill zone, then start wave 1.")
	if restore_action_setup_preview:
		var preview_report = _preview_next_action_setup_plan()
		if bool(preview_report.get("ok", false)):
			debug_log.push("Action setup preview restored: %s at %s." % [
				str(preview_report.get("structure_type", "structure")).capitalize(),
				_tile_text(preview_report.get("tile", INVALID_TILE)),
			], "system")
		else:
			debug_log.push("Action setup preview restore failed: %s." % preview_report.get("reason", "blocked"), "system")
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
			_clear_discard_follow_up()
			_clear_combat_follow_up()
			selected_card_index = -1
			build_mode = "none"
		else:
			debug_log.push("Card rejected: %s." % play_result["reason"])

		_refresh_screen()
		return

	build_mode = str(card.get("structureType", "card"))
	debug_log.push("Card selected: %s." % card.get("label", card_id))
	_refresh_screen()


func _on_use_best_target_pressed() -> void:
	var report = _best_target_action_report()
	if not bool(report.get("ok", false)):
		debug_log.push("Best target unavailable: %s." % report.get("reason", "blocked"))
		_refresh_screen()
		return

	var intent = str(report.get("intent", ""))
	if intent == "direct_card":
		_play_best_direct_card(report)
		return

	var tile: Vector2i = report.get("tile", INVALID_TILE)
	if not _is_valid_tile(tile):
		debug_log.push("Best target unavailable: invalid tile.")
		_refresh_screen()
		return

	if intent == "card" and int(report.get("card_index", -1)) >= 0:
		selected_card_index = int(report.get("card_index", -1))
		var card = simulation.get_card_data(str(report.get("card_id", "")))
		if simulation.card_requires_tile(str(report.get("card_id", ""))):
			build_mode = str(card.get("structureType", "card"))

	debug_log.push("Best target chosen: %s at %s." % [
		report.get("label", "target"),
		_tile_text(tile),
	])
	_on_tile_pressed(tile)


func _play_best_direct_card(report: Dictionary) -> void:
	var card_id = str(report.get("card_id", ""))
	var card_index = int(report.get("card_index", -1))
	if card_id.is_empty() or card_index < 0:
		debug_log.push("Best target unavailable: direct card missing.")
		_refresh_screen()
		return

	selected_card_index = card_index
	var play_result = simulation.play_card(card_id, selected_class_id)
	if bool(play_result.get("ok", false)):
		debug_log.push("Best hand action played %s. Mana: %s." % [
			play_result.get("card_label", simulation.get_card_label(card_id)),
			simulation.get_mana(),
		])
		for event in play_result.get("events", []):
			debug_log.push(event)
		_clear_discard_follow_up()
		_clear_combat_follow_up()
		selected_card_index = -1
		build_mode = "none"
		_clear_preview()
	else:
		debug_log.push("Best hand action rejected: %s." % play_result.get("reason", "blocked"))

	_refresh_screen()


func _on_setup_plan_pressed() -> void:
	var report = _setup_plan_action_report()
	if not bool(report.get("ok", false)):
		debug_log.push("Setup plan unavailable: %s." % report.get("reason", "blocked"))
		_refresh_screen()
		return

	var placed_count = 0
	var execute_result = _execute_setup_plan(true, "Setup plan")
	placed_count = int(execute_result.get("placed_count", 0))

	if placed_count <= 0:
		debug_log.push("Setup plan made no placement.")
	else:
		debug_log.push("Setup plan complete: %s" % simulation.get_front_defense_summary(player_count))

	selected_card_index = -1
	build_mode = "none"
	_clear_preview()
	_refresh_screen()


func _execute_setup_plan(prefer_preview: bool, log_label: String) -> Dictionary:
	var placed_count = 0
	var stop_reason = ""
	var placement_limit = max(1, simulation.get_active_directions(player_count).size())
	while placed_count < placement_limit and not _front_setup_is_complete():
		var step_report = {}
		if prefer_preview and placed_count == 0:
			step_report = _setup_plan_preview_step_report()
		if not bool(step_report.get("ok", false)):
			step_report = _setup_plan_next_step_report()
		if not bool(step_report.get("ok", false)):
			stop_reason = str(step_report.get("reason", "blocked"))
			debug_log.push("%s stopped: %s." % [log_label, stop_reason])
			break

		var tile: Vector2i = step_report.get("tile", INVALID_TILE)
		var structure_type = str(step_report.get("structure_type", ""))
		var place_result = simulation.place_structure(tile, structure_type, player_count, selected_class_id)
		if not bool(place_result.get("ok", false)):
			stop_reason = str(place_result.get("reason", "blocked"))
			debug_log.push("%s rejected at %s: %s." % [
				log_label,
				_tile_text(tile),
				stop_reason,
			])
			break

		placed_count += 1
		debug_log.push("%s placed %s at %s." % [
			log_label,
			structure_type.capitalize(),
			_tile_text(tile),
		])
		_push_recommendation_log(step_report.get("recommendation", {}))

	return {
		"ok": placed_count > 0,
		"reason": "ok" if placed_count > 0 else (stop_reason if not stop_reason.is_empty() else "no_placement"),
		"placed_count": placed_count,
		"front_complete": _front_setup_is_complete(),
	}


func _on_discard_selected_pressed() -> void:
	if not run_started:
		debug_log.push("Discard locked: begin the run first.")
		_refresh_log()
		return

	var action_report = _discard_action_report()
	if not bool(action_report.get("ok", false)):
		debug_log.push("Discard rejected: %s." % action_report.get("reason", "blocked"))
		_refresh_screen()
		return

	var card_id = str(action_report.get("card_id", ""))
	var result = simulation.discard_card(card_id)
	if bool(result["ok"]):
		if bool(action_report.get("suggested", false)):
			if str(action_report.get("suggestion_kind", "emergency")) == "pressure":
				debug_log.push("Pressure discard used: %s." % action_report.get("label", card_id))
			else:
				debug_log.push("Emergency discard used: %s." % action_report.get("label", card_id))
		for event in result["events"]:
			debug_log.push(event)
		var follow_up_line = _capture_discard_follow_up(result)
		if not follow_up_line.is_empty():
			debug_log.push(follow_up_line, "system")
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
	var recommendation = simulation.get_reward_recommendation_report(player_count, selected_class_id)
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
		debug_log.push(_format_reward_choice_lock_trace(result), "system")
		_push_choice_trace_log("Reward", "card", card_id, str(result.get("card_label", card_id)), recommendation)
	else:
		debug_log.push("Reward rejected: %s." % result["reason"])

	_refresh_screen()


func _on_skip_reward_pressed() -> void:
	if not run_started:
		debug_log.push("Reward gold locked: begin the run first.")
		_refresh_log()
		return

	var recommendation = simulation.get_reward_recommendation_report(player_count, selected_class_id)
	var result = simulation.skip_reward_offer()
	if bool(result["ok"]):
		debug_log.push("Reward gold taken: +%s gold. Gold: %s -> %s. Cards left out: %s." % [
			result.get("gold_gain", 0),
			result.get("gold_before", 0),
			result.get("gold_after", 0),
			result.get("skipped_count", 0),
		])
		debug_log.push("Reward economy: %s" % result.get("economy_summary", simulation.get_economy_summary()), "system")
		debug_log.push(_format_reward_choice_lock_trace(result), "system")
		_push_choice_trace_log("Reward", "gold", "", "Take gold +%s" % result.get("gold_gain", 0), recommendation)
	else:
		debug_log.push("Reward gold rejected: %s." % result["reason"])

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
	var recommendation = simulation.get_artifact_recommendation_report()
	var result = simulation.claim_artifact(artifact_id)
	if bool(result["ok"]):
		selected_artifact_replacement_offer_id = ""
		selected_dormant_artifact_release_id = ""
		debug_log.push("Artifact equipped: %s. %s Equipped: %s -> %s." % [
			result["artifact_label"],
			result.get("effect", ""),
			result.get("equipped_count_before", 0),
			result.get("equipped_count_after", 0),
		])
		_push_choice_trace_log("Artifact", "artifact", artifact_id, str(result.get("artifact_label", artifact_id)), recommendation)
	else:
		if str(result.get("reason", "")) == "artifact_slots_full":
			selected_artifact_replacement_offer_id = artifact_id
			selected_dormant_artifact_release_id = ""
			debug_log.push("Artifact replacement armed: %s. Choose which equipped artifact becomes dormant, or keep current." % simulation.get_artifact_label(artifact_id))
		else:
			debug_log.push("Artifact rejected: %s." % result["reason"])

	_refresh_screen()


func _on_artifact_replace_button_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Artifact replacement locked: begin the run first.")
		_refresh_log()
		return

	if selected_artifact_replacement_offer_id.is_empty():
		debug_log.push("Artifact replacement unavailable: choose a new artifact first.")
		_refresh_screen()
		return

	var equipped_artifacts = simulation.get_equipped_artifacts()
	if index < 0 or index >= equipped_artifacts.size():
		return

	var old_artifact_id = str(equipped_artifacts[index])
	var new_artifact_id = selected_artifact_replacement_offer_id
	var recommendation = simulation.get_artifact_recommendation_report()
	var result = simulation.replace_artifact(old_artifact_id, new_artifact_id, selected_dormant_artifact_release_id)
	if bool(result.get("ok", false)):
		selected_artifact_replacement_offer_id = ""
		selected_dormant_artifact_release_id = ""
		var release_text = ""
		if bool(result.get("dormant_released", false)):
			release_text = " %s released with no refund." % result.get("released_dormant_artifact_label", "Dormant artifact")
		debug_log.push("Artifact replaced: %s equipped, %s dormant. %s" % [
			result.get("artifact_label", new_artifact_id),
			result.get("replaced_artifact_label", old_artifact_id),
			"%s%s" % [result.get("effect", ""), release_text],
		])
		_push_choice_trace_log("Artifact", "artifact", new_artifact_id, str(result.get("artifact_label", new_artifact_id)), recommendation)
	else:
		debug_log.push("Artifact replacement rejected: %s." % result.get("reason", "blocked"))

	_refresh_screen()


func _on_artifact_release_button_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Artifact release locked: begin the run first.")
		_refresh_log()
		return

	if selected_artifact_replacement_offer_id.is_empty():
		debug_log.push("Artifact release unavailable: choose a new artifact first.")
		_refresh_screen()
		return

	var dormant_artifacts = simulation.get_dormant_artifacts()
	if index < 0 or index >= dormant_artifacts.size():
		return

	selected_dormant_artifact_release_id = str(dormant_artifacts[index])
	debug_log.push("Artifact release selected: %s. Now choose which equipped artifact becomes dormant, or keep current." % simulation.get_artifact_label(selected_dormant_artifact_release_id))
	_refresh_screen()


func _on_skip_artifact_pressed() -> void:
	if not run_started:
		debug_log.push("Artifact skip locked: begin the run first.")
		_refresh_log()
		return

	var recommendation = simulation.get_artifact_recommendation_report()
	var result = simulation.skip_artifact_offer()
	if bool(result["ok"]):
		selected_artifact_replacement_offer_id = ""
		selected_dormant_artifact_release_id = ""
		debug_log.push("Artifact kept current: no party passive changed.")
		_push_choice_trace_log("Artifact", "skip", "", "Keep current artifacts", recommendation)
	else:
		debug_log.push("Artifact skip rejected: %s." % result["reason"])

	_refresh_screen()


func _on_shop_reactivation_dormant_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Shop reactivation locked: begin the run first.")
		_refresh_log()
		return

	var dormant_artifacts = simulation.get_dormant_artifacts()
	if index < 0 or index >= dormant_artifacts.size():
		return

	selected_shop_reactivation_dormant_artifact_id = str(dormant_artifacts[index])
	var slot_report: Dictionary = simulation.get_artifact_slot_report()
	if not bool(slot_report.get("slots_full", false)):
		selected_shop_reactivation_replaced_artifact_id = ""
	var selected_label_text = simulation.get_artifact_label(selected_shop_reactivation_dormant_artifact_id)
	if bool(slot_report.get("slots_full", false)):
		debug_log.push("Shop reactivation selected: %s. Choose which equipped artifact becomes dormant." % selected_label_text)
	else:
		debug_log.push("Shop reactivation selected: %s. Ready to spend a boss shard." % selected_label_text)

	_refresh_screen()


func _on_shop_reactivation_replace_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Shop reactivation swap locked: begin the run first.")
		_refresh_log()
		return

	if selected_shop_reactivation_dormant_artifact_id.is_empty():
		debug_log.push("Shop reactivation swap unavailable: choose a dormant artifact first.")
		_refresh_screen()
		return

	var equipped_artifacts = simulation.get_equipped_artifacts()
	if index < 0 or index >= equipped_artifacts.size():
		return

	selected_shop_reactivation_replaced_artifact_id = str(equipped_artifacts[index])
	debug_log.push("Shop reactivation swap selected: %s becomes dormant. Buy the service to spend a boss shard." % simulation.get_artifact_label(selected_shop_reactivation_replaced_artifact_id))
	_refresh_screen()


func _shop_vote_ready_for_purchase(option_report: Dictionary) -> bool:
	var vote_result = simulation.request_shop_purchase_vote(
		option_report,
		player_count,
		selected_shop_reactivation_dormant_artifact_id,
		selected_shop_reactivation_replaced_artifact_id
	)
	if not bool(vote_result.get("ok", false)):
		debug_log.push("Shop vote rejected: %s." % vote_result.get("reason", "blocked"))
		_push_shop_vote_result(vote_result)
		return false

	_push_shop_vote_result(vote_result)
	return bool(vote_result.get("ready_to_purchase", false))


func _push_shop_vote_result(result: Dictionary) -> void:
	for event in result.get("events", []):
		debug_log.push(str(event))

	if result.has("voteSession"):
		debug_log.push(_format_shop_purchase_vote_session_trace(result), "system")


func _on_shop_button_pressed(index: int) -> void:
	if not run_started:
		debug_log.push("Shop locked: begin the run first.")
		_refresh_log()
		return

	var option_report = simulation.get_shop_option_report_at(index, player_count, selected_class_id)
	if not bool(option_report.get("ok", false)):
		return

	var recommendation = simulation.get_shop_recommendation_report(player_count, selected_class_id)
	if str(option_report.get("shop_option_type", "remove_card")) == "service":
		var service_id = str(option_report.get("service_id", ""))
		var service_type = str(option_report.get("service_type", ""))
		var purchase_report = option_report
		var service_result: Dictionary = {}
		if service_type == "reactivate_dormant_artifact":
			var reactivation_report = _shop_reactivation_report_for_button(option_report)
			if not _shop_reactivation_selection_ready(reactivation_report):
				debug_log.push("Shop reactivation target needed: %s." % _short_block_reason(str(reactivation_report.get("reason", "reactivation_dormant_target_required"))))
				_refresh_screen()
				return

			purchase_report = reactivation_report
			if not _shop_vote_ready_for_purchase(purchase_report):
				_refresh_screen()
				return

			service_result = simulation.buy_shop_service(
				service_id,
				selected_shop_reactivation_dormant_artifact_id,
				selected_shop_reactivation_replaced_artifact_id
			)
		else:
			if not _shop_vote_ready_for_purchase(purchase_report):
				_refresh_screen()
				return

			service_result = simulation.buy_shop_service(service_id)
		if bool(service_result["ok"]):
			selected_card_index = -1
			build_mode = "none"
			_clear_preview()
			_clear_shop_reactivation_selection()
			if str(service_result.get("service_type", "")) == "reactivate_dormant_artifact":
				debug_log.push("Shop service bought: %s [%s]. Boss shards: %s -> %s. Artifact action: %s -> %s." % [
					service_result.get("service_label", service_id),
					service_result.get("service_type", "service"),
					service_result.get("boss_shards_before", 0),
					service_result.get("boss_shards_after", 0),
					service_result.get("artifact_actions_before", 0),
					service_result.get("artifact_actions_after", 0),
				])
				var replaced_text = ""
				if not str(service_result.get("replaced_artifact_label", "")).is_empty():
					replaced_text = " %s became dormant." % service_result.get("replaced_artifact_label", "")
				debug_log.push("Shop service effect: reactivated %s.%s %s" % [
					service_result.get("reactivated_artifact_label", "?"),
					replaced_text,
					service_result.get("loadout_summary", ""),
				])
			else:
				debug_log.push("Shop service bought: %s [%s]. Gold: %s -> %s. Base HP: %s -> %s." % [
					service_result.get("service_label", service_id),
					service_result.get("service_type", "service"),
					service_result.get("gold_before", 0),
					service_result.get("gold_after", 0),
					service_result.get("base_hp_before", 0),
					service_result.get("base_hp_after", 0),
				])
				debug_log.push("Shop service effect: healed %s, reinforced %s structure(s) for +%s total HP. %s" % [
					service_result.get("healed", 0),
					service_result.get("reinforced_structures", 0),
					service_result.get("total_reinforced_hp", 0),
					service_result.get("deck_after_summary", ""),
				])
			_push_choice_trace_log("Shop", "service", service_id, str(service_result.get("service_label", service_id)), recommendation)
		else:
			debug_log.push("Shop service rejected: %s." % service_result["reason"])

		_refresh_screen()
		return

	var card_id = str(option_report.get("card_id", ""))
	if not _shop_vote_ready_for_purchase(option_report):
		_refresh_screen()
		return

	var result = simulation.remove_shop_card(card_id)
	if bool(result["ok"]):
		selected_card_index = -1
		build_mode = "none"
		_clear_preview()
		_clear_shop_reactivation_selection()
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
		_push_choice_trace_log("Shop", "card", card_id, str(result.get("card_label", card_id)), recommendation)
	else:
		debug_log.push("Shop rejected: %s." % result["reason"])

	_refresh_screen()


func _on_skip_shop_pressed() -> void:
	if not run_started:
		debug_log.push("Shop skip locked: begin the run first.")
		_refresh_log()
		return

	if simulation.has_active_shop_purchase_vote():
		var hold_result = simulation.hold_shop_purchase_vote()
		if bool(hold_result.get("ok", false)):
			_push_shop_vote_result(hold_result)
		else:
			debug_log.push("Shop vote hold rejected: %s." % hold_result.get("reason", "blocked"))
		_refresh_screen()
		return

	var recommendation = simulation.get_shop_recommendation_report(player_count, selected_class_id)
	var result = simulation.skip_shop_offer()
	if bool(result["ok"]):
		_clear_shop_reactivation_selection()
		debug_log.push("Shop skipped.")
		_push_choice_trace_log("Shop", "skip", "", "Skip shop", recommendation)
	else:
		debug_log.push("Shop skip rejected: %s." % result["reason"])

	_refresh_screen()


func _push_choice_trace_log(kind: String, chosen_type: String, chosen_id: String, chosen_label: String, recommendation: Dictionary) -> void:
	var trace_line = _format_choice_trace_line(kind, chosen_type, chosen_id, chosen_label, recommendation)
	if trace_line.is_empty():
		return

	debug_log.push(trace_line, "system")


func _format_choice_trace_line(kind: String, chosen_type: String, chosen_id: String, chosen_label: String, recommendation: Dictionary) -> String:
	var picked_label = chosen_label
	if picked_label.is_empty():
		picked_label = chosen_id if not chosen_id.is_empty() else chosen_type

	if not bool(recommendation.get("ok", false)):
		return "%s choice trace: picked %s; no active suggestion (%s)." % [
			kind,
			picked_label,
			recommendation.get("reason_text", recommendation.get("reason", "none")),
		]

	var suggested_type = str(recommendation.get("choice_type", chosen_type))
	if suggested_type.is_empty() or suggested_type == "none":
		suggested_type = chosen_type

	var suggested_id = _choice_trace_suggested_id(kind, suggested_type, recommendation)
	var suggested_label = str(recommendation.get("label", suggested_id if not suggested_id.is_empty() else suggested_type))
	var followed = _choice_trace_matches(chosen_type, chosen_id, suggested_type, suggested_id)
	var state_text = "followed suggestion" if followed else "bypassed suggestion"
	var parts = PackedStringArray()
	parts.append("%s choice trace: %s; picked %s; suggested %s" % [
		kind,
		state_text,
		picked_label,
		suggested_label,
	])

	var reason_text = str(recommendation.get("reason_text", ""))
	if not reason_text.is_empty():
		parts.append("Reason: %s" % reason_text)

	var detail_text = _compact_choice_trace_detail(str(recommendation.get("detail_text", "")))
	if not detail_text.is_empty():
		parts.append("Why now: %s" % detail_text)

	return "%s." % ". ".join(parts)


func _choice_trace_suggested_id(kind: String, suggested_type: String, recommendation: Dictionary) -> String:
	match kind.to_lower():
		"artifact":
			return str(recommendation.get("artifact_id", ""))
		"shop":
			if suggested_type == "service":
				return str(recommendation.get("service_id", ""))
			return str(recommendation.get("card_id", ""))
		_:
			if suggested_type == "gold":
				return ""
			return str(recommendation.get("card_id", ""))


func _choice_trace_matches(chosen_type: String, chosen_id: String, suggested_type: String, suggested_id: String) -> bool:
	if chosen_type != suggested_type:
		return false
	if suggested_id.is_empty():
		return true
	return chosen_id == suggested_id


func _compact_choice_trace_detail(detail_text: String) -> String:
	if detail_text.is_empty():
		return ""

	var detail_parts = detail_text.split("|", false)
	if detail_parts.size() <= 4:
		return detail_text

	var compact_parts = PackedStringArray()
	for index in range(min(4, detail_parts.size())):
		compact_parts.append(str(detail_parts[index]).strip_edges())
	return " | ".join(compact_parts)


func _on_start_wave_pressed() -> void:
	if not simulation.is_loaded():
		debug_log.push("Cannot start wave: data is not loaded.")
		_refresh_log()
		return

	if not run_started:
		debug_log.push("Cannot start wave: begin the run first.")
		_refresh_log()
		return

	var active_player_count = _run_player_count()
	var result = simulation.start_wave(active_player_count)
	if bool(result["ok"]):
		confirmed_risk_ping_marker.clear()
		debug_log.push(_format_wave_started_lock_trace(result), "system")
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
		debug_log.push("Cannot pull next wave: data is not loaded.")
		_refresh_log()
		return

	if not run_started:
		debug_log.push("Cannot pull next wave: begin the run first.")
		_refresh_log()
		return

	var active_player_count = _run_player_count()
	var pull_tempo_line = _wave_pull_tempo_line(active_player_count)
	debug_log.push("Stack risk before pull: %s" % simulation.get_wave_stack_risk_summary(active_player_count))
	if not pull_tempo_line.is_empty():
		debug_log.push("Pull tempo before pull: %s" % pull_tempo_line)
	var result = simulation.stack_next_wave(active_player_count)
	if bool(result["ok"]):
		confirmed_risk_ping_marker.clear()
		var vote_session: Dictionary = result.get("voteSession", {})
		if not vote_session.is_empty():
			debug_log.push(_format_wave_stack_vote_session_trace(result), "system")
		var stack_report: Dictionary = result.get("wave_stack", {})
		if not stack_report.is_empty():
			debug_log.push(_format_wave_stack_contract_trace(result), "system")
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
		confirmed_risk_ping_marker.clear()
		var vote_session: Dictionary = result.get("voteSession", {})
		if not vote_session.is_empty():
			debug_log.push(_format_wave_stack_vote_session_trace(result), "system")
		for event in result.get("events", []):
			debug_log.push(str(event))
	else:
		debug_log.push("Wave stack vote hold rejected: %s." % result["reason"])

	_refresh_screen()


func _on_risk_ping_button_pressed(index: int) -> void:
	if not simulation.is_loaded():
		debug_log.push("Risk ping unavailable: data is not loaded.", "system")
		_refresh_log()
		return

	if not run_started:
		debug_log.push("Risk ping unavailable: begin the run first.", "system")
		_refresh_log()
		return

	var report = simulation.get_risk_ping_report(player_count, selected_class_id)
	var candidates: Array = report.get("candidates", []) if bool(report.get("ok", false)) else []
	if index < 0 or index >= candidates.size() or typeof(candidates[index]) != TYPE_DICTIONARY:
		debug_log.push("Risk ping unavailable: no candidate at that slot.", "system")
		_refresh_screen()
		return

	var candidate: Dictionary = candidates[index]
	confirmed_risk_ping_marker = _risk_ping_marker_from_candidate(candidate, report)
	debug_log.push("Risk ping confirmed: %s [%s]. Source: %s. Reason: %s." % [
		candidate.get("label", "Ping"),
		candidate.get("tag", "risk_ping"),
		report.get("source_label", "-"),
		candidate.get("reason", "-"),
	], "system")
	_refresh_screen()


func _risk_ping_marker_from_candidate(candidate: Dictionary, report: Dictionary) -> Dictionary:
	var tile_value = candidate.get("tile", INVALID_TILE)
	if typeof(tile_value) != TYPE_VECTOR2I:
		return {}

	var tile: Vector2i = tile_value
	if not _is_valid_tile(tile):
		return {}

	return {
		"tile": tile,
		"label": "P",
		"candidate_label": str(candidate.get("label", "Ping")),
		"tag": str(candidate.get("tag", "risk_ping")),
		"source_label": str(report.get("source_label", "-")),
		"reason": str(candidate.get("reason", "-")),
	}


func _on_step_wave_pressed() -> void:
	if not run_started:
		debug_log.push("No active run to step.")
		_refresh_log()
		return

	if not simulation.wave_active:
		debug_log.push("No active wave to step.")
		_refresh_log()
		return

	confirmed_risk_ping_marker.clear()
	_run_wave_step()


func _on_autoplay_case_pressed() -> void:
	wave_timer.stop()
	_ensure_selected_class_id()

	if selected_class_id.is_empty():
		debug_log.push("Autoplay case rejected: no class profile loaded.")
		_refresh_log()
		return

	var runner = M0AutoplayRunnerScript.new()
	var result = runner.run_class_profile(selected_class_id, player_count)
	_push_autoplay_result("Autoplay case", result)
	_refresh_screen()


func _on_autoplay_pressed() -> void:
	wave_timer.stop()

	var runner = M0AutoplayRunnerScript.new()
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

	var runner = M0AutoplayRunnerScript.new()
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

	_set_autoplay_focus_queue(report)
	_push_autoplay_focus_queue(report)
	_push_autoplay_next_action_queue(report)


func _set_autoplay_focus_queue(report: Dictionary) -> void:
	last_autoplay_focus_queue = report.get("alpha_focus_queue", []).duplicate(true)
	last_autoplay_next_action_queue = report.get("next_action_queue", []).duplicate(true)
	last_autoplay_recommendation_contrast_samples = _autoplay_recommendation_contrast_samples_from_report(report)
	selected_autoplay_focus_index = 0
	selected_autoplay_recommendation_contrast_index = 0
	active_alpha_probe_entry.clear()
	alpha_focus_probe_results.clear()
	alpha_focus_manual_review_results.clear()
	var load_result = _load_alpha_manual_review_results_for_focus_queue()
	if bool(load_result.get("ok", false)) and int(load_result.get("loaded_count", 0)) > 0:
		debug_log.push("Human review restored: %s saved cases." % load_result.get("loaded_count", 0), "system")
	elif not bool(load_result.get("ok", false)):
		debug_log.push("Human review restore skipped: %s." % load_result.get("reason", "unknown"), "system")
	last_boss_warning_response_line = ""
	_refresh_alpha_focus_panel()
	_refresh_alpha_coverage_panel()
	_refresh_map_view()


func _clear_autoplay_focus_queue() -> void:
	last_autoplay_focus_queue.clear()
	last_autoplay_next_action_queue.clear()
	last_autoplay_recommendation_contrast_samples.clear()
	selected_autoplay_focus_index = 0
	selected_autoplay_recommendation_contrast_index = 0
	active_alpha_probe_entry.clear()
	alpha_focus_probe_results.clear()
	alpha_focus_manual_review_results.clear()
	last_boss_warning_response_line = ""
	_refresh_alpha_focus_panel()
	_refresh_alpha_coverage_panel()
	_refresh_map_view()


func _refresh_alpha_focus_panel() -> void:
	if alpha_focus_panel == null:
		return

	alpha_focus_panel.visible = not last_autoplay_focus_queue.is_empty() or not last_autoplay_next_action_queue.is_empty()
	if last_autoplay_focus_queue.is_empty():
		if alpha_focus_title_label != null:
			alpha_focus_title_label.text = "Alpha focus: next actions" if not last_autoplay_next_action_queue.is_empty() else "Alpha focus: -"
		if alpha_focus_body_label != null:
			alpha_focus_body_label.text = _format_next_action_queue_panel_body()
		if alpha_focus_prev_button != null:
			alpha_focus_prev_button.disabled = true
		if alpha_focus_next_button != null:
			alpha_focus_next_button.disabled = true
		_refresh_alpha_focus_action_button({})
		if alpha_focus_apply_button != null:
			alpha_focus_apply_button.disabled = true
			alpha_focus_apply_button.text = "Use setup"
		if alpha_focus_probe_button != null:
			alpha_focus_probe_button.disabled = true
			alpha_focus_probe_button.text = "Run probe"
		if alpha_focus_probe_status_label != null:
			alpha_focus_probe_status_label.text = ""
		_refresh_alpha_contrast_controls({})
		_refresh_alpha_focus_manual_review_controls({})
		return

	selected_autoplay_focus_index = clamp(selected_autoplay_focus_index, 0, last_autoplay_focus_queue.size() - 1)
	var entry: Dictionary = last_autoplay_focus_queue[selected_autoplay_focus_index]
	if alpha_focus_title_label != null:
		alpha_focus_title_label.text = _format_autoplay_focus_panel_title(entry, selected_autoplay_focus_index, last_autoplay_focus_queue.size())
	if alpha_focus_body_label != null:
		alpha_focus_body_label.text = _format_autoplay_focus_panel_body(entry)
	if alpha_focus_prev_button != null:
		alpha_focus_prev_button.disabled = last_autoplay_focus_queue.size() <= 1
	if alpha_focus_next_button != null:
		alpha_focus_next_button.disabled = last_autoplay_focus_queue.size() <= 1
	_refresh_alpha_focus_action_button(entry)
	if alpha_focus_apply_button != null:
		var has_setup = _alpha_focus_entry_has_setup(entry)
		alpha_focus_apply_button.disabled = run_started or not has_setup
		alpha_focus_apply_button.text = "Reset first" if run_started else "Use setup"
	if alpha_focus_probe_button != null:
		var has_probe_setup = _alpha_focus_entry_has_setup(entry)
		alpha_focus_probe_button.disabled = run_started or not has_probe_setup
		alpha_focus_probe_button.text = "Reset first" if run_started else "Run probe"
	if alpha_focus_probe_status_label != null:
		alpha_focus_probe_status_label.text = _format_alpha_probe_status()
	_refresh_alpha_contrast_controls(entry)
	_refresh_alpha_focus_manual_review_controls(entry)


func _refresh_alpha_focus_action_button(entry: Dictionary) -> void:
	if alpha_focus_action_button == null:
		return

	var action = _selected_next_action_for_panel(entry)
	var setup_report = _next_action_setup_report(action, entry)
	alpha_focus_action_button.disabled = not bool(setup_report.get("ok", false))
	alpha_focus_action_button.text = "Reset first" if run_started else "Use action"
	alpha_focus_action_button.tooltip_text = str(setup_report.get("summary", setup_report.get("reason", "No action queue case selected.")))


func _refresh_alpha_contrast_controls(entry: Dictionary) -> void:
	var samples = _autoplay_recommendation_contrast_samples_for_entry(entry)
	var sample_count = samples.size()
	if sample_count <= 0:
		selected_autoplay_recommendation_contrast_index = 0
	else:
		selected_autoplay_recommendation_contrast_index = clamp(selected_autoplay_recommendation_contrast_index, 0, sample_count - 1)

	if alpha_focus_contrast_prev_button != null:
		alpha_focus_contrast_prev_button.disabled = sample_count <= 1
	if alpha_focus_contrast_next_button != null:
		alpha_focus_contrast_next_button.disabled = sample_count <= 1
	if alpha_focus_contrast_status_label != null:
		if sample_count <= 0:
			alpha_focus_contrast_status_label.text = "Contrast sample: none"
		else:
			var sample: Dictionary = samples[selected_autoplay_recommendation_contrast_index]
			alpha_focus_contrast_status_label.text = "Contrast sample %s/%s: %s R%s" % [
				selected_autoplay_recommendation_contrast_index + 1,
				sample_count,
				str(sample.get("choice_type", "choice")),
				sample.get("round", 0),
			]


func _refresh_alpha_focus_manual_review_controls(entry: Dictionary) -> void:
	var has_entry = not entry.is_empty()
	if alpha_focus_manual_status_label != null:
		alpha_focus_manual_status_label.text = _format_alpha_focus_manual_review_status(entry)
	if alpha_focus_issue_tag_option != null:
		alpha_focus_issue_tag_option.disabled = not has_entry
		alpha_focus_issue_tag_option.select(_alpha_issue_tag_index(_alpha_issue_tag_id_for_entry(entry)))
	if alpha_focus_recommendation_contrast_option != null:
		alpha_focus_recommendation_contrast_option.disabled = not has_entry
		alpha_focus_recommendation_contrast_option.select(_alpha_recommendation_contrast_index(_alpha_recommendation_contrast_id_for_entry(entry)))
	_refresh_alpha_recommendation_fix_check_controls(entry)
	if alpha_focus_mark_clear_button != null:
		alpha_focus_mark_clear_button.disabled = not has_entry
		if _alpha_focus_is_clear_candidate(entry):
			alpha_focus_mark_clear_button.text = "Confirm clear"
			alpha_focus_mark_clear_button.tooltip_text = "Probe improved this issue. Confirm after a human check."
		else:
			alpha_focus_mark_clear_button.text = "Mark clear"
			alpha_focus_mark_clear_button.tooltip_text = "Mark this case clear after a human check."
	if alpha_focus_mark_issue_button != null:
		alpha_focus_mark_issue_button.disabled = not has_entry


func _refresh_alpha_recommendation_fix_check_controls(entry: Dictionary) -> void:
	var contrast_id = _alpha_recommendation_contrast_id_for_entry(entry)
	var selected_ids = _alpha_recommendation_fix_check_ids_for_entry(entry)
	_refresh_alpha_recommendation_fix_check_controls_for_selection(not entry.is_empty(), contrast_id, selected_ids)


func _refresh_alpha_recommendation_fix_check_controls_for_selection(has_entry: bool, contrast_id: String, selected_ids: Array) -> void:
	var enabled = has_entry and _alpha_recommendation_contrast_needs_fix(contrast_id)
	for index in range(alpha_focus_recommendation_fix_check_buttons.size()):
		var check_button = alpha_focus_recommendation_fix_check_buttons[index]
		if check_button == null:
			continue

		var check_id = _alpha_recommendation_fix_check_id_for_index(index)
		check_button.disabled = not enabled
		check_button.button_pressed = selected_ids.has(check_id) if enabled else false


func _refresh_alpha_coverage_panel() -> void:
	if alpha_coverage_panel == null:
		return

	if alpha_coverage_run_button != null:
		alpha_coverage_run_button.disabled = not simulation.is_loaded()
		alpha_coverage_run_button.text = "Run coverage"
	_refresh_alpha_coverage_issue_button()

	if last_alpha_coverage_result.is_empty():
		if alpha_coverage_title_label != null:
			alpha_coverage_title_label.text = "Alpha coverage: not run"
		if alpha_coverage_body_label != null:
			alpha_coverage_body_label.text = "Functional class checks are ready." if simulation.is_loaded() else "Data is not loaded."
		return

	var aggregate: Dictionary = last_alpha_coverage_result.get("aggregate", {})
	var ok = bool(last_alpha_coverage_result.get("ok", false))
	var case_count = int(aggregate.get("case_count", 0))
	var pass_count = int(aggregate.get("pass_count", 0))
	if alpha_coverage_title_label != null:
		alpha_coverage_title_label.text = "Alpha coverage: %s %s/%s" % [
			"PASS" if ok else "FAIL",
			pass_count,
			case_count,
		]
	if alpha_coverage_body_label != null:
		alpha_coverage_body_label.text = _format_alpha_coverage_panel_body(last_alpha_coverage_result)
	_refresh_alpha_coverage_issue_button()


func _refresh_alpha_coverage_issue_button() -> void:
	var next_manual_index = _alpha_first_remaining_review_index()
	var next_priority_case = _alpha_next_priority_case_summary()
	if alpha_coverage_open_next_manual_button != null:
		alpha_coverage_open_next_manual_button.disabled = next_manual_index < 0
		alpha_coverage_open_next_manual_button.text = "Open priority" if next_manual_index >= 0 else "No manual"
		alpha_coverage_open_next_manual_button.tooltip_text = (
			_format_alpha_next_priority_button_tooltip(next_priority_case)
			if next_manual_index >= 0
			else "Every human alpha case in this queue has been marked."
		)

	var issue_index = _alpha_first_issue_review_index()
	if alpha_coverage_open_issue_button != null:
		alpha_coverage_open_issue_button.disabled = issue_index < 0
		alpha_coverage_open_issue_button.text = "Open issue" if issue_index >= 0 else "No issue"
		alpha_coverage_open_issue_button.tooltip_text = (
			"Jump to the first human review case marked as an issue."
			if issue_index >= 0
			else "No human review issue has been marked."
		)

	var fix_recommendation: Dictionary = _alpha_manual_review_report().get("fix_recommendation", {})
	var fix_lane_index = _alpha_fix_lane_review_index()
	var fix_lane_entry = _alpha_fix_lane_entry()
	if alpha_coverage_open_fix_lane_button != null:
		alpha_coverage_open_fix_lane_button.disabled = fix_lane_index < 0
		alpha_coverage_open_fix_lane_button.text = "Open fix lane" if fix_lane_index >= 0 else "No fix lane"
		var fix_text = _format_alpha_fix_recommendation(fix_recommendation)
		alpha_coverage_open_fix_lane_button.tooltip_text = (
			"Jump to the top fix lane: %s." % fix_text
			if fix_lane_index >= 0 and not fix_text.is_empty()
			else "No human review issue has a fix recommendation."
		)

	var recommendation_fix_report = _alpha_manual_review_report()
	var recommendation_fix: Dictionary = recommendation_fix_report.get("recommendation_contrast_fix", {})
	var recommendation_fix_index = _alpha_recommendation_fix_review_index()
	if alpha_coverage_open_recommendation_fix_button != null:
		alpha_coverage_open_recommendation_fix_button.disabled = recommendation_fix_index < 0
		alpha_coverage_open_recommendation_fix_button.text = "Open rec fix" if recommendation_fix_index >= 0 else "No rec fix"
		var recommendation_fix_text = _format_alpha_recommendation_contrast_fix(recommendation_fix)
		alpha_coverage_open_recommendation_fix_button.tooltip_text = (
			"Jump to the top recommendation wording fix: %s." % recommendation_fix_text
			if recommendation_fix_index >= 0 and not recommendation_fix_text.is_empty()
			else "No recommendation wording issue has been marked."
		)

	if alpha_coverage_probe_fix_lane_button != null:
		var has_fix_probe_setup = _alpha_focus_entry_has_setup(fix_lane_entry)
		alpha_coverage_probe_fix_lane_button.disabled = run_started or fix_lane_index < 0 or not has_fix_probe_setup
		if run_started:
			alpha_coverage_probe_fix_lane_button.text = "Reset first"
		elif fix_lane_index < 0:
			alpha_coverage_probe_fix_lane_button.text = "No fix probe"
		else:
			alpha_coverage_probe_fix_lane_button.text = "Probe fix lane"
		var probe_fix_lane_tooltip = "No recommended fix lane can be probed."
		if run_started:
			probe_fix_lane_tooltip = "Reset before probing the recommended fix lane."
		elif fix_lane_index >= 0 and has_fix_probe_setup:
			probe_fix_lane_tooltip = "Jump to the top fix lane and run its opening probe: %s." % _format_alpha_fix_recommendation(fix_recommendation)
		alpha_coverage_probe_fix_lane_button.tooltip_text = probe_fix_lane_tooltip


func _format_alpha_coverage_panel_body(result: Dictionary) -> String:
	if result.is_empty():
		return "Functional class checks are ready."

	var aggregate: Dictionary = result.get("aggregate", {})
	var lines = []
	var required_signal_count = int(aggregate.get("required_signal_count", 0))
	var observed_signal_count = int(aggregate.get("observed_signal_count", 0))
	var missing_signal_ids = _string_values_from_array(aggregate.get("missing_signal_ids", []))
	var reject_reason_ids = _string_values_from_array(aggregate.get("reject_reason_ids", []))
	var summary_lines = _string_values_from_array(result.get("summary_lines", []))
	var human_review_queue = result.get("human_review_queue", [])
	lines.append("Scope: functionality only, human alpha still required.")
	lines.append("Signals: %s/%s observed" % [observed_signal_count, required_signal_count])
	lines.append("Missing: %s" % ("none" if missing_signal_ids.is_empty() else ", ".join(missing_signal_ids)))
	lines.append("Expected rejects: %s" % ("none" if reject_reason_ids.is_empty() else ", ".join(reject_reason_ids)))
	var recommendation_choice_summary = str(aggregate.get("recommendation_choice_summary", ""))
	if not recommendation_choice_summary.is_empty():
		lines.append("Recommendation choices: %s" % recommendation_choice_summary)
	var recommendation_class_summary = str(aggregate.get("recommendation_class_summary", ""))
	if not recommendation_class_summary.is_empty():
		lines.append("Recommendation by class: %s" % recommendation_class_summary)
	var recommendation_party_summary = str(aggregate.get("recommendation_party_summary", ""))
	if not recommendation_party_summary.is_empty():
		lines.append("Recommendation by party: %s" % recommendation_party_summary)
	var recommendation_front_summary = str(aggregate.get("recommendation_front_summary", ""))
	if not recommendation_front_summary.is_empty():
		lines.append("Recommendation by front: %s" % recommendation_front_summary)
	var recommendation_focus_summary = str(aggregate.get("recommendation_focus_summary", ""))
	if not recommendation_focus_summary.is_empty():
		lines.append("Recommendation focus: %s" % recommendation_focus_summary)
	lines.append("Human review queue: %s cases" % human_review_queue.size())
	if human_review_queue.size() > 0:
		var review_report = _alpha_manual_review_report()
		lines.append(_format_alpha_manual_review_report_summary(review_report))
		lines.append(_format_alpha_review_gap_summary(review_report))
		var priority_spread_text = _format_alpha_review_priority_spread_line()
		if not priority_spread_text.is_empty():
			lines.append(priority_spread_text)
		var priority_lane_text = _format_alpha_review_priority_lane_line()
		if not priority_lane_text.is_empty():
			lines.append(priority_lane_text)
		var next_priority_text = _format_alpha_next_priority_line()
		if not next_priority_text.is_empty():
			lines.append(next_priority_text)
		lines.append("Fix queue: %s open" % review_report.get("issue_count", 0))
		var recommendation_fix_cases: Array = review_report.get("recommendation_fix_cases", [])
		if not recommendation_fix_cases.is_empty():
			lines.append("Recommendation wording queue: %s open" % recommendation_fix_cases.size())
		var issue_tag_text = _format_alpha_issue_tag_summary(review_report.get("issue_tag_summary", []))
		if not issue_tag_text.is_empty():
			lines.append("Issue tags: %s" % issue_tag_text)
		var recommendation_contrast_text = _format_alpha_recommendation_contrast_summary(review_report.get("recommendation_contrast_summary", []))
		if not recommendation_contrast_text.is_empty():
			lines.append("Recommendation contrast: %s" % recommendation_contrast_text)
		var recommendation_contrast_fix_text = _format_alpha_recommendation_contrast_fix(review_report.get("recommendation_contrast_fix", {}))
		if not recommendation_contrast_fix_text.is_empty():
			lines.append("Recommendation wording fix: %s" % recommendation_contrast_fix_text)
			var recommendation_fix_case_text = _format_alpha_recommendation_fix_case(review_report)
			if not recommendation_fix_case_text.is_empty():
				lines.append("Recommendation wording case: %s" % recommendation_fix_case_text)
			var recommendation_fix_priority_text = _format_alpha_recommendation_fix_check_priority(review_report.get("recommendation_fix_check_priority", {}))
			if not recommendation_fix_priority_text.is_empty():
				lines.append("Recommendation wording priority: %s" % recommendation_fix_priority_text)
			var recommendation_fix_check_text = _format_alpha_recommendation_fix_check_summary(review_report.get("recommendation_fix_check_summary", []))
			if not recommendation_fix_check_text.is_empty():
				lines.append("Recommendation wording checks: %s" % recommendation_fix_check_text)
		var fix_recommendation_text = _format_alpha_fix_recommendation(review_report.get("fix_recommendation", {}))
		if not fix_recommendation_text.is_empty():
			lines.append("Fix recommendation: %s" % fix_recommendation_text)
			var fix_lane_case_text = _format_alpha_fix_lane_case(review_report)
			if not fix_lane_case_text.is_empty():
				lines.append("Fix lane case: %s" % fix_lane_case_text)
				lines.append("Fix lane probe: %s" % _format_alpha_fix_lane_probe_status(review_report))
				lines.append("Fix lane priority: %s" % _format_alpha_fix_lane_priority(review_report))
		var issue_text = _format_alpha_review_case_list(review_report.get("issue_cases", []), 3)
		if not issue_text.is_empty():
			lines.append("Issue cases: %s" % issue_text)
		var next_text = _format_alpha_review_case_list(_alpha_remaining_review_cases_by_priority(), 3)
		if not next_text.is_empty():
			lines.append("Next manual: %s" % next_text)
	if not summary_lines.is_empty():
		lines.append("Cases:")
		for line in summary_lines:
			lines.append("- %s" % line)
	return "\n".join(lines)


func _string_values_from_array(value) -> Array:
	var result = []
	if typeof(value) != TYPE_ARRAY:
		return result

	for item in value:
		result.append(str(item))
	return result


func _alpha_manual_review_report() -> Dictionary:
	var clear_cases: Array = []
	var issue_cases: Array = []
	var recommendation_fix_cases: Array = []
	var remaining_cases: Array = []
	var issue_tag_counts: Dictionary = {}
	var recommendation_contrast_counts: Dictionary = {}
	var recommendation_fix_check_counts: Dictionary = {}
	for index in range(last_autoplay_focus_queue.size()):
		var entry_value = last_autoplay_focus_queue[index]
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		var manual_result = _alpha_focus_manual_review_result_for_entry(entry)
		var status = str(manual_result.get("status", ""))
		var case_summary = _alpha_review_case_summary_for_entry(index, entry, manual_result)
		match status:
			"manual_clear":
				clear_cases.append(case_summary)
				var clear_contrast_id = str(case_summary.get("recommendation_contrast_id", "not_checked"))
				recommendation_contrast_counts[clear_contrast_id] = int(recommendation_contrast_counts.get(clear_contrast_id, 0)) + 1
				if _alpha_recommendation_contrast_needs_fix(clear_contrast_id):
					recommendation_fix_cases.append(case_summary)
					_count_alpha_recommendation_fix_checks(recommendation_fix_check_counts, case_summary.get("recommendation_fix_check_ids", []))
			"manual_issue":
				issue_cases.append(case_summary)
				var tag_id = str(case_summary.get("issue_tag_id", "untagged"))
				issue_tag_counts[tag_id] = int(issue_tag_counts.get(tag_id, 0)) + 1
				var issue_contrast_id = str(case_summary.get("recommendation_contrast_id", "not_checked"))
				recommendation_contrast_counts[issue_contrast_id] = int(recommendation_contrast_counts.get(issue_contrast_id, 0)) + 1
				if _alpha_recommendation_contrast_needs_fix(issue_contrast_id):
					recommendation_fix_cases.append(case_summary)
					_count_alpha_recommendation_fix_checks(recommendation_fix_check_counts, case_summary.get("recommendation_fix_check_ids", []))
			_:
				remaining_cases.append(case_summary)

	var issue_tag_summary = _alpha_issue_tag_summary_from_counts(issue_tag_counts)
	var recommendation_contrast_summary = _alpha_recommendation_contrast_summary_from_counts(recommendation_contrast_counts)
	var recommendation_fix_check_summary = _alpha_recommendation_fix_check_summary_from_counts(recommendation_fix_check_counts)
	var recommendation_fix_check_priority = _alpha_recommendation_fix_check_priority_from_summary(recommendation_fix_check_summary)
	var fix_recommendation = _alpha_fix_recommendation_from_issue_tags(issue_tag_summary)
	var recommendation_contrast_fix = _alpha_recommendation_contrast_fix_from_summary(recommendation_contrast_summary)
	return {
		"total_count": last_autoplay_focus_queue.size(),
		"clear_count": clear_cases.size(),
		"issue_count": issue_cases.size(),
		"remaining_count": remaining_cases.size(),
		"clear_cases": clear_cases,
		"issue_cases": issue_cases,
		"recommendation_fix_cases": recommendation_fix_cases,
		"remaining_cases": remaining_cases,
		"issue_tag_counts": issue_tag_counts,
		"issue_tag_summary": issue_tag_summary,
		"recommendation_contrast_counts": recommendation_contrast_counts,
		"recommendation_contrast_summary": recommendation_contrast_summary,
		"recommendation_fix_check_counts": recommendation_fix_check_counts,
		"recommendation_fix_check_summary": recommendation_fix_check_summary,
		"recommendation_fix_check_priority": recommendation_fix_check_priority,
		"fix_recommendation": fix_recommendation,
		"recommendation_contrast_fix": recommendation_contrast_fix,
	}


func _alpha_remaining_review_cases_by_priority() -> Array:
	var remaining_cases: Array = []
	var order = _alpha_focus_review_order()
	for item_value in order:
		if typeof(item_value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = item_value
		var status = str(item.get("status", ""))
		if status == "manual_issue" or status == "manual_clear":
			continue

		var index = int(item.get("index", -1))
		if index < 0 or index >= last_autoplay_focus_queue.size():
			continue

		var entry_value = last_autoplay_focus_queue[index]
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		remaining_cases.append(_alpha_review_case_summary_for_entry(index, entry, {}))

	return remaining_cases


func _alpha_review_case_summary_for_entry(index: int, entry: Dictionary, manual_result: Dictionary) -> Dictionary:
	return {
		"index": index,
		"rank": int(entry.get("rank", index + 1)),
		"label": _alpha_focus_case_label(entry),
		"class_id": str(entry.get("class_id", "")),
		"class_label": str(entry.get("class_label", _class_label(str(entry.get("class_id", ""))))),
		"player_count": int(entry.get("player_count", 0)),
		"direction": str(entry.get("direction", "")),
		"active_directions": _string_values_from_array(entry.get("active_directions", [])),
		"status": str(manual_result.get("status", "")),
		"issue_tag_id": str(manual_result.get("issue_tag_id", "untagged")),
		"issue_tag_label": str(manual_result.get("issue_tag_label", "")),
		"recommendation_contrast_id": str(manual_result.get("recommendation_contrast_id", "not_checked")),
		"recommendation_contrast_label": str(manual_result.get("recommendation_contrast_label", "")),
		"recommendation_fix_check_ids": _normalized_alpha_recommendation_fix_check_ids(manual_result.get("recommendation_fix_check_ids", [])),
		"recommendation_fix_check_text": _format_alpha_recommendation_fix_check_labels(manual_result.get("recommendation_fix_check_ids", [])),
		"review_priority_score": int(entry.get("review_priority_score", 0)),
		"review_priority_reason": str(entry.get("review_priority_reason", "")),
	}


func _format_alpha_next_priority_line() -> String:
	var case_summary = _alpha_next_priority_case_summary()
	if case_summary.is_empty():
		return ""

	var score = int(case_summary.get("review_priority_score", 0))
	var score_text = "score %s" % score if score > 0 else "unscored"
	var reason = _compact_alpha_review_priority_reason(str(case_summary.get("review_priority_reason", "")), 2)
	var reason_text = "" if reason.is_empty() else " | %s" % reason
	return "Next priority: %s | %s%s" % [
		case_summary.get("label", "case"),
		score_text,
		reason_text,
	]


func _format_alpha_review_priority_spread_line() -> String:
	var report = _alpha_review_priority_spread_report()
	if report.is_empty():
		return "Priority spread: none"

	var top_class: Dictionary = report.get("top_class", {})
	var top_front: Dictionary = report.get("top_front", {})
	return "Priority spread: high %s / medium %s / low %s | top class %s | top front %s" % [
		report.get("high_count", 0),
		report.get("medium_count", 0),
		report.get("low_count", 0),
		_format_alpha_review_priority_score_entry(top_class),
		_format_alpha_review_priority_score_entry(top_front),
	]


func _format_alpha_review_priority_lane_line() -> String:
	var report = _alpha_review_priority_spread_report()
	var next_case = _alpha_next_priority_case_summary()
	if report.is_empty() or next_case.is_empty():
		return ""

	var top_class: Dictionary = report.get("top_class", {})
	var top_front: Dictionary = report.get("top_front", {})
	return "Priority lane: %s + %s | start %s" % [
		top_class.get("label", "Class"),
		top_front.get("label", "front"),
		next_case.get("label", "case"),
	]


func _alpha_review_priority_spread_report() -> Dictionary:
	var remaining_cases = _alpha_remaining_review_cases_by_priority()
	if remaining_cases.is_empty():
		return {}

	var high_count = 0
	var medium_count = 0
	var low_count = 0
	var class_scores: Dictionary = {}
	var class_order: Array = []
	var front_scores: Dictionary = {}
	var front_order: Array = []
	for case_value in remaining_cases:
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_summary: Dictionary = case_value
		var score = int(case_summary.get("review_priority_score", 0))
		match _alpha_review_priority_bucket(score):
			"high":
				high_count += 1
			"medium":
				medium_count += 1
			_:
				low_count += 1

		_alpha_review_add_priority_score(
			class_scores,
			class_order,
			str(case_summary.get("class_label", "Class")),
			score
		)
		_alpha_review_add_priority_score(
			front_scores,
			front_order,
			_alpha_review_front_gap_label(case_summary),
			score
		)

	return {
		"high_count": high_count,
		"medium_count": medium_count,
		"low_count": low_count,
		"top_class": _alpha_review_top_priority_score_entry(class_scores, class_order),
		"top_front": _alpha_review_top_priority_score_entry(front_scores, front_order),
	}


func _alpha_review_priority_bucket(score: int) -> String:
	if score >= 30:
		return "high"
	if score >= 24:
		return "medium"
	return "low"


func _alpha_review_add_priority_score(scores: Dictionary, order: Array, label: String, score: int) -> void:
	if label.is_empty():
		return
	if not scores.has(label):
		order.append(label)
		scores[label] = {
			"score": 0,
			"cases": 0,
		}

	var entry: Dictionary = scores.get(label, {})
	entry["score"] = int(entry.get("score", 0)) + score
	entry["cases"] = int(entry.get("cases", 0)) + 1
	scores[label] = entry


func _alpha_review_top_priority_score_entry(scores: Dictionary, order: Array) -> Dictionary:
	var best_label = ""
	var best_score = -1
	var best_cases = 0
	for label_value in order:
		var label = str(label_value)
		var entry: Dictionary = scores.get(label, {})
		var score = int(entry.get("score", 0))
		var case_count = int(entry.get("cases", 0))
		if best_label.is_empty() or score > best_score:
			best_label = label
			best_score = score
			best_cases = case_count

	if best_label.is_empty():
		return {}

	return {
		"label": best_label,
		"score": best_score,
		"cases": best_cases,
	}


func _format_alpha_review_priority_score_entry(entry: Dictionary) -> String:
	if entry.is_empty():
		return "none"

	return "%s score %s (%s cases)" % [
		entry.get("label", "case"),
		entry.get("score", 0),
		entry.get("cases", 0),
	]


func _alpha_next_priority_case_summary() -> Dictionary:
	var remaining_cases = _alpha_remaining_review_cases_by_priority()
	if remaining_cases.is_empty():
		return {}

	var case_value = remaining_cases[0]
	if typeof(case_value) != TYPE_DICTIONARY:
		return {}

	var case_summary: Dictionary = case_value
	return case_summary


func _format_alpha_next_priority_button_tooltip(case_summary: Dictionary) -> String:
	if case_summary.is_empty():
		return "Jump to the highest-priority unreviewed human alpha case."

	var score = int(case_summary.get("review_priority_score", 0))
	var score_text = "score %s" % score if score > 0 else "unscored"
	var reason = _compact_alpha_review_priority_reason(str(case_summary.get("review_priority_reason", "")), 1)
	var reason_text = "" if reason.is_empty() else " Reason: %s." % reason
	return "Jump to highest-priority unreviewed case: %s (%s).%s" % [
		case_summary.get("label", "case"),
		score_text,
		reason_text,
	]


func _compact_alpha_review_priority_reason(reason: String, max_parts: int) -> String:
	if reason.is_empty() or max_parts <= 0:
		return ""

	var parts: Array[String] = []
	for part_value in reason.split(";"):
		var part = str(part_value).strip_edges()
		if part.is_empty():
			continue

		parts.append(part)
		if parts.size() >= max_parts:
			break

	return "; ".join(parts)


func _alpha_first_issue_review_index() -> int:
	return _alpha_first_issue_review_index_for_tag("")


func _alpha_first_remaining_review_index() -> int:
	var order = _alpha_focus_review_order()
	for item_value in order:
		if typeof(item_value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = item_value
		var status = str(item.get("status", ""))
		if status == "manual_issue" or status == "manual_clear":
			continue

		var index = int(item.get("index", -1))
		if index >= 0 and index < last_autoplay_focus_queue.size():
			return index

	return -1


func _alpha_fix_lane_review_index() -> int:
	var report = _alpha_manual_review_report()
	var recommendation: Dictionary = report.get("fix_recommendation", {})
	var tag_id = str(recommendation.get("tag_id", ""))
	if tag_id.is_empty():
		return -1

	return _alpha_first_issue_review_index_for_tag(tag_id)


func _alpha_fix_lane_entry() -> Dictionary:
	var index = _alpha_fix_lane_review_index()
	if index < 0 or index >= last_autoplay_focus_queue.size():
		return {}

	var entry_value = last_autoplay_focus_queue[index]
	if typeof(entry_value) != TYPE_DICTIONARY:
		return {}

	var entry: Dictionary = entry_value
	return entry


func _alpha_recommendation_fix_review_index() -> int:
	var report = _alpha_manual_review_report()
	var case_summary = _alpha_recommendation_fix_case_summary(report)
	if case_summary.is_empty():
		return -1

	return clamp(int(case_summary.get("index", -1)), -1, max(-1, last_autoplay_focus_queue.size() - 1))


func _alpha_first_issue_review_index_for_tag(tag_id: String) -> int:
	var report = _alpha_manual_review_report()
	var issue_cases: Array = report.get("issue_cases", [])
	if issue_cases.is_empty():
		return -1

	var best_index = -1
	var best_priority = 999
	for issue_value in issue_cases:
		if typeof(issue_value) != TYPE_DICTIONARY:
			continue

		var issue: Dictionary = issue_value
		if not tag_id.is_empty() and str(issue.get("issue_tag_id", "untagged")) != tag_id:
			continue

		if tag_id.is_empty():
			return clamp(int(issue.get("index", -1)), -1, max(-1, last_autoplay_focus_queue.size() - 1))

		var priority = _alpha_fix_lane_issue_case_priority(issue)
		if priority < best_priority:
			best_priority = priority
			best_index = clamp(int(issue.get("index", -1)), -1, max(-1, last_autoplay_focus_queue.size() - 1))

	return best_index


func _alpha_issue_tag_summary_from_counts(issue_tag_counts: Dictionary) -> Array:
	var summary: Array = []
	for tag_id_value in ALPHA_ISSUE_TAG_IDS:
		var tag_id = str(tag_id_value)
		var count = int(issue_tag_counts.get(tag_id, 0))
		if count <= 0:
			continue

		summary.append({
			"tag_id": tag_id,
			"label": _alpha_issue_tag_label(tag_id) if tag_id == "untagged" else _alpha_issue_tag_display_label(tag_id),
			"count": count,
		})

	summary.sort_custom(_alpha_issue_tag_summary_item_is_before)
	return summary


func _alpha_issue_tag_summary_item_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	if int(left.get("count", 0)) != int(right.get("count", 0)):
		return int(left.get("count", 0)) > int(right.get("count", 0))

	return _alpha_issue_tag_order_index(str(left.get("tag_id", "untagged"))) < _alpha_issue_tag_order_index(str(right.get("tag_id", "untagged")))


func _alpha_recommendation_contrast_summary_from_counts(contrast_counts: Dictionary) -> Array:
	var summary: Array = []
	for contrast_id_value in ALPHA_RECOMMENDATION_CONTRAST_IDS:
		var contrast_id = str(contrast_id_value)
		var count = int(contrast_counts.get(contrast_id, 0))
		if count <= 0:
			continue

		summary.append({
			"contrast_id": contrast_id,
			"label": _alpha_recommendation_contrast_label(contrast_id),
			"count": count,
		})

	summary.sort_custom(_alpha_recommendation_contrast_summary_item_is_before)
	return summary


func _alpha_recommendation_contrast_summary_item_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	if int(left.get("count", 0)) != int(right.get("count", 0)):
		return int(left.get("count", 0)) > int(right.get("count", 0))

	return _alpha_recommendation_contrast_order_index(str(left.get("contrast_id", "not_checked"))) < _alpha_recommendation_contrast_order_index(str(right.get("contrast_id", "not_checked")))


func _alpha_issue_tag_order_index(tag_id: String) -> int:
	for index in range(ALPHA_ISSUE_TAG_IDS.size()):
		if str(ALPHA_ISSUE_TAG_IDS[index]) == tag_id:
			return index

	return ALPHA_ISSUE_TAG_IDS.size()


func _format_alpha_issue_tag_summary(summary: Array) -> String:
	if summary.is_empty():
		return ""

	var parts: Array[String] = []
	for item_value in summary:
		if typeof(item_value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = item_value
		parts.append("%s x%s" % [
			item.get("label", "No tag"),
			item.get("count", 0),
		])

	return ", ".join(parts)


func _format_alpha_recommendation_contrast_summary(summary: Array) -> String:
	if summary.is_empty():
		return ""

	var parts: Array[String] = []
	for item_value in summary:
		if typeof(item_value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = item_value
		parts.append("%s x%s" % [
			item.get("label", "Rec not checked"),
			item.get("count", 0),
		])

	return ", ".join(parts)


func _alpha_recommendation_contrast_needs_fix(contrast_id: String) -> bool:
	return ALPHA_RECOMMENDATION_CONTRAST_FIX_IDS.has(contrast_id)


func _alpha_recommendation_contrast_fix_from_summary(summary: Array) -> Dictionary:
	for item_value in summary:
		if typeof(item_value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = item_value
		var contrast_id = str(item.get("contrast_id", "not_checked"))
		if not _alpha_recommendation_contrast_needs_fix(contrast_id):
			continue

		return {
			"contrast_id": contrast_id,
			"label": str(item.get("label", _alpha_recommendation_contrast_label(contrast_id))),
			"count": int(item.get("count", 0)),
			"action": str(ALPHA_RECOMMENDATION_CONTRAST_FIX_RECOMMENDATIONS.get(contrast_id, "review recommendation wording")),
		}

	return {}


func _format_alpha_recommendation_contrast_fix(recommendation: Dictionary) -> String:
	if recommendation.is_empty():
		return ""

	return "%s x%s -> %s" % [
		recommendation.get("label", "Rec not checked"),
		recommendation.get("count", 0),
		recommendation.get("action", ""),
	]


func _format_alpha_recommendation_fix_case(report: Dictionary) -> String:
	var case_summary = _alpha_recommendation_fix_case_summary(report)
	if case_summary.is_empty():
		return ""

	return _format_alpha_review_case_list([case_summary], 1)


func _alpha_recommendation_fix_case_summary(report: Dictionary) -> Dictionary:
	var recommendation: Dictionary = report.get("recommendation_contrast_fix", {})
	var contrast_id = str(recommendation.get("contrast_id", ""))
	if contrast_id.is_empty():
		return {}

	var fix_cases: Array = report.get("recommendation_fix_cases", [])
	var best_case: Dictionary = {}
	var best_priority = 999
	for case_value in fix_cases:
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_summary: Dictionary = case_value
		if str(case_summary.get("recommendation_contrast_id", "not_checked")) != contrast_id:
			continue

		var priority = _alpha_recommendation_fix_case_priority(case_summary)
		if priority < best_priority:
			best_priority = priority
			best_case = case_summary

	return best_case


func _alpha_recommendation_fix_case_priority(case_summary: Dictionary) -> int:
	var status = str(case_summary.get("status", ""))
	var status_priority = 2
	if status == "manual_issue":
		status_priority = 0
	elif status == "manual_clear":
		status_priority = 1

	return status_priority * 10 + _alpha_fix_lane_issue_case_priority(case_summary)


func _alpha_fix_recommendation_from_issue_tags(summary: Array) -> Dictionary:
	if summary.is_empty():
		return {}

	var first_value = summary[0]
	if typeof(first_value) != TYPE_DICTIONARY:
		return {}

	var first: Dictionary = first_value
	var tag_id = str(first.get("tag_id", "untagged"))
	return {
		"tag_id": tag_id,
		"label": str(first.get("label", _alpha_issue_tag_label(tag_id))),
		"count": int(first.get("count", 0)),
		"action": str(ALPHA_ISSUE_TAG_FIX_RECOMMENDATIONS.get(tag_id, ALPHA_ISSUE_TAG_FIX_RECOMMENDATIONS["untagged"])),
	}


func _format_alpha_fix_recommendation(recommendation: Dictionary) -> String:
	if recommendation.is_empty():
		return ""

	return "%s x%s -> %s" % [
		recommendation.get("label", "No tag"),
		recommendation.get("count", 0),
		recommendation.get("action", ""),
	]


func _format_alpha_fix_lane_case(report: Dictionary) -> String:
	var issue = _alpha_fix_lane_case_summary(report)
	if issue.is_empty():
		return ""

	return _format_alpha_review_case_list([issue], 1)


func _alpha_fix_lane_case_summary(report: Dictionary) -> Dictionary:
	var recommendation: Dictionary = report.get("fix_recommendation", {})
	var tag_id = str(recommendation.get("tag_id", ""))
	if tag_id.is_empty():
		return {}

	var issue_cases: Array = report.get("issue_cases", [])
	var best_issue: Dictionary = {}
	var best_priority = 999
	for issue_value in issue_cases:
		if typeof(issue_value) != TYPE_DICTIONARY:
			continue

		var issue: Dictionary = issue_value
		if str(issue.get("issue_tag_id", "untagged")) != tag_id:
			continue

		var priority = _alpha_fix_lane_issue_case_priority(issue)
		if priority < best_priority:
			best_priority = priority
			best_issue = issue

	return best_issue


func _alpha_fix_lane_issue_case_priority(issue: Dictionary) -> int:
	var probe_status = _alpha_probe_status_for_case_summary(issue)
	match probe_status:
		"worse":
			return 0
		"recheck":
			return 1
		"probing":
			return 2
		"":
			return 3
		"better":
			return 4
		_:
			return 5


func _format_alpha_fix_lane_probe_status(report: Dictionary) -> String:
	var issue = _alpha_fix_lane_case_summary(report)
	if issue.is_empty():
		return ""

	var result = _alpha_probe_result_for_case_summary(issue)
	if result.is_empty():
		return "not run"

	return "%s - %s" % [
		result.get("badge", "PROBE"),
		_format_alpha_probe_result_brief(result),
	]


func _format_alpha_fix_lane_priority(report: Dictionary) -> String:
	var issue = _alpha_fix_lane_case_summary(report)
	if issue.is_empty():
		return ""

	var probe_status = _alpha_probe_status_for_case_summary(issue)
	match probe_status:
		"worse":
			return "PINNED - WORSE stays first until another probe or manual clear"
		"recheck":
			return "PINNED - RECHECK stays first until another probe or manual clear"
		"probing":
			return "PINNED - probe in progress"
		"better":
			return "CLEAR CANDIDATE - verify once, then mark clear"
		_:
			return "WATCH - run Probe fix lane before changing design"


func _alpha_probe_status_for_case_summary(issue: Dictionary) -> String:
	var result = _alpha_probe_result_for_case_summary(issue)
	if result.is_empty():
		return ""

	return str(result.get("status", ""))


func _alpha_probe_result_for_case_summary(issue: Dictionary) -> Dictionary:
	var index = int(issue.get("index", -1))
	if index < 0 or index >= last_autoplay_focus_queue.size():
		return {}

	var entry_value = last_autoplay_focus_queue[index]
	if typeof(entry_value) != TYPE_DICTIONARY:
		return {}

	var entry: Dictionary = entry_value
	return _alpha_focus_probe_result_for_entry(entry)


func _format_alpha_probe_result_brief(result: Dictionary) -> String:
	return "R%s HP %s vs original R%s HP %s (%s)" % [
		result.get("current_rounds", 0),
		result.get("current_hp", 0),
		result.get("original_rounds", 0),
		result.get("original_hp", 0),
		result.get("delta_text", "0"),
	]


func _format_alpha_manual_review_report_summary(report: Dictionary) -> String:
	return "Human review status: %s clear / %s issue / %s remaining" % [
		report.get("clear_count", 0),
		report.get("issue_count", 0),
		report.get("remaining_count", 0),
	]


func _format_alpha_review_gap_summary(report: Dictionary) -> String:
	var remaining_cases: Array = report.get("remaining_cases", [])
	if remaining_cases.is_empty():
		return "Review gaps: none"

	var class_counts: Dictionary = {}
	var class_order: Array = []
	var party_counts: Dictionary = {}
	var party_order: Array = []
	var front_counts: Dictionary = {}
	var front_order: Array = []
	for case_value in remaining_cases:
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_summary: Dictionary = case_value
		_alpha_review_count_label(class_counts, class_order, str(case_summary.get("class_label", "Class")))
		_alpha_review_count_label(party_counts, party_order, "%sP" % int(case_summary.get("player_count", 0)))
		_alpha_review_count_label(front_counts, front_order, _alpha_review_front_gap_label(case_summary))

	return "Review gaps: classes %s; parties %s; fronts %s" % [
		_format_alpha_review_count_summary(class_counts, class_order, 4),
		_format_alpha_review_count_summary(party_counts, party_order, 4),
		_format_alpha_review_count_summary(front_counts, front_order, 4),
	]


func _alpha_review_count_label(counts: Dictionary, order: Array, label: String) -> void:
	if label.is_empty():
		return
	if not counts.has(label):
		order.append(label)

	counts[label] = int(counts.get(label, 0)) + 1


func _alpha_review_front_gap_label(case_summary: Dictionary) -> String:
	var active_directions = _string_values_from_array(case_summary.get("active_directions", []))
	if not active_directions.is_empty():
		return "/".join(active_directions)

	var direction = str(case_summary.get("direction", ""))
	return "none" if direction.is_empty() else direction


func _format_alpha_review_count_summary(counts: Dictionary, order: Array, limit: int) -> String:
	if order.is_empty() or limit <= 0:
		return "none"

	var parts: Array[String] = []
	var visible_count = min(limit, order.size())
	for index in range(visible_count):
		var label = str(order[index])
		parts.append("%s x%s" % [label, int(counts.get(label, 0))])

	var hidden_count = 0
	for index in range(visible_count, order.size()):
		hidden_count += int(counts.get(str(order[index]), 0))
	if hidden_count > 0:
		parts.append("+%s cases" % hidden_count)

	return ", ".join(parts)


func _format_alpha_manual_review_log_summary() -> String:
	var report = _alpha_manual_review_report()
	var summary = "Human review summary: %s clear, %s issue, %s remaining." % [
		report.get("clear_count", 0),
		report.get("issue_count", 0),
		report.get("remaining_count", 0),
	]
	var tag_text = _format_alpha_issue_tag_summary(report.get("issue_tag_summary", []))
	var recommendation_contrast_text = _format_alpha_recommendation_contrast_summary(report.get("recommendation_contrast_summary", []))
	var fix_recommendation_text = _format_alpha_fix_recommendation(report.get("fix_recommendation", {}))
	var recommendation_wording_fix_text = _format_alpha_recommendation_contrast_fix(report.get("recommendation_contrast_fix", {}))
	var recommendation_fix_priority_text = _format_alpha_recommendation_fix_check_priority(report.get("recommendation_fix_check_priority", {}))
	var recommendation_fix_check_text = _format_alpha_recommendation_fix_check_summary(report.get("recommendation_fix_check_summary", []))
	if tag_text.is_empty() and recommendation_contrast_text.is_empty() and fix_recommendation_text.is_empty() and recommendation_wording_fix_text.is_empty() and recommendation_fix_priority_text.is_empty() and recommendation_fix_check_text.is_empty():
		return summary

	var parts: Array[String] = []
	parts.append(summary)
	if not tag_text.is_empty():
		parts.append("Tags: %s." % tag_text)
	if not recommendation_contrast_text.is_empty():
		parts.append("Recommendation contrast: %s." % recommendation_contrast_text)
	if not fix_recommendation_text.is_empty():
		parts.append("Fix: %s." % fix_recommendation_text)
	if not recommendation_wording_fix_text.is_empty():
		parts.append("Recommendation wording fix: %s." % recommendation_wording_fix_text)
	if not recommendation_fix_priority_text.is_empty():
		parts.append("Recommendation wording priority: %s." % recommendation_fix_priority_text)
	if not recommendation_fix_check_text.is_empty():
		parts.append("Recommendation wording checks: %s." % recommendation_fix_check_text)

	return " ".join(parts)


func _format_alpha_review_case_list(cases: Array, limit: int) -> String:
	if cases.is_empty() or limit <= 0:
		return ""

	var parts: Array[String] = []
	var count = min(limit, cases.size())
	for index in range(count):
		var case_value = cases[index]
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_summary: Dictionary = case_value
		var label = str(case_summary.get("label", "case"))
		var issue_tag_label = str(case_summary.get("issue_tag_label", ""))
		if not issue_tag_label.is_empty():
			label = "%s [%s]" % [label, issue_tag_label]
		parts.append(label)

	if cases.size() > limit:
		parts.append("+%s more" % (cases.size() - limit))

	return ", ".join(parts)


func _alpha_focus_case_label(entry: Dictionary) -> String:
	var class_id = str(entry.get("class_id", ""))
	var class_label = str(entry.get("class_label", _class_label(class_id)))
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	return "%s %sP%s" % [
		class_label,
		int(entry.get("player_count", 0)),
		direction_text,
	]


func _alpha_issue_tag_id_for_entry(entry: Dictionary) -> String:
	var manual_result = _alpha_focus_manual_review_result_for_entry(entry)
	if not manual_result.is_empty() and str(manual_result.get("status", "")) == "manual_issue":
		var issue_tag_id = str(manual_result.get("issue_tag_id", selected_alpha_issue_tag_id))
		if ALPHA_ISSUE_TAG_IDS.has(issue_tag_id):
			return issue_tag_id

	if ALPHA_ISSUE_TAG_IDS.has(selected_alpha_issue_tag_id):
		return selected_alpha_issue_tag_id

	return "untagged"


func _selected_alpha_issue_tag_id() -> String:
	if alpha_focus_issue_tag_option == null:
		return selected_alpha_issue_tag_id

	return _alpha_issue_tag_id_for_index(alpha_focus_issue_tag_option.selected)


func _alpha_recommendation_contrast_id_for_entry(entry: Dictionary) -> String:
	var manual_result = _alpha_focus_manual_review_result_for_entry(entry)
	if not manual_result.is_empty():
		var contrast_id = str(manual_result.get("recommendation_contrast_id", selected_alpha_recommendation_contrast_id))
		if ALPHA_RECOMMENDATION_CONTRAST_IDS.has(contrast_id):
			return contrast_id

	if ALPHA_RECOMMENDATION_CONTRAST_IDS.has(selected_alpha_recommendation_contrast_id):
		return selected_alpha_recommendation_contrast_id

	return "not_checked"


func _selected_alpha_recommendation_contrast_id() -> String:
	if alpha_focus_recommendation_contrast_option == null:
		return selected_alpha_recommendation_contrast_id

	return _alpha_recommendation_contrast_id_for_index(alpha_focus_recommendation_contrast_option.selected)


func _alpha_issue_tag_id_for_index(index: int) -> String:
	if index >= 0 and index < ALPHA_ISSUE_TAG_IDS.size():
		return str(ALPHA_ISSUE_TAG_IDS[index])

	return "untagged"


func _alpha_recommendation_contrast_id_for_index(index: int) -> String:
	if index >= 0 and index < ALPHA_RECOMMENDATION_CONTRAST_IDS.size():
		return str(ALPHA_RECOMMENDATION_CONTRAST_IDS[index])

	return "not_checked"


func _alpha_issue_tag_index(tag_id: String) -> int:
	for index in range(ALPHA_ISSUE_TAG_IDS.size()):
		if str(ALPHA_ISSUE_TAG_IDS[index]) == tag_id:
			return index

	return 0


func _alpha_recommendation_contrast_index(contrast_id: String) -> int:
	for index in range(ALPHA_RECOMMENDATION_CONTRAST_IDS.size()):
		if str(ALPHA_RECOMMENDATION_CONTRAST_IDS[index]) == contrast_id:
			return index

	return 0


func _alpha_issue_tag_label(tag_id: String) -> String:
	for index in range(ALPHA_ISSUE_TAG_IDS.size()):
		if str(ALPHA_ISSUE_TAG_IDS[index]) == tag_id:
			return str(ALPHA_ISSUE_TAG_LABELS[index])

	return str(ALPHA_ISSUE_TAG_LABELS[0])


func _alpha_recommendation_contrast_label(contrast_id: String) -> String:
	for index in range(ALPHA_RECOMMENDATION_CONTRAST_IDS.size()):
		if str(ALPHA_RECOMMENDATION_CONTRAST_IDS[index]) == contrast_id:
			return str(ALPHA_RECOMMENDATION_CONTRAST_LABELS[index])

	return str(ALPHA_RECOMMENDATION_CONTRAST_LABELS[0])


func _alpha_recommendation_contrast_order_index(contrast_id: String) -> int:
	for index in range(ALPHA_RECOMMENDATION_CONTRAST_IDS.size()):
		if str(ALPHA_RECOMMENDATION_CONTRAST_IDS[index]) == contrast_id:
			return index

	return ALPHA_RECOMMENDATION_CONTRAST_IDS.size()


func _alpha_recommendation_fix_check_id_for_index(index: int) -> String:
	if index >= 0 and index < ALPHA_RECOMMENDATION_FIX_CHECK_IDS.size():
		return str(ALPHA_RECOMMENDATION_FIX_CHECK_IDS[index])

	return ""


func _alpha_recommendation_fix_check_label(check_id: String) -> String:
	for index in range(ALPHA_RECOMMENDATION_FIX_CHECK_IDS.size()):
		if str(ALPHA_RECOMMENDATION_FIX_CHECK_IDS[index]) == check_id:
			return str(ALPHA_RECOMMENDATION_FIX_CHECK_LABELS[index])

	return check_id


func _alpha_recommendation_fix_check_node_name(check_id: String) -> String:
	match check_id:
		"auto_pick":
			return "AlphaRecommendationFixAutoPickCheck"
		"alternate_hidden":
			return "AlphaRecommendationFixAltHiddenCheck"
		"discussion_blocked":
			return "AlphaRecommendationFixTalkBlockedCheck"
		_:
			return "AlphaRecommendationFixCheck"


func _alpha_recommendation_fix_check_tooltip(check_id: String) -> String:
	match check_id:
		"auto_pick":
			return "Recommendation reads like the game already chose for the player."
		"alternate_hidden":
			return "The alternate choice does not show a clear upside."
		"discussion_blocked":
			return "The wording reduces table discussion instead of starting it."
		_:
			return "Mark a recommendation wording issue."


func _alpha_recommendation_fix_check_order_index(check_id: String) -> int:
	for index in range(ALPHA_RECOMMENDATION_FIX_CHECK_IDS.size()):
		if str(ALPHA_RECOMMENDATION_FIX_CHECK_IDS[index]) == check_id:
			return index

	return ALPHA_RECOMMENDATION_FIX_CHECK_IDS.size()


func _normalized_alpha_recommendation_fix_check_ids(value) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return result

	for item_value in value:
		var check_id = str(item_value)
		if not ALPHA_RECOMMENDATION_FIX_CHECK_IDS.has(check_id) or result.has(check_id):
			continue

		result.append(check_id)

	return result


func _alpha_recommendation_fix_check_ids_for_entry(entry: Dictionary) -> Array[String]:
	var manual_result = _alpha_focus_manual_review_result_for_entry(entry)
	if not manual_result.is_empty():
		return _normalized_alpha_recommendation_fix_check_ids(manual_result.get("recommendation_fix_check_ids", []))

	return selected_alpha_recommendation_fix_check_ids.duplicate()


func _selected_alpha_recommendation_fix_check_ids() -> Array[String]:
	return selected_alpha_recommendation_fix_check_ids.duplicate()


func _format_alpha_recommendation_fix_check_labels(check_ids: Array) -> String:
	var normalized = _normalized_alpha_recommendation_fix_check_ids(check_ids)
	if normalized.is_empty():
		return ""

	var labels = PackedStringArray()
	for check_id in normalized:
		labels.append(_alpha_recommendation_fix_check_label(check_id))

	return ", ".join(labels)


func _count_alpha_recommendation_fix_checks(check_counts: Dictionary, check_ids: Array) -> void:
	for check_id in _normalized_alpha_recommendation_fix_check_ids(check_ids):
		check_counts[check_id] = int(check_counts.get(check_id, 0)) + 1


func _alpha_recommendation_fix_check_summary_from_counts(check_counts: Dictionary) -> Array:
	var summary: Array = []
	for check_id_value in ALPHA_RECOMMENDATION_FIX_CHECK_IDS:
		var check_id = str(check_id_value)
		var count = int(check_counts.get(check_id, 0))
		if count <= 0:
			continue

		summary.append({
			"check_id": check_id,
			"label": _alpha_recommendation_fix_check_label(check_id),
			"count": count,
		})

	summary.sort_custom(_alpha_recommendation_fix_check_summary_item_is_before)
	return summary


func _alpha_recommendation_fix_check_summary_item_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	if int(left.get("count", 0)) != int(right.get("count", 0)):
		return int(left.get("count", 0)) > int(right.get("count", 0))

	return _alpha_recommendation_fix_check_order_index(str(left.get("check_id", ""))) < _alpha_recommendation_fix_check_order_index(str(right.get("check_id", "")))


func _format_alpha_recommendation_fix_check_summary(summary: Array) -> String:
	if summary.is_empty():
		return ""

	var parts: Array[String] = []
	for item_value in summary:
		if typeof(item_value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = item_value
		parts.append("%s x%s" % [
			item.get("label", "Recommendation issue"),
			item.get("count", 0),
		])

	return ", ".join(parts)


func _alpha_recommendation_fix_check_priority_from_summary(summary: Array) -> Dictionary:
	if summary.is_empty():
		return {}

	var first_value = summary[0]
	if typeof(first_value) != TYPE_DICTIONARY:
		return {}

	var first: Dictionary = first_value
	var check_id = str(first.get("check_id", ""))
	if check_id.is_empty():
		return {}

	return {
		"check_id": check_id,
		"label": str(first.get("label", _alpha_recommendation_fix_check_label(check_id))),
		"count": int(first.get("count", 0)),
		"action": str(ALPHA_RECOMMENDATION_FIX_CHECK_PRIORITY_ACTIONS.get(check_id, "rewrite recommendation wording")),
	}


func _format_alpha_recommendation_fix_check_priority(priority: Dictionary) -> String:
	if priority.is_empty():
		return ""

	return "%s x%s -> %s" % [
		priority.get("label", "Recommendation issue"),
		priority.get("count", 0),
		priority.get("action", ""),
	]


func _alpha_issue_tag_display_label(tag_id: String) -> String:
	if tag_id.is_empty() or tag_id == "untagged":
		return ""

	return _alpha_issue_tag_label(tag_id)


func _alpha_issue_tag_suffix(review: Dictionary) -> String:
	if str(review.get("status", "")) != "manual_issue":
		return ""

	var issue_tag_label = str(review.get("issue_tag_label", ""))
	if issue_tag_label.is_empty():
		issue_tag_label = _alpha_issue_tag_display_label(str(review.get("issue_tag_id", "")))
	if issue_tag_label.is_empty():
		return ""

	return " [%s]" % issue_tag_label


func _alpha_recommendation_contrast_suffix(review: Dictionary) -> String:
	if review.is_empty():
		return ""

	var contrast_id = str(review.get("recommendation_contrast_id", "not_checked"))
	var contrast_label = str(review.get("recommendation_contrast_label", ""))
	if contrast_label.is_empty():
		contrast_label = _alpha_recommendation_contrast_label(contrast_id)
	if contrast_label.is_empty():
		return ""

	return " | Rec: %s" % contrast_label


func _alpha_recommendation_fix_check_suffix(review: Dictionary) -> String:
	if review.is_empty():
		return ""

	var check_text = _format_alpha_recommendation_fix_check_labels(review.get("recommendation_fix_check_ids", []))
	if check_text.is_empty():
		return ""

	return " | Rec checks: %s" % check_text


func _alpha_focus_persistent_key(entry: Dictionary) -> String:
	var coverage_run_id = str(entry.get("coverage_run_id", ""))
	if not coverage_run_id.is_empty():
		return "coverage:%s" % coverage_run_id

	return "focus:%s|%s|%s|%s|%s" % [
		entry.get("class_id", entry.get("class_label", "")),
		entry.get("player_count", 0),
		entry.get("direction", ""),
		entry.get("primary_signal", ""),
		entry.get("next_probe", ""),
	]


func _alpha_manual_review_status_is_valid(status: String) -> bool:
	return ["manual_clear", "manual_issue"].has(status)


func _normalized_alpha_manual_review_result(review: Dictionary, persistent_key: String, entry_key: String) -> Dictionary:
	var status = str(review.get("status", ""))
	if not _alpha_manual_review_status_is_valid(status):
		return {}

	var summary = str(review.get("summary", ""))
	if summary.is_empty():
		summary = "needs follow-up before alpha" if status == "manual_issue" else "checked by human alpha"
	var issue_tag_id = str(review.get("issue_tag_id", "untagged"))
	if not ALPHA_ISSUE_TAG_IDS.has(issue_tag_id):
		issue_tag_id = "untagged"
	var issue_tag_label = _alpha_issue_tag_display_label(issue_tag_id)
	var recommendation_contrast_id = str(review.get("recommendation_contrast_id", "not_checked"))
	if not ALPHA_RECOMMENDATION_CONTRAST_IDS.has(recommendation_contrast_id):
		recommendation_contrast_id = "not_checked"
	var recommendation_contrast_label = _alpha_recommendation_contrast_label(recommendation_contrast_id)
	var recommendation_fix_check_ids = _normalized_alpha_recommendation_fix_check_ids(review.get("recommendation_fix_check_ids", []))
	if not _alpha_recommendation_contrast_needs_fix(recommendation_contrast_id):
		recommendation_fix_check_ids.clear()

	return {
		"status": status,
		"badge": str(review.get("badge", _alpha_probe_badge_for_status(status))),
		"summary": summary,
		"class_id": str(review.get("class_id", "")),
		"class_label": str(review.get("class_label", "")),
		"player_count": int(review.get("player_count", 0)),
		"direction": str(review.get("direction", "")),
		"coverage_run_id": str(review.get("coverage_run_id", "")),
		"issue_tag_id": issue_tag_id,
		"issue_tag_label": issue_tag_label,
		"recommendation_contrast_id": recommendation_contrast_id,
		"recommendation_contrast_label": recommendation_contrast_label,
		"recommendation_fix_check_ids": recommendation_fix_check_ids,
		"recommendation_fix_check_text": _format_alpha_recommendation_fix_check_labels(recommendation_fix_check_ids),
		"persistent_key": persistent_key,
		"entry_key": entry_key,
	}


func _load_alpha_manual_review_store() -> Dictionary:
	if not FileAccess.file_exists(ALPHA_MANUAL_REVIEW_SAVE_PATH):
		return {
			"ok": true,
			"reason": "missing",
			"reviews": {},
			"stored_count": 0,
		}

	var file = FileAccess.open(ALPHA_MANUAL_REVIEW_SAVE_PATH, FileAccess.READ)
	if file == null:
		return {
			"ok": false,
			"reason": "open_failed",
			"reviews": {},
			"error": error_string(FileAccess.get_open_error()),
		}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"reason": "invalid_json",
			"reviews": {},
		}

	var payload: Dictionary = parsed
	var source_reviews_value = payload.get("reviews", {})
	if typeof(source_reviews_value) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"reason": "invalid_reviews",
			"reviews": {},
		}

	var source_reviews: Dictionary = source_reviews_value
	var reviews: Dictionary = {}
	for persistent_key_value in source_reviews.keys():
		var review_value = source_reviews[persistent_key_value]
		if typeof(review_value) != TYPE_DICTIONARY:
			continue

		var persistent_key = str(persistent_key_value)
		var review: Dictionary = review_value
		var normalized = _normalized_alpha_manual_review_result(review, persistent_key, str(review.get("entry_key", "")))
		if normalized.is_empty():
			continue

		reviews[persistent_key] = normalized

	return {
		"ok": true,
		"reason": "loaded",
		"reviews": reviews,
		"stored_count": reviews.size(),
	}


func _load_alpha_manual_review_results_for_focus_queue() -> Dictionary:
	alpha_focus_manual_review_results.clear()
	var store_result = _load_alpha_manual_review_store()
	if not bool(store_result.get("ok", false)):
		return store_result

	var stored_reviews: Dictionary = store_result.get("reviews", {})
	var loaded_count = 0
	for entry_value in last_autoplay_focus_queue:
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		var persistent_key = _alpha_focus_persistent_key(entry)
		var entry_key = _alpha_focus_entry_key(entry)
		if persistent_key.is_empty() or entry_key.is_empty() or not stored_reviews.has(persistent_key):
			continue

		var review_value = stored_reviews[persistent_key]
		if typeof(review_value) != TYPE_DICTIONARY:
			continue

		var review: Dictionary = review_value
		var normalized = _normalized_alpha_manual_review_result(review, persistent_key, entry_key)
		if normalized.is_empty():
			continue

		alpha_focus_manual_review_results[entry_key] = normalized
		loaded_count += 1

	return {
		"ok": true,
		"reason": "loaded",
		"loaded_count": loaded_count,
		"stored_count": int(store_result.get("stored_count", 0)),
	}


func _save_alpha_manual_review_results() -> Dictionary:
	var store_result = _load_alpha_manual_review_store()
	var stored_reviews: Dictionary = {}
	if bool(store_result.get("ok", false)):
		stored_reviews = store_result.get("reviews", {}).duplicate(true)

	for entry_key_value in alpha_focus_manual_review_results.keys():
		var review_value = alpha_focus_manual_review_results[entry_key_value]
		if typeof(review_value) != TYPE_DICTIONARY:
			continue

		var entry_key = str(entry_key_value)
		var review: Dictionary = review_value
		var persistent_key = str(review.get("persistent_key", ""))
		if persistent_key.is_empty():
			continue

		var normalized = _normalized_alpha_manual_review_result(review, persistent_key, entry_key)
		if normalized.is_empty():
			continue

		stored_reviews[persistent_key] = normalized

	var payload = {
		"version": ALPHA_MANUAL_REVIEW_SAVE_VERSION,
		"reviews": stored_reviews,
		"review_count": stored_reviews.size(),
	}
	var json_text = JSON.stringify(payload, "\t")
	var file = FileAccess.open(ALPHA_MANUAL_REVIEW_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"reason": "open_failed",
			"path": ALPHA_MANUAL_REVIEW_SAVE_PATH,
			"error": error_string(FileAccess.get_open_error()),
		}

	file.store_string(json_text)
	return {
		"ok": true,
		"reason": "saved",
		"path": ALPHA_MANUAL_REVIEW_SAVE_PATH,
		"review_count": stored_reviews.size(),
		"characters": json_text.length(),
	}


func _debug_clear_alpha_manual_review_save() -> Dictionary:
	alpha_focus_manual_review_results.clear()
	if not FileAccess.file_exists(ALPHA_MANUAL_REVIEW_SAVE_PATH):
		_refresh_screen()
		return {
			"ok": true,
			"reason": "missing",
			"removed": false,
		}

	var dir = DirAccess.open("user://")
	if dir == null:
		return {
			"ok": false,
			"reason": "open_dir_failed",
			"removed": false,
		}

	var remove_error = dir.remove(ALPHA_MANUAL_REVIEW_SAVE_FILENAME)
	if remove_error != OK:
		return {
			"ok": false,
			"reason": "remove_failed",
			"removed": false,
			"error": error_string(remove_error),
		}

	_refresh_screen()
	return {
		"ok": true,
		"reason": "removed",
		"removed": true,
	}


func _selected_alpha_focus_entry() -> Dictionary:
	if last_autoplay_focus_queue.is_empty():
		return {}

	selected_autoplay_focus_index = clamp(selected_autoplay_focus_index, 0, last_autoplay_focus_queue.size() - 1)
	var entry_value = last_autoplay_focus_queue[selected_autoplay_focus_index]
	if typeof(entry_value) != TYPE_DICTIONARY:
		return {}

	var entry: Dictionary = entry_value
	return entry


func _selected_alpha_focus_direction() -> String:
	var entry: Dictionary = _selected_alpha_focus_entry()
	return str(entry.get("direction", ""))


func _alpha_focus_setup_marker() -> Dictionary:
	if run_started or not simulation.is_loaded():
		return {}

	var entry: Dictionary = _selected_alpha_focus_entry()
	if not _alpha_focus_entry_has_setup(entry):
		return {}

	var focus_class_id = str(entry.get("class_id", ""))
	if simulation.get_class_data(focus_class_id).is_empty():
		return {}

	var focus_player_count = clamp(int(entry.get("player_count", player_count)), 1, 4)
	var focus_direction = str(entry.get("direction", ""))
	for structure_type_value in _setup_plan_structure_sequence_for_class(focus_class_id):
		var structure_type = str(structure_type_value)
		var report = simulation.get_front_recommendation_tiles(focus_player_count, structure_type, focus_class_id)
		if not bool(report.get("ok", false)):
			continue

		var recommendation_tiles: Dictionary = report.get("tiles", {})
		var tile = _best_alpha_focus_setup_tile(
			recommendation_tiles,
			structure_type,
			focus_player_count,
			focus_class_id,
			focus_direction
		)
		if not _is_valid_tile(tile):
			continue

		var recommendation: Dictionary = recommendation_tiles.get(_tile_key(tile), {})
		var summary = str(recommendation.get("summary", report.get("summary", "first setup candidate")))
		var why = str(recommendation.get("why", "Replay starts by placing %s here." % structure_type.capitalize()))
		return {
			"tile": tile,
			"label": "F",
			"structure_type": structure_type,
			"class_id": focus_class_id,
			"class_label": _class_label(focus_class_id),
			"player_count": focus_player_count,
			"direction": focus_direction,
			"summary": "%s setup: %s at %s" % [
				_alpha_focus_case_label(entry),
				structure_type.capitalize(),
				_tile_text(tile),
			],
			"why": why,
			"recommendation_summary": summary,
		}

	return {}


func _alpha_focus_entry_key(entry: Dictionary) -> String:
	if entry.is_empty():
		return ""

	return "%s|%s|%s|%s|%s" % [
		entry.get("rank", 0),
		entry.get("class_id", entry.get("class_label", "")),
		entry.get("player_count", 0),
		entry.get("direction", ""),
		entry.get("primary_signal", ""),
	]


func _alpha_focus_entry_has_setup(entry: Dictionary) -> bool:
	return int(entry.get("player_count", 0)) > 0 and not str(entry.get("class_id", "")).is_empty()


func _alpha_focus_probe_result_for_entry(entry: Dictionary) -> Dictionary:
	var key = _alpha_focus_entry_key(entry)
	if key.is_empty() or not alpha_focus_probe_results.has(key):
		return {}

	var result_value = alpha_focus_probe_results[key]
	if typeof(result_value) != TYPE_DICTIONARY:
		return {}

	var result: Dictionary = result_value
	return result


func _alpha_focus_manual_review_result_for_entry(entry: Dictionary) -> Dictionary:
	var key = _alpha_focus_entry_key(entry)
	if key.is_empty() or not alpha_focus_manual_review_results.has(key):
		return {}

	var result_value = alpha_focus_manual_review_results[key]
	if typeof(result_value) != TYPE_DICTIONARY:
		return {}

	var result: Dictionary = result_value
	return result


func _alpha_focus_is_clear_candidate(entry: Dictionary) -> bool:
	var manual_result = _alpha_focus_manual_review_result_for_entry(entry)
	if manual_result.is_empty() or str(manual_result.get("status", "")) != "manual_issue":
		return false

	return str(_alpha_focus_probe_result_for_entry(entry).get("status", "")) == "better"


func _alpha_focus_review_order() -> Array:
	var order = []
	for index in range(last_autoplay_focus_queue.size()):
		var entry_value = last_autoplay_focus_queue[index]
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		order.append({
			"index": index,
			"rank": int(entry.get("rank", index + 1)),
			"priority": _alpha_focus_review_priority(entry),
			"review_priority_score": int(entry.get("review_priority_score", 0)),
			"status": _alpha_focus_review_status(entry),
		})

	order.sort_custom(_alpha_focus_review_item_is_before)
	return order


func _alpha_focus_review_item_is_before(left_value, right_value) -> bool:
	if typeof(left_value) != TYPE_DICTIONARY:
		return false
	if typeof(right_value) != TYPE_DICTIONARY:
		return true

	var left: Dictionary = left_value
	var right: Dictionary = right_value
	if int(left.get("priority", 999)) != int(right.get("priority", 999)):
		return int(left.get("priority", 999)) < int(right.get("priority", 999))
	if int(left.get("review_priority_score", 0)) != int(right.get("review_priority_score", 0)):
		return int(left.get("review_priority_score", 0)) > int(right.get("review_priority_score", 0))
	if int(left.get("rank", 999)) != int(right.get("rank", 999)):
		return int(left.get("rank", 999)) < int(right.get("rank", 999))
	return int(left.get("index", 999)) < int(right.get("index", 999))


func _alpha_focus_review_position_for_index(target_index: int, order: Array) -> int:
	for position in range(order.size()):
		var item_value = order[position]
		if typeof(item_value) != TYPE_DICTIONARY:
			continue

		var item: Dictionary = item_value
		if int(item.get("index", -1)) == target_index:
			return position

	return -1


func _alpha_focus_review_priority(entry: Dictionary) -> int:
	var manual_result = _alpha_focus_manual_review_result_for_entry(entry)
	if not manual_result.is_empty() and str(manual_result.get("status", "")) == "manual_issue":
		var probe_status = str(_alpha_focus_probe_result_for_entry(entry).get("status", ""))
		match probe_status:
			"worse":
				return 0
			"recheck":
				return 1
			"probing":
				return 2
			_:
				return 3

	var status = _alpha_focus_review_status(entry)
	match status:
		"worse":
			return 4
		"recheck":
			return 5
		"untested":
			return 6
		"probing":
			return 7
		"manual_clear":
			return 8
		"better":
			return 9
		_:
			return 10


func _alpha_focus_review_status(entry: Dictionary) -> String:
	var manual_result = _alpha_focus_manual_review_result_for_entry(entry)
	if not manual_result.is_empty() and str(manual_result.get("status", "")) == "manual_issue":
		return "manual_issue"

	if not manual_result.is_empty() and str(manual_result.get("status", "")) == "manual_clear":
		return "manual_clear"

	var result = _alpha_focus_probe_result_for_entry(entry)
	if not result.is_empty():
		return str(result.get("status", "untested"))

	return "untested"


func _record_alpha_probe_result(entry: Dictionary, current_rounds: int, current_hp: int) -> Dictionary:
	var key = _alpha_focus_entry_key(entry)
	if key.is_empty():
		return {}

	var result = _build_alpha_probe_result(entry, current_rounds, current_hp)
	alpha_focus_probe_results[key] = result
	return result


func _build_alpha_probe_result(entry: Dictionary, current_rounds: int, current_hp: int) -> Dictionary:
	var original_rounds = max(0, int(entry.get("completed_rounds", 0)))
	var original_hp = int(entry.get("base_hp", 0))
	var delta = current_hp - original_hp
	var status = "probing"
	if current_hp <= 0 and (original_rounds <= 0 or current_rounds < original_rounds):
		status = "worse"
	elif original_rounds <= 0 or current_rounds >= original_rounds:
		status = _probe_result_status(delta)

	var signal_report = _alpha_probe_signal_report(entry)
	return {
		"status": status,
		"badge": _alpha_probe_badge_for_status(status),
		"delta": delta,
		"delta_text": _signed_int_text(delta),
		"current_rounds": current_rounds,
		"current_hp": current_hp,
		"original_rounds": original_rounds,
		"original_hp": original_hp,
		"summary": _format_alpha_probe_result_summary(entry, current_rounds, current_hp, status),
		"signal_report": signal_report,
		"required_signal_ids": signal_report.get("required_signals", []),
		"observed_signal_ids": signal_report.get("observed_signals", []),
		"missing_signal_ids": signal_report.get("missing_signals", []),
		"signal_summary": signal_report.get("summary", ""),
	}


func _alpha_probe_signal_report(entry: Dictionary) -> Dictionary:
	var class_id = str(entry.get("class_id", selected_class_id))
	var required_signals = _alpha_probe_required_signal_ids(class_id)
	var observed_signals: Array[String] = []
	var missing_signals: Array[String] = []
	var stats: Dictionary = {}
	if simulation.is_loaded():
		stats = simulation.get_run_stats()

	for signal_id in required_signals:
		if _alpha_probe_signal_observed(str(signal_id), class_id, stats):
			observed_signals.append(str(signal_id))
		else:
			missing_signals.append(str(signal_id))

	return {
		"ok": true,
		"class_id": class_id,
		"passed": missing_signals.is_empty(),
		"required_signals": required_signals,
		"observed_signals": observed_signals,
		"missing_signals": missing_signals,
		"observed_count": observed_signals.size(),
		"required_count": required_signals.size(),
		"summary": _format_alpha_probe_signal_summary(required_signals, observed_signals, missing_signals),
	}


func _alpha_probe_required_signal_ids(class_id: String) -> Array[String]:
	match class_id:
		"guardian":
			return ["taunt_applied", "guardian_hit_received", "thorns_or_guard_log"]
		"architect":
			return ["path_changed", "full_block_rejected", "barricade_break_or_debris_log"]
		"elementalist":
			return ["splash_damage_applied", "control_effect_applied", "invalid_target_rejected"]
		"tinkerer":
			return ["aura_applied", "repair_or_boost_applied", "invalid_target_rejected"]
		_:
			return []


func _alpha_probe_signal_observed(signal_id: String, class_id: String, stats: Dictionary) -> bool:
	var effects: Dictionary = simulation.get_class_effects(class_id) if simulation.is_loaded() else {}
	match signal_id:
		"taunt_applied":
			return (
				int(effects.get("tauntPriority", 0)) > 0
				and _alpha_probe_stat_bucket_count(stats, "towers_placed_by_class", class_id) > 0
			)
		"guardian_hit_received":
			return (
				int(stats.get("class_taunt_hits", 0)) > 0
				or (class_id == "guardian" and int(stats.get("structure_hits", 0)) > 0)
			)
		"thorns_or_guard_log":
			return int(stats.get("class_thorns_damage", 0)) > 0 or int(stats.get("class_taunt_hits", 0)) > 0
		"path_changed":
			return (
				_alpha_probe_stat_bucket_count(stats, "barricades_placed_by_class", class_id) > 0
				or int(stats.get("break_path_steps", 0)) > 0
			)
		"full_block_rejected":
			return _alpha_probe_can_observe_full_block_rejection(class_id)
		"barricade_break_or_debris_log":
			return (
				int(stats.get("class_explosion_damage", 0)) > 0
				or int(stats.get("planned_collapses", 0)) > 0
				or (class_id == "architect" and int(stats.get("structures_destroyed", 0)) > 0)
			)
		"splash_damage_applied":
			return int(stats.get("class_splash_damage", 0)) > 0
		"control_effect_applied":
			return int(stats.get("boss_part_slow_waits", 0)) > 0
		"invalid_target_rejected":
			return _alpha_probe_can_observe_invalid_target_rejection(class_id)
		"aura_applied":
			return (
				int(stats.get("class_aura_damage", 0)) > 0
				or (
					int(effects.get("auraRange", 0)) > 0
					and _alpha_probe_stat_bucket_count(stats, "towers_placed_by_class", class_id) > 0
				)
			)
		"repair_or_boost_applied":
			return (
				int(stats.get("class_repairs", 0)) > 0
				or int(stats.get("class_aura_damage", 0)) > 0
				or int(stats.get("card_repairs", 0)) > 0
			)
		_:
			return false


func _alpha_probe_can_observe_full_block_rejection(class_id: String) -> bool:
	if not simulation.is_loaded():
		return false

	var map_size = simulation.get_map_size()
	for y in range(map_size.y):
		for x in range(map_size.x):
			var result = simulation.can_place_structure(Vector2i(x, y), "barricade", player_count, class_id)
			if str(result.get("reason", "")).begins_with("would_fully_block"):
				return true

	return false


func _alpha_probe_can_observe_invalid_target_rejection(class_id: String) -> bool:
	if not simulation.is_loaded():
		return false

	match class_id:
		"elementalist":
			return _alpha_probe_has_empty_enemy_target_tile()
		"tinkerer":
			return _alpha_probe_has_empty_repair_target_tile()
		_:
			return false


func _alpha_probe_has_empty_enemy_target_tile() -> bool:
	var map_size = simulation.get_map_size()
	for y in range(map_size.y):
		for x in range(map_size.x):
			var tile = Vector2i(x, y)
			if not _is_valid_tile(tile):
				continue

			var result = simulation.debug_card_target_condition("m0_arc_spark", tile, player_count, "elementalist")
			if str(result.get("reason", "")) == "no_enemy_at_tile":
				return true

	return false


func _alpha_probe_has_empty_repair_target_tile() -> bool:
	var map_size = simulation.get_map_size()
	for y in range(map_size.y):
		for x in range(map_size.x):
			var tile = Vector2i(x, y)
			if not _is_valid_tile(tile):
				continue

			var result = simulation.debug_card_target_condition("m0_field_patch", tile, player_count, "tinkerer")
			if ["no_structure", "structure_not_damaged"].has(str(result.get("reason", ""))):
				return true

	return false


func _alpha_probe_stat_bucket_count(stats: Dictionary, stat_key: String, bucket_key: String) -> int:
	var bucket_value = stats.get(stat_key, {})
	if typeof(bucket_value) != TYPE_DICTIONARY:
		return 0

	var bucket: Dictionary = bucket_value
	return int(bucket.get(bucket_key, 0))


func _format_alpha_probe_signal_summary(
	required_signals: Array[String],
	observed_signals: Array[String],
	missing_signals: Array[String]
) -> String:
	if required_signals.is_empty():
		return "Coverage Signals: none configured."

	var observed_text = "none" if observed_signals.is_empty() else ", ".join(observed_signals)
	var missing_text = "none" if missing_signals.is_empty() else ", ".join(missing_signals)
	return "Coverage Signals: %s/%s observed [%s]; missing [%s]." % [
		observed_signals.size(),
		required_signals.size(),
		observed_text,
		missing_text,
	]


func _format_alpha_probe_status() -> String:
	if active_alpha_probe_entry.is_empty():
		return "Probe compare: start a probe to compare this focus result with the replay."

	var class_label = str(active_alpha_probe_entry.get("class_label", _class_label(str(active_alpha_probe_entry.get("class_id", "")))))
	var player_count_text = int(active_alpha_probe_entry.get("player_count", 0))
	var direction = str(active_alpha_probe_entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	var original_rounds = max(0, int(active_alpha_probe_entry.get("completed_rounds", 0)))
	var original_hp = int(active_alpha_probe_entry.get("base_hp", 0))

	if not simulation.is_loaded() or not run_started:
		return _with_alpha_probe_boss_response("Probe compare: inactive. Original %s %sP%s reached R%s with HP %s." % [
			class_label,
			player_count_text,
			direction_text,
			original_rounds,
			original_hp,
		])

	var current_rounds = simulation.get_completed_rounds()
	var current_hp = simulation.get_base_hp()
	if original_rounds > 0 and current_rounds < original_rounds:
		return _with_alpha_probe_boss_response("Probe compare: %s %sP%s now R%s/%s HP %s; original HP %s at R%s." % [
			class_label,
			player_count_text,
			direction_text,
			current_rounds,
			original_rounds,
			current_hp,
			original_hp,
			original_rounds,
		])

	return _with_alpha_probe_boss_response(_format_alpha_probe_completed_status(active_alpha_probe_entry, current_rounds, current_hp))


func _with_alpha_probe_boss_response(status_text: String) -> String:
	var response_line = _alpha_focus_probe_boss_response_status_line()
	if response_line.is_empty():
		return status_text

	return "%s\n%s" % [status_text, response_line]


func _alpha_focus_probe_boss_response_status_line() -> String:
	if active_alpha_probe_entry.is_empty():
		return ""

	if last_boss_warning_response_line.is_empty():
		var pending_warning = _alpha_focus_pending_boss_warning_text(false)
		if not pending_warning.is_empty():
			return "Probe boss response: %s." % pending_warning
		return "Probe boss response: none recorded yet."

	return "Probe boss response: %s" % _short_boss_warning_response_text()


func _format_alpha_probe_result_summary(entry: Dictionary, current_rounds: int, current_hp: int, status: String) -> String:
	if status == "probing":
		return _format_alpha_probe_progress_status(entry, current_rounds, current_hp)

	return _format_alpha_probe_completed_status(entry, current_rounds, current_hp)


func _format_alpha_probe_progress_status(entry: Dictionary, current_rounds: int, current_hp: int) -> String:
	var class_label = str(entry.get("class_label", _class_label(str(entry.get("class_id", "")))))
	var player_count_text = int(entry.get("player_count", 0))
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	var original_rounds = max(0, int(entry.get("completed_rounds", 0)))
	var original_hp = int(entry.get("base_hp", 0))
	return "Probe compare: %s %sP%s now R%s/%s HP %s; original HP %s at R%s." % [
		class_label,
		player_count_text,
		direction_text,
		current_rounds,
		original_rounds,
		current_hp,
		original_hp,
		original_rounds,
	]


func _format_alpha_probe_completed_status(entry: Dictionary, current_rounds: int, current_hp: int) -> String:
	var class_label = str(entry.get("class_label", _class_label(str(entry.get("class_id", "")))))
	var player_count_text = int(entry.get("player_count", 0))
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	var original_rounds = max(0, int(entry.get("completed_rounds", 0)))
	var original_hp = int(entry.get("base_hp", 0))
	var delta = current_hp - original_hp
	return "Probe compare: %s %sP%s current R%s HP %s vs original R%s HP %s (%s, %s)." % [
		class_label,
		player_count_text,
		direction_text,
		current_rounds,
		current_hp,
		original_rounds,
		original_hp,
		_signed_int_text(delta),
		_probe_delta_label(delta),
	]


func _signed_int_text(value: int) -> String:
	return "+%s" % value if value > 0 else str(value)


func _probe_delta_label(delta: int) -> String:
	if delta > 0:
		return "better"
	if delta < 0:
		return "worse"
	return "same"


func _probe_result_status(delta: int) -> String:
	if delta > 0:
		return "better"
	if delta < 0:
		return "worse"
	return "recheck"


func _alpha_probe_badge_for_status(status: String) -> String:
	match status:
		"manual_issue":
			return "ISSUE"
		"manual_clear":
			return "CLEAR"
		"untested":
			return "UNTESTED"
		"better":
			return "BETTER"
		"worse":
			return "WORSE"
		"recheck":
			return "RECHECK"
		"probing":
			return "PROBING"
		_:
			return "PROBE"


func _alpha_focus_probe_badge_text(entry: Dictionary) -> String:
	var status = _alpha_focus_review_status(entry)
	if status == "untested":
		return ""

	return " [%s]" % _alpha_probe_badge_for_status(status)


func _alpha_focus_probe_result_line(entry: Dictionary) -> String:
	var result = _alpha_focus_probe_result_for_entry(entry)
	if result.is_empty():
		return ""

	var result_line = "Probe Result: %s - %s" % [
		result.get("badge", "PROBE"),
		result.get("summary", ""),
	]
	var signal_summary = str(result.get("signal_summary", ""))
	if signal_summary.is_empty():
		return result_line

	return "%s\n%s" % [result_line, signal_summary]


func _alpha_focus_manual_review_line(entry: Dictionary) -> String:
	var result = _alpha_focus_manual_review_result_for_entry(entry)
	if result.is_empty():
		return "Human Review: not recorded"

	return "Human Review: %s%s - %s%s%s" % [
		result.get("badge", "REVIEW"),
		_alpha_issue_tag_suffix(result),
		result.get("summary", ""),
		_alpha_recommendation_contrast_suffix(result),
		_alpha_recommendation_fix_check_suffix(result),
	]


func _alpha_focus_recommendation_fix_lines(entry: Dictionary) -> PackedStringArray:
	var lines = PackedStringArray()
	var result = _alpha_focus_manual_review_result_for_entry(entry)
	if result.is_empty():
		return lines

	var contrast_id = str(result.get("recommendation_contrast_id", "not_checked"))
	if not _alpha_recommendation_contrast_needs_fix(contrast_id):
		return lines

	var contrast_label = _alpha_recommendation_contrast_label(contrast_id)
	var action = str(ALPHA_RECOMMENDATION_CONTRAST_FIX_RECOMMENDATIONS.get(contrast_id, "review recommendation wording"))
	lines.append("Recommendation Fix Detail: %s -> %s" % [
		contrast_label,
		action,
	])
	var check_text = _format_alpha_recommendation_fix_check_labels(result.get("recommendation_fix_check_ids", []))
	if not check_text.is_empty():
		lines.append("Recommendation Fix Checks: %s" % check_text)
	var preset_text = _alpha_recommendation_rewrite_preset_text(entry, result)
	if not preset_text.is_empty():
		lines.append("Recommendation Rewrite Preset: %s" % preset_text)

	var source_parts = PackedStringArray()
	var choice_type = str(entry.get("recommendation_choice_type", ""))
	var label = str(entry.get("recommendation_label", ""))
	if not label.is_empty():
		source_parts.append("%s choice: %s" % [
			choice_type if not choice_type.is_empty() else "reward",
			label,
		])
	var reason = str(entry.get("recommendation_reason", ""))
	if not reason.is_empty():
		source_parts.append("Reason: %s" % reason)
	var detail = _compact_choice_trace_detail(str(entry.get("recommendation_detail", "")))
	if not detail.is_empty():
		source_parts.append("Why now: %s" % detail)
	if not source_parts.is_empty():
		lines.append("Recommendation Source: %s" % " | ".join(source_parts))

	var contrast_probe = str(entry.get("recommendation_contrast_probe", ""))
	if not contrast_probe.is_empty():
		lines.append("Recommendation Rewrite Check: %s" % contrast_probe)

	return lines


func _alpha_recommendation_rewrite_preset_text(entry: Dictionary, review: Dictionary) -> String:
	var check_id = _alpha_primary_recommendation_fix_check_id(review.get("recommendation_fix_check_ids", []))
	return _alpha_recommendation_rewrite_preset_from_parts(
		check_id,
		_alpha_recommendation_preset_label(entry),
		_alpha_recommendation_preset_reason(entry),
		_alpha_recommendation_preset_alternate(entry)
	)


func _alpha_reward_recommendation_rewrite_preset_text(recommendation: Dictionary) -> String:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return ""

	return _alpha_choice_recommendation_rewrite_preset_text(
		str(recommendation.get("choice_type", "")),
		str(recommendation.get("label", "")),
		str(recommendation.get("reason_text", "")),
		str(recommendation.get("detail_text", "")),
		_alpha_recommendation_preset_alternate_from_choice_type(str(recommendation.get("choice_type", "")))
	)


func _alpha_artifact_recommendation_rewrite_preset_text(recommendation: Dictionary) -> String:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return ""

	return _alpha_choice_recommendation_rewrite_preset_text(
		"artifact",
		str(recommendation.get("label", recommendation.get("artifact_id", ""))),
		str(recommendation.get("reason_text", "")),
		str(recommendation.get("detail_text", "")),
		"the other artifact or skipping for now"
	)


func _alpha_shop_recommendation_rewrite_preset_text(recommendation: Dictionary) -> String:
	if recommendation.is_empty() or not bool(recommendation.get("ok", false)):
		return ""

	var alternate = "saving gold for a later trim"
	if str(recommendation.get("choice_type", "card")) == "service":
		alternate = "removing a card or skipping for now"

	return _alpha_choice_recommendation_rewrite_preset_text(
		"shop",
		str(recommendation.get("label", recommendation.get("card_id", recommendation.get("service_id", "")))),
		str(recommendation.get("reason_text", "")),
		str(recommendation.get("detail_text", "")),
		alternate
	)


func _alpha_choice_recommendation_rewrite_preset_text(choice_type: String, label: String, reason: String, detail: String, alternate: String) -> String:
	var check_id = _alpha_active_recommendation_fix_check_id()
	if check_id.is_empty():
		return ""

	return _alpha_recommendation_rewrite_preset_from_parts(
		check_id,
		_alpha_recommendation_preset_label_from_values(choice_type, label),
		_alpha_recommendation_preset_reason_from_values(reason, detail),
		alternate
	)


func _alpha_active_recommendation_fix_check_id() -> String:
	var report = _alpha_manual_review_report()
	var priority: Dictionary = report.get("recommendation_fix_check_priority", {})
	return str(priority.get("check_id", ""))


func _alpha_recommendation_rewrite_preset_from_parts(check_id: String, label: String, reason: String, alternate: String) -> String:
	match check_id:
		"auto_pick":
			return "Consider %s because %s. %s is still valid if the table wants flexibility." % [
				label,
				reason,
				alternate,
			]
		"alternate_hidden":
			return "Compare %s for %s with %s for flexibility before choosing." % [
				label,
				reason,
				alternate,
			]
		"discussion_blocked":
			return "Ask the table: take %s for %s now, or choose %s for later flexibility?" % [
				label,
				reason,
				alternate,
			]
		_:
			return "Name one reason for %s, name one safe alternate, then ask the table to choose." % label


func _alpha_primary_recommendation_fix_check_id(check_ids: Array) -> String:
	var normalized = _normalized_alpha_recommendation_fix_check_ids(check_ids)
	if normalized.is_empty():
		return ""

	return str(normalized[0])


func _alpha_recommendation_preset_label(entry: Dictionary) -> String:
	var choice_type = str(entry.get("recommendation_choice_type", ""))
	var label = str(entry.get("recommendation_label", "")).strip_edges()
	return _alpha_recommendation_preset_label_from_values(choice_type, label)


func _alpha_recommendation_preset_label_from_values(choice_type: String, label: String) -> String:
	var clean_label = label.strip_edges()
	if clean_label.is_empty():
		return "this option"
	if choice_type == "gold":
		return "taking %s" % clean_label

	return clean_label


func _alpha_recommendation_preset_reason(entry: Dictionary) -> String:
	var reason = str(entry.get("recommendation_reason", "")).strip_edges()
	var detail = _compact_choice_trace_detail(str(entry.get("recommendation_detail", ""))).strip_edges()
	return _alpha_recommendation_preset_reason_from_values(reason, detail)


func _alpha_recommendation_preset_reason_from_values(reason: String, detail: String) -> String:
	var clean_reason = reason.strip_edges()
	if not clean_reason.is_empty():
		return clean_reason

	var clean_detail = _compact_choice_trace_detail(detail).strip_edges()
	if not clean_detail.is_empty():
		return clean_detail

	return "it answers the current board"


func _alpha_recommendation_preset_alternate(entry: Dictionary) -> String:
	return _alpha_recommendation_preset_alternate_from_choice_type(str(entry.get("recommendation_choice_type", "")))


func _alpha_recommendation_preset_alternate_from_choice_type(choice_type: String) -> String:
	match choice_type:
		"gold":
			return "a clear role card"
		"card":
			return "gold or another safe card"
		_:
			return "another safe option"


func _format_alpha_focus_manual_review_status(entry: Dictionary) -> String:
	if entry.is_empty():
		return "Human review: -"

	var result = _alpha_focus_manual_review_result_for_entry(entry)
	if result.is_empty():
		return "Human review: not recorded"

	var clear_candidate_text = " | Clear candidate: probe improved; confirm once" if _alpha_focus_is_clear_candidate(entry) else ""
	return "Human review: %s%s - %s%s%s%s" % [
		result.get("badge", "REVIEW"),
		_alpha_issue_tag_suffix(result),
		result.get("summary", ""),
		_alpha_recommendation_contrast_suffix(result),
		_alpha_recommendation_fix_check_suffix(result),
		clear_candidate_text,
	]


func _alpha_focus_boss_response_line(entry: Dictionary) -> String:
	if active_alpha_probe_entry.is_empty():
		return ""
	if _alpha_focus_entry_key(entry) != _alpha_focus_entry_key(active_alpha_probe_entry):
		return ""
	if last_boss_warning_response_line.is_empty():
		var pending_warning = _alpha_focus_pending_boss_warning_text(true)
		if not pending_warning.is_empty():
			return "Boss Response: %s" % pending_warning
		return "Boss Response: none recorded yet"

	return "Boss Response: %s" % _short_boss_warning_response_text()


func _alpha_focus_pending_boss_warning_text(compact: bool) -> String:
	var report = _active_boss_warning_report()
	if report.is_empty():
		return ""

	var tile_value = report.get("tile", INVALID_TILE)
	var tile = INVALID_TILE
	if typeof(tile_value) == TYPE_VECTOR2I:
		tile = tile_value

	var focus_label = str(report.get("focus_label", "boss part"))
	var danger_label = str(report.get("danger_label", ""))
	var target_text = focus_label
	if not danger_label.is_empty() and danger_label != focus_label:
		target_text = "%s opens %s" % [focus_label, danger_label]

	var pending_text = "pending %s at %s" % [target_text, _tile_text(tile)]
	if compact:
		return pending_text

	var suggestion = str(report.get("suggestion", "answer the boss warning"))
	return "%s - %s" % [pending_text, suggestion]


func _short_boss_warning_response_text() -> String:
	var prefix = "Boss warning response: "
	if last_boss_warning_response_line.begins_with(prefix):
		return last_boss_warning_response_line.substr(prefix.length())

	return last_boss_warning_response_line


func _alpha_focus_review_priority_line(entry: Dictionary) -> String:
	var score = int(entry.get("review_priority_score", 0))
	var score_text = "" if score <= 0 else " | Score %s" % score
	var reason = str(entry.get("review_priority_reason", ""))
	var reason_text = "" if reason.is_empty() else " | %s" % reason
	return "Review Priority: %s%s%s" % [
		_alpha_probe_badge_for_status(_alpha_focus_review_status(entry)),
		score_text,
		reason_text,
	]


func _format_autoplay_focus_panel_title(entry: Dictionary, index: int, total: int) -> String:
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	var review_order = _alpha_focus_review_order()
	var review_position = _alpha_focus_review_position_for_index(index, review_order) + 1
	var review_text = "" if review_position <= 0 else " | review %s/%s" % [review_position, review_order.size()]
	return "Alpha focus %s/%s%s: %s %sP%s%s" % [
		index + 1,
		total,
		review_text,
		entry.get("class_label", "Default"),
		entry.get("player_count", 0),
		direction_text,
		_alpha_focus_probe_badge_text(entry),
	]


func _format_autoplay_focus_panel_body(entry: Dictionary) -> String:
	var cards: Array = entry.get("analysis_cards", [])
	var lines = PackedStringArray()
	if not cards.is_empty():
		for card_value in cards:
			if typeof(card_value) != TYPE_DICTIONARY:
				continue

			var card: Dictionary = card_value
			lines.append("%s: %s" % [
				card.get("title", "Card"),
				card.get("body", ""),
			])

	if lines.is_empty():
		lines.append("Result: R%s, base HP %s" % [
			entry.get("completed_rounds", 0),
			entry.get("base_hp", 0),
		])
		lines.append("Cause: %s - %s" % [
			entry.get("primary_signal", "review"),
			entry.get("evidence", ""),
		])
		lines.append("Next Probe: %s" % entry.get("next_probe", ""))

	var recommendation_contrast_line = _autoplay_recommendation_contrast_line_for_entry(entry)
	if not recommendation_contrast_line.is_empty():
		lines.append(recommendation_contrast_line)

	lines.append(_alpha_focus_review_priority_line(entry))
	lines.append(_alpha_focus_manual_review_line(entry))
	for recommendation_fix_line in _alpha_focus_recommendation_fix_lines(entry):
		lines.append(recommendation_fix_line)

	var probe_line = _alpha_focus_probe_result_line(entry)
	if not probe_line.is_empty():
		lines.append(probe_line)

	var boss_response_line = _alpha_focus_boss_response_line(entry)
	if not boss_response_line.is_empty():
		lines.append(boss_response_line)

	var next_action_line = _alpha_focus_next_action_line(entry)
	if not next_action_line.is_empty():
		lines.append(next_action_line)

	return "\n".join(lines)


func _autoplay_recommendation_contrast_line_for_entry(entry: Dictionary) -> String:
	var sample = _autoplay_recommendation_contrast_sample_for_entry(entry)
	if sample.is_empty():
		return ""

	var samples = _autoplay_recommendation_contrast_samples_for_entry(entry)
	var sample_count = samples.size()
	var sample_position = clamp(selected_autoplay_recommendation_contrast_index, 0, max(0, sample_count - 1)) + 1
	var choice_type = str(sample.get("choice_type", "choice"))
	var prompt = str(sample.get("prompt", ""))
	if prompt.is_empty():
		return ""

	var reason = str(sample.get("recommendation_reason", ""))
	var reason_text = "" if reason.is_empty() else " | Reason: %s" % reason
	var detail = str(sample.get("recommendation_detail", ""))
	var detail_text = "" if detail.is_empty() else " | Why now: %s" % detail
	return "Recommendation Contrast Sample: %s/%s %s | %s%s%s" % [
		sample_position,
		max(1, sample_count),
		choice_type,
		prompt,
		reason_text,
		detail_text,
	]


func _autoplay_recommendation_contrast_sample_for_entry(entry: Dictionary) -> Dictionary:
	var samples = _autoplay_recommendation_contrast_samples_for_entry(entry)
	if samples.is_empty():
		return {}

	var selected_index = clamp(selected_autoplay_recommendation_contrast_index, 0, samples.size() - 1)
	var sample_value = samples[selected_index]
	if typeof(sample_value) != TYPE_DICTIONARY:
		return {}

	var sample: Dictionary = sample_value
	return sample


func _autoplay_recommendation_contrast_samples_for_entry(entry: Dictionary) -> Array:
	var samples: Array = []
	if entry.is_empty() or last_autoplay_recommendation_contrast_samples.is_empty():
		return samples

	var class_id = str(entry.get("class_id", ""))
	var class_label = str(entry.get("class_label", ""))
	var player_count_value = int(entry.get("player_count", 0))
	for sample_value in last_autoplay_recommendation_contrast_samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue

		var sample: Dictionary = sample_value
		if int(sample.get("player_count", 0)) != player_count_value:
			continue
		var sample_class_id = str(sample.get("class_id", ""))
		var sample_class_label = str(sample.get("class_label", ""))
		if (not class_id.is_empty() and sample_class_id == class_id) or (not class_label.is_empty() and sample_class_label == class_label):
			samples.append(sample)

	return samples


func _alpha_focus_next_action_line(entry: Dictionary) -> String:
	var action = _next_action_for_alpha_focus_entry(entry)
	if action.is_empty():
		return ""

	return _format_next_action_panel_entry(action)


func _format_next_action_queue_panel_body() -> String:
	if last_autoplay_next_action_queue.is_empty():
		return ""

	var lines = PackedStringArray()
	var limit = min(AUTOPLAY_NEXT_ACTION_LOG_LIMIT, last_autoplay_next_action_queue.size())
	for index in range(limit):
		var action_value = last_autoplay_next_action_queue[index]
		if typeof(action_value) != TYPE_DICTIONARY:
			continue

		var action: Dictionary = action_value
		lines.append(_format_next_action_panel_entry(action))

	return "\n".join(lines)


func _selected_next_action_for_panel(entry: Dictionary) -> Dictionary:
	if not entry.is_empty():
		return _next_action_for_alpha_focus_entry(entry)

	if last_autoplay_next_action_queue.is_empty():
		return {}

	var first_value = last_autoplay_next_action_queue[0]
	if typeof(first_value) != TYPE_DICTIONARY:
		return {}

	var action: Dictionary = first_value
	return action


func _next_action_for_alpha_focus_entry(entry: Dictionary) -> Dictionary:
	if last_autoplay_next_action_queue.is_empty():
		return {}

	var best_action: Dictionary = {}
	var best_score = -1
	for action_value in last_autoplay_next_action_queue:
		if typeof(action_value) != TYPE_DICTIONARY:
			continue

		var action: Dictionary = action_value
		var score = _next_action_match_score(entry, action)
		if best_action.is_empty() or score > best_score:
			best_action = action
			best_score = score

	if best_score > 0:
		return best_action

	var first_value = last_autoplay_next_action_queue[0]
	if typeof(first_value) != TYPE_DICTIONARY:
		return {}

	var first_action: Dictionary = first_value
	return first_action


func _next_action_setup_report(action: Dictionary, fallback_entry: Dictionary) -> Dictionary:
	if action.is_empty():
		return _next_action_setup_reject("No action queue case selected.")
	if run_started:
		return _next_action_setup_reject("Reset before applying an action queue case.")
	if not simulation.is_loaded():
		return _next_action_setup_reject("Data is not loaded.")

	var setup_entry = _next_action_setup_entry(action, fallback_entry)
	if setup_entry.is_empty():
		return _next_action_setup_reject("This action has no class/player setup to apply.")

	var next_class_id = str(setup_entry.get("class_id", ""))
	if next_class_id.is_empty() or simulation.get_class_data(next_class_id).is_empty():
		return _next_action_setup_reject("Action queue setup has an unknown class.")

	return {
		"ok": true,
		"entry": setup_entry,
		"summary": "Apply %s and preview the first setup tile. Check: %s" % [
			_next_action_setup_entry_label(setup_entry),
			setup_entry.get("next_probe", ""),
		],
	}


func _next_action_setup_entry(action: Dictionary, fallback_entry: Dictionary) -> Dictionary:
	var next_class_id = str(action.get("class_id", fallback_entry.get("class_id", "")))
	var next_player_count = int(action.get("player_count", fallback_entry.get("player_count", 0)))
	if next_class_id.is_empty() or next_player_count <= 0:
		return {}

	var fallback_class_label = str(fallback_entry.get("class_label", ""))
	var class_label = str(action.get("class_label", fallback_class_label))
	if class_label.is_empty():
		class_label = _class_label(next_class_id)

	return {
		"rank": int(action.get("rank", fallback_entry.get("rank", 0))),
		"class_id": next_class_id,
		"class_label": class_label,
		"player_count": clamp(next_player_count, 1, 4),
		"direction": str(action.get("direction", fallback_entry.get("direction", ""))),
		"primary_signal": str(action.get("signal", fallback_entry.get("primary_signal", "next action"))),
		"evidence": str(action.get("metric", fallback_entry.get("evidence", ""))),
		"next_probe": str(action.get("check", fallback_entry.get("next_probe", ""))),
		"review_priority_score": int(action.get("review_priority_score", fallback_entry.get("review_priority_score", 0))),
		"review_priority_reason": str(action.get("review_priority_reason", fallback_entry.get("review_priority_reason", ""))),
		"recommendation_choice_type": str(action.get("recommendation_choice_type", fallback_entry.get("recommendation_choice_type", "none"))),
		"recommendation_label": str(action.get("recommendation_label", fallback_entry.get("recommendation_label", ""))),
		"completed_rounds": int(fallback_entry.get("completed_rounds", 0)),
		"base_hp": int(fallback_entry.get("base_hp", 0)),
	}


func _next_action_setup_entry_label(entry: Dictionary) -> String:
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	return "%s %sP%s" % [
		entry.get("class_label", "Default"),
		entry.get("player_count", 0),
		direction_text,
	]


func _next_action_setup_reject(reason: String) -> Dictionary:
	return {
		"ok": false,
		"reason": reason,
		"summary": reason,
		"entry": {},
	}


func _preview_next_action_setup_plan() -> Dictionary:
	if not simulation.is_loaded():
		return _next_action_preview_reject("data_not_loaded")

	var report = _setup_plan_next_step_report()
	if not bool(report.get("ok", false)):
		return report

	var tile: Vector2i = report.get("tile", INVALID_TILE)
	if not _is_valid_tile(tile):
		return _next_action_preview_reject("invalid_tile")

	var structure_type = str(report.get("structure_type", ""))
	if not ["tower", "barricade"].has(structure_type):
		return _next_action_preview_reject("invalid_structure")

	selected_card_index = -1
	build_mode = structure_type
	hovered_tile = tile
	selected_tile = tile
	preview_tile = tile
	preview_ok = true
	preview_reason = ""
	return {
		"ok": true,
		"reason": "ok",
		"tile": tile,
		"structure_type": structure_type,
		"summary": "First setup preview: %s at %s. %s" % [
			structure_type.capitalize(),
			_tile_text(tile),
			report.get("summary", ""),
		],
	}


func _has_action_setup_preview() -> bool:
	if run_started:
		return false
	if not preview_ok or not _is_valid_tile(preview_tile):
		return false
	if not ["tower", "barricade"].has(build_mode):
		return false

	return selected_tile == preview_tile


func _next_action_preview_reject(reason: String) -> Dictionary:
	return {
		"ok": false,
		"reason": reason,
		"summary": reason,
		"tile": INVALID_TILE,
		"structure_type": "",
	}


func _next_action_match_score(entry: Dictionary, action: Dictionary) -> int:
	var score = 0
	var class_id = str(action.get("class_id", ""))
	if not class_id.is_empty() and class_id == str(entry.get("class_id", "")):
		score += 4

	var action_player_count = int(action.get("player_count", 0))
	if action_player_count > 0 and action_player_count == int(entry.get("player_count", 0)):
		score += 2

	var direction = str(action.get("direction", ""))
	if not direction.is_empty() and direction == str(entry.get("direction", "")):
		score += 2

	var signal_text = str(action.get("signal", ""))
	if not signal_text.is_empty() and signal_text == str(entry.get("primary_signal", "")):
		score += 1

	return score


func _format_next_action_panel_entry(action: Dictionary) -> String:
	var rank = int(action.get("rank", 0))
	var severity = str(action.get("severity", "watch")).to_upper()
	var signal_text = str(action.get("signal", "review"))
	var hypothesis = str(action.get("hypothesis", ""))
	var check = str(action.get("check", ""))
	var metric = str(action.get("metric", ""))
	var source = _next_action_source_text(action)
	var review_reason = str(action.get("review_priority_reason", ""))
	var review_reason_text = "" if review_reason.is_empty() else "\nReason: %s" % review_reason
	return "Action Queue #%s [%s] %s: %s\nCheck: %s\nMetric: %s\nSource: %s%s" % [
		rank,
		severity,
		signal_text,
		hypothesis,
		check,
		metric,
		source,
		review_reason_text,
	]


func _next_action_source_text(action: Dictionary) -> String:
	var source = str(action.get("source", "report"))
	var document = str(action.get("document", ""))
	if document.is_empty():
		return source

	return "%s / %s" % [source, document]


func _push_autoplay_focus_queue(report: Dictionary) -> void:
	var queue: Array = report.get("alpha_focus_queue", [])
	if queue.is_empty():
		return

	var limit = min(AUTOPLAY_FOCUS_LOG_LIMIT, queue.size())
	for index in range(limit):
		var entry_value = queue[index]
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		debug_log.push(_format_autoplay_focus_entry(entry_value), "system")


func _push_autoplay_next_action_queue(report: Dictionary) -> void:
	var queue: Array = report.get("next_action_queue", [])
	if queue.is_empty():
		return

	var limit = min(AUTOPLAY_NEXT_ACTION_LOG_LIMIT, queue.size())
	for index in range(limit):
		var action_value = queue[index]
		if typeof(action_value) != TYPE_DICTIONARY:
			continue

		debug_log.push(_format_autoplay_next_action_entry(action_value), "system")


func _format_autoplay_focus_entry(entry: Dictionary) -> String:
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	return "Alpha focus #%s: %s %sP%s - %s. %s Next: %s" % [
		entry.get("rank", 0),
		entry.get("class_label", "Default"),
		entry.get("player_count", 0),
		direction_text,
		entry.get("primary_signal", "review"),
		entry.get("evidence", ""),
		entry.get("next_probe", ""),
	]


func _autoplay_recommendation_contrast_samples_from_report(report: Dictionary) -> Array:
	var samples_value = report.get("recommendation_contrast_samples", [])
	if typeof(samples_value) != TYPE_ARRAY:
		var aggregate_value = report.get("aggregate", {})
		if typeof(aggregate_value) == TYPE_DICTIONARY:
			var aggregate: Dictionary = aggregate_value
			samples_value = aggregate.get("recommendation_contrast_samples", [])

	var samples: Array = []
	if typeof(samples_value) != TYPE_ARRAY:
		return samples

	for sample_value in samples_value:
		if typeof(sample_value) == TYPE_DICTIONARY:
			var sample: Dictionary = sample_value
			samples.append(sample.duplicate(true))

	return samples


func _format_autoplay_next_action_entry(action: Dictionary) -> String:
	var reason = str(action.get("review_priority_reason", ""))
	var reason_text = "" if reason.is_empty() else " Reason: %s" % reason
	return "Next action #%s [%s] %s: %s Check: %s%s" % [
		action.get("rank", 0),
		str(action.get("severity", "watch")).to_upper(),
		action.get("signal", "review"),
		action.get("hypothesis", ""),
		action.get("check", ""),
		reason_text,
	]


func _record_alpha_focus_manual_review(status: String) -> void:
	var entry: Dictionary = _selected_alpha_focus_entry()
	var key = _alpha_focus_entry_key(entry)
	if entry.is_empty() or key.is_empty():
		debug_log.push("Human review unavailable: no alpha focus case selected.", "system")
		_refresh_screen()
		return

	var normalized_status = "manual_issue" if status == "manual_issue" else "manual_clear"
	var was_clear_candidate = normalized_status == "manual_clear" and _alpha_focus_is_clear_candidate(entry)
	var badge = _alpha_probe_badge_for_status(normalized_status)
	var class_label = str(entry.get("class_label", _class_label(str(entry.get("class_id", "")))))
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction
	var summary = "needs follow-up before alpha" if normalized_status == "manual_issue" else "checked by human alpha"
	var persistent_key = _alpha_focus_persistent_key(entry)
	var issue_tag_id = _selected_alpha_issue_tag_id() if normalized_status == "manual_issue" else "untagged"
	var issue_tag_label = _alpha_issue_tag_display_label(issue_tag_id)
	var recommendation_contrast_id = _selected_alpha_recommendation_contrast_id()
	var recommendation_contrast_label = _alpha_recommendation_contrast_label(recommendation_contrast_id)
	var recommendation_fix_check_ids: Array[String] = []
	if _alpha_recommendation_contrast_needs_fix(recommendation_contrast_id):
		recommendation_fix_check_ids = _selected_alpha_recommendation_fix_check_ids()
	var recommendation_fix_check_text = _format_alpha_recommendation_fix_check_labels(recommendation_fix_check_ids)
	alpha_focus_manual_review_results[key] = {
		"status": normalized_status,
		"badge": badge,
		"summary": summary,
		"class_id": entry.get("class_id", ""),
		"class_label": class_label,
		"player_count": int(entry.get("player_count", 0)),
		"direction": direction,
		"coverage_run_id": entry.get("coverage_run_id", ""),
		"issue_tag_id": issue_tag_id,
		"issue_tag_label": issue_tag_label,
		"recommendation_contrast_id": recommendation_contrast_id,
		"recommendation_contrast_label": recommendation_contrast_label,
		"recommendation_fix_check_ids": recommendation_fix_check_ids,
		"recommendation_fix_check_text": recommendation_fix_check_text,
		"persistent_key": persistent_key,
		"entry_key": key,
	}
	var issue_tag_suffix = "" if issue_tag_label.is_empty() else " [%s]" % issue_tag_label
	var recommendation_contrast_suffix = " | Recommendation contrast: %s" % recommendation_contrast_label
	var recommendation_fix_check_suffix = "" if recommendation_fix_check_text.is_empty() else " | Recommendation checks: %s" % recommendation_fix_check_text
	debug_log.push("Human review marked %s%s: %s %sP%s - %s%s%s." % [
		badge,
		issue_tag_suffix,
		class_label,
		int(entry.get("player_count", 0)),
		direction_text,
		summary,
		recommendation_contrast_suffix,
		recommendation_fix_check_suffix,
	], "system")
	if was_clear_candidate:
		debug_log.push("Clear candidate confirmed: %s." % _alpha_focus_case_label(entry), "system")
	var save_result = _save_alpha_manual_review_results()
	if bool(save_result.get("ok", false)):
		debug_log.push("Human review saved: %s (%s cases)." % [
			save_result.get("path", ALPHA_MANUAL_REVIEW_SAVE_PATH),
			save_result.get("review_count", 0),
		], "system")
	else:
		debug_log.push("Human review save failed: %s." % save_result.get("reason", "unknown"), "system")
	debug_log.push(_format_alpha_manual_review_log_summary(), "system")
	_refresh_screen()


func _on_alpha_focus_mark_clear_pressed() -> void:
	_record_alpha_focus_manual_review("manual_clear")


func _on_alpha_focus_mark_issue_pressed() -> void:
	_record_alpha_focus_manual_review("manual_issue")


func _on_alpha_issue_tag_selected(index: int) -> void:
	selected_alpha_issue_tag_id = _alpha_issue_tag_id_for_index(index)


func _on_alpha_recommendation_contrast_selected(index: int) -> void:
	selected_alpha_recommendation_contrast_id = _alpha_recommendation_contrast_id_for_index(index)
	if not _alpha_recommendation_contrast_needs_fix(selected_alpha_recommendation_contrast_id):
		selected_alpha_recommendation_fix_check_ids.clear()
	_refresh_alpha_recommendation_fix_check_controls_for_selection(
		not _selected_alpha_focus_entry().is_empty(),
		selected_alpha_recommendation_contrast_id,
		selected_alpha_recommendation_fix_check_ids
	)


func _on_alpha_recommendation_fix_check_toggled(toggled_on: bool, check_id: String) -> void:
	if not ALPHA_RECOMMENDATION_FIX_CHECK_IDS.has(check_id):
		return

	if toggled_on:
		if not selected_alpha_recommendation_fix_check_ids.has(check_id):
			selected_alpha_recommendation_fix_check_ids.append(check_id)
	elif selected_alpha_recommendation_fix_check_ids.has(check_id):
		selected_alpha_recommendation_fix_check_ids.erase(check_id)


func _on_alpha_coverage_open_next_manual_pressed() -> void:
	var next_manual_index = _alpha_first_remaining_review_index()
	if next_manual_index < 0:
		debug_log.push("Alpha next manual queue empty: every human case is marked.", "system")
		_refresh_screen()
		return

	selected_autoplay_focus_index = next_manual_index
	selected_autoplay_recommendation_contrast_index = 0
	active_alpha_probe_entry.clear()
	var entry: Dictionary = _selected_alpha_focus_entry()
	debug_log.push("Alpha next manual opened: %s." % _alpha_focus_case_label(entry), "system")
	_refresh_alpha_focus_panel()
	_refresh_alpha_coverage_panel()
	_refresh_map_view()
	_refresh_log()


func _on_alpha_coverage_open_issue_pressed() -> void:
	var issue_index = _alpha_first_issue_review_index()
	if issue_index < 0:
		debug_log.push("Alpha issue queue empty: no human issue marked.", "system")
		_refresh_screen()
		return

	selected_autoplay_focus_index = issue_index
	selected_autoplay_recommendation_contrast_index = 0
	active_alpha_probe_entry.clear()
	var entry: Dictionary = _selected_alpha_focus_entry()
	debug_log.push("Alpha issue opened: %s." % _alpha_focus_case_label(entry), "system")
	_refresh_alpha_focus_panel()
	_refresh_alpha_coverage_panel()
	_refresh_map_view()
	_refresh_log()


func _on_alpha_coverage_open_fix_lane_pressed() -> void:
	var report = _alpha_manual_review_report()
	var recommendation: Dictionary = report.get("fix_recommendation", {})
	var tag_id = str(recommendation.get("tag_id", ""))
	if tag_id.is_empty():
		debug_log.push("Alpha fix lane empty: no recommended human issue marked.", "system")
		_refresh_screen()
		return

	var fix_lane_index = _alpha_first_issue_review_index_for_tag(tag_id)
	if fix_lane_index < 0:
		debug_log.push("Alpha fix lane empty: no recommended human issue marked.", "system")
		_refresh_screen()
		return

	selected_autoplay_focus_index = fix_lane_index
	selected_autoplay_recommendation_contrast_index = 0
	active_alpha_probe_entry.clear()
	var entry: Dictionary = _selected_alpha_focus_entry()
	debug_log.push("Alpha fix lane opened: %s. %s" % [
		_alpha_focus_case_label(entry),
		_format_alpha_fix_recommendation(recommendation),
	], "system")
	_refresh_alpha_focus_panel()
	_refresh_alpha_coverage_panel()
	_refresh_map_view()
	_refresh_log()


func _on_alpha_coverage_open_recommendation_fix_pressed() -> void:
	var report = _alpha_manual_review_report()
	var recommendation: Dictionary = report.get("recommendation_contrast_fix", {})
	var fix_index = _alpha_recommendation_fix_review_index()
	if recommendation.is_empty() or fix_index < 0:
		debug_log.push("Alpha recommendation wording fix empty: no unclear recommendation case marked.", "system")
		_refresh_screen()
		return

	selected_autoplay_focus_index = fix_index
	selected_autoplay_recommendation_contrast_index = 0
	active_alpha_probe_entry.clear()
	var entry: Dictionary = _selected_alpha_focus_entry()
	debug_log.push("Alpha recommendation wording fix opened: %s. %s" % [
		_alpha_focus_case_label(entry),
		_format_alpha_recommendation_contrast_fix(recommendation),
	], "system")
	_refresh_alpha_focus_panel()
	_refresh_alpha_coverage_panel()
	_refresh_map_view()
	_refresh_log()


func _on_alpha_coverage_probe_fix_lane_pressed() -> void:
	var report = _alpha_manual_review_report()
	var recommendation: Dictionary = report.get("fix_recommendation", {})
	var tag_id = str(recommendation.get("tag_id", ""))
	if tag_id.is_empty():
		debug_log.push("Alpha fix lane probe unavailable: no recommended human issue marked.", "system")
		_refresh_screen()
		return

	var fix_lane_index = _alpha_first_issue_review_index_for_tag(tag_id)
	if fix_lane_index < 0:
		debug_log.push("Alpha fix lane probe unavailable: no recommended human issue marked.", "system")
		_refresh_screen()
		return

	selected_autoplay_focus_index = fix_lane_index
	selected_autoplay_recommendation_contrast_index = 0
	active_alpha_probe_entry.clear()
	var entry: Dictionary = _selected_alpha_focus_entry()
	_start_alpha_focus_probe_for_entry(entry, "Alpha fix lane probe", _format_alpha_fix_recommendation(recommendation))


func _on_alpha_coverage_run_pressed() -> void:
	if not simulation.is_loaded():
		debug_log.push("Alpha coverage unavailable: data is not loaded.", "system")
		_refresh_screen()
		return

	var runner = M0AlphaCoverageRunnerScript.new()
	last_alpha_coverage_result = runner.run_all()
	var aggregate: Dictionary = last_alpha_coverage_result.get("aggregate", {})
	var ok = bool(last_alpha_coverage_result.get("ok", false))
	var case_count = int(aggregate.get("case_count", 0))
	var pass_count = int(aggregate.get("pass_count", 0))
	var required_signal_count = int(aggregate.get("required_signal_count", 0))
	var observed_signal_count = int(aggregate.get("observed_signal_count", 0))
	var human_review_queue: Array = last_alpha_coverage_result.get("human_review_queue", [])
	debug_log.push("Alpha coverage %s: %s/%s cases, %s/%s signals. Human alpha still required." % [
		"passed" if ok else "failed",
		pass_count,
		case_count,
		observed_signal_count,
		required_signal_count,
	], "system")
	debug_log.push("Alpha coverage review queue ready: %s human cases." % human_review_queue.size(), "system")
	var recommendation_focus_summary = str(aggregate.get("recommendation_focus_summary", ""))
	if not recommendation_focus_summary.is_empty():
		debug_log.push("Alpha recommendation focus: %s" % recommendation_focus_summary, "system")

	for line in last_alpha_coverage_result.get("summary_lines", []):
		debug_log.push(str(line), "system")

	_set_autoplay_focus_queue({
		"alpha_focus_queue": last_alpha_coverage_result.get("alpha_focus_queue", []),
		"next_action_queue": last_alpha_coverage_result.get("next_action_queue", []),
		"recommendation_contrast_samples": last_alpha_coverage_result.get("recommendation_contrast_samples", []),
		"aggregate": aggregate,
	})
	_refresh_screen()


func _on_alpha_focus_prev_pressed() -> void:
	if last_autoplay_focus_queue.is_empty():
		return

	_move_alpha_focus_selection(-1)
	_refresh_screen()


func _on_alpha_focus_next_pressed() -> void:
	if last_autoplay_focus_queue.is_empty():
		return

	_move_alpha_focus_selection(1)
	_refresh_screen()


func _on_alpha_contrast_prev_pressed() -> void:
	_move_alpha_recommendation_contrast_sample(-1)


func _on_alpha_contrast_next_pressed() -> void:
	_move_alpha_recommendation_contrast_sample(1)


func _move_alpha_recommendation_contrast_sample(step: int) -> void:
	var entry = _selected_alpha_focus_entry()
	var samples = _autoplay_recommendation_contrast_samples_for_entry(entry)
	if samples.is_empty():
		selected_autoplay_recommendation_contrast_index = 0
		_refresh_alpha_focus_panel()
		return

	selected_autoplay_recommendation_contrast_index = (
		selected_autoplay_recommendation_contrast_index + step + samples.size()
	) % samples.size()
	_refresh_alpha_focus_panel()


func _move_alpha_focus_selection(step: int) -> void:
	var order = _alpha_focus_review_order()
	if order.is_empty():
		return

	var current_position = _alpha_focus_review_position_for_index(selected_autoplay_focus_index, order)
	if current_position < 0:
		current_position = 0

	var next_position = (current_position + step + order.size()) % order.size()
	var item_value = order[next_position]
	if typeof(item_value) != TYPE_DICTIONARY:
		return

	var item: Dictionary = item_value
	selected_autoplay_focus_index = clamp(int(item.get("index", selected_autoplay_focus_index)), 0, last_autoplay_focus_queue.size() - 1)
	selected_autoplay_recommendation_contrast_index = 0
	if not run_started:
		selected_card_index = -1
		build_mode = "none"
		hovered_tile = INVALID_TILE
		selected_tile = INVALID_TILE
		_clear_preview()


func _on_alpha_focus_action_pressed() -> void:
	var current_entry: Dictionary = _selected_alpha_focus_entry()
	var action = _selected_next_action_for_panel(current_entry)
	var setup_report = _next_action_setup_report(action, current_entry)
	if not bool(setup_report.get("ok", false)):
		debug_log.push("Next action setup unavailable: %s" % setup_report.get("reason", "unknown"))
		_refresh_screen()
		return

	var setup_entry: Dictionary = setup_report.get("entry", {})
	_select_alpha_focus_for_setup_entry(setup_entry)
	active_alpha_probe_entry.clear()
	if _apply_alpha_focus_setup(setup_entry, false):
		var preview_report = _preview_next_action_setup_plan()
		debug_log.push("Next action setup applied: %s.%s Check: %s" % [
			_next_action_setup_entry_label(setup_entry),
			_alpha_focus_setup_preview_text(preview_report),
			setup_entry.get("next_probe", ""),
		], "system")
	_refresh_screen()


func _select_alpha_focus_for_setup_entry(setup_entry: Dictionary) -> void:
	if last_autoplay_focus_queue.is_empty() or setup_entry.is_empty():
		return

	for index in range(last_autoplay_focus_queue.size()):
		var entry_value = last_autoplay_focus_queue[index]
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = entry_value
		if str(entry.get("class_id", "")) != str(setup_entry.get("class_id", "")):
			continue
		if int(entry.get("player_count", 0)) != int(setup_entry.get("player_count", 0)):
			continue

		var direction = str(setup_entry.get("direction", ""))
		if not direction.is_empty() and direction != str(entry.get("direction", "")):
			continue

		selected_autoplay_focus_index = index
		selected_autoplay_recommendation_contrast_index = 0
		return


func _on_alpha_focus_apply_pressed() -> void:
	var entry: Dictionary = _selected_alpha_focus_entry()
	active_alpha_probe_entry.clear()
	if _apply_alpha_focus_setup(entry, false):
		var preview_report = _preview_next_action_setup_plan()
		debug_log.push("Alpha focus setup applied: %s.%s Begin run to replay this case." % [
			_alpha_focus_case_label(entry),
			_alpha_focus_setup_preview_text(preview_report),
		], "system")
	_refresh_screen()


func _alpha_focus_setup_preview_text(preview_report: Dictionary) -> String:
	if bool(preview_report.get("ok", false)):
		return " Preview: %s at %s." % [
			str(preview_report.get("structure_type", "structure")).capitalize(),
			_tile_text(preview_report.get("tile", INVALID_TILE)),
		]

	return " Preview unavailable: %s." % preview_report.get("reason", "blocked")


func _on_alpha_focus_probe_pressed() -> void:
	var entry: Dictionary = _selected_alpha_focus_entry()
	_start_alpha_focus_probe_for_entry(entry, "Alpha focus probe")


func _start_alpha_focus_probe_for_entry(entry: Dictionary, log_label: String, context: String = "") -> void:
	if not _apply_alpha_focus_setup(entry, false):
		_refresh_screen()
		return

	_on_begin_run_pressed()
	if run_started:
		active_alpha_probe_entry = entry.duplicate(true)
		var direction = str(entry.get("direction", ""))
		var direction_text = "" if direction.is_empty() else " @%s" % direction
		debug_log.push("%s started: %s %sP%s. Opening defense and wave 1 will run once." % [
			log_label,
			_class_label(selected_class_id),
			player_count,
			direction_text,
		], "system")
		if not context.is_empty():
			debug_log.push("%s context: %s." % [log_label, context], "system")
		var probe_result = _run_alpha_focus_opening_probe()
		if bool(probe_result.get("ok", false)):
			var result_prefix = "%s result" % log_label
			if not context.is_empty():
				result_prefix = "%s (%s)" % [result_prefix, context]
			debug_log.push("%s: %s" % [result_prefix, probe_result.get("summary", "")], "system")
		else:
			var stopped_prefix = "%s stopped" % log_label
			if not context.is_empty():
				stopped_prefix = "%s (%s)" % [stopped_prefix, context]
			debug_log.push("%s: %s. %s" % [
				stopped_prefix,
				probe_result.get("reason", "blocked"),
				probe_result.get("summary", ""),
			], "system")
	_refresh_screen()


func _run_alpha_focus_opening_probe() -> Dictionary:
	var setup_result = _execute_setup_plan(false, "Alpha probe setup")
	var setup_placed_count = int(setup_result.get("placed_count", 0))
	if not bool(setup_result.get("ok", false)):
		var blocked_result = _record_alpha_probe_result(active_alpha_probe_entry, simulation.get_completed_rounds(), simulation.get_base_hp())
		return {
			"ok": false,
			"reason": setup_result.get("reason", "setup_blocked"),
			"summary": "placed %s. %s %s" % [
				setup_placed_count,
				_format_alpha_probe_status(),
				blocked_result.get("signal_summary", ""),
			],
		}

	var start_result = simulation.start_wave(player_count)
	if not bool(start_result.get("ok", false)):
		var blocked_wave_result = _record_alpha_probe_result(active_alpha_probe_entry, simulation.get_completed_rounds(), simulation.get_base_hp())
		return {
			"ok": false,
			"reason": start_result.get("reason", "wave_blocked"),
			"summary": "%s %s" % [
				_format_alpha_probe_status(),
				blocked_wave_result.get("signal_summary", ""),
			],
		}

	for event in start_result.get("events", []):
		debug_log.push(str(event))

	var step_limit = max(1, simulation.get_autoplay_max_steps_per_round())
	var step_count = 0
	while simulation.wave_active and step_count < step_limit:
		var events = simulation.step_wave(player_count)
		for event in events:
			debug_log.push(str(event))
		step_count += 1

	wave_timer.stop()
	if simulation.wave_active:
		var timeout_result = _record_alpha_probe_result(active_alpha_probe_entry, simulation.get_completed_rounds(), simulation.get_base_hp())
		return {
			"ok": false,
			"reason": "step_limit_reached",
			"summary": "placed %s. Probe stopped after %s steps. %s %s" % [
				setup_placed_count,
				step_count,
				_format_alpha_probe_status(),
				timeout_result.get("signal_summary", ""),
			],
		}

	var result = _record_alpha_probe_result(active_alpha_probe_entry, simulation.get_completed_rounds(), simulation.get_base_hp())
	return {
		"ok": true,
		"reason": "ok",
		"steps": step_count,
		"summary": "placed %s, R%s HP %s after %s steps. %s %s" % [
			setup_placed_count,
			simulation.get_completed_rounds(),
			simulation.get_base_hp(),
			step_count,
			_format_alpha_probe_status(),
			result.get("signal_summary", ""),
		],
	}


func _apply_alpha_focus_setup(entry: Dictionary, log_success: bool) -> bool:
	if not simulation.is_loaded():
		debug_log.push("Alpha focus setup unavailable: data is not loaded.")
		return false

	if run_started:
		debug_log.push("Alpha focus setup locked: reset before applying a focus case.")
		return false

	if entry.is_empty():
		debug_log.push("Alpha focus setup unavailable: no focus case selected.")
		return false

	var next_class_id = str(entry.get("class_id", ""))
	if next_class_id.is_empty() or simulation.get_class_data(next_class_id).is_empty():
		debug_log.push("Alpha focus setup unavailable: unknown class.")
		return false

	var next_player_count = clamp(int(entry.get("player_count", player_count)), 1, 4)
	var direction = str(entry.get("direction", ""))
	var direction_text = "" if direction.is_empty() else " @%s" % direction

	wave_timer.stop()
	_clear_preview()
	_clear_discard_follow_up()
	_clear_combat_follow_up()
	selected_card_index = -1
	selected_artifact_replacement_offer_id = ""
	selected_dormant_artifact_release_id = ""
	_clear_shop_reactivation_selection()
	hovered_tile = INVALID_TILE
	selected_tile = INVALID_TILE
	build_mode = "none"
	last_boss_warning_response_line = ""
	player_count = next_player_count
	selected_class_id = next_class_id
	simulation.reset_run()
	if log_success:
		debug_log.push("Alpha focus setup applied: %s %sP%s. Begin run to replay this case." % [
			_class_label(selected_class_id),
			player_count,
			direction_text,
		])
	return true


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


func _on_log_filter_selected(index: int) -> void:
	log_filter_category = _log_category_for_filter_index(index)
	_refresh_log()


func _on_important_log_toggled(enabled: bool) -> void:
	show_important_logs_only = enabled
	_refresh_log()


func _on_wave_timer_timeout() -> void:
	_run_wave_step()


func _run_wave_step() -> void:
	if not run_started:
		return

	var completed_rounds_before = simulation.get_completed_rounds()
	var previous_combat_follow_up_key = last_combat_follow_up_report_key
	var events = simulation.step_wave(player_count)
	for event in events:
		debug_log.push(event)
	var combat_follow_up_line = _capture_combat_follow_up(previous_combat_follow_up_key)
	if not combat_follow_up_line.is_empty():
		debug_log.push(combat_follow_up_line, "system")

	if not simulation.wave_active:
		wave_timer.stop()
	if not active_alpha_probe_entry.is_empty() and simulation.get_completed_rounds() > completed_rounds_before:
		_record_alpha_probe_result(active_alpha_probe_entry, simulation.get_completed_rounds(), simulation.get_base_hp())
		debug_log.push(_format_alpha_probe_status(), "system")

	_refresh_screen()


func _on_reset_pressed() -> void:
	wave_timer.stop()
	hovered_tile = INVALID_TILE
	selected_tile = INVALID_TILE
	selected_card_index = -1
	selected_artifact_replacement_offer_id = ""
	selected_dormant_artifact_release_id = ""
	_clear_shop_reactivation_selection()
	build_mode = "none"
	_clear_preview()
	player_count = simulation.get_default_player_count() if simulation.is_loaded() else 1
	run_started = false
	_clear_autoplay_focus_queue()
	_clear_hand_ready_cue()
	_clear_discard_follow_up()
	_clear_combat_follow_up()
	confirmed_risk_ping_marker.clear()
	active_alpha_probe_entry.clear()
	last_alpha_coverage_result.clear()
	run_config_lock_snapshot.clear()
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
	var placement_recommendation = _active_front_recommendation_at(tile)

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
		var selected_card = simulation.get_card_data(selected_card_id)
		var boss_warning_log = _boss_warning_response_log_line(selected_card_id, selected_card, tile)
		var previous_combat_follow_up_key = last_combat_follow_up_report_key
		var play_result = simulation.play_card_at_tile(selected_card_id, tile, player_count, selected_class_id)
		if bool(play_result["ok"]):
			debug_log.push("Played %s at %s. Mana: %s." % [
				play_result["card_label"],
				_tile_text(tile),
				simulation.get_mana(),
			])
			if not boss_warning_log.is_empty():
				last_boss_warning_response_line = boss_warning_log
				debug_log.push(boss_warning_log, "combat")
			_push_recommendation_log(placement_recommendation)
			for event in play_result["events"]:
				debug_log.push(event)
			_clear_discard_follow_up()
			_clear_combat_follow_up()
			var combat_follow_up_line = _capture_combat_follow_up(previous_combat_follow_up_key)
			if not combat_follow_up_line.is_empty():
				debug_log.push(combat_follow_up_line, "system")
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
		_push_recommendation_log(placement_recommendation)
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
		var structure_threat = _active_structure_threat_report()
		var threat_tile_value = structure_threat.get("tile", INVALID_TILE)
		if typeof(threat_tile_value) == TYPE_VECTOR2I and threat_tile_value == tile:
			lines.append(str(structure_threat.get("summary", "")))

	if int(report["enemy_count"]) > 0:
		lines.append("Enemies: %s (%s)" % [report["enemy_count"], report["enemy_summary"]])
		var enemy_traits = str(report.get("enemy_traits", ""))
		if not enemy_traits.is_empty() and enemy_traits != "Standard":
			lines.append("Enemy traits: %s" % enemy_traits)

	var card_target = _selected_card_target_at(tile)
	if not card_target.is_empty():
		var card_target_text = "ok" if bool(card_target.get("valid", false)) else "blocked: %s" % card_target.get("reason", "unknown")
		lines.append("Card target: %s" % card_target_text)
		var boss_part_summary = str(card_target.get("boss_part_summary", ""))
		if not boss_part_summary.is_empty():
			lines.append(boss_part_summary)
	var recommendation = _active_front_recommendation_at(tile)
	if not recommendation.is_empty():
		var recommendation_label = "Recommended target" if bool(card_target.get("valid", false)) else "Recommended"
		lines.append("%s: %s" % [
			recommendation_label,
			recommendation.get("summary", "-"),
		])
		lines.append("Why: %s" % recommendation.get("why", "-"))
		var details = _recommendation_detail_text(recommendation)
		if not details.is_empty():
			lines.append("Details: %s" % details)

	var enemy_intent: Dictionary = report.get("enemy_intent", {})
	if not enemy_intent.is_empty():
		lines.append("Intent: %s" % enemy_intent.get("summary", "unknown"))

	var event = str(report["event"])
	if not event.is_empty():
		lines.append("Event: %s" % event)

	var boss_warning = _boss_warning_map_entry_at(tile)
	if not boss_warning.is_empty():
		lines.append("Boss warning: %s" % boss_warning.get("summary", "-"))
		var suggestion = str(boss_warning.get("suggestion", ""))
		if not suggestion.is_empty():
			lines.append("Response: %s" % suggestion)

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

	var report = _card_target_report(card_id, _run_player_count(), selected_class_id)
	if not bool(report.get("ok", false)):
		return {}

	return report.get("tiles", {})


func _card_target_report(card_id: String, target_player_count: int = -1, class_id: String = "") -> Dictionary:
	var resolved_player_count = _run_player_count() if target_player_count <= 0 else clamp(target_player_count, 1, 4)
	var resolved_class_id = selected_class_id if class_id.is_empty() else class_id
	var cache_key = "%s|%s|%s|%s|%s|%s|%s|%s|%s" % [
		card_id,
		resolved_player_count,
		resolved_class_id,
		simulation.get_mana(),
		simulation.wave_active,
		str(simulation.get_hand()),
		str(simulation.get_structure_tiles()),
		str(simulation.debug_get_enemies()),
		simulation.get_completed_rounds(),
	]
	if card_target_report_cache.has(cache_key):
		return card_target_report_cache[cache_key]

	var report = simulation.get_card_target_tiles(card_id, resolved_player_count, resolved_class_id)
	card_target_report_cache[cache_key] = report
	return report


func _active_front_recommendation_tiles() -> Dictionary:
	var structure_type = _active_recommendation_structure_type()
	if structure_type.is_empty():
		return {}

	return _front_recommendation_tiles_for_structure(structure_type)


func _visible_front_recommendation_tiles() -> Dictionary:
	var active_tiles = _active_front_recommendation_tiles()
	if not active_tiles.is_empty():
		return active_tiles

	return _setup_plan_preview_tiles()


func _setup_plan_preview_tiles() -> Dictionary:
	if build_mode != "none":
		return {}
	if not _selected_card_id().is_empty():
		return {}

	var report = _setup_plan_action_report()
	if not bool(report.get("ok", false)):
		return {}

	var tile: Vector2i = report.get("tile", INVALID_TILE)
	if not _is_valid_tile(tile):
		return {}

	var structure_type = str(report.get("structure_type", "structure"))
	var recommendation: Dictionary = report.get("recommendation", {})
	var summary = str(recommendation.get("summary", "%s setup target" % structure_type.capitalize()))
	var why = str(recommendation.get("why", "Setup plan will place %s here before the next wave." % structure_type.capitalize()))
	var details = []
	var detail_text = str(report.get("summary", ""))
	if not detail_text.is_empty():
		details.append(detail_text)

	return {
		_tile_key(tile): {
			"summary": "setup plan %s: %s" % [structure_type, summary],
			"why": why,
			"details": details,
			"setup_plan": true,
			"structure_type": structure_type,
		},
	}


func _boss_warning_map_entry_at(tile: Vector2i) -> Dictionary:
	return _boss_warning_map_tiles().get(_tile_key(tile), {})


func _boss_warning_map_tiles() -> Dictionary:
	var report = _active_boss_warning_report()
	if report.is_empty():
		return {}

	var tiles = {}
	var severity = str(report.get("severity", "warning"))
	var summary = str(report.get("summary", "Boss part warning"))
	var suggestion = str(report.get("suggestion", "answer the boss part warning"))
	var focus_label = str(report.get("focus_label", "part"))

	var boss_tile_value = report.get("tile", INVALID_TILE)
	if typeof(boss_tile_value) == TYPE_VECTOR2I and _is_valid_tile(boss_tile_value):
		var boss_tile: Vector2i = boss_tile_value
		tiles[_tile_key(boss_tile)] = {
			"kind": "focus",
			"label": "W",
			"severity": severity,
			"summary": "%s at %s: %s" % [focus_label, _tile_text(boss_tile), summary],
			"suggestion": suggestion,
		}

	var structure_tile = _boss_warning_structure_target_tile(report)
	if _is_valid_tile(structure_tile):
		tiles[_tile_key(structure_tile)] = {
			"kind": "structure",
			"label": "!",
			"severity": severity,
			"summary": "Threatened structure at %s: %s" % [_tile_text(structure_tile), summary],
			"suggestion": "repair or block before the boss pattern lands",
		}

	var delay_count = 0
	for delay_tile in _boss_warning_delay_candidates(report, "barricade"):
		if delay_count >= 4:
			break
		if not _is_valid_tile(delay_tile) or _enemy_occupies_tile(delay_tile):
			continue

		var place_check = simulation.can_place_structure(delay_tile, "barricade", player_count, selected_class_id)
		if not bool(place_check.get("ok", false)):
			continue

		var key = _tile_key(delay_tile)
		if tiles.has(key):
			continue

		tiles[key] = {
			"kind": "delay",
			"label": "D",
			"severity": severity,
			"summary": "Delay candidate at %s: place a barricade to buy time against the boss." % _tile_text(delay_tile),
			"suggestion": "place barricade if damage or repair is not available",
		}
		delay_count += 1

	return tiles


func _spawn_warning_map_tiles(active_player_count: int, active_directions: Array) -> Dictionary:
	if not simulation.is_loaded():
		return {}

	var timeline_report: Dictionary
	var row_limit = max(4, active_directions.size() * 2)
	if simulation.wave_active:
		timeline_report = simulation.get_active_wave_spawn_timeline_report(active_player_count, row_limit)
	else:
		timeline_report = simulation.get_wave_spawn_timeline_report(active_player_count, simulation.get_current_round(), row_limit)
	if not bool(timeline_report.get("ok", false)):
		return {}

	var active_direction_lookup = {}
	for direction_value in active_directions:
		active_direction_lookup[str(direction_value)] = true
	if active_direction_lookup.is_empty():
		return {}

	var entrances = simulation.get_entrances()
	var tiles = {}
	var rows: Array = timeline_report.get("rows", [])
	for row_index in range(rows.size()):
		var row_value = rows[row_index]
		if typeof(row_value) != TYPE_DICTIONARY:
			continue

		var row: Dictionary = row_value
		var status = str(row.get("status", ""))
		if status.is_empty():
			status = "next" if row_index == 0 else "queued"

		for direction in _string_values_from_array(row.get("directions", [])):
			if not active_direction_lookup.has(direction) or not entrances.has(direction):
				continue

			var coord_value = entrances.get(direction, [])
			if typeof(coord_value) != TYPE_ARRAY:
				continue

			var coord: Array = coord_value
			if coord.size() < 2:
				continue

			var tile = Vector2i(int(coord[0]), int(coord[1]))
			if not _is_valid_tile(tile):
				continue

			var key = _tile_key(tile)
			if tiles.has(key):
				continue

			tiles[key] = {
				"tile": tile,
				"direction": direction,
				"label": _spawn_warning_label_for_status(status),
				"status": status,
				"severity": _spawn_warning_severity(row, status),
				"summary": str(row.get("summary", "")),
				"enemyId": str(row.get("enemyId", "")),
				"enemyLabel": str(row.get("enemyLabel", "")),
				"enemyRole": str(row.get("enemyRole", "")),
				"directionRole": str(row.get("directionRole", "")),
				"firstSpawnTimeSeconds": float(row.get("firstSpawnTimeSeconds", 0.0)),
				"warningTimeSeconds": float(row.get("warningTimeSeconds", 0.0)),
				"sourceRound": int(row.get("sourceRound", row.get("round", simulation.get_current_round()))),
				"active": simulation.wave_active,
			}

	return tiles


func _spawn_warning_label_for_status(status: String) -> String:
	return ">" if status == "next" else "Q"


func _spawn_warning_severity(row: Dictionary, status: String) -> String:
	var enemy_role = str(row.get("enemyRole", ""))
	var direction_role = str(row.get("directionRole", ""))
	if enemy_role == "boss" or direction_role == "boss":
		return "boss"
	if status == "next":
		return "warning"
	if ["fast", "breaker", "siege"].has(direction_role) or ["fast", "breaker", "siege"].has(enemy_role):
		return "warning"
	return "notice"


func _front_recommendation_tiles_for_structure(structure_type: String) -> Dictionary:
	if structure_type.is_empty():
		return {}

	var report = simulation.get_front_recommendation_tiles(_run_player_count(), structure_type, selected_class_id)
	if not bool(report.get("ok", false)):
		return {}

	return report.get("tiles", {})


func _active_front_recommendation_summary() -> String:
	var structure_type = _active_recommendation_structure_type()
	if structure_type.is_empty():
		return ""

	return _front_recommendation_summary_for_structure(structure_type)


func _front_recommendation_summary_for_structure(structure_type: String) -> String:
	if structure_type.is_empty():
		return ""

	return simulation.get_front_recommendation_summary(_run_player_count(), structure_type, selected_class_id)


func _active_recommendation_structure_type() -> String:
	if ["tower", "barricade"].has(build_mode):
		return build_mode

	var card_id = _selected_card_id()
	if card_id.is_empty():
		return ""

	var card = simulation.get_card_data(card_id)
	if str(card.get("kind", "")) != "place_structure":
		return ""

	return str(card.get("structureType", ""))


func _card_button_tooltip(card_id: String, hand_index: int = -1, discard_report: Dictionary = {}) -> String:
	var card = simulation.get_card_data(card_id)
	if card.is_empty():
		return "Unknown card."

	var lines = PackedStringArray()
	lines.append("%s [%s] cost %s" % [
		card.get("label", card_id),
		simulation.get_card_rarity_label(card_id),
		card.get("cost", 0),
	])
	lines.append("Role: %s" % simulation.get_card_role(card_id))
	lines.append("Effect: %s" % simulation.get_card_effect_summary(card_id))

	if simulation.card_requires_tile(card_id):
		var target_report = _card_target_report(card_id, player_count, selected_class_id)
		lines.append("Targets: %s" % target_report.get("summary", "Targets unavailable."))
		var waiting_line = _card_waiting_hint_line(card_id, card, target_report)
		if not waiting_line.is_empty():
			lines.append(waiting_line)
		var boss_response_line = _card_boss_warning_tooltip_line(card_id, card)
		if not boss_response_line.is_empty():
			lines.append(boss_response_line)
		var spawn_response_line = _card_spawn_response_tooltip_line(card_id, card)
		if not spawn_response_line.is_empty():
			lines.append(spawn_response_line)
	else:
		var play_check = simulation.can_play_card(card_id, selected_class_id)
		lines.append("Play: %s" % ("ready" if bool(play_check.get("ok", false)) else play_check.get("reason", "blocked")))
		var spawn_response_line = _card_spawn_response_tooltip_line(card_id, card)
		if not spawn_response_line.is_empty():
			lines.append(spawn_response_line)

	var discard_hint = _card_discard_hint_line(hand_index, discard_report)
	if not discard_hint.is_empty():
		lines.append(discard_hint)

	return "\n".join(lines)


func _card_button_state_label(card_id: String, hand_index: int = -1, discard_report: Dictionary = {}) -> String:
	var state_label = ""
	if simulation.card_requires_tile(card_id):
		var card = simulation.get_card_data(card_id)
		var boss_response_label = _card_boss_warning_state_label(card_id, card)
		if not boss_response_label.is_empty():
			state_label = boss_response_label
			return _card_state_with_discard_marker(state_label, hand_index, discard_report)

		var target_report = _card_target_report(card_id, player_count, selected_class_id)
		if not bool(target_report.get("ok", false)):
			state_label = _short_block_reason(str(target_report.get("reason", "blocked")))
		elif int(target_report.get("valid_count", 0)) <= 0:
			state_label = _card_waiting_state_label(card_id, card, target_report)
		else:
			state_label = "Target"
		state_label = _card_state_with_spawn_marker(state_label, card_id, card)
		return _card_state_with_discard_marker(state_label, hand_index, discard_report)

	var play_check = simulation.can_play_card(card_id, selected_class_id)
	if bool(play_check.get("ok", false)):
		state_label = "Ready"
	else:
		state_label = _short_block_reason(str(play_check.get("reason", "blocked")))
	state_label = _card_state_with_spawn_marker(state_label, card_id, simulation.get_card_data(card_id))

	return _card_state_with_discard_marker(state_label, hand_index, discard_report)


func _card_state_with_spawn_marker(state_label: String, card_id: String, card: Dictionary) -> String:
	var spawn_line = _card_spawn_response_tooltip_line(card_id, card)
	if spawn_line.is_empty():
		return state_label

	return "%s | Spawn answer" % state_label


func _card_state_with_discard_marker(state_label: String, hand_index: int, discard_report: Dictionary) -> String:
	var marker = _card_discard_state_marker(hand_index, discard_report)
	if marker.is_empty():
		return state_label

	return "%s | %s" % [state_label, marker]


func _card_discard_state_marker(hand_index: int, discard_report: Dictionary) -> String:
	if not _discard_report_matches_hand_index(hand_index, discard_report):
		return ""
	if not bool(discard_report.get("suggested", false)):
		return ""

	return "Pressure pick" if str(discard_report.get("suggestion_kind", "")) == "pressure" else "Discard pick"


func _card_discard_hint_line(hand_index: int, discard_report: Dictionary) -> String:
	if not _discard_report_matches_hand_index(hand_index, discard_report):
		return ""
	if not bool(discard_report.get("suggested", false)):
		return ""

	var mana_gain = simulation.get_discard_mana_gain()
	if str(discard_report.get("suggestion_kind", "")) == "pressure":
		return "Pressure discard: opens 1 hand slot under Hand pressure and gains %s mana." % mana_gain
	return "Emergency discard: best current stuck-hand candidate; gains %s mana." % mana_gain


func _discard_report_matches_hand_index(hand_index: int, discard_report: Dictionary) -> bool:
	if hand_index < 0:
		return false
	if not bool(discard_report.get("ok", false)):
		return false

	return int(discard_report.get("card_index", -1)) == hand_index


func _clear_hand_ready_cue() -> void:
	last_hand_state_snapshot.clear()
	last_hand_ready_cue = ""


func _update_hand_ready_cue(hand: Array) -> void:
	if not simulation.is_loaded() or not run_started:
		_clear_hand_ready_cue()
		return

	var next_snapshot: Dictionary = {}
	var ready_labels = PackedStringArray()
	for index in range(hand.size()):
		var card_id = str(hand[index])
		var snapshot_key = "%s:%s" % [index, card_id]
		var state = _hand_plan_card_state(card_id)
		var previous_state = str(last_hand_state_snapshot.get(snapshot_key, "new"))
		next_snapshot[snapshot_key] = state
		if state == "ready" and _is_hand_ready_cue_previous_state(previous_state):
			ready_labels.append(_hand_ready_cue_card_label(card_id))

	last_hand_state_snapshot = next_snapshot
	last_hand_ready_cue = ""
	if ready_labels.is_empty():
		return

	last_hand_ready_cue = "Ready now: %s" % ", ".join(ready_labels)
	debug_log.push("Hand cue: %s." % last_hand_ready_cue, "system")


func _is_hand_ready_cue_previous_state(state: String) -> bool:
	return state == "waiting" or state == "no_mana" or state == "blocked"


func _hand_ready_cue_card_label(card_id: String) -> String:
	var card = simulation.get_card_data(card_id)
	return str(card.get("label", card_id))


func _hand_plan_summary() -> String:
	var report = _hand_plan_report()
	var parts = PackedStringArray()
	parts.append("%s ready" % report.get("ready_count", 0))
	parts.append("%s waiting" % report.get("waiting_count", 0))
	parts.append("%s no mana" % report.get("no_mana_count", 0))
	if int(report.get("blocked_count", 0)) > 0:
		parts.append("%s blocked" % report.get("blocked_count", 0))

	var plan_parts = PackedStringArray()
	plan_parts.append(", ".join(parts))
	if not last_hand_ready_cue.is_empty():
		plan_parts.append(last_hand_ready_cue)
	plan_parts.append(_hand_plan_best_text(report))

	return "Hand plan: %s" % " | ".join(plan_parts)


func _hand_plan_report() -> Dictionary:
	var report = {
		"ready_count": 0,
		"waiting_count": 0,
		"no_mana_count": 0,
		"blocked_count": 0,
	}

	if not simulation.is_loaded() or not run_started:
		report["blocked_count"] = 0
		return report

	for card_id_value in simulation.get_hand():
		var card_id = str(card_id_value)
		match _hand_plan_card_state(card_id):
			"ready":
				report["ready_count"] = int(report.get("ready_count", 0)) + 1
			"waiting":
				report["waiting_count"] = int(report.get("waiting_count", 0)) + 1
			"no_mana":
				report["no_mana_count"] = int(report.get("no_mana_count", 0)) + 1
			_:
				report["blocked_count"] = int(report.get("blocked_count", 0)) + 1

	return report


func _hand_plan_card_state(card_id: String) -> String:
	var card = simulation.get_card_data(card_id)
	if card.is_empty():
		return "blocked"

	if simulation.card_requires_tile(card_id):
		var target_report = _card_target_report(card_id, player_count, selected_class_id)
		if not bool(target_report.get("ok", false)):
			return "no_mana" if str(target_report.get("reason", "")) == "not_enough_mana" else "blocked"
		return "ready" if int(target_report.get("valid_count", 0)) > 0 else "waiting"

	var play_check = simulation.can_play_card(card_id, selected_class_id)
	if bool(play_check.get("ok", false)):
		return "ready"
	return "no_mana" if str(play_check.get("reason", "")) == "not_enough_mana" else "blocked"


func _hand_plan_best_text(report: Dictionary) -> String:
	var best_report = _best_hand_card_target_report()
	if bool(best_report.get("ok", false)):
		var label = str(best_report.get("label", best_report.get("card_id", "card")))
		var tile = best_report.get("tile", INVALID_TILE)
		if _is_valid_tile(tile):
			return "best %s at %s" % [label, _tile_text(tile)]
		return "best %s now" % label

	var reason = str(best_report.get("reason", "blocked"))
	if int(report.get("ready_count", 0)) <= 0 and int(report.get("no_mana_count", 0)) > 0:
		return "best wait for kill mana or discard"
	if int(report.get("ready_count", 0)) <= 0 and int(report.get("waiting_count", 0)) > 0:
		return "best wait for %s" % _hand_plan_waiting_target_text()
	if reason == "planned_collapse_preserved":
		return "best hold repair"
	if reason == "hand_empty":
		return "best draw next prep"
	return "best %s" % _short_block_reason(reason).to_lower()


func _card_waiting_state_label(card_id: String, card: Dictionary, target_report: Dictionary) -> String:
	match _card_waiting_key(card_id, card, target_report):
		"enemy":
			return "Wait enemy"
		"damage":
			return "Wait damage"
		"structure":
			return "Need structure"
		"build":
			return "No build tile"
		_:
			return "No target"


func _card_waiting_hint_line(card_id: String, card: Dictionary, target_report: Dictionary) -> String:
	if not bool(target_report.get("ok", false)) or int(target_report.get("valid_count", 0)) > 0:
		return ""

	match _card_waiting_key(card_id, card, target_report):
		"enemy":
			return "Wait: no enemy is targetable yet."
		"damage":
			return "Wait: repair works after a structure takes damage."
		"structure":
			return "Wait: place or expose a damaged structure first."
		"build":
			return "Wait: no legal build tile is available; clear path pressure or use another card."
		_:
			return "Wait: no valid target is available yet."


func _card_waiting_detail_text(card_id: String, card: Dictionary, target_report: Dictionary) -> String:
	match _card_waiting_key(card_id, card, target_report):
		"enemy":
			return "wait for an enemy target"
		"damage":
			return "wait for a damaged structure"
		"structure":
			return "need a damaged structure"
		"build":
			return "no legal build tile"
		_:
			return "wait for a valid target"


func _card_waiting_key(_card_id: String, card: Dictionary, target_report: Dictionary) -> String:
	match str(card.get("kind", "")):
		"damage_enemy":
			return "enemy"
		"repair_structure":
			var reason_counts: Dictionary = target_report.get("reason_counts", {})
			if int(reason_counts.get("structure_not_damaged", 0)) > 0:
				return "damage"
			return "structure"
		"place_structure":
			return "build"
		_:
			return "target"


func _hand_plan_waiting_target_text() -> String:
	var wait_keys = {}
	for card_id_value in simulation.get_hand():
		var card_id = str(card_id_value)
		var card = simulation.get_card_data(card_id)
		if card.is_empty() or not simulation.card_requires_tile(card_id):
			continue

		var target_report = _card_target_report(card_id, player_count, selected_class_id)
		if bool(target_report.get("ok", false)) and int(target_report.get("valid_count", 0)) <= 0:
			wait_keys[_card_waiting_key(card_id, card, target_report)] = true

	var labels = PackedStringArray()
	if wait_keys.has("enemy"):
		labels.append("enemy")
	if wait_keys.has("damage"):
		labels.append("damaged structure")
	if wait_keys.has("structure"):
		labels.append("structure")
	if wait_keys.has("build"):
		labels.append("legal build tile")
	if labels.is_empty():
		labels.append("a valid target")

	return " or ".join(labels)


func _discard_action_report() -> Dictionary:
	if not simulation.is_loaded():
		return _discard_action_reject("data_not_loaded", "Discard selected", "Data is not loaded.")
	if not run_started:
		return _discard_action_reject("run_not_started", "Discard selected", "Begin the run first.")
	if simulation.get_discard_charges() <= 0:
		return _discard_action_reject("discard_unavailable", "Discard unavailable", "No discard uses remain this round.")

	var selected_card_id = _selected_card_id()
	if not selected_card_id.is_empty():
		return _discard_card_action_report(selected_card_index, selected_card_id, false)

	var suggested_report = _suggested_discard_action_report()
	if bool(suggested_report.get("ok", false)) or _should_surface_discard_suggestion_reject(suggested_report):
		return suggested_report

	return _discard_action_reject(
		"no_card_selected",
		"Select discard card",
		"Choose a card first, or use playable cards before spending the emergency discard."
	)


func _should_surface_discard_suggestion_reject(suggested_report: Dictionary) -> bool:
	var reason = str(suggested_report.get("reason", ""))
	return reason == "playable_card_available" or reason == "no_pressure_discard_candidate"


func _suggested_discard_action_report() -> Dictionary:
	var plan_report = _hand_plan_report()
	var pressure_report = simulation.get_hand_pressure_report()
	if _hand_pressure_should_offer_discard(pressure_report):
		return _pressure_discard_action_report(pressure_report, plan_report)

	if int(plan_report.get("ready_count", 0)) > 0:
		return _discard_action_reject("playable_card_available", "Select discard card", "A hand card is ready; play or select a card before discarding.")
	if int(plan_report.get("no_mana_count", 0)) <= 0 and int(plan_report.get("blocked_count", 0)) <= 0:
		return _discard_action_reject("no_emergency_discard", "Select discard card", "No emergency discard suggestion is needed yet.")

	var candidate = _best_discard_candidate(["no_mana", "blocked"])
	if int(candidate.get("index", -1)) < 0:
		return _discard_action_reject("no_discard_candidate", "Select discard card", "No hand card is a good emergency discard candidate.")

	return _discard_card_action_report(
		int(candidate.get("index", -1)),
		str(candidate.get("card_id", "")),
		true,
		"emergency"
	)


func _hand_pressure_should_offer_discard(pressure_report: Dictionary) -> bool:
	if not bool(pressure_report.get("ok", false)):
		return false

	var state = str(pressure_report.get("state", "open"))
	return state == "draw_held" or state == "hand_full" or state == "near_full"


func _pressure_discard_action_report(pressure_report: Dictionary, plan_report: Dictionary) -> Dictionary:
	var pressure_summary = str(pressure_report.get("summary", "Hand pressure is high."))
	if int(plan_report.get("ready_count", 0)) > 0:
		return _discard_action_reject(
			"playable_card_available",
			"Play to open slot",
			"%s A hand card is ready; play it first, or select a specific card if you still want to discard." % pressure_summary
		)

	var candidate = _best_discard_candidate(["no_mana", "blocked", "waiting"])
	if int(candidate.get("index", -1)) < 0:
		return _discard_action_reject(
			"no_pressure_discard_candidate",
			"Select discard card",
			"%s Choose a card manually if you want to open a hand slot." % pressure_summary
		)

	var report = _discard_card_action_report(
		int(candidate.get("index", -1)),
		str(candidate.get("card_id", "")),
		true,
		"pressure"
	)
	var label = str(report.get("label", candidate.get("card_id", "card")))
	report["summary"] = "%s Pressure discard: send %s to discard, open 1 hand slot, and gain %s mana. Uses left: %s/%s." % [
		pressure_summary,
		label,
		simulation.get_discard_mana_gain(),
		simulation.get_discard_charges(),
		simulation.get_discard_charge_cap(),
	]
	return report


func _best_discard_candidate(allowed_states: Array) -> Dictionary:
	var hand = simulation.get_hand()
	var best_index = -1
	var best_score = -999999
	var best_state = ""
	for index in range(hand.size()):
		var card_id = str(hand[index])
		var state = _hand_plan_card_state(card_id)
		if not allowed_states.has(state):
			continue

		var score = _discard_candidate_score(card_id, state, index)
		if best_index < 0 or score > best_score:
			best_index = index
			best_score = score
			best_state = state

	if best_index < 0:
		return {
			"ok": false,
			"index": -1,
			"card_id": "",
			"state": "",
		}

	return {
		"ok": true,
		"index": best_index,
		"card_id": str(hand[best_index]),
		"state": best_state,
		"score": best_score,
	}


func _discard_candidate_score(card_id: String, state: String, index: int) -> int:
	var card = simulation.get_card_data(card_id)
	var score = 0
	match state:
		"no_mana":
			score += 400
		"blocked":
			score += 300
		"waiting":
			score += 250
		_:
			score += 100

	score += int(card.get("cost", 0)) * 25
	var priority_index = _class_hand_priority_index(card_id)
	if priority_index >= 0:
		score += priority_index * 8
	else:
		score += 60
	score += _duplicate_hand_count(card_id) * 15
	score -= index
	return score


func _duplicate_hand_count(card_id: String) -> int:
	var count = 0
	for hand_card_id in simulation.get_hand():
		if str(hand_card_id) == card_id:
			count += 1

	return max(0, count - 1)


func _discard_card_action_report(index: int, card_id: String, suggested: bool, suggestion_kind: String = "") -> Dictionary:
	var card = simulation.get_card_data(card_id)
	if card.is_empty():
		return _discard_action_reject("unknown_card", "Discard selected", "Selected card is missing.")

	var label = str(card.get("label", card_id))
	var mana_gain = simulation.get_discard_mana_gain()
	var action = "Discard"
	var reason_text = "Selected discard"
	if suggested:
		if suggestion_kind == "pressure":
			action = "Discard pressure"
			reason_text = "Pressure discard"
		else:
			action = "Discard suggested"
			reason_text = "Emergency discard"
	return {
		"ok": true,
		"reason": "ok",
		"card_id": card_id,
		"card_index": index,
		"label": label,
		"suggested": suggested,
		"suggestion_kind": suggestion_kind if suggested else "",
		"button_text": "%s: %s (+%s mana)" % [action, label, mana_gain],
		"summary": "%s: send %s to discard and gain %s mana. Uses left: %s/%s." % [
			reason_text,
			label,
			mana_gain,
			simulation.get_discard_charges(),
			simulation.get_discard_charge_cap(),
		],
	}


func _discard_action_reject(reason: String, button_text: String, summary: String) -> Dictionary:
	return {
		"ok": false,
		"reason": reason,
		"button_text": button_text,
		"summary": summary,
		"card_id": "",
		"card_index": -1,
		"suggested": false,
		"suggestion_kind": "",
	}


func _short_block_reason(reason: String) -> String:
	match reason:
		"not_enough_mana":
			return "No mana"
		"not_enough_gold":
			return "No gold"
		"not_enough_boss_shards":
			return "No boss shard"
		"reward_choice_pending":
			return "Resolve reward"
		"shop_purchase_unavailable":
			return "Purchase used"
		"shop_vote_active", "shop_vote_already_active":
			return "Vote open"
		"shop_vote_player_count_changed":
			return "Players changed"
		"base_full":
			return "Base full"
		"no_structures":
			return "No structures"
		"no_dormant_artifact":
			return "No dormant"
		"reactivation_dormant_target_required", "artifact_not_dormant":
			return "Choose dormant"
		"reactivation_swap_target_required", "artifact_not_equipped":
			return "Choose swap"
		"artifact_replacement_not_required":
			return "No swap needed"
		"artifact_action_unavailable":
			return "Action used"
		"shop_service_disabled":
			return "Disabled"
		"unknown_shop_service":
			return "Unknown service"
		"unknown_shop_service_type":
			return "Unknown service"
		"card_not_in_hand":
			return "Not held"
		"hand_full":
			return "Hand full"
		"no_cards_to_draw":
			return "No draw"
		"card_requires_tile":
			return "Target"
		_:
			return reason.capitalize().replace("_", " ")


func _selected_card_status_text(card_id: String) -> String:
	var card = simulation.get_card_data(card_id)
	if card.is_empty():
		return "Selected card: unknown"

	var lines = PackedStringArray()
	lines.append("Selected card: %s [%s] cost %s" % [
		card.get("label", card_id),
		simulation.get_card_rarity_label(card_id),
		card.get("cost", 0),
	])
	lines.append("Role: %s | %s" % [
		simulation.get_card_role(card_id),
		simulation.get_card_effect_summary(card_id),
	])

	if simulation.card_requires_tile(card_id):
		var target_report = _card_target_report(card_id, player_count, selected_class_id)
		if not bool(target_report.get("ok", false)):
			lines.append("State: blocked: %s" % _short_block_reason(str(target_report.get("reason", "blocked"))))
		elif int(target_report.get("valid_count", 0)) <= 0:
			lines.append("State: %s" % _card_waiting_detail_text(card_id, card, target_report))
		else:
			lines.append("State: choose a highlighted tile")
		lines.append("Targets: %s" % target_report.get("summary", "Targets unavailable."))
		var waiting_line = _card_waiting_hint_line(card_id, card, target_report)
		if not waiting_line.is_empty():
			lines.append(waiting_line)
		var boss_response_line = _card_boss_warning_tooltip_line(card_id, card)
		if not boss_response_line.is_empty():
			lines.append(boss_response_line)
		var timing_line = _selected_card_timing_line(card_id)
		if not timing_line.is_empty():
			lines.append(timing_line)
		var recommendation_summary = _active_front_recommendation_summary()
		if not recommendation_summary.is_empty():
			lines.append(recommendation_summary)
	else:
		var play_check = simulation.can_play_card(card_id, selected_class_id)
		lines.append("State: %s" % ("ready to play" if bool(play_check.get("ok", false)) else "blocked: %s" % play_check.get("reason", "unknown")))

	lines.append(_selected_card_discard_status_line())
	return "\n".join(lines)


func _selected_card_discard_status_line() -> String:
	var suggested_report = _suggested_discard_action_report()
	if _discard_report_matches_hand_index(selected_card_index, suggested_report):
		var mana_gain = simulation.get_discard_mana_gain()
		if str(suggested_report.get("suggestion_kind", "")) == "pressure":
			return "Discard: pressure pick; opens 1 hand slot under Hand pressure and gains %s mana." % mana_gain
		return "Discard: emergency pick; best current stuck-hand candidate and gains %s mana." % mana_gain

	if simulation.get_discard_charges() <= 0:
		return "Discard: no use left this round."

	return "Discard: selected card can be discarded for %s mana. Uses left: %s/%s." % [
		simulation.get_discard_mana_gain(),
		simulation.get_discard_charges(),
		simulation.get_discard_charge_cap(),
	]


func _capture_discard_follow_up(result: Dictionary) -> String:
	_clear_discard_follow_up()
	var mana_gain = int(result.get("mana_gain", simulation.get_discard_mana_gain()))
	var ready_labels = _ready_hand_card_labels(3)
	if not ready_labels.is_empty():
		var best_report = _best_hand_card_target_report()
		if _best_report_is_hand_card_action(best_report):
			last_discard_follow_up_card_id = str(best_report.get("card_id", ""))
			last_discard_follow_up_card_index = int(best_report.get("card_index", -1))
		last_discard_follow_up_summary = "Discard follow-up: %s now ready after +%s mana; %s." % [
			", ".join(ready_labels),
			mana_gain,
			_hand_plan_best_text(_hand_plan_report()),
		]
		return last_discard_follow_up_summary

	var hand = simulation.get_hand()
	if hand.is_empty():
		last_discard_follow_up_summary = "Discard follow-up: +%s mana; hand is empty until the next draw." % mana_gain
		return last_discard_follow_up_summary

	var plan_report = _hand_plan_report()
	if int(plan_report.get("waiting_count", 0)) > 0:
		last_discard_follow_up_summary = "Discard follow-up: +%s mana; no card ready yet, wait for %s." % [
			mana_gain,
			_hand_plan_waiting_target_text(),
		]
		return last_discard_follow_up_summary
	if int(plan_report.get("no_mana_count", 0)) > 0:
		last_discard_follow_up_summary = "Discard follow-up: +%s mana; %s card(s) still need more mana." % [
			mana_gain,
			plan_report.get("no_mana_count", 0),
		]
		return last_discard_follow_up_summary

	last_discard_follow_up_summary = "Discard follow-up: +%s mana; no immediate hand action opened." % mana_gain
	return last_discard_follow_up_summary


func _clear_discard_follow_up() -> void:
	last_discard_follow_up_card_id = ""
	last_discard_follow_up_card_index = -1
	last_discard_follow_up_summary = ""


func _capture_combat_follow_up(previous_report_key: String = "") -> String:
	var report = simulation.get_last_kill_resource_report()
	if not bool(report.get("ok", false)):
		return ""

	var report_key = _combat_follow_up_report_key(report)
	if report_key.is_empty() or report_key == previous_report_key:
		return ""

	_clear_combat_follow_up()
	last_combat_follow_up_report_key = report_key
	if not _combat_follow_up_has_actionable_gain(report):
		return ""

	var gain_text = _combat_follow_up_gain_text(report)
	var ready_labels = _ready_hand_card_labels(3)
	if not ready_labels.is_empty():
		var best_report = _best_hand_card_target_report()
		if _best_report_is_hand_card_action(best_report):
			last_combat_follow_up_card_id = str(best_report.get("card_id", ""))
			last_combat_follow_up_card_index = int(best_report.get("card_index", -1))
		last_combat_follow_up_summary = "Combat follow-up: %s now ready after %s; %s." % [
			", ".join(ready_labels),
			gain_text,
			_hand_plan_best_text(_hand_plan_report()),
		]
		return last_combat_follow_up_summary

	var hand = simulation.get_hand()
	if hand.is_empty():
		last_combat_follow_up_summary = "Combat follow-up: %s; hand is empty until the next draw." % gain_text
		return last_combat_follow_up_summary

	var plan_report = _hand_plan_report()
	if int(plan_report.get("waiting_count", 0)) > 0:
		last_combat_follow_up_summary = "Combat follow-up: %s; no card ready yet, wait for %s." % [
			gain_text,
			_hand_plan_waiting_target_text(),
		]
		return last_combat_follow_up_summary
	if int(plan_report.get("no_mana_count", 0)) > 0:
		last_combat_follow_up_summary = "Combat follow-up: %s; %s card(s) still need more mana." % [
			gain_text,
			plan_report.get("no_mana_count", 0),
		]
		return last_combat_follow_up_summary

	last_combat_follow_up_summary = "Combat follow-up: %s; no immediate hand action opened." % gain_text
	return last_combat_follow_up_summary


func _clear_combat_follow_up() -> void:
	last_combat_follow_up_card_id = ""
	last_combat_follow_up_card_index = -1
	last_combat_follow_up_summary = ""
	last_combat_follow_up_report_key = ""


func _combat_follow_up_report_key(report: Dictionary) -> String:
	if not bool(report.get("ok", false)):
		return ""

	return "%s|%s|%s|%s|%s|%s|%s|%s" % [
		report.get("enemy_label", ""),
		report.get("mana_before", 0),
		report.get("mana_after", 0),
		report.get("gold_after", 0),
		report.get("draw_gauge_after", 0),
		report.get("hand_after", 0),
		report.get("draw_count_after", 0),
		report.get("discard_count_after", 0),
	]


func _combat_follow_up_has_actionable_gain(report: Dictionary) -> bool:
	if int(report.get("mana_gain", 0)) > 0:
		return true
	if int(report.get("drawn_count", 0)) > 0:
		return true
	return not str(report.get("draw_held_reason", "")).is_empty()


func _combat_follow_up_gain_text(report: Dictionary) -> String:
	var parts = PackedStringArray()
	if int(report.get("mana_gain", 0)) > 0:
		parts.append("+%s mana" % report.get("mana_gain", 0))
	if int(report.get("drawn_count", 0)) > 0:
		var labels: Array = report.get("drawn_labels", [])
		if labels.is_empty():
			parts.append("+%s card" % report.get("drawn_count", 0))
		else:
			var drawn_labels = PackedStringArray()
			for label in labels:
				drawn_labels.append(str(label))
			parts.append("drew %s" % ", ".join(drawn_labels))
	if not str(report.get("draw_held_reason", "")).is_empty():
		parts.append("draw held")
	if parts.is_empty():
		parts.append("combat gains")

	return " and ".join(parts)


func _best_target_report_with_discard_follow_up(report: Dictionary) -> Dictionary:
	if not _best_target_matches_discard_follow_up(report):
		return report

	var decorated = report.duplicate(true)
	decorated["button_text"] = "Follow-up: %s" % report.get("button_text", "Use best target")
	decorated["summary"] = "%s %s" % [
		report.get("summary", ""),
		last_discard_follow_up_summary,
	]
	return decorated


func _best_target_report_with_combat_follow_up(report: Dictionary) -> Dictionary:
	if str(report.get("button_text", "")).begins_with("Follow-up"):
		return report
	if not _best_target_matches_combat_follow_up(report):
		return report

	var decorated = report.duplicate(true)
	decorated["button_text"] = "Combat follow-up: %s" % report.get("button_text", "Use best target")
	decorated["summary"] = "%s %s" % [
		report.get("summary", ""),
		last_combat_follow_up_summary,
	]
	return decorated


func _best_target_matches_discard_follow_up(report: Dictionary) -> bool:
	if last_discard_follow_up_card_id.is_empty():
		return false
	if not bool(report.get("ok", false)):
		return false
	if not _best_report_is_hand_card_action(report):
		return false
	if int(report.get("card_index", -1)) != last_discard_follow_up_card_index:
		return false

	return str(report.get("card_id", "")) == last_discard_follow_up_card_id


func _best_target_matches_combat_follow_up(report: Dictionary) -> bool:
	if last_combat_follow_up_card_id.is_empty():
		return false
	if not bool(report.get("ok", false)):
		return false
	if not _best_report_is_hand_card_action(report):
		return false
	if int(report.get("card_index", -1)) != last_combat_follow_up_card_index:
		return false

	return str(report.get("card_id", "")) == last_combat_follow_up_card_id


func _best_report_is_hand_card_action(report: Dictionary) -> bool:
	var intent = str(report.get("intent", ""))
	return intent == "card" or intent == "direct_card"


func _ready_hand_card_labels(limit: int) -> PackedStringArray:
	var labels = PackedStringArray()
	var seen = {}
	for card_id_value in simulation.get_hand():
		var card_id = str(card_id_value)
		if _hand_plan_card_state(card_id) != "ready":
			continue

		var card = simulation.get_card_data(card_id)
		var label = str(card.get("label", card_id))
		if seen.has(label):
			continue

		seen[label] = true
		labels.append(label)
		if labels.size() >= limit:
			break

	return labels


func _card_boss_warning_state_label(card_id: String, card: Dictionary) -> String:
	var report = _card_boss_warning_action_report(card_id, card)
	if report.is_empty():
		return ""

	return str(report.get("label", "Boss answer"))


func _card_boss_warning_tooltip_line(card_id: String, card: Dictionary) -> String:
	var report = _card_boss_warning_action_report(card_id, card)
	if report.is_empty():
		return ""

	return "Boss response: %s at %s - %s" % [
		report.get("label", "Boss answer"),
		_tile_text(report.get("tile", INVALID_TILE)),
		report.get("suggestion", "answer the boss warning"),
	]


func _card_boss_warning_action_report(card_id: String, card: Dictionary) -> Dictionary:
	if card.is_empty():
		return {}

	var warning_report = _active_boss_warning_report()
	if warning_report.is_empty():
		return {}

	var tile = _boss_warning_card_tile(card_id, card)
	if not _is_valid_tile(tile):
		return {}

	return {
		"ok": true,
		"label": _card_boss_warning_action_label(card),
		"tile": tile,
		"suggestion": warning_report.get("suggestion", "answer the boss warning"),
	}


func _card_boss_warning_action_label(card: Dictionary) -> String:
	match str(card.get("kind", "")):
		"damage_enemy":
			return "Boss answer"
		"repair_structure":
			return "Repair target"
		"place_structure":
			if str(card.get("structureType", "")) == "barricade":
				return "Delay option"
			return "Boss setup"
		_:
			return "Boss answer"


func _boss_warning_response_log_line(card_id: String, card: Dictionary, tile: Vector2i) -> String:
	if card.is_empty() or not _card_tile_answers_boss_warning(card, tile):
		return ""

	var report = _active_boss_warning_report()
	if report.is_empty():
		return ""

	var focus_label = str(report.get("focus_label", "part"))
	var danger_label = str(report.get("danger_label", focus_label))
	var part_text = focus_label
	if not danger_label.is_empty() and danger_label != focus_label:
		part_text = "%s opens %s" % [focus_label, danger_label]

	return "Boss warning response: %s -> %s at %s. %s. %s" % [
		card.get("label", card_id),
		_card_boss_warning_action_label(card),
		_tile_text(tile),
		part_text,
		report.get("suggestion", "answer the boss warning"),
	]


func _selected_card_timing_line(card_id: String) -> String:
	var card = simulation.get_card_data(card_id)
	if card.is_empty():
		return ""

	match str(card.get("kind", "")):
		"repair_structure":
			return _repair_card_timing_line(card_id)
		_:
			return ""


func _repair_card_timing_line(card_id: String) -> String:
	if not simulation.wave_active:
		var prep_target_report = _card_target_report(card_id, player_count, selected_class_id)
		if int(prep_target_report.get("valid_count", 0)) > 0:
			var prep_tile = _best_tile_from_card_target_report(prep_target_report)
			if _is_valid_tile(prep_tile):
				return "Timing: repair damaged structure at %s before starting." % _tile_text(prep_tile)
		return "Timing: wait until a structure is damaged."

	var boss_warning_tile = _boss_warning_card_tile(card_id, simulation.get_card_data(card_id))
	if _is_valid_tile(boss_warning_tile):
		var boss_warning = _active_boss_warning_report()
		return "Timing: repair boss warning target at %s; %s." % [
			_tile_text(boss_warning_tile),
			boss_warning.get("suggestion", "protect the threatened structure"),
		]

	var tactical_report = simulation.get_wave_tactical_report(player_count, selected_class_id)
	var threat: Dictionary = tactical_report.get("threat", {})
	var action = str(threat.get("action", ""))
	var structure_threat = _active_structure_threat_report()
	if ["attack_structure", "boss_siege"].has(action):
		var threat_tile: Vector2i = threat.get("tile", INVALID_TILE)
		var play_check = simulation.can_play_card_at_tile(card_id, threat_tile, player_count, selected_class_id)
		if bool(play_check.get("ok", false)):
			if bool(structure_threat.get("planned_collapse", false)):
				return "Timing: optional at %s; repair prevents planned collapse damage." % _tile_text(threat_tile)
			if bool(structure_threat.get("will_break", false)):
				return "Timing: repair now at %s; next hit would break it." % _tile_text(threat_tile)
			return "Timing: repair now at %s; current threat is targeting it." % _tile_text(threat_tile)
		if str(play_check.get("reason", "")) == "structure_not_damaged":
			if bool(structure_threat.get("planned_collapse", false)):
				return "Timing: cannot pre-repair full structure at %s; next hit creates planned collapse damage." % _tile_text(threat_tile)
			if bool(structure_threat.get("will_break", false)):
				return "Timing: cannot pre-repair full structure at %s; block with damage/control or replace after." % _tile_text(threat_tile)
			return "Timing: hold until after hit at %s; repair only works on damaged structures." % _tile_text(threat_tile)

	var tactical_tile = _best_tactical_card_tile(card_id, simulation.get_card_data(card_id))
	if _is_valid_tile(tactical_tile):
		return "Timing: repair current threat at %s." % _tile_text(tactical_tile)

	var fallback_target_report = _card_target_report(card_id, player_count, selected_class_id)
	if int(fallback_target_report.get("valid_count", 0)) > 0:
		var fallback_tile = _best_tile_from_card_target_report(fallback_target_report)
		if _is_valid_tile(fallback_tile):
			return "Timing: repair damaged structure at %s." % _tile_text(fallback_tile)

	return "Timing: no damaged structure yet; hold this card."


func _reward_button_text(report: Dictionary) -> String:
	var prefix = "Suggested Take" if bool(report.get("recommended", false)) else "Take"
	return "%s %s [%s] - %s\n%s\nDeck copies: %s -> %s" % [
		prefix,
		report.get("label", report.get("card_id", "?")),
		report.get("rarity_label", "Common"),
		report.get("role", "Card"),
		report.get("effect", ""),
		report.get("deck_count", 0),
		int(report.get("deck_count", 0)) + 1,
	]


func _reward_button_tooltip(report: Dictionary) -> String:
	var recommendation_text = ""
	if bool(report.get("recommended", false)):
		recommendation_text = " | Suggested: %s" % report.get("recommendation_reason", "best current pick")
		var recommendation_detail = str(report.get("recommendation_detail", ""))
		if not recommendation_detail.is_empty():
			recommendation_text += " | Why now: %s" % recommendation_detail
		var rewrite_preset = str(report.get("recommendation_rewrite_preset", ""))
		if not rewrite_preset.is_empty():
			recommendation_text += " | Discussion prompt: %s" % rewrite_preset
	return "Take: %s | unlock %s | %s | %s%s" % [
		report.get("claim_preview", "Adds 1 copy to discard pile."),
		report.get("unlock", "R1+"),
		report.get("deck_zone_summary", ""),
		report.get("summary", ""),
		recommendation_text,
	]


func _artifact_button_text(report: Dictionary) -> String:
	var action = "Suggested Equip" if bool(report.get("recommended", false)) else "Equip"
	if bool(report.get("requires_replacement", false)):
		action = "Suggested Replace" if bool(report.get("recommended", false)) else "Replace Needed"
	if not bool(report.get("can_claim", true)):
		action = _short_block_reason(str(report.get("reason", "blocked")))
	return "%s %s - %s\nParty passive: %s\nAction: %s -> %s" % [
		action,
		report.get("label", report.get("artifact_id", "?")),
		"Equipped" if bool(report.get("equipped", false)) else "New",
		report.get("effect", ""),
		report.get("artifact_actions_remaining", simulation.get_artifact_actions_remaining()),
		report.get("artifact_actions_after", report.get("artifact_actions_remaining", simulation.get_artifact_actions_remaining())),
	]


func _artifact_button_tooltip(report: Dictionary) -> String:
	var recommendation_text = ""
	if bool(report.get("recommended", false)):
		recommendation_text = " | Suggested: %s" % report.get("recommendation_reason", "best party passive")
		var recommendation_detail = str(report.get("recommendation_detail", ""))
		if not recommendation_detail.is_empty():
			recommendation_text += " | Why now: %s" % recommendation_detail
		var rewrite_preset = str(report.get("recommendation_rewrite_preset", ""))
		if not rewrite_preset.is_empty():
			recommendation_text += " | Discussion prompt: %s" % rewrite_preset
	var replace_text = ""
	if bool(report.get("requires_replacement", false)):
		replace_text = " | Slot full: choose which equipped artifact becomes dormant, or keep current."
	return "Equip: party passive | Action %s/%s | %s | %s%s%s" % [
		report.get("artifact_actions_remaining", simulation.get_artifact_actions_remaining()),
		report.get("artifact_action_limit", simulation.get_artifact_action_limit()),
		report.get("loadout_summary", "equipped %s" % report.get("equipped_count", 0)),
		report.get("summary", ""),
		recommendation_text,
		replace_text,
	]


func _shop_button_text(report: Dictionary) -> String:
	if str(report.get("shop_option_type", "remove_card")) == "service":
		var service_state = "Ready" if bool(report.get("can_buy", false)) else _short_block_reason(str(report.get("reason", "blocked")))
		var service_action = "Suggested Buy" if bool(report.get("recommended", false)) else "Buy"
		if bool(report.get("shop_vote_active", false)):
			service_state = "Vote %s/%s" % [
				report.get("shop_vote_approvals", 0),
				report.get("shop_vote_required", simulation.get_shop_purchase_required_votes(player_count)),
			]
			service_action = "Approve Buy"
		if str(report.get("service_type", "")) == "reactivate_dormant_artifact":
			return "%s %s - %s\n%s\nBoss shards: %s -> %s | Action: %s -> %s" % [
				service_action,
				report.get("label", report.get("service_id", "?")),
				service_state,
				report.get("effect", ""),
				report.get("boss_shards", 0),
				report.get("boss_shards_after", report.get("boss_shards", 0)),
				report.get("artifact_actions_remaining", simulation.get_artifact_actions_remaining()),
				report.get("artifact_actions_after", report.get("artifact_actions_remaining", simulation.get_artifact_actions_remaining())),
			]

		return "%s %s - %s\n%s\nGold: %s -> %s" % [
			service_action,
			report.get("label", report.get("service_id", "?")),
			service_state,
			report.get("effect", ""),
			report.get("gold", 0),
			report.get("gold_after", report.get("gold", 0)),
		]

	var state = "Ready" if bool(report.get("can_remove", false)) else _short_block_reason(str(report.get("reason", "blocked")))
	var action = "Suggested Remove" if bool(report.get("recommended", false)) else "Remove"
	if bool(report.get("shop_vote_active", false)):
		state = "Vote %s/%s" % [
			report.get("shop_vote_approvals", 0),
			report.get("shop_vote_required", simulation.get_shop_purchase_required_votes(player_count)),
		]
		action = "Approve Remove"
	return "%s %s [%s] - %s\n%s\nCopies: %s -> %s | Gold: %s -> %s" % [
		action,
		report.get("label", report.get("card_id", "?")),
		report.get("rarity_label", "Common"),
		state,
		report.get("effect", ""),
		report.get("deck_count", 0),
		report.get("deck_count_after", 0),
		report.get("gold", 0),
		report.get("gold_after", report.get("gold", 0)),
	]


func _shop_button_tooltip(report: Dictionary) -> String:
	var vote_text = ""
	if bool(report.get("shop_vote_active", false)):
		vote_text = " | Active vote: %s" % report.get("shop_vote_summary", simulation.get_shop_purchase_vote_summary(player_count))
	elif bool(report.get("shop_vote_blocked", false)):
		vote_text = " | Another shop vote is open: %s" % report.get("shop_vote_summary", simulation.get_shop_purchase_vote_summary(player_count))

	if str(report.get("shop_option_type", "remove_card")) == "service":
		var service_state = "Ready" if bool(report.get("can_buy", false)) else "Blocked: %s" % _short_block_reason(str(report.get("reason", "blocked")))
		var service_recommendation_text = ""
		if bool(report.get("recommended", false)):
			service_recommendation_text = " | Suggested: %s" % report.get("recommendation_reason", "strongest service")
			var service_recommendation_detail = str(report.get("recommendation_detail", ""))
			if not service_recommendation_detail.is_empty():
				service_recommendation_text += " | Why now: %s" % service_recommendation_detail
			var service_rewrite_preset = str(report.get("recommendation_rewrite_preset", ""))
			if not service_rewrite_preset.is_empty():
				service_recommendation_text += " | Discussion prompt: %s" % service_rewrite_preset
		return "%s | Service | %s | %s%s%s" % [
			service_state,
			report.get("effect", ""),
			report.get("purchase_preview", ""),
			service_recommendation_text,
			vote_text,
		]

	var state = "Ready" if bool(report.get("can_remove", false)) else "Blocked: %s" % _short_block_reason(str(report.get("reason", "blocked")))
	var recommendation_text = ""
	if bool(report.get("recommended", false)):
		recommendation_text = " | Suggested: %s" % report.get("recommendation_reason", "least costly trim")
		var recommendation_detail = str(report.get("recommendation_detail", ""))
		if not recommendation_detail.is_empty():
			recommendation_text += " | Why now: %s" % recommendation_detail
		var rewrite_preset = str(report.get("recommendation_rewrite_preset", ""))
		if not rewrite_preset.is_empty():
			recommendation_text += " | Discussion prompt: %s" % rewrite_preset
	return "%s | %s | %s | %s%s%s" % [
		state,
		report.get("role", "Card"),
		report.get("deck_zone_summary", ""),
		report.get("removal_preview", ""),
		recommendation_text,
		vote_text,
	]


func _best_target_action_report() -> Dictionary:
	if not simulation.is_loaded():
		return _best_target_reject("data_not_loaded", "Use best target", "Data is not loaded.")
	if not run_started:
		return _best_target_reject("run_not_started", "Use best target", "Begin the run first.")
	if simulation.has_pending_reward():
		return _best_target_reject("reward_pending", "Resolve reward", "Claim or skip the pending reward first.")
	if simulation.is_run_complete():
		return _best_target_reject("run_complete", "Run complete", simulation.get_run_outcome_summary(player_count))

	var selected_card_id = _selected_card_id()
	if not selected_card_id.is_empty():
		return _best_card_target_report(selected_card_id)

	if ["tower", "barricade"].has(build_mode):
		return _best_build_target_report(build_mode)
	if build_mode == "remove":
		return _best_target_reject("manual_remove", "Choose structure", "Pick the structure to remove manually.")

	return _best_hand_card_target_report()


func _best_hand_card_target_report() -> Dictionary:
	var hand = simulation.get_hand()
	if hand.is_empty():
		return _best_target_reject("hand_empty", "No hand card", "No card is currently available.")

	var best_report = {}
	var best_score = -999999
	var planned_collapse_reject = {}
	for index in range(hand.size()):
		var card_id = str(hand[index])
		var report = _best_hand_card_report_for_index(index, card_id)
		if not bool(report.get("ok", false)):
			if str(report.get("reason", "")) == "planned_collapse_preserved" and planned_collapse_reject.is_empty():
				planned_collapse_reject = report
			continue

		var score = int(report.get("score", 0))
		if best_report.is_empty() or score > best_score:
			best_report = report
			best_score = score

	if best_report.is_empty():
		if not planned_collapse_reject.is_empty():
			return planned_collapse_reject
		return _best_target_reject("no_playable_hand_card", "No quick card", "No hand card has a valid quick target.")

	return best_report


func _best_hand_card_report_for_index(index: int, card_id: String) -> Dictionary:
	var card = simulation.get_card_data(card_id)
	if card.is_empty():
		return _best_target_reject("unknown_card", "Use best target", "Hand card is missing.")

	if not simulation.card_requires_tile(card_id):
		var play_check = simulation.can_play_card(card_id, selected_class_id)
		if not bool(play_check.get("ok", false)):
			return _best_target_reject(str(play_check.get("reason", "blocked")), "No quick card", "%s is blocked." % card.get("label", card_id))

		var score = _best_hand_card_score(card_id, card, INVALID_TILE, false, false, index)
		var spawn_suffix = _spawn_response_hand_summary_suffix(card, INVALID_TILE)
		return {
			"ok": true,
			"reason": "ok",
			"intent": "direct_card",
			"card_id": card_id,
			"card_index": index,
			"tile": INVALID_TILE,
			"label": card.get("label", card_id),
			"button_text": "Play %s" % card.get("label", card_id),
			"summary": "Suggested hand action: play %s now. %s%s" % [
				card.get("label", card_id),
				simulation.get_card_effect_summary(card_id),
				spawn_suffix,
			],
			"score": score,
		}

	var target_report = _card_target_report(card_id, player_count, selected_class_id)
	if not bool(target_report.get("ok", false)) or int(target_report.get("valid_count", 0)) <= 0:
		return _best_target_reject(str(target_report.get("reason", "blocked")), "No quick card", str(target_report.get("summary", "No valid target.")))

	var tactical_tile = _best_tactical_card_tile(card_id, card)
	var spawn_response_tile = _best_spawn_response_card_tile(card_id, card, target_report)
	var tile = tactical_tile if _is_valid_tile(tactical_tile) else spawn_response_tile
	if not _is_valid_tile(tile):
		tile = _best_hand_card_tile(card_id, card, target_report)
	if not _is_valid_tile(tile):
		return _best_target_reject("no_valid_target", "No quick card", str(target_report.get("summary", "No valid target.")))
	if _quick_hand_card_would_prevent_planned_collapse(card, tile):
		var structure_threat = _active_structure_threat_report()
		var reject = _best_target_reject(
			"planned_collapse_preserved",
			"Hold repair",
			"Hold %s: planned collapse at %s is worth %s area damage." % [
				card.get("label", card_id),
				_tile_text(tile),
				structure_threat.get("collapse_damage", 0),
			]
		)
		reject["card_id"] = card_id
		reject["card_index"] = index
		reject["tile"] = tile
		return reject

	var play_check = simulation.can_play_card_at_tile(card_id, tile, player_count, selected_class_id)
	if not bool(play_check.get("ok", false)):
		return _best_target_reject(str(play_check.get("reason", "blocked")), "No quick card", "Suggested %s target is blocked." % card.get("label", card_id))

	var recommended = _hand_card_tile_is_front_recommended(card, tile)
	var tactical = _is_valid_tile(tactical_tile) and tactical_tile == tile
	var score = _best_hand_card_score(card_id, card, tile, recommended, tactical, index)
	var spawn_suffix = _spawn_response_hand_summary_suffix(card, tile)
	return {
		"ok": true,
		"reason": "ok",
		"intent": "card",
		"card_id": card_id,
		"card_index": index,
		"tile": tile,
		"label": card.get("label", card_id),
		"button_text": "Use %s at %s" % [
			card.get("label", card_id),
			_tile_text(tile),
		],
		"summary": "Suggested hand action: use %s at %s. %s%s%s%s" % [
			card.get("label", card_id),
			_tile_text(tile),
			target_report.get("summary", ""),
			_boss_focus_target_suffix(tile),
			_boss_warning_target_suffix(card, tile),
			spawn_suffix,
		],
		"score": score,
		"tactical": tactical,
	}


func _boss_focus_target_suffix(tile: Vector2i) -> String:
	if not _is_valid_tile(tile):
		return ""

	var summary = simulation.get_boss_focus_part_summary(tile)
	if summary.is_empty() or summary.ends_with("none"):
		return ""

	return " %s" % summary


func _boss_warning_target_suffix(card: Dictionary, tile: Vector2i) -> String:
	if not _card_tile_answers_boss_warning(card, tile):
		return ""

	var report = _active_boss_warning_report()
	var suggestion = str(report.get("suggestion", "answer the boss part warning"))
	return " Boss warning response: %s." % suggestion


func _quick_hand_card_would_prevent_planned_collapse(card: Dictionary, tile: Vector2i) -> bool:
	if str(card.get("kind", "")) != "repair_structure":
		return false

	var structure_threat = _active_structure_threat_report()
	if not bool(structure_threat.get("planned_collapse", false)):
		return false

	var threat_tile_value = structure_threat.get("tile", INVALID_TILE)
	return typeof(threat_tile_value) == TYPE_VECTOR2I and threat_tile_value == tile


func _best_tactical_card_tile(card_id: String, card: Dictionary) -> Vector2i:
	var boss_warning_tile = _boss_warning_card_tile(card_id, card)
	if _is_valid_tile(boss_warning_tile):
		return boss_warning_tile

	if not simulation.wave_active:
		return INVALID_TILE

	var report = simulation.get_wave_tactical_report(player_count, selected_class_id)
	if str(report.get("state", "")) != "active":
		return INVALID_TILE

	var threat: Dictionary = report.get("threat", {})
	if threat.is_empty():
		return INVALID_TILE

	var candidates: Array = []
	match str(card.get("kind", "")):
		"damage_enemy":
			candidates.append(threat.get("source_tile", INVALID_TILE))
			candidates.append(threat.get("tile", INVALID_TILE))
		"repair_structure":
			candidates.append(threat.get("tile", INVALID_TILE))
			candidates.append(threat.get("target_tile", INVALID_TILE))
		_:
			return INVALID_TILE

	for candidate_value in candidates:
		if typeof(candidate_value) != TYPE_VECTOR2I:
			continue

		var tile: Vector2i = candidate_value
		var play_check = simulation.can_play_card_at_tile(card_id, tile, player_count, selected_class_id)
		if bool(play_check.get("ok", false)):
			return tile

	return INVALID_TILE


func _boss_warning_card_tile(card_id: String, card: Dictionary) -> Vector2i:
	var report = _active_boss_warning_report()
	if report.is_empty():
		return INVALID_TILE

	match str(card.get("kind", "")):
		"damage_enemy":
			return _boss_warning_damage_tile(card_id, report)
		"repair_structure":
			return _boss_warning_repair_tile(card_id, report)
		"place_structure":
			return _boss_warning_delay_tile(card_id, card, report)
		_:
			return INVALID_TILE


func _active_boss_warning_report() -> Dictionary:
	if not simulation.is_loaded() or not run_started or not simulation.wave_active:
		return {}

	var report = simulation.get_boss_part_warning_report(_run_player_count())
	if not bool(report.get("ok", false)):
		return {}

	return report


func _boss_warning_damage_tile(card_id: String, report: Dictionary) -> Vector2i:
	var tile_value = report.get("tile", INVALID_TILE)
	if typeof(tile_value) != TYPE_VECTOR2I:
		return INVALID_TILE

	var tile: Vector2i = tile_value
	var play_check = simulation.can_play_card_at_tile(card_id, tile, player_count, selected_class_id)
	return tile if bool(play_check.get("ok", false)) else INVALID_TILE


func _boss_warning_repair_tile(card_id: String, report: Dictionary) -> Vector2i:
	var tile = _boss_warning_structure_target_tile(report)
	if not _is_valid_tile(tile):
		return INVALID_TILE

	var play_check = simulation.can_play_card_at_tile(card_id, tile, player_count, selected_class_id)
	return tile if bool(play_check.get("ok", false)) else INVALID_TILE


func _boss_warning_delay_tile(card_id: String, card: Dictionary, report: Dictionary) -> Vector2i:
	var structure_type = str(card.get("structureType", ""))
	if structure_type != "barricade":
		return INVALID_TILE

	for tile in _boss_warning_delay_candidates(report, structure_type):
		if _enemy_occupies_tile(tile):
			continue

		var play_check = simulation.can_play_card_at_tile(card_id, tile, player_count, selected_class_id)
		if bool(play_check.get("ok", false)):
			return tile

	return INVALID_TILE


func _boss_warning_structure_target_tile(report: Dictionary) -> Vector2i:
	var target_key = str(report.get("target_key", ""))
	if target_key.is_empty():
		return INVALID_TILE

	var structure: Dictionary = simulation.get_structure_tiles().get(target_key, {})
	var tile_value = structure.get("tile", INVALID_TILE)
	if typeof(tile_value) != TYPE_VECTOR2I:
		return INVALID_TILE

	return tile_value


func _boss_warning_delay_candidates(report: Dictionary, structure_type: String) -> Array[Vector2i]:
	var boss_tile_value = report.get("tile", INVALID_TILE)
	if typeof(boss_tile_value) != TYPE_VECTOR2I:
		return []

	var direction = _boss_warning_enemy_direction(report)
	var forward = _direction_step_toward_base(direction)
	if forward == Vector2i.ZERO:
		return []

	var boss_tile: Vector2i = boss_tile_value
	var anchor = boss_tile + forward + forward
	var tiles: Array[Vector2i] = []
	for offset in _boss_warning_delay_offsets(direction, structure_type):
		tiles.append(anchor + offset)

	return tiles


func _boss_warning_delay_offsets(direction: String, structure_type: String) -> Array[Vector2i]:
	var forward = _direction_step_toward_base(direction)
	if forward == Vector2i.ZERO:
		return []

	var side = Vector2i(-forward.y, forward.x)
	if structure_type == "barricade":
		return [
			Vector2i.ZERO,
			forward,
			side,
			side * -1,
			forward + side,
			forward + side * -1,
			forward * -1,
		]

	return [
		side,
		side * -1,
		forward + side,
		forward + side * -1,
		Vector2i.ZERO,
		forward,
	]


func _boss_warning_enemy_direction(report: Dictionary) -> String:
	var target_enemy_id = int(report.get("enemy_id", -1))
	var report_tile_value = report.get("tile", INVALID_TILE)
	var active_directions = simulation.get_active_directions(player_count)

	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		var direction = str(enemy.get("direction", ""))
		if not bool(enemy.get("boss", false)) or not active_directions.has(direction):
			continue
		if target_enemy_id >= 0 and int(enemy.get("id", -1)) == target_enemy_id:
			return direction
		if typeof(report_tile_value) == TYPE_VECTOR2I and enemy.get("tile", INVALID_TILE) == report_tile_value:
			return direction

	return ""


func _enemy_occupies_tile(tile: Vector2i) -> bool:
	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		if enemy.get("tile", INVALID_TILE) == tile:
			return true

	return false


func _direction_step_toward_base(direction: String) -> Vector2i:
	match direction:
		"north":
			return Vector2i(0, 1)
		"east":
			return Vector2i(-1, 0)
		"south":
			return Vector2i(0, -1)
		"west":
			return Vector2i(1, 0)
		_:
			return Vector2i.ZERO


func _best_hand_card_tile(card_id: String, card: Dictionary, target_report: Dictionary) -> Vector2i:
	if str(card.get("kind", "")) == "place_structure":
		var structure_type = str(card.get("structureType", ""))
		var recommended_tile = _best_tile_from_recommendations(_front_recommendation_tiles_for_structure(structure_type), structure_type)
		if _is_valid_tile(recommended_tile):
			return recommended_tile

	return _best_tile_from_card_target_report(target_report)


func _best_spawn_response_card_tile(_card_id: String, card: Dictionary, target_report: Dictionary) -> Vector2i:
	if str(card.get("kind", "")) != "place_structure":
		return INVALID_TILE

	var response = _spawn_response_report(_run_player_count())
	if response.is_empty():
		return INVALID_TILE

	var direction = str(response.get("direction", ""))
	var structure_type = str(card.get("structureType", ""))
	if direction.is_empty() or not _spawn_response_structure_type_matches_card(response, structure_type):
		return INVALID_TILE

	var recommendation_tiles = _front_recommendation_tiles_for_structure(structure_type)
	for key_value in _sorted_tile_keys_by_position(recommendation_tiles):
		var key = str(key_value)
		var recommendation: Dictionary = recommendation_tiles.get(key, {})
		if str(recommendation.get("direction", "")) != direction:
			continue

		var tile_value = recommendation.get("tile", _tile_from_key(key))
		var tile = tile_value if typeof(tile_value) == TYPE_VECTOR2I else _tile_from_key(key)
		if _is_valid_tile(tile) and _target_report_tile_is_valid(target_report, tile):
			return tile

	return INVALID_TILE


func _target_report_tile_is_valid(target_report: Dictionary, tile: Vector2i) -> bool:
	var target_tiles: Dictionary = target_report.get("tiles", {})
	var target: Dictionary = target_tiles.get(_tile_key(tile), {})
	return bool(target.get("valid", false))


func _hand_card_tile_is_front_recommended(card: Dictionary, tile: Vector2i) -> bool:
	if str(card.get("kind", "")) != "place_structure":
		return false

	var structure_type = str(card.get("structureType", ""))
	return _front_recommendation_tiles_for_structure(structure_type).has(_tile_key(tile))


func _best_hand_card_score(card_id: String, card: Dictionary, tile: Vector2i, recommended: bool, tactical: bool, index: int) -> int:
	var score = 1000 - index
	var kind = str(card.get("kind", ""))
	var cost = int(card.get("cost", 0))
	score -= cost * 12
	score += _spawn_response_hand_score_bonus(card, tile)
	if recommended:
		score += 450
	if tactical:
		score += 520
	if _card_tile_answers_boss_warning(card, tile):
		score += 620

	match kind:
		"place_structure":
			score += 300
			if not _front_setup_is_complete():
				score += 300
			var structure_type = str(card.get("structureType", ""))
			if selected_class_id == "architect" and structure_type == "barricade":
				score += 130
			elif structure_type == "tower":
				score += 90
		"damage_enemy":
			score += 260 if simulation.wave_active else -120
			score += int(card.get("damage", 0)) * 30
		"repair_structure":
			score += 220
			if _is_valid_tile(tile):
				score += 80
		"draw_cards":
			score += 120 + int(card.get("draw", 0)) * 50

	if _class_hand_priority_index(card_id) >= 0:
		score += max(0, 160 - _class_hand_priority_index(card_id) * 12)

	return score


func _card_tile_answers_boss_warning(card: Dictionary, tile: Vector2i) -> bool:
	var report = _active_boss_warning_report()
	if report.is_empty() or not _is_valid_tile(tile):
		return false

	match str(card.get("kind", "")):
		"damage_enemy":
			var boss_tile_value = report.get("tile", INVALID_TILE)
			return typeof(boss_tile_value) == TYPE_VECTOR2I and boss_tile_value == tile
		"repair_structure":
			return _boss_warning_structure_target_tile(report) == tile
		"place_structure":
			if str(card.get("structureType", "")) != "barricade":
				return false

			for candidate in _boss_warning_delay_candidates(report, "barricade"):
				if candidate == tile:
					return true

			return false
		_:
			return false


func _card_spawn_response_tooltip_line(card_id: String, card: Dictionary) -> String:
	var target_tile = INVALID_TILE
	if simulation.card_requires_tile(card_id):
		var target_report = _card_target_report(card_id, player_count, selected_class_id)
		if bool(target_report.get("ok", false)) and int(target_report.get("valid_count", 0)) > 0:
			var tactical_tile = _best_tactical_card_tile(card_id, card)
			target_tile = tactical_tile if _is_valid_tile(tactical_tile) else _best_spawn_response_card_tile(card_id, card, target_report)
			if not _is_valid_tile(target_tile):
				target_tile = _best_hand_card_tile(card_id, card, target_report)

	var response = _spawn_response_hand_report(card, target_tile)
	if response.is_empty():
		return ""

	return "Spawn answer: %s" % response.get("reason", "matches the next spawn response")


func _spawn_response_hand_summary_suffix(card: Dictionary, tile: Vector2i) -> String:
	var response = _spawn_response_hand_report(card, tile)
	if response.is_empty():
		return ""

	return " Spawn answer: %s." % response.get("reason", "matches the next spawn response")


func _spawn_response_hand_score_bonus(card: Dictionary, tile: Vector2i) -> int:
	var response = _spawn_response_hand_report(card, tile)
	return int(response.get("score_bonus", 0)) if not response.is_empty() else 0


func _spawn_response_hand_report(card: Dictionary, tile: Vector2i) -> Dictionary:
	if card.is_empty() or not simulation.is_loaded() or not run_started:
		return {}

	var response = _spawn_response_report(_run_player_count())
	if response.is_empty():
		return {}

	var row: Dictionary = response.get("row", {})
	var direction = str(response.get("direction", ""))
	var role = _spawn_response_role(row)
	var kind = str(card.get("kind", ""))
	var score_bonus = 0
	var reason = ""

	match kind:
		"place_structure":
			var structure_type = str(card.get("structureType", ""))
			if not _spawn_response_structure_type_matches_card(response, structure_type):
				return {}

			score_bonus = 420
			if _spawn_response_tile_matches_direction(tile, direction, structure_type):
				score_bonus += 180
				reason = "%s supports the next %s front spawn at %s" % [
					structure_type.capitalize(),
					direction,
					_tile_text(tile),
				]
			else:
				reason = "%s supports the next %s front spawn" % [
					structure_type.capitalize(),
					direction,
				]
		"damage_enemy":
			if not simulation.wave_active:
				return {}

			var enemy_direction = _enemy_direction_at_tile(tile)
			if not enemy_direction.is_empty() and enemy_direction != direction:
				return {}

			score_bonus = 360
			if ["boss", "fast", "structure_break"].has(role):
				score_bonus += 160
			reason = "focus fire answers the next %s threat on %s" % [
				_spawn_response_role_label(role),
				direction,
			]
		"repair_structure":
			if not simulation.wave_active or not ["boss", "structure_break", "short"].has(role):
				return {}

			score_bonus = 300
			reason = "repair is ready for the next %s pressure on %s" % [
				_spawn_response_role_label(role),
				direction,
			]
		"draw_cards":
			if simulation.wave_active:
				score_bonus = 120
				reason = "draw can look for an answer while %s is active" % direction
			else:
				score_bonus = 80
				reason = "draw can find an answer before %s opens" % direction
		_:
			return {}

	return {
		"ok": true,
		"direction": direction,
		"role": role,
		"score_bonus": score_bonus,
		"reason": reason,
	}


func _spawn_response_structure_type_matches_card(response: Dictionary, structure_type: String) -> bool:
	if structure_type.is_empty():
		return false

	if structure_type == str(response.get("structure_type", "")):
		return true

	var row: Dictionary = response.get("row", {})
	match _spawn_response_role(row):
		"boss", "structure_break", "short", "fast":
			return structure_type == "barricade"
		"armored", "slow", "killzone", "swarm":
			return structure_type == "tower"
		_:
			return false


func _spawn_response_tile_matches_direction(tile: Vector2i, direction: String, structure_type: String) -> bool:
	if not _is_valid_tile(tile) or direction.is_empty() or structure_type.is_empty():
		return false

	var recommendation: Dictionary = _front_recommendation_tiles_for_structure(structure_type).get(_tile_key(tile), {})
	return str(recommendation.get("direction", "")) == direction


func _enemy_direction_at_tile(tile: Vector2i) -> String:
	if not _is_valid_tile(tile):
		return ""

	for enemy_value in simulation.debug_get_enemies():
		if typeof(enemy_value) != TYPE_DICTIONARY:
			continue

		var enemy: Dictionary = enemy_value
		if enemy.get("tile", INVALID_TILE) == tile:
			return str(enemy.get("direction", ""))

	return ""


func _spawn_response_role_label(role: String) -> String:
	match role:
		"boss":
			return "boss"
		"structure_break", "short":
			return "breaker"
		"fast":
			return "fast"
		"armored", "slow":
			return "armored"
		"killzone":
			return "swarm"
		_:
			return "spawn"


func _class_hand_priority_index(card_id: String) -> int:
	var priority: Array = simulation.get_class_autoplay_profile(selected_class_id).get("cardPriority", [])
	for index in range(priority.size()):
		if str(priority[index]) == card_id:
			return index

	return -1


func _best_card_target_report(card_id: String) -> Dictionary:
	var card = simulation.get_card_data(card_id)
	if card.is_empty():
		return _best_target_reject("unknown_card", "Use best target", "Selected card is missing.")
	if not simulation.card_requires_tile(card_id):
		return _best_target_reject("card_has_no_target", "Click card to play", "%s does not need a tile." % card.get("label", card_id))

	var target_report = _card_target_report(card_id, player_count, selected_class_id)
	if not bool(target_report.get("ok", false)):
		return _best_target_reject(str(target_report.get("reason", "blocked")), "No target", str(target_report.get("summary", "Targets unavailable.")))
	if int(target_report.get("valid_count", 0)) <= 0:
		return _best_target_reject("no_valid_target", "No target", str(target_report.get("summary", "No valid target.")))

	var tactical_tile = _best_tactical_card_tile(card_id, card)
	var tile = tactical_tile if _is_valid_tile(tactical_tile) else _best_tile_from_card_target_report(target_report)
	if not _is_valid_tile(tile):
		return _best_target_reject("no_valid_target", "No target", str(target_report.get("summary", "No valid target.")))

	var play_check = simulation.can_play_card_at_tile(card_id, tile, player_count, selected_class_id)
	if not bool(play_check.get("ok", false)):
		return _best_target_reject(str(play_check.get("reason", "blocked")), "No target", "Best target is blocked: %s." % play_check.get("reason", "unknown"))

	return {
		"ok": true,
		"reason": "ok",
		"intent": "card",
		"card_id": card_id,
		"card_index": selected_card_index,
		"tile": tile,
		"label": card.get("label", card_id),
		"button_text": "Use %s at %s" % [
			card.get("label", card_id),
			_tile_text(tile),
		],
		"summary": "%s will be played at %s. %s%s%s" % [
			card.get("label", card_id),
			_tile_text(tile),
			target_report.get("summary", ""),
			_boss_focus_target_suffix(tile),
			_boss_warning_target_suffix(card, tile),
		],
		"tactical": _is_valid_tile(tactical_tile) and tactical_tile == tile,
	}


func _best_build_target_report(structure_type: String) -> Dictionary:
	if simulation.wave_active:
		return _best_target_reject("wave_active", "Wave active", "Build changes are locked during an active wave.")

	var tile = _best_tile_from_recommendations(_front_recommendation_tiles_for_structure(structure_type), structure_type)
	if not _is_valid_tile(tile):
		tile = _first_valid_structure_tile(structure_type)
	if not _is_valid_tile(tile):
		return _best_target_reject("no_valid_target", "No build target", "No valid %s tile is available." % structure_type)

	var place_check = simulation.can_place_structure(tile, structure_type, player_count, selected_class_id)
	if not bool(place_check.get("ok", false)):
		return _best_target_reject(str(place_check.get("reason", "blocked")), "No build target", "Best %s target is blocked: %s." % [structure_type, place_check.get("reason", "unknown")])

	return {
		"ok": true,
		"reason": "ok",
		"intent": "build",
		"tile": tile,
		"label": structure_type.capitalize(),
		"button_text": "Build %s at %s" % [
			structure_type.capitalize(),
			_tile_text(tile),
		],
		"summary": "Build %s at %s. %s" % [
			structure_type,
			_tile_text(tile),
			_front_recommendation_summary_for_structure(structure_type),
		],
	}


func _best_target_reject(reason: String, button_text: String, summary: String) -> Dictionary:
	return {
		"ok": false,
		"reason": reason,
		"button_text": button_text,
		"summary": summary,
		"tile": INVALID_TILE,
	}


func _setup_plan_action_report() -> Dictionary:
	if not simulation.is_loaded():
		return _setup_plan_reject("data_not_loaded", "Use setup plan", "Data is not loaded.")
	if not run_started:
		return _setup_plan_reject("run_not_started", "Use setup plan", "Begin the run first.")
	if simulation.wave_active:
		return _setup_plan_reject("wave_active", "Wave active", "Setup plan is only for the preparation window.")
	if simulation.has_pending_reward():
		return _setup_plan_reject("reward_pending", "Resolve reward", "Claim or skip the pending reward first.")
	if simulation.is_run_complete():
		return _setup_plan_reject("run_complete", "Run complete", simulation.get_run_outcome_summary(player_count))
	if _front_setup_is_complete():
		return _setup_plan_reject("setup_complete", "Setup covered", simulation.get_front_defense_summary(player_count))

	var step_report = _setup_plan_preview_step_report()
	if not bool(step_report.get("ok", false)):
		step_report = _setup_plan_next_step_report()
	if not bool(step_report.get("ok", false)):
		return step_report

	var tile: Vector2i = step_report.get("tile", INVALID_TILE)
	var structure_type = str(step_report.get("structure_type", "structure"))
	return {
		"ok": true,
		"reason": "ok",
		"button_text": "Plan %s at %s" % [
			structure_type.capitalize(),
			_tile_text(tile),
		],
		"summary": "Next: place %s at %s. %s" % [
			structure_type.capitalize(),
			_tile_text(tile),
			step_report.get("summary", ""),
		],
		"tile": tile,
		"structure_type": structure_type,
		"recommendation": step_report.get("recommendation", {}),
		"preview": bool(step_report.get("preview", false)),
	}


func _setup_plan_preview_step_report() -> Dictionary:
	if not run_started:
		return _setup_plan_reject("run_not_started", "Use setup plan", "Begin the run first.")
	if not preview_ok:
		return _setup_plan_reject("no_current_preview", "Use setup plan", "No selected setup preview is currently active.")
	if not _is_valid_tile(preview_tile):
		return _setup_plan_reject("invalid_preview_tile", "Use setup plan", "The selected setup preview tile is not valid.")
	if selected_tile != preview_tile:
		return _setup_plan_reject("preview_not_selected", "Use setup plan", "Select a setup preview tile before using the plan.")
	if not _selected_card_id().is_empty():
		return _setup_plan_reject("card_preview_active", "Use setup plan", "Resolve the selected card before using the setup plan.")
	if not ["tower", "barricade"].has(build_mode):
		return _setup_plan_reject("no_structure_preview", "Use setup plan", "No structure setup preview is currently active.")

	var structure_type = build_mode
	var place_check = simulation.can_place_structure(preview_tile, structure_type, player_count, selected_class_id)
	if not bool(place_check.get("ok", false)):
		return _setup_plan_reject(str(place_check.get("reason", "blocked")), "Use setup plan", "Selected setup preview is blocked: %s." % place_check.get("reason", "unknown"))

	var recommendation_tiles = _front_recommendation_tiles_for_structure(structure_type)
	var recommendation: Dictionary = recommendation_tiles.get(_tile_key(preview_tile), {})
	return {
		"ok": true,
		"reason": "ok",
		"button_text": "Use setup plan",
		"summary": "Current preview: %s at %s. %s" % [
			structure_type.capitalize(),
			_tile_text(preview_tile),
			_front_recommendation_summary_for_structure(structure_type),
		],
		"tile": preview_tile,
		"structure_type": structure_type,
		"recommendation": recommendation,
		"preview": true,
	}


func _setup_plan_next_step_report() -> Dictionary:
	for structure_type in _setup_plan_structure_sequence():
		var step_report = _setup_structure_target_report(str(structure_type))
		if bool(step_report.get("ok", false)):
			return step_report

	return _setup_plan_reject("no_valid_target", "No setup tile", "No recommended setup tile is currently available.")


func _setup_structure_target_report(structure_type: String) -> Dictionary:
	var recommendation_tiles = _front_recommendation_tiles_for_structure(structure_type)
	var tile = _best_tile_from_recommendations(recommendation_tiles, structure_type)
	if not _is_valid_tile(tile):
		return _setup_plan_reject("no_valid_%s_target" % structure_type, "No %s tile" % structure_type.capitalize(), "No recommended %s tile is currently available." % structure_type)

	var place_check = simulation.can_place_structure(tile, structure_type, player_count, selected_class_id)
	if not bool(place_check.get("ok", false)):
		return _setup_plan_reject(str(place_check.get("reason", "blocked")), "No %s tile" % structure_type.capitalize(), "Recommended %s target is blocked: %s." % [structure_type, place_check.get("reason", "unknown")])

	return {
		"ok": true,
		"reason": "ok",
		"button_text": "Use setup plan",
		"summary": _front_recommendation_summary_for_structure(structure_type),
		"tile": tile,
		"structure_type": structure_type,
		"recommendation": recommendation_tiles.get(_tile_key(tile), {}),
	}


func _setup_plan_structure_sequence() -> Array:
	return _setup_plan_structure_sequence_for_class(selected_class_id)


func _setup_plan_structure_sequence_for_class(class_id: String) -> Array:
	if class_id == "architect":
		return ["barricade", "tower"]

	return ["tower", "barricade"]


func _front_setup_is_complete() -> bool:
	var report = simulation.get_front_defense_report(player_count)
	if not bool(report.get("ok", false)):
		return false

	var fronts: Array = report.get("fronts", [])
	for front_value in fronts:
		if typeof(front_value) != TYPE_DICTIONARY:
			continue

		var front: Dictionary = front_value
		if bool(front.get("needs_minimum_defense", false)):
			return false

	return not fronts.is_empty()


func _setup_plan_reject(reason: String, button_text: String, summary: String) -> Dictionary:
	return {
		"ok": false,
		"reason": reason,
		"button_text": button_text,
		"summary": summary,
		"tile": INVALID_TILE,
		"structure_type": "",
	}


func _best_tile_from_card_target_report(target_report: Dictionary) -> Vector2i:
	var target_tiles: Dictionary = target_report.get("tiles", {})
	var recommended_tile = _best_valid_recommended_card_tile(target_tiles)
	if _is_valid_tile(recommended_tile):
		return recommended_tile

	for key_value in _sorted_tile_keys_by_position(target_tiles):
		var key = str(key_value)
		var target: Dictionary = target_tiles.get(key, {})
		if bool(target.get("valid", false)):
			return _tile_from_key(key)

	return INVALID_TILE


func _best_valid_recommended_card_tile(target_tiles: Dictionary) -> Vector2i:
	var recommendation_tiles = _active_front_recommendation_tiles()
	for key_value in _sorted_tile_keys_by_position(recommendation_tiles):
		var key = str(key_value)
		var target: Dictionary = target_tiles.get(key, {})
		if bool(target.get("valid", false)):
			return _tile_from_key(key)

	return INVALID_TILE


func _best_tile_from_recommendations(recommendation_tiles: Dictionary, structure_type: String) -> Vector2i:
	for key_value in _sorted_tile_keys_by_position(recommendation_tiles):
		var key = str(key_value)
		var tile = _tile_from_key(key)
		var place_check = simulation.can_place_structure(tile, structure_type, player_count, selected_class_id)
		if bool(place_check.get("ok", false)):
			return tile

	return INVALID_TILE


func _best_alpha_focus_setup_tile(
	recommendation_tiles: Dictionary,
	structure_type: String,
	focus_player_count: int,
	focus_class_id: String,
	preferred_direction: String
) -> Vector2i:
	var fallback_tile = INVALID_TILE
	for key_value in _sorted_tile_keys_by_position(recommendation_tiles):
		var key = str(key_value)
		var tile = _tile_from_key(key)
		var place_check = simulation.can_place_structure(tile, structure_type, focus_player_count, focus_class_id)
		if not bool(place_check.get("ok", false)):
			continue

		if not _is_valid_tile(fallback_tile):
			fallback_tile = tile

		var recommendation: Dictionary = recommendation_tiles.get(key, {})
		var direction = str(recommendation.get("direction", ""))
		if preferred_direction.is_empty() or direction == preferred_direction:
			return tile

	return fallback_tile


func _first_valid_structure_tile(structure_type: String) -> Vector2i:
	var map_size = simulation.get_map_size()
	for y in range(map_size.y):
		for x in range(map_size.x):
			var tile = Vector2i(x, y)
			var place_check = simulation.can_place_structure(tile, structure_type, player_count, selected_class_id)
			if bool(place_check.get("ok", false)):
				return tile

	return INVALID_TILE


func _sorted_tile_keys_by_position(source: Dictionary) -> Array:
	var keys = source.keys()
	keys.sort_custom(func(left, right) -> bool:
		var left_tile = _tile_from_key(str(left))
		var right_tile = _tile_from_key(str(right))
		if left_tile.y == right_tile.y:
			return left_tile.x < right_tile.x

		return left_tile.y < right_tile.y
	)
	return keys


func _tile_from_key(key: String) -> Vector2i:
	var parts = key.split(",", false)
	if parts.size() != 2:
		return INVALID_TILE

	return Vector2i(int(parts[0]), int(parts[1]))


func _selected_card_target_at(tile: Vector2i) -> Dictionary:
	var target_tiles = _selected_card_target_tiles()
	return target_tiles.get(_tile_key(tile), {})


func _active_front_recommendation_at(tile: Vector2i) -> Dictionary:
	var recommendation_tiles = _active_front_recommendation_tiles()
	return recommendation_tiles.get(_tile_key(tile), {})


func _recommendation_detail_text(recommendation: Dictionary) -> String:
	var detail_values: Array = recommendation.get("details", [])
	var parts = PackedStringArray()
	for detail_value in detail_values:
		var detail_text = str(detail_value)
		if not detail_text.is_empty():
			parts.append(detail_text)

	return ", ".join(parts)


func _push_recommendation_log(recommendation: Dictionary) -> void:
	if recommendation.is_empty():
		return

	debug_log.push("Recommended tile reason: %s" % recommendation.get("why", recommendation.get("summary", "-")))
	var details = _recommendation_detail_text(recommendation)
	if not details.is_empty():
		debug_log.push("Recommended tile details: %s." % details)


func _tile_key(tile: Vector2i) -> String:
	return "%s,%s" % [tile.x, tile.y]


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
