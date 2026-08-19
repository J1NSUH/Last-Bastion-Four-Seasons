class_name M0CombatSimulation
extends RefCounted

const DATA_PATH = "res://data/m0/m0_test_data.json"
const REQUIRED_TOP_LEVEL_KEYS = [
	"map",
	"activeDirectionsByPlayerCount",
	"base",
	"run",
	"resources",
	"rewards",
	"shop",
	"structures",
	"cards",
	"classes",
	"artifacts",
	"deck",
	"enemies",
	"waveIntents",
	"wave",
	"debug",
]
const AUTOPLAY_TILE_PLANS = [
	"guard_line",
	"maze_grid",
	"killzone",
	"cluster",
]
const CARD_KINDS = [
	"place_structure",
	"damage_enemy",
	"repair_structure",
	"draw_cards",
]
const CARD_RARITIES = [
	"common",
	"uncommon",
	"rare",
]
const WAVE_INTENT_ROLES = [
	"swarm",
	"fast",
	"structure_break",
	"armored",
	"boss",
]
const WAVE_SPAWN_DIRECTION_ROLES = [
	"short",
	"slow",
	"fast",
	"killzone",
	"boss",
	"any",
]
const WAVE_STACK_RISK_LEVELS = [
	"low",
	"medium",
	"high",
	"locked",
]
const TILE_TARGET_CARD_KINDS = [
	"place_structure",
	"damage_enemy",
	"repair_structure",
]
const CLASS_EFFECT_KEYS = [
	"towerHpBonus",
	"tauntPriority",
	"thornsDamage",
	"barricadeHpBonus",
	"barricadeDeathDamage",
	"barricadeDeathRadius",
	"towerSplashDamage",
	"towerSplashRadius",
	"cardBossDamageBonus",
	"auraRange",
	"auraTowerDamageBonus",
	"repairPerRound",
]
const ARTIFACT_EFFECT_KEYS = [
	"maxHandBonus",
	"seedManaBonus",
	"manaPerKillBonus",
	"goldPerKillBonus",
	"drawGaugePerKillBonus",
	"waveStackLimitBonus",
	"artifactSlotBonus",
]
const ARTIFACT_SLOT_HARD_CAP = 4
const FRONT_DEFENSE_PATH_DEPTH = 7
const FRONT_DEFENSE_RADIUS = 2
const FRONT_MIN_STRUCTURE_COUNT = 1
const FRONT_RECOMMENDATION_PATH_DEPTH = 8
const FRONT_RECOMMENDATION_LIMIT = 8
const WAVE_STACK_FORBIDDEN_REWARD_FIELDS = [
	"goldMultiplier",
	"rarityBonus",
	"extraCardChoices",
	"stackClearBonus",
]
const SETTLEMENT_FORBIDDEN_SUMMARY_TEXT_TAGS = [
	"tripleReward",
	"stackBonus",
	"rarityUp",
	"extraChoice",
]
const REWARD_CHOICE_LOCK_FORBIDDEN_TAGS = [
	"rewardMultiplier",
	"rarityAdjustment",
	"extraCardChoices",
	"forcedCurse",
	"partyCoercion",
]
const REWARD_TO_MAINTENANCE_GATE_FORBIDDEN_TAGS = [
	"paidShopBeforeRewardResolved",
	"hiddenPenalty",
	"rewardMultiplier",
	"rarityAdjustment",
	"extraCardChoices",
	"forcedCurse",
	"partyCoercion",
]
const WAVE_PREVIEW_CARD_FORBIDDEN_TAGS = [
	"inactiveDirectionForecast",
	"hiddenSpawnDirection",
	"rewardMultiplier",
	"rarityAdjustment",
	"extraCardChoices",
	"bonusGold",
	"forcedClassCounter",
]
const LANE_PROJECTION_FORBIDDEN_TAGS = [
	"inactiveDirectionSpawn",
	"hiddenDirection",
	"allFrontsEveryWave",
	"rewardMultiplier",
	"rarityAdjustment",
	"extraCardChoices",
]
const WAVE_SPAWN_PLAN_FORBIDDEN_FIELDS = [
	"rewardMultiplier",
	"goldMultiplier",
	"rarityBonus",
	"extraCardChoices",
	"activeDirectionOverride",
	"inactiveDirectionSpawn",
]
const WAVE_SPAWN_TIMELINE_FORBIDDEN_TAGS = [
	"rewardMultiplier",
	"rarityAdjustment",
	"extraCardChoices",
	"inactiveDirectionWarning",
	"hiddenSpawnDirection",
]
const WAVE_STACK_VOTE_DURATION_SECONDS = 8
const WAVE_STACK_SPAWN_COUNTDOWN_SECONDS = 2
const WAVE_STACK_TEMPO_MOMENT_WINDOW_SECONDS = 20.0
const SHOP_PURCHASE_VOTE_DURATION_SECONDS = 20
const DIR_STEPS = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

var data: Dictionary = {}
var last_error = ""
var structures: Dictionary = {}
var enemies: Array[Dictionary] = []
var base_hp = 0
var wave_active = false
var current_round = 1
var active_round = 0
var completed_rounds = 0
var run_complete = false
var spawned_count = 0
var active_wave_packets: Array[Dictionary] = []
var next_enemy_id = 1
var recent_event_tiles: Dictionary = {}
var run_stats: Dictionary = {}
var mana = 0
var gold = 0
var boss_shards = 0
var draw_gauge = 0
var discard_charges = 0
var hand: Array = []
var draw_pile: Array = []
var discard_pile: Array = []
var reward_offer: Array = []
var artifact_offer: Array = []
var shop_offer: Array = []
var shop_service_offer: Array = []
var equipped_artifacts: Array = []
var dormant_artifacts: Array = []
var reward_queue: Array[Dictionary] = []
var active_reward_packet: Dictionary = {}
var wave_stack_vote: Dictionary = {}
var shop_purchase_vote: Dictionary = {}
var round_start_stats: Dictionary = {}
var last_round_report: Dictionary = {}
var last_round_resource_report: Dictionary = {}
var last_kill_resource_report: Dictionary = {}
var last_reward_claim_report: Dictionary = {}
var last_artifact_report: Dictionary = {}
var last_shop_report: Dictionary = {}
var shop_removals_remaining = 0
var shop_purchases_remaining = 0
var artifact_actions_remaining = 0
var boss_reward_pending = false
var wave_spawn_plan_cache: Dictionary = {}
var wave_preview_card_cache: Dictionary = {}
var wave_stack_tempo_tracker: Dictionary = {}
var last_wave_stack_tempo_moment: Dictionary = {}


func load_data() -> bool:
	last_error = ""

	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return _fail_load("Cannot open %s: %s" % [DATA_PATH, error_string(FileAccess.get_open_error())])

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return _fail_load("M0 data must be a JSON object.")

	data = parsed
	wave_spawn_plan_cache.clear()
	wave_preview_card_cache.clear()
	for key in REQUIRED_TOP_LEVEL_KEYS:
		if not data.has(key):
			return _fail_load("M0 data is missing top-level key: %s" % key)

	if not _validate_data():
		return _fail_load(last_error)

	reset_run()
	return true


func reset_run() -> void:
	structures.clear()
	enemies.clear()
	base_hp = int(data.get("base", {}).get("hp", 100))
	wave_active = false
	current_round = 1
	active_round = 0
	completed_rounds = 0
	run_complete = false
	spawned_count = 0
	active_wave_packets.clear()
	next_enemy_id = 1
	recent_event_tiles.clear()
	artifact_offer.clear()
	shop_offer.clear()
	shop_service_offer.clear()
	equipped_artifacts.clear()
	dormant_artifacts.clear()
	reward_queue.clear()
	active_reward_packet.clear()
	wave_stack_vote.clear()
	shop_purchase_vote.clear()
	round_start_stats.clear()
	last_round_report.clear()
	last_round_resource_report.clear()
	last_kill_resource_report.clear()
	last_reward_claim_report.clear()
	last_artifact_report.clear()
	last_shop_report.clear()
	wave_stack_tempo_tracker.clear()
	last_wave_stack_tempo_moment.clear()
	shop_removals_remaining = 0
	shop_purchases_remaining = 0
	artifact_actions_remaining = 0
	boss_reward_pending = false
	mana = get_seed_mana()
	gold = get_starting_gold()
	boss_shards = get_starting_boss_shards()
	draw_gauge = 0
	discard_charges = get_discard_charges_per_run()
	hand.clear()
	draw_pile = _starting_deck()
	discard_pile.clear()
	reward_offer.clear()
	run_stats = {
		"spawned": 0,
		"spawned_by_enemy_id": {},
		"bosses_spawned": 0,
		"killed": 0,
		"killed_by_enemy_id": {},
		"bosses_killed": 0,
		"boss_shards_gained": 0,
		"boss_shards_spent": 0,
		"boss_part_damage": 0,
		"boss_part_damage_by_part_id": {},
		"boss_parts_destroyed": 0,
		"boss_parts_destroyed_by_part_id": {},
		"boss_part_draws": 0,
		"boss_part_slow_waits": 0,
		"boss_phase_triggers": 0,
		"boss_pulse_damage": 0,
		"boss_siege_triggers": 0,
		"boss_siege_damage": 0,
		"base_hits": 0,
		"boss_base_hits": 0,
		"base_damage": 0,
		"base_hits_by_direction": {},
		"boss_base_hits_by_direction": {},
		"base_damage_by_direction": {},
		"base_hits_by_enemy_id": {},
		"tower_hits": 0,
		"structure_hits": 0,
		"structures_placed": 0,
		"structures_placed_by_class": {},
		"structures_placed_by_type": {},
		"towers_placed_by_class": {},
		"barricades_placed_by_class": {},
		"structures_destroyed": 0,
		"structures_destroyed_by_direction": {},
		"planned_collapses": 0,
		"planned_collapses_by_direction": {},
		"planned_collapse_damage": 0,
		"planned_collapse_damage_by_direction": {},
		"break_targets_found": 0,
		"break_path_steps": 0,
		"enemy_fast_moves": 0,
		"enemy_priority_break_moves": 0,
		"enemy_damage_reduced": 0,
		"cards_drawn": 0,
		"cards_played": 0,
		"mana_spent": 0,
		"gold_gained": 0,
		"gold_spent": 0,
		"card_reward_gold_gained": 0,
		"card_damage_dealt": 0,
		"card_repairs": 0,
		"card_effect_draws": 0,
		"kill_mana_gained": 0,
		"draw_gauge_gained": 0,
		"reward_cards_drawn": 0,
		"round_seed_cards_drawn": 0,
		"cards_discarded": 0,
		"discard_mana_gained": 0,
		"class_thorns_damage": 0,
		"class_explosion_damage": 0,
		"class_splash_damage": 0,
		"class_aura_damage": 0,
		"class_taunt_hits": 0,
		"class_repairs": 0,
		"card_rewards_offered": 0,
		"card_rewards_taken": 0,
		"card_reward_gold_choices": 0,
		"card_rewards_skipped": 0,
		"artifact_rewards_offered": 0,
		"artifact_rewards_taken": 0,
		"artifact_rewards_skipped": 0,
		"artifact_actions_spent": 0,
		"artifact_replacements": 0,
		"artifact_reactivations": 0,
		"artifact_dormant_added": 0,
		"artifact_dormant_released": 0,
		"shop_offers_opened": 0,
		"shop_cards_removed": 0,
		"shop_services_purchased": 0,
		"shop_base_hp_recovered": 0,
		"shop_structure_hp_reinforced": 0,
		"shop_gold_spent": 0,
		"shop_skips": 0,
		"rounds_started": 0,
		"rounds_completed": 0,
		"wave_stacks": 0,
		"stacked_rounds": 0,
		"max_wave_stack_depth": 0,
		"stack_rejections": 0,
		"wave_stack_votes_started": 0,
		"wave_stack_votes_approved": 0,
		"wave_stack_votes_passed": 0,
		"wave_stack_votes_held": 0,
		"shop_votes_started": 0,
		"shop_votes_approved": 0,
		"shop_votes_passed": 0,
		"shop_votes_held": 0,
		"wave_stack_tempo_moments": 0,
		"round_mana_refills": 0,
		"front_seed_mana_gained": 0,
		"discard_refills": 0,
		"steps": 0,
	}
	_draw_cards(get_opening_draw_count())
	round_start_stats = _copy_run_stats()


func is_loaded() -> bool:
	return not data.is_empty()


func get_default_player_count() -> int:
	return int(data.get("debug", {}).get("defaultPlayerCount", 1))


func get_run_setup_report(player_count: int, class_id: String) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var normalized_player_count = clamp(player_count, 1, 4)
	var active_directions = get_active_directions(normalized_player_count)
	if active_directions.is_empty():
		return _reject("no_active_directions")

	var resolved_class_id = class_id
	if resolved_class_id.is_empty():
		var class_ids = get_autoplay_class_ids()
		if not class_ids.is_empty():
			resolved_class_id = str(class_ids[0])

	if resolved_class_id.is_empty() or get_class_data(resolved_class_id).is_empty():
		return _reject("unknown_class")

	var class_label = get_class_label(resolved_class_id)
	var front_defense_report = get_front_defense_report(normalized_player_count)
	return {
		"ok": true,
		"reason": "ok",
		"player_count": normalized_player_count,
		"class_id": resolved_class_id,
		"class_label": class_label,
		"active_directions": active_directions.duplicate(),
		"seed_mana": get_seed_mana_for_player_count(normalized_player_count),
		"first_wave": describe_wave(normalized_player_count, current_round),
		"front_defense": front_defense_report,
		"front_defense_summary": str(front_defense_report.get("summary", "")),
		"summary": "%sP | fronts: %s | seed mana: %s | lead class: %s | %s" % [
			normalized_player_count,
			", ".join(_string_values(active_directions)),
			get_seed_mana_for_player_count(normalized_player_count),
			class_label,
			describe_wave(normalized_player_count, current_round),
		],
	}


func get_run_setup_summary(player_count: int, class_id: String) -> String:
	var report = get_run_setup_report(player_count, class_id)
	if not bool(report.get("ok", false)):
		return "Setup unavailable: %s" % report.get("reason", "unknown")

	return str(report.get("summary", ""))


func get_max_rounds() -> int:
	return int(data.get("run", {}).get("maxRounds", 100))


func get_current_round() -> int:
	return current_round


func get_active_round() -> int:
	return active_round


func get_completed_rounds() -> int:
	return completed_rounds


func get_base_hp() -> int:
	return base_hp


func is_run_complete() -> bool:
	return run_complete


func get_auto_step_interval() -> float:
	return float(data.get("debug", {}).get("autoStepIntervalSec", 0.6))


func get_autoplay_rounds() -> int:
	return int(data.get("debug", {}).get("autoplayRounds", 2))


func get_autoplay_boss_rounds() -> int:
	return int(data.get("debug", {}).get("autoplayBossRounds", max(1, int(data.get("wave", {}).get("bossEveryRounds", 10)))))


func get_autoplay_max_steps_per_round() -> int:
	return int(data.get("debug", {}).get("autoplayMaxStepsPerRound", 180))


func get_autoplay_cards_per_round() -> int:
	return int(data.get("debug", {}).get("autoplayCardsPerRound", 2))


func get_show_debug_logs_default() -> bool:
	return bool(data.get("debug", {}).get("showLogs", true))


func get_tutorial_rounds() -> int:
	return int(data.get("debug", {}).get("tutorialRounds", 3))


func get_wave_preview_round_count() -> int:
	return max(1, int(data.get("debug", {}).get("wavePreviewRounds", 3)))


func get_wave_stack_limit() -> int:
	return max(1, int(data.get("wave", {}).get("stackLimit", 1)) + _artifact_effect_total("waveStackLimitBonus"))


func get_active_wave_stack_depth() -> int:
	return active_wave_packets.size() if wave_active else 0


func get_pending_reward_packet_count() -> int:
	var count = reward_queue.size()
	if not active_reward_packet.is_empty():
		count += 1
	return count


func get_settlement_batch_report() -> Dictionary:
	var rounds: Array[int] = []
	var packets: Array[Dictionary] = []
	if not active_reward_packet.is_empty():
		packets.append(active_reward_packet)

	for packet_value in reward_queue:
		if typeof(packet_value) != TYPE_DICTIONARY:
			continue

		var packet: Dictionary = packet_value
		packets.append(packet)

	for packet in packets:
		rounds.append(int(packet.get("round", completed_rounds)))

	rounds.sort()
	var packet_count = rounds.size()
	if packet_count <= 0:
		return {
			"ok": false,
			"reason": "no_pending_settlement",
			"packet_count": 0,
			"rounds": [],
			"compressed": false,
			"no_bonus": true,
			"noBonusRewards": true,
			"settlementBatchId": "",
			"sourceWaveIds": [],
			"rewardPacketIds": [],
			"temporaryLockPolicy": {"onlyUnlockedRows": true},
			"forbiddenSummaryTextTags": SETTLEMENT_FORBIDDEN_SUMMARY_TEXT_TAGS.duplicate(),
			"summary": "Settlement: none",
		}

	var compressed = packet_count > 1
	var round_label = _format_completed_round_label(rounds)
	var no_bonus_text = "No bonus rewards; normal per-round packets."
	var current_packet: Dictionary = packets[0]
	var current_round = int(current_packet.get("round", completed_rounds))
	var batch_total = max(packet_count, int(current_packet.get("batch_total", packet_count)))
	var current_index = clamp(int(current_packet.get("batch_index", 1)), 1, batch_total)
	var queued_count = max(0, packet_count - 1)
	var progress_text = "packet %s/%s R%s" % [current_index, batch_total, current_round]
	var summary = "Settlement: %s for %s. %s" % [progress_text, round_label, no_bonus_text]
	if compressed:
		summary = "Compressed settlement: %s for %s; %s queued. %s" % [
			progress_text,
			round_label,
			queued_count,
			no_bonus_text,
		]

	return {
		"ok": true,
		"reason": "ok",
		"settlementBatchId": _settlement_batch_id(rounds),
		"packet_count": packet_count,
		"rounds": rounds.duplicate(),
		"sourceWaveIds": _wave_ids_for_rounds(rounds),
		"rewardPacketIds": _reward_packet_ids_for_rounds(rounds),
		"compressed": compressed,
		"no_bonus": true,
		"noBonusRewards": true,
		"temporaryLockPolicy": {"onlyUnlockedRows": true},
		"forbiddenSummaryTextTags": SETTLEMENT_FORBIDDEN_SUMMARY_TEXT_TAGS.duplicate(),
		"current_round": current_round,
		"current_packet_index": current_index,
		"batch_total": batch_total,
		"queued_count": queued_count,
		"remaining_after_current": queued_count,
		"progress": progress_text,
		"summary": summary,
	}


func get_settlement_batch_summary() -> String:
	return str(get_settlement_batch_report().get("summary", "Settlement: none"))


func _round_id_suffix(round_number: int) -> String:
	var clamped_round = max(0, round_number)
	if clamped_round < 10:
		return "00%s" % clamped_round
	if clamped_round < 100:
		return "0%s" % clamped_round

	return str(clamped_round)


func _wave_id(round_number: int) -> String:
	return "wave_day_%s" % _round_id_suffix(round_number)


func _wave_spawn_plan_id(round_number: int) -> String:
	return "spawn_plan_day_%s" % _round_id_suffix(round_number)


func _wave_preview_card_id(round_number: int) -> String:
	return "wave_preview_card_day_%s" % _round_id_suffix(round_number)


func _lane_projection_id(round_number: int, player_count: int) -> String:
	return "lane_projection_day_%s_%sp" % [
		_round_id_suffix(round_number),
		clamp(player_count, 1, 4),
	]


func _wave_reward_packet_id(round_number: int) -> String:
	return "wave_reward_packet_day_%s" % _round_id_suffix(round_number)


func _settlement_batch_id(rounds: Array) -> String:
	var sorted_rounds: Array = []
	for round_value in rounds:
		sorted_rounds.append(int(round_value))
	sorted_rounds.sort()
	if sorted_rounds.is_empty():
		return ""
	if sorted_rounds.size() == 1:
		return "settlement_batch_day_%s" % _round_id_suffix(int(sorted_rounds[0]))

	return "settlement_batch_day_%s_to_%s" % [
		_round_id_suffix(int(sorted_rounds[0])),
		_round_id_suffix(int(sorted_rounds[sorted_rounds.size() - 1])),
	]


func _wave_ids_for_rounds(rounds: Array) -> Array:
	var ids: Array = []
	for round_value in rounds:
		ids.append(_wave_id(int(round_value)))
	return ids


func _reward_packet_ids_for_rounds(rounds: Array) -> Array:
	var ids: Array = []
	for round_value in rounds:
		ids.append(_wave_reward_packet_id(int(round_value)))
	return ids


func _current_reward_packet_id() -> String:
	if not active_reward_packet.is_empty():
		var packet_id = str(active_reward_packet.get("rewardPacketId", ""))
		if not packet_id.is_empty():
			return packet_id

	return _wave_reward_packet_id(_current_reward_report_round())


func _current_reward_settlement_batch_id() -> String:
	if not active_reward_packet.is_empty():
		var batch_id = str(active_reward_packet.get("generatedInsideSettlementBatchId", ""))
		if not batch_id.is_empty():
			return batch_id

		return _settlement_batch_id([int(active_reward_packet.get("round", _current_reward_report_round()))])

	return _settlement_batch_id([_current_reward_report_round()])


func _reward_choice_lock_id(reward_packet_id: String, player_id: String) -> String:
	return "reward_choice_lock_%s_%s" % [
		reward_packet_id,
		player_id,
	]


func _reward_choice_source_reason_tags(choice_type: String, card_id: String) -> Array:
	if choice_type == "decline_for_gold":
		return ["decline_for_shop_trim_gold", "candidate_count_unchanged", "rarity_unchanged"]

	var tags: Array = ["card_reward_candidate", "candidate_count_unchanged", "rarity_unchanged"]
	if not card_id.is_empty():
		tags.append("card_role_%s" % get_card_role(card_id))
		tags.append("card_rarity_%s" % get_card_rarity(card_id))
	return tags


func _build_reward_choice_lock(choice_type: String, chosen_card_id: String, decline_gold_added: int, player_id: String = "player_1") -> Dictionary:
	var reward_packet_id = _current_reward_packet_id()
	var chosen_value = null if choice_type == "decline_for_gold" else chosen_card_id
	return {
		"id": _reward_choice_lock_id(reward_packet_id, player_id),
		"settlementBatchId": _current_reward_settlement_batch_id(),
		"rewardPacketId": reward_packet_id,
		"playerId": player_id,
		"choiceType": choice_type,
		"chosenCardId": chosen_value,
		"declineGoldAdded": decline_gold_added,
		"isTemporary": false,
		"reversalDeadline": "before_first_paid_shop_vote",
		"requiresExplicitConfirm": false,
		"sourceReasonTags": _reward_choice_source_reason_tags(choice_type, chosen_card_id),
		"forbiddenLockTags": REWARD_CHOICE_LOCK_FORBIDDEN_TAGS.duplicate(),
		"candidateCountUnchanged": true,
		"rarityUnchanged": true,
		"goldDeclineUnchanged": true,
		"noBonusRewards": true,
	}


func _settlement_packet_choice_locked_event(lock: Dictionary) -> Dictionary:
	return {
		"event": "settlement_packet_choice_locked",
		"settlementBatchId": lock.get("settlementBatchId", ""),
		"rewardPacketId": lock.get("rewardPacketId", ""),
		"playerId": lock.get("playerId", "player_1"),
		"choiceType": lock.get("choiceType", "card"),
		"temporaryLocked": lock.get("isTemporary", false),
		"noBonusRewards": lock.get("noBonusRewards", true),
		"forbiddenLockTags": lock.get("forbiddenLockTags", []),
	}


func _reward_packet_id_from_packet(packet: Dictionary) -> String:
	var packet_id = str(packet.get("rewardPacketId", ""))
	if not packet_id.is_empty():
		return packet_id

	return _wave_reward_packet_id(int(packet.get("round", _current_reward_report_round())))


func _pending_reward_choice_lock_ids() -> Array:
	var ids: Array = []
	if not reward_offer.is_empty():
		ids.append(_reward_choice_lock_id(_current_reward_packet_id(), "player_1"))

	for packet_value in reward_queue:
		if typeof(packet_value) != TYPE_DICTIONARY:
			continue

		var packet: Dictionary = packet_value
		ids.append(_reward_choice_lock_id(_reward_packet_id_from_packet(packet), "player_1"))

	return ids


func _maintenance_gate_settlement_batch_id() -> String:
	var batch_id = ""
	if not active_reward_packet.is_empty():
		batch_id = str(active_reward_packet.get("generatedInsideSettlementBatchId", ""))
		if not batch_id.is_empty():
			return batch_id

	for packet_value in reward_queue:
		if typeof(packet_value) != TYPE_DICTIONARY:
			continue

		var packet: Dictionary = packet_value
		batch_id = str(packet.get("generatedInsideSettlementBatchId", ""))
		if not batch_id.is_empty():
			return batch_id

	var settlement_report = get_settlement_batch_report()
	batch_id = str(settlement_report.get("settlementBatchId", ""))
	if not batch_id.is_empty():
		return batch_id

	batch_id = str(last_reward_claim_report.get("settlementBatchId", ""))
	if not batch_id.is_empty():
		return batch_id

	return ""


func _maintenance_next_screen_type(pending_reward_choice_lock_ids: Array) -> String:
	if not artifact_offer.is_empty():
		return "artifact_choice"
	if _has_open_shop_offer():
		return "shop"
	if run_complete:
		return "mvp_result"
	if not pending_reward_choice_lock_ids.is_empty() or not reward_queue.is_empty():
		return "wave_preview"

	return "wave_preview"


func _maintenance_summary_tags(pending_reward_choice_lock_ids: Array) -> Array:
	var tags: Array = []
	if not last_round_report.is_empty():
		tags.append("combat_report_available")
	if not pending_reward_choice_lock_ids.is_empty():
		tags.append("pending_reward_choice")
	if reward_queue.size() > 0:
		tags.append("pending_settlement_packet")
	if not artifact_offer.is_empty():
		tags.append("pending_artifact_choice")
	if _has_open_shop_offer():
		tags.append("pending_shop")
	if bool(get_settlement_batch_report().get("compressed", false)):
		tags.append("compressed_settlement")
	tags.append("deck_state")
	tags.append("shop_trim_gold")
	tags.append("active_direction_preview")
	return tags


func _reward_to_maintenance_gate_id(settlement_batch_id: String) -> String:
	if settlement_batch_id.is_empty():
		return "reward_to_maintenance_gate_none"

	return "reward_to_maintenance_gate_%s" % settlement_batch_id


func get_reward_to_maintenance_gate_report() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var pending_reward_choice_lock_ids = _pending_reward_choice_lock_ids()
	var pending_curse_confirm_ids: Array = []
	var settlement_batch_id = _maintenance_gate_settlement_batch_id()
	var next_screen_type = _maintenance_next_screen_type(pending_reward_choice_lock_ids)
	var pending_reward_choices = not pending_reward_choice_lock_ids.is_empty() or not pending_curse_confirm_ids.is_empty()
	var pending_any = pending_reward_choices or not artifact_offer.is_empty() or _has_open_shop_offer() or reward_queue.size() > 0 or not active_reward_packet.is_empty()
	var can_start_paid_shop_vote = pending_reward_choice_lock_ids.is_empty() and pending_curse_confirm_ids.is_empty()
	return {
		"ok": true,
		"reason": "ok",
		"id": _reward_to_maintenance_gate_id(settlement_batch_id),
		"runId": "m0_local_debug_run",
		"settlementBatchId": null if settlement_batch_id.is_empty() else settlement_batch_id,
		"pendingRewardChoiceLockIds": pending_reward_choice_lock_ids,
		"pendingCurseConfirmIds": pending_curse_confirm_ids,
		"nextScreenType": next_screen_type,
		"firstPaidShopVoteStarted": int(run_stats.get("shop_cards_removed", 0)) > 0 or int(run_stats.get("shop_gold_spent", 0)) > 0,
		"maintenanceSummaryTags": _maintenance_summary_tags(pending_reward_choice_lock_ids),
		"forbiddenGateTags": REWARD_TO_MAINTENANCE_GATE_FORBIDDEN_TAGS.duplicate(),
		"state": "blocked" if pending_any else "clear",
		"canStartPaidShopVote": can_start_paid_shop_vote,
		"paidShopBlocked": not can_start_paid_shop_vote,
		"summary": "RewardToMaintenanceGate: %s -> %s | pending choices %s | paid shop %s" % [
			"blocked" if pending_any else "clear",
			next_screen_type,
			pending_reward_choice_lock_ids.size(),
			"ready" if can_start_paid_shop_vote else "held",
		],
	}


func get_seed_mana() -> int:
	return int(data.get("resources", {}).get("seedMana", 0)) + _artifact_effect_total("seedManaBonus")


func get_seed_mana_per_extra_front() -> int:
	return int(data.get("resources", {}).get("seedManaPerExtraFront", 0))


func get_seed_mana_for_player_count(player_count: int) -> int:
	var extra_fronts = max(0, get_active_directions(player_count).size() - 1)
	return get_seed_mana() + (extra_fronts * get_seed_mana_per_extra_front())


func get_extra_front_count(player_count: int) -> int:
	return max(0, get_active_directions(player_count).size() - 1)


func prepare_run_for_player_count(player_count: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if wave_active:
		return _reject("wave_active")

	if completed_rounds > 0 or current_round != 1 or has_pending_reward():
		return _reject("run_already_progressed")

	var target_mana = get_seed_mana_for_player_count(player_count)
	var gained = max(0, target_mana - mana)
	mana = max(mana, target_mana)
	if not run_stats.is_empty() and gained > 0:
		run_stats["front_seed_mana_gained"] = int(run_stats.get("front_seed_mana_gained", 0)) + gained
	return {
		"ok": true,
		"reason": "ok",
		"mana": mana,
		"gained": gained,
		"active_fronts": get_active_directions(player_count).size(),
	}


func get_max_hand_size() -> int:
	return int(data.get("resources", {}).get("maxHandSize", 5)) + _artifact_effect_total("maxHandBonus")


func get_opening_draw_count() -> int:
	return int(data.get("resources", {}).get("openingDraw", 5))


func get_seed_draw_count() -> int:
	return int(data.get("resources", {}).get("seedDraw", 0))


func get_seed_draw_per_extra_front() -> int:
	return int(data.get("resources", {}).get("seedDrawPerExtraFront", 0))


func get_seed_draw_count_for_player_count(player_count: int) -> int:
	var extra_fronts = get_extra_front_count(player_count)
	return get_seed_draw_count() + (extra_fronts * get_seed_draw_per_extra_front())


func get_discard_charges_per_run() -> int:
	return int(data.get("resources", {}).get("discardCharges", 0))


func get_discard_charge_cap() -> int:
	return int(data.get("resources", {}).get("discardChargeCap", get_discard_charges_per_run()))


func get_discard_mana_gain() -> int:
	return int(data.get("resources", {}).get("discardManaGain", 0))


func get_starting_gold() -> int:
	return int(data.get("resources", {}).get("startingGold", 0))


func get_starting_boss_shards() -> int:
	return int(data.get("resources", {}).get("startingBossShards", 0))


func get_mana_per_kill() -> int:
	return int(data.get("rewards", {}).get("manaPerKill", 0)) + _artifact_effect_total("manaPerKillBonus")


func get_gold_per_kill() -> int:
	return int(data.get("rewards", {}).get("goldPerKill", 0)) + _artifact_effect_total("goldPerKillBonus")


func get_draw_gauge_per_kill() -> int:
	return int(data.get("rewards", {}).get("drawGaugePerKill", 0)) + _artifact_effect_total("drawGaugePerKillBonus")


func get_draw_gauge_per_card() -> int:
	return int(data.get("rewards", {}).get("drawGaugePerCard", 1))


func get_card_offer_count() -> int:
	return int(data.get("rewards", {}).get("cardOfferCount", 3))


func get_card_reward_gold() -> int:
	return int(data.get("rewards", {}).get("cardRewardGold", 0))


func get_boss_shard_reward() -> int:
	return int(data.get("rewards", {}).get("bossShardReward", 0))


func get_artifact_offer_count() -> int:
	return int(data.get("rewards", {}).get("artifactOfferCount", 0))


func get_artifact_action_limit() -> int:
	return max(0, int(data.get("rewards", {}).get("artifactActionLimit", 1)))


func get_artifact_actions_remaining() -> int:
	return artifact_actions_remaining


func get_artifact_action_summary() -> String:
	return "artifact action %s/%s" % [
		artifact_actions_remaining,
		get_artifact_action_limit(),
	]


func get_artifact_slot_hard_cap() -> int:
	return max(1, int(data.get("rewards", {}).get("artifactSlotHardCap", ARTIFACT_SLOT_HARD_CAP)))


func get_artifact_slot_limit() -> int:
	var base_limit = max(1, int(data.get("rewards", {}).get("artifactSlotLimit", 3)))
	return min(get_artifact_slot_hard_cap(), base_limit + _artifact_effect_total("artifactSlotBonus"))


func get_dormant_artifact_limit() -> int:
	return max(0, int(data.get("rewards", {}).get("dormantArtifactLimit", 2)))


func get_boss_shop_round_interval() -> int:
	return int(data.get("shop", {}).get("bossShopEveryRounds", 0))


func get_shop_deck_removal_offer_count() -> int:
	return int(data.get("shop", {}).get("deckRemovalOfferCount", 0))


func get_shop_deck_removal_limit() -> int:
	return int(data.get("shop", {}).get("deckRemovalLimit", 0))


func get_shop_deck_removal_gold_cost() -> int:
	return int(data.get("shop", {}).get("deckRemovalGoldCost", 0))


func get_shop_purchase_limit() -> int:
	var shop_data: Dictionary = data.get("shop", {})
	if shop_data.has("purchaseLimit"):
		return int(shop_data.get("purchaseLimit", 0))

	return max(0, get_shop_deck_removal_limit())


func get_shop_service_offer_ids() -> Array:
	var service_ids = data.get("shop", {}).get("serviceOfferIds", [])
	if typeof(service_ids) != TYPE_ARRAY:
		return []

	return service_ids.duplicate()


func get_shop_services_data() -> Dictionary:
	var services = data.get("shop", {}).get("services", {})
	if typeof(services) != TYPE_DICTIONARY:
		return {}

	return services.duplicate(true)


func get_shop_service_data(service_id: String) -> Dictionary:
	var services = get_shop_services_data()
	if not services.has(service_id):
		return {}

	var service = services.get(service_id, {})
	if typeof(service) != TYPE_DICTIONARY:
		return {}

	return service.duplicate(true)


func get_shop_service_label(service_id: String) -> String:
	return str(get_shop_service_data(service_id).get("label", service_id))


func get_mana() -> int:
	return mana


func get_gold() -> int:
	return gold


func get_boss_shards() -> int:
	return boss_shards


func get_draw_gauge() -> int:
	return draw_gauge


func get_discard_charges() -> int:
	return discard_charges


func get_hand() -> Array:
	return hand.duplicate()


func get_draw_count() -> int:
	return draw_pile.size()


func get_discard_count() -> int:
	return discard_pile.size()


func get_deck_zone_counts(card_id: String = "") -> Dictionary:
	var hand_count = hand.size()
	var draw_count = draw_pile.size()
	var discard_count = discard_pile.size()
	if not card_id.is_empty():
		hand_count = _count_card_in_array(hand, card_id)
		draw_count = _count_card_in_array(draw_pile, card_id)
		discard_count = _count_card_in_array(discard_pile, card_id)

	return {
		"hand_count": hand_count,
		"draw_count": draw_count,
		"discard_count": discard_count,
		"total_count": hand_count + draw_count + discard_count,
	}


func get_deck_cycle_summary() -> String:
	var counts = get_deck_zone_counts()
	var next_draw_text = "%s card(s) before discard reshuffle" % counts.get("draw_count", 0)
	if int(counts.get("draw_count", 0)) <= 0:
		next_draw_text = "next draw reshuffles discard" if int(counts.get("discard_count", 0)) > 0 else "no cards available to draw"

	return "Deck: hand=%s draw=%s discard=%s total=%s | %s" % [
		counts.get("hand_count", 0),
		counts.get("draw_count", 0),
		counts.get("discard_count", 0),
		counts.get("total_count", 0),
		next_draw_text,
	]


func get_shop_trim_gold_progress_summary(gold_value: int = -1) -> String:
	var target_gold = gold if gold_value < 0 else max(0, gold_value)
	var gold_cost = get_shop_deck_removal_gold_cost()
	if gold_cost <= 0:
		return "no shop trim gold cost"

	if target_gold >= gold_cost:
		return "%s/%s ready" % [target_gold, gold_cost]

	return "%s/%s need %s" % [
		target_gold,
		gold_cost,
		gold_cost - target_gold,
	]


func get_economy_summary() -> String:
	var counts = get_deck_zone_counts()
	var card_reward_gold = get_card_reward_gold()
	var reward_gold_text = ""
	if card_reward_gold > 0:
		reward_gold_text = " | take gold -> %s" % get_shop_trim_gold_progress_summary(gold + card_reward_gold)

	return "Economy: deck=%s cards | shop trim gold %s | boss shards %s%s" % [
		counts.get("total_count", 0),
		get_shop_trim_gold_progress_summary(),
		boss_shards,
		reward_gold_text,
	]


func get_card_reward_gold_choice_summary() -> String:
	var counts = get_deck_zone_counts()
	var gold_gain = get_card_reward_gold()
	var gold_after = gold + gold_gain
	return "Gold choice: +%s gold (%s -> %s) | shop trim %s | deck stays %s cards" % [
		gold_gain,
		gold,
		gold_after,
		get_shop_trim_gold_progress_summary(gold_after),
		counts.get("total_count", 0),
	]


func get_round_preparation_report(player_count: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var active_directions = get_active_directions(player_count)
	var extra_fronts = get_extra_front_count(player_count)
	var seed_mana = get_seed_mana_for_player_count(player_count)
	var base_seed_mana = get_seed_mana()
	var seed_draw = get_seed_draw_count_for_player_count(player_count)
	var planned_report = {
		"ok": true,
		"reason": "ok",
		"mode": "planned",
		"active_fronts": active_directions.size(),
		"active_directions": active_directions.duplicate(),
		"extra_fronts": extra_fronts,
		"seed_mana": seed_mana,
		"front_seed_mana": max(0, seed_mana - base_seed_mana),
		"seed_draw": seed_draw,
		"front_seed_draw": max(0, seed_draw - get_seed_draw_count()),
		"discard_charges": get_discard_charges_per_run(),
		"hand_count": hand.size(),
		"max_hand_size": get_max_hand_size(),
		"draw_count": draw_pile.size(),
		"discard_count": discard_pile.size(),
	}
	planned_report["summary"] = _format_round_preparation_summary(planned_report)

	if last_round_resource_report.is_empty() or int(last_round_resource_report.get("round", 0)) != current_round:
		return planned_report

	var actual_report = last_round_resource_report.duplicate(true)
	actual_report["summary"] = _format_round_preparation_summary(actual_report)
	return actual_report


func get_round_preparation_summary(player_count: int) -> String:
	var report = get_round_preparation_report(player_count)
	if not bool(report.get("ok", false)):
		return "Round prep: unavailable (%s)" % report.get("reason", "unknown")

	return str(report.get("summary", "Round prep: -"))


func get_card_data(card_id: String) -> Dictionary:
	return data.get("cards", {}).get(card_id, {})


func get_card_label(card_id: String) -> String:
	var card = get_card_data(card_id)
	return str(card.get("label", card_id))


func get_card_rarity(card_id: String) -> String:
	var card = get_card_data(card_id)
	var rarity = str(card.get("rarity", "common"))
	return rarity if CARD_RARITIES.has(rarity) else "common"


func get_card_rarity_label(card_id: String) -> String:
	match get_card_rarity(card_id):
		"rare":
			return "Rare"
		"uncommon":
			return "Uncommon"
		_:
			return "Common"


func get_card_reward_min_round(card_id: String) -> int:
	var card = get_card_data(card_id)
	return max(1, int(card.get("rewardMinRound", 1)))


func get_card_unlock_summary(card_id: String) -> String:
	return "R%s+" % get_card_reward_min_round(card_id)


func get_card_role(card_id: String) -> String:
	var card = get_card_data(card_id)
	match str(card.get("kind", "")):
		"place_structure":
			if str(card.get("structureType", "")) == "barricade":
				return "Maze"
			return "Defense"
		"damage_enemy":
			return "Damage"
		"repair_structure":
			return "Repair"
		"draw_cards":
			return "Draw"
		_:
			return "Card"


func get_card_effect_summary(card_id: String) -> String:
	var card = get_card_data(card_id)
	if card.is_empty():
		return "Unknown card."

	match str(card.get("kind", "")):
		"place_structure":
			return "Place %s." % str(card.get("structureType", "structure"))
		"damage_enemy":
			return "Deal %s damage to one enemy." % card.get("damage", 0)
		"repair_structure":
			return "Repair %s HP on a damaged structure." % card.get("repair", 0)
		"draw_cards":
			return "Draw %s card." % card.get("draw", 0)
		_:
			return "No effect summary."


func get_card_deck_count(card_id: String) -> int:
	return _count_card_in_array(hand, card_id) + _count_card_in_array(draw_pile, card_id) + _count_card_in_array(discard_pile, card_id)


func get_card_reward_report(card_id: String) -> Dictionary:
	var card = get_card_data(card_id)
	if card.is_empty():
		return _reject("unknown_card")

	var reward_round = _current_reward_report_round()
	var zone_counts = get_deck_zone_counts(card_id)
	var hand_count = int(zone_counts.get("hand_count", 0))
	var draw_count = int(zone_counts.get("draw_count", 0))
	var discard_count = int(zone_counts.get("discard_count", 0))
	var deck_count = int(zone_counts.get("total_count", 0))
	return {
		"ok": true,
		"reason": "ok",
		"card_id": card_id,
		"label": str(card.get("label", card_id)),
		"cost": int(card.get("cost", 0)),
		"kind": str(card.get("kind", "")),
		"rarity": get_card_rarity(card_id),
		"rarity_label": get_card_rarity_label(card_id),
		"reward_min_round": get_card_reward_min_round(card_id),
		"unlock": get_card_unlock_summary(card_id),
		"reward_unlocked": _is_reward_card_unlocked(card_id, reward_round),
		"role": get_card_role(card_id),
		"effect": get_card_effect_summary(card_id),
		"deck_count": deck_count,
		"hand_count": hand_count,
		"draw_count": draw_count,
		"discard_count": discard_count,
		"deck_zone_summary": _format_card_zone_summary(zone_counts),
		"claim_preview": "Adds 1 copy to discard pile.",
		"summary": "%s [%s %s] %s Deck copies: %s." % [
			card.get("label", card_id),
			get_card_rarity_label(card_id),
			card.get("cost", 0),
			get_card_effect_summary(card_id),
			deck_count,
		],
	}


func card_requires_tile(card_id: String) -> bool:
	var card = get_card_data(card_id)
	return TILE_TARGET_CARD_KINDS.has(str(card.get("kind", "")))


func get_class_ids() -> Array:
	var ids: Array = []
	var classes_data: Dictionary = data.get("classes", {})
	for class_id in classes_data.keys():
		ids.append(str(class_id))
	ids.sort()
	return ids


func get_autoplay_class_ids() -> Array:
	var ids: Array = []
	var classes_data: Dictionary = data.get("classes", {})
	var configured_ids: Array = data.get("debug", {}).get("autoplayClassIds", [])

	for class_id in configured_ids:
		if classes_data.has(str(class_id)):
			ids.append(str(class_id))

	if ids.is_empty():
		return get_class_ids()

	return ids


func get_class_data(class_id: String) -> Dictionary:
	return data.get("classes", {}).get(class_id, {})


func get_class_label(class_id: String) -> String:
	var class_data = get_class_data(class_id)
	return str(class_data.get("label", class_id))


func get_class_autoplay_profile(class_id: String) -> Dictionary:
	return get_class_data(class_id).get("autoplay", {})


func get_class_effects(class_id: String) -> Dictionary:
	return get_class_data(class_id).get("effects", {})


func get_artifact_data(artifact_id: String) -> Dictionary:
	return data.get("artifacts", {}).get(artifact_id, {})


func get_artifact_label(artifact_id: String) -> String:
	var artifact_data = get_artifact_data(artifact_id)
	return str(artifact_data.get("label", artifact_id))


func get_artifact_effect_summary(artifact_id: String) -> String:
	var artifact = get_artifact_data(artifact_id)
	if artifact.is_empty():
		return "Unknown artifact."

	var effects: Dictionary = artifact.get("effects", {})
	if effects.is_empty():
		return "No passive effect."

	var parts = PackedStringArray()
	for effect_key in effects.keys():
		parts.append(_format_artifact_effect(str(effect_key), int(effects[effect_key])))
	return ", ".join(parts)


func get_artifact_reward_report(artifact_id: String) -> Dictionary:
	var artifact = get_artifact_data(artifact_id)
	if artifact.is_empty():
		return _reject("unknown_artifact")

	var equipped = equipped_artifacts.has(artifact_id)
	var slot_report = get_artifact_slot_report()
	var slots_full = bool(slot_report.get("slots_full", false))
	var action_available = artifact_actions_remaining > 0
	var block_reason = "ok"
	if not action_available:
		block_reason = "artifact_action_unavailable"
	elif equipped:
		block_reason = "artifact_already_equipped"
	return {
		"ok": true,
		"reason": block_reason,
		"artifact_id": artifact_id,
		"label": str(artifact.get("label", artifact_id)),
		"effect": get_artifact_effect_summary(artifact_id),
		"equipped": equipped,
		"can_claim": block_reason == "ok",
		"artifact_actions_remaining": artifact_actions_remaining,
		"artifact_action_limit": get_artifact_action_limit(),
		"artifact_actions_after": max(0, artifact_actions_remaining - 1) if block_reason == "ok" else artifact_actions_remaining,
		"equipped_count": equipped_artifacts.size(),
		"slot_limit": int(slot_report.get("slot_limit", 0)),
		"slots_full": slots_full,
		"requires_replacement": slots_full and not equipped,
		"dormant_count": int(slot_report.get("dormant_count", 0)),
		"dormant_limit": int(slot_report.get("dormant_limit", 0)),
		"loadout_summary": str(slot_report.get("summary", "")),
		"summary": "%s | %s | slots %s/%s%s%s" % [
			artifact.get("label", artifact_id),
			get_artifact_effect_summary(artifact_id),
			equipped_artifacts.size(),
			slot_report.get("slot_limit", 0),
			" | already equipped" if equipped else "",
			" | replacement required" if slots_full and not equipped else "",
		],
	}


func get_artifact_offer_reports() -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	for artifact_id in artifact_offer:
		var report = get_artifact_reward_report(str(artifact_id))
		if bool(report.get("ok", false)):
			reports.append(report)
	return reports


func get_artifact_offer_summary() -> String:
	if artifact_offer.is_empty():
		return "Artifact: none"

	var parts = PackedStringArray()
	for report in get_artifact_offer_reports():
		parts.append("%s: %s" % [
			report.get("label", report.get("artifact_id", "?")),
			report.get("effect", ""),
		])

	var recommendation = get_artifact_recommendation_report()
	var recommendation_text = ""
	if bool(recommendation.get("ok", false)):
		recommendation_text = " | Suggested: %s" % recommendation.get("label", recommendation.get("artifact_id", "?"))

	var slot_report = get_artifact_slot_report()
	var slot_text = " | %s | %s" % [
		slot_report.get("summary", get_artifact_loadout_summary()),
		get_artifact_action_summary(),
	]
	if bool(slot_report.get("slots_full", false)):
		slot_text += " | slots full: replace one or keep current"

	return "Artifact: choose 1 of %s | %s%s%s" % [
		artifact_offer.size(),
		" | ".join(parts),
		recommendation_text,
		slot_text,
	]


func get_artifact_recommendation_report() -> Dictionary:
	if artifact_offer.is_empty():
		return {
			"ok": false,
			"reason": "no_artifact_offer",
			"artifact_id": "",
			"index": -1,
			"score": 0,
			"reason_text": "No artifact offer is waiting.",
			"detail_text": "",
			"summary": "Artifact recommendation: none",
			"candidates": [],
		}

	var best_index = -1
	var best_artifact_id = ""
	var best_score = -999999
	var candidates: Array[Dictionary] = []
	for index in range(artifact_offer.size()):
		var artifact_id = str(artifact_offer[index])
		var score = _artifact_recommendation_score(artifact_id)
		var reason_text = _artifact_recommendation_reason(artifact_id)
		var candidate = {
			"artifact_id": artifact_id,
			"label": get_artifact_label(artifact_id),
			"index": index,
			"score": score,
			"reason_text": reason_text,
			"detail_text": _artifact_recommendation_detail(artifact_id, reason_text),
		}
		candidates.append(candidate)
		if best_artifact_id.is_empty() or score > best_score:
			best_index = index
			best_artifact_id = artifact_id
			best_score = score

	if best_artifact_id.is_empty():
		return {
			"ok": false,
			"reason": "no_valid_artifact",
			"artifact_id": "",
			"index": -1,
			"score": 0,
			"reason_text": "No valid artifact is available.",
			"detail_text": "",
			"summary": "Artifact recommendation: none",
			"candidates": candidates,
		}

	var reason_text = _artifact_recommendation_reason(best_artifact_id)
	var detail_text = _artifact_recommendation_detail(best_artifact_id, reason_text)
	return {
		"ok": true,
		"reason": "ok",
		"artifact_id": best_artifact_id,
		"label": get_artifact_label(best_artifact_id),
		"index": best_index,
		"score": best_score,
		"reason_text": reason_text,
		"detail_text": detail_text,
		"summary": "Suggested artifact: %s - %s" % [
			get_artifact_label(best_artifact_id),
			reason_text,
		],
		"candidates": candidates,
	}


func get_artifact_recommendation_summary() -> String:
	return str(get_artifact_recommendation_report().get("summary", "Artifact recommendation: none"))


func get_shop_offer() -> Array:
	return shop_offer.duplicate()


func get_shop_service_offer() -> Array:
	return shop_service_offer.duplicate()


func has_open_shop_offer() -> bool:
	return _has_open_shop_offer()


func _has_open_shop_offer() -> bool:
	return not shop_offer.is_empty() or not shop_service_offer.is_empty()


func get_shop_removals_remaining() -> int:
	return shop_removals_remaining


func get_shop_purchases_remaining() -> int:
	return shop_purchases_remaining


func get_card_removal_report(card_id: String) -> Dictionary:
	var card = get_card_data(card_id)
	if card.is_empty():
		return _reject("unknown_card")

	var zone_counts = get_deck_zone_counts(card_id)
	var deck_count = int(zone_counts.get("total_count", 0))
	var gold_cost = get_shop_deck_removal_gold_cost()
	var can_afford = gold >= gold_cost
	var gate_report = get_reward_to_maintenance_gate_report()
	var paid_shop_blocked = shop_offer.has(card_id) and not bool(gate_report.get("canStartPaidShopVote", true))
	var block_reason = "ok"
	if not _has_open_shop_offer():
		block_reason = "no_shop_offer"
	elif not shop_offer.has(card_id):
		block_reason = "shop_card_not_offered"
	elif shop_purchases_remaining <= 0:
		block_reason = "shop_purchase_unavailable"
	elif shop_removals_remaining <= 0:
		block_reason = "shop_removal_unavailable"
	elif paid_shop_blocked:
		block_reason = "reward_choice_pending"
	elif deck_count <= 0:
		block_reason = "card_not_in_deck"
	elif not can_afford:
		block_reason = "not_enough_gold"
	var can_remove = block_reason == "ok"
	return {
		"ok": true,
		"reason": block_reason,
		"shop_option_type": "remove_card",
		"choice_type": "card",
		"card_id": card_id,
		"label": get_card_label(card_id),
		"cost": int(card.get("cost", 0)),
		"kind": str(card.get("kind", "")),
		"rarity": get_card_rarity(card_id),
		"rarity_label": get_card_rarity_label(card_id),
		"role": get_card_role(card_id),
		"effect": get_card_effect_summary(card_id),
		"deck_count": deck_count,
		"deck_count_after": max(0, deck_count - 1),
		"hand_count": int(zone_counts.get("hand_count", 0)),
		"draw_count": int(zone_counts.get("draw_count", 0)),
		"discard_count": int(zone_counts.get("discard_count", 0)),
		"deck_zone_summary": _format_card_zone_summary(zone_counts),
		"gold": gold,
		"gold_cost": gold_cost,
		"gold_after": gold - gold_cost if can_afford else gold,
		"can_afford": can_afford,
		"removal_preview": "Pay %s gold to remove 1 copy permanently." % gold_cost,
		"can_remove": can_remove,
		"can_buy": can_remove,
		"rewardToMaintenanceGate": gate_report,
		"paid_shop_blocked": paid_shop_blocked,
		"summary": "%s [%s] %s gold | copies %s -> %s | %s" % [
			get_card_label(card_id),
			get_card_rarity_label(card_id),
			gold_cost,
			deck_count,
			max(0, deck_count - 1),
			get_card_effect_summary(card_id),
		],
	}


func get_shop_offer_reports() -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	for card_id in shop_offer:
		var report = get_card_removal_report(str(card_id))
		if bool(report.get("ok", false)):
			reports.append(report)
	return reports


func get_shop_service_report(service_id: String, reactivation_dormant_artifact_id: String = "", reactivation_replaced_artifact_id: String = "") -> Dictionary:
	var service = get_shop_service_data(service_id)
	if service.is_empty():
		return _reject("unknown_shop_service")

	var service_type = str(service.get("type", ""))
	var label = get_shop_service_label(service_id)
	var gold_cost = max(0, int(service.get("goldCost", 0)))
	var boss_shard_cost = max(0, int(service.get("bossShardCost", 0)))
	var can_afford_gold = gold >= gold_cost
	var can_afford_shards = boss_shards >= boss_shard_cost
	var can_afford = can_afford_gold and can_afford_shards
	var gate_report = get_reward_to_maintenance_gate_report()
	var paid_shop_blocked = shop_service_offer.has(service_id) and not bool(gate_report.get("canStartPaidShopVote", true))
	var base_max = max(1, int(data.get("base", {}).get("hp", 100)))
	var base_damage = max(0, base_max - base_hp)
	var heal = max(0, int(service.get("heal", 0)))
	var base_hp_after = min(base_max, base_hp + heal)
	var hp_bonus = max(0, int(service.get("hpBonus", 0)))
	var affected_structures = structures.size()
	var uses_artifact_action = service_type == "reactivate_dormant_artifact"
	var artifact_action_after = max(0, artifact_actions_remaining - 1) if uses_artifact_action else artifact_actions_remaining
	var reactivation_plan: Dictionary = {}
	if service_type == "reactivate_dormant_artifact":
		reactivation_plan = get_dormant_reactivation_plan(service_id, reactivation_dormant_artifact_id, reactivation_replaced_artifact_id)

	var block_reason = "ok"
	if not _has_open_shop_offer():
		block_reason = "no_shop_offer"
	elif not shop_service_offer.has(service_id):
		block_reason = "shop_service_not_offered"
	elif shop_purchases_remaining <= 0:
		block_reason = "shop_purchase_unavailable"
	elif paid_shop_blocked:
		block_reason = "reward_choice_pending"
	elif not can_afford_gold:
		block_reason = "not_enough_gold"
	elif not can_afford_shards:
		block_reason = "not_enough_boss_shards"
	elif uses_artifact_action and artifact_actions_remaining <= 0:
		block_reason = "artifact_action_unavailable"
	elif service_type == "restore_base":
		if heal <= 0:
			block_reason = "shop_service_disabled"
		elif bool(service.get("requiresBaseDamage", false)) and base_damage <= 0:
			block_reason = "base_full"
	elif service_type == "structure_hp_boost":
		if hp_bonus <= 0:
			block_reason = "shop_service_disabled"
		elif structures.is_empty():
			block_reason = "no_structures"
	elif service_type == "reactivate_dormant_artifact":
		if not bool(reactivation_plan.get("ok", false)):
			block_reason = str(reactivation_plan.get("reason", "no_dormant_artifact"))
	elif service_type.is_empty():
		block_reason = "unknown_shop_service_type"
	else:
		block_reason = "unknown_shop_service_type"

	var can_buy = block_reason == "ok"
	var summary = str(service.get("summary", label))
	var purchase_preview = summary
	if service_type == "restore_base":
		purchase_preview = "Pay %s gold to restore %s base HP (%s -> %s)." % [
			gold_cost,
			min(heal, base_damage),
			base_hp,
			base_hp_after,
		]
	elif service_type == "structure_hp_boost":
		purchase_preview = "Pay %s gold to reinforce %s structure(s) by +%s HP." % [
			gold_cost,
			affected_structures,
			hp_bonus,
		]
	elif service_type == "reactivate_dormant_artifact":
		var dormant_label = str(reactivation_plan.get("dormant_artifact_label", "Dormant artifact"))
		var replaced_label = str(reactivation_plan.get("replaced_artifact_label", ""))
		if replaced_label.is_empty():
			purchase_preview = "Pay %s boss shard and 1 artifact action to reactivate %s into an empty artifact slot." % [
				boss_shard_cost,
				dormant_label,
			]
		else:
			purchase_preview = "Pay %s boss shard and 1 artifact action to reactivate %s; %s becomes dormant." % [
				boss_shard_cost,
				dormant_label,
				replaced_label,
			]

	return {
		"ok": true,
		"reason": block_reason,
		"shop_option_type": "service",
		"choice_type": "service",
		"service_id": service_id,
		"label": label,
		"service_type": service_type,
		"effect": summary,
		"summary": summary,
		"gold": gold,
		"gold_cost": gold_cost,
		"gold_after": gold - gold_cost if can_afford_gold else gold,
		"boss_shards": boss_shards,
		"boss_shard_cost": boss_shard_cost,
		"boss_shards_after": boss_shards - boss_shard_cost if can_afford_shards else boss_shards,
		"uses_artifact_action": uses_artifact_action,
		"artifact_actions_remaining": artifact_actions_remaining,
		"artifact_action_limit": get_artifact_action_limit(),
		"artifact_actions_after": artifact_action_after if can_buy else artifact_actions_remaining,
		"can_afford_gold": can_afford_gold,
		"can_afford_shards": can_afford_shards,
		"can_afford": can_afford,
		"can_buy": can_buy,
		"base_hp": base_hp,
		"base_max_hp": base_max,
		"base_damage": base_damage,
		"base_hp_after": base_hp_after,
		"heal": heal,
		"hp_bonus": hp_bonus,
		"affected_structures": affected_structures,
		"purchase_preview": purchase_preview,
		"dormant_artifact_id": str(reactivation_plan.get("dormant_artifact_id", "")),
		"dormant_artifact_label": str(reactivation_plan.get("dormant_artifact_label", "")),
		"dormant_artifact_effect": str(reactivation_plan.get("dormant_artifact_effect", "")),
		"replaced_artifact_id": str(reactivation_plan.get("replaced_artifact_id", "")),
		"replaced_artifact_label": str(reactivation_plan.get("replaced_artifact_label", "")),
		"replaced_artifact_effect": str(reactivation_plan.get("replaced_artifact_effect", "")),
		"loadout_summary": str(reactivation_plan.get("loadout_summary", get_artifact_loadout_summary())),
		"rewardToMaintenanceGate": gate_report,
		"paid_shop_blocked": paid_shop_blocked,
	}


func get_shop_service_reports() -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	for service_id in shop_service_offer:
		var report = get_shop_service_report(str(service_id))
		if bool(report.get("ok", false)):
			reports.append(report)
	return reports


func get_shop_option_reports(player_count: int = 1, class_id: String = "") -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	for report in get_shop_offer_reports():
		report["shop_option_index"] = reports.size()
		reports.append(report)

	for report in get_shop_service_reports():
		report["shop_option_index"] = reports.size()
		reports.append(report)

	return reports


func get_shop_option_report_at(index: int, player_count: int = 1, class_id: String = "") -> Dictionary:
	var reports = get_shop_option_reports(player_count, class_id)
	if index < 0 or index >= reports.size():
		return _reject("shop_option_out_of_range")

	return reports[index].duplicate(true)


func get_shop_offer_summary(player_count: int = 1, class_id: String = "") -> String:
	if not _has_open_shop_offer():
		return get_last_shop_summary()

	var removal_parts = PackedStringArray()
	for report in get_shop_offer_reports():
		removal_parts.append("%s %sg copies %s -> %s" % [
			report.get("label", report.get("card_id", "?")),
			report.get("gold_cost", 0),
			report.get("deck_count", 0),
			report.get("deck_count_after", 0),
		])

	var service_parts = PackedStringArray()
	for report in get_shop_service_reports():
		if str(report.get("service_type", "")) == "reactivate_dormant_artifact":
			service_parts.append("%s %s shard, action %s/%s" % [
				report.get("label", report.get("service_id", "?")),
				report.get("boss_shard_cost", 0),
				report.get("artifact_actions_remaining", artifact_actions_remaining),
				report.get("artifact_action_limit", get_artifact_action_limit()),
			])
		else:
			service_parts.append("%s %sg" % [
				report.get("label", report.get("service_id", "?")),
				report.get("gold_cost", 0),
			])

	var recommendation = get_shop_recommendation_report(player_count, class_id)
	var recommendation_text = ""
	if bool(recommendation.get("ok", false)):
		recommendation_text = " | Suggested: %s" % recommendation.get("label", recommendation.get("card_id", recommendation.get("service_id", "?")))
	var vote_text = ""
	if has_active_shop_purchase_vote():
		vote_text = " | %s" % get_shop_purchase_vote_summary(player_count)

	var removal_text = "none" if removal_parts.is_empty() else " | ".join(removal_parts)
	var service_text = "none" if service_parts.is_empty() else " | ".join(service_parts)
	return "Shop: gold %s | purchases %s | remove %s card(s) | %s | services %s%s%s" % [
		gold,
		shop_purchases_remaining,
		shop_removals_remaining,
		removal_text,
		service_text,
		recommendation_text,
		vote_text,
	]


func get_shop_recommendation_report(player_count: int = 1, class_id: String = "") -> Dictionary:
	if not _has_open_shop_offer():
		return {
			"ok": false,
			"reason": "no_shop_offer",
			"card_id": "",
			"service_id": "",
			"choice_type": "none",
			"index": -1,
			"score": 0,
			"reason_text": "No shop offer is waiting.",
			"detail_text": "",
			"summary": "Shop recommendation: none",
			"candidates": [],
		}

	var best_index = -1
	var best_choice_type = ""
	var best_choice_id = ""
	var best_score = -999999
	var candidates: Array[Dictionary] = []
	var option_reports = get_shop_option_reports(player_count, class_id)
	for index in range(option_reports.size()):
		var report: Dictionary = option_reports[index]
		var option_type = str(report.get("shop_option_type", "remove_card"))
		var choice_type = "service" if option_type == "service" else "card"
		var choice_id = str(report.get("service_id", "")) if choice_type == "service" else str(report.get("card_id", ""))
		var can_buy = bool(report.get("can_buy", report.get("can_remove", false)))
		var score = -999999
		var reason_text = _short_reject_reason(str(report.get("reason", "blocked")))
		var detail_text = ""
		if can_buy and choice_type == "service":
			score = _shop_service_recommendation_score(choice_id)
			reason_text = _shop_service_recommendation_reason(choice_id)
			detail_text = _shop_service_recommendation_detail(choice_id, reason_text)
		elif can_buy:
			score = _shop_removal_recommendation_score(choice_id, player_count, class_id)
			reason_text = _shop_removal_recommendation_reason(choice_id, player_count, class_id)
			detail_text = _shop_removal_recommendation_detail(choice_id, player_count, class_id, reason_text)

		var candidate = {
			"card_id": choice_id if choice_type == "card" else "",
			"service_id": choice_id if choice_type == "service" else "",
			"choice_type": choice_type,
			"shop_option_type": option_type,
			"label": str(report.get("label", choice_id)),
			"index": index,
			"score": score,
			"can_remove": bool(report.get("can_remove", false)),
			"can_buy": can_buy,
			"reason_text": reason_text,
			"detail_text": detail_text,
		}
		candidates.append(candidate)
		if can_buy and (best_choice_id.is_empty() or score > best_score):
			best_index = index
			best_choice_type = choice_type
			best_choice_id = choice_id
			best_score = score

	if best_choice_id.is_empty():
		return {
			"ok": false,
			"reason": "no_shop_purchase_available",
			"card_id": "",
			"service_id": "",
			"choice_type": "none",
			"index": -1,
			"score": 0,
			"reason_text": "No offered shop choice can be bought right now.",
			"detail_text": "",
			"summary": "Shop recommendation: none",
			"candidates": candidates,
		}

	var best_label = get_card_label(best_choice_id) if best_choice_type == "card" else get_shop_service_label(best_choice_id)
	var reason_text = _shop_removal_recommendation_reason(best_choice_id, player_count, class_id) if best_choice_type == "card" else _shop_service_recommendation_reason(best_choice_id)
	var detail_text = _shop_removal_recommendation_detail(best_choice_id, player_count, class_id, reason_text) if best_choice_type == "card" else _shop_service_recommendation_detail(best_choice_id, reason_text)
	return {
		"ok": true,
		"reason": "ok",
		"card_id": best_choice_id if best_choice_type == "card" else "",
		"service_id": best_choice_id if best_choice_type == "service" else "",
		"choice_type": best_choice_type,
		"shop_option_type": "service" if best_choice_type == "service" else "remove_card",
		"label": best_label,
		"index": best_index,
		"score": best_score,
		"reason_text": reason_text,
		"detail_text": detail_text,
		"summary": "Suggested %s: %s - %s" % [
			"service" if best_choice_type == "service" else "removal",
			best_label,
			reason_text,
		],
		"candidates": candidates,
	}


func get_shop_recommendation_summary(player_count: int = 1, class_id: String = "") -> String:
	return str(get_shop_recommendation_report(player_count, class_id).get("summary", "Shop recommendation: none"))


func get_last_shop_report() -> Dictionary:
	if last_shop_report.is_empty():
		return {
			"ok": false,
			"reason": "no_shop_action",
		}

	return last_shop_report.duplicate(true)


func get_last_shop_summary() -> String:
	if last_shop_report.is_empty():
		return "Shop: none"

	if bool(last_shop_report.get("skipped", false)):
		return "Shop: last offer skipped."

	if str(last_shop_report.get("shop_action_type", "")) == "service":
		if str(last_shop_report.get("service_type", "")) == "reactivate_dormant_artifact":
			var replaced_text = ""
			if not str(last_shop_report.get("replaced_artifact_label", "")).is_empty():
				replaced_text = " | %s now dormant" % last_shop_report.get("replaced_artifact_label", "")
			return "Shop: last service %s | boss shards %s -> %s | reactivated %s%s | %s" % [
				last_shop_report.get("service_label", "?"),
				last_shop_report.get("boss_shards_before", 0),
				last_shop_report.get("boss_shards_after", 0),
				last_shop_report.get("reactivated_artifact_label", "?"),
				replaced_text,
				last_shop_report.get("loadout_summary", get_artifact_loadout_summary()),
			]

		return "Shop: last service %s | gold %s -> %s | base %s -> %s | structures reinforced %s | %s" % [
			last_shop_report.get("service_label", "?"),
			last_shop_report.get("gold_before", 0),
			last_shop_report.get("gold_after", 0),
			last_shop_report.get("base_hp_before", 0),
			last_shop_report.get("base_hp_after", 0),
			last_shop_report.get("reinforced_structures", 0),
			last_shop_report.get("deck_after_summary", get_deck_cycle_summary()),
		]

	return "Shop: last trim %s removed from %s | gold %s -> %s | copies %s -> %s | %s" % [
		last_shop_report.get("card_label", "?"),
		last_shop_report.get("removed_from", "?"),
		last_shop_report.get("gold_before", 0),
		last_shop_report.get("gold_after", 0),
		last_shop_report.get("deck_count_before", 0),
		last_shop_report.get("deck_count_after", 0),
		last_shop_report.get("deck_after_summary", get_deck_cycle_summary()),
	]


func get_shop_to_wave_preparation_report(player_count: int = 1) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if last_shop_report.is_empty():
		return {
			"ok": false,
			"reason": "no_shop_action",
			"summary": "",
		}

	if _has_open_shop_offer():
		return {
			"ok": false,
			"reason": "shop_still_open",
			"summary": "",
		}

	if wave_active:
		return {
			"ok": false,
			"reason": "wave_active",
			"summary": "",
		}

	if run_complete:
		return {
			"ok": false,
			"reason": "run_complete",
			"summary": "",
		}

	var preview_card = get_next_wave_preview_card(player_count)
	var next_round = current_round
	var next_directions = []
	var next_role = "pressure"
	if not preview_card.is_empty() and (not preview_card.has("ok") or bool(preview_card.get("ok", false))):
		next_round = int(preview_card.get("round", current_round))
		next_directions = preview_card.get("projectedDirections", preview_card.get("directions", []))
		next_role = str(preview_card.get("primaryEnemyRole", "pressure"))

	var direction_text = _join_values(_array_string_values(next_directions))
	if direction_text.is_empty():
		direction_text = "active front"

	var action_type = str(last_shop_report.get("shop_action_type", "remove_card"))
	var action_label = ""
	var effect_text = ""
	var reminder_text = ""
	match action_type:
		"service":
			action_label = str(last_shop_report.get("service_label", "Shop service"))
			var service_type = str(last_shop_report.get("service_type", "service"))
			if service_type == "restore_base":
				effect_text = "base %s -> %s" % [
					last_shop_report.get("base_hp_before", 0),
					last_shop_report.get("base_hp_after", 0),
				]
				reminder_text = "use the extra buffer to fix %s, not to ignore leaks" % direction_text
			elif service_type == "structure_hp_boost":
				effect_text = "%s structure(s) reinforced for +%s total HP" % [
					last_shop_report.get("reinforced_structures", 0),
					last_shop_report.get("total_reinforced_hp", 0),
				]
				reminder_text = "let braced structures buy time against %s, but keep paths open" % next_role
			elif service_type == "reactivate_dormant_artifact":
				var replaced_text = ""
				if not str(last_shop_report.get("replaced_artifact_label", "")).is_empty():
					replaced_text = "; %s now dormant" % last_shop_report.get("replaced_artifact_label", "")
				effect_text = "reactivated %s%s; boss shards %s -> %s" % [
					last_shop_report.get("reactivated_artifact_label", "?"),
					replaced_text,
					last_shop_report.get("boss_shards_before", 0),
					last_shop_report.get("boss_shards_after", 0),
				]
				reminder_text = "build the next %s answer around the restored passive, not around the dormant one" % next_role
			else:
				effect_text = str(last_shop_report.get("effect", "service applied"))
				reminder_text = "carry the service into the next front decision"
		"skip":
			action_label = "Shop skipped"
			effect_text = "gold held"
			reminder_text = "the next wave has no shop help, so check %s before starting" % direction_text
		_:
			action_label = str(last_shop_report.get("card_label", "Deck trim"))
			effect_text = "deck copies %s -> %s" % [
				last_shop_report.get("deck_count_before", 0),
				last_shop_report.get("deck_count_after", 0),
			]
			reminder_text = "use the leaner draw to answer %s on %s" % [
				next_role,
				direction_text,
			]

	var summary = "Maintenance memo: %s; %s. Next R%s: %s." % [
		action_label,
		effect_text,
		next_round,
		reminder_text,
	]
	return {
		"ok": true,
		"reason": "ok",
		"shop_action_type": action_type,
		"action_label": action_label,
		"effect_text": effect_text,
		"reminder_text": reminder_text,
		"next_round": next_round,
		"next_directions": _array_string_values(next_directions),
		"next_role": next_role,
		"summary": summary,
	}


func get_shop_to_wave_preparation_summary(player_count: int = 1) -> String:
	var report = get_shop_to_wave_preparation_report(player_count)
	if not bool(report.get("ok", false)):
		return ""

	return str(report.get("summary", ""))


func can_remove_shop_card(card_id: String) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not _has_open_shop_offer():
		return _reject("no_shop_offer")

	if not shop_offer.has(card_id):
		return _reject("shop_card_not_offered")

	if shop_purchases_remaining <= 0:
		return _reject("shop_purchase_unavailable")

	if shop_removals_remaining <= 0:
		return _reject("shop_removal_unavailable")

	var gate_report = get_reward_to_maintenance_gate_report()
	if not bool(gate_report.get("canStartPaidShopVote", true)):
		var reject_result = _reject("reward_choice_pending")
		reject_result["rewardToMaintenanceGate"] = gate_report
		return reject_result

	var report = get_card_removal_report(card_id)
	if not bool(report.get("ok", false)):
		return report

	if int(report.get("deck_count", 0)) <= 0:
		return _reject("card_not_in_deck")

	if gold < get_shop_deck_removal_gold_cost():
		return _reject("not_enough_gold")

	return {"ok": true, "reason": "ok"}


func can_buy_shop_service(service_id: String, reactivation_dormant_artifact_id: String = "", reactivation_replaced_artifact_id: String = "") -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var report = get_shop_service_report(service_id, reactivation_dormant_artifact_id, reactivation_replaced_artifact_id)
	if not bool(report.get("ok", false)):
		return report

	if not bool(report.get("can_buy", false)):
		var reject_result = _reject(str(report.get("reason", "blocked")))
		reject_result["service_report"] = report
		return reject_result

	return {"ok": true, "reason": "ok"}


func get_enemy_label(enemy_id: String) -> String:
	var enemy_data = _enemy_data_by_id(enemy_id)
	return str(enemy_data.get("label", enemy_id))


func get_enemy_data(enemy_id: String) -> Dictionary:
	return _enemy_data_by_id(enemy_id).duplicate(true)


func get_enemy_trait_summary(enemy_id: String) -> String:
	var enemy_data = _enemy_data_by_id(enemy_id)
	if enemy_data.is_empty():
		return ""

	var traits = PackedStringArray()
	var move_steps = int(enemy_data.get("moveSteps", 1))
	if move_steps > 1:
		traits.append("Fast x%s" % move_steps)

	if bool(enemy_data.get("structurePriority", false)):
		traits.append("Structure focus")

	var damage_reduction = int(enemy_data.get("damageReduction", 0))
	if damage_reduction > 0:
		traits.append("Armor %s" % damage_reduction)

	if bool(enemy_data.get("boss", false)):
		traits.append("Boss")
		var boss_parts: Array = enemy_data.get("bossParts", [])
		if boss_parts.size() > 0:
			traits.append("Parts %s" % boss_parts.size())

	if traits.is_empty():
		return "Standard"

	return ", ".join(traits)


func get_enemy_mix_ids(round_number = -1) -> Array:
	var target_round = current_round if int(round_number) <= 0 else int(round_number)
	var ids: Array = []
	for enemy_id in _enemy_mix_pattern_for_round(target_round):
		var enemy_id_text = str(enemy_id)
		if not ids.has(enemy_id_text):
			ids.append(enemy_id_text)
	return ids


func get_enemy_mix_summary(round_number = -1) -> String:
	var ids = get_enemy_mix_ids(round_number)
	if ids.is_empty():
		return get_enemy_label(_default_enemy_id())

	var labels = PackedStringArray()
	for enemy_id in ids:
		labels.append(get_enemy_label(str(enemy_id)))
	return ", ".join(labels)


func get_enemy_mix_trait_summary(round_number = -1) -> String:
	var ids = get_enemy_mix_ids(round_number)
	var parts = PackedStringArray()
	for enemy_id in ids:
		var trait_summary = get_enemy_trait_summary(str(enemy_id))
		if trait_summary.is_empty() or trait_summary == "Standard":
			continue

		parts.append("%s: %s" % [
			get_enemy_label(str(enemy_id)),
			trait_summary,
		])

	if parts.is_empty():
		return "Standard"

	return " | ".join(parts)


func get_wave_intent_ids() -> Array:
	var ids: Array = []
	var wave_intents: Dictionary = data.get("waveIntents", {})
	for intent_id in wave_intents.keys():
		ids.append(str(intent_id))
	ids.sort()
	return ids


func get_wave_intent_data(intent_id: String) -> Dictionary:
	return _wave_intent_data(intent_id).duplicate(true)


func get_wave_intent_report(round_number = -1) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var target_round = _next_preview_round() if int(round_number) <= 0 else int(round_number)
	if target_round > get_max_rounds():
		return _reject("no_next_round")

	var boss_enemy_id = _boss_enemy_id() if _is_boss_round(target_round) else ""
	var enemy_roles = _wave_enemy_role_tags(get_enemy_mix_ids(target_round), boss_enemy_id)
	var inferred_primary_enemy_role = _wave_primary_enemy_role_for_round(target_round, enemy_roles, boss_enemy_id)
	var scheduled_intent_id = _wave_intent_id_for_round(target_round)
	var primary_enemy_role = _wave_intent_primary_role(scheduled_intent_id, inferred_primary_enemy_role)
	var wave_intent_id = scheduled_intent_id
	if wave_intent_id.is_empty():
		wave_intent_id = _wave_intent_id_for_role(target_round, primary_enemy_role)

	return _build_wave_intent_report(target_round, wave_intent_id, primary_enemy_role, enemy_roles, inferred_primary_enemy_role)


func get_wave_intent_summary(round_number = -1) -> String:
	var report = get_wave_intent_report(round_number)
	if not bool(report.get("ok", false)):
		return "WaveIntent: unavailable (%s)" % report.get("reason", "unknown")

	return str(report.get("summary", "WaveIntent: -"))


func get_wave_spawn_plan_report(player_count: int, round_number = -1) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var target_round = _next_preview_round() if int(round_number) <= 0 else int(round_number)
	if target_round > get_max_rounds():
		return _reject("no_next_round")

	var normalized_player_count = clamp(player_count, 1, 4)
	var active_directions = _array_string_values(get_active_directions(normalized_player_count))
	if active_directions.is_empty():
		return _reject("no_active_direction")

	return _cached_wave_spawn_plan(normalized_player_count, target_round, active_directions)


func get_wave_spawn_plan_summary(player_count: int, round_number = -1) -> String:
	var report = get_wave_spawn_plan_report(player_count, round_number)
	if not bool(report.get("ok", false)):
		return "SpawnPlan: unavailable (%s)" % report.get("reason", "unknown")

	return str(report.get("summary", "SpawnPlan: -"))


func get_wave_spawn_timeline_report(player_count: int, round_number = -1, max_rows: int = 4) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var target_round = _next_preview_round() if int(round_number) <= 0 else int(round_number)
	if target_round > get_max_rounds():
		return _reject("no_next_round")

	var spawn_plan = get_wave_spawn_plan_report(player_count, target_round)
	if not bool(spawn_plan.get("ok", false)):
		return spawn_plan

	var rows = _wave_spawn_timeline_rows_from_plan(spawn_plan, max_rows)
	var total_packet_count = int(spawn_plan.get("spawnPacketCount", rows.size()))
	return {
		"ok": true,
		"reason": "ok",
		"mode": "preview",
		"spawnPlanId": str(spawn_plan.get("spawnPlanId", "")),
		"waveId": str(spawn_plan.get("waveId", "")),
		"round": target_round,
		"day": target_round,
		"playerCount": clamp(player_count, 1, 4),
		"playerCountAtStart": clamp(player_count, 1, 4),
		"activeDirections": spawn_plan.get("activeDirections", []),
		"directions": spawn_plan.get("directions", []),
		"rows": rows,
		"rowCount": rows.size(),
		"totalPacketCount": total_packet_count,
		"hiddenRowCount": max(0, total_packet_count - rows.size()),
		"criticalWarningTags": spawn_plan.get("criticalWarningTags", []),
		"forbiddenTimelineTags": WAVE_SPAWN_TIMELINE_FORBIDDEN_TAGS.duplicate(),
		"noBonusRewards": true,
		"summary": _format_wave_spawn_timeline_summary("Spawn timing R%s" % target_round, rows, max(0, total_packet_count - rows.size())),
	}


func get_wave_spawn_timeline_summary(player_count: int, round_number = -1, max_rows: int = 4) -> String:
	var report = get_wave_spawn_timeline_report(player_count, round_number, max_rows)
	if not bool(report.get("ok", false)):
		return "Spawn timing: unavailable (%s)" % report.get("reason", "unknown")

	return str(report.get("summary", "Spawn timing: -"))


func get_active_wave_spawn_timeline_report(player_count: int, max_rows: int = 4) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")
	if not wave_active:
		return _reject("wave_not_active")

	var rows: Array = []
	var remaining_packet_count = 0
	var source_rounds: Array = []
	for active_packet_value in active_wave_packets:
		if typeof(active_packet_value) != TYPE_DICTIONARY:
			continue

		var active_packet: Dictionary = active_packet_value
		var packet_round = int(active_packet.get("round", active_round))
		if not source_rounds.has(packet_round):
			source_rounds.append(packet_round)

		var active_directions = _array_string_values(active_packet.get("active_directions", get_active_directions(player_count)))
		var spawn_plan: Dictionary = active_packet.get("spawnPlan", {})
		if spawn_plan.is_empty():
			spawn_plan = _cached_wave_spawn_plan(player_count, packet_round, active_directions)

		var spawn_packets: Array = spawn_plan.get("spawnPackets", [])
		var spawned = clamp(int(active_packet.get("spawned", 0)), 0, spawn_packets.size())
		for spawn_index in range(spawned, spawn_packets.size()):
			var spawn_packet_value = spawn_packets[spawn_index]
			if typeof(spawn_packet_value) != TYPE_DICTIONARY:
				continue

			remaining_packet_count += 1
			if rows.size() >= max(1, max_rows):
				continue

			var row = _wave_spawn_timeline_row_from_packet(spawn_plan, spawn_packet_value, spawn_index)
			row["sourceRound"] = packet_round
			row["stacked"] = bool(active_packet.get("stacked", false))
			row["status"] = "next" if rows.is_empty() else "queued"
			rows.append(row)

	source_rounds.sort()
	return {
		"ok": true,
		"reason": "ok",
		"mode": "active",
		"round": active_round,
		"day": active_round,
		"playerCount": clamp(player_count, 1, 4),
		"playerCountAtStart": clamp(player_count, 1, 4),
		"sourceRounds": source_rounds,
		"rows": rows,
		"rowCount": rows.size(),
		"remainingPacketCount": remaining_packet_count,
		"hiddenRowCount": max(0, remaining_packet_count - rows.size()),
		"forbiddenTimelineTags": WAVE_SPAWN_TIMELINE_FORBIDDEN_TAGS.duplicate(),
		"noBonusRewards": true,
		"summary": _format_wave_spawn_timeline_summary("Spawn queue", rows, max(0, remaining_packet_count - rows.size())),
	}


func get_active_wave_spawn_timeline_summary(player_count: int, max_rows: int = 4) -> String:
	var report = get_active_wave_spawn_timeline_report(player_count, max_rows)
	if not bool(report.get("ok", false)):
		return "Spawn queue: unavailable (%s)" % report.get("reason", "unknown")

	return str(report.get("summary", "Spawn queue: -"))


func get_wave_stack_impact_report(player_count: int, max_rows: int = 4) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")
	if not wave_active:
		return _reject("wave_not_active")

	var stack_depth = get_active_wave_stack_depth()
	if stack_depth <= 1:
		return _reject("not_stacked")

	var source_rounds: Array = []
	var pulled_rounds: Array = []
	for active_packet_value in active_wave_packets:
		if typeof(active_packet_value) != TYPE_DICTIONARY:
			continue

		var active_packet: Dictionary = active_packet_value
		var packet_round = int(active_packet.get("round", active_round))
		if not source_rounds.has(packet_round):
			source_rounds.append(packet_round)
		if bool(active_packet.get("stacked", false)) and not pulled_rounds.has(packet_round):
			pulled_rounds.append(packet_round)

	source_rounds.sort()
	pulled_rounds.sort()
	var timeline_report = get_active_wave_spawn_timeline_report(player_count, max_rows)
	var rows: Array = timeline_report.get("rows", []) if bool(timeline_report.get("ok", false)) else []
	var next_row: Dictionary = {}
	if not rows.is_empty() and typeof(rows[0]) == TYPE_DICTIONARY:
		next_row = rows[0]

	var remaining_packets = int(timeline_report.get("remainingPacketCount", 0)) if bool(timeline_report.get("ok", false)) else 0
	var hidden_rows = int(timeline_report.get("hiddenRowCount", 0)) if bool(timeline_report.get("ok", false)) else 0
	var summary = "Pull impact: depth %s/%s, pulled %s into active queue %s; %s; remaining packets %s. Tempo only. No bonus rewards." % [
		stack_depth,
		get_wave_stack_limit(),
		_wave_stack_rounds_label(pulled_rounds),
		_wave_stack_rounds_label(source_rounds),
		_wave_stack_impact_next_text(next_row),
		remaining_packets,
	]
	return {
		"ok": true,
		"reason": "ok",
		"stackDepth": stack_depth,
		"stackLimit": get_wave_stack_limit(),
		"sourceRounds": source_rounds,
		"pulledRounds": pulled_rounds,
		"nextRow": next_row,
		"remainingPacketCount": remaining_packets,
		"hiddenRowCount": hidden_rows,
		"tempoOnly": true,
		"noBonusRewards": true,
		"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
		"summary": summary,
	}


func get_wave_stack_impact_summary(player_count: int, max_rows: int = 4) -> String:
	var report = get_wave_stack_impact_report(player_count, max_rows)
	if not bool(report.get("ok", false)):
		return ""

	return str(report.get("summary", ""))


func get_wave_stack_tempo_moment_report() -> Dictionary:
	if not wave_stack_tempo_tracker.is_empty():
		return _wave_stack_tempo_moment_with_current_pressure(wave_stack_tempo_tracker)
	if not last_wave_stack_tempo_moment.is_empty():
		return last_wave_stack_tempo_moment.duplicate(true)

	return _reject("no_wave_stack_tempo_moment")


func get_wave_stack_tempo_moment_summary() -> String:
	var report = get_wave_stack_tempo_moment_report()
	if not bool(report.get("ok", false)):
		return ""

	return str(report.get("summary", ""))


func _wave_spawn_timeline_rows_from_plan(spawn_plan: Dictionary, max_rows: int) -> Array:
	var rows: Array = []
	var spawn_packets: Array = spawn_plan.get("spawnPackets", [])
	var row_limit = max(1, max_rows)
	for index in range(min(row_limit, spawn_packets.size())):
		var spawn_packet_value = spawn_packets[index]
		if typeof(spawn_packet_value) != TYPE_DICTIONARY:
			continue

		rows.append(_wave_spawn_timeline_row_from_packet(spawn_plan, spawn_packet_value, index))

	return rows


func _wave_spawn_timeline_row_from_packet(spawn_plan: Dictionary, spawn_packet_value, spawn_index: int) -> Dictionary:
	var packet: Dictionary = spawn_packet_value
	var enemy_id = str(packet.get("enemyId", ""))
	var first_spawn_time = max(0.0, float(packet.get("firstSpawnTimeSeconds", 0.0)))
	var warning_lead_time = max(0.0, float(packet.get("warningLeadTimeSeconds", 0.0)))
	var warning_time = max(0.0, first_spawn_time - warning_lead_time)
	var directions = _array_string_values(packet.get("directions", []))
	return {
		"index": spawn_index + 1,
		"packetId": str(packet.get("packetId", "")),
		"spawnPlanId": str(spawn_plan.get("spawnPlanId", "")),
		"waveId": str(spawn_plan.get("waveId", "")),
		"round": int(spawn_plan.get("round", current_round)),
		"day": int(spawn_plan.get("day", spawn_plan.get("round", current_round))),
		"enemyId": enemy_id,
		"enemyLabel": get_enemy_label(enemy_id),
		"enemyRole": str(packet.get("enemyRole", "")),
		"directionRole": str(packet.get("directionRole", "any")),
		"directions": directions,
		"directionText": _join_values(directions),
		"firstSpawnTimeSeconds": first_spawn_time,
		"warningLeadTimeSeconds": warning_lead_time,
		"warningTimeSeconds": warning_time,
		"intervalSeconds": float(packet.get("intervalSeconds", 0.0)),
		"routeProfileId": str(packet.get("routeProfileId", "")),
		"count": max(1, int(packet.get("count", 1))),
		"summary": _format_spawn_timeline_row_summary(first_spawn_time, directions, enemy_id, packet),
	}


func _format_wave_spawn_timeline_summary(prefix: String, rows: Array, hidden_count: int) -> String:
	if rows.is_empty():
		return "%s: clear" % prefix

	var parts = PackedStringArray()
	for row_value in rows:
		if typeof(row_value) != TYPE_DICTIONARY:
			continue

		var row: Dictionary = row_value
		parts.append(str(row.get("summary", "")))

	var suffix = ""
	if hidden_count > 0:
		suffix = " | +%s more" % hidden_count

	return "%s: %s%s | no bonus rewards" % [
		prefix,
		" | ".join(parts),
		suffix,
	]


func _format_spawn_timeline_row_summary(first_spawn_time: float, directions: Array, enemy_id: String, packet: Dictionary) -> String:
	var direction_text = _join_values(directions)
	if direction_text.is_empty():
		direction_text = "unknown"

	var role_text = str(packet.get("directionRole", "any"))
	var role_suffix = "" if role_text == "any" else " %s" % role_text
	return "%s %s %s%s" % [
		_format_spawn_seconds_label(first_spawn_time),
		direction_text,
		get_enemy_label(enemy_id),
		role_suffix,
	]


func _wave_stack_impact_next_text(row: Dictionary) -> String:
	if row.is_empty():
		return "spawn queue is clear"

	var directions = _array_string_values(row.get("directions", []))
	var direction_text = _join_values(directions)
	if direction_text.is_empty():
		direction_text = "unknown front"

	var seconds = max(0.0, float(row.get("firstSpawnTimeSeconds", 0.0)))
	var timing_text = "now" if seconds <= 0.01 else "at %s" % _format_spawn_seconds_label(seconds)
	return "next %s %s %s" % [
		direction_text,
		row.get("enemyLabel", row.get("enemyId", "enemy")),
		timing_text,
	]


func _wave_stack_rounds_label(rounds: Array) -> String:
	if rounds.is_empty():
		return "none"

	var parts = PackedStringArray()
	for round_value in rounds:
		parts.append("R%s" % int(round_value))
	return "+".join(parts)


func _begin_or_update_wave_stack_tempo_tracker(player_count: int, stack_report: Dictionary, risk_report: Dictionary) -> void:
	var source_rounds = _active_wave_rounds()
	var pulled_rounds = _active_pulled_wave_rounds()
	var current_step = int(run_stats.get("steps", 0))
	if wave_stack_tempo_tracker.is_empty():
		wave_stack_tempo_tracker = {
			"ok": true,
			"event": "moment_wave_stack_tempo",
			"state": "watching",
			"sourcePhase": "combat",
			"sourceDay": active_round if active_round > 0 else current_round,
			"playerCount": clamp(player_count, 1, 4),
			"startedAtStep": current_step,
			"windowSteps": _wave_stack_tempo_window_steps(),
			"windowSeconds": WAVE_STACK_TEMPO_MOMENT_WINDOW_SECONDS,
			"baseHpAtCall": base_hp,
			"baseDamageAtCall": int(run_stats.get("base_damage", 0)),
			"baseHitsAtCall": int(run_stats.get("base_hits", 0)),
			"structuresDestroyedAtCall": int(run_stats.get("structures_destroyed", 0)),
			"plannedCollapsesAtCall": int(run_stats.get("planned_collapses", 0)),
			"baseDamageByDirectionAtCall": _dictionary_int_copy(run_stats.get("base_damage_by_direction", {})),
			"baseHitsByDirectionAtCall": _dictionary_int_copy(run_stats.get("base_hits_by_direction", {})),
			"structuresDestroyedByDirectionAtCall": _dictionary_int_copy(run_stats.get("structures_destroyed_by_direction", {})),
			"initialRiskSeverity": str(risk_report.get("severity", "unknown")),
			"initialRiskLabels": _array_string_values(risk_report.get("detail_labels", [])),
			"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
			"forbiddenOutcomeTags": ["stackRewardEfficiency", "bonusGold", "rarityBoost", "extraCardChoices"],
			"noBonusRewards": true,
			"tempoOnly": true,
		}

	wave_stack_tempo_tracker["stackDepth"] = get_active_wave_stack_depth()
	wave_stack_tempo_tracker["stackLimit"] = get_wave_stack_limit()
	wave_stack_tempo_tracker["activeDirections"] = _array_string_values(stack_report.get("activeDirections", get_active_directions(player_count)))
	wave_stack_tempo_tracker["directions"] = _array_string_values(stack_report.get("directions", []))
	wave_stack_tempo_tracker["sourceRounds"] = source_rounds.duplicate()
	wave_stack_tempo_tracker["pulledRounds"] = pulled_rounds.duplicate()
	wave_stack_tempo_tracker["lastPulledRound"] = int(stack_report.get("pulledRound", 0))
	wave_stack_tempo_tracker = _wave_stack_tempo_moment_with_current_pressure(wave_stack_tempo_tracker)


func _update_wave_stack_tempo_tracker(events: Array[String]) -> void:
	if wave_stack_tempo_tracker.is_empty():
		return

	var report = _wave_stack_tempo_moment_with_current_pressure(wave_stack_tempo_tracker)
	var elapsed_steps = int(report.get("elapsedSteps", 0))
	var window_steps = int(report.get("windowSteps", _wave_stack_tempo_window_steps()))
	var should_finalize = elapsed_steps >= window_steps or not wave_active or base_hp <= 0
	if should_finalize:
		report["finalized"] = true
		last_wave_stack_tempo_moment = report.duplicate(true)
		wave_stack_tempo_tracker.clear()
		run_stats["wave_stack_tempo_moments"] = int(run_stats.get("wave_stack_tempo_moments", 0)) + 1
		events.append("Decisive moment: %s" % report.get("summary", "moment_wave_stack_tempo"))
	else:
		wave_stack_tempo_tracker = report.duplicate(true)


func _wave_stack_tempo_moment_with_current_pressure(source: Dictionary) -> Dictionary:
	var report = source.duplicate(true)
	var elapsed_steps = max(0, int(run_stats.get("steps", 0)) - int(report.get("startedAtStep", 0)))
	var window_steps = max(1, int(report.get("windowSteps", _wave_stack_tempo_window_steps())))
	var base_damage_delta = max(0, int(run_stats.get("base_damage", 0)) - int(report.get("baseDamageAtCall", 0)))
	var base_hits_delta = max(0, int(run_stats.get("base_hits", 0)) - int(report.get("baseHitsAtCall", 0)))
	var destroyed_delta = max(0, int(run_stats.get("structures_destroyed", 0)) - int(report.get("structuresDestroyedAtCall", 0)))
	var planned_delta = max(0, int(run_stats.get("planned_collapses", 0)) - int(report.get("plannedCollapsesAtCall", 0)))
	var base_damage_by_direction = _wave_stack_tempo_bucket_delta("base_damage_by_direction", report.get("baseDamageByDirectionAtCall", {}))
	var base_hits_by_direction = _wave_stack_tempo_bucket_delta("base_hits_by_direction", report.get("baseHitsByDirectionAtCall", {}))
	var destroyed_by_direction = _wave_stack_tempo_bucket_delta("structures_destroyed_by_direction", report.get("structuresDestroyedByDirectionAtCall", {}))
	var primary_direction = _wave_stack_tempo_primary_direction(base_damage_by_direction, destroyed_by_direction, report.get("directions", []))
	var pressure_score = base_damage_delta * 2 + base_hits_delta * 3 + destroyed_delta * 5
	var state = "watching"
	if base_hp <= 0:
		state = "failed_after_pull"
	elif pressure_score >= 5 or destroyed_delta > 0:
		state = "pressure_spike"
	elif elapsed_steps >= window_steps or not wave_active:
		state = "stable"

	report["state"] = state
	report["elapsedSteps"] = elapsed_steps
	report["windowSteps"] = window_steps
	report["windowSeconds"] = WAVE_STACK_TEMPO_MOMENT_WINDOW_SECONDS
	report["baseHpAfter"] = base_hp
	report["baseDamageDelta"] = base_damage_delta
	report["baseHitsDelta"] = base_hits_delta
	report["structuresDestroyedDelta"] = destroyed_delta
	report["plannedCollapsesDelta"] = planned_delta
	report["pressureScore"] = pressure_score
	report["primaryDirection"] = primary_direction
	report["baseDamageByDirectionDelta"] = base_damage_by_direction
	report["baseHitsByDirectionDelta"] = base_hits_by_direction
	report["structuresDestroyedByDirectionDelta"] = destroyed_by_direction
	report["riskTags"] = _wave_stack_tempo_risk_tags(report)
	report["holdTags"] = _wave_stack_tempo_hold_tags(report)
	report["summary"] = _format_wave_stack_tempo_moment_summary(report)
	return report


func _wave_stack_tempo_window_steps() -> int:
	var interval = max(0.1, get_auto_step_interval())
	return max(1, int(ceil(WAVE_STACK_TEMPO_MOMENT_WINDOW_SECONDS / interval)))


func _active_pulled_wave_rounds() -> Array:
	var rounds: Array = []
	for active_packet_value in active_wave_packets:
		if typeof(active_packet_value) != TYPE_DICTIONARY:
			continue

		var active_packet: Dictionary = active_packet_value
		var round_number = int(active_packet.get("round", active_round))
		if bool(active_packet.get("stacked", false)) and not rounds.has(round_number):
			rounds.append(round_number)

	rounds.sort()
	return rounds


func _wave_stack_tempo_bucket_delta(stat_key: String, baseline_value) -> Dictionary:
	var baseline: Dictionary = baseline_value if typeof(baseline_value) == TYPE_DICTIONARY else {}
	var current_bucket: Dictionary = run_stats.get(stat_key, {})
	var delta = {}
	for key in current_bucket.keys():
		var key_text = str(key)
		var amount = int(current_bucket.get(key_text, 0)) - int(baseline.get(key_text, 0))
		if amount > 0:
			delta[key_text] = amount
	return delta


func _wave_stack_tempo_primary_direction(base_damage_by_direction: Dictionary, destroyed_by_direction: Dictionary, fallback_directions: Array) -> String:
	var top_base = _top_count_from_dictionary(base_damage_by_direction)
	if int(top_base.get("value", 0)) > 0:
		return str(top_base.get("key", ""))

	var top_destroyed = _top_count_from_dictionary(destroyed_by_direction)
	if int(top_destroyed.get("value", 0)) > 0:
		return str(top_destroyed.get("key", ""))

	var directions = _array_string_values(fallback_directions)
	if not directions.is_empty():
		return str(directions[0])
	return ""


func _wave_stack_tempo_risk_tags(report: Dictionary) -> Array:
	var tags: Array = ["tempo_stack"]
	if int(report.get("baseDamageDelta", 0)) > 0:
		tags.append("post_stack_base_damage")
	if int(report.get("baseHitsDelta", 0)) > 0:
		tags.append("post_stack_leak")
	if int(report.get("structuresDestroyedDelta", 0)) > 0:
		tags.append("post_stack_structure_loss")
	if int(report.get("plannedCollapsesDelta", 0)) > 0:
		tags.append("planned_collapse_absorbed")
	if str(report.get("state", "")) == "stable":
		tags.append("post_stack_stable")
	if base_hp <= 0:
		tags.append("base_destroyed")
	return tags


func _wave_stack_tempo_hold_tags(report: Dictionary) -> Array:
	var tags: Array = []
	if base_hp <= 0:
		tags.append("hold_next_pull")
		tags.append("base_critical_hold")
	if int(report.get("baseDamageDelta", 0)) >= 3 or int(report.get("baseHitsDelta", 0)) >= 2:
		tags.append("hold_next_pull")
	if int(report.get("structuresDestroyedDelta", 0)) > 0:
		tags.append("repair_before_pull")
	if _base_hp_percent() <= 0.3:
		tags.append("base_critical_hold")
	if tags.is_empty():
		tags.append("tempo_survived")
	return _unique_string_array(tags)


func _format_wave_stack_tempo_moment_summary(report: Dictionary) -> String:
	var state_label = _wave_stack_tempo_state_label(str(report.get("state", "watching")))
	var pulled_label = _wave_stack_rounds_label(report.get("pulledRounds", []))
	var direction = _direction_label(str(report.get("primaryDirection", "")))
	var hold_tags = _join_values(_array_string_values(report.get("holdTags", [])))
	return "moment_wave_stack_tempo: %s after pulled %s on %s; +%s base damage, +%s leaks, +%s structures lost in %s/%s steps; hold tags %s. No bonus rewards." % [
		state_label,
		pulled_label,
		direction,
		report.get("baseDamageDelta", 0),
		report.get("baseHitsDelta", 0),
		report.get("structuresDestroyedDelta", 0),
		min(int(report.get("elapsedSteps", 0)), int(report.get("windowSteps", _wave_stack_tempo_window_steps()))),
		report.get("windowSteps", _wave_stack_tempo_window_steps()),
		hold_tags,
	]


func _wave_stack_tempo_state_label(state: String) -> String:
	match state:
		"failed_after_pull":
			return "base failed"
		"pressure_spike":
			return "pressure spike"
		"stable":
			return "stable"
		_:
			return "watching"


func _dictionary_int_copy(source_value) -> Dictionary:
	var source: Dictionary = source_value if typeof(source_value) == TYPE_DICTIONARY else {}
	var copy = {}
	for key in source.keys():
		copy[str(key)] = int(source.get(key, 0))
	return copy


func _top_count_from_dictionary(source: Dictionary) -> Dictionary:
	var best_key = ""
	var best_value = 0
	for key in source.keys():
		var key_text = str(key)
		var value = int(source.get(key_text, 0))
		if value > best_value:
			best_key = key_text
			best_value = value
	return {
		"key": best_key,
		"value": best_value,
	}


func _unique_string_array(values: Array) -> Array:
	var unique: Array = []
	for value in values:
		var text = str(value)
		if not unique.has(text):
			unique.append(text)
	return unique


func _format_spawn_seconds_label(seconds: float) -> String:
	if abs(seconds - round(seconds)) < 0.01:
		return "%ss" % int(round(seconds))

	return "%.1fs" % seconds


func _wave_plan_cache_key(player_count: int, round_number: int, active_directions: Array) -> String:
	return "%s|%s|%s" % [
		clamp(player_count, 1, 4),
		round_number,
		_join_values(_array_string_values(active_directions)),
	]


func _cached_wave_spawn_plan(player_count: int, round_number: int, active_directions: Array) -> Dictionary:
	var key = _wave_plan_cache_key(player_count, round_number, active_directions)
	if not wave_spawn_plan_cache.has(key):
		wave_spawn_plan_cache[key] = _build_wave_spawn_plan(player_count, round_number, active_directions)

	return wave_spawn_plan_cache.get(key, {})


func _cached_wave_preview_card(player_count: int, round_number: int, active_directions: Array) -> Dictionary:
	var key = _wave_plan_cache_key(player_count, round_number, active_directions)
	if not wave_preview_card_cache.has(key):
		wave_preview_card_cache[key] = _build_wave_preview_card(player_count, round_number, active_directions)

	return wave_preview_card_cache.get(key, {})


func get_wave_preview_cards(player_count: int, count = -1) -> Array[Dictionary]:
	var cards: Array[Dictionary] = []
	if not is_loaded():
		return cards

	var preview_count = get_wave_preview_round_count() if int(count) <= 0 else int(count)
	var start_round = _next_preview_round()
	if start_round > get_max_rounds():
		return cards

	var normalized_player_count = clamp(player_count, 1, 4)
	var active_directions = _array_string_values(get_active_directions(normalized_player_count))
	for offset in range(preview_count):
		var round_number = start_round + offset
		if round_number > get_max_rounds():
			break

		cards.append(_cached_wave_preview_card(normalized_player_count, round_number, active_directions))

	return cards


func get_next_wave_preview_card(player_count: int) -> Dictionary:
	var cards = get_wave_preview_cards(player_count, 1)
	if cards.is_empty():
		return _reject("no_next_wave_preview")

	return cards[0]


func get_wave_preview_rows(player_count: int, count = -1) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for card in get_wave_preview_cards(player_count, count):
		var round_number = int(card.get("round", current_round))
		rows.append({
			"round": round_number,
			"spawn_count": int(card.get("normalSpawnCount", _get_normal_spawn_count(round_number))),
			"total_spawn_count": int(card.get("totalSpawnCount", _get_spawn_count(round_number))),
			"enemy_ids": card.get("enemyGroups", []),
			"enemy_mix": get_enemy_mix_summary(round_number),
			"enemy_traits": get_enemy_mix_trait_summary(round_number),
			"enemy_roles": card.get("enemyRoles", []),
			"primary_enemy_role": card.get("primaryEnemyRole", "swarm"),
			"boss_enemy_id": str(card.get("bossEnemyId", "")),
			"boss_label": str(card.get("bossLabel", "")),
			"active_directions": card.get("activeDirections", []),
			"directions": card.get("directions", []),
			"projected_directions": card.get("projectedDirections", []),
			"preview_card_id": str(card.get("previewCardId", "")),
			"wave_preview_card": card,
			"summary": str(card.get("summary", _format_wave_preview_row(round_number, player_count))),
		})

	return rows


func get_next_wave_preview_summary(player_count: int, count = -1) -> String:
	var rows = get_wave_preview_rows(player_count, count)
	if rows.is_empty():
		return "Next waves: none"

	var parts = PackedStringArray()
	for row in rows:
		parts.append(str(row.get("summary", "")))

	return "Next waves: %s" % " | ".join(parts)


func get_reward_offer() -> Array:
	return reward_offer.duplicate()


func get_reward_card_pool(round_number = -1) -> Array:
	var target_round = current_round if int(round_number) <= 0 else int(round_number)
	return _reward_card_pool_for_round(target_round)


func get_reward_card_pool_summary(round_number = -1) -> String:
	var pool = get_reward_card_pool(round_number)
	if pool.is_empty():
		return "Reward pool: none"

	var rarity_counts = {
		"common": 0,
		"uncommon": 0,
		"rare": 0,
	}
	for card_id in pool:
		var rarity = get_card_rarity(str(card_id))
		rarity_counts[rarity] = int(rarity_counts.get(rarity, 0)) + 1

	return "Reward pool: common=%s uncommon=%s rare=%s" % [
		rarity_counts.get("common", 0),
		rarity_counts.get("uncommon", 0),
		rarity_counts.get("rare", 0),
	]


func get_reward_offer_reports() -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	for card_id in reward_offer:
		var report = get_card_reward_report(str(card_id))
		if bool(report.get("ok", false)):
			reports.append(report)
	return reports


func get_reward_offer_summary(player_count: int = 1, class_id: String = "") -> String:
	if reward_offer.is_empty():
		return get_last_reward_claim_summary()

	var parts = PackedStringArray()
	for report in get_reward_offer_reports():
		parts.append("%s %s cost %s deck %s" % [
			report.get("rarity_label", "Common"),
			report.get("label", report.get("card_id", "?")),
			report.get("cost", 0),
			report.get("deck_count", 0),
		])

	var recommendation = get_reward_recommendation_report(player_count, class_id)
	var recommendation_text = ""
	if bool(recommendation.get("ok", false)):
		recommendation_text = " | Suggested: %s" % recommendation.get("label", recommendation.get("card_id", "?"))

	var settlement_report = get_settlement_batch_report()
	var settlement_text = ""
	if bool(settlement_report.get("ok", false)) and bool(settlement_report.get("compressed", false)):
		settlement_text = " | %s" % settlement_report.get("summary", "")

	var gold_choice_text = "take gold"
	var card_reward_gold = get_card_reward_gold()
	if card_reward_gold > 0:
		gold_choice_text = "take +%s gold" % card_reward_gold

	return "Reward: choose 1 card from %s or %s | %s%s%s" % [
		reward_offer.size(),
		gold_choice_text,
		" | ".join(parts),
		recommendation_text,
		settlement_text,
	]


func get_reward_recommendation_report(player_count: int = 1, class_id: String = "") -> Dictionary:
	if reward_offer.is_empty():
		return {
			"ok": false,
			"reason": "no_reward_offer",
			"summary": "Reward recommendation: none",
			"card_id": "",
			"index": -1,
			"score": 0,
			"choice_type": "none",
			"reason_text": "No reward offer is waiting.",
			"detail_text": "",
			"candidates": [],
		}

	var best_index = -1
	var best_card_id = ""
	var best_score = -999999
	var candidates: Array[Dictionary] = []
	for index in range(reward_offer.size()):
		var card_id = str(reward_offer[index])
		var score = _reward_recommendation_score(card_id, player_count, class_id)
		var reason_text = _reward_recommendation_reason(card_id, player_count, class_id)
		var detail_text = _reward_recommendation_detail(card_id, player_count, class_id, reason_text)
		var candidate = {
			"card_id": card_id,
			"label": get_card_label(card_id),
			"index": index,
			"score": score,
			"choice_type": "card",
			"reason_text": reason_text,
			"detail_text": detail_text,
		}
		candidates.append(candidate)
		if best_card_id.is_empty() or score > best_score:
			best_index = index
			best_card_id = card_id
			best_score = score

	var gold_candidate = _reward_gold_recommendation_candidate(player_count, class_id)
	if bool(gold_candidate.get("ok", false)):
		candidates.append(gold_candidate)
		if best_card_id.is_empty() or int(gold_candidate.get("score", -999999)) > best_score:
			return {
				"ok": true,
				"reason": "ok",
				"choice_type": "gold",
				"card_id": "",
				"label": gold_candidate.get("label", _reward_gold_label()),
				"index": -1,
				"score": int(gold_candidate.get("score", 0)),
				"gold_gain": get_card_reward_gold(),
				"reason_text": str(gold_candidate.get("reason_text", "")),
				"detail_text": str(gold_candidate.get("detail_text", "")),
				"candidates": candidates,
				"summary": "Suggested reward: %s - %s" % [
					gold_candidate.get("label", _reward_gold_label()),
					gold_candidate.get("reason_text", "keeps the deck lean"),
				],
			}

	if best_card_id.is_empty():
		return {
			"ok": false,
			"reason": "no_valid_reward",
			"summary": "Reward recommendation: none",
			"card_id": "",
			"index": -1,
			"score": 0,
			"choice_type": "none",
			"reason_text": "No valid reward card is available.",
			"detail_text": "",
			"candidates": candidates,
		}

	var reason_text = _reward_recommendation_reason(best_card_id, player_count, class_id)
	var detail_text = _reward_recommendation_detail(best_card_id, player_count, class_id, reason_text)
	return {
		"ok": true,
		"reason": "ok",
		"card_id": best_card_id,
		"label": get_card_label(best_card_id),
		"index": best_index,
		"score": best_score,
		"choice_type": "card",
		"reason_text": reason_text,
		"detail_text": detail_text,
		"candidates": candidates,
		"summary": "Suggested reward: %s - %s" % [
			get_card_label(best_card_id),
			reason_text,
		],
	}


func get_reward_recommendation_summary(player_count: int = 1, class_id: String = "") -> String:
	return str(get_reward_recommendation_report(player_count, class_id).get("summary", "Reward recommendation: none"))


func get_last_reward_claim_report() -> Dictionary:
	if last_reward_claim_report.is_empty():
		return {
			"ok": false,
			"reason": "no_reward_claim",
		}

	return last_reward_claim_report.duplicate(true)


func get_last_reward_claim_summary() -> String:
	if last_reward_claim_report.is_empty():
		return "Reward: none"

	if bool(last_reward_claim_report.get("gold_choice", false)):
		return "Reward: last gold choice +%s gold | gold %s -> %s" % [
			last_reward_claim_report.get("gold_gain", 0),
			last_reward_claim_report.get("gold_before", 0),
			last_reward_claim_report.get("gold_after", 0),
		]

	return "Reward: last pick %s [%s] -> discard | copies %s -> %s | %s" % [
		last_reward_claim_report.get("card_label", "?"),
		last_reward_claim_report.get("rarity_label", "Common"),
		last_reward_claim_report.get("deck_count_before", 0),
		last_reward_claim_report.get("deck_count_after", 0),
		last_reward_claim_report.get("deck_after_summary", get_deck_cycle_summary()),
	]


func get_artifact_offer() -> Array:
	return artifact_offer.duplicate()


func get_equipped_artifacts() -> Array:
	return equipped_artifacts.duplicate()


func get_dormant_artifacts() -> Array:
	return dormant_artifacts.duplicate()


func get_equipped_artifact_summary() -> String:
	if equipped_artifacts.is_empty():
		return "none"

	var labels = PackedStringArray()
	for artifact_id in equipped_artifacts:
		labels.append(get_artifact_label(str(artifact_id)))
	return ", ".join(labels)


func get_dormant_artifact_summary() -> String:
	if dormant_artifacts.is_empty():
		return "none"

	var labels = PackedStringArray()
	for artifact_id in dormant_artifacts:
		labels.append(get_artifact_label(str(artifact_id)))
	return ", ".join(labels)


func get_artifact_loadout_summary() -> String:
	return "equipped %s/%s: %s | dormant %s/%s: %s" % [
		equipped_artifacts.size(),
		get_artifact_slot_limit(),
		get_equipped_artifact_summary(),
		dormant_artifacts.size(),
		get_dormant_artifact_limit(),
		get_dormant_artifact_summary(),
	]


func get_artifact_slot_report() -> Dictionary:
	var slot_limit = get_artifact_slot_limit()
	var dormant_limit = get_dormant_artifact_limit()
	return {
		"ok": true,
		"reason": "ok",
		"equipped_count": equipped_artifacts.size(),
		"slot_limit": slot_limit,
		"slot_hard_cap": get_artifact_slot_hard_cap(),
		"slots_full": equipped_artifacts.size() >= slot_limit,
		"dormant_count": dormant_artifacts.size(),
		"dormant_limit": dormant_limit,
		"dormant_full": dormant_limit <= 0 or dormant_artifacts.size() >= dormant_limit,
		"equipped_artifacts": equipped_artifacts.duplicate(),
		"dormant_artifacts": dormant_artifacts.duplicate(),
		"equipped_summary": get_equipped_artifact_summary(),
		"dormant_summary": get_dormant_artifact_summary(),
		"summary": get_artifact_loadout_summary(),
	}


func get_dormant_reactivation_plan(service_id: String = "", reactivation_dormant_artifact_id: String = "", reactivation_replaced_artifact_id: String = "") -> Dictionary:
	if dormant_artifacts.is_empty():
		return {
			"ok": false,
			"reason": "no_dormant_artifact",
			"loadout_summary": get_artifact_loadout_summary(),
		}

	var service_data = get_shop_service_data(service_id) if not service_id.is_empty() else {}
	var dormant_artifact_id = str(dormant_artifacts[0])
	var requested_dormant_id = str(service_data.get("artifactId", ""))
	if not reactivation_dormant_artifact_id.is_empty():
		requested_dormant_id = reactivation_dormant_artifact_id

	if not requested_dormant_id.is_empty() and dormant_artifacts.has(requested_dormant_id):
		dormant_artifact_id = requested_dormant_id
	elif not requested_dormant_id.is_empty():
		return {
			"ok": false,
			"reason": "artifact_not_dormant",
			"dormant_artifact_id": requested_dormant_id,
			"loadout_summary": get_artifact_loadout_summary(),
		}

	var slot_limit = get_artifact_slot_limit()
	var slots_full = equipped_artifacts.size() >= slot_limit
	var replaced_artifact_id = ""
	if slots_full:
		if equipped_artifacts.is_empty():
			return {
				"ok": false,
				"reason": "no_equipped_artifact",
				"loadout_summary": get_artifact_loadout_summary(),
			}

		replaced_artifact_id = str(equipped_artifacts[0])
		var requested_replace_id = str(service_data.get("replaceEquippedArtifactId", ""))
		if not reactivation_replaced_artifact_id.is_empty():
			requested_replace_id = reactivation_replaced_artifact_id

		if not requested_replace_id.is_empty() and equipped_artifacts.has(requested_replace_id):
			replaced_artifact_id = requested_replace_id
		elif not requested_replace_id.is_empty():
			return {
				"ok": false,
				"reason": "artifact_not_equipped",
				"replaced_artifact_id": requested_replace_id,
				"loadout_summary": get_artifact_loadout_summary(),
			}
	elif not reactivation_replaced_artifact_id.is_empty():
		return {
			"ok": false,
			"reason": "artifact_replacement_not_required",
			"replaced_artifact_id": reactivation_replaced_artifact_id,
			"loadout_summary": get_artifact_loadout_summary(),
		}

	return {
		"ok": true,
		"reason": "ok",
		"dormant_artifact_id": dormant_artifact_id,
		"dormant_artifact_label": get_artifact_label(dormant_artifact_id),
		"dormant_artifact_effect": get_artifact_effect_summary(dormant_artifact_id),
		"replaced_artifact_id": replaced_artifact_id,
		"replaced_artifact_label": get_artifact_label(replaced_artifact_id) if not replaced_artifact_id.is_empty() else "",
		"replaced_artifact_effect": get_artifact_effect_summary(replaced_artifact_id) if not replaced_artifact_id.is_empty() else "",
		"slot_limit": slot_limit,
		"slots_full": slots_full,
		"dormant_count": dormant_artifacts.size(),
		"dormant_limit": get_dormant_artifact_limit(),
		"loadout_summary": get_artifact_loadout_summary(),
	}


func get_last_artifact_report() -> Dictionary:
	if last_artifact_report.is_empty():
		return {
			"ok": false,
			"reason": "no_artifact_action",
		}

	return last_artifact_report.duplicate(true)


func get_artifact_to_wave_preparation_report(player_count: int = 1) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if last_artifact_report.is_empty():
		return {
			"ok": false,
			"reason": "no_artifact_action",
			"summary": "",
		}

	if not artifact_offer.is_empty():
		return {
			"ok": false,
			"reason": "artifact_still_open",
			"summary": "",
		}

	if wave_active:
		return {
			"ok": false,
			"reason": "wave_active",
			"summary": "",
		}

	if run_complete:
		return {
			"ok": false,
			"reason": "run_complete",
			"summary": "",
		}

	var preview_card = get_next_wave_preview_card(player_count)
	var next_round = current_round
	var next_directions = []
	var next_role = "pressure"
	if not preview_card.is_empty() and (not preview_card.has("ok") or bool(preview_card.get("ok", false))):
		next_round = int(preview_card.get("round", current_round))
		next_directions = preview_card.get("projectedDirections", preview_card.get("directions", []))
		next_role = str(preview_card.get("primaryEnemyRole", "pressure"))

	var direction_text = _join_values(_array_string_values(next_directions))
	if direction_text.is_empty():
		direction_text = "active front"

	var action_type = str(last_artifact_report.get("artifact_action_type", "equip"))
	var action_label = ""
	var effect_text = ""
	var reminder_text = ""
	if action_type == "skip":
		action_label = "Artifact skipped"
		effect_text = "current passives held: %s" % get_equipped_artifact_summary()
		reminder_text = "start R%s by solving %s on %s without a new passive" % [
			next_round,
			next_role,
			direction_text,
		]
	else:
		var artifact_id = str(last_artifact_report.get("artifact_id", ""))
		action_label = str(last_artifact_report.get("artifact_label", get_artifact_label(artifact_id)))
		effect_text = str(last_artifact_report.get("effect", get_artifact_effect_summary(artifact_id)))
		if action_type == "replace":
			effect_text += " replacing %s now dormant" % last_artifact_report.get("replaced_artifact_label", "an artifact")
			if bool(last_artifact_report.get("dormant_released", false)):
				effect_text += "; released %s with no refund" % last_artifact_report.get("released_dormant_artifact_label", "a dormant artifact")
		elif action_type == "reactivate":
			effect_text += " reactivated from dormant"
			if not str(last_artifact_report.get("replaced_artifact_label", "")).is_empty():
				effect_text += "; %s now dormant" % last_artifact_report.get("replaced_artifact_label", "an artifact")
		reminder_text = _artifact_to_wave_reminder(artifact_id, next_role, direction_text)

	var summary = "Artifact memo: %s; %s. Next R%s: %s." % [
		action_label,
		effect_text,
		next_round,
		reminder_text,
	]
	return {
		"ok": true,
		"reason": "ok",
		"artifact_action_type": action_type,
		"action_label": action_label,
		"effect_text": effect_text,
		"reminder_text": reminder_text,
		"next_round": next_round,
		"next_directions": _array_string_values(next_directions),
		"next_role": next_role,
		"summary": summary,
	}


func get_artifact_to_wave_preparation_summary(player_count: int = 1) -> String:
	var report = get_artifact_to_wave_preparation_report(player_count)
	if not bool(report.get("ok", false)):
		return ""

	return str(report.get("summary", ""))


func has_pending_reward() -> bool:
	return (
		not reward_offer.is_empty()
		or not artifact_offer.is_empty()
		or _has_open_shop_offer()
		or not reward_queue.is_empty()
		or not active_reward_packet.is_empty()
	)


func get_maintenance_check_report(player_count: int = 1) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var pending_steps: Array[String] = []
	if not reward_offer.is_empty():
		pending_steps.append("card reward")
	if not artifact_offer.is_empty():
		pending_steps.append("artifact")
	if _has_open_shop_offer():
		pending_steps.append("shop trim/service")

	var pending_packet_count = get_pending_reward_packet_count()
	if pending_packet_count > 0 and pending_steps.is_empty():
		pending_steps.append("%s settlement packet(s)" % pending_packet_count)
	elif reward_queue.size() > 0:
		pending_steps.append("%s queued packet(s)" % reward_queue.size())

	var settlement_report = get_settlement_batch_report()
	var settlement_summary = ""
	if bool(settlement_report.get("ok", false)) and bool(settlement_report.get("compressed", false)):
		settlement_summary = str(settlement_report.get("summary", ""))

	var gate_report = get_reward_to_maintenance_gate_report()
	var state = "clear" if pending_steps.is_empty() else "blocked"
	var next_step = "start wave" if state == "clear" else "resolve %s" % " / ".join(pending_steps)
	var summary_parts = PackedStringArray()
	summary_parts.append("Maintenance: %s" % ("clear" if state == "clear" else next_step))
	if not settlement_summary.is_empty():
		summary_parts.append(settlement_summary)
	summary_parts.append(str(gate_report.get("summary", "RewardToMaintenanceGate: -")))
	summary_parts.append(get_economy_summary())
	var artifact_to_wave_summary = ""
	if state == "clear":
		artifact_to_wave_summary = get_artifact_to_wave_preparation_summary(player_count)
		if not artifact_to_wave_summary.is_empty():
			summary_parts.append(artifact_to_wave_summary)
	var shop_to_wave_summary = ""
	if state == "clear":
		shop_to_wave_summary = get_shop_to_wave_preparation_summary(player_count)
		if not shop_to_wave_summary.is_empty():
			summary_parts.append(shop_to_wave_summary)
	return {
		"ok": true,
		"reason": "ok",
		"rewardToMaintenanceGate": gate_report,
		"gate_id": gate_report.get("id", ""),
		"state": state,
		"pending_steps": pending_steps,
		"pendingRewardChoiceLockIds": gate_report.get("pendingRewardChoiceLockIds", []),
		"pendingCurseConfirmIds": gate_report.get("pendingCurseConfirmIds", []),
		"pending_packet_count": pending_packet_count,
		"settlement_summary": settlement_summary,
		"settlementBatchId": gate_report.get("settlementBatchId", null),
		"nextScreenType": gate_report.get("nextScreenType", "wave_preview"),
		"canStartPaidShopVote": gate_report.get("canStartPaidShopVote", true),
		"paidShopBlocked": gate_report.get("paidShopBlocked", false),
		"maintenanceSummaryTags": gate_report.get("maintenanceSummaryTags", []),
		"forbiddenGateTags": gate_report.get("forbiddenGateTags", []),
		"economy_summary": get_economy_summary(),
		"artifact_to_wave_summary": artifact_to_wave_summary,
		"shop_to_wave_summary": shop_to_wave_summary,
		"next_step": next_step,
		"summary": " | ".join(summary_parts),
	}


func get_maintenance_check_summary(player_count: int = 1) -> String:
	var report = get_maintenance_check_report(player_count)
	if not bool(report.get("ok", false)):
		return "Maintenance: %s" % str(report.get("reason", "blocked"))

	return str(report.get("summary", "Maintenance: -"))


func get_resource_summary() -> String:
	return "mana=%s gold=%s boss_shards=%s hand=%s/%s draw=%s discard=%s discard_uses=%s gauge=%s/%s artifacts=%s/%s dormant=%s/%s artifact_action=%s/%s reward_packets=%s shop=%s" % [
		mana,
		gold,
		boss_shards,
		hand.size(),
		get_max_hand_size(),
		draw_pile.size(),
		discard_pile.size(),
		discard_charges,
		draw_gauge,
		get_draw_gauge_per_card(),
		equipped_artifacts.size(),
		get_artifact_slot_limit(),
		dormant_artifacts.size(),
		get_dormant_artifact_limit(),
		artifact_actions_remaining,
		get_artifact_action_limit(),
		get_pending_reward_packet_count(),
		shop_purchases_remaining if _has_open_shop_offer() else 0,
	]


func get_last_kill_resource_report() -> Dictionary:
	if last_kill_resource_report.is_empty():
		return {
			"ok": false,
			"reason": "no_kill_yet",
		}

	return last_kill_resource_report.duplicate(true)


func get_last_kill_resource_summary() -> String:
	if last_kill_resource_report.is_empty():
		return "Combat gains: none yet"

	return "Combat gains: %s" % str(last_kill_resource_report.get("summary", "-"))


func get_class_effect_summary() -> String:
	return _class_effect_summary_from_report(_class_effect_report(false))


func get_hand_pressure_report() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var max_hand_size = get_max_hand_size()
	var hand_count = hand.size()
	var hand_room = max(0, max_hand_size - hand_count)
	var threshold = get_draw_gauge_per_card()
	var next_kill_gauge = get_draw_gauge_per_kill()
	var draw_source_count = draw_pile.size() + discard_pile.size()
	var last_draw_held_reason = str(last_kill_resource_report.get("draw_held_reason", ""))
	var state = "open"
	var severity = "ok"
	var action = "keep using cards"
	if last_draw_held_reason == "hand_full":
		state = "draw_held"
		severity = "warning"
		action = "play or discard before the next kill"
	elif hand_count >= max_hand_size and (draw_gauge >= threshold or draw_source_count > 0):
		state = "hand_full"
		severity = "warning"
		action = "play or discard before drawing"
	elif hand_count >= max_hand_size:
		state = "full_no_draw"
		severity = "watch"
		action = "play a card before future draws"
	elif hand_room <= 1 and threshold > 0 and next_kill_gauge > 0 and draw_source_count > 0 and draw_gauge + next_kill_gauge >= threshold:
		state = "near_full"
		severity = "watch"
		action = "leave one more slot before the next kill"

	var report = {
		"ok": true,
		"reason": "ok",
		"state": state,
		"severity": severity,
		"hand_count": hand_count,
		"max_hand_size": max_hand_size,
		"hand_room": hand_room,
		"draw_gauge": draw_gauge,
		"draw_gauge_threshold": threshold,
		"draw_gauge_per_kill": next_kill_gauge,
		"draw_source_count": draw_source_count,
		"last_draw_held_reason": last_draw_held_reason,
		"suggested_action": action,
	}
	report["summary"] = _format_hand_pressure_summary(report)
	return report


func get_hand_pressure_summary() -> String:
	var report = get_hand_pressure_report()
	if not bool(report.get("ok", false)):
		return "Hand pressure: unavailable"

	return str(report.get("summary", "Hand pressure: -"))


func get_map_size() -> Vector2i:
	var map_data: Dictionary = data.get("map", {})
	return Vector2i(int(map_data.get("width", 21)), int(map_data.get("height", 21)))


func get_base_cells() -> Array[Vector2i]:
	var map_data: Dictionary = data.get("map", {})
	var base_data: Dictionary = map_data.get("base", {})
	var origin: Array = base_data.get("origin", [9, 9])
	var size: Array = base_data.get("size", [3, 3])
	var cells: Array[Vector2i] = []

	for y in range(int(size[1])):
		for x in range(int(size[0])):
			cells.append(Vector2i(int(origin[0]) + x, int(origin[1]) + y))

	return cells


func get_entrances() -> Dictionary:
	return data.get("map", {}).get("entrances", {})


func get_active_directions(player_count: int) -> Array:
	var by_count: Dictionary = data.get("activeDirectionsByPlayerCount", {})
	return by_count.get(str(clamp(player_count, 1, 4)), [])


func get_lane_projection_report(player_count: int, round_number = -1) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var normalized_player_count = clamp(player_count, 1, 4)
	var target_round = _next_preview_round() if int(round_number) <= 0 else int(round_number)
	if target_round > get_max_rounds():
		return _reject("no_next_round")

	var active_directions = _array_string_values(get_active_directions(normalized_player_count))
	if active_directions.is_empty():
		return _reject("no_active_direction")

	var boss_enemy_id = _boss_enemy_id() if _is_boss_round(target_round) else ""
	var enemy_roles = _wave_enemy_role_tags(get_enemy_mix_ids(target_round), boss_enemy_id)
	var inferred_primary_enemy_role = _wave_primary_enemy_role_for_round(target_round, enemy_roles, boss_enemy_id)
	var scheduled_intent_id = _wave_intent_id_for_round(target_round)
	var primary_enemy_role = _wave_intent_primary_role(scheduled_intent_id, inferred_primary_enemy_role)
	var wave_intent_id = scheduled_intent_id
	if wave_intent_id.is_empty():
		wave_intent_id = _wave_intent_id_for_role(target_round, primary_enemy_role)
	var projected_directions = _lane_projection_directions(target_round, active_directions, wave_intent_id, primary_enemy_role)
	var uses_inactive = _wave_preview_uses_inactive_direction(projected_directions, active_directions)
	var wave_intent = _build_wave_intent_report(target_round, wave_intent_id, primary_enemy_role, enemy_roles, inferred_primary_enemy_role)
	return {
		"ok": true,
		"reason": "ok",
		"id": _lane_projection_id(target_round, normalized_player_count),
		"laneProjectionId": _lane_projection_id(target_round, normalized_player_count),
		"waveId": _wave_id(target_round),
		"round": target_round,
		"day": target_round,
		"playerCount": normalized_player_count,
		"playerCountAtStart": normalized_player_count,
		"activeDirections": active_directions.duplicate(),
		"directions": projected_directions.duplicate(),
		"projectedDirections": projected_directions.duplicate(),
		"primaryDirection": "" if projected_directions.is_empty() else str(projected_directions[0]),
		"secondaryDirections": projected_directions.slice(1),
		"maxSimultaneousFronts": projected_directions.size(),
		"projectionMode": _lane_projection_mode(projected_directions, active_directions),
		"waveIntentId": wave_intent_id,
		"waveIntent": wave_intent,
		"enemyRoles": enemy_roles.duplicate(),
		"primaryEnemyRole": primary_enemy_role,
		"inferredPrimaryEnemyRole": inferred_primary_enemy_role,
		"usesInactiveDirections": uses_inactive,
		"forbiddenProjectionTags": LANE_PROJECTION_FORBIDDEN_TAGS.duplicate(),
		"summary": _format_lane_projection_summary(target_round, active_directions, projected_directions, wave_intent_id),
	}


func get_structure_tiles() -> Dictionary:
	return structures


func get_enemy_tiles() -> Dictionary:
	var counts = {}
	for enemy in enemies:
		var key = _tile_key(enemy["tile"])
		counts[key] = int(counts.get(key, 0)) + 1
	return counts


func get_enemy_trait_tiles() -> Dictionary:
	var tiles = {}
	for enemy in enemies:
		var key = _tile_key(enemy["tile"])
		var entry: Dictionary = tiles.get(key, {
			"count": 0,
			"fast_count": 0,
			"breaker_count": 0,
			"armor_count": 0,
			"boss_count": 0,
		})

		entry["count"] = int(entry.get("count", 0)) + 1
		if _enemy_move_steps(enemy) > 1:
			entry["fast_count"] = int(entry.get("fast_count", 0)) + 1
		if _enemy_prioritizes_structures(enemy):
			entry["breaker_count"] = int(entry.get("breaker_count", 0)) + 1
		if _enemy_damage_reduction(enemy) > 0:
			entry["armor_count"] = int(entry.get("armor_count", 0)) + 1
		if _is_boss_enemy(enemy):
			entry["boss_count"] = int(entry.get("boss_count", 0)) + 1

		entry["primary"] = _enemy_trait_tile_primary(entry)
		entry["label"] = _enemy_trait_tile_label(entry)
		entry["summary"] = _enemy_trait_tile_summary(entry)
		tiles[key] = entry

	return tiles


func get_boss_enemy_tiles() -> Dictionary:
	var counts = {}
	for enemy in enemies:
		if not _is_boss_enemy(enemy):
			continue

		var key = _tile_key(enemy["tile"])
		counts[key] = int(counts.get(key, 0)) + 1
	return counts


func get_boss_part_reports() -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	for enemy in enemies:
		if not _is_boss_enemy(enemy):
			continue

		var focus_part_id = _boss_focus_part_id(enemy)
		var parts = _boss_sorted_parts(enemy)
		for part in parts:
			var part_id = str(part.get("id", ""))
			reports.append({
				"enemy_id": int(enemy.get("id", -1)),
				"boss_enemy_id": str(enemy.get("enemy_id", "")),
				"boss_label": str(_enemy_data(enemy).get("label", "Boss")),
				"tile": enemy.get("tile", Vector2i.ZERO),
				"part_id": part_id,
				"label": str(part.get("label", part_id)),
				"hp": int(part.get("hp", 0)),
				"max_hp": int(part.get("max_hp", 0)),
				"priority": int(part.get("priority", 0)),
				"destroyed": int(part.get("hp", 0)) <= 0,
				"focus": part_id == focus_part_id,
				"effect_summary": _boss_part_effect_summary(part),
			})

	return reports


func get_boss_part_summary() -> String:
	var reports = get_boss_part_reports()
	if reports.is_empty():
		return "Boss parts: none"

	var parts = PackedStringArray()
	var focus_label = ""
	for report in reports:
		var label = str(report.get("label", report.get("part_id", "part")))
		var status = "broken" if bool(report.get("destroyed", false)) else "%s/%s" % [
			report.get("hp", 0),
			report.get("max_hp", 0),
		]
		if bool(report.get("focus", false)):
			focus_label = label
		parts.append("%s %s" % [label, status])

	if focus_label.is_empty():
		focus_label = "body"

	return "Boss parts: %s | focus %s" % [
		", ".join(parts),
		focus_label,
	]


func get_boss_focus_part_report(tile: Vector2i) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	var enemy_index = _find_enemy_index_at_tile(tile)
	if enemy_index < 0:
		return _reject("no_enemy_at_tile")

	var report = _boss_focus_part_report_for_enemy(enemies[enemy_index])
	if bool(report.get("ok", false)):
		report["tile"] = tile
	return report


func get_boss_focus_part_summary(tile: Vector2i) -> String:
	var report = get_boss_focus_part_report(tile)
	if not bool(report.get("ok", false)):
		return "Boss focus: none"

	return str(report.get("summary", "Boss focus: none"))


func get_boss_part_warning_report(player_count: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var active_directions = get_active_directions(player_count)
	var blocked = _blocked_tiles()
	var best_report = {}
	var best_score = -999999
	for enemy in enemies:
		if not _is_boss_enemy(enemy):
			continue

		if not active_directions.has(str(enemy.get("direction", ""))):
			continue

		var report = _boss_part_warning_report_for_enemy(enemy, blocked)
		if not bool(report.get("ok", false)):
			continue

		var score = int(report.get("score", 0))
		if best_report.is_empty() or score > best_score:
			best_report = report
			best_score = score

	if best_report.is_empty():
		return _reject("no_boss_part_warning")

	return best_report


func get_boss_part_warning_summary(player_count: int) -> String:
	var report = get_boss_part_warning_report(player_count)
	if not bool(report.get("ok", false)):
		return "Boss part warning: none"

	return str(report.get("summary", "Boss part warning: none"))


func get_enemy_intents(player_count: int) -> Array[Dictionary]:
	var intents: Array[Dictionary] = []
	if not is_loaded() or enemies.is_empty():
		return intents

	var blocked = _blocked_tiles()
	for enemy in enemies:
		if not get_active_directions(player_count).has(str(enemy.get("direction", ""))):
			continue

		var intent = _predict_enemy_intent(enemy, blocked)
		if not intent.is_empty():
			intents.append(intent)

	return intents


func get_enemy_intent_tiles(player_count: int) -> Dictionary:
	var tiles = {}
	for intent in get_enemy_intents(player_count):
		var tile: Vector2i = intent.get("tile", Vector2i.ZERO)
		var key = _tile_key(tile)
		var entry: Dictionary = tiles.get(key, {
			"count": 0,
			"attack_count": 0,
			"siege_count": 0,
			"base_count": 0,
			"move_count": 0,
			"break_count": 0,
			"wait_count": 0,
			"boss_count": 0,
		})
		var action = str(intent.get("action", "wait"))
		entry["count"] = int(entry.get("count", 0)) + 1
		if bool(intent.get("boss", false)):
			entry["boss_count"] = int(entry.get("boss_count", 0)) + 1

		match action:
			"boss_siege":
				entry["siege_count"] = int(entry.get("siege_count", 0)) + 1
			"attack_structure":
				entry["attack_count"] = int(entry.get("attack_count", 0)) + 1
			"hit_base":
				entry["base_count"] = int(entry.get("base_count", 0)) + 1
			"move":
				entry["move_count"] = int(entry.get("move_count", 0)) + 1
			"break_path":
				entry["break_count"] = int(entry.get("break_count", 0)) + 1
			_:
				entry["wait_count"] = int(entry.get("wait_count", 0)) + 1

		entry["severity"] = _enemy_intent_tile_severity(entry)
		entry["summary"] = _enemy_intent_tile_summary(entry)
		tiles[key] = entry

	return tiles


func get_enemy_intent_summary(player_count: int) -> String:
	var intent_tiles = get_enemy_intent_tiles(player_count)
	if intent_tiles.is_empty():
		return "Intents: none"

	var attack_count = 0
	var siege_count = 0
	var base_count = 0
	var move_count = 0
	var break_count = 0
	var wait_count = 0
	var boss_count = 0
	for entry in intent_tiles.values():
		attack_count += int(entry.get("attack_count", 0))
		siege_count += int(entry.get("siege_count", 0))
		base_count += int(entry.get("base_count", 0))
		move_count += int(entry.get("move_count", 0))
		break_count += int(entry.get("break_count", 0))
		wait_count += int(entry.get("wait_count", 0))
		boss_count += int(entry.get("boss_count", 0))

	return "Intents: base=%s attack=%s siege=%s move=%s break=%s wait=%s boss=%s" % [
		base_count,
		attack_count,
		siege_count,
		move_count,
		break_count,
		wait_count,
		boss_count,
	]


func get_wave_tactical_report(player_count: int, class_id: String = "") -> Dictionary:
	if not is_loaded():
		return _wave_tactical_report(false, "data_not_loaded", "data", "Data missing", "Load M0 data first.", "", {}, "Tactics: data missing")

	if not wave_active:
		return _wave_tactical_report(true, "idle", "idle", "No active wave", "Start a wave to reveal live enemy intent.", _wave_tactical_idle_card_hint(class_id), {}, "Tactics: idle - start a wave")

	if enemies.is_empty():
		return _wave_tactical_report(true, "spawning", "watch", "Spawning window", "Watch entrances; first enemies have not entered the kill zone yet.", _wave_tactical_idle_card_hint(class_id), {}, "Tactics: spawning - watch entrances")

	var intents = get_enemy_intents(player_count)
	if intents.is_empty():
		return _wave_tactical_report(true, "no_intent", "watch", "No readable threat", "Step the wave and watch for the next intent marker.", _wave_tactical_idle_card_hint(class_id), {}, "Tactics: no readable threat")

	var threat = _highest_priority_wave_intent(intents)
	var action = str(threat.get("action", "wait"))
	var severity = _wave_tactical_severity(action)
	var card_hint = _wave_tactical_card_hint(threat, class_id)
	var headline = _wave_tactical_headline(threat)
	var suggestion = _wave_tactical_suggestion(threat, card_hint)
	var summary = "Tactics: %s | %s | %s" % [
		headline,
		suggestion,
		card_hint,
	]
	return _wave_tactical_report(true, "active", severity, headline, suggestion, card_hint, threat, summary)


func get_wave_tactical_summary(player_count: int, class_id: String = "") -> String:
	return str(get_wave_tactical_report(player_count, class_id).get("summary", "Tactics: -"))


func get_risk_ping_report(player_count: int, class_id: String = "") -> Dictionary:
	if not is_loaded():
		return _risk_ping_report(false, "data_not_loaded", "data", "data missing", [], "Risk pings: data missing")

	if not wave_active:
		return _risk_ping_report(true, "idle", "idle", "no active wave", [], "Risk pings: none - start a wave")

	var candidates: Array[Dictionary] = []
	var tactical_report = get_wave_tactical_report(player_count, class_id)
	var source = "none"
	var source_label = "no urgent threat"
	var severity = str(tactical_report.get("severity", "watch"))

	if str(tactical_report.get("state", "")) == "active":
		var threat: Dictionary = tactical_report.get("threat", {})
		source = str(threat.get("action", "wait"))
		source_label = _risk_ping_source_label(threat, tactical_report)
		_append_risk_ping_candidates_for_threat(candidates, threat, tactical_report, player_count)

	if candidates.is_empty():
		var stack_report = get_wave_stack_risk_report(player_count)
		var stack_severity = str(stack_report.get("severity", ""))
		if has_active_wave_stack_vote() or ["risky", "critical"].has(stack_severity):
			source = "wave_pull"
			source_label = "wave pull risk"
			severity = stack_severity
			_append_risk_ping_candidates_for_stack(candidates, stack_report)

	if candidates.is_empty():
		var worst_front = _worst_front_pressure(player_count)
		var front_severity = str(worst_front.get("severity", "idle"))
		if ["danger", "critical"].has(front_severity):
			source = "front_pressure"
			source_label = "%s front pressure" % _direction_label(str(worst_front.get("direction", "")))
			severity = front_severity
			_add_risk_ping_candidate(candidates, "Slow/control request", "slow_control", "Buy time on the pressured front.")
			_add_risk_ping_candidate(candidates, "Focus fire", "focus_fire", "Remove the nearest threat before it leaks.")
			_add_risk_ping_candidate(candidates, "Route check", "route_check", "Check whether the path became too short.")

	if candidates.is_empty():
		return _risk_ping_report(true, "clear", "clear", source_label, [], "Risk pings: none - no urgent ping candidate")

	return _risk_ping_report(true, source, severity, source_label, candidates)


func get_risk_ping_summary(player_count: int, class_id: String = "") -> String:
	return str(get_risk_ping_report(player_count, class_id).get("summary", "Risk pings: -"))


func get_front_pressure(player_count: int) -> Array[Dictionary]:
	var fronts: Array[Dictionary] = []
	var blocked = _blocked_tiles()

	for direction in get_active_directions(player_count):
		var direction_text = str(direction)
		var enemy_count = 0
		var boss_count = 0
		var nearest_steps = -1

		for enemy in enemies:
			if str(enemy.get("direction", "")) != direction_text:
				continue

			enemy_count += 1
			if _is_boss_enemy(enemy):
				boss_count += 1

			var path = _find_path(enemy["tile"], blocked)
			var steps = path.size() - 1
			if steps >= 0 and (nearest_steps < 0 or steps < nearest_steps):
				nearest_steps = steps

		var severity = _front_pressure_severity(enemy_count, nearest_steps, boss_count)
		fronts.append({
			"direction": direction_text,
			"enemy_count": enemy_count,
			"boss_count": boss_count,
			"nearest_steps": nearest_steps,
			"severity": severity,
			"summary": _format_front_pressure(direction_text, enemy_count, nearest_steps, boss_count),
		})

	return fronts


func get_front_pressure_by_direction(player_count: int) -> Dictionary:
	var by_direction = {}
	for front in get_front_pressure(player_count):
		by_direction[str(front.get("direction", ""))] = front
	return by_direction


func get_front_defense_report(player_count: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var active_directions = get_active_directions(player_count)
	if active_directions.is_empty():
		return _reject("no_active_direction")

	var paths_by_direction: Dictionary = get_path_cells_by_direction(player_count)
	var pressure_by_direction: Dictionary = get_front_pressure_by_direction(player_count)
	var fronts: Array = []
	var by_direction = {}
	var order_index = 0

	for direction_value in active_directions:
		var direction = str(direction_value)
		var path: Array = paths_by_direction.get(direction, [])
		var coverage = _front_defense_coverage_for_path(path)
		var pressure: Dictionary = pressure_by_direction.get(direction, {})
		var stat_report = _front_direction_stat_report(direction)
		var structure_count = int(coverage.get("structure_count", 0))
		var pressure_severity = str(pressure.get("severity", "idle"))
		var entry = {
			"direction": direction,
			"order_index": order_index,
			"minimum_structure_count": FRONT_MIN_STRUCTURE_COUNT,
			"needs_minimum_defense": structure_count < FRONT_MIN_STRUCTURE_COUNT,
			"structure_count": structure_count,
			"tower_count": int(coverage.get("tower_count", 0)),
			"barricade_count": int(coverage.get("barricade_count", 0)),
			"damaged_count": int(coverage.get("damaged_count", 0)),
			"critical_count": int(coverage.get("critical_count", 0)),
			"total_hp": int(coverage.get("total_hp", 0)),
			"pressure": pressure,
			"pressure_severity": pressure_severity,
			"pressure_rank": _front_pressure_rank(pressure_severity),
			"base_hits": int(stat_report.get("base_hits", 0)),
			"boss_base_hits": int(stat_report.get("boss_base_hits", 0)),
			"base_damage": int(stat_report.get("base_damage", 0)),
			"structures_destroyed": int(stat_report.get("structures_destroyed", 0)),
			"planned_collapses": int(stat_report.get("planned_collapses", 0)),
			"planned_collapse_damage": int(stat_report.get("planned_collapse_damage", 0)),
		}
		entry["score"] = _front_defense_score(entry)
		entry["summary"] = _front_defense_summary(entry)
		fronts.append(entry)
		by_direction[direction] = entry
		order_index += 1

	var priority_directions = _front_defense_priority(fronts)
	return {
		"ok": true,
		"reason": "ok",
		"active_directions": active_directions.duplicate(),
		"minimum_structure_count": FRONT_MIN_STRUCTURE_COUNT,
		"fronts": fronts,
		"by_direction": by_direction,
		"priority_directions": priority_directions,
		"weakest_direction": "" if priority_directions.is_empty() else str(priority_directions[0]),
		"summary": _front_defense_report_summary(fronts),
	}


func get_front_pressure_summary(player_count: int) -> String:
	if not is_loaded():
		return "Fronts: -"

	var parts = PackedStringArray()
	for front in get_front_pressure(player_count):
		parts.append(str(front.get("summary", "")))

	if parts.size() == 0:
		return "Fronts: none"

	return "Fronts: %s" % " | ".join(parts)


func get_front_defense_summary(player_count: int) -> String:
	var report = get_front_defense_report(player_count)
	if not bool(report.get("ok", false)):
		return "Defense fronts: %s" % report.get("reason", "unknown")

	return str(report.get("summary", "Defense fronts: -"))


func get_run_outcome_report(player_count: int) -> Dictionary:
	if not is_loaded():
		return {
			"state": "unloaded",
			"focus": "data",
			"headline": "Data not loaded.",
			"primary_direction": "",
			"next_suggestion": "Load M0 data before reading the run.",
			"details": [],
		}

	var active_directions = get_active_directions(player_count)
	var leak = _top_bucket_value("base_hits_by_direction", active_directions)
	var boss_leak = _top_bucket_value("boss_base_hits_by_direction", active_directions)
	var collapse = _top_bucket_value("structures_destroyed_by_direction", active_directions)
	var planned_collapse = _top_bucket_value("planned_collapses_by_direction", active_directions)
	var total_leaks = _total_bucket_value("base_hits_by_direction", active_directions)
	var total_collapses = _total_bucket_value("structures_destroyed_by_direction", active_directions)
	var total_planned_collapses = _total_bucket_value("planned_collapses_by_direction", active_directions)
	var total_planned_collapse_damage = _total_bucket_value("planned_collapse_damage_by_direction", active_directions)
	var enemies_data: Dictionary = data.get("enemies", {})
	var top_enemy = _top_bucket_value("base_hits_by_enemy_id", enemies_data.keys())
	var primary_direction = str(leak.get("key", ""))
	var headline = "Stable: no leaks yet."
	var focus = "stable"
	var state = "stable"
	var next_suggestion = "Keep comparing front pressure before pulling the next wave."
	var details: Array = []

	if base_hp <= 0:
		state = "failed"
		if int(boss_leak.get("value", 0)) > 0:
			focus = "boss_leak"
			primary_direction = str(boss_leak.get("key", ""))
			headline = "Failed: boss reached base from %s." % _direction_label(primary_direction)
			next_suggestion = "Next run: create a wider boss delay pocket on %s." % _direction_label(primary_direction)
		elif int(leak.get("value", 0)) > 0:
			focus = "front_leak"
			headline = "Failed: %s leaked %s times." % [
				_direction_label(primary_direction),
				leak.get("value", 0),
			]
			next_suggestion = "Next run: add an earlier slow or barricade on %s." % _direction_label(primary_direction)
		else:
			focus = "unknown_failure"
			headline = "Failed: base was destroyed."
			next_suggestion = "Next run: watch the last base damage event and rebuild that lane first."
	elif run_complete:
		state = "complete"
		focus = "complete"
		headline = "Complete: survived %s rounds." % get_max_rounds()
		next_suggestion = "Review leaks and collapses before raising difficulty."
	elif total_leaks > 0:
		state = "warning"
		focus = "front_leak"
		headline = "Warning: %s leaked %s times." % [
			_direction_label(primary_direction),
			leak.get("value", 0),
		]
		next_suggestion = "Next round: reinforce %s before adding new damage." % _direction_label(primary_direction)
	elif total_collapses > 0:
		if total_planned_collapses >= total_collapses and total_planned_collapse_damage > 0:
			state = "stable"
			focus = "planned_collapse"
			primary_direction = str(planned_collapse.get("key", ""))
			headline = "Tactical: planned collapse dealt %s damage." % total_planned_collapse_damage
			next_suggestion = "Next round: rebuild the spent %s pocket before stacking pressure." % _direction_label(primary_direction)
		else:
			state = "strained"
			focus = "structure_collapse"
			primary_direction = str(collapse.get("key", ""))
			headline = "Strained: %s lost %s structures." % [
				_direction_label(primary_direction),
				collapse.get("value", 0),
			]
			next_suggestion = "Next round: decide which %s structures are meant to break." % _direction_label(primary_direction)

	if total_leaks > 0:
		details.append("base_leaks=%s" % total_leaks)
	if int(top_enemy.get("value", 0)) > 0:
		details.append("top_leaker=%s x%s" % [
			get_enemy_label(str(top_enemy.get("key", ""))),
			top_enemy.get("value", 0),
		])
	if total_collapses > 0:
		details.append("structure_collapses=%s" % total_collapses)
	if total_planned_collapses > 0:
		details.append("planned_collapses=%s" % total_planned_collapses)
	if total_planned_collapse_damage > 0:
		details.append("planned_collapse_damage=%s" % total_planned_collapse_damage)
	details.append("base_hp=%s" % base_hp)
	details.append("completed=%s/%s" % [completed_rounds, get_max_rounds()])

	return {
		"state": state,
		"focus": focus,
		"headline": headline,
		"primary_direction": primary_direction,
		"next_suggestion": next_suggestion,
		"leak_count": total_leaks,
		"structure_collapse_count": total_collapses,
		"planned_collapse_count": total_planned_collapses,
		"planned_collapse_damage": total_planned_collapse_damage,
		"boss_leak_count": int(boss_leak.get("value", 0)),
		"top_leaker": str(top_enemy.get("key", "")),
		"details": details,
	}


func get_run_outcome_summary(player_count: int) -> String:
	var report = get_run_outcome_report(player_count)
	var details = PackedStringArray()
	for detail in report.get("details", []):
		details.append(str(detail))
	var detail_text = ", ".join(details) if not details.is_empty() else "no details"
	return "%s | %s | next: %s" % [
		report.get("headline", "Outcome unavailable."),
		detail_text,
		report.get("next_suggestion", "-"),
	]


func get_tutorial_hint(player_count: int) -> Dictionary:
	if not is_loaded():
		return _tutorial_hint(false, "data", 0, "Data not loaded.", last_error, "Load M0 data.", "blocked")

	var tutorial_rounds = get_tutorial_rounds()
	if tutorial_rounds <= 0:
		return _tutorial_hint(false, "off", 0, "Tutorial disabled.", "", "", "idle")

	if not artifact_offer.is_empty():
		return _tutorial_hint(
			true,
			"artifact",
			min(tutorial_rounds, max(1, completed_rounds)),
			"Equip the boss artifact.",
			"Artifacts are party-wide passives. Pick one before the next wave starts.",
			"Choose an artifact or skip it.",
			"reward"
		)

	if not reward_offer.is_empty():
		return _tutorial_hint(
			true,
			"reward",
			min(tutorial_rounds, max(1, completed_rounds)),
			"Choose a card or take gold.",
			"Cards enter the discard pile. Gold keeps the deck lean and helps future shop trims.",
			"Pick the card that solves your weakest front, or take gold if the deck is already stable.",
			"reward"
		)

	if _has_open_shop_offer():
		return _tutorial_hint(
			true,
			"shop",
			min(tutorial_rounds, max(1, completed_rounds)),
			"Use the boss shop.",
			"Trim a weak card, restore the base, or reinforce existing structures before the next wave.",
			"Buy one offered option or skip the shop.",
			"reward"
		)

	if completed_rounds >= tutorial_rounds and not wave_active:
		return _tutorial_hint(false, "complete", tutorial_rounds, "Tutorial complete.", "", "", "idle")

	if wave_active:
		return _active_tutorial_hint(player_count, tutorial_rounds)

	if structures.is_empty():
		return _tutorial_hint(
			true,
			"setup",
			1,
			"Build the first kill zone.",
			"Start with one tower near the active path and one barricade to bend enemy movement.",
			"Select a structure card or build mode, then click a green target tile.",
			"info"
		)

	var damaged_structures = _count_damaged_structures()
	if damaged_structures > 0:
		return _tutorial_hint(
			true,
			"repair",
			min(tutorial_rounds, current_round),
			"Repair before expanding.",
			"%s structures are damaged. A broken defense may open the shortest route to base." % damaged_structures,
			"Use a repair card or place a replacement before starting the next wave.",
			"warning"
		)

	if current_round <= 1:
		return _tutorial_hint(
			true,
			"start_wave",
			1,
			"Start the first wave.",
			"Your first defense is ready enough for M0. Watch enemy intents as they move.",
			"Press Start wave, then Step or Auto step.",
			"info"
		)

	if current_round == 2:
		return _tutorial_hint(
			true,
			"reinforce",
			2,
			"Reinforce the active fronts.",
			"Player count decides active directions. More players means more lanes need a basic delay pocket.",
			"Add one tower or barricade near the weakest active front.",
			"info"
		)

	return _tutorial_hint(
		true,
		"stack_intro",
		min(tutorial_rounds, current_round),
		"Try an early call only when stable.",
		"Wave stacking removes waiting time but does not add bonus rewards.",
		"Check Stack risk; if it is stable, try Pull next wave. If not, repair first.",
		"info"
	)


func get_tutorial_summary(player_count: int) -> String:
	var hint = get_tutorial_hint(player_count)
	if not bool(hint.get("visible", false)):
		return "Tutorial: complete"

	return "Tutorial %s/%s: %s %s Next: %s" % [
		hint.get("step", 0),
		get_tutorial_rounds(),
		hint.get("title", "-"),
		hint.get("body", ""),
		hint.get("action", "-"),
	]


func get_wave_stack_summary() -> String:
	if not wave_active:
		return "Stack: idle limit=%s tempo-only no bonus" % get_wave_stack_limit()

	var packet_parts = PackedStringArray()
	for packet in active_wave_packets:
		packet_parts.append("%s:%s/%s" % [
			packet.get("round", 0),
			packet.get("spawned", 0),
			packet.get("total", 0),
		])

	return "Stack: %s/%s [%s] pull_next=%s tempo-only no bonus" % [
		get_active_wave_stack_depth(),
		get_wave_stack_limit(),
		", ".join(packet_parts),
		_next_stack_round(),
	]


func get_wave_stack_action_label(player_count: int) -> String:
	if has_active_wave_stack_vote() and player_count > 1:
		return "Approve pull"

	return "Pull next wave"


func get_wave_stack_risk_report(player_count: int) -> Dictionary:
	if not is_loaded():
		return _wave_stack_risk_blocked("data_not_loaded")

	if not wave_active:
		return {
			"can_call": false,
			"severity": "idle",
			"score": 0,
			"round": current_round,
			"headline": "No active wave.",
			"suggestion": "Start a wave before pulling the next one.",
			"tempo_line": _wave_stack_tempo_line(current_round + 1),
			"no_bonus": true,
			"details": [],
			"detail_labels": [],
		}

	var stack_check = can_stack_next_wave(player_count)
	if not bool(stack_check.get("ok", false)):
		return _wave_stack_risk_blocked(str(stack_check.get("reason", "blocked")))

	var score = 0
	var details = PackedStringArray()
	var active_direction_count = max(1, get_active_directions(player_count).size())
	var base_max = max(1, int(data.get("base", {}).get("hp", 100)))
	var base_percent = float(base_hp) / float(base_max)
	var planned_depth = get_active_wave_stack_depth() + 1
	var next_round = _next_stack_round()
	var incoming_count = _get_spawn_count(next_round)
	var damaged_structures = _count_damaged_structures()
	var critical_structures = _count_critical_structures()
	var active_enemy_count = enemies.size()
	var boss_count = _active_boss_count()
	var worst_front = _worst_front_pressure(player_count)
	var worst_front_severity = str(worst_front.get("severity", "idle"))
	var hand_pressure = get_hand_pressure_report()
	var hand_pressure_state = str(hand_pressure.get("state", "open"))
	var hand_pressure_value = "%s/%s" % [
		hand_pressure.get("hand_count", hand.size()),
		hand_pressure.get("max_hand_size", get_max_hand_size()),
	]

	if base_percent <= 0.3:
		score += 5
		details.append("base_critical")
	elif base_percent <= 0.5:
		score += 2
		details.append("base_low")

	if boss_count > 0:
		score += 3
		details.append("boss_active")

	if worst_front_severity == "critical":
		score += 3
		details.append("front_critical:%s" % worst_front.get("direction", "front"))
	elif worst_front_severity == "danger":
		score += 1
		details.append("front_danger:%s" % worst_front.get("direction", "front"))

	if critical_structures > 0:
		score += 3
		details.append("critical_structures=%s" % critical_structures)
	elif damaged_structures > 0:
		score += 2
		details.append("damaged_structures=%s" % damaged_structures)

	if active_enemy_count >= active_direction_count * 4:
		score += 3
		details.append("enemy_density_high=%s" % active_enemy_count)
	elif active_enemy_count >= active_direction_count * 2:
		score += 1
		details.append("enemy_density_medium=%s" % active_enemy_count)

	if ["draw_held", "hand_full"].has(hand_pressure_state):
		score += 3
		details.append("hand_pressure_%s=%s" % [hand_pressure_state, hand_pressure_value])
	elif ["near_full", "full_no_draw"].has(hand_pressure_state):
		score += 1
		details.append("hand_pressure_%s=%s" % [hand_pressure_state, hand_pressure_value])

	if planned_depth >= get_wave_stack_limit():
		score += 2
		details.append("last_stack_slot")
	elif get_active_wave_stack_depth() > 1:
		score += 1
		details.append("already_stacked")

	if incoming_count >= 16:
		score += 1
		details.append("large_next_wave=%s" % incoming_count)

	var severity = _wave_stack_risk_severity(score)
	var detail_labels = _wave_stack_risk_detail_labels(details)
	return {
		"can_call": true,
		"severity": severity,
		"score": score,
		"round": next_round,
		"planned_depth": planned_depth,
		"incoming_count": incoming_count,
		"headline": "Pull next risk: %s for round %s." % [severity, next_round],
		"suggestion": _wave_stack_risk_suggestion(severity),
		"tempo_line": _wave_stack_tempo_line(next_round),
		"no_bonus": true,
		"details": details,
		"detail_labels": detail_labels,
	}


func get_wave_stack_risk_summary(player_count: int) -> String:
	var report = get_wave_stack_risk_report(player_count)
	var details = PackedStringArray()
	for detail in report.get("detail_labels", []):
		details.append(str(detail))

	var detail_text = ", ".join(details) if not details.is_empty() else "no extra risk"
	return "%s %s | %s | %s" % [
		report.get("headline", "Pull next risk unavailable."),
		detail_text,
		report.get("suggestion", "-"),
		report.get("tempo_line", "Tempo only: no bonus rewards."),
	]


func get_wave_pull_decision_report(player_count: int) -> Dictionary:
	var risk_report = get_wave_stack_risk_report(player_count)
	var severity = str(risk_report.get("severity", "blocked"))
	var can_call = bool(risk_report.get("can_call", false))
	var watch_labels = _wave_pull_watch_labels(risk_report.get("detail_labels", []))
	var decision = _wave_pull_decision_label(can_call, severity)
	var next_step = _wave_pull_decision_next_step(can_call, severity, risk_report)
	return {
		"ok": true,
		"decision": decision,
		"severity": severity,
		"can_call": can_call,
		"watch_labels": watch_labels,
		"headline": "Pull check: %s" % decision,
		"next_step": next_step,
		"no_bonus": true,
		"risk": risk_report,
	}


func get_wave_pull_decision_summary(player_count: int) -> String:
	var report = get_wave_pull_decision_report(player_count)
	var watch_labels = PackedStringArray()
	for label in report.get("watch_labels", []):
		watch_labels.append(str(label))

	var watch_text = ", ".join(watch_labels) if not watch_labels.is_empty() else "no extra risk"
	return "%s | Watch: %s | %s | No bonus rewards." % [
		report.get("headline", "Pull check: unavailable"),
		watch_text,
		report.get("next_step", "-"),
	]


func has_active_wave_stack_vote() -> bool:
	return not wave_stack_vote.is_empty()


func get_active_wave_stack_vote_session() -> Dictionary:
	return wave_stack_vote.duplicate(true)


func get_wave_stack_required_votes(player_count: int) -> int:
	var normalized_count = clamp(player_count, 1, 4)
	if normalized_count <= 1:
		return 1

	if _is_base_critical_for_stack_vote():
		return normalized_count

	return int(floor(float(normalized_count) / 2.0)) + 1


func _base_hp_percent() -> float:
	var base_max = max(1, int(data.get("base", {}).get("hp", 100)))
	return float(base_hp) / float(base_max)


func _wave_stack_required_consent_mode(player_count: int) -> String:
	var normalized_count = clamp(player_count, 1, 4)
	if normalized_count <= 1:
		return "solo_confirm"
	if _is_base_critical_for_stack_vote():
		return "unanimous"
	return "majority"


func _player_ids_for_count(count: int) -> Array:
	var ids: Array = []
	for index in range(max(0, count)):
		ids.append("player_%s" % (index + 1))
	return ids


func _hold_player_ids_for_vote(player_count: int, approvals: int) -> Array:
	var ids: Array = []
	for index in range(max(0, approvals), clamp(player_count, 1, 4)):
		ids.append("player_%s" % (index + 1))
	return ids


func _wave_stack_vote_session_id(round_number: int, vote_index: int) -> String:
	return "stack_vote_day_%s_%s" % [
		_round_id_suffix(round_number),
		_round_id_suffix(vote_index),
	]


func _wave_stack_preview_card_ids(round_number: int) -> Array:
	return [
		_wave_preview_card_id(round_number),
	]


func _wave_stack_risk_level_for_vote(severity: String) -> String:
	match severity:
		"stable":
			return "low"
		"risky":
			return "medium"
		"critical":
			return "high"
		_:
			return "locked"


func _wave_stack_risk_reason_text_id(risk_report: Dictionary) -> String:
	var details: Array = risk_report.get("details", [])
	if not details.is_empty():
		return "stack_risk_%s" % str(details[0]).replace(":", "_").replace("=", "_")

	return "stack_risk_%s" % str(risk_report.get("severity", "unknown"))


func _build_wave_stack_vote_session(player_count: int, next_round: int, risk_report: Dictionary) -> Dictionary:
	var normalized_count = clamp(player_count, 1, 4)
	var vote_index = int(run_stats.get("wave_stack_votes_started", 0)) + 1
	var current_wave_rounds = _active_wave_rounds()
	var active_directions = _array_string_values(get_active_directions(normalized_count))
	var preview_card = _cached_wave_preview_card(normalized_count, next_round, active_directions)
	var spawn_plan = _cached_wave_spawn_plan(normalized_count, next_round, active_directions)
	return {
		"id": _wave_stack_vote_session_id(next_round, vote_index),
		"runId": "m0_local_debug_run",
		"sessionId": "session_local_001",
		"day": current_round,
		"sourceType": "button",
		"sourcePlayerId": "player_1",
		"sourcePingId": "",
		"currentWaveIds": _wave_ids_for_rounds(current_wave_rounds),
		"candidateWaveIds": [_wave_id(next_round)],
		"candidateSpawnPlanIds": [str(spawn_plan.get("spawnPlanId", _wave_spawn_plan_id(next_round)))],
		"candidateSpawnPlans": [spawn_plan],
		"stackCountBefore": get_active_wave_stack_depth(),
		"stackCountAfter": get_active_wave_stack_depth() + 1,
		"currentWaveStackLimit": get_wave_stack_limit(),
		"baseHpPercentAtStart": _base_hp_percent(),
		"requiredConsentMode": _wave_stack_required_consent_mode(normalized_count),
		"voteDurationSeconds": WAVE_STACK_VOTE_DURATION_SECONDS,
		"timeoutAction": "hold",
		"yesPlayerIds": ["player_1"],
		"holdPlayerIds": [],
		"claimedPlayerIds": [],
		"stackRiskLevel": _wave_stack_risk_level_for_vote(str(risk_report.get("severity", "blocked"))),
		"stackRiskReasonTextId": _wave_stack_risk_reason_text_id(risk_report),
		"previewCardIds": _wave_stack_preview_card_ids(next_round),
		"previewCards": [preview_card],
		"linkedWarningIds": [],
		"blockedReasonTags": [],
		"resolvedAction": null,
		"resolvedReasonTags": [],
		"spawnCountdownSeconds": WAVE_STACK_SPAWN_COUNTDOWN_SECONDS,
		"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
		"noBonusRewards": true,
		"round": next_round,
		"approvals": 1,
		"required": get_wave_stack_required_votes(normalized_count),
		"rule": _wave_stack_vote_rule_label(normalized_count),
		"player_count": normalized_count,
		"risk_severity": str(risk_report.get("severity", "unknown")),
		"risk_score": int(risk_report.get("score", 0)),
	}


func _resolved_wave_stack_vote_session(action: String, reason_tags: Array, player_count: int, approvals: int) -> Dictionary:
	if wave_stack_vote.is_empty():
		return {}

	var resolved = wave_stack_vote.duplicate(true)
	resolved["approvals"] = approvals
	resolved["yesPlayerIds"] = _player_ids_for_count(approvals)
	resolved["resolvedAction"] = action
	resolved["resolvedReasonTags"] = reason_tags.duplicate()
	if action == "held":
		resolved["holdPlayerIds"] = _hold_player_ids_for_vote(player_count, approvals)
	else:
		resolved["holdPlayerIds"] = []
	return resolved


func _wave_stack_vote_resolved_event(vote_session: Dictionary) -> Dictionary:
	return {
		"event": "wave_stack_vote_resolved",
		"voteSessionId": vote_session.get("id", ""),
		"day": vote_session.get("day", current_round),
		"resolvedAction": vote_session.get("resolvedAction", "unknown"),
		"resolvedReasonTags": vote_session.get("resolvedReasonTags", []),
		"yesCount": vote_session.get("yesPlayerIds", []).size(),
		"holdCount": vote_session.get("holdPlayerIds", []).size(),
		"timeoutAction": vote_session.get("timeoutAction", "hold"),
		"noBonusRewards": vote_session.get("noBonusRewards", true),
	}


func _wave_stack_vote_started_event(vote_session: Dictionary) -> Dictionary:
	return {
		"event": "wave_stack_vote_started",
		"voteSessionId": vote_session.get("id", ""),
		"day": vote_session.get("day", current_round),
		"sourceType": vote_session.get("sourceType", "button"),
		"candidateWaveIds": vote_session.get("candidateWaveIds", []),
		"candidateSpawnPlanIds": vote_session.get("candidateSpawnPlanIds", []),
		"stackRiskLevel": vote_session.get("stackRiskLevel", "locked"),
		"requiredConsentMode": vote_session.get("requiredConsentMode", "majority"),
		"timeoutAction": vote_session.get("timeoutAction", "hold"),
		"forbiddenRewardFields": vote_session.get("forbiddenRewardFields", []),
		"noBonusRewards": vote_session.get("noBonusRewards", true),
	}


func get_wave_stack_vote_summary(player_count: int) -> String:
	if not is_loaded():
		return "Vote: data not loaded"

	if player_count <= 1:
		return "Vote: solo instant"

	if not wave_active:
		return "Vote: idle"

	if wave_stack_vote.is_empty():
		return "Vote: none required=%s %s" % [
			get_wave_stack_required_votes(player_count),
			_wave_stack_vote_rule_label(player_count),
		]

	return "Vote: round %s %s/%s %s risk=%s" % [
		wave_stack_vote.get("round", _next_stack_round()),
		wave_stack_vote.get("approvals", 0),
		wave_stack_vote.get("required", get_wave_stack_required_votes(player_count)),
		wave_stack_vote.get("rule", _wave_stack_vote_rule_label(player_count)),
		wave_stack_vote.get("risk_severity", "unknown"),
	]


func has_active_shop_purchase_vote() -> bool:
	return not shop_purchase_vote.is_empty()


func get_active_shop_purchase_vote_session() -> Dictionary:
	return shop_purchase_vote.duplicate(true)


func get_shop_purchase_required_votes(player_count: int) -> int:
	var normalized_count = clamp(player_count, 1, 4)
	if normalized_count <= 1:
		return 1

	return int(floor(float(normalized_count) / 2.0)) + 1


func get_shop_purchase_option_key(
	option_report: Dictionary,
	reactivation_dormant_artifact_id: String = "",
	reactivation_replaced_artifact_id: String = ""
) -> String:
	return _shop_purchase_vote_option_key(option_report, reactivation_dormant_artifact_id, reactivation_replaced_artifact_id)


func get_shop_purchase_vote_summary(player_count: int) -> String:
	if not is_loaded():
		return "Shop vote: data not loaded"
	if player_count <= 1:
		return "Shop vote: solo instant"
	if not _has_open_shop_offer():
		return "Shop vote: idle"
	if shop_purchase_vote.is_empty():
		return "Shop vote: none required=%s majority" % get_shop_purchase_required_votes(player_count)

	return "Shop vote: %s %s/%s %s timeout=%s" % [
		shop_purchase_vote.get("label", "purchase"),
		shop_purchase_vote.get("approvals", 0),
		shop_purchase_vote.get("required", get_shop_purchase_required_votes(player_count)),
		shop_purchase_vote.get("requiredConsentMode", "majority"),
		shop_purchase_vote.get("timeoutAction", "decline"),
	]


func get_shop_purchase_action_label(option_report: Dictionary, player_count: int) -> String:
	if has_active_shop_purchase_vote() and player_count > 1:
		return "Approve buy" if str(option_report.get("shop_option_type", "remove_card")) == "service" else "Approve remove"

	return "Buy" if str(option_report.get("shop_option_type", "remove_card")) == "service" else "Remove"


func request_shop_purchase_vote(
	option_report: Dictionary,
	player_count: int,
	reactivation_dormant_artifact_id: String = "",
	reactivation_replaced_artifact_id: String = ""
) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")
	if option_report.is_empty():
		return _reject("shop_option_missing")
	if not _has_open_shop_offer():
		return _reject("no_shop_offer")

	var normalized_count = clamp(player_count, 1, 4)
	if not _shop_purchase_vote_uses_party_resource(option_report):
		return {
			"ok": true,
			"reason": "vote_not_required",
			"requires_vote": false,
			"ready_to_purchase": true,
			"events": [],
		}

	if not _shop_purchase_vote_option_ready(option_report):
		var blocked_reason = str(option_report.get("reason", "blocked"))
		return {
			"ok": false,
			"reason": blocked_reason,
			"requires_vote": true,
			"ready_to_purchase": false,
			"events": ["Shop vote blocked: %s." % blocked_reason],
		}

	if normalized_count <= 1:
		return {
			"ok": true,
			"reason": "vote_not_required",
			"requires_vote": false,
			"ready_to_purchase": true,
			"events": [],
		}

	var requested_key = _shop_purchase_vote_option_key(
		option_report,
		reactivation_dormant_artifact_id,
		reactivation_replaced_artifact_id
	)
	if requested_key.is_empty():
		return _reject("shop_option_missing")

	if has_active_shop_purchase_vote():
		if int(shop_purchase_vote.get("player_count", normalized_count)) != normalized_count:
			shop_purchase_vote.clear()
			return _reject("shop_vote_player_count_changed")

		if str(shop_purchase_vote.get("optionKey", "")) != requested_key:
			return {
				"ok": false,
				"reason": "shop_vote_already_active",
				"requires_vote": true,
				"ready_to_purchase": false,
				"voteSession": shop_purchase_vote.duplicate(true),
				"events": [
					"Shop purchase vote already active. %s" % get_shop_purchase_vote_summary(normalized_count),
				],
			}

		var required_votes = get_shop_purchase_required_votes(normalized_count)
		var approvals = min(normalized_count, int(shop_purchase_vote.get("approvals", 0)) + 1)
		shop_purchase_vote["approvals"] = approvals
		shop_purchase_vote["required"] = required_votes
		shop_purchase_vote["yesPlayerIds"] = _player_ids_for_count(approvals)
		run_stats["shop_votes_approved"] = int(run_stats.get("shop_votes_approved", 0)) + 1

		if approvals < required_votes:
			return {
				"ok": true,
				"reason": "vote_waiting",
				"requires_vote": true,
				"ready_to_purchase": false,
				"approvals": approvals,
				"required": required_votes,
				"voteSession": shop_purchase_vote.duplicate(true),
				"events": [
					"Shop purchase vote waiting: %s/%s for %s." % [
						approvals,
						required_votes,
						shop_purchase_vote.get("label", "purchase"),
					],
				],
			}

		run_stats["shop_votes_passed"] = int(run_stats.get("shop_votes_passed", 0)) + 1
		var resolved_vote_session = _resolved_shop_purchase_vote_session("purchased", ["required_votes_met"], normalized_count, approvals)
		shop_purchase_vote.clear()
		return {
			"ok": true,
			"reason": "vote_passed",
			"requires_vote": true,
			"ready_to_purchase": true,
			"approvals": approvals,
			"required": required_votes,
			"voteSession": resolved_vote_session,
			"shop_purchase_vote_resolved": _shop_purchase_vote_resolved_event(resolved_vote_session),
			"events": [
				"Shop purchase vote passed: %s/%s for %s." % [
					approvals,
					required_votes,
					resolved_vote_session.get("label", "purchase"),
				],
			],
		}

	shop_purchase_vote = _build_shop_purchase_vote_session(
		option_report,
		normalized_count,
		reactivation_dormant_artifact_id,
		reactivation_replaced_artifact_id
	)
	run_stats["shop_votes_started"] = int(run_stats.get("shop_votes_started", 0)) + 1
	run_stats["shop_votes_approved"] = int(run_stats.get("shop_votes_approved", 0)) + 1

	return {
		"ok": true,
		"reason": "vote_started",
		"requires_vote": true,
		"ready_to_purchase": false,
		"approvals": 1,
		"required": shop_purchase_vote.get("required", get_shop_purchase_required_votes(normalized_count)),
		"voteSession": shop_purchase_vote.duplicate(true),
		"shop_purchase_vote_started": _shop_purchase_vote_started_event(shop_purchase_vote),
		"events": [
			"Shop purchase vote started: 1/%s for %s. Timeout declines with no purchase." % [
				shop_purchase_vote.get("required", get_shop_purchase_required_votes(normalized_count)),
				shop_purchase_vote.get("label", "purchase"),
			],
		],
	}


func hold_shop_purchase_vote() -> Dictionary:
	if not has_active_shop_purchase_vote():
		return _reject("no_shop_vote")

	var approvals = int(shop_purchase_vote.get("approvals", 0))
	var required_votes = int(shop_purchase_vote.get("required", 0))
	var vote_player_count = int(shop_purchase_vote.get("player_count", max(1, required_votes)))
	var resolved_vote_session = _resolved_shop_purchase_vote_session("held", ["hold_requested"], vote_player_count, approvals)
	shop_purchase_vote.clear()
	run_stats["shop_votes_held"] = int(run_stats.get("shop_votes_held", 0)) + 1

	return {
		"ok": true,
		"reason": "vote_held",
		"requires_vote": true,
		"ready_to_purchase": false,
		"voteSession": resolved_vote_session,
		"shop_purchase_vote_resolved": _shop_purchase_vote_resolved_event(resolved_vote_session),
		"events": [
			"Shop purchase held: %s/%s approvals. No gold, boss shard, artifact action, or purchase limit was spent." % [
				approvals,
				required_votes,
			],
		],
	}


func _shop_purchase_vote_session_id(day_number: int, vote_index: int) -> String:
	return "shop_vote_day_%s_%s" % [
		_round_id_suffix(day_number),
		_round_id_suffix(vote_index),
	]


func _shop_purchase_vote_consent_mode(player_count: int) -> String:
	return "solo_confirm" if player_count <= 1 else "majority"


func _shop_purchase_vote_uses_party_resource(option_report: Dictionary) -> bool:
	if str(option_report.get("shop_option_type", "remove_card")) == "remove_card":
		return int(option_report.get("gold_cost", 0)) > 0

	return (
		int(option_report.get("gold_cost", 0)) > 0
		or int(option_report.get("boss_shard_cost", 0)) > 0
		or bool(option_report.get("uses_artifact_action", false))
	)


func _shop_purchase_vote_option_ready(option_report: Dictionary) -> bool:
	if str(option_report.get("shop_option_type", "remove_card")) == "service":
		return bool(option_report.get("can_buy", false))

	return bool(option_report.get("can_remove", option_report.get("can_buy", false)))


func _shop_purchase_vote_option_key(
	option_report: Dictionary,
	reactivation_dormant_artifact_id: String = "",
	reactivation_replaced_artifact_id: String = ""
) -> String:
	var option_type = str(option_report.get("shop_option_type", "remove_card"))
	if option_type == "service":
		var service_id = str(option_report.get("service_id", ""))
		if service_id.is_empty():
			return ""

		if str(option_report.get("service_type", "")) == "reactivate_dormant_artifact":
			var dormant_id = reactivation_dormant_artifact_id
			var replaced_id = reactivation_replaced_artifact_id
			if dormant_id.is_empty():
				dormant_id = str(option_report.get("dormant_artifact_id", ""))
			if replaced_id.is_empty():
				replaced_id = str(option_report.get("replaced_artifact_id", ""))
			return "service:%s:%s:%s" % [service_id, dormant_id, replaced_id]

		return "service:%s" % service_id

	var card_id = str(option_report.get("card_id", ""))
	if card_id.is_empty():
		return ""

	return "card:%s" % card_id


func _build_shop_purchase_vote_session(
	option_report: Dictionary,
	player_count: int,
	reactivation_dormant_artifact_id: String = "",
	reactivation_replaced_artifact_id: String = ""
) -> Dictionary:
	var normalized_count = clamp(player_count, 1, 4)
	var vote_index = int(run_stats.get("shop_votes_started", 0)) + 1
	var option_type = str(option_report.get("shop_option_type", "remove_card"))
	var choice_type = "service" if option_type == "service" else "card"
	var label = str(option_report.get("label", option_report.get("service_id", option_report.get("card_id", "purchase"))))
	var dormant_id = reactivation_dormant_artifact_id
	var replaced_id = reactivation_replaced_artifact_id
	if dormant_id.is_empty():
		dormant_id = str(option_report.get("dormant_artifact_id", ""))
	if replaced_id.is_empty():
		replaced_id = str(option_report.get("replaced_artifact_id", ""))

	return {
		"id": _shop_purchase_vote_session_id(current_round, vote_index),
		"runId": "m0_local_debug_run",
		"sessionId": "session_local_001",
		"day": current_round,
		"sourceType": "shop_button",
		"sourcePlayerId": "player_1",
		"shopOptionIndex": int(option_report.get("shop_option_index", -1)),
		"optionType": option_type,
		"choiceType": choice_type,
		"optionKey": _shop_purchase_vote_option_key(option_report, dormant_id, replaced_id),
		"cardId": str(option_report.get("card_id", "")),
		"serviceId": str(option_report.get("service_id", "")),
		"serviceType": str(option_report.get("service_type", "")),
		"label": label,
		"effect": str(option_report.get("effect", option_report.get("summary", ""))),
		"goldCost": max(0, int(option_report.get("gold_cost", 0))),
		"bossShardCost": max(0, int(option_report.get("boss_shard_cost", 0))),
		"usesArtifactAction": bool(option_report.get("uses_artifact_action", false)),
		"artifactActionCost": 1 if bool(option_report.get("uses_artifact_action", false)) else 0,
		"reactivationDormantArtifactId": dormant_id,
		"reactivationReplacedArtifactId": replaced_id,
		"purchaseLimitBefore": shop_purchases_remaining,
		"goldBefore": gold,
		"bossShardsBefore": boss_shards,
		"artifactActionsBefore": artifact_actions_remaining,
		"requiredConsentMode": _shop_purchase_vote_consent_mode(normalized_count),
		"voteDurationSeconds": SHOP_PURCHASE_VOTE_DURATION_SECONDS,
		"timeoutAction": "decline",
		"timeoutDefaultResult": "no_purchase",
		"yesPlayerIds": ["player_1"],
		"holdPlayerIds": [],
		"resolvedAction": null,
		"resolvedReasonTags": [],
		"approvals": 1,
		"required": get_shop_purchase_required_votes(normalized_count),
		"player_count": normalized_count,
		"summary": "Shop vote: %s 1/%s majority" % [
			label,
			get_shop_purchase_required_votes(normalized_count),
		],
	}


func _resolved_shop_purchase_vote_session(action: String, reason_tags: Array, player_count: int, approvals: int) -> Dictionary:
	if shop_purchase_vote.is_empty():
		return {}

	var resolved = shop_purchase_vote.duplicate(true)
	resolved["approvals"] = approvals
	resolved["yesPlayerIds"] = _player_ids_for_count(approvals)
	resolved["resolvedAction"] = action
	resolved["resolvedReasonTags"] = reason_tags.duplicate()
	if action == "held":
		resolved["holdPlayerIds"] = _hold_player_ids_for_vote(player_count, approvals)
	else:
		resolved["holdPlayerIds"] = []
	return resolved


func _shop_purchase_vote_started_event(vote_session: Dictionary) -> Dictionary:
	return {
		"event": "shop_purchase_vote_started",
		"voteSessionId": vote_session.get("id", ""),
		"day": vote_session.get("day", current_round),
		"shopOptionIndex": vote_session.get("shopOptionIndex", -1),
		"optionKey": vote_session.get("optionKey", ""),
		"label": vote_session.get("label", "purchase"),
		"goldCost": vote_session.get("goldCost", 0),
		"bossShardCost": vote_session.get("bossShardCost", 0),
		"artifactActionCost": vote_session.get("artifactActionCost", 0),
		"requiredConsentMode": vote_session.get("requiredConsentMode", "majority"),
		"timeoutAction": vote_session.get("timeoutAction", "decline"),
		"timeoutDefaultResult": vote_session.get("timeoutDefaultResult", "no_purchase"),
	}


func _shop_purchase_vote_resolved_event(vote_session: Dictionary) -> Dictionary:
	return {
		"event": "shop_purchase_vote_resolved",
		"voteSessionId": vote_session.get("id", ""),
		"day": vote_session.get("day", current_round),
		"shopOptionIndex": vote_session.get("shopOptionIndex", -1),
		"optionKey": vote_session.get("optionKey", ""),
		"resolvedAction": vote_session.get("resolvedAction", "unknown"),
		"resolvedReasonTags": vote_session.get("resolvedReasonTags", []),
		"yesCount": vote_session.get("yesPlayerIds", []).size(),
		"holdCount": vote_session.get("holdPlayerIds", []).size(),
		"timeoutAction": vote_session.get("timeoutAction", "decline"),
		"timeoutDefaultResult": vote_session.get("timeoutDefaultResult", "no_purchase"),
	}


func can_stack_next_wave(player_count: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not wave_active:
		return _reject("wave_not_active")

	if has_pending_reward():
		return _reject("reward_pending")

	if get_active_wave_stack_depth() >= get_wave_stack_limit():
		return _reject("stack_limit_reached")

	var next_round = _next_stack_round()
	if next_round > get_max_rounds():
		return _reject("no_next_round")

	if get_active_directions(player_count).is_empty():
		return _reject("no_active_direction")

	return {
		"ok": true,
		"reason": "ok",
		"round": next_round,
		"stack_depth": get_active_wave_stack_depth() + 1,
	}


func propose_wave_stack(player_count: int) -> Dictionary:
	if player_count <= 1:
		return _execute_wave_stack(player_count)

	var result = can_stack_next_wave(player_count)
	if not bool(result.get("ok", false)):
		run_stats["stack_rejections"] = int(run_stats.get("stack_rejections", 0)) + 1
		return result

	if has_active_wave_stack_vote():
		return {
			"ok": true,
			"reason": "vote_already_active",
			"round": wave_stack_vote.get("round", _next_stack_round()),
			"approvals": wave_stack_vote.get("approvals", 0),
			"required": wave_stack_vote.get("required", get_wave_stack_required_votes(player_count)),
			"voteSession": wave_stack_vote.duplicate(true),
			"events": ["Wave pull vote already active. %s" % get_wave_stack_vote_summary(player_count)],
		}

	var next_round = int(result.get("round", _next_stack_round()))
	var required_votes = get_wave_stack_required_votes(player_count)
	var risk_report = get_wave_stack_risk_report(player_count)
	wave_stack_vote = _build_wave_stack_vote_session(player_count, next_round, risk_report)
	run_stats["wave_stack_votes_started"] = int(run_stats.get("wave_stack_votes_started", 0)) + 1
	run_stats["wave_stack_votes_approved"] = int(run_stats.get("wave_stack_votes_approved", 0)) + 1

	var events: Array[String] = [
		"Wave pull vote started for round %s: 1/%s %s." % [
			next_round,
			required_votes,
			wave_stack_vote.get("rule", "majority"),
		],
		"Risk: %s" % get_wave_stack_risk_summary(player_count),
		"No bonus rewards added; this only compresses waiting time.",
	]
	if str(wave_stack_vote.get("rule", "")) == "unanimous":
		events.append("Base is critical; all players must approve.")

	return {
		"ok": true,
		"reason": "vote_started",
		"round": next_round,
		"approvals": 1,
		"required": required_votes,
		"voteSession": wave_stack_vote.duplicate(true),
		"wave_stack_vote_started": _wave_stack_vote_started_event(wave_stack_vote),
		"noBonusRewards": true,
		"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
		"events": events,
	}


func approve_wave_stack_vote(player_count: int) -> Dictionary:
	if player_count <= 1:
		return _execute_wave_stack(player_count)

	if not has_active_wave_stack_vote():
		return propose_wave_stack(player_count)

	var result = can_stack_next_wave(player_count)
	if not bool(result.get("ok", false)):
		wave_stack_vote.clear()
		run_stats["stack_rejections"] = int(run_stats.get("stack_rejections", 0)) + 1
		return result

	var expected_round = int(result.get("round", _next_stack_round()))
	var vote_round = int(wave_stack_vote.get("round", expected_round))
	if vote_round != expected_round:
		wave_stack_vote.clear()
		return _reject("stack_vote_stale")

	var vote_player_count = int(wave_stack_vote.get("player_count", player_count))
	if vote_player_count != clamp(player_count, 1, 4):
		wave_stack_vote.clear()
		return _reject("stack_vote_player_count_changed")

	var required_votes = get_wave_stack_required_votes(player_count)
	var approvals = min(player_count, int(wave_stack_vote.get("approvals", 0)) + 1)
	wave_stack_vote["approvals"] = approvals
	wave_stack_vote["required"] = required_votes
	wave_stack_vote["rule"] = _wave_stack_vote_rule_label(player_count)
	wave_stack_vote["requiredConsentMode"] = _wave_stack_required_consent_mode(player_count)
	wave_stack_vote["yesPlayerIds"] = _player_ids_for_count(approvals)
	run_stats["wave_stack_votes_approved"] = int(run_stats.get("wave_stack_votes_approved", 0)) + 1

	if approvals < required_votes:
		return {
			"ok": true,
			"reason": "vote_waiting",
			"round": vote_round,
			"approvals": approvals,
			"required": required_votes,
			"voteSession": wave_stack_vote.duplicate(true),
			"noBonusRewards": true,
			"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
			"events": [
				"Wave pull vote waiting for round %s: %s/%s %s." % [
					vote_round,
					approvals,
					required_votes,
					wave_stack_vote.get("rule", "majority"),
				],
			],
		}

	run_stats["wave_stack_votes_passed"] = int(run_stats.get("wave_stack_votes_passed", 0)) + 1
	var pass_events: Array[String] = [
		"Wave pull vote passed for round %s: %s/%s." % [vote_round, approvals, required_votes],
	]
	var resolved_vote_session = _resolved_wave_stack_vote_session("called", ["required_votes_met"], player_count, approvals)
	var stack_result = _execute_wave_stack(player_count)
	var combined_events = pass_events
	for event in stack_result.get("events", []):
		combined_events.append(str(event))
	stack_result["events"] = combined_events
	stack_result["voteSession"] = resolved_vote_session
	stack_result["wave_stack_vote_resolved"] = _wave_stack_vote_resolved_event(resolved_vote_session)
	return stack_result


func hold_wave_stack_vote() -> Dictionary:
	if not has_active_wave_stack_vote():
		return _reject("no_stack_vote")

	var vote_round = int(wave_stack_vote.get("round", 0))
	var approvals = int(wave_stack_vote.get("approvals", 0))
	var required_votes = int(wave_stack_vote.get("required", 0))
	var vote_player_count = int(wave_stack_vote.get("player_count", max(1, required_votes)))
	var resolved_vote_session = _resolved_wave_stack_vote_session("held", ["hold_requested"], vote_player_count, approvals)
	wave_stack_vote.clear()
	run_stats["wave_stack_votes_held"] = int(run_stats.get("wave_stack_votes_held", 0)) + 1

	return {
		"ok": true,
		"reason": "vote_held",
		"voteSession": resolved_vote_session,
		"wave_stack_vote_resolved": _wave_stack_vote_resolved_event(resolved_vote_session),
		"noBonusRewards": true,
		"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
		"events": [
			"Wave pull held for round %s: %s/%s approvals." % [
				vote_round,
				approvals,
				required_votes,
			],
		],
	}


func stack_next_wave(player_count: int) -> Dictionary:
	if player_count <= 1:
		return _execute_wave_stack(player_count)

	if has_active_wave_stack_vote():
		return approve_wave_stack_vote(player_count)

	return propose_wave_stack(player_count)


func _execute_wave_stack(player_count: int) -> Dictionary:
	var result = can_stack_next_wave(player_count)
	if not bool(result.get("ok", false)):
		run_stats["stack_rejections"] = int(run_stats.get("stack_rejections", 0)) + 1
		return result

	var pre_stack_risk_report = get_wave_stack_risk_report(player_count)
	var next_round = int(result.get("round", _next_stack_round()))
	wave_stack_vote.clear()
	_add_active_wave_packet(next_round, true, player_count)
	run_stats["rounds_started"] = int(run_stats.get("rounds_started", 0)) + 1
	run_stats["wave_stacks"] = int(run_stats.get("wave_stacks", 0)) + 1
	run_stats["stacked_rounds"] = int(run_stats.get("stacked_rounds", 0)) + 1
	_update_max_wave_stack_depth()
	_add_stacked_discard_charge()
	var active_directions = _array_string_values(get_active_directions(player_count))
	var stack_report = _build_wave_stack_executed_report(player_count, next_round, active_directions)
	var impact_report = get_wave_stack_impact_report(player_count, 4)
	_begin_or_update_wave_stack_tempo_tracker(player_count, stack_report, pre_stack_risk_report)
	var tempo_moment_report = get_wave_stack_tempo_moment_report()
	var events: Array[String] = [
		"Next wave pulled forward. %s" % describe_wave(player_count, next_round),
		"No bonus rewards added; this only compresses waiting time.",
		"Discard uses available: %s/%s." % [discard_charges, get_discard_charge_cap()],
	]
	if bool(impact_report.get("ok", false)):
		events.insert(1, str(impact_report.get("summary", "")))
	if bool(tempo_moment_report.get("ok", false)):
		events.insert(2, str(tempo_moment_report.get("summary", "")))

	return {
		"ok": true,
		"reason": "wave_stacked",
		"round": next_round,
		"stack_depth": get_active_wave_stack_depth(),
		"wave_stack": stack_report,
		"wave_stack_impact": impact_report,
		"wave_stack_tempo_moment": tempo_moment_report,
		"stackedRounds": stack_report.get("stackedRounds", []),
		"settlementPackets": stack_report.get("settlementPackets", []),
		"settlementBatch": stack_report.get("settlementBatch", {}),
		"noBonusRewards": true,
		"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
		"events": events,
	}


func debug_get_enemies() -> Array:
	return enemies.duplicate(true)


func debug_set_hand(card_ids: Array) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	for card_id in card_ids:
		if get_card_data(str(card_id)).is_empty():
			return _reject("unknown_card")

	hand.clear()
	for card_id in card_ids:
		hand.append(str(card_id))

	return {"ok": true, "reason": "debug_hand_set"}


func debug_set_draw_pile(card_ids: Array) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	for card_id in card_ids:
		if get_card_data(str(card_id)).is_empty():
			return _reject("unknown_card")

	draw_pile.clear()
	for card_id in card_ids:
		draw_pile.append(str(card_id))

	return {"ok": true, "reason": "debug_draw_pile_set"}


func debug_spawn_enemy(tile: Vector2i, hp: int = -1, direction: String = "debug", enemy_id: String = "") -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	var resolved_enemy_id = _default_enemy_id() if enemy_id.is_empty() else enemy_id
	if _enemy_data_by_id(resolved_enemy_id).is_empty():
		return _reject("unknown_enemy")

	var enemy_data = _enemy_data_by_id(resolved_enemy_id)
	var enemy_hp = hp if hp > 0 else int(enemy_data.get("hp", 6))
	var enemy = {
		"id": next_enemy_id,
		"enemy_id": resolved_enemy_id,
		"tile": tile,
		"hp": enemy_hp,
		"direction": direction,
		"round": current_round,
		"stacked": false,
		"boss": bool(enemy_data.get("boss", false)),
		"phase_triggered": false,
		"siege_gaze_charge": 0,
		"boss_parts": _initial_boss_parts(enemy_data),
		"boss_stride_slow_charge": 0,
	}
	enemies.append(enemy)
	next_enemy_id += 1
	recent_event_tiles[_tile_key(tile)] = "debug_spawn"

	return {
		"ok": true,
		"reason": "debug_enemy_spawned",
		"id": enemy["id"],
		"enemy_id": resolved_enemy_id,
	}


func debug_set_round(round_number: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if wave_active:
		return _reject("wave_active")

	if round_number < 1 or round_number > get_max_rounds():
		return _reject("round_out_of_range")

	current_round = round_number
	return {"ok": true, "reason": "debug_round_set"}


func debug_set_base_hp(value: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var base_max = int(data.get("base", {}).get("hp", 100))
	base_hp = max(0, min(value, base_max))
	return {"ok": true, "reason": "debug_base_hp_set"}


func debug_set_gold(value: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	gold = max(0, value)
	return {"ok": true, "reason": "debug_gold_set"}


func debug_set_boss_shards(value: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	boss_shards = max(0, value)
	return {"ok": true, "reason": "debug_boss_shards_set"}


func debug_set_artifact_actions_remaining(value: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	artifact_actions_remaining = clamp(value, 0, get_artifact_action_limit())
	return {"ok": true, "reason": "debug_artifact_actions_set"}


func debug_set_mana(value: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	mana = max(0, value)
	return {"ok": true, "reason": "debug_mana_set"}


func debug_set_draw_gauge(value: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	draw_gauge = max(0, value)
	return {"ok": true, "reason": "debug_draw_gauge_set"}


func debug_generate_artifact_offer() -> Array[String]:
	var events: Array[String] = []
	if not is_loaded():
		events.append("Artifact debug rejected: data not loaded.")
		return events

	_generate_artifact_offer(events)
	return events


func debug_generate_reward_offer(round_number = -1) -> Array[String]:
	var offer: Array[String] = []
	if not is_loaded():
		return offer

	var target_round = current_round if round_number <= 0 else round_number
	var events: Array[String] = []
	_generate_reward_offer(events, target_round)
	for card_id in reward_offer:
		offer.append(str(card_id))

	return offer


func debug_generate_shop_offer(round_number = -1) -> Array[String]:
	var events: Array[String] = []
	if not is_loaded():
		events.append("Shop debug rejected: data not loaded.")
		return events

	var target_round = current_round if round_number <= 0 else round_number
	_generate_shop_offer(events, target_round)
	return events


func debug_place_structure(tile: Vector2i, structure_type: String, class_id: String = "") -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not class_id.is_empty() and get_class_data(class_id).is_empty():
		return _reject("unknown_class")

	if not ["tower", "barricade"].has(structure_type):
		return _reject("unknown_structure_type")

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	if get_base_cells().has(tile):
		return _reject("base_tile_blocked")

	if structures.has(_tile_key(tile)):
		return _reject("tile_occupied")

	_store_structure(tile, structure_type, class_id)
	recent_event_tiles[_tile_key(tile)] = "debug_structure"

	return {"ok": true, "reason": "debug_placed_%s" % structure_type}


func debug_card_target_condition(card_id: String, tile: Vector2i, player_count: int, class_id: String = "") -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var card = get_card_data(card_id)
	if card.is_empty():
		return _reject("unknown_card")

	var kind = str(card.get("kind", ""))
	if not TILE_TARGET_CARD_KINDS.has(kind):
		return _reject("card_does_not_use_tile")

	if kind == "place_structure":
		var structure_type = str(card.get("structureType", ""))
		return can_place_structure(tile, structure_type, player_count, class_id)

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	if kind == "damage_enemy":
		if _find_enemy_index_at_tile(tile) < 0:
			return _reject("no_enemy_at_tile")
		return {"ok": true, "reason": "ok"}

	if kind == "repair_structure":
		var key = _tile_key(tile)
		if not structures.has(key):
			return _reject("no_structure")

		var structure: Dictionary = structures[key]
		if int(structure.get("hp", 0)) >= int(structure.get("max_hp", 0)):
			return _reject("structure_not_damaged")

		return {"ok": true, "reason": "ok"}

	return _reject("unsupported_card_kind")


func debug_damage_structure(tile: Vector2i, damage: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	var key = _tile_key(tile)
	if not structures.has(key):
		return _reject("no_structure")

	var structure: Dictionary = structures[key]
	var old_hp = int(structure.get("hp", 0))
	var applied_damage = max(0, min(old_hp, damage))
	structure["hp"] = old_hp - applied_damage
	structures[key] = structure
	recent_event_tiles[key] = "debug_structure_damage"
	return {
		"ok": true,
		"reason": "debug_structure_damaged",
		"tile": tile,
		"damage": applied_damage,
		"hp": structure["hp"],
		"max_hp": structure.get("max_hp", 0),
	}


func debug_run_tower_attack() -> Array[String]:
	var events: Array[String] = []
	recent_event_tiles.clear()
	_towers_attack(events)
	return events


func debug_run_enemy_movement() -> Array[String]:
	var events: Array[String] = []
	recent_event_tiles.clear()
	_move_enemies(events)
	return events


func debug_refill_round_resources(player_count: int = 1) -> Array[String]:
	var events: Array[String] = []
	_refill_round_resources(events, player_count)
	return events


func get_recent_event_tiles() -> Dictionary:
	return recent_event_tiles


func get_tower_range_cells(extra_tower_tile = Vector2i(-1, -1)) -> Dictionary:
	var cells = {}
	var tower_data: Dictionary = data.get("structures", {}).get("m0_basic_tower", {})
	var tower_range = int(tower_data.get("range", 3))

	for structure in structures.values():
		if structure["type"] == "tower":
			_add_range_cells(cells, structure["tile"], tower_range)

	if _is_in_bounds(extra_tower_tile):
		_add_range_cells(cells, extra_tower_tile, tower_range)

	return cells


func get_run_stats() -> Dictionary:
	return run_stats


func get_last_round_report() -> Dictionary:
	if last_round_report.is_empty():
		return {
			"ok": false,
			"reason": "no_completed_round",
		}

	return last_round_report.duplicate(true)


func get_last_round_summary() -> String:
	if last_round_report.is_empty():
		return "Last round: none"

	var details: Array = last_round_report.get("details", [])
	var detail_text = " | ".join(_string_values(details)) if not details.is_empty() else "No notable events."
	return "Last %s: %s %s Next: %s | %s" % [
		last_round_report.get("round_label", "round"),
		last_round_report.get("headline", "-"),
		last_round_report.get("scoreline", ""),
		last_round_report.get("suggestion", "-"),
		detail_text,
	]


func get_last_round_panel_report(player_count: int) -> Dictionary:
	if last_round_report.is_empty():
		return {
			"ok": false,
			"reason": "no_completed_round",
		}

	var detail_lines = _string_values(last_round_report.get("details", []))
	var reward_line = _last_round_reward_line()
	var next_line = get_next_wave_preview_summary(player_count, 1)
	var score_line = "Score: %s" % str(last_round_report.get("scoreline", ""))
	var problem_line = "Problem: %s" % str(last_round_report.get("headline", "-"))
	var next_action_line = "Next action: %s" % str(last_round_report.get("suggestion", "-"))
	var rewards_line = "Rewards: %s" % reward_line.trim_prefix("Reward ")
	var preview_line = "Upcoming: %s" % next_line
	var lines: Array[String] = [
		score_line,
		problem_line,
		next_action_line,
		rewards_line,
		preview_line,
	]
	for detail_line in detail_lines:
		lines.append("Detail: %s" % str(detail_line))

	return {
		"ok": true,
		"reason": "ok",
		"title": "%s recap" % str(last_round_report.get("round_label", "Round")),
		"focus": str(last_round_report.get("focus", "stable")),
		"headline": str(last_round_report.get("headline", "-")),
		"scoreline": str(last_round_report.get("scoreline", "")),
		"suggestion": str(last_round_report.get("suggestion", "")),
		"score_line": score_line,
		"problem_line": problem_line,
		"next_action_line": next_action_line,
		"reward_line": reward_line,
		"rewards_line": rewards_line,
		"next_line": next_line,
		"preview_line": preview_line,
		"detail_lines": detail_lines,
		"lines": lines,
	}


func get_last_round_panel_summary(player_count: int) -> String:
	var report = get_last_round_panel_report(player_count)
	if not bool(report.get("ok", false)):
		return "Round recap: none"

	var lines: Array = report.get("lines", [])
	return "Round recap | %s: %s | %s" % [
		report.get("title", "Round recap"),
		report.get("headline", "-"),
		" | ".join(_string_values(lines)),
	]


func get_run_stats_summary() -> String:
	return "rounds=%s/%s steps=%s spawned=%s boss=%s/%s phase=%s pulse=%s siege=%s/%s parts=%s/%s/%s slow=%s killed=%s base_hits=%s boss_base=%s base_damage=%s tower_hits=%s structure_hits=%s placed=%s destroyed=%s planned=%s/%s break=%s/%s enemy_fx=%s/%s/%s stacks=%s depth=%s votes=%s/%s/%s cards=%s/%s discards=%s card_fx=%s/%s/%s reward_draws=%s seed_draws=%s rewards=%s/%s artifacts=%s/%s shop=%s/%s gold=%s/%s seed_bonus=%s mana_spent=%s kill_mana=%s discard_mana=%s class_fx=%s/%s/%s/%s taunt=%s repairs=%s" % [
		run_stats.get("rounds_completed", 0),
		run_stats.get("rounds_started", 0),
		run_stats.get("steps", 0),
		run_stats.get("spawned", 0),
		run_stats.get("bosses_spawned", 0),
		run_stats.get("bosses_killed", 0),
		run_stats.get("boss_phase_triggers", 0),
		run_stats.get("boss_pulse_damage", 0),
		run_stats.get("boss_siege_triggers", 0),
		run_stats.get("boss_siege_damage", 0),
		run_stats.get("boss_parts_destroyed", 0),
		run_stats.get("boss_part_damage", 0),
		run_stats.get("boss_part_draws", 0),
		run_stats.get("boss_part_slow_waits", 0),
		run_stats.get("killed", 0),
		run_stats.get("base_hits", 0),
		run_stats.get("boss_base_hits", 0),
		run_stats.get("base_damage", 0),
		run_stats.get("tower_hits", 0),
		run_stats.get("structure_hits", 0),
		run_stats.get("structures_placed", 0),
		run_stats.get("structures_destroyed", 0),
		run_stats.get("planned_collapses", 0),
		run_stats.get("planned_collapse_damage", 0),
		run_stats.get("break_targets_found", 0),
		run_stats.get("break_path_steps", 0),
		run_stats.get("enemy_fast_moves", 0),
		run_stats.get("enemy_priority_break_moves", 0),
		run_stats.get("enemy_damage_reduced", 0),
		run_stats.get("wave_stacks", 0),
		run_stats.get("max_wave_stack_depth", 0),
		run_stats.get("wave_stack_votes_started", 0),
		run_stats.get("wave_stack_votes_passed", 0),
		run_stats.get("wave_stack_votes_held", 0),
		run_stats.get("cards_played", 0),
		run_stats.get("cards_drawn", 0),
		run_stats.get("cards_discarded", 0),
		run_stats.get("card_damage_dealt", 0),
		run_stats.get("card_repairs", 0),
		run_stats.get("card_effect_draws", 0),
		run_stats.get("reward_cards_drawn", 0),
		run_stats.get("round_seed_cards_drawn", 0),
		run_stats.get("card_rewards_taken", 0),
		run_stats.get("card_rewards_offered", 0),
		run_stats.get("artifact_rewards_taken", 0),
		run_stats.get("artifact_rewards_offered", 0),
		run_stats.get("shop_cards_removed", 0),
		run_stats.get("shop_offers_opened", 0),
		run_stats.get("gold_gained", 0),
		run_stats.get("gold_spent", 0),
		run_stats.get("front_seed_mana_gained", 0),
		run_stats.get("mana_spent", 0),
		run_stats.get("kill_mana_gained", 0),
		run_stats.get("discard_mana_gained", 0),
		run_stats.get("class_thorns_damage", 0),
		run_stats.get("class_explosion_damage", 0),
		run_stats.get("class_splash_damage", 0),
		run_stats.get("class_aura_damage", 0),
		run_stats.get("class_taunt_hits", 0),
		run_stats.get("class_repairs", 0),
	]


func get_path_cells(player_count: int) -> Dictionary:
	var cells = {}
	for path in get_path_cells_by_direction(player_count).values():
		for tile in path:
			cells[_tile_key(tile)] = true
	return cells


func get_path_cells_by_direction(player_count: int) -> Dictionary:
	var paths = {}
	var blocked = _blocked_tiles()
	for direction in get_active_directions(player_count):
		paths[str(direction)] = _find_path(_entrance_tile(direction), blocked)
	return paths


func get_tile_report(tile: Vector2i, player_count: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	var key = _tile_key(tile)
	var entrance_direction = _entrance_direction_for_tile(tile)
	var front_pressure: Dictionary = {}
	if not entrance_direction.is_empty():
		front_pressure = get_front_pressure_by_direction(player_count).get(entrance_direction, {})
	var enemy_parts = PackedStringArray()
	var enemy_trait_tiles = get_enemy_trait_tiles()
	var enemy_trait_entry: Dictionary = enemy_trait_tiles.get(key, {})
	var enemy_intent_tiles = get_enemy_intent_tiles(player_count)

	for enemy in enemies:
		if enemy["tile"] == tile:
			var enemy_label = get_enemy_label(str(enemy.get("enemy_id", _default_enemy_id())))
			var trait_summary = get_enemy_trait_summary(str(enemy.get("enemy_id", _default_enemy_id())))
			if trait_summary == "Standard":
				enemy_parts.append("#%s %s hp %s" % [enemy["id"], enemy_label, enemy["hp"]])
			else:
				enemy_parts.append("#%s %s hp %s [%s]" % [enemy["id"], enemy_label, enemy["hp"], trait_summary])

	return {
		"ok": true,
		"reason": "ok",
		"tile": tile,
		"is_base": get_base_cells().has(tile),
		"entrance_direction": entrance_direction,
		"active_entrance": not entrance_direction.is_empty() and get_active_directions(player_count).has(entrance_direction),
		"front_pressure": front_pressure,
		"on_path": get_path_cells(player_count).has(key),
		"in_tower_range": get_tower_range_cells().has(key),
		"structure": structures.get(key, {}),
		"enemy_count": enemy_parts.size(),
		"enemy_summary": ", ".join(enemy_parts),
		"enemy_trait": enemy_trait_entry,
		"enemy_traits": str(enemy_trait_entry.get("summary", "")),
		"enemy_intent": enemy_intent_tiles.get(key, {}),
		"event": str(recent_event_tiles.get(key, "")),
	}


func get_wave_summary() -> String:
	var display_round = _active_wave_round_label() if wave_active else str(current_round)
	var spawn_total = _active_wave_total_spawn_count() if wave_active else _get_spawn_count(current_round)
	return "round=%s/%s completed=%s base_hp=%s structures=%s enemies=%s spawned=%s/%s active=%s stack=%s/%s queued_rewards=%s" % [
		display_round,
		get_max_rounds(),
		completed_rounds,
		base_hp,
		structures.size(),
		enemies.size(),
		spawned_count,
		spawn_total,
		wave_active,
		get_active_wave_stack_depth(),
		get_wave_stack_limit(),
		get_pending_reward_packet_count(),
	]


func describe_loaded_data() -> String:
	var map_size = get_map_size()
	var wave: Dictionary = data.get("wave", {})
	return "map=%sx%s base_hp=%s rounds=%s classes=%s wave=%s enemies=%s stack_limit=%s" % [
		map_size.x,
		map_size.y,
		base_hp,
		get_max_rounds(),
		get_class_ids().size(),
		wave.get("id", "?"),
		wave.get("spawnCount", "?"),
		get_wave_stack_limit(),
	]


func describe_wave(player_count: int, round_number = -1) -> String:
	var wave: Dictionary = data.get("wave", {})
	var target_round = current_round if round_number <= 0 else round_number
	var active_directions = _array_string_values(get_active_directions(player_count))
	var projected_directions = _wave_spawn_directions_for_round_number(player_count, active_directions, target_round)
	var boss_text = ""
	if _is_boss_round(target_round):
		boss_text = " + boss %s" % _boss_enemy_id()
	return "round %s/%s %s: %s enemies [%s]%s from %s" % [
		target_round,
		get_max_rounds(),
		wave.get("id", "?"),
		_get_normal_spawn_count(target_round),
		get_enemy_mix_summary(target_round),
		boss_text,
		_join_values(projected_directions),
	]


func can_place_structure(tile: Vector2i, structure_type: String, player_count: int, class_id: String = "") -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not class_id.is_empty() and get_class_data(class_id).is_empty():
		return _reject("unknown_class")

	if not ["tower", "barricade"].has(structure_type):
		return _reject("unknown_structure_type")

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	if get_base_cells().has(tile):
		return _reject("base_tile_blocked")

	if _is_entrance_tile(tile):
		return _reject("entrance_tile_blocked")

	if structures.has(_tile_key(tile)):
		return _reject("tile_occupied")

	var blocked = _blocked_tiles()
	blocked[_tile_key(tile)] = true

	for direction in get_active_directions(player_count):
		var path = _find_path(_entrance_tile(direction), blocked)
		if path.is_empty():
			return _reject("would_fully_block_%s" % direction)

	return {"ok": true, "reason": "ok"}


func place_structure(tile: Vector2i, structure_type: String, player_count: int, class_id: String = "") -> Dictionary:
	var result = can_place_structure(tile, structure_type, player_count, class_id)
	if not bool(result["ok"]):
		return result

	_store_structure(tile, structure_type, class_id)

	return {"ok": true, "reason": "placed_%s" % structure_type}


func get_front_recommendation_tiles(player_count: int, structure_type: String, class_id: String = "") -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not ["tower", "barricade"].has(structure_type):
		return _reject("unknown_structure_type")

	if not class_id.is_empty() and get_class_data(class_id).is_empty():
		return _reject("unknown_class")

	var defense_report = get_front_defense_report(player_count)
	if not bool(defense_report.get("ok", false)):
		return defense_report

	var paths_by_direction: Dictionary = get_path_cells_by_direction(player_count)
	var priority_directions: Array = defense_report.get("priority_directions", [])
	var by_direction: Dictionary = defense_report.get("by_direction", {})
	var tiles = {}
	var candidate_count = 0
	var selected_direction = ""
	var selected_front: Dictionary = {}

	for direction_value in priority_directions:
		var direction = str(direction_value)
		var path: Array = paths_by_direction.get(direction, [])
		var front_entry: Dictionary = by_direction.get(direction, {})
		var candidates = _front_recommendation_candidates_for_direction(
			direction,
			path,
			front_entry,
			structure_type,
			player_count,
			class_id
		)
		if candidates.is_empty():
			continue

		selected_direction = direction
		selected_front = front_entry.duplicate(true)
		for candidate_value in candidates:
			if typeof(candidate_value) != TYPE_DICTIONARY:
				continue

			var candidate: Dictionary = candidate_value
			var tile_value = candidate.get("tile", Vector2i(-1, -1))
			if typeof(tile_value) != TYPE_VECTOR2I:
				continue

			var tile: Vector2i = tile_value
			tiles[_tile_key(tile)] = candidate
			candidate_count += 1
			if candidate_count >= FRONT_RECOMMENDATION_LIMIT:
				break

		if candidate_count > 0:
			break

	return {
		"ok": true,
		"reason": "ok",
		"structure_type": structure_type,
		"primary_direction": selected_direction,
		"primary_front": selected_front,
		"candidate_count": candidate_count,
		"tiles": tiles,
		"summary": _front_recommendation_summary(structure_type, selected_direction, candidate_count, selected_front),
	}


func get_front_recommendation_summary(player_count: int, structure_type: String, class_id: String = "") -> String:
	var report = get_front_recommendation_tiles(player_count, structure_type, class_id)
	if not bool(report.get("ok", false)):
		return "Recommendation: %s" % report.get("reason", "unavailable")

	return str(report.get("summary", "Recommendation: -"))


func draw_card() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if hand.size() >= get_max_hand_size():
		return _reject("hand_full")

	if draw_pile.is_empty():
		if discard_pile.is_empty():
			return _reject("no_cards_to_draw")

		draw_pile = discard_pile.duplicate()
		discard_pile.clear()

	var card_id = draw_pile.pop_front()
	hand.append(str(card_id))
	run_stats["cards_drawn"] = int(run_stats.get("cards_drawn", 0)) + 1

	return {"ok": true, "reason": "drawn_%s" % card_id, "card_id": card_id}


func can_play_card(card_id: String, class_id: String = "") -> Dictionary:
	var base_result = _can_use_card(card_id)
	if not bool(base_result["ok"]):
		return base_result

	var kind = str(base_result["kind"])
	if TILE_TARGET_CARD_KINDS.has(kind):
		return _reject("card_requires_tile")

	if kind != "draw_cards":
		return _reject("unsupported_card_kind")

	var card: Dictionary = base_result["card"]
	if int(card.get("draw", 0)) <= 0:
		return _reject("invalid_draw_count")

	return {"ok": true, "reason": "ok"}


func play_card(card_id: String, class_id: String = "") -> Dictionary:
	var result = can_play_card(card_id, class_id)
	if not bool(result["ok"]):
		return result

	var card = get_card_data(card_id)
	var cost = int(card.get("cost", 0))
	var events: Array[String] = []
	_commit_card_play(card_id, cost)

	var draw_count = int(card.get("draw", 0))
	for _index in range(draw_count):
		var draw_result = draw_card()
		if bool(draw_result["ok"]):
			var drawn_card_id = str(draw_result["card_id"])
			var drawn_card = get_card_data(drawn_card_id)
			run_stats["card_effect_draws"] = int(run_stats.get("card_effect_draws", 0)) + 1
			events.append("%s drew %s." % [card.get("label", card_id), drawn_card.get("label", drawn_card_id)])
		else:
			events.append("%s draw held: %s." % [card.get("label", card_id), draw_result["reason"]])
			break

	return _played_card_result(card_id, card, cost, "", events)


func can_play_card_at_tile(card_id: String, tile: Vector2i, player_count: int, class_id: String = "") -> Dictionary:
	var base_result = _can_use_card(card_id)
	if not bool(base_result["ok"]):
		return base_result

	var kind = str(base_result["kind"])
	if not TILE_TARGET_CARD_KINDS.has(kind):
		return _reject("card_does_not_use_tile")

	if kind == "place_structure":
		var card: Dictionary = base_result["card"]
		var structure_type = str(card.get("structureType", ""))
		return can_place_structure(tile, structure_type, player_count, class_id)

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	if kind == "damage_enemy":
		var target_enemy_index = _find_enemy_index_at_tile(tile)
		if target_enemy_index < 0:
			return _reject("no_enemy_at_tile")

		var damage_target_report = {
			"ok": true,
			"reason": "ok",
		}
		var boss_part_report = _boss_focus_part_report_for_enemy(enemies[target_enemy_index])
		if bool(boss_part_report.get("ok", false)):
			damage_target_report["boss_part_id"] = boss_part_report.get("part_id", "")
			damage_target_report["boss_part_label"] = boss_part_report.get("label", "")
			damage_target_report["boss_part_hp"] = boss_part_report.get("hp", 0)
			damage_target_report["boss_part_max_hp"] = boss_part_report.get("max_hp", 0)
			damage_target_report["boss_part_effect_summary"] = boss_part_report.get("effect_summary", "")
			damage_target_report["boss_part_summary"] = boss_part_report.get("summary", "")
		return damage_target_report

	if kind == "repair_structure":
		var key = _tile_key(tile)
		if not structures.has(key):
			return _reject("no_structure")

		var structure: Dictionary = structures[key]
		if int(structure.get("hp", 0)) >= int(structure.get("max_hp", 0)):
			return _reject("structure_not_damaged")

		return {"ok": true, "reason": "ok"}

	return _reject("unsupported_card_kind")


func get_card_target_tiles(card_id: String, player_count: int, class_id: String = "") -> Dictionary:
	var base_result = _can_use_card(card_id)
	if not bool(base_result["ok"]):
		return {
			"ok": false,
			"reason": str(base_result.get("reason", "card_unavailable")),
			"card_id": card_id,
			"tiles": {},
			"valid_count": 0,
			"invalid_count": 0,
			"reason_counts": {},
			"summary": "Targets blocked: %s." % base_result.get("reason", "card_unavailable"),
		}

	var kind = str(base_result["kind"])
	var card: Dictionary = base_result["card"]
	if not TILE_TARGET_CARD_KINDS.has(kind):
		return {
			"ok": true,
			"reason": "card_does_not_use_tile",
			"card_id": card_id,
			"kind": kind,
			"tiles": {},
			"valid_count": 0,
			"invalid_count": 0,
			"reason_counts": {},
			"summary": "%s does not need a tile." % card.get("label", card_id),
		}

	var tiles = {}
	var reason_counts = {}
	var valid_count = 0
	var invalid_count = 0
	var map_size = get_map_size()

	for y in range(map_size.y):
		for x in range(map_size.x):
			var tile = Vector2i(x, y)
			var target_result = can_play_card_at_tile(card_id, tile, player_count, class_id)
			var target_ok = bool(target_result.get("ok", false))
			var reason = str(target_result.get("reason", "ok"))
			if target_ok:
				valid_count += 1
			else:
				invalid_count += 1
				reason_counts[reason] = int(reason_counts.get(reason, 0)) + 1

			var tile_report = {
				"valid": target_ok,
				"reason": reason,
				"kind": kind,
				"show_invalid": not target_ok and _should_show_invalid_card_target(kind, reason),
			}
			for boss_part_key in [
				"boss_part_id",
				"boss_part_label",
				"boss_part_hp",
				"boss_part_max_hp",
				"boss_part_effect_summary",
				"boss_part_summary",
			]:
				if target_result.has(boss_part_key):
					tile_report[boss_part_key] = target_result[boss_part_key]

			tiles[_tile_key(tile)] = tile_report

	return {
		"ok": true,
		"reason": "ok",
		"card_id": card_id,
		"kind": kind,
		"tiles": tiles,
		"valid_count": valid_count,
		"invalid_count": invalid_count,
		"reason_counts": reason_counts,
		"summary": _format_card_target_summary(card_id, card, valid_count, invalid_count, reason_counts),
	}


func get_card_target_summary(card_id: String, player_count: int, class_id: String = "") -> String:
	var report = get_card_target_tiles(card_id, player_count, class_id)
	return str(report.get("summary", "Targets unavailable."))


func play_card_at_tile(card_id: String, tile: Vector2i, player_count: int, class_id: String = "") -> Dictionary:
	var result = can_play_card_at_tile(card_id, tile, player_count, class_id)
	if not bool(result["ok"]):
		return result

	var card = get_card_data(card_id)
	var cost = int(card.get("cost", 0))
	var kind = str(card.get("kind", ""))
	var events: Array[String] = []
	var structure_type = str(card.get("structureType", ""))

	if kind == "place_structure":
		var placement = place_structure(tile, structure_type, player_count, class_id)
		if not bool(placement["ok"]):
			return placement
		events.append("%s placed %s at %s." % [card.get("label", card_id), structure_type, _tile_text(tile)])
	elif kind == "damage_enemy":
		_commit_card_play(card_id, cost)
		var target_enemy_index = _find_enemy_index_at_tile(tile)
		var damage = int(card.get("damage", 0)) + _class_card_damage_bonus(class_id, target_enemy_index)
		_damage_enemy_at_index(
			target_enemy_index,
			damage,
			events,
			"Card %s at %s" % [card.get("label", card_id), _tile_text(tile)],
			"card_damage_dealt",
			"card_damage"
		)
		return _played_card_result(card_id, card, cost, "", events)
	elif kind == "repair_structure":
		_commit_card_play(card_id, cost)
		var key = _tile_key(tile)
		var structure: Dictionary = structures[key]
		var repair_amount = int(card.get("repair", 0))
		var missing_hp = int(structure.get("max_hp", 0)) - int(structure.get("hp", 0))
		var repaired = min(repair_amount, missing_hp)
		structure["hp"] = int(structure["hp"]) + repaired
		structures[key] = structure
		run_stats["card_repairs"] = int(run_stats.get("card_repairs", 0)) + repaired
		recent_event_tiles[key] = "card_repair"
		events.append("%s repaired %s at %s for %s. HP: %s/%s." % [
			card.get("label", card_id),
			structure["type"],
			_tile_text(tile),
			repaired,
			structure["hp"],
			structure["max_hp"],
		])
		return _played_card_result(card_id, card, cost, "", events)

	_commit_card_play(card_id, cost)
	return _played_card_result(card_id, card, cost, structure_type, events)


func _can_use_card(card_id: String) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not hand.has(card_id):
		return _reject("card_not_in_hand")

	var card = get_card_data(card_id)
	if card.is_empty():
		return _reject("unknown_card")

	var cost = int(card.get("cost", 0))
	if cost > mana:
		return _reject("not_enough_mana")

	var kind = str(card.get("kind", ""))
	if not CARD_KINDS.has(kind):
		return _reject("unsupported_card_kind")

	return {
		"ok": true,
		"reason": "ok",
		"card": card,
		"cost": cost,
		"kind": kind,
	}


func _commit_card_play(card_id: String, cost: int) -> void:
	mana -= cost
	hand.erase(card_id)
	discard_pile.append(card_id)
	run_stats["cards_played"] = int(run_stats.get("cards_played", 0)) + 1
	run_stats["mana_spent"] = int(run_stats.get("mana_spent", 0)) + cost


func _played_card_result(card_id: String, card: Dictionary, cost: int, structure_type: String, events: Array[String]) -> Dictionary:
	return {
		"ok": true,
		"reason": "played_%s" % card_id,
		"card_id": card_id,
		"card_label": str(card.get("label", card_id)),
		"cost": cost,
		"structure_type": structure_type,
		"events": events,
	}


func can_discard_card(card_id: String) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if discard_charges <= 0:
		return _reject("discard_unavailable")

	if not hand.has(card_id):
		return _reject("card_not_in_hand")

	return {"ok": true, "reason": "ok"}


func discard_card(card_id: String) -> Dictionary:
	var result = can_discard_card(card_id)
	if not bool(result["ok"]):
		return result

	var card = get_card_data(card_id)
	var mana_gain = get_discard_mana_gain()
	var events: Array[String] = []
	hand.erase(card_id)
	discard_pile.append(card_id)
	discard_charges -= 1
	mana += mana_gain
	run_stats["cards_discarded"] = int(run_stats.get("cards_discarded", 0)) + 1
	run_stats["discard_mana_gained"] = int(run_stats.get("discard_mana_gained", 0)) + mana_gain

	events.append("Discarded %s: +%s mana." % [card.get("label", card_id), mana_gain])
	_try_draw_from_gauge(events)

	return {
		"ok": true,
		"reason": "discarded_%s" % card_id,
		"card_id": card_id,
		"card_label": str(card.get("label", card_id)),
		"mana_gain": mana_gain,
		"events": events,
	}


func claim_reward_card(card_id: String) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if reward_offer.is_empty():
		return _reject("no_reward_offer")

	if not reward_offer.has(card_id):
		return _reject("reward_card_not_offered")

	var card = get_card_data(card_id)
	var reward_report = get_card_reward_report(card_id)
	var card_zones_before = get_deck_zone_counts(card_id)
	var deck_zones_before = get_deck_zone_counts()
	discard_pile.append(card_id)
	var card_zones_after = get_deck_zone_counts(card_id)
	var deck_zones_after = get_deck_zone_counts()
	var reward_choice_lock = _build_reward_choice_lock("card", card_id, 0)
	var choice_locked_event = _settlement_packet_choice_locked_event(reward_choice_lock)
	reward_offer.clear()
	run_stats["card_rewards_taken"] = int(run_stats.get("card_rewards_taken", 0)) + 1
	last_reward_claim_report = {
		"ok": true,
		"reason": "ok",
		"rewardChoiceLock": reward_choice_lock,
		"rewardChoiceLockId": reward_choice_lock.get("id", ""),
		"settlement_packet_choice_locked": choice_locked_event,
		"rewardPacketId": reward_choice_lock.get("rewardPacketId", ""),
		"settlementBatchId": reward_choice_lock.get("settlementBatchId", ""),
		"choiceType": reward_choice_lock.get("choiceType", "card"),
		"noBonusRewards": true,
		"forbiddenLockTags": reward_choice_lock.get("forbiddenLockTags", []),
		"card_id": card_id,
		"card_label": str(card.get("label", card_id)),
		"rarity": str(reward_report.get("rarity", get_card_rarity(card_id))),
		"rarity_label": str(reward_report.get("rarity_label", get_card_rarity_label(card_id))),
		"role": str(reward_report.get("role", get_card_role(card_id))),
		"effect": str(reward_report.get("effect", get_card_effect_summary(card_id))),
		"destination": "discard",
		"deck_count_before": int(card_zones_before.get("total_count", 0)),
		"deck_count_after": int(card_zones_after.get("total_count", 0)),
		"card_zones_before": card_zones_before,
		"card_zones_after": card_zones_after,
		"deck_zones_before": deck_zones_before,
		"deck_zones_after": deck_zones_after,
		"card_before_summary": _format_card_zone_summary(card_zones_before),
		"card_after_summary": _format_card_zone_summary(card_zones_after),
		"deck_before_summary": _format_deck_zone_summary(deck_zones_before),
		"deck_after_summary": _format_deck_zone_summary(deck_zones_after),
	}
	_finish_active_reward_packet_if_ready()

	return {
		"ok": true,
		"reason": "claimed_%s" % card_id,
		"rewardChoiceLock": reward_choice_lock,
		"rewardChoiceLockId": reward_choice_lock.get("id", ""),
		"settlement_packet_choice_locked": choice_locked_event,
		"rewardPacketId": reward_choice_lock.get("rewardPacketId", ""),
		"settlementBatchId": reward_choice_lock.get("settlementBatchId", ""),
		"choiceType": reward_choice_lock.get("choiceType", "card"),
		"noBonusRewards": true,
		"forbiddenLockTags": reward_choice_lock.get("forbiddenLockTags", []),
		"card_id": card_id,
		"card_label": str(card.get("label", card_id)),
		"role": str(reward_report.get("role", get_card_role(card_id))),
		"effect": str(reward_report.get("effect", get_card_effect_summary(card_id))),
		"rarity_label": str(reward_report.get("rarity_label", get_card_rarity_label(card_id))),
		"destination": "discard",
		"deck_count_before": int(card_zones_before.get("total_count", 0)),
		"deck_count_after": int(card_zones_after.get("total_count", 0)),
		"card_before_summary": _format_card_zone_summary(card_zones_before),
		"card_after_summary": _format_card_zone_summary(card_zones_after),
		"deck_before_summary": _format_deck_zone_summary(deck_zones_before),
		"deck_after_summary": _format_deck_zone_summary(deck_zones_after),
	}


func claim_artifact(artifact_id: String) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if artifact_offer.is_empty():
		return _reject("no_artifact_offer")

	if not artifact_offer.has(artifact_id):
		return _reject("artifact_not_offered")

	if equipped_artifacts.has(artifact_id):
		return _reject("artifact_already_equipped")

	if artifact_actions_remaining <= 0:
		return _consume_artifact_action("equip")

	var reward_report = get_artifact_reward_report(artifact_id)
	var slot_limit = get_artifact_slot_limit()
	if equipped_artifacts.size() >= slot_limit:
		return {
			"ok": false,
			"reason": "artifact_slots_full",
			"artifact_id": artifact_id,
			"artifact_label": get_artifact_label(artifact_id),
			"equipped_count": equipped_artifacts.size(),
			"slot_limit": slot_limit,
			"dormant_count": dormant_artifacts.size(),
			"dormant_limit": get_dormant_artifact_limit(),
			"loadout_summary": get_artifact_loadout_summary(),
		}

	var action_result = _consume_artifact_action("equip")
	if not bool(action_result.get("ok", false)):
		return action_result

	var equipped_count_before = equipped_artifacts.size()
	equipped_artifacts.append(artifact_id)
	artifact_offer.clear()
	run_stats["artifact_rewards_taken"] = int(run_stats.get("artifact_rewards_taken", 0)) + 1
	last_artifact_report = {
		"ok": true,
		"reason": "claimed_%s" % artifact_id,
		"artifact_action_type": "equip",
		"skipped": false,
		"artifact_id": artifact_id,
		"artifact_label": get_artifact_label(artifact_id),
		"effect": str(reward_report.get("effect", get_artifact_effect_summary(artifact_id))),
		"artifact_actions_before": int(action_result.get("artifact_actions_before", 0)),
		"artifact_actions_after": artifact_actions_remaining,
		"artifact_action_limit": get_artifact_action_limit(),
		"equipped_count_before": equipped_count_before,
		"equipped_count_after": equipped_artifacts.size(),
		"slot_limit": get_artifact_slot_limit(),
		"dormant_count": dormant_artifacts.size(),
		"dormant_limit": get_dormant_artifact_limit(),
		"equipped_summary": get_equipped_artifact_summary(),
		"dormant_summary": get_dormant_artifact_summary(),
	}
	_finish_active_reward_packet_if_ready()

	return last_artifact_report.duplicate(true)


func replace_artifact(equipped_artifact_id: String, offered_artifact_id: String, released_dormant_artifact_id: String = "") -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if artifact_offer.is_empty():
		return _reject("no_artifact_offer")

	if not artifact_offer.has(offered_artifact_id):
		return _reject("artifact_not_offered")

	if not equipped_artifacts.has(equipped_artifact_id):
		return _reject("artifact_not_equipped")

	if equipped_artifacts.has(offered_artifact_id):
		return _reject("artifact_already_equipped")

	if artifact_actions_remaining <= 0:
		return _consume_artifact_action("replace")

	var dormant_limit = get_dormant_artifact_limit()
	var release_required = dormant_artifacts.size() >= dormant_limit
	var release_dormant = not released_dormant_artifact_id.is_empty()
	if release_required:
		if released_dormant_artifact_id.is_empty():
			return {
				"ok": false,
				"reason": "artifact_dormant_full",
				"release_required": true,
				"offered_artifact_id": offered_artifact_id,
				"offered_artifact_label": get_artifact_label(offered_artifact_id),
				"equipped_artifact_id": equipped_artifact_id,
				"equipped_artifact_label": get_artifact_label(equipped_artifact_id),
				"dormant_count": dormant_artifacts.size(),
				"dormant_limit": dormant_limit,
				"loadout_summary": get_artifact_loadout_summary(),
			}
		if not dormant_artifacts.has(released_dormant_artifact_id):
			return {
				"ok": false,
				"reason": "artifact_release_not_dormant",
				"release_required": true,
				"released_dormant_artifact_id": released_dormant_artifact_id,
				"offered_artifact_id": offered_artifact_id,
				"offered_artifact_label": get_artifact_label(offered_artifact_id),
				"dormant_count": dormant_artifacts.size(),
				"dormant_limit": dormant_limit,
				"loadout_summary": get_artifact_loadout_summary(),
			}
		release_dormant = true
	elif release_dormant:
		return {
			"ok": false,
			"reason": "artifact_release_not_required",
			"release_required": false,
			"released_dormant_artifact_id": released_dormant_artifact_id,
			"offered_artifact_id": offered_artifact_id,
			"offered_artifact_label": get_artifact_label(offered_artifact_id),
			"equipped_artifact_id": equipped_artifact_id,
			"equipped_artifact_label": get_artifact_label(equipped_artifact_id),
			"dormant_count": dormant_artifacts.size(),
			"dormant_limit": dormant_limit,
			"loadout_summary": get_artifact_loadout_summary(),
		}

	var replace_index = equipped_artifacts.find(equipped_artifact_id)
	if replace_index < 0:
		return _reject("artifact_not_equipped")

	var action_result = _consume_artifact_action("replace")
	if not bool(action_result.get("ok", false)):
		return action_result

	var equipped_count_before = equipped_artifacts.size()
	var dormant_count_before = dormant_artifacts.size()
	var reward_report = get_artifact_reward_report(offered_artifact_id)
	var released_dormant_artifact_label = ""
	var released_dormant_effect = ""
	if release_dormant:
		released_dormant_artifact_label = get_artifact_label(released_dormant_artifact_id)
		released_dormant_effect = get_artifact_effect_summary(released_dormant_artifact_id)
		dormant_artifacts.erase(released_dormant_artifact_id)

	equipped_artifacts[replace_index] = offered_artifact_id
	dormant_artifacts.append(equipped_artifact_id)
	artifact_offer.clear()
	run_stats["artifact_rewards_taken"] = int(run_stats.get("artifact_rewards_taken", 0)) + 1
	run_stats["artifact_replacements"] = int(run_stats.get("artifact_replacements", 0)) + 1
	run_stats["artifact_dormant_added"] = int(run_stats.get("artifact_dormant_added", 0)) + 1
	if release_dormant:
		run_stats["artifact_dormant_released"] = int(run_stats.get("artifact_dormant_released", 0)) + 1
	last_artifact_report = {
		"ok": true,
		"reason": "replaced_%s_with_%s" % [equipped_artifact_id, offered_artifact_id],
		"artifact_action_type": "replace",
		"skipped": false,
		"dormant_released": release_dormant,
		"artifact_id": offered_artifact_id,
		"artifact_label": get_artifact_label(offered_artifact_id),
		"effect": str(reward_report.get("effect", get_artifact_effect_summary(offered_artifact_id))),
		"artifact_actions_before": int(action_result.get("artifact_actions_before", 0)),
		"artifact_actions_after": artifact_actions_remaining,
		"artifact_action_limit": get_artifact_action_limit(),
		"replaced_artifact_id": equipped_artifact_id,
		"replaced_artifact_label": get_artifact_label(equipped_artifact_id),
		"replaced_effect": get_artifact_effect_summary(equipped_artifact_id),
		"released_dormant_artifact_id": released_dormant_artifact_id if release_dormant else "",
		"released_dormant_artifact_label": released_dormant_artifact_label,
		"released_dormant_effect": released_dormant_effect,
		"equipped_count_before": equipped_count_before,
		"equipped_count_after": equipped_artifacts.size(),
		"dormant_count_before": dormant_count_before,
		"dormant_count_after": dormant_artifacts.size(),
		"slot_limit": get_artifact_slot_limit(),
		"dormant_limit": get_dormant_artifact_limit(),
		"equipped_summary": get_equipped_artifact_summary(),
		"dormant_summary": get_dormant_artifact_summary(),
	}
	_finish_active_reward_packet_if_ready()
	return last_artifact_report.duplicate(true)


func skip_reward_offer() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if reward_offer.is_empty():
		return _reject("no_reward_offer")

	var gold_gain = get_card_reward_gold()
	var gold_before = gold
	var skipped_count = reward_offer.size()
	var reward_choice_lock = _build_reward_choice_lock("decline_for_gold", "", gold_gain)
	var choice_locked_event = _settlement_packet_choice_locked_event(reward_choice_lock)
	if gold_gain > 0:
		gold += gold_gain
		run_stats["gold_gained"] = int(run_stats.get("gold_gained", 0)) + gold_gain
		run_stats["card_reward_gold_gained"] = int(run_stats.get("card_reward_gold_gained", 0)) + gold_gain

	reward_offer.clear()
	run_stats["card_reward_gold_choices"] = int(run_stats.get("card_reward_gold_choices", 0)) + 1
	run_stats["card_rewards_skipped"] = int(run_stats.get("card_rewards_skipped", 0)) + 1
	last_reward_claim_report = {
		"ok": true,
		"reason": "reward_gold_taken",
		"rewardChoiceLock": reward_choice_lock,
		"rewardChoiceLockId": reward_choice_lock.get("id", ""),
		"settlement_packet_choice_locked": choice_locked_event,
		"rewardPacketId": reward_choice_lock.get("rewardPacketId", ""),
		"settlementBatchId": reward_choice_lock.get("settlementBatchId", ""),
		"choiceType": reward_choice_lock.get("choiceType", "decline_for_gold"),
		"noBonusRewards": true,
		"forbiddenLockTags": reward_choice_lock.get("forbiddenLockTags", []),
		"gold_choice": true,
		"gold_gain": gold_gain,
		"gold_before": gold_before,
		"gold_after": gold,
		"skipped_count": skipped_count,
		"economy_summary": get_economy_summary(),
	}
	_finish_active_reward_packet_if_ready()
	return {
		"ok": true,
		"reason": "reward_gold_taken",
		"rewardChoiceLock": reward_choice_lock,
		"rewardChoiceLockId": reward_choice_lock.get("id", ""),
		"settlement_packet_choice_locked": choice_locked_event,
		"rewardPacketId": reward_choice_lock.get("rewardPacketId", ""),
		"settlementBatchId": reward_choice_lock.get("settlementBatchId", ""),
		"choiceType": reward_choice_lock.get("choiceType", "decline_for_gold"),
		"noBonusRewards": true,
		"forbiddenLockTags": reward_choice_lock.get("forbiddenLockTags", []),
		"gold_gain": gold_gain,
		"gold_before": gold_before,
		"gold_after": gold,
		"skipped_count": skipped_count,
		"economy_summary": get_economy_summary(),
	}


func skip_artifact_offer() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if artifact_offer.is_empty():
		return _reject("no_artifact_offer")

	var skipped_count = artifact_offer.size()
	artifact_offer.clear()
	run_stats["artifact_rewards_skipped"] = int(run_stats.get("artifact_rewards_skipped", 0)) + 1
	last_artifact_report = {
		"ok": true,
		"reason": "artifact_skipped",
		"artifact_action_type": "skip",
		"skipped": true,
		"skipped_count": skipped_count,
		"artifact_actions_before": artifact_actions_remaining,
		"artifact_actions_after": artifact_actions_remaining,
		"artifact_action_limit": get_artifact_action_limit(),
		"slot_limit": get_artifact_slot_limit(),
		"dormant_count": dormant_artifacts.size(),
		"dormant_limit": get_dormant_artifact_limit(),
		"equipped_summary": get_equipped_artifact_summary(),
		"dormant_summary": get_dormant_artifact_summary(),
	}
	_finish_active_reward_packet_if_ready()
	return last_artifact_report.duplicate(true)


func remove_shop_card(card_id: String) -> Dictionary:
	var result = can_remove_shop_card(card_id)
	if not bool(result.get("ok", false)):
		return result

	var card_report = get_card_removal_report(card_id)
	var card_zones_before = get_deck_zone_counts(card_id)
	var deck_zones_before = get_deck_zone_counts()
	var gold_cost = get_shop_deck_removal_gold_cost()
	var gold_before = gold
	var removed_from = _remove_card_from_deck_zones(card_id)
	if removed_from.is_empty():
		return _reject("card_not_in_deck")

	gold = max(0, gold - gold_cost)
	var card_zones_after = get_deck_zone_counts(card_id)
	var deck_zones_after = get_deck_zone_counts()
	shop_removals_remaining = max(0, shop_removals_remaining - 1)
	shop_purchases_remaining = max(0, shop_purchases_remaining - 1)
	shop_purchase_vote.clear()
	if shop_removals_remaining <= 0 or shop_purchases_remaining <= 0:
		shop_offer.clear()
	if shop_purchases_remaining <= 0:
		shop_service_offer.clear()
		if artifact_offer.is_empty():
			artifact_actions_remaining = 0

	run_stats["shop_cards_removed"] = int(run_stats.get("shop_cards_removed", 0)) + 1
	run_stats["gold_spent"] = int(run_stats.get("gold_spent", 0)) + gold_cost
	run_stats["shop_gold_spent"] = int(run_stats.get("shop_gold_spent", 0)) + gold_cost
	last_shop_report = {
		"ok": true,
		"reason": "ok",
		"shop_action_type": "remove_card",
		"skipped": false,
		"card_id": card_id,
		"card_label": str(card_report.get("label", get_card_label(card_id))),
		"rarity_label": str(card_report.get("rarity_label", get_card_rarity_label(card_id))),
		"role": str(card_report.get("role", get_card_role(card_id))),
		"effect": str(card_report.get("effect", get_card_effect_summary(card_id))),
		"removed_from": removed_from,
		"gold_cost": gold_cost,
		"gold_before": gold_before,
		"gold_after": gold,
		"deck_count_before": int(card_zones_before.get("total_count", 0)),
		"deck_count_after": int(card_zones_after.get("total_count", 0)),
		"card_zones_before": card_zones_before,
		"card_zones_after": card_zones_after,
		"deck_zones_before": deck_zones_before,
		"deck_zones_after": deck_zones_after,
		"card_before_summary": _format_card_zone_summary(card_zones_before),
		"card_after_summary": _format_card_zone_summary(card_zones_after),
		"deck_before_summary": _format_deck_zone_summary(deck_zones_before),
		"deck_after_summary": _format_deck_zone_summary(deck_zones_after),
	}
	_finish_active_reward_packet_if_ready()

	return last_shop_report.duplicate(true)


func buy_shop_service(service_id: String, reactivation_dormant_artifact_id: String = "", reactivation_replaced_artifact_id: String = "") -> Dictionary:
	var result = can_buy_shop_service(service_id, reactivation_dormant_artifact_id, reactivation_replaced_artifact_id)
	if not bool(result.get("ok", false)):
		return result

	var service_report = get_shop_service_report(service_id, reactivation_dormant_artifact_id, reactivation_replaced_artifact_id)
	var service = get_shop_service_data(service_id)
	var service_type = str(service.get("type", ""))
	var gold_cost = max(0, int(service.get("goldCost", 0)))
	var boss_shard_cost = max(0, int(service.get("bossShardCost", 0)))
	var gold_before = gold
	var boss_shards_before = boss_shards
	var artifact_actions_before = artifact_actions_remaining
	var artifact_actions_after = artifact_actions_remaining
	var base_hp_before = base_hp
	var base_hp_after = base_hp
	var healed = 0
	var hp_bonus = max(0, int(service.get("hpBonus", 0)))
	var reinforced_structures = 0
	var total_reinforced_hp = 0
	var reactivated_artifact_id = ""
	var reactivated_artifact_label = ""
	var reactivated_artifact_effect = ""
	var replaced_artifact_id = ""
	var replaced_artifact_label = ""
	var replaced_artifact_effect = ""
	if service_type == "restore_base":
		var heal = max(0, int(service.get("heal", 0)))
		var base_max = max(1, int(data.get("base", {}).get("hp", 100)))
		base_hp = min(base_max, base_hp + heal)
		base_hp_after = base_hp
		healed = max(0, base_hp_after - base_hp_before)
	elif service_type == "structure_hp_boost":
		for key in structures.keys():
			var structure_key = str(key)
			var structure: Dictionary = structures[structure_key]
			structure["max_hp"] = int(structure.get("max_hp", 0)) + hp_bonus
			structure["hp"] = int(structure.get("hp", 0)) + hp_bonus
			structures[structure_key] = structure
			recent_event_tiles[structure_key] = "shop_reinforced"
			reinforced_structures += 1
			total_reinforced_hp += hp_bonus
	elif service_type == "reactivate_dormant_artifact":
		reactivated_artifact_id = str(service_report.get("dormant_artifact_id", ""))
		replaced_artifact_id = str(service_report.get("replaced_artifact_id", ""))
		if reactivated_artifact_id.is_empty() or not dormant_artifacts.has(reactivated_artifact_id):
			return _reject("no_dormant_artifact")

		var dormant_index = dormant_artifacts.find(reactivated_artifact_id)
		var replaced_index = -1
		if not replaced_artifact_id.is_empty():
			replaced_index = equipped_artifacts.find(replaced_artifact_id)
			if replaced_index < 0:
				return _reject("artifact_not_equipped")

		var action_result = _consume_artifact_action("reactivate")
		if not bool(action_result.get("ok", false)):
			return action_result

		artifact_actions_before = int(action_result.get("artifact_actions_before", artifact_actions_before))
		artifact_actions_after = int(action_result.get("artifact_actions_after", artifact_actions_remaining))
		dormant_artifacts.remove_at(dormant_index)
		if replaced_index >= 0:
			equipped_artifacts[replaced_index] = reactivated_artifact_id
			dormant_artifacts.append(replaced_artifact_id)
		else:
			equipped_artifacts.append(reactivated_artifact_id)

		reactivated_artifact_label = get_artifact_label(reactivated_artifact_id)
		reactivated_artifact_effect = get_artifact_effect_summary(reactivated_artifact_id)
		replaced_artifact_label = get_artifact_label(replaced_artifact_id) if not replaced_artifact_id.is_empty() else ""
		replaced_artifact_effect = get_artifact_effect_summary(replaced_artifact_id) if not replaced_artifact_id.is_empty() else ""
		run_stats["artifact_reactivations"] = int(run_stats.get("artifact_reactivations", 0)) + 1
		last_artifact_report = {
			"ok": true,
			"reason": "reactivated_%s" % reactivated_artifact_id,
			"artifact_action_type": "reactivate",
			"skipped": false,
			"artifact_id": reactivated_artifact_id,
			"artifact_label": reactivated_artifact_label,
			"effect": reactivated_artifact_effect,
			"replaced_artifact_id": replaced_artifact_id,
			"replaced_artifact_label": replaced_artifact_label,
			"replaced_effect": replaced_artifact_effect,
			"boss_shard_cost": boss_shard_cost,
			"boss_shards_before": boss_shards_before,
			"boss_shards_after": max(0, boss_shards - boss_shard_cost),
			"artifact_actions_before": artifact_actions_before,
			"artifact_actions_after": artifact_actions_after,
			"artifact_action_limit": get_artifact_action_limit(),
			"equipped_count_after": equipped_artifacts.size(),
			"dormant_count_after": dormant_artifacts.size(),
			"slot_limit": get_artifact_slot_limit(),
			"dormant_limit": get_dormant_artifact_limit(),
			"equipped_summary": get_equipped_artifact_summary(),
			"dormant_summary": get_dormant_artifact_summary(),
		}

	gold = max(0, gold - gold_cost)
	boss_shards = max(0, boss_shards - boss_shard_cost)
	shop_purchases_remaining = max(0, shop_purchases_remaining - 1)
	shop_purchase_vote.clear()
	shop_service_offer.erase(service_id)
	if shop_purchases_remaining <= 0:
		shop_offer.clear()
		shop_service_offer.clear()
		shop_removals_remaining = 0
		if artifact_offer.is_empty():
			artifact_actions_remaining = 0

	run_stats["shop_services_purchased"] = int(run_stats.get("shop_services_purchased", 0)) + 1
	run_stats["shop_base_hp_recovered"] = int(run_stats.get("shop_base_hp_recovered", 0)) + healed
	run_stats["shop_structure_hp_reinforced"] = int(run_stats.get("shop_structure_hp_reinforced", 0)) + total_reinforced_hp
	run_stats["gold_spent"] = int(run_stats.get("gold_spent", 0)) + gold_cost
	run_stats["shop_gold_spent"] = int(run_stats.get("shop_gold_spent", 0)) + gold_cost
	run_stats["boss_shards_spent"] = int(run_stats.get("boss_shards_spent", 0)) + boss_shard_cost
	last_shop_report = {
		"ok": true,
		"reason": "ok",
		"shop_action_type": "service",
		"skipped": false,
		"service_id": service_id,
		"service_label": str(service_report.get("label", get_shop_service_label(service_id))),
		"service_type": service_type,
		"effect": str(service_report.get("purchase_preview", service_report.get("summary", ""))),
		"gold_cost": gold_cost,
		"gold_before": gold_before,
		"gold_after": gold,
		"boss_shard_cost": boss_shard_cost,
		"boss_shards_before": boss_shards_before,
		"boss_shards_after": boss_shards,
		"uses_artifact_action": service_type == "reactivate_dormant_artifact",
		"artifact_actions_before": artifact_actions_before,
		"artifact_actions_after": artifact_actions_remaining,
		"artifact_action_limit": get_artifact_action_limit(),
		"base_hp_before": base_hp_before,
		"base_hp_after": base_hp_after,
		"healed": healed,
		"reinforced_structures": reinforced_structures,
		"total_reinforced_hp": total_reinforced_hp,
		"reactivated_artifact_id": reactivated_artifact_id,
		"reactivated_artifact_label": reactivated_artifact_label,
		"reactivated_artifact_effect": reactivated_artifact_effect,
		"replaced_artifact_id": replaced_artifact_id,
		"replaced_artifact_label": replaced_artifact_label,
		"replaced_artifact_effect": replaced_artifact_effect,
		"loadout_summary": get_artifact_loadout_summary(),
		"deck_after_summary": get_deck_cycle_summary(),
	}
	_finish_active_reward_packet_if_ready()

	return last_shop_report.duplicate(true)


func skip_shop_offer() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not _has_open_shop_offer():
		return _reject("no_shop_offer")

	var skipped_count = shop_offer.size() + shop_service_offer.size()
	shop_offer.clear()
	shop_service_offer.clear()
	shop_removals_remaining = 0
	shop_purchases_remaining = 0
	shop_purchase_vote.clear()
	if artifact_offer.is_empty():
		artifact_actions_remaining = 0
	run_stats["shop_skips"] = int(run_stats.get("shop_skips", 0)) + 1
	last_shop_report = {
		"ok": true,
		"reason": "shop_skipped",
		"shop_action_type": "skip",
		"skipped": true,
		"skipped_count": skipped_count,
		"deck_after_summary": get_deck_cycle_summary(),
	}
	_finish_active_reward_packet_if_ready()
	return last_shop_report.duplicate(true)


func can_remove_structure(tile: Vector2i) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if not _is_in_bounds(tile):
		return _reject("out_of_bounds")

	if not structures.has(_tile_key(tile)):
		return _reject("no_structure")

	return {"ok": true, "reason": "ok"}


func remove_structure(tile: Vector2i) -> Dictionary:
	var result = can_remove_structure(tile)
	if not bool(result["ok"]):
		return result

	var key = _tile_key(tile)
	var structure: Dictionary = structures[key]
	structures.erase(key)
	recent_event_tiles[key] = "structure_removed"

	return {"ok": true, "reason": "removed_%s" % structure["type"]}


func start_wave(player_count: int) -> Dictionary:
	var start_check = can_start_wave(player_count)
	if not bool(start_check.get("ok", false)):
		return start_check

	var normalized_player_count = clamp(player_count, 1, 4)
	var active_directions = _array_string_values(start_check.get("active_directions", get_active_directions(normalized_player_count)))
	var wave_start_report = _build_wave_started_report(normalized_player_count, current_round, active_directions)
	var events: Array[String] = []
	_refill_round_resources(events, normalized_player_count)
	wave_active = true
	active_round = current_round
	spawned_count = 0
	active_wave_packets.clear()
	wave_stack_vote.clear()
	shop_purchase_vote.clear()
	_add_active_wave_packet(active_round, false, normalized_player_count)
	enemies.clear()
	run_stats["rounds_started"] = int(run_stats.get("rounds_started", 0)) + 1
	_update_max_wave_stack_depth()
	events.push_front("Wave started. %s" % describe_wave(normalized_player_count, active_round))
	return {
		"ok": true,
		"events": events,
		"wave_started": wave_start_report,
		"playerCountAtStart": normalized_player_count,
		"activeDirections": active_directions.duplicate(),
		"directions": wave_start_report.get("directions", []).duplicate(),
		"enemyGroups": wave_start_report.get("enemyGroups", []).duplicate(),
		"spawnPlanId": str(wave_start_report.get("spawnPlanId", "")),
		"spawnPlan": wave_start_report.get("spawnPlan", {}),
		"previewCardId": str(wave_start_report.get("previewCardId", "")),
		"previewCard": wave_start_report.get("previewCard", {}),
	}


func can_start_wave(player_count: int) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if wave_active:
		return _reject("wave_already_active")

	if has_pending_reward():
		return _reject("reward_pending")

	if run_complete:
		return _reject("run_complete")

	if base_hp <= 0:
		return _reject("base_destroyed")

	var active_directions = _array_string_values(get_active_directions(player_count))
	if active_directions.is_empty():
		return _reject("no_active_direction")

	var spawn_plan = get_wave_spawn_plan_report(player_count, current_round)
	if not bool(spawn_plan.get("ok", false)):
		return spawn_plan

	var projected_directions = _array_string_values(spawn_plan.get("directions", []))
	if projected_directions.is_empty():
		return _reject("no_projected_direction")

	if int(spawn_plan.get("spawnPacketCount", 0)) <= 0:
		return _reject("no_spawn_packets")

	for direction in projected_directions:
		var path = _find_path(_entrance_tile(direction), _blocked_tiles())
		if path.is_empty():
			return _reject("no_path_from_%s" % direction)

	return {
		"ok": true,
		"reason": "ok",
		"round": current_round,
		"active_directions": active_directions.duplicate(),
		"directions": projected_directions.duplicate(),
		"laneProjection": get_lane_projection_report(player_count, current_round),
		"spawnPlanId": str(spawn_plan.get("spawnPlanId", "")),
		"spawnPlan": spawn_plan,
	}


func _build_wave_started_report(player_count: int, round_number: int, active_directions: Array) -> Dictionary:
	var spawn_plan = _cached_wave_spawn_plan(player_count, round_number, active_directions)
	var directions = _array_string_values(spawn_plan.get("directions", []))
	if directions.is_empty():
		directions = _wave_spawn_directions_for_round_number(player_count, active_directions, round_number)
	var preview_card = _cached_wave_preview_card(player_count, round_number, active_directions)
	var wave_intent: Dictionary = preview_card.get("waveIntent", {})
	return {
		"event": "wave_started",
		"day": round_number,
		"round": round_number,
		"playerCount": player_count,
		"playerCountAtStart": player_count,
		"activeDirections": active_directions.duplicate(),
		"directions": directions,
		"enemyGroups": get_enemy_mix_ids(round_number),
		"waveIntentId": str(preview_card.get("waveIntentId", "")),
		"waveIntent": wave_intent,
		"previewCardId": str(preview_card.get("previewCardId", "")),
		"previewCard": preview_card,
		"spawnPlanId": str(spawn_plan.get("spawnPlanId", _wave_spawn_plan_id(round_number))),
		"spawnPlan": spawn_plan,
	}


func _wave_spawn_directions_for_round(player_count: int, active_directions: Array) -> Array:
	return _wave_spawn_directions_for_round_number(player_count, active_directions, current_round)


func _wave_spawn_directions_for_round_number(player_count: int, active_directions: Array, round_number: int) -> Array:
	var normalized_player_count = clamp(player_count, 1, 4)
	var resolved_active_directions = _array_string_values(active_directions)
	if resolved_active_directions.is_empty():
		resolved_active_directions = _array_string_values(get_active_directions(normalized_player_count))
	if resolved_active_directions.is_empty():
		return []

	var target_round = current_round if round_number <= 0 else round_number
	var boss_enemy_id = _boss_enemy_id() if _is_boss_round(target_round) else ""
	var enemy_roles = _wave_enemy_role_tags(get_enemy_mix_ids(target_round), boss_enemy_id)
	var inferred_primary_enemy_role = _wave_primary_enemy_role_for_round(target_round, enemy_roles, boss_enemy_id)
	var scheduled_intent_id = _wave_intent_id_for_round(target_round)
	var primary_enemy_role = _wave_intent_primary_role(scheduled_intent_id, inferred_primary_enemy_role)
	var wave_intent_id = scheduled_intent_id
	if wave_intent_id.is_empty():
		wave_intent_id = _wave_intent_id_for_role(target_round, primary_enemy_role)
	return _lane_projection_directions(
		target_round,
		resolved_active_directions,
		wave_intent_id,
		primary_enemy_role
	)


func _build_wave_stack_executed_report(player_count: int, pulled_round: int, active_directions: Array) -> Dictionary:
	var stacked_rounds = _active_wave_rounds()
	var settlement_packets = _build_wave_stack_settlement_packet_reports(stacked_rounds)
	var preview_card = _cached_wave_preview_card(clamp(player_count, 1, 4), pulled_round, active_directions)
	var spawn_plan = _cached_wave_spawn_plan(clamp(player_count, 1, 4), pulled_round, active_directions)
	var settlement_batch = {
		"settlementBatchId": _settlement_batch_id(stacked_rounds),
		"sourceWaveIds": _wave_ids_for_rounds(stacked_rounds),
		"rewardPacketIds": _reward_packet_ids_for_rounds(stacked_rounds),
		"packetCount": settlement_packets.size(),
		"compressed": stacked_rounds.size() > 1,
		"noBonusRewards": true,
		"temporaryLockPolicy": {"onlyUnlockedRows": true},
		"forbiddenSummaryTextTags": SETTLEMENT_FORBIDDEN_SUMMARY_TEXT_TAGS.duplicate(),
	}
	return {
		"event": "wave_stacked",
		"round": pulled_round,
		"day": pulled_round,
		"playerCount": clamp(player_count, 1, 4),
		"playerCountAtStart": clamp(player_count, 1, 4),
		"activeDirections": active_directions.duplicate(),
		"directions": _array_string_values(spawn_plan.get("directions", _wave_spawn_directions_for_round_number(player_count, active_directions, pulled_round))),
		"enemyGroups": get_enemy_mix_ids(pulled_round),
		"waveIntentId": str(preview_card.get("waveIntentId", "")),
		"waveIntent": preview_card.get("waveIntent", {}),
		"spawnPlanId": str(spawn_plan.get("spawnPlanId", _wave_spawn_plan_id(pulled_round))),
		"spawnPlan": spawn_plan,
		"previewCardId": str(preview_card.get("previewCardId", "")),
		"previewCard": preview_card,
		"stackDepth": get_active_wave_stack_depth(),
		"pulledRound": pulled_round,
		"stackedRounds": stacked_rounds.duplicate(),
		"settlementPackets": settlement_packets,
		"settlementBatch": settlement_batch,
		"tempoOnly": true,
		"noBonusRewards": true,
		"forbiddenRewardFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
	}


func _build_wave_stack_settlement_packet_reports(rounds: Array) -> Array:
	var packets: Array = []
	var batch_id = _settlement_batch_id(rounds)
	for index in range(rounds.size()):
		var round_number = int(rounds[index])
		packets.append({
			"rewardPacketId": _wave_reward_packet_id(round_number),
			"waveId": _wave_id(round_number),
			"spawnPlanId": _wave_spawn_plan_id(round_number),
			"round": round_number,
			"day": round_number,
			"batchIndex": index + 1,
			"batchTotal": rounds.size(),
			"generatedInsideSettlementBatchId": batch_id if rounds.size() > 1 else "",
			"candidateCount": get_card_offer_count(),
			"noBonusRewards": true,
			"forbiddenBonusFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
		})
	return packets


func step_wave(player_count: int) -> Array[String]:
	var events: Array[String] = []
	if not wave_active:
		return events

	recent_event_tiles.clear()
	run_stats["steps"] = int(run_stats.get("steps", 0)) + 1

	_spawn_active_wave_enemies(player_count, events)

	_towers_attack(events)
	_move_enemies(events)

	if _all_active_wave_packets_spawned() and enemies.is_empty() and base_hp > 0:
		events.append("Wave group complete. %s" % get_wave_summary())
		wave_active = false
		_complete_active_rounds(events)

	if base_hp <= 0:
		if not active_wave_packets.is_empty():
			last_round_report = _build_last_round_report(_active_wave_rounds(), false, false)
			round_start_stats = _copy_run_stats()
			events.append("Round report: %s" % get_last_round_summary())
		wave_active = false
		active_round = 0
		active_wave_packets.clear()
		wave_stack_vote.clear()
		shop_purchase_vote.clear()
		events.append("Base destroyed. M0 run failed.")
		events.append("Outcome: %s" % get_run_outcome_summary(player_count))

	_update_wave_stack_tempo_tracker(events)
	return events


func _spawn_active_wave_enemies(player_count: int, events: Array[String]) -> void:
	for packet_index in range(active_wave_packets.size()):
		var packet: Dictionary = active_wave_packets[packet_index]
		if int(packet.get("spawned", 0)) >= int(packet.get("total", 0)):
			continue

		_spawn_enemy_from_packet(player_count, packet_index, events)


func _spawn_enemy_from_packet(player_count: int, packet_index: int, events: Array[String]) -> void:
	if packet_index < 0 or packet_index >= active_wave_packets.size():
		return

	var packet: Dictionary = active_wave_packets[packet_index]
	var packet_round = int(packet.get("round", active_round))
	var active_directions = _array_string_values(get_active_directions(player_count))
	var spawn_plan: Dictionary = packet.get("spawnPlan", {})
	if spawn_plan.is_empty():
		spawn_plan = _cached_wave_spawn_plan(player_count, packet_round, active_directions)
	var packet_spawned = int(packet.get("spawned", 0))
	var spawn_packet_ref = _wave_spawn_packet_ref_for_spawn_index(spawn_plan, packet_spawned)
	var spawn_packet: Dictionary = spawn_packet_ref.get("packet", {})
	var packet_spawn_offset = int(spawn_packet_ref.get("offset", 0))
	var spawn_directions = _array_string_values(spawn_packet.get("directions", []))
	if spawn_directions.is_empty():
		spawn_directions = _array_string_values(packet.get("directions", []))
	if spawn_directions.is_empty():
		spawn_directions = _wave_spawn_directions_for_round_number(player_count, active_directions, packet_round)
	if spawn_directions.is_empty():
		wave_active = false
		events.append("No active direction. Wave stopped.")
		return

	var direction: String = spawn_directions[packet_spawn_offset % spawn_directions.size()]
	var tile = _entrance_tile(direction)
	var enemy_id = str(spawn_packet.get("enemyId", _enemy_id_for_spawn(packet_spawned, packet_round)))
	var enemy_data = _enemy_data_by_id(enemy_id)
	var enemy = {
		"id": next_enemy_id,
		"enemy_id": enemy_id,
		"tile": tile,
		"hp": int(enemy_data.get("hp", 6)),
		"direction": direction,
		"round": packet_round,
		"spawn_plan_id": str(spawn_plan.get("spawnPlanId", packet.get("spawnPlanId", ""))),
		"spawn_packet_id": str(spawn_packet.get("packetId", "")),
		"stacked": bool(packet.get("stacked", false)),
		"boss": bool(enemy_data.get("boss", false)),
		"phase_triggered": false,
		"siege_gaze_charge": 0,
		"boss_parts": _initial_boss_parts(enemy_data),
		"boss_stride_slow_charge": 0,
	}
	enemies.append(enemy)
	packet["spawned"] = packet_spawned + 1
	active_wave_packets[packet_index] = packet
	spawned_count += 1
	next_enemy_id += 1
	run_stats["spawned"] = int(run_stats.get("spawned", 0)) + 1
	_increment_bucket_stat("spawned_by_enemy_id", enemy_id, 1)
	if _is_boss_enemy(enemy):
		run_stats["bosses_spawned"] = int(run_stats.get("bosses_spawned", 0)) + 1
	recent_event_tiles[_tile_key(tile)] = "spawn"
	events.append("%s spawned at %s from round %s via %s." % [
		_enemy_display_name(enemy),
		direction,
		packet_round,
		spawn_packet.get("packetId", packet.get("spawnPlanId", "spawn_plan")),
	])


func _towers_attack(events: Array[String]) -> void:
	var tower_data: Dictionary = data.get("structures", {}).get("m0_basic_tower", {})
	var tower_range = int(tower_data.get("range", 3))
	var tower_damage = int(tower_data.get("damage", 1))

	for structure in structures.values():
		if structure["type"] != "tower":
			continue

		if not structures.has(_tile_key(structure["tile"])):
			continue

		var target_index = _find_nearest_enemy_index(structure["tile"], tower_range)
		if target_index < 0:
			continue

		var target = enemies[target_index]
		var target_id = int(target["id"])
		var target_tile: Vector2i = target["tile"]
		var aura_bonus = _tinkerer_aura_damage_bonus(structure)
		var damage = tower_damage + aura_bonus
		if aura_bonus > 0:
			run_stats["class_aura_damage"] = int(run_stats.get("class_aura_damage", 0)) + aura_bonus

		run_stats["tower_hits"] = int(run_stats.get("tower_hits", 0)) + 1
		recent_event_tiles[_tile_key(structure["tile"])] = "attack"
		_damage_enemy_at_index(
			target_index,
			damage,
			events,
			"Tower at %s" % _tile_text(structure["tile"]),
			"",
			"hit"
		)
		_apply_elementalist_splash(structure, target_tile, target_id, events)


func _move_enemies(events: Array[String]) -> void:
	var index = enemies.size() - 1
	while index >= 0:
		if index >= enemies.size():
			index = enemies.size() - 1
			continue

		if _enemy_attack_adjacent_structure(index, events):
			index -= 1
			continue

		if _try_boss_siege_gaze(index, events):
			index -= 1
			continue

		if _try_boss_stride_slow_wait(index, events):
			index -= 1
			continue

		var enemy = enemies[index]
		if _enemy_prioritizes_structures(enemy) and _move_enemy_toward_break_target(index, events, true):
			index -= 1
			continue

		var path = _find_path(enemy["tile"], _blocked_tiles())
		if path.size() <= 1:
			if _move_enemy_toward_break_target(index, events):
				index -= 1
				continue

			events.append("%s cannot find path and waits." % _enemy_display_name(enemy))
			index -= 1
			continue

		var next_tile: Vector2i = path[1]
		if get_base_cells().has(next_tile):
			_enemy_hit_base(index, next_tile, events)
		else:
			enemy["tile"] = next_tile
			enemies[index] = enemy
			_move_enemy_bonus_steps(index, events)

		index -= 1


func _enemy_hit_base(enemy_index: int, base_tile: Vector2i, events: Array[String]) -> void:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return

	var enemy = enemies[enemy_index]
	var enemy_data = _enemy_data(enemy)
	var damage = int(enemy_data.get("baseDamage", 1))
	var enemy_direction = str(enemy.get("direction", ""))
	var enemy_id = str(enemy.get("enemy_id", _default_enemy_id()))
	base_hp -= damage
	run_stats["base_hits"] = int(run_stats.get("base_hits", 0)) + 1
	if _is_boss_enemy(enemy):
		run_stats["boss_base_hits"] = int(run_stats.get("boss_base_hits", 0)) + 1
		_increment_bucket_stat("boss_base_hits_by_direction", enemy_direction, 1)
	run_stats["base_damage"] = int(run_stats.get("base_damage", 0)) + damage
	_increment_bucket_stat("base_hits_by_direction", enemy_direction, 1)
	_increment_bucket_stat("base_damage_by_direction", enemy_direction, damage)
	_increment_bucket_stat("base_hits_by_enemy_id", enemy_id, 1)
	events.append("%s reached base. Base HP: %s." % [_enemy_display_name(enemy), base_hp])
	recent_event_tiles[_tile_key(base_tile)] = "base_damage"
	enemies.remove_at(enemy_index)


func _move_enemy_bonus_steps(enemy_index: int, events: Array[String]) -> void:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return

	var move_steps = _enemy_move_steps(enemies[enemy_index])
	var bonus_steps = move_steps - 1
	if bonus_steps <= 0:
		return

	for _bonus_step in range(bonus_steps):
		if enemy_index < 0 or enemy_index >= enemies.size():
			return

		var enemy = enemies[enemy_index]
		var path = _find_path(enemy["tile"], _blocked_tiles())
		if path.size() <= 1:
			return

		var next_tile: Vector2i = path[1]
		run_stats["enemy_fast_moves"] = int(run_stats.get("enemy_fast_moves", 0)) + 1
		if get_base_cells().has(next_tile):
			_enemy_hit_base(enemy_index, next_tile, events)
			return

		enemy["tile"] = next_tile
		enemies[enemy_index] = enemy
		recent_event_tiles[_tile_key(next_tile)] = "fast_move"
		events.append("%s darted to %s." % [
			_enemy_display_name(enemy),
			_tile_text(next_tile),
		])


func _move_enemy_toward_break_target(enemy_index: int, events: Array[String], priority_move = false) -> bool:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return false

	var enemy = enemies[enemy_index]
	var enemy_tile: Vector2i = enemy["tile"]
	var target = _find_break_target(enemy_tile)
	if target.is_empty():
		return false

	var approach_path: Array = target.get("approach_path", [])
	if approach_path.size() <= 1:
		return false

	var next_tile: Vector2i = approach_path[1]
	enemy["tile"] = next_tile
	enemies[enemy_index] = enemy
	run_stats["break_targets_found"] = int(run_stats.get("break_targets_found", 0)) + 1
	run_stats["break_path_steps"] = int(run_stats.get("break_path_steps", 0)) + 1
	if priority_move:
		run_stats["enemy_priority_break_moves"] = int(run_stats.get("enemy_priority_break_moves", 0)) + 1
	recent_event_tiles[_tile_key(next_tile)] = "break_path"
	var target_tile: Vector2i = target.get("tile", Vector2i.ZERO)
	var pressure_label = "prioritizes structure pressure" if priority_move else "pressures blocked path"
	events.append("%s %s toward %s at %s." % [
		_enemy_display_name(enemy),
		pressure_label,
		target.get("type", "structure"),
		_tile_text(target_tile),
	])

	return true


func _enemy_attack_adjacent_structure(enemy_index: int, events: Array[String]) -> bool:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return false

	var enemy = enemies[enemy_index]
	var enemy_tile: Vector2i = enemy["tile"]
	var target = _choose_adjacent_structure_target(enemy_tile)
	if target.is_empty():
		return false

	var target_key = str(target["key"])
	var target_tile: Vector2i = target["tile"]
	var damage = int(_enemy_data(enemy).get("structureDamage", 4))
	var structure: Dictionary = structures[target_key]
	structure["hp"] = int(structure["hp"]) - damage
	run_stats["structure_hits"] = int(run_stats.get("structure_hits", 0)) + 1
	if _structure_taunt_priority(structure) > 0:
		run_stats["class_taunt_hits"] = int(run_stats.get("class_taunt_hits", 0)) + 1
	recent_event_tiles[_tile_key(target_tile)] = "structure_hit"
	events.append("%s hit %s at %s for %s. HP: %s/%s." % [
		_enemy_display_name(enemy),
		structure["type"],
		_tile_text(target_tile),
		damage,
		max(0, int(structure["hp"])),
		structure["max_hp"],
	])

	_apply_guardian_thorns(structure, int(enemy["id"]), events)

	if int(structure["hp"]) <= 0:
		structures.erase(target_key)
		run_stats["structures_destroyed"] = int(run_stats.get("structures_destroyed", 0)) + 1
		_increment_bucket_stat("structures_destroyed_by_direction", str(enemy.get("direction", "")), 1)
		recent_event_tiles[_tile_key(target_tile)] = "structure_destroyed"
		events.append("%s at %s destroyed. Paths recalculated." % [
			str(structure["type"]).capitalize(),
			_tile_text(target_tile),
		])
		_apply_architect_planned_collapse(structure, target_tile, str(enemy.get("direction", "")), events)
	else:
		structures[target_key] = structure

	return true


func _find_break_target(enemy_tile: Vector2i) -> Dictionary:
	var blocked = _blocked_tiles()
	var best = {}
	var best_approach_steps = 999999
	var best_opened_steps = 999999
	var best_priority = -999999
	var best_hp = 999999

	for key in structures.keys():
		var structure_key = str(key)
		var structure: Dictionary = structures[structure_key]
		var structure_tile: Vector2i = structure["tile"]
		var removal_blocked = blocked.duplicate()
		removal_blocked.erase(structure_key)

		var opened_path = _find_path(enemy_tile, removal_blocked)
		if opened_path.is_empty():
			continue

		var approach_path = _find_path_to_adjacent_open_tile(enemy_tile, structure_tile, blocked)
		if approach_path.is_empty():
			continue

		var approach_steps = approach_path.size() - 1
		var opened_steps = opened_path.size() - 1
		var priority = _structure_attack_priority(structure)
		var hp = int(structure.get("hp", 0))
		if _is_better_break_target(best, approach_steps, opened_steps, priority, hp, best_approach_steps, best_opened_steps, best_priority, best_hp):
			best = {
				"key": structure_key,
				"tile": structure_tile,
				"type": structure.get("type", "structure"),
				"approach_path": approach_path,
				"opened_steps": opened_steps,
			}
			best_approach_steps = approach_steps
			best_opened_steps = opened_steps
			best_priority = priority
			best_hp = hp

	return best


func _is_better_break_target(best: Dictionary, approach_steps: int, opened_steps: int, priority: int, hp: int, best_approach_steps: int, best_opened_steps: int, best_priority: int, best_hp: int) -> bool:
	if best.is_empty():
		return true

	if approach_steps != best_approach_steps:
		return approach_steps < best_approach_steps

	if opened_steps != best_opened_steps:
		return opened_steps < best_opened_steps

	if priority != best_priority:
		return priority > best_priority

	return hp < best_hp


func _choose_adjacent_structure_target(enemy_tile: Vector2i) -> Dictionary:
	var best = {}
	var best_priority = -999999
	var best_hp = 999999

	for step in DIR_STEPS:
		var check_tile = enemy_tile + step
		var key = _tile_key(check_tile)
		if not structures.has(key):
			continue

		var structure: Dictionary = structures[key]
		var priority = _structure_attack_priority(structure)
		var hp = int(structure.get("hp", 0))
		if best.is_empty() or priority > best_priority or (priority == best_priority and hp < best_hp):
			best = {
				"key": key,
				"tile": check_tile,
			}
			best_priority = priority
			best_hp = hp

	return best


func _structure_attack_priority(structure: Dictionary) -> int:
	var priority = _structure_taunt_priority(structure)
	var max_hp = int(structure.get("max_hp", 0))
	var hp = int(structure.get("hp", 0))

	if max_hp > 0 and hp < max_hp:
		priority += 10

	if str(structure.get("type", "")) == "barricade":
		priority += 1

	return priority


func _structure_taunt_priority(structure: Dictionary) -> int:
	var effects = get_class_effects(str(structure.get("class_id", "")))
	return int(effects.get("tauntPriority", 0))


func _predict_enemy_intent(enemy: Dictionary, blocked: Dictionary) -> Dictionary:
	var enemy_tile: Vector2i = enemy.get("tile", Vector2i.ZERO)
	var adjacent_target = _choose_adjacent_structure_target(enemy_tile)
	if not adjacent_target.is_empty():
		var target_key = str(adjacent_target.get("key", ""))
		var target_tile: Vector2i = adjacent_target.get("tile", enemy_tile)
		var target_structure: Dictionary = structures.get(target_key, {})
		return _enemy_intent_result(enemy, "attack_structure", target_tile, {
			"target_type": str(target_structure.get("type", "structure")),
		})

	var siege_target_key = _boss_siege_target_key_for_next_step(enemy)
	if not siege_target_key.is_empty() and structures.has(siege_target_key):
		var siege_structure: Dictionary = structures[siege_target_key]
		return _enemy_intent_result(enemy, "boss_siege", siege_structure.get("tile", enemy_tile), {
			"target_type": str(siege_structure.get("type", "structure")),
		})

	if _enemy_prioritizes_structures(enemy):
		var priority_break_target = _find_break_target(enemy_tile)
		if not priority_break_target.is_empty():
			var priority_approach_path: Array = priority_break_target.get("approach_path", [])
			if priority_approach_path.size() > 1:
				var priority_approach_tile: Vector2i = priority_approach_path[1]
				return _enemy_intent_result(enemy, "break_path", priority_approach_tile, {
					"target_tile": priority_break_target.get("tile", Vector2i.ZERO),
					"target_type": str(priority_break_target.get("type", "structure")),
				})

	var path = _find_path(enemy_tile, blocked)
	if path.size() > 1:
		var next_tile: Vector2i = path[1]
		if get_base_cells().has(next_tile):
			return _enemy_intent_result(enemy, "hit_base", next_tile)

		return _enemy_intent_result(enemy, "move", next_tile)

	var break_target = _find_break_target(enemy_tile)
	if not break_target.is_empty():
		var approach_path: Array = break_target.get("approach_path", [])
		if approach_path.size() > 1:
			var approach_tile: Vector2i = approach_path[1]
			return _enemy_intent_result(enemy, "break_path", approach_tile, {
				"target_tile": break_target.get("tile", Vector2i.ZERO),
				"target_type": str(break_target.get("type", "structure")),
			})

	return _enemy_intent_result(enemy, "wait", enemy_tile)


func _enemy_intent_result(enemy: Dictionary, action: String, tile: Vector2i, extra: Dictionary = {}) -> Dictionary:
	var result = {
		"enemy_instance_id": int(enemy.get("id", 0)),
		"enemy_id": str(enemy.get("enemy_id", _default_enemy_id())),
		"direction": str(enemy.get("direction", "")),
		"source_tile": enemy.get("tile", tile),
		"tile": tile,
		"action": action,
		"boss": _is_boss_enemy(enemy),
	}
	for key in extra.keys():
		result[key] = extra[key]
	return result


func _enemy_intent_tile_severity(entry: Dictionary) -> String:
	if int(entry.get("base_count", 0)) > 0:
		return "base"
	if int(entry.get("siege_count", 0)) > 0:
		return "siege"
	if int(entry.get("attack_count", 0)) > 0:
		return "attack"
	if int(entry.get("break_count", 0)) > 0:
		return "break"
	if int(entry.get("move_count", 0)) > 0:
		return "move"
	return "wait"


func _enemy_intent_tile_summary(entry: Dictionary) -> String:
	var parts = PackedStringArray()
	if int(entry.get("base_count", 0)) > 0:
		parts.append("base %s" % entry.get("base_count", 0))
	if int(entry.get("siege_count", 0)) > 0:
		parts.append("siege %s" % entry.get("siege_count", 0))
	if int(entry.get("attack_count", 0)) > 0:
		parts.append("attack %s" % entry.get("attack_count", 0))
	if int(entry.get("break_count", 0)) > 0:
		parts.append("break %s" % entry.get("break_count", 0))
	if int(entry.get("move_count", 0)) > 0:
		parts.append("move %s" % entry.get("move_count", 0))
	if int(entry.get("wait_count", 0)) > 0:
		parts.append("wait %s" % entry.get("wait_count", 0))
	if int(entry.get("boss_count", 0)) > 0:
		parts.append("boss %s" % entry.get("boss_count", 0))

	return ", ".join(parts) if not parts.is_empty() else "none"


func _wave_tactical_report(ok: bool, state: String, severity: String, headline: String, suggestion: String, card_hint: String, threat: Dictionary, summary: String) -> Dictionary:
	return {
		"ok": ok,
		"state": state,
		"reason": state,
		"severity": severity,
		"headline": headline,
		"suggestion": suggestion,
		"card_hint": card_hint,
		"threat": threat,
		"summary": summary,
	}


func _risk_ping_report(ok: bool, state: String, severity: String, source_label: String, candidates: Array, forced_summary: String = "") -> Dictionary:
	var labels = _risk_ping_candidate_labels(candidates)
	var summary = forced_summary
	if summary.is_empty():
		summary = "Risk pings: %s -> %s | candidate only until confirmed" % [
			source_label,
			", ".join(labels),
		]

	return {
		"ok": ok,
		"state": state,
		"severity": severity,
		"source_label": source_label,
		"candidates": candidates,
		"labels": labels,
		"summary": summary,
		"candidate_only": true,
	}


func _risk_ping_candidate_labels(candidates: Array) -> PackedStringArray:
	var labels = PackedStringArray()
	for candidate_value in candidates:
		if typeof(candidate_value) != TYPE_DICTIONARY:
			continue
		var candidate: Dictionary = candidate_value
		var label = str(candidate.get("label", ""))
		if not label.is_empty():
			labels.append(label)

	return labels


func _add_risk_ping_candidate(candidates: Array, label: String, tag: String, reason: String, tile: Vector2i = Vector2i(-1, -1)) -> void:
	if label.is_empty() or candidates.size() >= 4:
		return

	for candidate_value in candidates:
		if typeof(candidate_value) != TYPE_DICTIONARY:
			continue
		var candidate: Dictionary = candidate_value
		if str(candidate.get("label", "")) == label:
			return

	candidates.append({
		"label": label,
		"tag": tag,
		"reason": reason,
		"tile": tile,
	})


func _append_risk_ping_candidates_for_threat(candidates: Array, threat: Dictionary, tactical_report: Dictionary, player_count: int) -> void:
	var source_tile: Vector2i = threat.get("source_tile", Vector2i(-1, -1))
	var target_tile: Vector2i = threat.get("tile", source_tile)
	var break_target_tile: Vector2i = threat.get("target_tile", target_tile)
	match str(threat.get("action", "wait")):
		"hit_base":
			if _risk_ping_base_hit_is_critical(threat):
				_add_risk_ping_candidate(candidates, "Retreat/hold", "retreat_hold", "The next base hit can put the run in critical danger.", target_tile)
			_add_risk_ping_candidate(candidates, "Focus fire", "focus_fire", "Stop the leaking enemy before it reaches base.", source_tile)
			_add_risk_ping_candidate(candidates, "Slow/control request", "slow_control", "Buy seconds before the base hit lands.", source_tile)
			_add_risk_ping_candidate(candidates, "Route check", "route_check", "Check whether the path is too short.", target_tile)
			_add_risk_ping_candidate(candidates, "Move kill zone", "move_kill_zone", "Shift damage backward if the front is already lost.", target_tile)
		"boss_siege":
			_add_risk_ping_candidate(candidates, "Part focus", "part_focus", "Pressure the boss part before the pattern repeats.", source_tile)
			_add_risk_ping_candidate(candidates, "Repair request", "repair_request", "Prepare the targeted structure for the hit.", target_tile)
			_add_risk_ping_candidate(candidates, "Taunt reposition", "taunt_reposition", "Move attention away from the weakest structure.", target_tile)
			_add_risk_ping_candidate(candidates, "Hold pull", "hold_pull", "Do not add another wave during the boss pattern.", source_tile)
		"attack_structure":
			var structure_risk = _risk_ping_structure_threat(threat)
			if bool(structure_risk.get("will_break", false)):
				if bool(structure_risk.get("planned_collapse", false)):
					_add_risk_ping_candidate(candidates, "Hold sacrifice", "hold_sacrifice", "Let the marked barricade break if the blast is valuable.", target_tile)
					_add_risk_ping_candidate(candidates, "Rear rebuild", "rear_rebuild", "Prepare the next pocket behind the collapse.", target_tile)
				else:
					_add_risk_ping_candidate(candidates, "Repair request", "repair_request", "Prevent the structure from breaking.", target_tile)
					_add_risk_ping_candidate(candidates, "Rear rebuild", "rear_rebuild", "Prepare a replacement pocket if repair is late.", target_tile)
			else:
				_add_risk_ping_candidate(candidates, "Repair request", "repair_request", "Keep the structure healthy before the next hit.", target_tile)
			_add_risk_ping_candidate(candidates, "Focus fire", "focus_fire", "Kill or weaken the attacker before contact.", source_tile)
			_add_risk_ping_candidate(candidates, "Route check", "route_check", "Check whether this structure is the last bend.", target_tile)
		"break_path":
			_add_risk_ping_candidate(candidates, "Route check", "route_check", "The enemy is opening a shorter route.", break_target_tile)
			_add_risk_ping_candidate(candidates, "Focus fire", "focus_fire", "Remove the breaker before the path opens.", source_tile)
			_add_risk_ping_candidate(candidates, "Move kill zone", "move_kill_zone", "Prepare a fallback damage pocket.", break_target_tile)
			_add_risk_ping_candidate(candidates, "Repair request", "repair_request", "Repair nearby pieces only if they still change the route.", break_target_tile)
		"move":
			var direction = str(threat.get("direction", ""))
			var pressure = get_front_pressure_by_direction(player_count).get(direction, {})
			if ["danger", "critical"].has(str(pressure.get("severity", "idle"))):
				_add_risk_ping_candidate(candidates, "Slow/control request", "slow_control", "Buy time on the pressured front.", source_tile)
				_add_risk_ping_candidate(candidates, "Focus fire", "focus_fire", "Remove the nearest threat before it leaks.", source_tile)
				_add_risk_ping_candidate(candidates, "Route check", "route_check", "Check whether the path became too short.", target_tile)
		_:
			if str(tactical_report.get("severity", "")) != "watch":
				_add_risk_ping_candidate(candidates, "Route check", "route_check", "Re-read the active threat before spending cards.", target_tile)


func _append_risk_ping_candidates_for_stack(candidates: Array, stack_report: Dictionary) -> void:
	_add_risk_ping_candidate(candidates, "Hold pull", "hold_pull", "Wave pull risk is rising.")

	var labels = _risk_ping_candidate_labels_from_values(stack_report.get("detail_labels", []))
	var label_text = " ".join(labels)
	if label_text.contains("structure"):
		_add_risk_ping_candidate(candidates, "Repair request", "repair_request", "Structure damage is part of the pull risk.")
	if label_text.contains("front") or label_text.contains("density"):
		_add_risk_ping_candidate(candidates, "Route check", "route_check", "Front pressure is part of the pull risk.")
	if label_text.contains("hand"):
		_add_risk_ping_candidate(candidates, "Discard plan", "discard_plan", "Open a hand slot before adding more pressure.")


func _risk_ping_candidate_labels_from_values(values) -> PackedStringArray:
	var labels = PackedStringArray()
	for value in values:
		var label = str(value)
		if not label.is_empty():
			labels.append(label)

	return labels


func _risk_ping_source_label(threat: Dictionary, tactical_report: Dictionary) -> String:
	var direction = _direction_label(str(threat.get("direction", "")))
	match str(threat.get("action", "wait")):
		"hit_base":
			return "%s base danger" % direction
		"boss_siege":
			return "%s boss pattern" % direction
		"attack_structure":
			return "%s structure danger" % direction
		"break_path":
			return "%s path break" % direction
		"move":
			return "%s front pressure" % direction
		_:
			return str(tactical_report.get("headline", "active threat"))


func _risk_ping_base_hit_is_critical(threat: Dictionary) -> bool:
	var enemy_data = _enemy_data_by_id(str(threat.get("enemy_id", _default_enemy_id())))
	var base_damage = max(1, int(enemy_data.get("baseDamage", 1)))
	var base_max = max(1, int(data.get("base", {}).get("hp", 100)))
	return base_hp <= base_damage or float(base_hp) / float(base_max) <= 0.3


func _risk_ping_structure_threat(threat: Dictionary) -> Dictionary:
	var tile: Vector2i = threat.get("tile", Vector2i(-1, -1))
	var structure: Dictionary = structures.get(_tile_key(tile), {})
	if structure.is_empty():
		return {
			"ok": false,
			"will_break": false,
			"planned_collapse": false,
		}

	var enemy_data = _enemy_data_by_id(str(threat.get("enemy_id", _default_enemy_id())))
	var incoming_damage = max(0, int(enemy_data.get("structureDamage", 0)))
	if str(threat.get("action", "")) == "boss_siege":
		incoming_damage = max(incoming_damage, int(enemy_data.get("siegeGazeDamage", 0)))

	var hp = int(structure.get("hp", 0))
	var will_break = incoming_damage > 0 and hp - incoming_damage <= 0
	var effects = get_class_effects(str(structure.get("class_id", "")))
	var planned_collapse = will_break and str(structure.get("type", "")) == "barricade" and int(effects.get("barricadeDeathDamage", 0)) > 0
	return {
		"ok": true,
		"will_break": will_break,
		"planned_collapse": planned_collapse,
		"incoming_damage": incoming_damage,
		"hp": hp,
	}


func _highest_priority_wave_intent(intents: Array[Dictionary]) -> Dictionary:
	var best_intent: Dictionary = {}
	var best_score = -999999
	var best_id = 999999
	for intent in intents:
		var score = _wave_tactical_intent_score(intent)
		var enemy_id = int(intent.get("enemy_instance_id", 999999))
		if score > best_score or (score == best_score and enemy_id < best_id):
			best_intent = intent
			best_score = score
			best_id = enemy_id

	return best_intent


func _wave_tactical_intent_score(intent: Dictionary) -> int:
	var score = 0
	match str(intent.get("action", "wait")):
		"hit_base":
			score = 1000
		"boss_siege":
			score = 900
		"attack_structure":
			score = 800
		"break_path":
			score = 700
		"move":
			score = 400
		_:
			score = 100

	if bool(intent.get("boss", false)):
		score += 175

	return score


func _wave_tactical_severity(action: String) -> String:
	match action:
		"hit_base":
			return "base"
		"boss_siege":
			return "boss"
		"attack_structure":
			return "structure"
		"break_path":
			return "break"
		"move":
			return "advance"
		_:
			return "watch"


func _wave_tactical_headline(intent: Dictionary) -> String:
	var action = str(intent.get("action", "wait"))
	var enemy_label = _wave_tactical_enemy_label(intent)
	var source_tile: Vector2i = intent.get("source_tile", Vector2i.ZERO)
	var target_tile: Vector2i = intent.get("tile", source_tile)
	match action:
		"hit_base":
			return "%s will hit base from %s" % [enemy_label, _format_tile(target_tile)]
		"boss_siege":
			return "%s is targeting %s at %s" % [
				enemy_label,
				intent.get("target_type", "structure"),
				_format_tile(target_tile),
			]
		"attack_structure":
			return "%s will hit %s at %s" % [
				enemy_label,
				intent.get("target_type", "structure"),
				_format_tile(target_tile),
			]
		"break_path":
			return "%s is pressuring path toward %s" % [
				enemy_label,
				_format_tile(intent.get("target_tile", target_tile)),
			]
		"move":
			return "%s will move %s -> %s" % [
				enemy_label,
				_format_tile(source_tile),
				_format_tile(target_tile),
			]
		_:
			return "%s is waiting at %s" % [enemy_label, _format_tile(source_tile)]


func _wave_tactical_suggestion(intent: Dictionary, card_hint: String) -> String:
	var has_card_answer = not card_hint.is_empty() and not card_hint.begins_with("Card hint: no")
	match str(intent.get("action", "wait")):
		"hit_base":
			return "stop this enemy now" if has_card_answer else "expect base damage on the next step"
		"boss_siege":
			return "focus boss damage" if has_card_answer else "prepare to repair or replace the target"
		"attack_structure":
			return "use damage before the hit" if has_card_answer else "repair after the hit or reinforce nearby"
		"break_path":
			return "damage the breaker before it opens the path" if has_card_answer else "prepare to rebuild the broken lane"
		"move":
			return "let towers fire, then spend cards if it reaches a weak tile"
		_:
			return "step once and re-check intent"


func _wave_tactical_enemy_label(intent: Dictionary) -> String:
	var enemy_id = str(intent.get("enemy_id", _default_enemy_id()))
	var enemy_data = _enemy_data_by_id(enemy_id)
	var label = str(enemy_data.get("label", enemy_id))
	var prefix = "Boss " if bool(intent.get("boss", false)) else "Enemy "
	return "%s%s #%s" % [prefix, label, intent.get("enemy_instance_id", "?")]


func _wave_tactical_card_hint(intent: Dictionary, class_id: String) -> String:
	var damage_hint = _wave_tactical_damage_card_hint(intent, class_id)
	if not damage_hint.is_empty():
		return damage_hint

	var repair_hint = _wave_tactical_repair_card_hint(class_id)
	if not repair_hint.is_empty():
		return repair_hint

	var draw_hint = _wave_tactical_draw_card_hint(class_id)
	if not draw_hint.is_empty():
		return draw_hint

	return "Card hint: no direct answer in hand"


func _wave_tactical_idle_card_hint(class_id: String) -> String:
	var draw_hint = _wave_tactical_draw_card_hint(class_id)
	if not draw_hint.is_empty():
		return draw_hint

	return "Card hint: hold cards until enemies enter"


func _wave_tactical_damage_card_hint(intent: Dictionary, class_id: String) -> String:
	var source_tile: Vector2i = intent.get("source_tile", Vector2i.ZERO)
	var best_card_id = ""
	var best_damage = -1
	for card_id_value in hand:
		var card_id = str(card_id_value)
		var card = get_card_data(card_id)
		if str(card.get("kind", "")) != "damage_enemy":
			continue
		if int(card.get("damage", 0)) <= best_damage:
			continue

		var play_check = can_play_card_at_tile(card_id, source_tile, 1, class_id)
		if bool(play_check.get("ok", false)):
			best_card_id = card_id
			best_damage = int(card.get("damage", 0))

	if best_card_id.is_empty():
		return ""

	return "Card hint: %s can hit %s for %s" % [
		get_card_label(best_card_id),
		_format_tile(source_tile),
		best_damage,
	]


func _wave_tactical_repair_card_hint(class_id: String) -> String:
	var damaged_tile = _first_damaged_structure_tile()
	if damaged_tile == Vector2i(-1, -1):
		return ""

	var best_card_id = ""
	var best_repair = -1
	for card_id_value in hand:
		var card_id = str(card_id_value)
		var card = get_card_data(card_id)
		if str(card.get("kind", "")) != "repair_structure":
			continue
		if int(card.get("repair", 0)) <= best_repair:
			continue

		var play_check = can_play_card_at_tile(card_id, damaged_tile, 1, class_id)
		if bool(play_check.get("ok", false)):
			best_card_id = card_id
			best_repair = int(card.get("repair", 0))

	if best_card_id.is_empty():
		return ""

	return "Card hint: %s can repair %s for %s" % [
		get_card_label(best_card_id),
		_format_tile(damaged_tile),
		best_repair,
	]


func _wave_tactical_draw_card_hint(class_id: String) -> String:
	for card_id_value in hand:
		var card_id = str(card_id_value)
		var card = get_card_data(card_id)
		if str(card.get("kind", "")) != "draw_cards":
			continue

		var play_check = can_play_card(card_id, class_id)
		if bool(play_check.get("ok", false)):
			return "Card hint: %s can draw now" % get_card_label(card_id)

	return ""


func _first_damaged_structure_tile() -> Vector2i:
	for structure in structures.values():
		if typeof(structure) != TYPE_DICTIONARY:
			continue

		var structure_entry: Dictionary = structure
		if int(structure_entry.get("hp", 0)) < int(structure_entry.get("max_hp", 0)):
			return structure_entry.get("tile", Vector2i(-1, -1))

	return Vector2i(-1, -1)


func _format_tile(tile: Vector2i) -> String:
	return "(%s,%s)" % [tile.x, tile.y]


func _format_card_target_summary(card_id: String, card: Dictionary, valid_count: int, invalid_count: int, reason_counts: Dictionary) -> String:
	var blocked_parts = PackedStringArray()
	for reason in _top_reason_keys(reason_counts, 3):
		blocked_parts.append("%s=%s" % [reason, reason_counts[reason]])

	var blocked_text = ", ".join(blocked_parts) if not blocked_parts.is_empty() else "none"
	return "%s targets: valid=%s blocked=%s (%s)" % [
		card.get("label", card_id),
		valid_count,
		invalid_count,
		blocked_text,
	]


func _reward_recommendation_score(card_id: String, player_count: int, class_id: String) -> int:
	var card = get_card_data(card_id)
	if card.is_empty():
		return -999999

	var score = _reward_card_strength_score(card_id)
	var kind = str(card.get("kind", ""))
	var target_damage_count = clamp(player_count, 1, 4)
	var damage_deck_count = _deck_kind_count("damage_enemy")

	if kind == "damage_enemy":
		if damage_deck_count < target_damage_count:
			score += 1000 + int(card.get("damage", 0)) * 50
		elif damage_deck_count < max(2, target_damage_count) and int(card.get("damage", 0)) >= 4:
			score += 400
	elif kind == "repair_structure":
		if _deck_kind_count("repair_structure") <= 0:
			score += 260
		if _count_damaged_structures() > 0:
			score += 180
	elif kind == "draw_cards":
		if _deck_kind_count("draw_cards") <= 0:
			score += 220
	elif kind == "place_structure":
		var structure_type = str(card.get("structureType", ""))
		if structure_type == "tower" and _deck_structure_type_count("tower") < player_count + 1:
			score += 180
		elif structure_type == "barricade" and _deck_structure_type_count("barricade") < player_count + 2:
			score += 160

	score += _class_priority_reward_bonus(card_id, class_id)
	score -= get_card_deck_count(card_id) * 15
	return score


func _reward_recommendation_reason(card_id: String, player_count: int, class_id: String) -> String:
	var card = get_card_data(card_id)
	if card.is_empty():
		return "unknown card"

	var kind = str(card.get("kind", ""))
	var damage_deck_count = _deck_kind_count("damage_enemy")
	var target_damage_count = clamp(player_count, 1, 4)
	if kind == "damage_enemy" and damage_deck_count < target_damage_count:
		return "fills damage coverage %s/%s active fronts" % [
			damage_deck_count,
			target_damage_count,
		]
	if kind == "damage_enemy" and int(card.get("damage", 0)) >= 4:
		return "adds heavy boss damage"
	if _class_priority_reward_bonus(card_id, class_id) > 0:
		return "matches %s plan" % get_class_label(class_id)
	if kind == "repair_structure" and _deck_kind_count("repair_structure") <= 0:
		return "adds first repair option"
	if kind == "repair_structure" and _count_damaged_structures() > 0:
		return "helps stabilize damaged structures"
	if kind == "draw_cards" and _deck_kind_count("draw_cards") <= 0:
		return "adds first draw option"
	if kind == "place_structure":
		return "adds %s setup consistency" % str(card.get("structureType", "structure"))

	return "best overall value in this offer"


func _reward_recommendation_detail(card_id: String, player_count: int, class_id: String, reason_text: String = "") -> String:
	var card = get_card_data(card_id)
	if card.is_empty():
		return "No card context available."

	var active_directions = get_active_directions(player_count)
	var front_text = _join_values(active_directions)
	if front_text.is_empty():
		front_text = "none"

	var counts = get_deck_zone_counts()
	var current_copies = get_card_deck_count(card_id)
	var deck_total = int(counts.get("total_count", 0))
	var detail_reason = reason_text
	if detail_reason.is_empty():
		detail_reason = _reward_recommendation_reason(card_id, player_count, class_id)

	var parts = PackedStringArray()
	parts.append("Need: %s" % detail_reason)
	parts.append("Fronts: %s active (%s)" % [
		active_directions.size(),
		front_text,
	])
	parts.append("Deck: %s cards, %s copies %s -> %s" % [
		deck_total,
		get_card_label(card_id),
		current_copies,
		current_copies + 1,
	])
	parts.append("Gold option: %s" % get_card_reward_gold_choice_summary())
	return " | ".join(parts)


func _reward_gold_recommendation_candidate(player_count: int, class_id: String) -> Dictionary:
	var gold_gain = get_card_reward_gold()
	if gold_gain <= 0:
		return {"ok": false, "reason": "gold_choice_unavailable"}

	var reason_text = _reward_gold_recommendation_reason(player_count, class_id)
	return {
		"ok": true,
		"reason": "ok",
		"choice_type": "gold",
		"card_id": "",
		"label": _reward_gold_label(),
		"index": -1,
		"score": _reward_gold_recommendation_score(player_count, class_id),
		"gold_gain": gold_gain,
		"reason_text": reason_text,
		"detail_text": _reward_gold_recommendation_detail(player_count, class_id, reason_text),
	}


func _reward_gold_label() -> String:
	var gold_gain = get_card_reward_gold()
	if gold_gain > 0:
		return "Take gold +%s" % gold_gain

	return "Take gold"


func _reward_gold_recommendation_score(player_count: int, class_id: String) -> int:
	var gold_gain = get_card_reward_gold()
	if gold_gain <= 0:
		return -999999

	var score = 40 + gold_gain * 35
	var deck_total = int(get_deck_zone_counts().get("total_count", 0))
	var deck_watch_count = _reward_gold_deck_watch_count(player_count)
	if deck_total >= deck_watch_count:
		score += 160 + max(0, deck_total - deck_watch_count) * 35

	if _reward_core_coverage_is_stable(player_count):
		score += 240
	else:
		score -= 800

	var gold_cost = get_shop_deck_removal_gold_cost()
	var gold_after = gold + gold_gain
	if gold_cost > 0:
		if gold < gold_cost and gold_after >= gold_cost:
			score += 900
		elif gold_after >= max(0, gold_cost - 1):
			score += 220
		elif gold >= gold_cost:
			score += 160

	return score


func _reward_gold_recommendation_reason(player_count: int, class_id: String) -> String:
	var gold_gain = get_card_reward_gold()
	var gold_cost = get_shop_deck_removal_gold_cost()
	var gold_after = gold + gold_gain
	if gold_cost > 0 and gold < gold_cost and gold_after >= gold_cost and _reward_core_coverage_is_stable(player_count):
		return "funds the next shop trim"

	if _reward_core_coverage_is_stable(player_count) and int(get_deck_zone_counts().get("total_count", 0)) >= _reward_gold_deck_watch_count(player_count):
		return "keeps a stable deck lean"

	if _reward_core_coverage_is_stable(player_count):
		return "banks gold without adding deck weight"

	return "gold is available, but card coverage is still thin"


func _reward_gold_recommendation_detail(player_count: int, class_id: String, reason_text: String = "") -> String:
	var target_damage_count = clamp(player_count, 1, 4)
	var detail_reason = reason_text
	if detail_reason.is_empty():
		detail_reason = _reward_gold_recommendation_reason(player_count, class_id)

	var parts = PackedStringArray()
	parts.append("Need: %s" % detail_reason)
	parts.append("Coverage: damage %s/%s, repair %s, draw %s, towers %s, barricades %s" % [
		_deck_kind_count("damage_enemy"),
		target_damage_count,
		_deck_kind_count("repair_structure"),
		_deck_kind_count("draw_cards"),
		_deck_structure_type_count("tower"),
		_deck_structure_type_count("barricade"),
	])
	parts.append(get_card_reward_gold_choice_summary())
	return " | ".join(parts)


func _reward_core_coverage_is_stable(player_count: int) -> bool:
	var target_damage_count = clamp(player_count, 1, 4)
	return (
		_deck_kind_count("damage_enemy") >= target_damage_count
		and _deck_kind_count("repair_structure") > 0
		and _deck_kind_count("draw_cards") > 0
		and _deck_structure_type_count("tower") >= max(1, player_count)
		and _deck_structure_type_count("barricade") >= max(1, player_count)
	)


func _reward_gold_deck_watch_count(player_count: int) -> int:
	return max(8, 5 + clamp(player_count, 1, 4) * 2)


func _reward_card_strength_score(card_id: String) -> int:
	var card = get_card_data(card_id)
	var score = 0
	match str(card.get("kind", "")):
		"damage_enemy":
			score += int(card.get("damage", 0)) * 100
		"repair_structure":
			score += int(card.get("repair", 0)) * 20
		"draw_cards":
			score += int(card.get("draw", 0)) * 50
		"place_structure":
			score += 80 if str(card.get("structureType", "")) == "tower" else 60

	score -= int(card.get("cost", 0)) * 5
	match get_card_rarity(card_id):
		"rare":
			score += 12
		"uncommon":
			score += 6

	return score


func _artifact_recommendation_score(artifact_id: String) -> int:
	var artifact = get_artifact_data(artifact_id)
	if artifact.is_empty():
		return -999999

	var score = 0
	if equipped_artifacts.has(artifact_id):
		score -= 100000

	var effects: Dictionary = artifact.get("effects", {})
	for effect_key in effects.keys():
		var value = int(effects.get(effect_key, 0))
		match str(effect_key):
			"seedManaBonus":
				score += 500 * max(1, value)
			"manaPerKillBonus":
				score += 420 * max(1, value)
			"drawGaugePerKillBonus":
				score += 380 * max(1, value)
			"maxHandBonus":
				score += 340 * max(1, value)
			"waveStackLimitBonus":
				score += 260 * max(1, value)
			"artifactSlotBonus":
				score += 240 * max(1, value)
			"goldPerKillBonus":
				score += 220 * max(1, value)
			_:
				if value > 0:
					score += 100 * value

	return score


func _artifact_recommendation_reason(artifact_id: String) -> String:
	var artifact = get_artifact_data(artifact_id)
	var effects: Dictionary = artifact.get("effects", {})
	if effects.has("seedManaBonus"):
		return "adds safer round starts"
	if effects.has("manaPerKillBonus"):
		return "turns kills into more plays"
	if effects.has("drawGaugePerKillBonus"):
		return "keeps the deck cycling during dense waves"
	if effects.has("maxHandBonus"):
		return "keeps combo hands open"
	if effects.has("waveStackLimitBonus"):
		return "opens future wave stacking pressure"
	if effects.has("artifactSlotBonus"):
		return "delays a future artifact replacement decision"
	if effects.has("goldPerKillBonus"):
		return "accelerates shop trimming"
	return "best party passive in this offer"


func _artifact_recommendation_detail(artifact_id: String, reason_text: String = "") -> String:
	var artifact = get_artifact_data(artifact_id)
	if artifact.is_empty():
		return "No artifact context available."

	var detail_reason = reason_text
	if detail_reason.is_empty():
		detail_reason = _artifact_recommendation_reason(artifact_id)

	var effects: Dictionary = artifact.get("effects", {})
	var effect_parts = PackedStringArray()
	var effect_keys: Array = effects.keys()
	effect_keys.sort()
	for effect_key_value in effect_keys:
		var effect_key = str(effect_key_value)
		var value = int(effects.get(effect_key, 0))
		effect_parts.append("%s +%s" % [
			_artifact_effect_detail_label(effect_key),
			value,
		])
	if effect_parts.is_empty():
		effect_parts.append("party passive")

	return "Need: %s | Equipped: %s | Loadout: %s | Effect: %s | %s" % [
		detail_reason,
		get_equipped_artifact_summary(),
		get_artifact_loadout_summary(),
		", ".join(effect_parts),
		get_economy_summary(),
	]


func _artifact_effect_detail_label(effect_key: String) -> String:
	match effect_key:
		"seedManaBonus":
			return "seed mana"
		"manaPerKillBonus":
			return "mana per kill"
		"drawGaugePerKillBonus":
			return "draw gauge per kill"
		"maxHandBonus":
			return "max hand"
		"waveStackLimitBonus":
			return "wave stack limit"
		"artifactSlotBonus":
			return "artifact slot"
		"goldPerKillBonus":
			return "gold per kill"
		_:
			return effect_key


func _artifact_to_wave_reminder(artifact_id: String, next_role: String, direction_text: String) -> String:
	var artifact = get_artifact_data(artifact_id)
	var effects: Dictionary = artifact.get("effects", {})
	if effects.has("seedManaBonus"):
		return "spend the higher seed mana on an earlier tower or barricade for %s" % direction_text
	if effects.has("maxHandBonus"):
		return "hold one more cheap answer while preparing for %s on %s" % [
			next_role,
			direction_text,
		]
	if effects.has("manaPerKillBonus"):
		return "turn the first kills into faster mana loops before %s snowballs" % next_role
	if effects.has("drawGaugePerKillBonus"):
		return "use the first kill zone to refill answers against %s" % next_role
	if effects.has("goldPerKillBonus"):
		return "bank extra kill gold without treating the next pull as a reward boost"
	if effects.has("waveStackLimitBonus"):
		return "only pull faster if the front is stable; the artifact adds tempo, not bonus rewards"
	if effects.has("artifactSlotBonus"):
		return "use the extra slot to keep one more identity piece, not to avoid future replacement talks"

	return "carry this passive into the %s pressure on %s" % [
		next_role,
		direction_text,
	]


func _shop_removal_recommendation_score(card_id: String, player_count: int, class_id: String) -> int:
	var card = get_card_data(card_id)
	if card.is_empty():
		return -999999

	var score = 500 - _reward_card_strength_score(card_id)
	var deck_count = get_card_deck_count(card_id)
	if deck_count > 1:
		score += deck_count * 120
	else:
		score -= 140

	score -= _class_priority_reward_bonus(card_id, class_id)
	score += int(card.get("cost", 0)) * 12

	match get_card_rarity(card_id):
		"rare":
			score -= 120
		"uncommon":
			score -= 50

	var kind = str(card.get("kind", ""))
	var active_fronts = clamp(player_count, 1, 4)
	match kind:
		"damage_enemy":
			if _deck_kind_count("damage_enemy") <= active_fronts:
				score -= 900
			elif int(card.get("damage", 0)) <= 2:
				score += 120
		"repair_structure":
			if _deck_kind_count("repair_structure") <= 1:
				score -= 520
		"draw_cards":
			if _deck_kind_count("draw_cards") <= 1:
				score -= 440
		"place_structure":
			var structure_type = str(card.get("structureType", ""))
			if structure_type == "tower" and _deck_structure_type_count("tower") <= active_fronts + 1:
				score -= 420
			elif structure_type == "barricade" and _deck_structure_type_count("barricade") <= active_fronts + 2:
				score -= 360
			elif structure_type == "barricade":
				score += 80

	return score


func _shop_removal_recommendation_reason(card_id: String, player_count: int, class_id: String) -> String:
	var card = get_card_data(card_id)
	if card.is_empty():
		return "unknown card"

	var deck_count = get_card_deck_count(card_id)
	var kind = str(card.get("kind", ""))
	var active_fronts = clamp(player_count, 1, 4)
	if kind == "damage_enemy" and _deck_kind_count("damage_enemy") <= active_fronts:
		return "keep scarce damage coverage"
	if kind == "repair_structure" and _deck_kind_count("repair_structure") <= 1:
		return "keep scarce repair coverage"
	if kind == "draw_cards" and _deck_kind_count("draw_cards") <= 1:
		return "keep scarce draw coverage"
	if kind == "place_structure":
		var structure_type = str(card.get("structureType", ""))
		if structure_type == "tower" and _deck_structure_type_count("tower") <= active_fronts + 1:
			return "tower setup is still thin"
		if structure_type == "barricade" and _deck_structure_type_count("barricade") <= active_fronts + 2:
			return "barricade setup is still thin"
	if deck_count > 1:
		return "trims a duplicate copy"
	if _class_priority_reward_bonus(card_id, class_id) <= 0:
		return "removes a low-priority card"
	return "least costly trim in this offer"


func _shop_removal_recommendation_detail(card_id: String, player_count: int, class_id: String, reason_text: String = "") -> String:
	var card = get_card_data(card_id)
	if card.is_empty():
		return "No shop context available."

	var detail_reason = reason_text
	if detail_reason.is_empty():
		detail_reason = _shop_removal_recommendation_reason(card_id, player_count, class_id)

	var active_directions = get_active_directions(player_count)
	var front_text = _join_values(active_directions)
	if front_text.is_empty():
		front_text = "none"

	var deck_counts = get_deck_zone_counts()
	var card_count = get_card_deck_count(card_id)
	var gold_cost = get_shop_deck_removal_gold_cost()
	var gold_after = max(0, gold - gold_cost) if gold >= gold_cost else gold
	return "Need: %s | Fronts: %s active (%s) | Deck: %s cards, %s copies %s -> %s | Gold: %s -> %s, next trim %s | Class: %s" % [
		detail_reason,
		active_directions.size(),
		front_text,
		deck_counts.get("total_count", 0),
		get_card_label(card_id),
		card_count,
		max(0, card_count - 1),
		gold,
		gold_after,
		get_shop_trim_gold_progress_summary(gold_after),
		get_class_label(class_id) if not class_id.is_empty() else "none",
	]


func _shop_service_recommendation_score(service_id: String) -> int:
	var report = get_shop_service_report(service_id)
	if not bool(report.get("can_buy", false)):
		return -999999

	var service_type = str(report.get("service_type", ""))
	if service_type == "restore_base":
		var base_damage = int(report.get("base_damage", 0))
		var heal = int(report.get("heal", 0))
		var score = 660 + (min(base_damage, heal) * 90) + (base_damage * 25)
		if _base_hp_percent() <= 0.3:
			score += 320
		return score

	if service_type == "structure_hp_boost":
		var score = 610 + (int(report.get("affected_structures", 0)) * 45)
		score += _count_damaged_structures() * 80
		score += _count_critical_structures() * 140
		return score

	if service_type == "reactivate_dormant_artifact":
		var score = 640 + (get_dormant_artifacts().size() * 25)
		if not str(report.get("replaced_artifact_id", "")).is_empty():
			score += 35
		return score

	return -999999


func _shop_service_recommendation_reason(service_id: String) -> String:
	var report = get_shop_service_report(service_id)
	var service_type = str(report.get("service_type", ""))
	if service_type == "restore_base":
		if _base_hp_percent() <= 0.3:
			return "prevents a low-base collapse"
		return "repairs boss chip damage"

	if service_type == "structure_hp_boost":
		if _count_critical_structures() > 0:
			return "keeps critical structures standing"
		if _count_damaged_structures() > 0:
			return "stabilizes damaged structures"
		return "thickens the existing kill zone"

	if service_type == "reactivate_dormant_artifact":
		return "restores a dormant party passive for the next stretch"

	return _short_reject_reason(str(report.get("reason", "blocked")))


func _shop_service_recommendation_detail(service_id: String, reason_text: String = "") -> String:
	var report = get_shop_service_report(service_id)
	if not bool(report.get("ok", false)):
		return "No shop context available."

	var detail_reason = reason_text
	if detail_reason.is_empty():
		detail_reason = _shop_service_recommendation_reason(service_id)

	if str(report.get("service_type", "")) == "reactivate_dormant_artifact":
		var replaced_text = "empty slot"
		if not str(report.get("replaced_artifact_label", "")).is_empty():
			replaced_text = "%s becomes dormant" % report.get("replaced_artifact_label", "")
		return "Need: %s | Boss shards: %s -> %s | Reactivate: %s | Swap: %s | Loadout: %s | Effect: %s" % [
			detail_reason,
			report.get("boss_shards", 0),
			report.get("boss_shards_after", report.get("boss_shards", 0)),
			report.get("dormant_artifact_label", "?"),
			replaced_text,
			report.get("loadout_summary", get_artifact_loadout_summary()),
			report.get("purchase_preview", report.get("summary", "")),
		]

	return "Need: %s | Base: %s/%s -> %s/%s | Structures: %s active, %s damaged, %s critical | Gold: %s -> %s | Effect: %s" % [
		detail_reason,
		report.get("base_hp", 0),
		report.get("base_max_hp", 0),
		report.get("base_hp_after", report.get("base_hp", 0)),
		report.get("base_max_hp", 0),
		report.get("affected_structures", 0),
		_count_damaged_structures(),
		_count_critical_structures(),
		report.get("gold", 0),
		report.get("gold_after", report.get("gold", 0)),
		report.get("purchase_preview", report.get("summary", "")),
	]


func _short_reject_reason(reason: String) -> String:
	match reason:
		"not_enough_gold":
			return "No gold"
		"not_enough_boss_shards":
			return "No boss shard"
		"no_shop_offer":
			return "No shop offer"
		"shop_card_not_offered":
			return "Not offered"
		"shop_service_not_offered":
			return "Not offered"
		"shop_purchase_unavailable":
			return "Purchase used"
		"shop_removal_unavailable":
			return "Removal used"
		"reward_choice_pending":
			return "Resolve reward"
		"card_not_in_deck":
			return "Not in deck"
		"base_full":
			return "Base full"
		"no_structures":
			return "No structures"
		"no_dormant_artifact":
			return "No dormant"
		"no_equipped_artifact":
			return "No equipped artifact"
		"shop_service_disabled":
			return "Disabled"
		"unknown_shop_service":
			return "Unknown service"
		"unknown_shop_service_type":
			return "Unknown service"
		_:
			return reason.capitalize().replace("_", " ")


func _class_priority_reward_bonus(card_id: String, class_id: String) -> int:
	if class_id.is_empty():
		return 0

	var priority: Array = get_class_autoplay_profile(class_id).get("cardPriority", [])
	for index in range(priority.size()):
		if str(priority[index]) == card_id:
			return max(20, 220 - index * 20)

	return 0


func _deck_kind_count(kind: String) -> int:
	var count = 0
	for card_id in _all_deck_card_ids():
		if str(get_card_data(str(card_id)).get("kind", "")) == kind:
			count += 1

	return count


func _deck_structure_type_count(structure_type: String) -> int:
	var count = 0
	for card_id in _all_deck_card_ids():
		var card = get_card_data(str(card_id))
		if str(card.get("kind", "")) == "place_structure" and str(card.get("structureType", "")) == structure_type:
			count += 1

	return count


func _all_deck_card_ids() -> Array:
	var ids: Array = []
	for source in [hand, draw_pile, discard_pile]:
		for card_id in source:
			ids.append(str(card_id))

	return ids


func _should_show_invalid_card_target(kind: String, reason: String) -> bool:
	match kind:
		"place_structure":
			return [
				"base_tile_blocked",
				"entrance_tile_blocked",
				"tile_occupied",
			].has(reason) or reason.begins_with("would_fully_block")
		"repair_structure":
			return reason == "structure_not_damaged"
		_:
			return false


func _top_reason_keys(reason_counts: Dictionary, limit: int) -> Array[String]:
	var keys: Array[String] = []
	for key in reason_counts.keys():
		keys.append(str(key))

	keys.sort_custom(func(left: String, right: String) -> bool:
		var left_count = int(reason_counts.get(left, 0))
		var right_count = int(reason_counts.get(right, 0))
		if left_count == right_count:
			return left < right
		return left_count > right_count
	)

	if keys.size() > limit:
		keys.resize(limit)

	return keys


func _front_pressure_severity(enemy_count: int, nearest_steps: int, boss_count: int = 0) -> String:
	if enemy_count <= 0:
		return "idle"

	if boss_count > 0:
		return "critical"

	if nearest_steps >= 0 and nearest_steps <= 3:
		return "critical"

	if enemy_count >= 4 or (nearest_steps >= 0 and nearest_steps <= 6):
		return "danger"

	return "watch"


func _format_front_pressure(direction: String, enemy_count: int, nearest_steps: int, boss_count: int = 0) -> String:
	if enemy_count <= 0:
		return "%s clear" % direction

	var nearest_text = "blocked" if nearest_steps < 0 else "%s steps" % nearest_steps
	var boss_text = ""
	if boss_count > 0:
		boss_text = " boss %s" % boss_count
	return "%s %s enemy%s nearest %s" % [direction, enemy_count, boss_text, nearest_text]


func _find_nearest_enemy_index(tile: Vector2i, max_range: int) -> int:
	var best_index = -1
	var best_distance = 999999

	for index in range(enemies.size()):
		var enemy_tile: Vector2i = enemies[index]["tile"]
		var distance = abs(enemy_tile.x - tile.x) + abs(enemy_tile.y - tile.y)
		if distance <= max_range and distance < best_distance:
			best_index = index
			best_distance = distance

	return best_index


func _find_enemy_index_at_tile(tile: Vector2i) -> int:
	for index in range(enemies.size()):
		if enemies[index]["tile"] == tile:
			return index

	return -1


func _find_enemy_index_by_id(enemy_id: int) -> int:
	for index in range(enemies.size()):
		if int(enemies[index]["id"]) == enemy_id:
			return index

	return -1


func _damage_enemy_at_index(enemy_index: int, damage: int, events: Array[String], source_label: String, stat_key: String = "", event_type: String = "hit") -> bool:
	if damage <= 0 or enemy_index < 0 or enemy_index >= enemies.size():
		return false

	var enemy = enemies[enemy_index]
	var applied_damage = _apply_enemy_damage_reduction(enemy, damage, events)
	if applied_damage <= 0:
		return false

	enemy["hp"] = int(enemy["hp"]) - applied_damage
	enemies[enemy_index] = enemy
	events.append("%s hit %s for %s. HP: %s." % [
		source_label,
		_enemy_display_name(enemy),
		applied_damage,
		max(0, int(enemy["hp"])),
	])

	if not stat_key.is_empty():
		run_stats[stat_key] = int(run_stats.get(stat_key, 0)) + applied_damage

	if _is_boss_enemy(enemy):
		enemy = _apply_boss_part_damage(enemy, applied_damage, events, source_label)
		enemies[enemy_index] = enemy

	recent_event_tiles[_tile_key(enemy["tile"])] = event_type
	_try_boss_phase_pulse(enemy_index, events)
	if int(enemy["hp"]) > 0:
		return false

	events.append("%s killed." % _enemy_display_name(enemy))
	run_stats["killed"] = int(run_stats.get("killed", 0)) + 1
	_increment_bucket_stat("killed_by_enemy_id", str(enemy.get("enemy_id", _default_enemy_id())), 1)
	if _is_boss_enemy(enemy):
		run_stats["bosses_killed"] = int(run_stats.get("bosses_killed", 0)) + 1
		boss_reward_pending = true
	recent_event_tiles[_tile_key(enemy["tile"])] = "kill"
	_grant_kill_rewards(events, enemy)
	enemies.remove_at(enemy_index)
	return true


func _damage_enemy_by_id(enemy_id: int, damage: int, events: Array[String], source_label: String, stat_key: String = "", event_type: String = "hit") -> bool:
	var enemy_index = _find_enemy_index_by_id(enemy_id)
	if enemy_index < 0:
		return false

	return _damage_enemy_at_index(enemy_index, damage, events, source_label, stat_key, event_type)


func _initial_boss_parts(enemy_data: Dictionary) -> Dictionary:
	if not bool(enemy_data.get("boss", false)):
		return {}

	var parts = {}
	for part_value in enemy_data.get("bossParts", []):
		if typeof(part_value) != TYPE_DICTIONARY:
			continue

		var part_data: Dictionary = part_value
		var part_id = str(part_data.get("id", ""))
		if part_id.is_empty():
			continue

		var hp = max(1, int(part_data.get("hp", 1)))
		var effects: Dictionary = part_data.get("effects", {})
		parts[part_id] = {
			"id": part_id,
			"label": str(part_data.get("label", part_id)),
			"hp": hp,
			"max_hp": hp,
			"priority": int(part_data.get("priority", 999)),
			"effects": effects.duplicate(true),
		}

	return parts


func _boss_sorted_parts(enemy: Dictionary) -> Array:
	var parts: Array = []
	var part_map: Dictionary = enemy.get("boss_parts", {})
	for part_id in part_map.keys():
		var part_value = part_map.get(part_id, {})
		if typeof(part_value) == TYPE_DICTIONARY:
			parts.append(part_value)

	parts.sort_custom(func(left, right) -> bool:
		var left_priority = int(left.get("priority", 999))
		var right_priority = int(right.get("priority", 999))
		if left_priority == right_priority:
			return str(left.get("id", "")) < str(right.get("id", ""))
		return left_priority < right_priority
	)
	return parts


func _boss_focus_part_id(enemy: Dictionary) -> String:
	for part in _boss_sorted_parts(enemy):
		if int(part.get("hp", 0)) > 0:
			return str(part.get("id", ""))

	return ""


func _boss_focus_part_report_for_enemy(enemy: Dictionary) -> Dictionary:
	if not _is_boss_enemy(enemy):
		return _reject("not_boss")

	var part_map: Dictionary = enemy.get("boss_parts", {})
	if part_map.is_empty():
		return _reject("no_boss_parts")

	var focus_part_id = _boss_focus_part_id(enemy)
	if focus_part_id.is_empty() or not part_map.has(focus_part_id):
		return _reject("no_focus_part")

	var part: Dictionary = part_map[focus_part_id]
	var label = str(part.get("label", focus_part_id))
	var hp = int(part.get("hp", 0))
	var max_hp = int(part.get("max_hp", 0))
	var effect_summary = _boss_part_effect_summary(part)
	return {
		"ok": true,
		"reason": "ok",
		"enemy_id": int(enemy.get("id", -1)),
		"boss_enemy_id": str(enemy.get("enemy_id", "")),
		"boss_label": str(_enemy_data(enemy).get("label", "Boss")),
		"tile": enemy.get("tile", Vector2i.ZERO),
		"part_id": focus_part_id,
		"label": label,
		"hp": hp,
		"max_hp": max_hp,
		"priority": int(part.get("priority", 0)),
		"effect_summary": effect_summary,
		"summary": "Boss focus: %s %s/%s - %s" % [
			label,
			hp,
			max_hp,
			effect_summary,
		],
	}


func _boss_part_warning_report_for_enemy(enemy: Dictionary, blocked: Dictionary) -> Dictionary:
	var focus_report = _boss_focus_part_report_for_enemy(enemy)
	if not bool(focus_report.get("ok", false)):
		return focus_report

	var gaze_report = _boss_gaze_part_warning_report(enemy, focus_report)
	if bool(gaze_report.get("ok", false)):
		return gaze_report

	var stride_report = _boss_stride_part_warning_report(enemy, focus_report, blocked)
	if bool(stride_report.get("ok", false)):
		return stride_report

	var opportunity_report = _boss_part_opportunity_warning_report(enemy, focus_report)
	if bool(opportunity_report.get("ok", false)):
		return opportunity_report

	return _reject("no_boss_part_warning")


func _boss_gaze_part_warning_report(enemy: Dictionary, focus_report: Dictionary) -> Dictionary:
	var gaze_part = _boss_first_alive_part_with_any_effect(enemy, [
		"siegeGazeIntervalBonus",
		"siegeGazeDamageReduction",
	])
	if gaze_part.is_empty():
		return _reject("no_gaze_part")

	var enemy_data = _enemy_data(enemy)
	var interval = _boss_siege_interval(enemy)
	var damage = _boss_siege_damage(enemy)
	var siege_range = int(enemy_data.get("siegeGazeRange", 0))
	if interval <= 0 or damage <= 0 or siege_range <= 0:
		return _reject("no_gaze_pattern")

	var target_key = _find_boss_siege_target_key(enemy.get("tile", Vector2i.ZERO), siege_range)
	if target_key.is_empty():
		return _reject("no_gaze_target")

	var steps_until_gaze = max(1, interval - int(enemy.get("siege_gaze_charge", 0)))
	var focus_label = str(focus_report.get("label", "part"))
	var focus_part_id = str(focus_report.get("part_id", ""))
	var danger_part_id = str(gaze_part.get("id", ""))
	var danger_label = str(gaze_part.get("label", danger_part_id))
	var severity = "critical" if steps_until_gaze <= 1 else "warning"
	var suggestion = "break %s to delay and weaken the gaze" % danger_label
	if focus_part_id != danger_part_id:
		suggestion = "break %s to open %s before the gaze repeats" % [
			focus_label,
			danger_label,
		]

	return {
		"ok": true,
		"reason": "gaze_part_unbroken",
		"severity": severity,
		"score": 950 if steps_until_gaze <= 1 else 760,
		"enemy_id": int(enemy.get("id", -1)),
		"boss_enemy_id": str(enemy.get("enemy_id", "")),
		"tile": enemy.get("tile", Vector2i.ZERO),
		"focus_part_id": focus_part_id,
		"focus_label": focus_label,
		"danger_part_id": danger_part_id,
		"danger_label": danger_label,
		"steps_until_pattern": steps_until_gaze,
		"target_key": target_key,
		"suggestion": suggestion,
		"summary": "Boss part warning: %s; gaze in %s step(s), %s." % [
			"%s blocks %s" % [focus_label, danger_label] if focus_part_id != danger_part_id else "%s is exposed" % danger_label,
			steps_until_gaze,
			suggestion,
		],
	}


func _boss_stride_part_warning_report(enemy: Dictionary, focus_report: Dictionary, blocked: Dictionary) -> Dictionary:
	var stride_part = _boss_first_alive_part_with_any_effect(enemy, ["strideSkipEvery"])
	if stride_part.is_empty():
		return _reject("no_stride_part")

	var path = _find_path(enemy.get("tile", Vector2i.ZERO), blocked)
	var steps_to_base = path.size() - 1
	var severity = "watch"
	var score = 360
	if steps_to_base >= 0 and steps_to_base <= 2:
		severity = "critical"
		score = 820
	elif steps_to_base >= 0 and steps_to_base <= 5:
		severity = "warning"
		score = 620

	var focus_label = str(focus_report.get("label", "part"))
	return {
		"ok": true,
		"reason": "stride_part_unbroken",
		"severity": severity,
		"score": score,
		"enemy_id": int(enemy.get("id", -1)),
		"boss_enemy_id": str(enemy.get("enemy_id", "")),
		"tile": enemy.get("tile", Vector2i.ZERO),
		"focus_part_id": str(focus_report.get("part_id", "")),
		"focus_label": focus_label,
		"danger_part_id": str(stride_part.get("id", "")),
		"danger_label": str(stride_part.get("label", "Legs")),
		"steps_to_base": steps_to_base,
		"suggestion": "break %s to make future strides stall" % focus_label,
		"summary": "Boss part warning: %s unbroken; base in %s step(s), break it to slow future strides." % [
			focus_label,
			steps_to_base if steps_to_base >= 0 else "?",
		],
	}


func _boss_part_opportunity_warning_report(enemy: Dictionary, focus_report: Dictionary) -> Dictionary:
	var focus_part_id = str(focus_report.get("part_id", ""))
	var part_map: Dictionary = enemy.get("boss_parts", {})
	if focus_part_id.is_empty() or not part_map.has(focus_part_id):
		return _reject("no_focus_part")

	var focus_part: Dictionary = part_map[focus_part_id]
	var effects: Dictionary = focus_part.get("effects", {})
	if int(effects.get("drawOnBreak", 0)) <= 0:
		return _reject("no_part_opportunity")

	var focus_label = str(focus_report.get("label", "part"))
	return {
		"ok": true,
		"reason": "part_opportunity",
		"severity": "opportunity",
		"score": 280,
		"enemy_id": int(enemy.get("id", -1)),
		"boss_enemy_id": str(enemy.get("enemy_id", "")),
		"tile": enemy.get("tile", Vector2i.ZERO),
		"focus_part_id": focus_part_id,
		"focus_label": focus_label,
		"danger_part_id": focus_part_id,
		"danger_label": focus_label,
		"suggestion": "break %s if the party needs another card" % focus_label,
		"summary": "Boss part warning: %s can draw a card when broken." % focus_label,
	}


func _boss_first_alive_part_with_any_effect(enemy: Dictionary, effect_keys: Array) -> Dictionary:
	for part in _boss_sorted_parts(enemy):
		if int(part.get("hp", 0)) <= 0:
			continue

		var effects: Dictionary = part.get("effects", {})
		for effect_key_value in effect_keys:
			if int(effects.get(str(effect_key_value), 0)) > 0:
				return part

	return {}


func _apply_boss_part_damage(enemy: Dictionary, damage: int, events: Array[String], source_label: String) -> Dictionary:
	if damage <= 0:
		return enemy

	if not _is_boss_enemy(enemy):
		return enemy

	var part_map: Dictionary = enemy.get("boss_parts", {})
	if part_map.is_empty():
		return enemy

	var remaining_damage = damage
	while remaining_damage > 0:
		var part_id = _boss_focus_part_id(enemy)
		if part_id.is_empty() or not part_map.has(part_id):
			break

		var part: Dictionary = part_map[part_id]
		var old_hp = int(part.get("hp", 0))
		if old_hp <= 0:
			break

		var applied_damage = min(old_hp, remaining_damage)
		part["hp"] = old_hp - applied_damage
		part_map[part_id] = part
		enemy["boss_parts"] = part_map
		remaining_damage -= applied_damage
		run_stats["boss_part_damage"] = int(run_stats.get("boss_part_damage", 0)) + applied_damage
		_increment_bucket_stat("boss_part_damage_by_part_id", part_id, applied_damage)
		events.append("%s focused %s for %s. Part HP: %s/%s." % [
			source_label,
			part.get("label", part_id),
			applied_damage,
			max(0, int(part.get("hp", 0))),
			part.get("max_hp", 0),
		])

		if int(part.get("hp", 0)) <= 0:
			run_stats["boss_parts_destroyed"] = int(run_stats.get("boss_parts_destroyed", 0)) + 1
			_increment_bucket_stat("boss_parts_destroyed_by_part_id", part_id, 1)
			events.append("Boss part %s broke." % part.get("label", part_id))
			enemy = _apply_boss_part_break_effect(enemy, part, events)
			part_map = enemy.get("boss_parts", {})

	return enemy


func _apply_boss_part_break_effect(enemy: Dictionary, part: Dictionary, events: Array[String]) -> Dictionary:
	var effects: Dictionary = part.get("effects", {})
	var draw_count = int(effects.get("drawOnBreak", 0))
	for _index in range(draw_count):
		var draw_result = draw_card()
		if bool(draw_result.get("ok", false)):
			var card_id = str(draw_result.get("card_id", ""))
			run_stats["boss_part_draws"] = int(run_stats.get("boss_part_draws", 0)) + 1
			events.append("%s break drew %s." % [
				part.get("label", "Boss part"),
				get_card_label(card_id),
			])
		else:
			events.append("%s break draw held: %s." % [
				part.get("label", "Boss part"),
				draw_result.get("reason", "blocked"),
			])

	return enemy


func _boss_destroyed_part_effect_total(enemy: Dictionary, effect_key: String) -> int:
	var total = 0
	for part in _boss_sorted_parts(enemy):
		if int(part.get("hp", 0)) > 0:
			continue

		var effects: Dictionary = part.get("effects", {})
		total += int(effects.get(effect_key, 0))

	return total


func _boss_siege_interval(enemy: Dictionary) -> int:
	return int(_enemy_data(enemy).get("siegeGazeIntervalSteps", 0)) + _boss_destroyed_part_effect_total(enemy, "siegeGazeIntervalBonus")


func _boss_siege_damage(enemy: Dictionary) -> int:
	return max(0, int(_enemy_data(enemy).get("siegeGazeDamage", 0)) - _boss_destroyed_part_effect_total(enemy, "siegeGazeDamageReduction"))


func _try_boss_stride_slow_wait(enemy_index: int, events: Array[String]) -> bool:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return false

	var enemy = enemies[enemy_index]
	if not _is_boss_enemy(enemy):
		return false

	var skip_every = _boss_destroyed_part_effect_total(enemy, "strideSkipEvery")
	if skip_every <= 0:
		return false

	var charge = int(enemy.get("boss_stride_slow_charge", 0)) + 1
	if charge < skip_every:
		enemy["boss_stride_slow_charge"] = charge
		enemies[enemy_index] = enemy
		return false

	enemy["boss_stride_slow_charge"] = 0
	enemies[enemy_index] = enemy
	run_stats["boss_part_slow_waits"] = int(run_stats.get("boss_part_slow_waits", 0)) + 1
	recent_event_tiles[_tile_key(enemy.get("tile", Vector2i.ZERO))] = "boss_slow"
	events.append("%s loses a step after its legs break." % _enemy_display_name(enemy))
	return true


func _boss_part_effect_summary(part: Dictionary) -> String:
	var effects: Dictionary = part.get("effects", {})
	var parts = PackedStringArray()
	if int(effects.get("strideSkipEvery", 0)) > 0:
		parts.append("slows stride")
	if int(effects.get("siegeGazeIntervalBonus", 0)) > 0:
		parts.append("delays gaze")
	if int(effects.get("siegeGazeDamageReduction", 0)) > 0:
		parts.append("weakens gaze")
	if int(effects.get("drawOnBreak", 0)) > 0:
		parts.append("draws card")

	if parts.is_empty():
		return "part break"

	return ", ".join(parts)


func _try_boss_phase_pulse(enemy_index: int, events: Array[String]) -> void:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return

	var enemy = enemies[enemy_index]
	if not _is_boss_enemy(enemy):
		return

	if bool(enemy.get("phase_triggered", false)):
		return

	if int(enemy.get("hp", 0)) <= 0:
		return

	var enemy_data = _enemy_data(enemy)
	var threshold = int(enemy_data.get("phaseHpThreshold", 0))
	var pulse_damage = int(enemy_data.get("phasePulseDamage", 0))
	var pulse_radius = int(enemy_data.get("phasePulseRadius", 0))
	if threshold <= 0 or pulse_damage <= 0 or pulse_radius <= 0:
		return

	if int(enemy.get("hp", 0)) > threshold:
		return

	enemy["phase_triggered"] = true
	enemies[enemy_index] = enemy
	run_stats["boss_phase_triggers"] = int(run_stats.get("boss_phase_triggers", 0)) + 1
	recent_event_tiles[_tile_key(enemy["tile"])] = "boss_pulse"
	events.append("%s releases a pressure pulse." % _enemy_display_name(enemy))
	_apply_boss_pressure_pulse(enemy, pulse_damage, pulse_radius, events)


func _try_boss_siege_gaze(enemy_index: int, events: Array[String]) -> bool:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return false

	var enemy = enemies[enemy_index]
	if not _is_boss_enemy(enemy):
		return false

	var enemy_data = _enemy_data(enemy)
	var interval = _boss_siege_interval(enemy)
	var damage = _boss_siege_damage(enemy)
	var siege_range = int(enemy_data.get("siegeGazeRange", 0))
	if interval <= 0 or damage <= 0 or siege_range <= 0:
		return false

	var charge = int(enemy.get("siege_gaze_charge", 0)) + 1
	enemy["siege_gaze_charge"] = charge
	if charge < interval:
		enemies[enemy_index] = enemy
		return false

	var target_key = _find_boss_siege_target_key(enemy["tile"], siege_range)
	if target_key.is_empty():
		enemy["siege_gaze_charge"] = interval
		enemies[enemy_index] = enemy
		return false

	enemy["siege_gaze_charge"] = 0
	enemies[enemy_index] = enemy
	_apply_boss_siege_gaze(enemy, target_key, damage, events)
	return true


func _boss_siege_target_key_for_next_step(enemy: Dictionary) -> String:
	if not _is_boss_enemy(enemy):
		return ""

	var enemy_data = _enemy_data(enemy)
	var interval = _boss_siege_interval(enemy)
	var damage = _boss_siege_damage(enemy)
	var siege_range = int(enemy_data.get("siegeGazeRange", 0))
	if interval <= 0 or damage <= 0 or siege_range <= 0:
		return ""

	if int(enemy.get("siege_gaze_charge", 0)) + 1 < interval:
		return ""

	return _find_boss_siege_target_key(enemy.get("tile", Vector2i.ZERO), siege_range)


func _find_boss_siege_target_key(boss_tile: Vector2i, siege_range: int) -> String:
	var best_key = ""
	var best_vulnerability = -1.0
	var best_distance = 999999
	var best_hp = 999999

	for key in structures.keys():
		var structure_key = str(key)
		var structure: Dictionary = structures[structure_key]
		var structure_tile: Vector2i = structure["tile"]
		var distance = abs(structure_tile.x - boss_tile.x) + abs(structure_tile.y - boss_tile.y)
		if distance > siege_range:
			continue

		var max_hp = max(1, int(structure.get("max_hp", 1)))
		var hp = int(structure.get("hp", 0))
		var vulnerability = 1.0 - (float(hp) / float(max_hp))
		if _is_better_boss_siege_target(best_key, vulnerability, distance, hp, best_vulnerability, best_distance, best_hp):
			best_key = structure_key
			best_vulnerability = vulnerability
			best_distance = distance
			best_hp = hp

	return best_key


func _is_better_boss_siege_target(best_key: String, vulnerability: float, distance: int, hp: int, best_vulnerability: float, best_distance: int, best_hp: int) -> bool:
	if best_key.is_empty():
		return true

	var vulnerability_delta = abs(vulnerability - best_vulnerability)
	if vulnerability_delta >= 0.001:
		return vulnerability > best_vulnerability

	if distance != best_distance:
		return distance < best_distance

	return hp < best_hp


func _apply_boss_siege_gaze(enemy: Dictionary, target_key: String, damage: int, events: Array[String]) -> void:
	if not structures.has(target_key):
		return

	var structure: Dictionary = structures[target_key]
	var structure_tile: Vector2i = structure["tile"]
	var old_hp = int(structure.get("hp", 0))
	var applied_damage = min(old_hp, damage)
	structure["hp"] = old_hp - damage
	run_stats["boss_siege_triggers"] = int(run_stats.get("boss_siege_triggers", 0)) + 1
	run_stats["boss_siege_damage"] = int(run_stats.get("boss_siege_damage", 0)) + applied_damage
	recent_event_tiles[_tile_key(enemy["tile"])] = "boss_siege"
	recent_event_tiles[_tile_key(structure_tile)] = "boss_siege"
	events.append("%s fixes its gaze on %s at %s for %s. HP: %s/%s." % [
		_enemy_display_name(enemy),
		structure.get("type", "structure"),
		_tile_text(structure_tile),
		damage,
		max(0, int(structure["hp"])),
		structure.get("max_hp", 0),
	])

	if int(structure["hp"]) <= 0:
		structures.erase(target_key)
		run_stats["structures_destroyed"] = int(run_stats.get("structures_destroyed", 0)) + 1
		_increment_bucket_stat("structures_destroyed_by_direction", str(enemy.get("direction", "")), 1)
		recent_event_tiles[_tile_key(structure_tile)] = "structure_destroyed"
		events.append("%s at %s cracked under the boss gaze." % [
			str(structure.get("type", "structure")).capitalize(),
			_tile_text(structure_tile),
		])
		_apply_architect_planned_collapse(structure, structure_tile, str(enemy.get("direction", "")), events)
	else:
		structures[target_key] = structure


func _apply_boss_pressure_pulse(enemy: Dictionary, pulse_damage: int, pulse_radius: int, events: Array[String]) -> void:
	var boss_tile: Vector2i = enemy["tile"]
	var target_keys: Array[String] = []

	for key in structures.keys():
		var structure: Dictionary = structures[key]
		var structure_tile: Vector2i = structure["tile"]
		var distance = abs(structure_tile.x - boss_tile.x) + abs(structure_tile.y - boss_tile.y)
		if distance <= pulse_radius:
			target_keys.append(str(key))

	for target_key in target_keys:
		if not structures.has(target_key):
			continue

		var structure: Dictionary = structures[target_key]
		var structure_tile: Vector2i = structure["tile"]
		var old_hp = int(structure.get("hp", 0))
		var applied_damage = min(old_hp, pulse_damage)
		structure["hp"] = old_hp - pulse_damage
		run_stats["boss_pulse_damage"] = int(run_stats.get("boss_pulse_damage", 0)) + applied_damage
		recent_event_tiles[_tile_key(structure_tile)] = "boss_pulse"
		events.append("Boss pulse hit %s at %s for %s. HP: %s/%s." % [
			structure.get("type", "structure"),
			_tile_text(structure_tile),
			pulse_damage,
			max(0, int(structure["hp"])),
			structure.get("max_hp", 0),
		])

		if int(structure["hp"]) <= 0:
			structures.erase(target_key)
			run_stats["structures_destroyed"] = int(run_stats.get("structures_destroyed", 0)) + 1
			_increment_bucket_stat("structures_destroyed_by_direction", str(enemy.get("direction", "")), 1)
			recent_event_tiles[_tile_key(structure_tile)] = "structure_destroyed"
			events.append("%s at %s collapsed under boss pressure." % [
				str(structure.get("type", "structure")).capitalize(),
				_tile_text(structure_tile),
			])
			_apply_architect_planned_collapse(structure, structure_tile, str(enemy.get("direction", "")), events)
		else:
			structures[target_key] = structure


func _apply_guardian_thorns(structure: Dictionary, enemy_id: int, events: Array[String]) -> void:
	var effects = get_class_effects(str(structure.get("class_id", "")))
	var thorns_damage = int(effects.get("thornsDamage", 0))
	if thorns_damage <= 0:
		return

	_damage_enemy_by_id(
		enemy_id,
		thorns_damage,
		events,
		"Guardian thorns at %s" % _tile_text(structure["tile"]),
		"class_thorns_damage",
		"thorns"
	)


func _apply_architect_planned_collapse(
	structure: Dictionary,
	target_tile: Vector2i,
	direction: String,
	events: Array[String]
) -> Dictionary:
	var explosion_report = _apply_architect_explosion(structure, target_tile, events)
	if not bool(explosion_report.get("triggered", false)):
		return explosion_report

	var damage = int(explosion_report.get("damage", 0))
	run_stats["planned_collapses"] = int(run_stats.get("planned_collapses", 0)) + 1
	run_stats["planned_collapse_damage"] = int(run_stats.get("planned_collapse_damage", 0)) + damage
	_increment_bucket_stat("planned_collapses_by_direction", direction, 1)
	_increment_bucket_stat("planned_collapse_damage_by_direction", direction, damage)
	return explosion_report


func _apply_architect_explosion(structure: Dictionary, target_tile: Vector2i, events: Array[String]) -> Dictionary:
	if str(structure.get("type", "")) != "barricade":
		return {"triggered": false, "damage": 0}

	var effects = get_class_effects(str(structure.get("class_id", "")))
	var explosion_damage = int(effects.get("barricadeDeathDamage", 0))
	var explosion_radius = int(effects.get("barricadeDeathRadius", 0))
	if explosion_damage <= 0 or explosion_radius <= 0:
		return {"triggered": false, "damage": 0}

	recent_event_tiles[_tile_key(target_tile)] = "explosion"
	events.append("Architect barricade at %s exploded." % _tile_text(target_tile))
	var damage_before = int(run_stats.get("class_explosion_damage", 0))
	for index in range(enemies.size() - 1, -1, -1):
		var enemy_tile: Vector2i = enemies[index]["tile"]
		var distance = abs(enemy_tile.x - target_tile.x) + abs(enemy_tile.y - target_tile.y)
		if distance <= explosion_radius:
			_damage_enemy_at_index(
				index,
				explosion_damage,
				events,
				"Architect explosion at %s" % _tile_text(target_tile),
				"class_explosion_damage",
				"explosion"
			)
	var damage_done = int(run_stats.get("class_explosion_damage", 0)) - damage_before
	if damage_done > 0:
		events.append("Planned collapse at %s dealt %s explosion damage." % [
			_tile_text(target_tile),
			damage_done,
		])
	return {
		"triggered": true,
		"damage": damage_done,
	}


func _apply_elementalist_splash(structure: Dictionary, target_tile: Vector2i, primary_enemy_id: int, events: Array[String]) -> void:
	var effects = get_class_effects(str(structure.get("class_id", "")))
	var splash_damage = int(effects.get("towerSplashDamage", 0))
	var splash_radius = int(effects.get("towerSplashRadius", 0))
	if splash_damage <= 0 or splash_radius <= 0:
		return

	for index in range(enemies.size() - 1, -1, -1):
		if int(enemies[index]["id"]) == primary_enemy_id:
			continue

		var enemy_tile: Vector2i = enemies[index]["tile"]
		var distance = abs(enemy_tile.x - target_tile.x) + abs(enemy_tile.y - target_tile.y)
		if distance <= splash_radius:
			_damage_enemy_at_index(
				index,
				splash_damage,
				events,
				"Elementalist splash at %s" % _tile_text(target_tile),
				"class_splash_damage",
				"splash"
			)


func _class_card_damage_bonus(class_id: String, enemy_index: int) -> int:
	if class_id.is_empty() or enemy_index < 0 or enemy_index >= enemies.size():
		return 0

	if not _is_boss_enemy(enemies[enemy_index]):
		return 0

	var effects = get_class_effects(class_id)
	return int(effects.get("cardBossDamageBonus", 0))


func _tinkerer_aura_damage_bonus(structure: Dictionary) -> int:
	if str(structure.get("type", "")) != "tower":
		return 0

	var tower_tile: Vector2i = structure["tile"]
	var best_bonus = 0
	for aura_source in structures.values():
		var effects = get_class_effects(str(aura_source.get("class_id", "")))
		var aura_range = int(effects.get("auraRange", 0))
		var damage_bonus = int(effects.get("auraTowerDamageBonus", 0))
		if aura_range <= 0 or damage_bonus <= 0:
			continue

		var aura_tile: Vector2i = aura_source["tile"]
		var distance = abs(aura_tile.x - tower_tile.x) + abs(aura_tile.y - tower_tile.y)
		if distance <= aura_range:
			best_bonus = max(best_bonus, damage_bonus)

	return best_bonus


func _grant_kill_rewards(events: Array[String], enemy: Dictionary) -> void:
	var report = {
		"ok": true,
		"reason": "ok",
		"enemy_id": enemy.get("enemy_id", _default_enemy_id()),
		"enemy_label": _enemy_display_name(enemy),
		"mana_before": mana,
		"gold_before": gold,
		"draw_gauge_before": draw_gauge,
		"hand_before": hand.size(),
		"draw_count_before": draw_pile.size(),
		"discard_count_before": discard_pile.size(),
		"mana_gain": 0,
		"gold_gain": 0,
		"draw_gauge_gain": 0,
		"drawn_count": 0,
		"drawn_card_ids": [],
		"drawn_labels": [],
		"draw_held_reason": "",
	}

	var mana_gain = get_mana_per_kill()
	if mana_gain > 0:
		mana += mana_gain
		run_stats["kill_mana_gained"] = int(run_stats.get("kill_mana_gained", 0)) + mana_gain
		events.append("Kill reward: +%s mana." % mana_gain)
	report["mana_gain"] = mana_gain

	var gold_gain = get_gold_per_kill()
	if gold_gain > 0:
		gold += gold_gain
		run_stats["gold_gained"] = int(run_stats.get("gold_gained", 0)) + gold_gain
		events.append("Kill reward: +%s gold." % gold_gain)
	report["gold_gain"] = gold_gain

	var gauge_gain = get_draw_gauge_per_kill()
	if gauge_gain > 0:
		draw_gauge += gauge_gain
		run_stats["draw_gauge_gained"] = int(run_stats.get("draw_gauge_gained", 0)) + gauge_gain
		events.append("Kill reward: +%s draw gauge." % gauge_gain)
		var draw_report = _try_draw_from_gauge(events)
		report["drawn_count"] = int(draw_report.get("drawn_count", 0))
		report["drawn_card_ids"] = draw_report.get("drawn_card_ids", [])
		report["drawn_labels"] = draw_report.get("drawn_labels", [])
		report["draw_held_reason"] = str(draw_report.get("held_reason", ""))
	report["draw_gauge_gain"] = gauge_gain

	report["mana_after"] = mana
	report["gold_after"] = gold
	report["draw_gauge_after"] = draw_gauge
	report["draw_gauge_threshold"] = get_draw_gauge_per_card()
	report["hand_after"] = hand.size()
	report["draw_count_after"] = draw_pile.size()
	report["discard_count_after"] = discard_pile.size()
	report["summary"] = _format_kill_resource_summary(report)
	last_kill_resource_report = report


func _try_draw_from_gauge(events: Array[String]) -> Dictionary:
	var report = {
		"drawn_count": 0,
		"drawn_card_ids": [],
		"drawn_labels": [],
		"held_reason": "",
		"gauge_spent": 0,
	}
	var threshold = get_draw_gauge_per_card()
	if threshold <= 0:
		return report

	while draw_gauge >= threshold:
		var draw_result = draw_card()
		if not bool(draw_result["ok"]):
			report["held_reason"] = str(draw_result["reason"])
			events.append("Reward draw held: %s." % draw_result["reason"])
			return report

		draw_gauge -= threshold
		report["gauge_spent"] = int(report.get("gauge_spent", 0)) + threshold
		run_stats["reward_cards_drawn"] = int(run_stats.get("reward_cards_drawn", 0)) + 1
		var card_id = str(draw_result["card_id"])
		var card = get_card_data(card_id)
		var drawn_card_ids: Array = report.get("drawn_card_ids", [])
		var drawn_labels: Array = report.get("drawn_labels", [])
		drawn_card_ids.append(card_id)
		drawn_labels.append(str(card.get("label", card_id)))
		report["drawn_card_ids"] = drawn_card_ids
		report["drawn_labels"] = drawn_labels
		report["drawn_count"] = int(report.get("drawn_count", 0)) + 1
		events.append("Reward draw: %s." % card.get("label", card_id))

	return report


func _format_kill_resource_summary(report: Dictionary) -> String:
	var gain_parts = PackedStringArray()
	var mana_gain = int(report.get("mana_gain", 0))
	var gold_gain = int(report.get("gold_gain", 0))
	var gauge_gain = int(report.get("draw_gauge_gain", 0))
	if mana_gain > 0:
		gain_parts.append("+%s mana" % mana_gain)
	if gold_gain > 0:
		gain_parts.append("+%s gold" % gold_gain)
	if gauge_gain > 0:
		gain_parts.append("+%s gauge" % gauge_gain)
	if gain_parts.is_empty():
		gain_parts.append("no resource gain")

	var draw_text = "gauge %s/%s" % [
		report.get("draw_gauge_after", 0),
		report.get("draw_gauge_threshold", get_draw_gauge_per_card()),
	]
	var drawn_labels: Array = report.get("drawn_labels", [])
	if int(report.get("drawn_count", 0)) > 0:
		draw_text = "drew %s" % ", ".join(_string_values(drawn_labels))
	elif not str(report.get("draw_held_reason", "")).is_empty():
		draw_text = "draw held: %s" % _short_reject_reason(str(report.get("draw_held_reason", ""))).to_lower()

	return "last kill %s -> %s; %s; now mana %s, gauge %s/%s" % [
		report.get("enemy_label", "enemy"),
		", ".join(gain_parts),
		draw_text,
		report.get("mana_after", mana),
		report.get("draw_gauge_after", draw_gauge),
		report.get("draw_gauge_threshold", get_draw_gauge_per_card()),
	]


func _format_hand_pressure_summary(report: Dictionary) -> String:
	var hand_text = "%s/%s" % [
		report.get("hand_count", 0),
		report.get("max_hand_size", 0),
	]
	var gauge_text = "%s/%s" % [
		report.get("draw_gauge", 0),
		report.get("draw_gauge_threshold", get_draw_gauge_per_card()),
	]
	match str(report.get("state", "open")):
		"draw_held":
			return "Hand pressure: draw held because hand is full %s; %s." % [
				hand_text,
				report.get("suggested_action", "play or discard"),
			]
		"hand_full":
			return "Hand pressure: hand full %s, gauge %s; %s." % [
				hand_text,
				gauge_text,
				report.get("suggested_action", "play or discard"),
			]
		"full_no_draw":
			return "Hand pressure: hand full %s; no draw waiting yet." % hand_text
		"near_full":
			return "Hand pressure: 1 slot left, next kill may draw; %s." % report.get("suggested_action", "leave a slot")
		_:
			return "Hand pressure: %s slot(s) open, gauge %s." % [
				report.get("hand_room", 0),
				gauge_text,
			]


func _reward_card_pool_for_round(round_number: int) -> Array:
	var reward_cards: Array = data.get("deck", {}).get("rewardCards", [])
	var pool: Array = []
	for card_id in reward_cards:
		var card_id_text = str(card_id)
		if _is_reward_card_unlocked(card_id_text, round_number):
			pool.append(card_id_text)
	return pool


func _is_reward_card_unlocked(card_id: String, round_number: int) -> bool:
	if get_card_data(card_id).is_empty():
		return false

	return round_number >= get_card_reward_min_round(card_id)


func _current_reward_report_round() -> int:
	if not active_reward_packet.is_empty():
		return int(active_reward_packet.get("round", max(1, completed_rounds)))
	if completed_rounds > 0:
		return completed_rounds
	return current_round


func _generate_reward_offer(events: Array[String], reward_round = -1) -> void:
	reward_offer.clear()
	last_reward_claim_report.clear()
	var target_round = completed_rounds if reward_round <= 0 else reward_round
	var reward_cards = _reward_card_pool_for_round(target_round)
	var offer_count = min(get_card_offer_count(), reward_cards.size())
	if offer_count > 0:
		var start_index = target_round % reward_cards.size()
		for index in range(offer_count):
			var reward_index = (start_index + index) % reward_cards.size()
			reward_offer.append(str(reward_cards[reward_index]))

	if reward_offer.is_empty():
		events.append("No unlocked card reward available for round %s." % target_round)
		return

	run_stats["card_rewards_offered"] = int(run_stats.get("card_rewards_offered", 0)) + reward_offer.size()
	events.append("Round %s card reward offered: %s. %s." % [
		target_round,
		_card_labels(reward_offer),
		get_reward_card_pool_summary(target_round),
	])


func _generate_artifact_offer(events: Array[String]) -> void:
	artifact_offer.clear()
	var artifact_pool: Array = data.get("rewards", {}).get("artifactPool", [])
	var offer_count = min(get_artifact_offer_count(), artifact_pool.size())
	if offer_count <= 0:
		events.append("No artifact reward available.")
		return

	var start_index = equipped_artifacts.size() % artifact_pool.size()
	var attempts = 0
	var index = 0
	while artifact_offer.size() < offer_count and attempts < artifact_pool.size():
		var artifact_index = (start_index + index) % artifact_pool.size()
		var artifact_id = str(artifact_pool[artifact_index])
		if not equipped_artifacts.has(artifact_id) and not dormant_artifacts.has(artifact_id) and not artifact_offer.has(artifact_id):
			artifact_offer.append(artifact_id)

		index += 1
		attempts += 1

	if artifact_offer.is_empty():
		events.append("No new artifact reward available.")
		return

	run_stats["artifact_rewards_offered"] = int(run_stats.get("artifact_rewards_offered", 0)) + artifact_offer.size()
	_open_artifact_action_window(events, "artifact offer")
	events.append("Artifact reward offered: %s." % _artifact_labels(artifact_offer))


func _generate_shop_offer(events: Array[String], reward_round: int) -> void:
	shop_offer.clear()
	shop_service_offer.clear()
	shop_removals_remaining = 0
	shop_purchases_remaining = 0
	shop_purchase_vote.clear()
	last_shop_report.clear()
	if not _is_shop_round(reward_round):
		return

	var purchase_limit = get_shop_purchase_limit()
	if purchase_limit <= 0:
		events.append("Shop unavailable: purchases are disabled.")
		return

	var removal_limit = get_shop_deck_removal_limit()
	var offer_count = get_shop_deck_removal_offer_count()
	if removal_limit > 0 and offer_count > 0:
		var candidates = _current_deck_card_ids()
		for index in range(min(offer_count, candidates.size())):
			shop_offer.append(str(candidates[index]))

	for service_id_value in get_shop_service_offer_ids():
		var service_id = str(service_id_value)
		if not get_shop_service_data(service_id).is_empty() and _shop_service_is_offerable(service_id):
			shop_service_offer.append(service_id)

	if shop_offer.is_empty() and shop_service_offer.is_empty():
		events.append("Shop skipped: no deck trim or service offers available.")
		return

	shop_purchases_remaining = purchase_limit
	shop_removals_remaining = min(removal_limit, shop_offer.size(), shop_purchases_remaining)
	if _shop_offer_uses_artifact_action():
		_open_artifact_action_window(events, "shop service")
	run_stats["shop_offers_opened"] = int(run_stats.get("shop_offers_opened", 0)) + 1
	var opened_parts = PackedStringArray()
	if not shop_offer.is_empty():
		opened_parts.append("remove %s card(s) for %s gold each from %s" % [
			shop_removals_remaining,
			get_shop_deck_removal_gold_cost(),
			_card_labels(shop_offer),
		])
	if not shop_service_offer.is_empty():
		opened_parts.append("services %s" % _shop_service_labels(shop_service_offer))
	events.append("Shop opened: %s." % " | ".join(opened_parts))


func _shop_service_is_offerable(service_id: String) -> bool:
	var service = get_shop_service_data(service_id)
	if service.is_empty():
		return false

	var service_type = str(service.get("type", ""))
	if service_type == "reactivate_dormant_artifact":
		return not dormant_artifacts.is_empty()

	return true


func _shop_offer_uses_artifact_action() -> bool:
	for service_id_value in shop_service_offer:
		var service = get_shop_service_data(str(service_id_value))
		if str(service.get("type", "")) == "reactivate_dormant_artifact":
			return true

	return false


func _open_artifact_action_window(events: Array[String], source: String) -> void:
	var action_limit = get_artifact_action_limit()
	if action_limit <= 0:
		artifact_actions_remaining = 0
		return

	if artifact_actions_remaining == action_limit:
		return

	artifact_actions_remaining = action_limit
	events.append("Artifact action ready: %s/%s (%s)." % [
		artifact_actions_remaining,
		action_limit,
		source,
	])


func _consume_artifact_action(action_type: String) -> Dictionary:
	var action_limit = get_artifact_action_limit()
	if action_limit <= 0 or artifact_actions_remaining <= 0:
		return {
			"ok": false,
			"reason": "artifact_action_unavailable",
			"artifact_action_type": action_type,
			"artifact_actions_before": artifact_actions_remaining,
			"artifact_actions_after": artifact_actions_remaining,
			"artifact_action_limit": action_limit,
		}

	var actions_before = artifact_actions_remaining
	artifact_actions_remaining = max(0, artifact_actions_remaining - 1)
	run_stats["artifact_actions_spent"] = int(run_stats.get("artifact_actions_spent", 0)) + 1
	return {
		"ok": true,
		"reason": "ok",
		"artifact_action_type": action_type,
		"artifact_actions_before": actions_before,
		"artifact_actions_after": artifact_actions_remaining,
		"artifact_action_limit": action_limit,
	}


func _present_next_reward_packet(events: Array[String]) -> void:
	if not reward_offer.is_empty() or not artifact_offer.is_empty() or _has_open_shop_offer() or not active_reward_packet.is_empty():
		return

	if reward_queue.is_empty():
		return

	active_reward_packet = reward_queue.pop_front()
	var reward_round = int(active_reward_packet.get("round", completed_rounds))
	_generate_reward_offer(events, reward_round)
	if bool(active_reward_packet.get("artifact", false)):
		_generate_artifact_offer(events)
	if bool(active_reward_packet.get("shop", false)):
		_generate_shop_offer(events, reward_round)

	if reward_offer.is_empty() and artifact_offer.is_empty() and not _has_open_shop_offer():
		active_reward_packet.clear()
		_present_next_reward_packet(events)


func _finish_active_reward_packet_if_ready() -> void:
	if active_reward_packet.is_empty():
		return

	if not reward_offer.is_empty() or not artifact_offer.is_empty() or _has_open_shop_offer():
		return

	active_reward_packet.clear()
	artifact_actions_remaining = 0
	var ignored_events: Array[String] = []
	_present_next_reward_packet(ignored_events)


func _complete_active_rounds(events: Array[String]) -> void:
	if active_wave_packets.is_empty():
		return

	var completed_packet_rounds = _active_wave_rounds()
	var boss_artifact_queued = false
	var boss_shop_queued = false
	var settlement_batch_total = completed_packet_rounds.size()
	var settlement_batch_id = _settlement_batch_id(completed_packet_rounds)
	for packet_index in range(completed_packet_rounds.size()):
		var round_number = int(completed_packet_rounds[packet_index])
		completed_rounds = max(completed_rounds, round_number)
		run_stats["rounds_completed"] = int(run_stats.get("rounds_completed", 0)) + 1
		var reward_packet = {
			"rewardPacketId": _wave_reward_packet_id(round_number),
			"waveId": _wave_id(round_number),
			"spawnPlanId": _wave_spawn_plan_id(round_number),
			"round": round_number,
			"artifact": false,
			"shop": false,
			"batch_index": packet_index + 1,
			"batch_total": settlement_batch_total,
			"generatedInsideSettlementBatchId": settlement_batch_id if settlement_batch_total > 1 else "",
			"candidateCount": get_card_offer_count(),
			"noBonusRewards": true,
			"forbiddenBonusFields": WAVE_STACK_FORBIDDEN_REWARD_FIELDS.duplicate(),
		}
		if boss_reward_pending and _is_boss_round(round_number) and not boss_artifact_queued:
			reward_packet["artifact"] = true
			reward_packet["shop"] = _is_shop_round(round_number)
			var boss_shard_gain = get_boss_shard_reward()
			if boss_shard_gain > 0:
				boss_shards += boss_shard_gain
				run_stats["boss_shards_gained"] = int(run_stats.get("boss_shards_gained", 0)) + boss_shard_gain
				reward_packet["bossShardReward"] = boss_shard_gain
				reward_packet["bossShardsAfter"] = boss_shards
				events.append("Boss reward: +%s boss shard(s)." % boss_shard_gain)
			boss_artifact_queued = true
			boss_shop_queued = bool(reward_packet["shop"])
		reward_queue.append(reward_packet)

	last_round_report = _build_last_round_report(completed_packet_rounds, boss_artifact_queued, boss_shop_queued)
	round_start_stats = _copy_run_stats()
	events.append("Round report: %s" % get_last_round_summary())

	boss_reward_pending = false
	active_wave_packets.clear()
	wave_stack_vote.clear()
	shop_purchase_vote.clear()

	if completed_rounds >= get_max_rounds():
		run_complete = true
		current_round = get_max_rounds()
		active_round = 0
		events.append("Run complete: survived %s rounds." % get_max_rounds())
		_present_next_reward_packet(events)
		return

	current_round = completed_rounds + 1
	active_round = 0
	events.append("Next round ready: %s/%s." % [current_round, get_max_rounds()])
	_present_next_reward_packet(events)


func _refill_round_resources(events: Array[String], player_count: int) -> void:
	var base_seed_mana = get_seed_mana()
	last_kill_resource_report.clear()
	mana = get_seed_mana_for_player_count(player_count)
	discard_charges = get_discard_charges_per_run()
	var seed_cards_drawn = _draw_round_seed_cards(player_count)
	var active_directions = get_active_directions(player_count)
	run_stats["round_mana_refills"] = int(run_stats.get("round_mana_refills", 0)) + 1
	run_stats["front_seed_mana_gained"] = int(run_stats.get("front_seed_mana_gained", 0)) + max(0, mana - base_seed_mana)
	run_stats["discard_refills"] = int(run_stats.get("discard_refills", 0)) + 1
	if seed_cards_drawn > 0:
		run_stats["round_seed_cards_drawn"] = int(run_stats.get("round_seed_cards_drawn", 0)) + seed_cards_drawn
	last_round_resource_report = {
		"ok": true,
		"reason": "ok",
		"mode": "actual",
		"round": current_round,
		"active_fronts": active_directions.size(),
		"active_directions": active_directions.duplicate(),
		"extra_fronts": get_extra_front_count(player_count),
		"seed_mana": mana,
		"front_seed_mana": max(0, mana - base_seed_mana),
		"seed_draw": get_seed_draw_count_for_player_count(player_count),
		"front_seed_draw": max(0, get_seed_draw_count_for_player_count(player_count) - get_seed_draw_count()),
		"drawn": seed_cards_drawn,
		"discard_charges": discard_charges,
		"hand_count": hand.size(),
		"max_hand_size": get_max_hand_size(),
		"draw_count": draw_pile.size(),
		"discard_count": discard_pile.size(),
	}
	last_round_resource_report["summary"] = _format_round_preparation_summary(last_round_resource_report)
	events.append("Round resources refilled: mana %s, seed draw %s/%s, discard uses %s, active fronts %s." % [
		mana,
		seed_cards_drawn,
		get_seed_draw_count_for_player_count(player_count),
		discard_charges,
		active_directions.size(),
	])
	_repair_tinkerer_structures(events)


func _build_last_round_report(completed_packet_rounds: Array[int], artifact_queued: bool, shop_queued: bool) -> Dictionary:
	var active_directions = _all_configured_directions()
	var base_hits = _stat_delta("base_hits")
	var boss_base_hits = _stat_delta("boss_base_hits")
	var base_damage = _stat_delta("base_damage")
	var destroyed = _stat_delta("structures_destroyed")
	var planned_collapses = _stat_delta("planned_collapses")
	var planned_collapse_damage = _stat_delta("planned_collapse_damage")
	var killed = _stat_delta("killed")
	var spawned = _stat_delta("spawned")
	var cards_played = _stat_delta("cards_played")
	var mana_spent_delta = _stat_delta("mana_spent")
	var class_effect_report = _class_effect_report(true)
	var class_effect_summary = _class_effect_summary_from_report(class_effect_report, "Class effects: none this round")
	var leak = _top_bucket_delta("base_hits_by_direction", active_directions)
	var collapse = _top_bucket_delta("structures_destroyed_by_direction", active_directions)
	var planned_collapse = _top_bucket_delta("planned_collapses_by_direction", active_directions)
	var focus = "stable"
	var headline = "Defense held."
	var suggestion = "Compare front pressure before starting the next wave."
	var details: Array = []

	if base_hp <= 0:
		focus = "failed"
		headline = "Base destroyed."
		suggestion = "Restart and create an earlier delay pocket before the base."
	elif base_hits > 0:
		focus = "leak"
		headline = "%s leaked %s time(s)." % [
			_direction_label(str(leak.get("key", ""))),
			base_hits,
		]
		suggestion = "Add a tower, slow, or barricade on %s before the next wave." % _direction_label(str(leak.get("key", "")))
	elif destroyed > 0:
		if planned_collapses >= destroyed and planned_collapse_damage > 0:
			focus = "planned_collapse"
			headline = "Planned collapse dealt %s damage." % planned_collapse_damage
			suggestion = "Rebuild the spent pocket on %s before pulling extra pressure." % _direction_label(str(planned_collapse.get("key", "")))
		else:
			focus = "collapse"
			headline = "%s structure(s) broke." % destroyed
			suggestion = "Repair or rebuild the weakest point on %s." % _direction_label(str(collapse.get("key", "")))
	elif completed_packet_rounds.size() > 1:
		focus = "stack_clear"
		headline = "Stacked waves cleared."
		suggestion = "Resolve the compressed settlement before pulling another wave."
	elif _stat_delta("bosses_killed") > 0:
		focus = "boss_clear"
		headline = "Boss cleared."
		suggestion = "Choose the artifact that fixes the run's weakest resource."
	elif killed > 0:
		headline = "Clean clear."

	details.append("spawned %s / killed %s" % [spawned, killed])
	details.append("base hits %s / damage %s" % [base_hits, base_damage])
	details.append("structures lost %s" % destroyed)
	if planned_collapses > 0:
		details.append("planned collapses %s / damage %s" % [planned_collapses, planned_collapse_damage])
	if completed_packet_rounds.size() > 1:
		details.append("compressed settlement %s packets / no bonus" % completed_packet_rounds.size())
	if bool(class_effect_report.get("active", false)):
		details.append(class_effect_summary.trim_prefix("Class effects: "))
	if cards_played > 0 or mana_spent_delta > 0:
		details.append("cards %s / mana %s" % [cards_played, mana_spent_delta])
	if boss_base_hits > 0:
		details.append("boss base hits %s" % boss_base_hits)
	if artifact_queued:
		details.append("artifact queued")
	if shop_queued:
		details.append("shop trim queued")

	return {
		"ok": true,
		"reason": "ok",
		"rounds": completed_packet_rounds.duplicate(),
		"round_label": _format_completed_round_label(completed_packet_rounds),
		"focus": focus,
		"headline": headline,
		"suggestion": suggestion,
		"scoreline": "base %s hp, spawned %s, killed %s, leaks %s, lost %s" % [
			base_hp,
			spawned,
			killed,
			base_hits,
			destroyed,
		],
		"details": details.duplicate(),
		"base_hp": base_hp,
		"spawned": spawned,
		"killed": killed,
		"base_hits": base_hits,
		"boss_base_hits": boss_base_hits,
		"base_damage": base_damage,
		"structures_destroyed": destroyed,
		"planned_collapses": planned_collapses,
		"planned_collapse_damage": planned_collapse_damage,
		"class_effects": class_effect_report,
		"class_effect_summary": class_effect_summary,
		"cards_played": cards_played,
		"mana_spent": mana_spent_delta,
		"stack_depth": completed_packet_rounds.size(),
		"artifact_queued": artifact_queued,
		"shop_queued": shop_queued,
		"primary_leak_direction": str(leak.get("key", "")),
		"primary_collapse_direction": str(collapse.get("key", "")),
		"primary_planned_collapse_direction": str(planned_collapse.get("key", "")),
		"reward_packets_queued": reward_queue.size(),
	}


func _last_round_reward_line() -> String:
	var waiting_parts = PackedStringArray()
	if not reward_offer.is_empty():
		waiting_parts.append("card choice")
	if not artifact_offer.is_empty():
		waiting_parts.append("artifact choice")
	if _has_open_shop_offer():
		waiting_parts.append("shop")

	var settlement_report = get_settlement_batch_report()
	var settlement_prefix = ""
	if bool(settlement_report.get("ok", false)) and bool(settlement_report.get("compressed", false)):
		settlement_prefix = "%s " % settlement_report.get("summary", "")

	if waiting_parts.size() > 0:
		return "%sReward waiting: %s." % [settlement_prefix, ", ".join(waiting_parts)]
	if reward_queue.size() > 0:
		return "%sReward queued: %s packet(s)." % [settlement_prefix, reward_queue.size()]
	return "Reward waiting: none."


func _class_effect_report(use_round_delta: bool) -> Dictionary:
	var report = {
		"guardian_taunt_hits": _class_effect_stat("class_taunt_hits", use_round_delta),
		"guardian_thorns_damage": _class_effect_stat("class_thorns_damage", use_round_delta),
		"architect_collapses": _class_effect_stat("planned_collapses", use_round_delta),
		"architect_explosion_damage": _class_effect_stat("class_explosion_damage", use_round_delta),
		"elementalist_splash_damage": _class_effect_stat("class_splash_damage", use_round_delta),
		"tinkerer_aura_damage": _class_effect_stat("class_aura_damage", use_round_delta),
		"tinkerer_repairs": _class_effect_stat("class_repairs", use_round_delta),
	}

	var total = 0
	for value in report.values():
		total += int(value)

	report["active"] = total > 0
	return report


func _class_effect_stat(stat_key: String, use_round_delta: bool) -> int:
	if use_round_delta:
		return _stat_delta(stat_key)
	return int(run_stats.get(stat_key, 0))


func _class_effect_summary_from_report(report: Dictionary, none_text: String = "Class effects: none yet") -> String:
	if not bool(report.get("active", false)):
		return none_text

	var parts = PackedStringArray()
	var guardian_parts = PackedStringArray()
	var taunt_hits = int(report.get("guardian_taunt_hits", 0))
	var thorns_damage = int(report.get("guardian_thorns_damage", 0))
	if taunt_hits > 0:
		guardian_parts.append("taunt %s hit(s)" % taunt_hits)
	if thorns_damage > 0:
		guardian_parts.append("thorns %s dmg" % thorns_damage)
	if guardian_parts.size() > 0:
		parts.append("Guardian %s" % ", ".join(guardian_parts))

	var architect_collapses = int(report.get("architect_collapses", 0))
	var architect_damage = int(report.get("architect_explosion_damage", 0))
	if architect_collapses > 0 or architect_damage > 0:
		if architect_collapses > 0:
			parts.append("Architect collapse %s time(s), %s dmg" % [
				architect_collapses,
				architect_damage,
			])
		else:
			parts.append("Architect explosion %s dmg" % architect_damage)

	var splash_damage = int(report.get("elementalist_splash_damage", 0))
	if splash_damage > 0:
		parts.append("Elementalist splash %s dmg" % splash_damage)

	var tinkerer_parts = PackedStringArray()
	var aura_damage = int(report.get("tinkerer_aura_damage", 0))
	var repairs = int(report.get("tinkerer_repairs", 0))
	if aura_damage > 0:
		tinkerer_parts.append("aura %s bonus dmg" % aura_damage)
	if repairs > 0:
		tinkerer_parts.append("repairs %s hp" % repairs)
	if tinkerer_parts.size() > 0:
		parts.append("Tinkerer %s" % ", ".join(tinkerer_parts))

	if parts.is_empty():
		return none_text
	return "Class effects: %s" % " | ".join(parts)


func _repair_tinkerer_structures(events: Array[String]) -> void:
	for key in structures.keys():
		var structure: Dictionary = structures[key]
		var effects = get_class_effects(str(structure.get("class_id", "")))
		var repair_amount = int(effects.get("repairPerRound", 0))
		if repair_amount <= 0:
			continue

		var missing_hp = int(structure.get("max_hp", 0)) - int(structure.get("hp", 0))
		if missing_hp <= 0:
			continue

		var repaired = min(repair_amount, missing_hp)
		structure["hp"] = int(structure["hp"]) + repaired
		structures[key] = structure
		run_stats["class_repairs"] = int(run_stats.get("class_repairs", 0)) + repaired
		events.append("Tinkerer repaired %s at %s for %s. HP: %s/%s." % [
			structure["type"],
			_tile_text(structure["tile"]),
			repaired,
			structure["hp"],
			structure["max_hp"],
		])


func _validate_data() -> bool:
	var map_size = get_map_size()
	if map_size.x <= 0 or map_size.y <= 0:
		last_error = "M0 map size must be positive."
		return false

	for base_tile in get_base_cells():
		if not _is_in_bounds(base_tile):
			last_error = "M0 base tile is out of bounds: %s" % _tile_text(base_tile)
			return false

	var entrances = get_entrances()
	for direction in ["north", "east", "south", "west"]:
		if not entrances.has(direction):
			last_error = "M0 entrance is missing: %s" % direction
			return false

		var coord: Array = entrances[direction]
		if coord.size() < 2:
			last_error = "M0 entrance coordinate is invalid: %s" % direction
			return false

		var entrance_tile = Vector2i(int(coord[0]), int(coord[1]))
		if not _is_in_bounds(entrance_tile):
			last_error = "M0 entrance is out of bounds: %s %s" % [direction, _tile_text(entrance_tile)]
			return false

	var by_count: Dictionary = data.get("activeDirectionsByPlayerCount", {})
	for count in range(1, 5):
		var key = str(count)
		if not by_count.has(key):
			last_error = "M0 active directions missing player count: %s" % key
			return false

		var directions: Array = by_count[key]
		if directions.is_empty():
			last_error = "M0 active directions cannot be empty for player count: %s" % key
			return false

		for direction in directions:
			if not entrances.has(str(direction)):
				last_error = "M0 active direction has no entrance: %s" % direction
				return false

	var base_data: Dictionary = data.get("base", {})
	if int(base_data.get("hp", 0)) <= 0:
		last_error = "M0 base hp must be positive."
		return false

	var run_data: Dictionary = data.get("run", {})
	if int(run_data.get("maxRounds", 0)) <= 0:
		last_error = "M0 maxRounds must be positive."
		return false

	var structures_data: Dictionary = data.get("structures", {})
	for structure_id in ["m0_basic_tower", "m0_barricade"]:
		if not structures_data.has(structure_id):
			last_error = "M0 structure data is missing: %s" % structure_id
			return false

	if int(structures_data["m0_basic_tower"].get("hp", 0)) <= 0:
		last_error = "M0 tower hp must be positive."
		return false

	if int(structures_data["m0_basic_tower"].get("range", 0)) <= 0:
		last_error = "M0 tower range must be positive."
		return false

	if int(structures_data["m0_basic_tower"].get("damage", 0)) <= 0:
		last_error = "M0 tower damage must be positive."
		return false

	if int(structures_data["m0_barricade"].get("hp", 0)) <= 0:
		last_error = "M0 barricade hp must be positive."
		return false

	var resources_data: Dictionary = data.get("resources", {})
	var seed_mana = int(resources_data.get("seedMana", -1))
	var seed_mana_per_extra_front = int(resources_data.get("seedManaPerExtraFront", 0))
	var starting_gold = int(resources_data.get("startingGold", -1))
	var starting_boss_shards = int(resources_data.get("startingBossShards", 0))
	var max_hand_size = int(resources_data.get("maxHandSize", 0))
	var opening_draw = int(resources_data.get("openingDraw", 0))
	var seed_draw = int(resources_data.get("seedDraw", -1))
	var seed_draw_per_extra_front = int(resources_data.get("seedDrawPerExtraFront", 0))
	var discard_charges_data = int(resources_data.get("discardCharges", -1))
	var discard_charge_cap = int(resources_data.get("discardChargeCap", discard_charges_data))
	var discard_mana_gain = int(resources_data.get("discardManaGain", -1))
	if seed_mana < 0:
		last_error = "M0 seedMana cannot be negative."
		return false

	if seed_mana_per_extra_front < 0:
		last_error = "M0 seedManaPerExtraFront cannot be negative."
		return false

	if starting_gold < 0:
		last_error = "M0 startingGold cannot be negative."
		return false

	if starting_boss_shards < 0:
		last_error = "M0 startingBossShards cannot be negative."
		return false

	if max_hand_size <= 0:
		last_error = "M0 maxHandSize must be positive."
		return false

	if opening_draw <= 0 or opening_draw > max_hand_size:
		last_error = "M0 openingDraw must be between 1 and maxHandSize."
		return false

	if seed_draw < 0:
		last_error = "M0 seedDraw cannot be negative."
		return false

	if seed_draw_per_extra_front < 0:
		last_error = "M0 seedDrawPerExtraFront cannot be negative."
		return false

	if discard_charges_data < 0:
		last_error = "M0 discardCharges cannot be negative."
		return false

	if discard_charge_cap < discard_charges_data:
		last_error = "M0 discardChargeCap cannot be lower than discardCharges."
		return false

	if discard_mana_gain < 0:
		last_error = "M0 discardManaGain cannot be negative."
		return false

	var rewards_data: Dictionary = data.get("rewards", {})
	if int(rewards_data.get("manaPerKill", -1)) < 0:
		last_error = "M0 manaPerKill cannot be negative."
		return false

	if int(rewards_data.get("goldPerKill", -1)) < 0:
		last_error = "M0 goldPerKill cannot be negative."
		return false

	if int(rewards_data.get("drawGaugePerKill", -1)) < 0:
		last_error = "M0 drawGaugePerKill cannot be negative."
		return false

	if int(rewards_data.get("drawGaugePerCard", 0)) <= 0:
		last_error = "M0 drawGaugePerCard must be positive."
		return false

	if int(rewards_data.get("cardOfferCount", 0)) <= 0:
		last_error = "M0 cardOfferCount must be positive."
		return false

	if int(rewards_data.get("cardRewardGold", 0)) < 0:
		last_error = "M0 cardRewardGold cannot be negative."
		return false

	if int(rewards_data.get("bossShardReward", 0)) < 0:
		last_error = "M0 bossShardReward cannot be negative."
		return false

	if int(rewards_data.get("artifactOfferCount", 0)) < 0:
		last_error = "M0 artifactOfferCount cannot be negative."
		return false

	if int(rewards_data.get("artifactActionLimit", 1)) < 0:
		last_error = "M0 artifactActionLimit cannot be negative."
		return false

	var artifact_slot_limit_data = int(rewards_data.get("artifactSlotLimit", 3))
	var artifact_slot_hard_cap_data = int(rewards_data.get("artifactSlotHardCap", ARTIFACT_SLOT_HARD_CAP))
	var dormant_artifact_limit_data = int(rewards_data.get("dormantArtifactLimit", 2))
	if artifact_slot_limit_data <= 0:
		last_error = "M0 artifactSlotLimit must be positive."
		return false

	if artifact_slot_hard_cap_data < artifact_slot_limit_data:
		last_error = "M0 artifactSlotHardCap cannot be lower than artifactSlotLimit."
		return false

	if artifact_slot_hard_cap_data > ARTIFACT_SLOT_HARD_CAP:
		last_error = "M0 artifactSlotHardCap cannot exceed %s." % ARTIFACT_SLOT_HARD_CAP
		return false

	if dormant_artifact_limit_data < 0:
		last_error = "M0 dormantArtifactLimit cannot be negative."
		return false

	var shop_data: Dictionary = data.get("shop", {})
	if int(shop_data.get("bossShopEveryRounds", 0)) < 0:
		last_error = "M0 bossShopEveryRounds cannot be negative."
		return false

	if int(shop_data.get("deckRemovalOfferCount", 0)) < 0:
		last_error = "M0 deckRemovalOfferCount cannot be negative."
		return false

	if int(shop_data.get("deckRemovalLimit", 0)) < 0:
		last_error = "M0 deckRemovalLimit cannot be negative."
		return false

	if int(shop_data.get("deckRemovalGoldCost", 0)) < 0:
		last_error = "M0 deckRemovalGoldCost cannot be negative."
		return false

	if int(shop_data.get("purchaseLimit", max(0, int(shop_data.get("deckRemovalLimit", 0))))) < 0:
		last_error = "M0 shop purchaseLimit cannot be negative."
		return false

	var shop_service_ids = shop_data.get("serviceOfferIds", [])
	if typeof(shop_service_ids) != TYPE_ARRAY:
		last_error = "M0 shop serviceOfferIds must be an array."
		return false

	var shop_services = shop_data.get("services", {})
	if typeof(shop_services) != TYPE_DICTIONARY:
		last_error = "M0 shop services must be a dictionary."
		return false

	for service_id_value in shop_service_ids:
		var service_id = str(service_id_value)
		if not shop_services.has(service_id):
			last_error = "M0 shop service is missing: %s" % service_id
			return false

		if typeof(shop_services[service_id]) != TYPE_DICTIONARY:
			last_error = "M0 shop service must be a dictionary: %s" % service_id
			return false

		var service: Dictionary = shop_services[service_id]
		var service_type = str(service.get("type", ""))
		if str(service.get("label", "")).is_empty():
			last_error = "M0 shop service label is missing: %s" % service_id
			return false

		if not ["restore_base", "structure_hp_boost", "reactivate_dormant_artifact"].has(service_type):
			last_error = "M0 shop service type is unknown: %s" % service_id
			return false

		if int(service.get("goldCost", 0)) < 0:
			last_error = "M0 shop service goldCost cannot be negative: %s" % service_id
			return false

		if int(service.get("bossShardCost", 0)) < 0:
			last_error = "M0 shop service bossShardCost cannot be negative: %s" % service_id
			return false

		if service_type == "restore_base" and int(service.get("heal", 0)) <= 0:
			last_error = "M0 restore_base shop service heal must be positive: %s" % service_id
			return false

		if service_type == "structure_hp_boost" and int(service.get("hpBonus", 0)) <= 0:
			last_error = "M0 structure_hp_boost shop service hpBonus must be positive: %s" % service_id
			return false

	var artifacts_data: Dictionary = data.get("artifacts", {})
	if artifacts_data.is_empty():
		last_error = "M0 artifacts cannot be empty."
		return false

	for artifact_id in artifacts_data.keys():
		var artifact: Dictionary = artifacts_data[artifact_id]
		if str(artifact.get("label", "")).is_empty():
			last_error = "M0 artifact label is missing: %s" % artifact_id
			return false

		var artifact_effects: Dictionary = artifact.get("effects", {})
		if artifact_effects.is_empty():
			last_error = "M0 artifact effects are missing: %s" % artifact_id
			return false

		for effect_key in artifact_effects.keys():
			if not ARTIFACT_EFFECT_KEYS.has(str(effect_key)):
				last_error = "M0 artifact effect key is invalid: %s/%s" % [artifact_id, effect_key]
				return false

			if int(artifact_effects[effect_key]) < 0:
				last_error = "M0 artifact effect value cannot be negative: %s/%s" % [artifact_id, effect_key]
				return false

	var artifact_pool: Array = rewards_data.get("artifactPool", [])
	if int(rewards_data.get("artifactOfferCount", 0)) > 0 and artifact_pool.is_empty():
		last_error = "M0 artifactPool cannot be empty when artifactOfferCount is positive."
		return false

	for artifact_id in artifact_pool:
		if not artifacts_data.has(str(artifact_id)):
			last_error = "M0 artifactPool references missing artifact: %s" % artifact_id
			return false

	var cards_data: Dictionary = data.get("cards", {})
	if cards_data.is_empty():
		last_error = "M0 cards cannot be empty."
		return false

	for card_id in cards_data.keys():
		var card: Dictionary = cards_data[card_id]
		if str(card.get("label", "")).is_empty():
			last_error = "M0 card label is missing: %s" % card_id
			return false

		if int(card.get("cost", -1)) < 0:
			last_error = "M0 card cost cannot be negative: %s" % card_id
			return false

		if not CARD_RARITIES.has(str(card.get("rarity", "common"))):
			last_error = "M0 card rarity is invalid: %s" % card_id
			return false

		if int(card.get("rewardMinRound", 1)) <= 0:
			last_error = "M0 card rewardMinRound must be positive: %s" % card_id
			return false

		var kind = str(card.get("kind", ""))
		if not CARD_KINDS.has(kind):
			last_error = "M0 unsupported card kind: %s" % card_id
			return false

		if kind == "place_structure":
			if not ["tower", "barricade"].has(str(card.get("structureType", ""))):
				last_error = "M0 card structureType is invalid: %s" % card_id
				return false
		elif kind == "damage_enemy":
			if int(card.get("damage", 0)) <= 0:
				last_error = "M0 damage card must have positive damage: %s" % card_id
				return false
		elif kind == "repair_structure":
			if int(card.get("repair", 0)) <= 0:
				last_error = "M0 repair card must have positive repair: %s" % card_id
				return false
		elif kind == "draw_cards":
			if int(card.get("draw", 0)) <= 0:
				last_error = "M0 draw card must have positive draw: %s" % card_id
				return false

	var classes_data: Dictionary = data.get("classes", {})
	if classes_data.is_empty():
		last_error = "M0 classes cannot be empty."
		return false

	for class_id in classes_data.keys():
		var class_data: Dictionary = classes_data[class_id]
		if str(class_data.get("label", "")).is_empty():
			last_error = "M0 class label is missing: %s" % class_id
			return false

		var effects_data: Dictionary = class_data.get("effects", {})
		if effects_data.is_empty():
			last_error = "M0 class effects are missing: %s" % class_id
			return false

		for effect_key in effects_data.keys():
			if not CLASS_EFFECT_KEYS.has(str(effect_key)):
				last_error = "M0 class effect key is invalid: %s/%s" % [class_id, effect_key]
				return false

			if int(effects_data[effect_key]) < 0:
				last_error = "M0 class effect value cannot be negative: %s/%s" % [class_id, effect_key]
				return false

		var autoplay_data: Dictionary = class_data.get("autoplay", {})
		if autoplay_data.is_empty():
			last_error = "M0 class autoplay profile is missing: %s" % class_id
			return false

		var card_priority: Array = autoplay_data.get("cardPriority", [])
		if card_priority.is_empty():
			last_error = "M0 class cardPriority cannot be empty: %s" % class_id
			return false

		for priority_card_id in card_priority:
			if not cards_data.has(str(priority_card_id)):
				last_error = "M0 class cardPriority references missing card: %s/%s" % [class_id, priority_card_id]
				return false

		var tile_plan = str(autoplay_data.get("tilePlan", ""))
		if not AUTOPLAY_TILE_PLANS.has(tile_plan):
			last_error = "M0 class tilePlan is invalid: %s/%s" % [class_id, tile_plan]
			return false

	var deck_data: Dictionary = data.get("deck", {})
	var starting_cards: Array = deck_data.get("startingCards", [])
	if starting_cards.is_empty():
		last_error = "M0 starting deck cannot be empty."
		return false

	if starting_cards.size() < opening_draw:
		last_error = "M0 starting deck must contain at least openingDraw cards."
		return false

	for card_id in starting_cards:
		if not cards_data.has(str(card_id)):
			last_error = "M0 starting deck references missing card: %s" % card_id
			return false

	var reward_cards: Array = deck_data.get("rewardCards", [])
	if reward_cards.is_empty():
		last_error = "M0 reward card pool cannot be empty."
		return false

	for card_id in reward_cards:
		if not cards_data.has(str(card_id)):
			last_error = "M0 reward card pool references missing card: %s" % card_id
			return false

	if _reward_card_pool_for_round(1).size() < int(rewards_data.get("cardOfferCount", 0)):
		last_error = "M0 reward card pool needs enough round 1 unlocked cards."
		return false

	var wave_data: Dictionary = data.get("wave", {})
	var enemy_id = str(wave_data.get("enemyId", ""))
	var enemies_data: Dictionary = data.get("enemies", {})
	if enemy_id.is_empty() or not enemies_data.has(enemy_id):
		last_error = "M0 wave references missing enemy: %s" % enemy_id
		return false

	if int(wave_data.get("spawnCount", 0)) <= 0:
		last_error = "M0 wave spawnCount must be positive."
		return false

	if int(wave_data.get("spawnGrowthPerRound", 0)) < 0:
		last_error = "M0 spawnGrowthPerRound cannot be negative."
		return false

	if int(wave_data.get("stackLimit", 0)) <= 0:
		last_error = "M0 wave stackLimit must be positive."
		return false

	var boss_enemy_id = str(wave_data.get("bossEnemyId", ""))
	if not boss_enemy_id.is_empty() and not enemies_data.has(boss_enemy_id):
		last_error = "M0 wave bossEnemyId references missing enemy: %s" % boss_enemy_id
		return false

	if int(wave_data.get("bossEveryRounds", 0)) < 0:
		last_error = "M0 bossEveryRounds cannot be negative."
		return false

	var raw_enemy_mix = wave_data.get("enemyMix", [])
	if typeof(raw_enemy_mix) != TYPE_ARRAY:
		last_error = "M0 enemyMix must be an array."
		return false

	var enemy_mix: Array = raw_enemy_mix
	for mix_index in range(enemy_mix.size()):
		if typeof(enemy_mix[mix_index]) != TYPE_DICTIONARY:
			last_error = "M0 enemyMix entry must be an object: %s" % mix_index
			return false

		var mix_entry: Dictionary = enemy_mix[mix_index]
		var mix_enemy_id = str(mix_entry.get("enemyId", ""))
		if mix_enemy_id.is_empty() or not enemies_data.has(mix_enemy_id):
			last_error = "M0 enemyMix references missing enemy: %s" % mix_enemy_id
			return false

		var mix_enemy_data: Dictionary = enemies_data[mix_enemy_id]
		if bool(mix_enemy_data.get("boss", false)):
			last_error = "M0 enemyMix cannot include boss enemies: %s" % mix_enemy_id
			return false

		if int(mix_entry.get("minRound", 1)) <= 0:
			last_error = "M0 enemyMix minRound must be positive: %s" % mix_enemy_id
			return false

		if int(mix_entry.get("weight", 1)) <= 0:
			last_error = "M0 enemyMix weight must be positive: %s" % mix_enemy_id
			return false

	var wave_intents: Dictionary = data.get("waveIntents", {})
	if wave_intents.is_empty():
		last_error = "M0 waveIntents cannot be empty."
		return false

	for intent_id in wave_intents.keys():
		if typeof(wave_intents[intent_id]) != TYPE_DICTIONARY:
			last_error = "M0 waveIntent must be an object: %s" % intent_id
			return false

		var intent_data: Dictionary = wave_intents[intent_id]
		if str(intent_data.get("label", "")).is_empty():
			last_error = "M0 waveIntent label is missing: %s" % intent_id
			return false

		var primary_role = str(intent_data.get("primaryRole", ""))
		if not WAVE_INTENT_ROLES.has(primary_role):
			last_error = "M0 waveIntent primaryRole is invalid: %s/%s" % [intent_id, primary_role]
			return false

		if str(intent_data.get("question", "")).is_empty():
			last_error = "M0 waveIntent question is missing: %s" % intent_id
			return false

		var raw_prep_tags = intent_data.get("recommendedPrepTags", [])
		if typeof(raw_prep_tags) != TYPE_ARRAY:
			last_error = "M0 waveIntent recommendedPrepTags must be an array: %s" % intent_id
			return false

		var prep_tags: Array = raw_prep_tags
		if prep_tags.is_empty():
			last_error = "M0 waveIntent recommendedPrepTags cannot be empty: %s" % intent_id
			return false

		for prep_tag in prep_tags:
			if str(prep_tag).is_empty():
				last_error = "M0 waveIntent recommendedPrepTags contains an empty tag: %s" % intent_id
				return false

		if intent_data.has("forbiddenPairTags") and typeof(intent_data.get("forbiddenPairTags", [])) != TYPE_ARRAY:
			last_error = "M0 waveIntent forbiddenPairTags must be an array: %s" % intent_id
			return false

	var raw_intent_schedule = wave_data.get("intentSchedule", [])
	if typeof(raw_intent_schedule) != TYPE_ARRAY:
		last_error = "M0 intentSchedule must be an array."
		return false

	var intent_schedule: Array = raw_intent_schedule
	if intent_schedule.is_empty():
		last_error = "M0 intentSchedule cannot be empty."
		return false

	for schedule_index in range(intent_schedule.size()):
		if typeof(intent_schedule[schedule_index]) != TYPE_DICTIONARY:
			last_error = "M0 intentSchedule entry must be an object: %s" % schedule_index
			return false

		var schedule_entry: Dictionary = intent_schedule[schedule_index]
		var schedule_intent_id = str(schedule_entry.get("intentId", ""))
		if schedule_intent_id.is_empty() or not wave_intents.has(schedule_intent_id):
			last_error = "M0 intentSchedule references missing intent: %s" % schedule_intent_id
			return false

		var is_boss_schedule = bool(schedule_entry.get("bossRound", false))
		var has_round_range = schedule_entry.has("minRound") or schedule_entry.has("maxRound")
		if not is_boss_schedule and not has_round_range:
			last_error = "M0 intentSchedule needs bossRound or minRound/maxRound: %s" % schedule_intent_id
			return false

		if has_round_range:
			var min_round = int(schedule_entry.get("minRound", 1))
			var max_round = int(schedule_entry.get("maxRound", min_round))
			if min_round <= 0 or max_round <= 0:
				last_error = "M0 intentSchedule rounds must be positive: %s" % schedule_intent_id
				return false

			if max_round < min_round:
				last_error = "M0 intentSchedule maxRound cannot be lower than minRound: %s" % schedule_intent_id
				return false

	var spawn_plan_rules: Dictionary = wave_data.get("spawnPlanRules", {})
	if spawn_plan_rules.is_empty():
		last_error = "M0 spawnPlanRules cannot be empty."
		return false

	if int(spawn_plan_rules.get("baseThreatBudget", 0)) <= 0:
		last_error = "M0 spawnPlanRules baseThreatBudget must be positive."
		return false

	if int(spawn_plan_rules.get("threatBudgetGrowthPerRound", 0)) < 0:
		last_error = "M0 spawnPlanRules threatBudgetGrowthPerRound cannot be negative."
		return false

	if int(spawn_plan_rules.get("normalEnemyBudget", 0)) <= 0:
		last_error = "M0 spawnPlanRules normalEnemyBudget must be positive."
		return false

	if int(spawn_plan_rules.get("bossEnemyBudget", 0)) <= 0:
		last_error = "M0 spawnPlanRules bossEnemyBudget must be positive."
		return false

	if str(spawn_plan_rules.get("defaultRouteProfileId", "")).is_empty():
		last_error = "M0 spawnPlanRules defaultRouteProfileId is missing."
		return false

	if float(spawn_plan_rules.get("defaultWarningLeadTimeSeconds", 0.0)) < 0.0:
		last_error = "M0 spawnPlanRules defaultWarningLeadTimeSeconds cannot be negative."
		return false

	var direction_role_by_intent = spawn_plan_rules.get("directionRoleByIntent", {})
	if typeof(direction_role_by_intent) != TYPE_DICTIONARY:
		last_error = "M0 spawnPlanRules directionRoleByIntent must be an object."
		return false

	for intent_id in direction_role_by_intent.keys():
		if not wave_intents.has(str(intent_id)):
			last_error = "M0 spawnPlanRules directionRoleByIntent references missing intent: %s" % intent_id
			return false

		var direction_role = str(direction_role_by_intent[intent_id])
		if not WAVE_SPAWN_DIRECTION_ROLES.has(direction_role):
			last_error = "M0 spawnPlanRules directionRoleByIntent role is invalid: %s/%s" % [intent_id, direction_role]
			return false

	var route_profile_by_intent = spawn_plan_rules.get("routeProfileByIntent", {})
	if typeof(route_profile_by_intent) != TYPE_DICTIONARY:
		last_error = "M0 spawnPlanRules routeProfileByIntent must be an object."
		return false

	for intent_id in route_profile_by_intent.keys():
		if not wave_intents.has(str(intent_id)):
			last_error = "M0 spawnPlanRules routeProfileByIntent references missing intent: %s" % intent_id
			return false

		if str(route_profile_by_intent[intent_id]).is_empty():
			last_error = "M0 spawnPlanRules routeProfileByIntent value is missing: %s" % intent_id
			return false

	var stack_risk_level_by_intent = spawn_plan_rules.get("stackRiskLevelByIntent", {})
	if typeof(stack_risk_level_by_intent) != TYPE_DICTIONARY:
		last_error = "M0 spawnPlanRules stackRiskLevelByIntent must be an object."
		return false

	for intent_id in stack_risk_level_by_intent.keys():
		if not wave_intents.has(str(intent_id)):
			last_error = "M0 spawnPlanRules stackRiskLevelByIntent references missing intent: %s" % intent_id
			return false

		var stack_risk_level = str(stack_risk_level_by_intent[intent_id])
		if not WAVE_STACK_RISK_LEVELS.has(stack_risk_level):
			last_error = "M0 spawnPlanRules stackRiskLevelByIntent level is invalid: %s/%s" % [intent_id, stack_risk_level]
			return false

	var critical_warning_tags_by_intent = spawn_plan_rules.get("criticalWarningTagsByIntent", {})
	if typeof(critical_warning_tags_by_intent) != TYPE_DICTIONARY:
		last_error = "M0 spawnPlanRules criticalWarningTagsByIntent must be an object."
		return false

	for intent_id in critical_warning_tags_by_intent.keys():
		if not wave_intents.has(str(intent_id)):
			last_error = "M0 spawnPlanRules criticalWarningTagsByIntent references missing intent: %s" % intent_id
			return false

		var raw_warning_tags = critical_warning_tags_by_intent[intent_id]
		if typeof(raw_warning_tags) != TYPE_ARRAY:
			last_error = "M0 spawnPlanRules criticalWarningTagsByIntent must store arrays: %s" % intent_id
			return false

		var warning_tags: Array = raw_warning_tags
		if warning_tags.is_empty():
			last_error = "M0 spawnPlanRules criticalWarningTagsByIntent cannot be empty: %s" % intent_id
			return false

		for warning_tag in warning_tags:
			if str(warning_tag).is_empty():
				last_error = "M0 spawnPlanRules criticalWarningTagsByIntent contains an empty tag: %s" % intent_id
				return false

	for validation_enemy_id in enemies_data.keys():
		var enemy_data: Dictionary = enemies_data[validation_enemy_id]
		if str(enemy_data.get("label", "")).is_empty():
			last_error = "M0 enemy label is missing: %s" % validation_enemy_id
			return false

		if int(enemy_data.get("hp", 0)) <= 0:
			last_error = "M0 enemy hp must be positive: %s" % validation_enemy_id
			return false

		if float(enemy_data.get("speedTilesPerSecond", 0.0)) <= 0.0:
			last_error = "M0 enemy speedTilesPerSecond must be positive: %s" % validation_enemy_id
			return false

		if int(enemy_data.get("baseDamage", 0)) <= 0:
			last_error = "M0 enemy baseDamage must be positive: %s" % validation_enemy_id
			return false

		if int(enemy_data.get("structureDamage", 0)) <= 0:
			last_error = "M0 enemy structureDamage must be positive: %s" % validation_enemy_id
			return false

		var phase_threshold = int(enemy_data.get("phaseHpThreshold", 0))
		var phase_pulse_damage = int(enemy_data.get("phasePulseDamage", 0))
		var phase_pulse_radius = int(enemy_data.get("phasePulseRadius", 0))
		var siege_interval = int(enemy_data.get("siegeGazeIntervalSteps", 0))
		var siege_damage = int(enemy_data.get("siegeGazeDamage", 0))
		var siege_range = int(enemy_data.get("siegeGazeRange", 0))
		if phase_threshold < 0 or phase_pulse_damage < 0 or phase_pulse_radius < 0:
			last_error = "M0 enemy phase values cannot be negative: %s" % validation_enemy_id
			return false

		if int(enemy_data.get("moveSteps", 1)) <= 0:
			last_error = "M0 enemy moveSteps must be positive: %s" % validation_enemy_id
			return false

		if int(enemy_data.get("damageReduction", 0)) < 0:
			last_error = "M0 enemy damageReduction cannot be negative: %s" % validation_enemy_id
			return false

		if phase_threshold > 0 or phase_pulse_damage > 0 or phase_pulse_radius > 0:
			if phase_threshold <= 0 or phase_pulse_damage <= 0 or phase_pulse_radius <= 0:
				last_error = "M0 enemy phase pulse fields must all be positive together: %s" % validation_enemy_id
				return false

			if phase_threshold >= int(enemy_data.get("hp", 0)):
				last_error = "M0 enemy phaseHpThreshold must be lower than hp: %s" % validation_enemy_id
				return false

		if siege_interval < 0 or siege_damage < 0 or siege_range < 0:
			last_error = "M0 enemy siege gaze values cannot be negative: %s" % validation_enemy_id
			return false

		if siege_interval > 0 or siege_damage > 0 or siege_range > 0:
			if siege_interval <= 0 or siege_damage <= 0 or siege_range <= 0:
				last_error = "M0 enemy siege gaze fields must all be positive together: %s" % validation_enemy_id
				return false

		if bool(enemy_data.get("boss", false)):
			for part_value in enemy_data.get("bossParts", []):
				if typeof(part_value) != TYPE_DICTIONARY:
					last_error = "M0 boss part must be a dictionary: %s" % validation_enemy_id
					return false

				var part_data: Dictionary = part_value
				if str(part_data.get("id", "")).is_empty():
					last_error = "M0 boss part id is missing: %s" % validation_enemy_id
					return false

				if str(part_data.get("label", "")).is_empty():
					last_error = "M0 boss part label is missing: %s" % validation_enemy_id
					return false

				if int(part_data.get("hp", 0)) <= 0:
					last_error = "M0 boss part hp must be positive: %s" % str(part_data.get("id", "part"))
					return false

				if int(part_data.get("priority", 0)) <= 0:
					last_error = "M0 boss part priority must be positive: %s" % str(part_data.get("id", "part"))
					return false

				var part_effects: Dictionary = part_data.get("effects", {})
				for effect_key in part_effects.keys():
					if int(part_effects.get(effect_key, 0)) < 0:
						last_error = "M0 boss part effect cannot be negative: %s.%s" % [
							str(part_data.get("id", "part")),
							str(effect_key),
						]
						return false

	var debug_data: Dictionary = data.get("debug", {})
	var default_player_count = int(debug_data.get("defaultPlayerCount", 1))
	if default_player_count < 1 or default_player_count > 4:
		last_error = "M0 defaultPlayerCount must be between 1 and 4."
		return false

	if get_auto_step_interval() <= 0.0:
		last_error = "M0 autoStepIntervalSec must be positive."
		return false

	if get_autoplay_rounds() <= 0:
		last_error = "M0 autoplayRounds must be positive."
		return false

	if get_autoplay_boss_rounds() < get_autoplay_rounds():
		last_error = "M0 autoplayBossRounds must be greater than or equal to autoplayRounds."
		return false

	if get_autoplay_max_steps_per_round() <= 0:
		last_error = "M0 autoplayMaxStepsPerRound must be positive."
		return false

	if get_autoplay_cards_per_round() <= 0:
		last_error = "M0 autoplayCardsPerRound must be positive."
		return false

	if get_tutorial_rounds() < 0:
		last_error = "M0 tutorialRounds cannot be negative."
		return false

	var autoplay_class_ids: Array = debug_data.get("autoplayClassIds", [])
	if autoplay_class_ids.is_empty():
		last_error = "M0 autoplayClassIds cannot be empty."
		return false

	for class_id in autoplay_class_ids:
		if not classes_data.has(str(class_id)):
			last_error = "M0 autoplayClassIds references missing class: %s" % class_id
			return false

	return true


func _add_range_cells(cells: Dictionary, center: Vector2i, distance: int) -> void:
	for y in range(center.y - distance, center.y + distance + 1):
		for x in range(center.x - distance, center.x + distance + 1):
			var tile = Vector2i(x, y)
			var manhattan = abs(tile.x - center.x) + abs(tile.y - center.y)
			if manhattan <= distance and _is_in_bounds(tile):
				cells[_tile_key(tile)] = true


func _store_structure(tile: Vector2i, structure_type: String, class_id: String) -> void:
	var key = _tile_key(tile)
	var structure_id = "m0_basic_tower" if structure_type == "tower" else "m0_barricade"
	var structure_data: Dictionary = data.get("structures", {}).get(structure_id, {})
	var max_hp = int(structure_data.get("hp", 12)) + _structure_hp_bonus(structure_type, class_id)
	structures[key] = {
		"type": structure_type,
		"tile": tile,
		"hp": max_hp,
		"max_hp": max_hp,
		"class_id": class_id,
	}
	run_stats["structures_placed"] = int(run_stats.get("structures_placed", 0)) + 1
	_increment_bucket_stat("structures_placed_by_class", class_id, 1)
	_increment_bucket_stat("structures_placed_by_type", structure_type, 1)
	if structure_type == "tower":
		_increment_bucket_stat("towers_placed_by_class", class_id, 1)
	elif structure_type == "barricade":
		_increment_bucket_stat("barricades_placed_by_class", class_id, 1)


func _find_path(start: Vector2i, blocked: Dictionary) -> Array[Vector2i]:
	if not _is_in_bounds(start) or blocked.has(_tile_key(start)):
		return []

	var base_cells = get_base_cells()
	var frontier: Array[Vector2i] = [start]
	var came_from = {}
	var visited = {}
	visited[_tile_key(start)] = true

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()

		for step in DIR_STEPS:
			var next = current + step
			var next_key = _tile_key(next)
			if visited.has(next_key) or not _is_in_bounds(next):
				continue

			came_from[next_key] = current
			visited[next_key] = true

			if base_cells.has(next):
				return _rebuild_path(start, next, came_from)

			if blocked.has(next_key):
				continue

			frontier.append(next)

	return []


func _find_path_to_adjacent_open_tile(start: Vector2i, target_tile: Vector2i, blocked: Dictionary) -> Array[Vector2i]:
	var best_path: Array[Vector2i] = []

	for step in DIR_STEPS:
		var approach_tile = target_tile + step
		if not _is_in_bounds(approach_tile):
			continue

		if blocked.has(_tile_key(approach_tile)):
			continue

		var path = _find_path_to_tile(start, approach_tile, blocked)
		if path.is_empty():
			continue

		if best_path.is_empty() or path.size() < best_path.size():
			best_path = path

	return best_path


func _find_path_to_tile(start: Vector2i, goal: Vector2i, blocked: Dictionary) -> Array[Vector2i]:
	if not _is_in_bounds(start) or not _is_in_bounds(goal):
		return []

	if blocked.has(_tile_key(start)) or blocked.has(_tile_key(goal)):
		return []

	if start == goal:
		var direct_path: Array[Vector2i] = [start]
		return direct_path

	var frontier: Array[Vector2i] = [start]
	var came_from = {}
	var visited = {}
	visited[_tile_key(start)] = true

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()

		for step in DIR_STEPS:
			var next = current + step
			var next_key = _tile_key(next)
			if visited.has(next_key) or not _is_in_bounds(next) or blocked.has(next_key):
				continue

			came_from[next_key] = current
			visited[next_key] = true

			if next == goal:
				return _rebuild_path(start, goal, came_from)

			frontier.append(next)

	return []


func _rebuild_path(start: Vector2i, goal: Vector2i, came_from: Dictionary) -> Array[Vector2i]:
	var path: Array[Vector2i] = [goal]
	var current = goal

	while current != start:
		current = came_from[_tile_key(current)]
		path.push_front(current)

	return path


func _blocked_tiles() -> Dictionary:
	var blocked = {}
	for key in structures.keys():
		blocked[key] = true
	return blocked


func _structure_hp_bonus(structure_type: String, class_id: String) -> int:
	var effects = get_class_effects(class_id)
	if structure_type == "tower":
		return int(effects.get("towerHpBonus", 0))
	if structure_type == "barricade":
		return int(effects.get("barricadeHpBonus", 0))
	return 0


func _entrance_tile(direction: String) -> Vector2i:
	var coord: Array = get_entrances().get(direction, [0, 0])
	return Vector2i(int(coord[0]), int(coord[1]))


func _is_entrance_tile(tile: Vector2i) -> bool:
	for coord in get_entrances().values():
		if tile == Vector2i(int(coord[0]), int(coord[1])):
			return true
	return false


func _entrance_direction_for_tile(tile: Vector2i) -> String:
	for direction in get_entrances().keys():
		var coord: Array = get_entrances()[direction]
		if tile == Vector2i(int(coord[0]), int(coord[1])):
			return str(direction)
	return ""


func _is_in_bounds(tile: Vector2i) -> bool:
	var map_size = get_map_size()
	return tile.x >= 0 and tile.y >= 0 and tile.x < map_size.x and tile.y < map_size.y


func _get_spawn_count(round_number = -1) -> int:
	var target_round = round_number
	if target_round <= 0:
		target_round = active_round if wave_active else current_round

	var boss_count = 1 if _is_boss_round(target_round) else 0
	return _get_normal_spawn_count(target_round) + boss_count


func _add_active_wave_packet(round_number: int, stacked: bool, player_count: int = 1) -> void:
	var active_directions = _array_string_values(get_active_directions(player_count))
	var spawn_plan = get_wave_spawn_plan_report(player_count, round_number)
	var projected_directions = _array_string_values(spawn_plan.get("directions", []))
	if projected_directions.is_empty():
		projected_directions = _wave_spawn_directions_for_round_number(player_count, active_directions, round_number)
	var wave_intent = spawn_plan.get("waveIntent", get_wave_intent_report(round_number))
	active_wave_packets.append({
		"round": round_number,
		"spawned": 0,
		"total": int(spawn_plan.get("totalSpawnCount", _get_spawn_count(round_number))),
		"stacked": stacked,
		"active_directions": active_directions.duplicate(),
		"directions": projected_directions.duplicate(),
		"waveIntentId": str(wave_intent.get("waveIntentId", "")),
		"laneProjectionId": str(spawn_plan.get("laneProjectionId", _lane_projection_id(round_number, player_count))),
		"spawnPlanId": str(spawn_plan.get("spawnPlanId", _wave_spawn_plan_id(round_number))),
		"spawnPlan": spawn_plan,
		"spawnPackets": spawn_plan.get("spawnPackets", []),
	})


func _next_stack_round() -> int:
	if active_wave_packets.is_empty():
		return current_round + 1

	return _highest_active_round() + 1


func _highest_active_round() -> int:
	var highest = active_round
	for packet in active_wave_packets:
		highest = max(highest, int(packet.get("round", 0)))
	return highest


func _all_active_wave_packets_spawned() -> bool:
	if active_wave_packets.is_empty():
		return false

	for packet in active_wave_packets:
		if int(packet.get("spawned", 0)) < int(packet.get("total", 0)):
			return false

	return true


func _active_wave_rounds() -> Array[int]:
	var rounds: Array[int] = []
	for packet in active_wave_packets:
		rounds.append(int(packet.get("round", 0)))
	rounds.sort()
	return rounds


func _active_wave_total_spawn_count() -> int:
	var total = 0
	for packet in active_wave_packets:
		total += int(packet.get("total", 0))
	return total


func _active_wave_round_label() -> String:
	var labels = PackedStringArray()
	for round_number in _active_wave_rounds():
		labels.append(str(round_number))
	return "+".join(labels)


func _update_max_wave_stack_depth() -> void:
	run_stats["max_wave_stack_depth"] = max(
		int(run_stats.get("max_wave_stack_depth", 0)),
		get_active_wave_stack_depth()
	)


func _add_stacked_discard_charge() -> void:
	var old_charges = discard_charges
	discard_charges = min(get_discard_charge_cap(), discard_charges + get_discard_charges_per_run())
	if discard_charges > old_charges:
		run_stats["discard_refills"] = int(run_stats.get("discard_refills", 0)) + 1


func _is_base_critical_for_stack_vote() -> bool:
	var base_max = max(1, int(data.get("base", {}).get("hp", 100)))
	return float(base_hp) / float(base_max) <= 0.3


func _wave_stack_vote_rule_label(player_count: int) -> String:
	if player_count <= 1:
		return "solo"
	if _is_base_critical_for_stack_vote():
		return "unanimous"
	return "majority"


func _active_tutorial_hint(player_count: int, tutorial_rounds: int) -> Dictionary:
	var step = min(tutorial_rounds, max(1, active_round))
	var base_max = max(1, int(data.get("base", {}).get("hp", 100)))
	var base_percent = float(base_hp) / float(base_max)
	if base_percent <= 0.3:
		return _tutorial_hint(
			true,
			"base_critical",
			step,
			"Base is in danger.",
			"Stop adding risk. The next leak can end the run.",
			"Spend damage, repair, or block the nearest critical front.",
			"danger"
		)

	if _active_boss_count() > 0:
		return _tutorial_hint(
			true,
			"boss_active",
			step,
			"Read the boss intent.",
			"Bosses are slow, but their patterns punish weak structures before they reach base.",
			"Use the intent marker to repair or burst the boss target.",
			"warning"
		)

	var worst_front = _worst_front_pressure(player_count)
	var worst_severity = str(worst_front.get("severity", "idle"))
	if worst_severity == "critical" or worst_severity == "danger":
		return _tutorial_hint(
			true,
			"front_pressure",
			step,
			"Answer the hottest front.",
			"%s is %s. Enemy intent markers show the next tile or target." % [
				_direction_label(str(worst_front.get("direction", ""))),
				worst_severity,
			],
			"Play damage, repair, or place a delay piece on that front.",
			"warning"
		)

	var stack_report = get_wave_stack_risk_report(player_count)
	if bool(stack_report.get("can_call", false)) and str(stack_report.get("severity", "")) == "stable":
		return _tutorial_hint(
			true,
			"stable_stack",
			step,
			"The defense is stable.",
			"Early call is for reducing downtime, not for extra reward.",
			"Try Pull next wave if everyone agrees, or keep stepping to finish safely.",
			"info"
		)

	return _tutorial_hint(
		true,
		"read_intents",
		step,
		"Follow enemy intents.",
		"Green card targets show what you can play. Intent borders show what enemies will do next.",
		"Spend one useful card before the wave reaches the base.",
		"info"
	)


func _tutorial_hint(visible: bool, stage: String, step: int, title: String, body: String, action: String, severity: String) -> Dictionary:
	return {
		"visible": visible,
		"stage": stage,
		"step": step,
		"title": title,
		"body": body,
		"action": action,
		"severity": severity,
	}


func _wave_stack_risk_blocked(reason: String) -> Dictionary:
	var next_round = _next_stack_round()
	var details: Array = [reason]
	var reason_label = _wave_stack_risk_detail_label(reason)
	return {
		"can_call": false,
		"severity": "blocked",
		"score": 0,
		"round": next_round,
		"headline": "Pull next blocked: %s." % reason_label,
		"suggestion": _wave_stack_blocked_suggestion(reason),
		"tempo_line": _wave_stack_tempo_line(next_round),
		"no_bonus": true,
		"details": details,
		"detail_labels": _wave_stack_risk_detail_labels(details),
	}


func _wave_stack_tempo_line(round_number: int) -> String:
	if round_number > get_max_rounds():
		return "Tempo only: no later wave to pull. No bonus rewards."

	return "Tempo only: pull round %s forward. No bonus rewards." % round_number


func _wave_stack_risk_detail_labels(detail_values) -> PackedStringArray:
	var labels = PackedStringArray()
	for detail_value in detail_values:
		labels.append(_wave_stack_risk_detail_label(str(detail_value)))
	return labels


func _wave_stack_risk_detail_label(detail: String) -> String:
	if detail == "base_critical":
		return "base HP critical"
	if detail == "base_low":
		return "base HP low"
	if detail == "boss_active":
		return "boss active"
	if detail == "last_stack_slot":
		return "last stack slot"
	if detail == "already_stacked":
		return "already stacked"
	if detail == "wave_not_active":
		return "wave not active"
	if detail == "reward_pending":
		return "reward pending"
	if detail == "stack_limit_reached":
		return "stack limit reached"
	if detail == "no_next_round":
		return "no next wave"
	if detail == "data_not_loaded":
		return "data not loaded"
	if detail.begins_with("front_critical:"):
		return "critical front: %s" % _direction_label(detail.substr("front_critical:".length()))
	if detail.begins_with("front_danger:"):
		return "danger front: %s" % _direction_label(detail.substr("front_danger:".length()))
	if detail.begins_with("critical_structures="):
		return "critical structures: %s" % detail.substr("critical_structures=".length())
	if detail.begins_with("damaged_structures="):
		return "damaged structures: %s" % detail.substr("damaged_structures=".length())
	if detail.begins_with("enemy_density_high="):
		return "enemy density high: %s enemies" % detail.substr("enemy_density_high=".length())
	if detail.begins_with("enemy_density_medium="):
		return "enemy density rising: %s enemies" % detail.substr("enemy_density_medium=".length())
	if detail.begins_with("hand_pressure_draw_held="):
		return "hand draw held: %s" % detail.substr("hand_pressure_draw_held=".length())
	if detail.begins_with("hand_pressure_hand_full="):
		return "hand full: %s" % detail.substr("hand_pressure_hand_full=".length())
	if detail.begins_with("hand_pressure_near_full="):
		return "hand near full: %s" % detail.substr("hand_pressure_near_full=".length())
	if detail.begins_with("hand_pressure_full_no_draw="):
		return "hand full soon: %s" % detail.substr("hand_pressure_full_no_draw=".length())
	if detail.begins_with("large_next_wave="):
		return "large next wave: %s enemies" % detail.substr("large_next_wave=".length())
	return detail.replace("_", " ")


func _wave_stack_risk_severity(score: int) -> String:
	if score >= 5:
		return "critical"
	if score >= 2:
		return "risky"
	return "stable"


func _wave_stack_risk_suggestion(severity: String) -> String:
	match severity:
		"critical":
			return "Hold the pull; repair, rebuild, or spend the current hand first."
		"risky":
			return "Pull only if the group has a repair or discard plan ready."
		_:
			return "Pulling is reasonable if the group wants less waiting."


func _wave_pull_watch_labels(detail_values) -> PackedStringArray:
	var labels = PackedStringArray()
	for detail_value in detail_values:
		var label = str(detail_value)
		if label.is_empty():
			continue
		labels.append(label)
		if labels.size() >= 3:
			break

	return labels


func _wave_pull_decision_label(can_call: bool, severity: String) -> String:
	if has_active_wave_stack_vote():
		return "vote open"
	if not can_call:
		return "wait" if severity == "idle" else "blocked"

	match severity:
		"critical":
			return "hold"
		"risky":
			return "prepare"
		_:
			return "pull"


func _wave_pull_decision_next_step(can_call: bool, severity: String, risk_report: Dictionary) -> String:
	if has_active_wave_stack_vote():
		return "Approve or Hold after checking the watch labels."
	if not can_call:
		return str(risk_report.get("suggestion", "Resolve the current state before pulling."))

	match severity:
		"critical":
			return "Hold is a tactical response; repair, rebuild, or spend the hand first."
		"risky":
			return "Agree on the repair, discard, or damage answer before pulling."
		_:
			return "Pull for tempo if the group wants less waiting."


func _wave_stack_blocked_suggestion(reason: String) -> String:
	match reason:
		"wave_not_active":
			return "Start the current wave first."
		"reward_pending":
			return "Resolve pending rewards before pulling another wave."
		"stack_limit_reached":
			return "The current stack is already at its limit."
		"no_next_round":
			return "There is no next wave to call."
		_:
			return "Resolve the blocked state before pulling another wave."


func _count_damaged_structures() -> int:
	var count = 0
	for structure in structures.values():
		if int(structure.get("hp", 0)) < int(structure.get("max_hp", 0)):
			count += 1
	return count


func _count_critical_structures() -> int:
	var count = 0
	for structure in structures.values():
		var max_hp = max(1, int(structure.get("max_hp", 1)))
		var hp = int(structure.get("hp", 0))
		if float(hp) / float(max_hp) <= 0.35:
			count += 1
	return count


func _active_boss_count() -> int:
	var count = 0
	for enemy in enemies:
		if _is_boss_enemy(enemy):
			count += 1
	return count


func _worst_front_pressure(player_count: int) -> Dictionary:
	var best = {}
	var best_rank = -1
	for front in get_front_pressure(player_count):
		var rank = _front_pressure_rank(str(front.get("severity", "idle")))
		if rank > best_rank:
			best = front
			best_rank = rank
	return best


func _front_defense_coverage_for_path(path: Array) -> Dictionary:
	var coverage = {
		"structure_count": 0,
		"tower_count": 0,
		"barricade_count": 0,
		"damaged_count": 0,
		"critical_count": 0,
		"total_hp": 0,
	}
	if path.is_empty():
		return coverage

	for structure_value in structures.values():
		if typeof(structure_value) != TYPE_DICTIONARY:
			continue

		var structure: Dictionary = structure_value
		var tile_value = structure.get("tile", Vector2i(-1, -1))
		if typeof(tile_value) != TYPE_VECTOR2I:
			continue

		var tile: Vector2i = tile_value
		if _min_distance_to_path_prefix(tile, path, FRONT_DEFENSE_PATH_DEPTH) > FRONT_DEFENSE_RADIUS:
			continue

		var max_hp = max(1, int(structure.get("max_hp", 1)))
		var hp = int(structure.get("hp", 0))
		coverage["structure_count"] = int(coverage.get("structure_count", 0)) + 1
		coverage["total_hp"] = int(coverage.get("total_hp", 0)) + hp
		if str(structure.get("type", "")) == "tower":
			coverage["tower_count"] = int(coverage.get("tower_count", 0)) + 1
		elif str(structure.get("type", "")) == "barricade":
			coverage["barricade_count"] = int(coverage.get("barricade_count", 0)) + 1
		if hp < max_hp:
			coverage["damaged_count"] = int(coverage.get("damaged_count", 0)) + 1
		if float(hp) / float(max_hp) <= 0.35:
			coverage["critical_count"] = int(coverage.get("critical_count", 0)) + 1

	return coverage


func _min_distance_to_path_prefix(tile: Vector2i, path: Array, path_depth: int) -> int:
	var best_distance = 999999
	var limit = min(path.size(), max(1, path_depth))
	for index in range(limit):
		var path_tile_value = path[index]
		if typeof(path_tile_value) != TYPE_VECTOR2I:
			continue

		var path_tile: Vector2i = path_tile_value
		var distance = abs(tile.x - path_tile.x) + abs(tile.y - path_tile.y)
		if distance < best_distance:
			best_distance = distance

	return best_distance


func _front_direction_stat_report(direction: String) -> Dictionary:
	return {
		"base_hits": _direction_bucket_stat("base_hits_by_direction", direction),
		"boss_base_hits": _direction_bucket_stat("boss_base_hits_by_direction", direction),
		"base_damage": _direction_bucket_stat("base_damage_by_direction", direction),
		"structures_destroyed": _direction_bucket_stat("structures_destroyed_by_direction", direction),
		"planned_collapses": _direction_bucket_stat("planned_collapses_by_direction", direction),
		"planned_collapse_damage": _direction_bucket_stat("planned_collapse_damage_by_direction", direction),
	}


func _direction_bucket_stat(stat_key: String, direction: String) -> int:
	var bucket: Dictionary = run_stats.get(stat_key, {})
	return int(bucket.get(direction, 0))


func _front_defense_score(entry: Dictionary) -> int:
	var structure_score = int(entry.get("structure_count", 0)) * 20
	var tower_score = int(entry.get("tower_count", 0)) * 8
	var barricade_score = int(entry.get("barricade_count", 0)) * 6
	var hp_score = int(entry.get("total_hp", 0))
	var pressure_penalty = int(entry.get("pressure_rank", 0)) * 20
	var leak_penalty = int(entry.get("base_hits", 0)) * 4 + int(entry.get("base_damage", 0))
	var collapse_penalty = int(entry.get("structures_destroyed", 0)) * 3
	var critical_penalty = int(entry.get("critical_count", 0)) * 12
	return structure_score + tower_score + barricade_score + hp_score - pressure_penalty - leak_penalty - collapse_penalty - critical_penalty


func _front_defense_priority(fronts: Array) -> Array:
	var remaining = fronts.duplicate(true)
	var directions: Array = []
	while not remaining.is_empty():
		var selected_index = 0
		for index in range(1, remaining.size()):
			if _front_defense_entry_is_weaker(remaining[index], remaining[selected_index]):
				selected_index = index

		var selected: Dictionary = remaining[selected_index]
		directions.append(str(selected.get("direction", "")))
		remaining.remove_at(selected_index)

	return directions


func _front_defense_entry_is_weaker(candidate_value, current_value) -> bool:
	if typeof(candidate_value) != TYPE_DICTIONARY:
		return false
	if typeof(current_value) != TYPE_DICTIONARY:
		return true

	var candidate: Dictionary = candidate_value
	var current: Dictionary = current_value
	if int(candidate.get("boss_base_hits", 0)) != int(current.get("boss_base_hits", 0)):
		return int(candidate.get("boss_base_hits", 0)) > int(current.get("boss_base_hits", 0))
	if int(candidate.get("base_hits", 0)) != int(current.get("base_hits", 0)):
		return int(candidate.get("base_hits", 0)) > int(current.get("base_hits", 0))
	if int(candidate.get("pressure_rank", 0)) != int(current.get("pressure_rank", 0)):
		if max(int(candidate.get("pressure_rank", 0)), int(current.get("pressure_rank", 0))) >= 2:
			return int(candidate.get("pressure_rank", 0)) > int(current.get("pressure_rank", 0))
	if int(candidate.get("structures_destroyed", 0)) != int(current.get("structures_destroyed", 0)):
		return int(candidate.get("structures_destroyed", 0)) > int(current.get("structures_destroyed", 0))
	if bool(candidate.get("needs_minimum_defense", false)) != bool(current.get("needs_minimum_defense", false)):
		return bool(candidate.get("needs_minimum_defense", false))
	if int(candidate.get("pressure_rank", 0)) != int(current.get("pressure_rank", 0)):
		return int(candidate.get("pressure_rank", 0)) > int(current.get("pressure_rank", 0))
	if int(candidate.get("structure_count", 0)) != int(current.get("structure_count", 0)):
		return int(candidate.get("structure_count", 0)) < int(current.get("structure_count", 0))
	if int(candidate.get("base_hits", 0)) != int(current.get("base_hits", 0)):
		return int(candidate.get("base_hits", 0)) > int(current.get("base_hits", 0))
	if int(candidate.get("score", 0)) != int(current.get("score", 0)):
		return int(candidate.get("score", 0)) < int(current.get("score", 0))
	return int(candidate.get("order_index", 0)) < int(current.get("order_index", 0))


func _front_defense_summary(entry: Dictionary) -> String:
	var status = "needs setup" if bool(entry.get("needs_minimum_defense", false)) else "covered"
	var planned_text = ""
	if int(entry.get("planned_collapses", 0)) > 0:
		planned_text = ", planned %s/%s" % [
			entry.get("planned_collapses", 0),
			entry.get("planned_collapse_damage", 0),
		]
	return "%s %s: structures %s, pressure %s, hits %s, lost %s%s" % [
		entry.get("direction", "front"),
		status,
		entry.get("structure_count", 0),
		entry.get("pressure_severity", "idle"),
		entry.get("base_hits", 0),
		entry.get("structures_destroyed", 0),
		planned_text,
	]


func _front_defense_report_summary(fronts: Array) -> String:
	var parts = PackedStringArray()
	for front in fronts:
		if typeof(front) != TYPE_DICTIONARY:
			continue

		var front_dictionary: Dictionary = front
		parts.append(str(front_dictionary.get("summary", "")))

	if parts.is_empty():
		return "Defense fronts: none"
	return "Defense fronts: %s" % " | ".join(parts)


func _front_recommendation_candidates_for_direction(
	direction: String,
	path: Array,
	front_entry: Dictionary,
	structure_type: String,
	player_count: int,
	class_id: String
) -> Array:
	var candidates: Array = []
	if path.is_empty():
		return candidates

	var seen = {}
	var offsets = _front_recommendation_offsets(structure_type)
	var path_limit = min(path.size(), FRONT_RECOMMENDATION_PATH_DEPTH)
	for path_index in range(1, path_limit):
		var path_tile_value = path[path_index]
		if typeof(path_tile_value) != TYPE_VECTOR2I:
			continue

		var path_tile: Vector2i = path_tile_value
		for offset_value in offsets:
			if typeof(offset_value) != TYPE_VECTOR2I:
				continue

			var offset: Vector2i = offset_value
			var tile = path_tile + offset
			var distance_from_path = abs(offset.x) + abs(offset.y)
			var key = _tile_key(tile)
			if seen.has(key):
				continue

			seen[key] = true
			var placement = can_place_structure(tile, structure_type, player_count, class_id)
			if not bool(placement.get("ok", false)):
				continue

			var why = _front_recommendation_reason(structure_type, direction, front_entry, path_index, distance_from_path)
			var details = _front_recommendation_details(structure_type, direction, front_entry, path_index, distance_from_path)
			var intent = _front_recommendation_intent(front_entry)
			candidates.append({
				"valid": true,
				"recommended": true,
				"tile": tile,
				"direction": direction,
				"structure_type": structure_type,
				"intent": intent,
				"rebuild": intent.begins_with("rebuild"),
				"path_index": path_index,
				"distance_from_path": distance_from_path,
				"why": why,
				"details": details,
				"summary": "%s candidate for %s front at %s. %s" % [
					structure_type.capitalize(),
					direction,
					_tile_text(tile),
					why,
				],
			})
			if candidates.size() >= FRONT_RECOMMENDATION_LIMIT:
				return candidates

	return candidates


func _front_recommendation_offsets(structure_type: String) -> Array:
	if structure_type == "barricade":
		return [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(-1, 0),
			Vector2i(0, 1),
			Vector2i(0, -1),
			Vector2i(1, 1),
			Vector2i(-1, -1),
		]

	return [
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(1, 1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(-1, -1),
		Vector2i(0, 0),
	]


func _front_recommendation_intent(front_entry: Dictionary) -> String:
	if int(front_entry.get("structures_destroyed", 0)) > 0:
		if int(front_entry.get("planned_collapses", 0)) >= int(front_entry.get("structures_destroyed", 0)) and int(front_entry.get("planned_collapse_damage", 0)) > 0:
			return "rebuild_planned_collapse"
		return "rebuild_lost_structure"
	if int(front_entry.get("base_hits", 0)) > 0:
		return "reinforce_leak"
	if int(front_entry.get("pressure_rank", 0)) >= 2:
		return "reinforce_pressure"
	if bool(front_entry.get("needs_minimum_defense", false)):
		return "setup_gap"
	return "setup_lowest"


func _front_recommendation_reason(
	structure_type: String,
	direction: String,
	front_entry: Dictionary,
	path_index: int,
	distance_from_path: int
) -> String:
	var action = "delay" if structure_type == "barricade" else "cover"
	if bool(front_entry.get("needs_minimum_defense", false)):
		return "%s has no nearby structure; %s this lane before expanding elsewhere." % [direction, action.capitalize()]
	if int(front_entry.get("pressure_rank", 0)) >= 2:
		return "%s pressure is %s; add %s before the next wave pull." % [
			direction,
			front_entry.get("pressure_severity", "danger"),
			action,
		]
	if int(front_entry.get("base_hits", 0)) > 0:
		return "%s has leaked %s time(s); reinforce its early path." % [
			direction,
			front_entry.get("base_hits", 0),
		]
	if int(front_entry.get("structures_destroyed", 0)) > 0:
		if int(front_entry.get("planned_collapses", 0)) >= int(front_entry.get("structures_destroyed", 0)) and int(front_entry.get("planned_collapse_damage", 0)) > 0:
			return "%s spent %s planned collapse(s) for %s damage; rebuild that pocket." % [
				direction,
				front_entry.get("planned_collapses", 0),
				front_entry.get("planned_collapse_damage", 0),
			]
		return "%s lost %s structure(s); rebuild the front pocket." % [
			direction,
			front_entry.get("structures_destroyed", 0),
		]

	return "%s is lowest priority score; this tile is step %s, distance %s from path." % [
		direction,
		path_index,
		distance_from_path,
	]


func _front_recommendation_details(
	structure_type: String,
	direction: String,
	front_entry: Dictionary,
	path_index: int,
	distance_from_path: int
) -> Array:
	var details: Array = []
	details.append("front=%s" % direction)
	details.append("structure=%s" % structure_type)
	details.append("coverage=%s/%s" % [
		front_entry.get("structure_count", 0),
		front_entry.get("minimum_structure_count", FRONT_MIN_STRUCTURE_COUNT),
	])
	details.append("pressure=%s" % front_entry.get("pressure_severity", "idle"))
	details.append("leaks=%s" % front_entry.get("base_hits", 0))
	details.append("lost=%s" % front_entry.get("structures_destroyed", 0))
	if int(front_entry.get("planned_collapses", 0)) > 0:
		details.append("planned=%s/%s" % [
			front_entry.get("planned_collapses", 0),
			front_entry.get("planned_collapse_damage", 0),
		])
	details.append("path_step=%s" % path_index)
	details.append("path_distance=%s" % distance_from_path)
	return details


func _front_recommendation_summary(structure_type: String, direction: String, candidate_count: int, front_entry: Dictionary = {}) -> String:
	if candidate_count <= 0:
		return "Recommendation: no valid %s tile found near active fronts." % structure_type

	var reason = _front_recommendation_reason(structure_type, direction, front_entry, 0, 0)
	var prefix = "Rebuild recommendation" if _front_recommendation_intent(front_entry).begins_with("rebuild") else "Recommendation"
	return "%s: %s %s tile(s) on %s front. %s" % [
		prefix,
		structure_type.capitalize(),
		candidate_count,
		direction,
		reason,
	]


func _front_pressure_rank(severity: String) -> int:
	match severity:
		"critical":
			return 3
		"danger":
			return 2
		"watch":
			return 1
		_:
			return 0


func _get_normal_spawn_count(round_number: int) -> int:
	var wave: Dictionary = data.get("wave", {})
	var base_count = int(wave.get("spawnCount", 0))
	var growth = int(wave.get("spawnGrowthPerRound", 0))
	return base_count + max(0, round_number - 1) * growth


func _build_wave_spawn_plan(player_count: int, round_number: int, active_directions: Array) -> Dictionary:
	var normalized_player_count = clamp(player_count, 1, 4)
	var resolved_active_directions = _array_string_values(active_directions)
	if resolved_active_directions.is_empty():
		resolved_active_directions = _array_string_values(get_active_directions(normalized_player_count))
	if resolved_active_directions.is_empty():
		return _reject("no_active_direction")

	var lane_projection = get_lane_projection_report(normalized_player_count, round_number)
	if not bool(lane_projection.get("ok", false)):
		return lane_projection

	var directions = _array_string_values(lane_projection.get("directions", []))
	if directions.is_empty():
		return _reject("no_projected_direction")

	var wave_intent = get_wave_intent_report(round_number)
	var wave_intent_id = str(wave_intent.get("waveIntentId", lane_projection.get("waveIntentId", "")))
	var primary_enemy_role = str(wave_intent.get("primaryEnemyRole", lane_projection.get("primaryEnemyRole", "swarm")))
	var enemy_sequence = _wave_spawn_enemy_sequence(round_number, primary_enemy_role)
	var spawn_packets = _wave_spawn_packets_for_sequence(round_number, directions, wave_intent_id, primary_enemy_role, enemy_sequence)
	var scaled_enemy_groups = _wave_scaled_enemy_groups(enemy_sequence)
	var budget_used = _wave_spawn_packets_budget_used(spawn_packets)
	var scaled_threat_budget = max(_wave_spawn_plan_budget_for_round(round_number), budget_used)
	var preview_response_tags = _wave_intent_prep_tags(wave_intent_id, _wave_preview_prep_tags(primary_enemy_role, directions.size()))
	var enemy_roles = _wave_enemy_role_tags(get_enemy_mix_ids(round_number), _boss_enemy_id() if _is_boss_round(round_number) else "")
	var uses_inactive = _wave_preview_uses_inactive_direction(directions, resolved_active_directions)
	return {
		"ok": true,
		"reason": "ok",
		"spawnPlanId": _wave_spawn_plan_id(round_number),
		"waveId": _wave_id(round_number),
		"day": round_number,
		"round": round_number,
		"playerCount": normalized_player_count,
		"playerCountAtStart": normalized_player_count,
		"activeDirections": resolved_active_directions.duplicate(),
		"directions": directions.duplicate(),
		"projectedDirections": directions.duplicate(),
		"laneProjectionId": str(lane_projection.get("laneProjectionId", "")),
		"laneProjection": lane_projection,
		"waveIntentId": wave_intent_id,
		"waveIntent": wave_intent,
		"previewQuestionTag": _wave_spawn_plan_question_tag(wave_intent_id, primary_enemy_role),
		"previewEnemyRoleProfileIds": _wave_spawn_role_profile_ids(enemy_roles),
		"previewResponseTags": preview_response_tags,
		"scaledThreatBudget": scaled_threat_budget,
		"budgetUsed": budget_used,
		"scaledEnemyGroups": scaled_enemy_groups,
		"enemyGroups": get_enemy_mix_ids(round_number),
		"spawnPackets": spawn_packets,
		"spawnPacketCount": spawn_packets.size(),
		"normalSpawnCount": _get_normal_spawn_count(round_number),
		"totalSpawnCount": enemy_sequence.size(),
		"bossEnemyId": _boss_enemy_id() if _is_boss_round(round_number) else "",
		"warnings": _wave_spawn_plan_warnings(round_number, directions, wave_intent),
		"criticalWarningTags": _wave_spawn_plan_critical_warning_tags(wave_intent_id),
		"stackRiskLevel": _wave_spawn_plan_stack_risk_level(wave_intent_id),
		"stackRiskReason": _wave_spawn_plan_stack_risk_reason(wave_intent_id, directions),
		"usesInactiveDirections": uses_inactive,
		"forbiddenSpawnPlanFields": WAVE_SPAWN_PLAN_FORBIDDEN_FIELDS.duplicate(),
		"noBonusRewards": true,
		"summary": _format_wave_spawn_plan_summary(round_number, directions, wave_intent, spawn_packets, budget_used, scaled_threat_budget),
	}


func _wave_spawn_plan_rules() -> Dictionary:
	return data.get("wave", {}).get("spawnPlanRules", {})


func _wave_spawn_plan_rule_dictionary(rule_key: String) -> Dictionary:
	var rules = _wave_spawn_plan_rules()
	var rule_value = rules.get(rule_key, {})
	if typeof(rule_value) == TYPE_DICTIONARY:
		return rule_value
	return {}


func _wave_spawn_plan_budget_for_round(round_number: int) -> int:
	var rules = _wave_spawn_plan_rules()
	var base_budget = int(rules.get("baseThreatBudget", _get_normal_spawn_count(1)))
	var growth = int(rules.get("threatBudgetGrowthPerRound", 1))
	var boss_budget = 0
	if _is_boss_round(round_number):
		boss_budget = _wave_spawn_budget_for_enemy_id(_boss_enemy_id())

	return base_budget + max(0, round_number - 1) * growth + boss_budget


func _wave_spawn_budget_for_enemy_id(enemy_id: String) -> int:
	var rules = _wave_spawn_plan_rules()
	var enemy_data = _enemy_data_by_id(enemy_id)
	if bool(enemy_data.get("boss", false)):
		return max(1, int(rules.get("bossEnemyBudget", 8)))
	return max(1, int(rules.get("normalEnemyBudget", 1)))


func _wave_spawn_enemy_sequence(round_number: int, primary_enemy_role: String) -> Array:
	var sequence: Array = []
	if _is_boss_round(round_number):
		var boss_enemy_id = _boss_enemy_id()
		if not boss_enemy_id.is_empty():
			sequence.append(boss_enemy_id)

	var normal_count = _get_normal_spawn_count(round_number)
	var pattern = _enemy_mix_pattern_for_round(round_number)
	if pattern.is_empty():
		pattern.append(_default_enemy_id())

	var front_loaded_enemy_id = _enemy_id_for_role_in_pattern(pattern, primary_enemy_role)
	var skip_front_loaded_once = false
	var normal_spawned = 0
	if not front_loaded_enemy_id.is_empty():
		sequence.append(front_loaded_enemy_id)
		normal_spawned += 1
		skip_front_loaded_once = true

	var pattern_index = 0
	while normal_spawned < normal_count:
		var enemy_id = str(pattern[pattern_index % pattern.size()])
		pattern_index += 1
		if skip_front_loaded_once and enemy_id == front_loaded_enemy_id:
			skip_front_loaded_once = false
			continue

		sequence.append(enemy_id)
		normal_spawned += 1

	return sequence


func _enemy_id_for_role_in_pattern(pattern: Array, role: String) -> String:
	if role == "boss":
		return ""

	for enemy_id_value in pattern:
		var enemy_id = str(enemy_id_value)
		var enemy_data = _enemy_data_by_id(enemy_id)
		if enemy_data.is_empty():
			continue

		if _wave_enemy_role_tag_for_data(enemy_data) == role:
			return enemy_id

	return ""


func _wave_spawn_packets_for_sequence(
	round_number: int,
	directions: Array,
	wave_intent_id: String,
	primary_enemy_role: String,
	enemy_sequence: Array
) -> Array:
	var packets: Array = []
	var spawn_directions = _array_string_values(directions)
	if spawn_directions.is_empty():
		return packets

	var interval_seconds = float(data.get("wave", {}).get("spawnIntervalSec", 1.0))
	for spawn_index in range(enemy_sequence.size()):
		var enemy_id = str(enemy_sequence[spawn_index])
		var direction = str(spawn_directions[spawn_index % spawn_directions.size()])
		var enemy_role = _wave_enemy_role_tag_for_data(_enemy_data_by_id(enemy_id))
		var direction_role = _wave_spawn_direction_role(wave_intent_id, primary_enemy_role, enemy_role)
		packets.append({
			"packetId": _wave_spawn_packet_id(round_number, spawn_index + 1),
			"enemyId": enemy_id,
			"enemyRole": enemy_role,
			"count": 1,
			"directionRole": direction_role,
			"directions": [direction],
			"firstSpawnTimeSeconds": float(spawn_index) * interval_seconds,
			"intervalSeconds": interval_seconds,
			"routeProfileId": _wave_spawn_route_profile_id(wave_intent_id, direction),
			"warningLeadTimeSeconds": _wave_spawn_warning_lead_time_seconds(),
			"budgetUsed": _wave_spawn_budget_for_enemy_id(enemy_id),
			"isOptionalAssistPacket": false,
			"forbiddenWhenStacked": false,
		})

	return packets


func _wave_spawn_packet_id(round_number: int, packet_number: int) -> String:
	return "spawn_packet_day_%s_%s" % [
		_round_id_suffix(round_number),
		_round_id_suffix(packet_number),
	]


func _wave_spawn_direction_role(wave_intent_id: String, primary_enemy_role: String, enemy_role: String) -> String:
	if enemy_role == "boss":
		return "boss"
	if enemy_role == "fast":
		return "fast"

	var by_intent = _wave_spawn_plan_rule_dictionary("directionRoleByIntent")
	var configured_role = str(by_intent.get(wave_intent_id, ""))
	if WAVE_SPAWN_DIRECTION_ROLES.has(configured_role):
		return configured_role

	match primary_enemy_role:
		"fast":
			return "fast"
		"structure_break":
			return "short"
		"armored":
			return "slow"
		"boss":
			return "boss"
		_:
			return "any"


func _wave_spawn_route_profile_id(wave_intent_id: String, direction: String) -> String:
	var by_intent = _wave_spawn_plan_rule_dictionary("routeProfileByIntent")
	var route_profile_id = str(by_intent.get(wave_intent_id, ""))
	if route_profile_id.is_empty():
		route_profile_id = str(_wave_spawn_plan_rules().get("defaultRouteProfileId", "route_active_main"))

	return "%s_%s" % [route_profile_id, direction]


func _wave_spawn_warning_lead_time_seconds() -> float:
	return max(0.0, float(_wave_spawn_plan_rules().get("defaultWarningLeadTimeSeconds", 2.0)))


func _wave_scaled_enemy_groups(enemy_sequence: Array) -> Array:
	var groups: Array = []
	var counts = {}
	var order: Array = []
	for enemy_id_value in enemy_sequence:
		var enemy_id = str(enemy_id_value)
		if not counts.has(enemy_id):
			counts[enemy_id] = 0
			order.append(enemy_id)
		counts[enemy_id] = int(counts.get(enemy_id, 0)) + 1

	for enemy_id in order:
		groups.append({
			"enemyId": enemy_id,
			"count": int(counts.get(enemy_id, 0)),
			"enemyRole": _wave_enemy_role_tag_for_data(_enemy_data_by_id(enemy_id)),
		})

	return groups


func _wave_spawn_packets_budget_used(spawn_packets: Array) -> int:
	var budget = 0
	for packet_value in spawn_packets:
		if typeof(packet_value) != TYPE_DICTIONARY:
			continue

		var packet: Dictionary = packet_value
		budget += int(packet.get("budgetUsed", 0))
	return budget


func _wave_spawn_role_profile_ids(enemy_roles: Array) -> Array:
	var ids: Array = []
	for role_value in enemy_roles:
		var role = str(role_value)
		var profile_id = "enemy_role_profile_%s" % role
		if not ids.has(profile_id):
			ids.append(profile_id)
	return ids


func _wave_spawn_plan_question_tag(wave_intent_id: String, primary_enemy_role: String) -> String:
	match wave_intent_id:
		"intent_route_read":
			return "route_read"
		"intent_fast_response":
			return "runner_burst"
		"intent_planned_structure_break":
			return "planned_collapse"
		"intent_path_stretch":
			return "path_extend"
		"intent_swarm_compression":
			return "swarm_clear"
		"intent_final_focus":
			return "final_focus"
		_:
			return primary_enemy_role


func _wave_spawn_plan_critical_warning_tags(wave_intent_id: String) -> Array:
	var by_intent = _wave_spawn_plan_rule_dictionary("criticalWarningTagsByIntent")
	var raw_tags = by_intent.get(wave_intent_id, [])
	if typeof(raw_tags) == TYPE_ARRAY:
		return _array_string_values(raw_tags)
	return []


func _wave_spawn_plan_stack_risk_level(wave_intent_id: String) -> String:
	var by_intent = _wave_spawn_plan_rule_dictionary("stackRiskLevelByIntent")
	var risk_level = str(by_intent.get(wave_intent_id, "low"))
	if WAVE_STACK_RISK_LEVELS.has(risk_level):
		return risk_level
	return "low"


func _wave_spawn_plan_stack_risk_reason(wave_intent_id: String, directions: Array) -> String:
	var direction_text = _join_values(directions)
	match _wave_spawn_plan_stack_risk_level(wave_intent_id):
		"high":
			return "High pressure on %s; pulling this plan early can blur boss focus." % direction_text
		"medium":
			return "Medium pressure on %s; pull only if the current front is stable." % direction_text
		"locked":
			return "This spawn plan should not be pulled early."
		_:
			return "Tempo-only pull on %s; no bonus rewards." % direction_text


func _wave_spawn_plan_warnings(round_number: int, directions: Array, wave_intent: Dictionary) -> Array:
	var warnings: Array = []
	warnings.append("R%s %s" % [
		round_number,
		wave_intent.get("label", wave_intent.get("waveIntentId", "wave")),
	])
	warnings.append("Spawns from %s" % _join_values(directions))
	var question = str(wave_intent.get("question", ""))
	if not question.is_empty():
		warnings.append(question)
	return warnings


func _wave_spawn_packet_ref_for_spawn_index(spawn_plan: Dictionary, spawn_index: int) -> Dictionary:
	var spawn_packets: Array = spawn_plan.get("spawnPackets", [])
	var cursor = 0
	for packet_value in spawn_packets:
		if typeof(packet_value) != TYPE_DICTIONARY:
			continue

		var packet: Dictionary = packet_value
		var count = max(1, int(packet.get("count", 1)))
		if spawn_index < cursor + count:
			return {
				"packet": packet,
				"offset": spawn_index - cursor,
			}

		cursor += count

	return {}


func _format_wave_spawn_plan_summary(
	round_number: int,
	directions: Array,
	wave_intent: Dictionary,
	spawn_packets: Array,
	budget_used: int,
	scaled_threat_budget: int
) -> String:
	return "SpawnPlan R%s: %s from %s | packets %s | budget %s/%s | no bonus rewards" % [
		round_number,
		wave_intent.get("label", wave_intent.get("waveIntentId", "wave")),
		_join_values(directions),
		spawn_packets.size(),
		budget_used,
		scaled_threat_budget,
	]


func _enemy_id_for_spawn(spawn_index: int, round_number: int) -> String:
	if spawn_index == 0 and _is_boss_round(round_number):
		return _boss_enemy_id()

	var normal_spawn_index = spawn_index
	if _is_boss_round(round_number):
		normal_spawn_index = max(0, spawn_index - 1)

	var pattern = _enemy_mix_pattern_for_round(round_number)
	if pattern.is_empty():
		return _default_enemy_id()

	return str(pattern[normal_spawn_index % pattern.size()])


func _next_preview_round() -> int:
	if run_complete:
		return get_max_rounds() + 1

	if wave_active:
		return _next_stack_round()

	return current_round


func _format_wave_preview_row(round_number: int, player_count: int) -> String:
	var active_directions = _array_string_values(get_active_directions(player_count))
	var projected_directions = _wave_spawn_directions_for_round_number(player_count, active_directions, round_number)
	var boss_text = ""
	if _is_boss_round(round_number):
		boss_text = " + boss %s" % get_enemy_label(_boss_enemy_id())

	var trait_summary = get_enemy_mix_trait_summary(round_number)
	var trait_text = ""
	if not trait_summary.is_empty() and trait_summary != "Standard":
		trait_text = " traits %s" % trait_summary

	return "R%s %s enemies [%s]%s%s from %s" % [
		round_number,
		_get_normal_spawn_count(round_number),
		get_enemy_mix_summary(round_number),
		boss_text,
		trait_text,
		_join_values(projected_directions),
	]


func _wave_intent_data(intent_id: String) -> Dictionary:
	if intent_id.is_empty():
		return {}

	var wave_intents: Dictionary = data.get("waveIntents", {})
	if not wave_intents.has(intent_id):
		return {}

	if typeof(wave_intents[intent_id]) != TYPE_DICTIONARY:
		return {}

	return wave_intents[intent_id]


func _wave_intent_id_for_round(round_number: int) -> String:
	var wave: Dictionary = data.get("wave", {})
	var raw_schedule = wave.get("intentSchedule", [])
	if typeof(raw_schedule) != TYPE_ARRAY:
		return ""

	for raw_entry in raw_schedule:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			continue

		var entry: Dictionary = raw_entry
		var intent_id = str(entry.get("intentId", ""))
		if intent_id.is_empty() or _wave_intent_data(intent_id).is_empty():
			continue

		if bool(entry.get("bossRound", false)) and _is_boss_round(round_number):
			return intent_id

		var min_round = max(1, int(entry.get("minRound", 1)))
		var max_round = int(entry.get("maxRound", min_round))
		if max_round < min_round:
			max_round = min_round

		if round_number >= min_round and round_number <= max_round:
			return intent_id

	return ""


func _wave_intent_primary_role(intent_id: String, fallback_role: String) -> String:
	var intent_data = _wave_intent_data(intent_id)
	var role = str(intent_data.get("primaryRole", fallback_role))
	if WAVE_INTENT_ROLES.has(role):
		return role

	return fallback_role if WAVE_INTENT_ROLES.has(fallback_role) else "swarm"


func _wave_intent_label(intent_id: String) -> String:
	var intent_data = _wave_intent_data(intent_id)
	if intent_data.is_empty():
		return intent_id

	return str(intent_data.get("label", intent_id))


func _wave_intent_question(intent_id: String, fallback_role: String) -> String:
	var intent_data = _wave_intent_data(intent_id)
	var question = str(intent_data.get("question", ""))
	if not question.is_empty():
		return question

	return _wave_preview_tactical_question(fallback_role)


func _wave_intent_prep_tags(intent_id: String, fallback_tags: Array) -> Array:
	var intent_data = _wave_intent_data(intent_id)
	var raw_tags = intent_data.get("recommendedPrepTags", [])
	if typeof(raw_tags) != TYPE_ARRAY:
		return fallback_tags.duplicate()

	var tags = _array_string_values(raw_tags)
	if tags.is_empty():
		return fallback_tags.duplicate()

	return tags


func _build_wave_intent_report(
	round_number: int,
	wave_intent_id: String,
	primary_enemy_role: String,
	enemy_roles: Array,
	inferred_primary_enemy_role: String
) -> Dictionary:
	var intent_data = _wave_intent_data(wave_intent_id)
	var scheduled_intent_id = _wave_intent_id_for_round(round_number)
	var source = "fallback"
	if not intent_data.is_empty():
		source = "scheduled" if scheduled_intent_id == wave_intent_id else "data"

	return {
		"ok": true,
		"reason": "ok",
		"id": wave_intent_id,
		"waveIntentId": wave_intent_id,
		"round": round_number,
		"day": round_number,
		"label": _wave_intent_label(wave_intent_id),
		"primaryEnemyRole": primary_enemy_role,
		"inferredPrimaryEnemyRole": inferred_primary_enemy_role,
		"enemyRoles": enemy_roles.duplicate(),
		"question": _wave_intent_question(wave_intent_id, primary_enemy_role),
		"recommendedPrepTags": _wave_intent_prep_tags(
			wave_intent_id,
			_wave_preview_prep_tags(primary_enemy_role, 1)
		),
		"source": source,
		"scheduled": scheduled_intent_id == wave_intent_id and not scheduled_intent_id.is_empty(),
		"summary": "WaveIntent R%s: %s | role %s | %s" % [
			round_number,
			_wave_intent_label(wave_intent_id),
			primary_enemy_role,
			_wave_intent_question(wave_intent_id, primary_enemy_role),
		],
	}


func _wave_intent_id_for_role(round_number: int, primary_enemy_role: String) -> String:
	var scheduled_intent_id = _wave_intent_id_for_round(round_number)
	if not scheduled_intent_id.is_empty():
		return scheduled_intent_id

	if _is_boss_round(round_number):
		return "intent_final_focus"
	if round_number <= 1:
		return "intent_route_read"

	match primary_enemy_role:
		"fast":
			return "intent_fast_response"
		"structure_break":
			return "intent_planned_structure_break"
		"armored":
			return "intent_path_stretch"
		"boss":
			return "intent_final_focus"
		_:
			return "intent_swarm_compression"


func _lane_projection_directions(
	round_number: int,
	active_directions: Array,
	wave_intent_id: String,
	primary_enemy_role: String
) -> Array:
	var active = _array_string_values(active_directions)
	if active.is_empty():
		return []
	if active.size() == 1:
		return [str(active[0])]
	if _is_boss_round(round_number):
		return active.duplicate()
	if round_number <= 1:
		return _lane_pick_directions(active, ["east"], 1)

	match primary_enemy_role:
		"fast":
			return _lane_pick_directions(active, ["west", "east", "north"], min(2, active.size()))
		"structure_break":
			return _lane_pick_directions(active, ["west", "east", "north"], 1)
		"armored":
			return _lane_pick_directions(active, ["north", "south", "east"], min(2, active.size()))
		_:
			return _lane_default_projection(round_number, active, wave_intent_id)


func _lane_default_projection(round_number: int, active_directions: Array, wave_intent_id: String) -> Array:
	var preferred_single = "east"
	if wave_intent_id == "intent_swarm_compression" and active_directions.has("south"):
		preferred_single = "south" if round_number >= 6 else "east"

	if active_directions.size() >= 4 and round_number >= 8 and round_number % 4 == 0:
		return _lane_pick_directions(active_directions, ["west", "north", "east"], 3)
	if active_directions.size() >= 3 and round_number >= 5 and round_number % 3 == 0:
		return _lane_pick_directions(active_directions, ["west", "east"], 2)
	if active_directions.size() >= 2 and round_number >= 4 and round_number % 2 == 0:
		return _lane_pick_directions(active_directions, ["north", "east"], 2)

	return _lane_pick_directions(active_directions, [preferred_single, "north", "west"], 1)


func _lane_pick_directions(active_directions: Array, preferred_order: Array, limit: int) -> Array:
	var picked: Array = []
	var max_count = clamp(limit, 1, max(1, active_directions.size()))
	for preferred in preferred_order:
		var direction = str(preferred)
		if active_directions.has(direction) and not picked.has(direction):
			picked.append(direction)
			if picked.size() >= max_count:
				return picked

	for direction_value in active_directions:
		var direction = str(direction_value)
		if not picked.has(direction):
			picked.append(direction)
			if picked.size() >= max_count:
				break

	return picked


func _lane_projection_mode(projected_directions: Array, active_directions: Array) -> String:
	if projected_directions.size() <= 1:
		return "single_front"
	if projected_directions.size() >= active_directions.size():
		return "all_active_fronts"
	return "split_fronts"


func _format_lane_projection_summary(
	round_number: int,
	active_directions: Array,
	projected_directions: Array,
	wave_intent_id: String
) -> String:
	return "LaneProjection R%s: %s -> %s | %s" % [
		round_number,
		_join_values(active_directions),
		_join_values(projected_directions),
		wave_intent_id,
	]


func _build_wave_preview_card(player_count: int, round_number: int, active_directions: Array) -> Dictionary:
	var normalized_player_count = clamp(player_count, 1, 4)
	var preview_active_directions = active_directions.duplicate()
	if preview_active_directions.is_empty():
		preview_active_directions = _array_string_values(get_active_directions(normalized_player_count))

	var spawn_plan = _cached_wave_spawn_plan(normalized_player_count, round_number, preview_active_directions)
	var projected_directions = _array_string_values(spawn_plan.get("directions", []))
	if projected_directions.is_empty():
		projected_directions = _wave_spawn_directions_for_round_number(normalized_player_count, preview_active_directions, round_number)
	var enemy_ids = get_enemy_mix_ids(round_number)
	var boss_enemy_id = _boss_enemy_id() if _is_boss_round(round_number) else ""
	var boss_label = get_enemy_label(boss_enemy_id) if not boss_enemy_id.is_empty() else ""
	var enemy_roles = _wave_enemy_role_tags(enemy_ids, boss_enemy_id)
	var inferred_primary_enemy_role = _wave_primary_enemy_role_for_round(round_number, enemy_roles, boss_enemy_id)
	var scheduled_intent_id = _wave_intent_id_for_round(round_number)
	var primary_enemy_role = _wave_intent_primary_role(scheduled_intent_id, inferred_primary_enemy_role)
	var wave_intent_id = scheduled_intent_id
	if wave_intent_id.is_empty():
		wave_intent_id = _wave_intent_id_for_role(round_number, primary_enemy_role)
	var prep_tags = _wave_intent_prep_tags(wave_intent_id, _wave_preview_prep_tags(primary_enemy_role, projected_directions.size()))
	var wave_intent = _build_wave_intent_report(round_number, wave_intent_id, primary_enemy_role, enemy_roles, inferred_primary_enemy_role)
	var lane_projection = {
		"id": _lane_projection_id(round_number, normalized_player_count),
		"laneProjectionId": _lane_projection_id(round_number, normalized_player_count),
		"waveIntentId": wave_intent_id,
		"waveIntent": wave_intent,
		"activeDirections": preview_active_directions.duplicate(),
		"directions": projected_directions.duplicate(),
		"projectionMode": _lane_projection_mode(projected_directions, preview_active_directions),
		"forbiddenProjectionTags": LANE_PROJECTION_FORBIDDEN_TAGS.duplicate(),
	}
	return {
		"ok": true,
		"reason": "ok",
		"id": _wave_preview_card_id(round_number),
		"previewCardId": _wave_preview_card_id(round_number),
		"laneProjectionId": str(lane_projection.get("laneProjectionId", "")),
		"laneProjection": lane_projection,
		"waveId": _wave_id(round_number),
		"spawnPlanId": str(spawn_plan.get("spawnPlanId", _wave_spawn_plan_id(round_number))),
		"spawnPlan": spawn_plan,
		"round": round_number,
		"day": round_number,
		"playerCount": normalized_player_count,
		"playerCountAtStart": normalized_player_count,
		"activeDirections": preview_active_directions.duplicate(),
		"directions": projected_directions.duplicate(),
		"projectedDirections": projected_directions.duplicate(),
		"usesInactiveDirections": _wave_preview_uses_inactive_direction(projected_directions, preview_active_directions),
		"enemyGroups": enemy_ids.duplicate(),
		"enemyGroupLabels": _wave_enemy_labels(enemy_ids),
		"scaledEnemyGroups": spawn_plan.get("scaledEnemyGroups", []),
		"spawnPackets": spawn_plan.get("spawnPackets", []),
		"spawnPacketCount": int(spawn_plan.get("spawnPacketCount", 0)),
		"spawnPlanSummary": str(spawn_plan.get("summary", "")),
		"enemyRoles": enemy_roles.duplicate(),
		"primaryEnemyRole": primary_enemy_role,
		"inferredPrimaryEnemyRole": inferred_primary_enemy_role,
		"bossEnemyId": boss_enemy_id,
		"bossLabel": boss_label,
		"hasBoss": not boss_enemy_id.is_empty(),
		"normalSpawnCount": int(spawn_plan.get("normalSpawnCount", _get_normal_spawn_count(round_number))),
		"totalSpawnCount": int(spawn_plan.get("totalSpawnCount", _get_spawn_count(round_number))),
		"frontCount": projected_directions.size(),
		"frontFocus": _wave_preview_front_focus(projected_directions, preview_active_directions),
		"projectionMode": str(lane_projection.get("projectionMode", "single_front")),
		"waveIntentId": wave_intent_id,
		"waveIntentLabel": str(wave_intent.get("label", wave_intent_id)),
		"waveIntentQuestion": str(wave_intent.get("question", "")),
		"waveIntent": wave_intent,
		"tacticalQuestion": str(wave_intent.get("question", _wave_preview_tactical_question(primary_enemy_role))),
		"recommendedPrepTags": prep_tags.duplicate(),
		"forbiddenPreviewTags": WAVE_PREVIEW_CARD_FORBIDDEN_TAGS.duplicate(),
		"noRewardChange": true,
		"candidateCountUnchanged": true,
		"rarityUnchanged": true,
		"summary": _format_wave_preview_card_summary(
			round_number,
			projected_directions,
			get_enemy_mix_summary(round_number),
			boss_label,
			primary_enemy_role,
			str(wave_intent.get("label", wave_intent_id)),
			prep_tags
		),
	}


func _wave_enemy_labels(enemy_ids: Array) -> Array:
	var labels: Array = []
	for enemy_id in enemy_ids:
		labels.append(get_enemy_label(str(enemy_id)))
	return labels


func _wave_enemy_role_tags(enemy_ids: Array, boss_enemy_id: String) -> Array:
	var tags: Array = []
	for enemy_id in enemy_ids:
		var enemy_data = _enemy_data_by_id(str(enemy_id))
		if enemy_data.is_empty():
			continue

		_wave_preview_add_unique(tags, _wave_enemy_role_tag_for_data(enemy_data))

	if not boss_enemy_id.is_empty():
		_wave_preview_add_unique(tags, "boss")
	if tags.is_empty():
		tags.append("swarm")
	return tags


func _wave_enemy_role_tag_for_data(enemy_data: Dictionary) -> String:
	if bool(enemy_data.get("boss", false)):
		return "boss"
	if int(enemy_data.get("moveSteps", 1)) > 1:
		return "fast"
	if bool(enemy_data.get("structurePriority", false)):
		return "structure_break"
	if int(enemy_data.get("damageReduction", 0)) > 0:
		return "armored"
	return "swarm"


func _wave_preview_add_unique(values: Array, value: String) -> void:
	if not values.has(value):
		values.append(value)


func _wave_primary_enemy_role_for_round(round_number: int, enemy_roles: Array, boss_enemy_id: String) -> String:
	if not boss_enemy_id.is_empty():
		return "boss"

	var introduced_roles: Array = []
	var wave: Dictionary = data.get("wave", {})
	var raw_enemy_mix = wave.get("enemyMix", [])
	if typeof(raw_enemy_mix) == TYPE_ARRAY:
		for raw_entry in raw_enemy_mix:
			if typeof(raw_entry) != TYPE_DICTIONARY:
				continue

			var entry: Dictionary = raw_entry
			if int(entry.get("minRound", 1)) != round_number:
				continue

			var enemy_data = _enemy_data_by_id(str(entry.get("enemyId", _default_enemy_id())))
			if enemy_data.is_empty():
				continue

			_wave_preview_add_unique(introduced_roles, _wave_enemy_role_tag_for_data(enemy_data))

	if not introduced_roles.is_empty():
		return _wave_primary_enemy_role(introduced_roles)

	return _wave_primary_enemy_role(enemy_roles)


func _wave_primary_enemy_role(enemy_roles: Array) -> String:
	for role in ["boss", "structure_break", "fast", "armored", "swarm"]:
		if enemy_roles.has(role):
			return role
	return "swarm"


func _wave_preview_prep_tags(primary_enemy_role: String, front_count: int) -> Array:
	var tags: Array = ["path_read", "cover_active_fronts"]
	if front_count > 1:
		tags.append("split_front_attention")

	match primary_enemy_role:
		"boss":
			tags.append("boss_part_focus")
			tags.append("delay_ready")
		"structure_break":
			tags.append("planned_collapse_check")
			tags.append("repair_or_rebuild")
		"fast":
			tags.append("short_path_check")
			tags.append("slow_or_taunt_ready")
		"armored":
			tags.append("long_path")
			tags.append("sustained_damage")
		_:
			tags.append("killzone_setup")
	return tags


func _wave_preview_front_focus(projected_directions: Array, active_directions: Array) -> String:
	if projected_directions.size() <= 1:
		return "single_front"
	if projected_directions.size() >= active_directions.size() and active_directions.size() >= 4:
		return "all_active_fronts"
	return "split_fronts"


func _wave_preview_uses_inactive_direction(projected_directions: Array, active_directions: Array) -> bool:
	for direction in projected_directions:
		if not active_directions.has(str(direction)):
			return true
	return false


func _wave_preview_tactical_question(primary_enemy_role: String) -> String:
	match primary_enemy_role:
		"boss":
			return "Choose one boss part and keep a delay answer ready."
		"structure_break":
			return "Decide which structure may break and where the rear line goes."
		"fast":
			return "Catch the short path before fast enemies reach the base."
		"armored":
			return "Make the path long enough for sustained damage to matter."
		_:
			return "Build the first kill zone on the shown front."


func _format_wave_preview_card_summary(
	round_number: int,
	projected_directions: Array,
	enemy_mix: String,
	boss_label: String,
	primary_enemy_role: String,
	wave_intent_label: String,
	prep_tags: Array
) -> String:
	var boss_text = ""
	if not boss_label.is_empty():
		boss_text = " + boss %s" % boss_label
	return "WavePreviewCard R%s: %s enemies [%s]%s from %s | intent %s | role %s | prep %s | no reward change" % [
		round_number,
		_get_normal_spawn_count(round_number),
		enemy_mix,
		boss_text,
		_join_values(projected_directions),
		wave_intent_label,
		primary_enemy_role,
		_join_values(prep_tags),
	]


func _enemy_mix_pattern_for_round(round_number: int) -> Array:
	var pattern: Array = []
	var wave: Dictionary = data.get("wave", {})
	var raw_enemy_mix = wave.get("enemyMix", [])
	var enemy_mix: Array = []
	if typeof(raw_enemy_mix) == TYPE_ARRAY:
		enemy_mix = raw_enemy_mix
	if enemy_mix.is_empty():
		pattern.append(_default_enemy_id())
		return pattern

	for raw_entry in enemy_mix:
		var entry: Dictionary = raw_entry
		var min_round = max(1, int(entry.get("minRound", 1)))
		if round_number < min_round:
			continue

		var enemy_id = str(entry.get("enemyId", _default_enemy_id()))
		var weight = max(1, int(entry.get("weight", 1)))
		for _weight_index in range(weight):
			pattern.append(enemy_id)

	if pattern.is_empty():
		pattern.append(_default_enemy_id())

	return pattern


func _default_enemy_id() -> String:
	return str(data.get("wave", {}).get("enemyId", "m0_walker"))


func _boss_enemy_id() -> String:
	return str(data.get("wave", {}).get("bossEnemyId", ""))


func _is_boss_round(round_number: int) -> bool:
	var boss_every_rounds = int(data.get("wave", {}).get("bossEveryRounds", 0))
	return boss_every_rounds > 0 and round_number > 0 and round_number % boss_every_rounds == 0 and not _boss_enemy_id().is_empty()


func _is_shop_round(round_number: int) -> bool:
	var shop_every_rounds = get_boss_shop_round_interval()
	return shop_every_rounds > 0 and round_number > 0 and round_number % shop_every_rounds == 0


func _enemy_data(enemy: Dictionary) -> Dictionary:
	return _enemy_data_by_id(str(enemy.get("enemy_id", _default_enemy_id())))


func _enemy_data_by_id(enemy_id: String) -> Dictionary:
	return data.get("enemies", {}).get(enemy_id, {})


func _enemy_move_steps(enemy: Dictionary) -> int:
	return max(1, int(_enemy_data(enemy).get("moveSteps", 1)))


func _enemy_prioritizes_structures(enemy: Dictionary) -> bool:
	return bool(_enemy_data(enemy).get("structurePriority", false))


func _enemy_damage_reduction(enemy: Dictionary) -> int:
	return max(0, int(_enemy_data(enemy).get("damageReduction", 0)))


func _enemy_trait_tile_primary(entry: Dictionary) -> String:
	if int(entry.get("boss_count", 0)) > 0:
		return "boss"
	if int(entry.get("breaker_count", 0)) > 0:
		return "breaker"
	if int(entry.get("armor_count", 0)) > 0:
		return "armor"
	if int(entry.get("fast_count", 0)) > 0:
		return "fast"
	return "standard"


func _enemy_trait_tile_label(entry: Dictionary) -> String:
	var primary = _enemy_trait_tile_primary(entry)
	var marker = "E"
	match primary:
		"boss":
			marker = "!"
		"breaker":
			marker = "#"
		"armor":
			marker = "A"
		"fast":
			marker = ">"

	var count = int(entry.get("count", 0))
	if count <= 1:
		return marker
	if count < 10:
		return "%s%s" % [marker, count]
	return str(count)


func _enemy_trait_tile_summary(entry: Dictionary) -> String:
	var parts = PackedStringArray()
	if int(entry.get("boss_count", 0)) > 0:
		parts.append("Boss %s" % entry.get("boss_count", 0))
	if int(entry.get("breaker_count", 0)) > 0:
		parts.append("Structure focus %s" % entry.get("breaker_count", 0))
	if int(entry.get("armor_count", 0)) > 0:
		parts.append("Armor %s" % entry.get("armor_count", 0))
	if int(entry.get("fast_count", 0)) > 0:
		parts.append("Fast %s" % entry.get("fast_count", 0))

	if parts.is_empty():
		return "Standard"

	return ", ".join(parts)


func _apply_enemy_damage_reduction(enemy: Dictionary, damage: int, events: Array[String]) -> int:
	var reduction = min(max(0, damage - 1), _enemy_damage_reduction(enemy))
	if reduction <= 0:
		return damage

	run_stats["enemy_damage_reduced"] = int(run_stats.get("enemy_damage_reduced", 0)) + reduction
	events.append("%s armor reduced damage by %s." % [_enemy_display_name(enemy), reduction])
	return damage - reduction


func _is_boss_enemy(enemy: Dictionary) -> bool:
	return bool(enemy.get("boss", false)) or bool(_enemy_data(enemy).get("boss", false))


func _enemy_display_name(enemy: Dictionary) -> String:
	var label = str(_enemy_data(enemy).get("label", enemy.get("enemy_id", "Enemy")))
	var prefix = "Boss " if _is_boss_enemy(enemy) else "Enemy "
	return "%s%s #%s" % [prefix, label, enemy.get("id", "?")]


func _artifact_effect_total(effect_key: String) -> int:
	var total = 0
	for artifact_id in equipped_artifacts:
		var artifact_data = get_artifact_data(str(artifact_id))
		var effects: Dictionary = artifact_data.get("effects", {})
		total += int(effects.get(effect_key, 0))
	return total


func _format_artifact_effect(effect_key: String, value: int) -> String:
	var signed_value = "+%s" % value
	match effect_key:
		"maxHandBonus":
			return "Max hand %s" % signed_value
		"seedManaBonus":
			return "Seed mana %s" % signed_value
		"waveStackLimitBonus":
			return "Wave call limit %s" % signed_value
		"artifactSlotBonus":
			return "Artifact slot %s" % signed_value
		"manaPerKillBonus":
			return "Mana per kill %s" % signed_value
		"goldPerKillBonus":
			return "Gold per kill %s" % signed_value
		"drawGaugePerKillBonus":
			return "Draw gauge per kill %s" % signed_value
		_:
			return "%s %s" % [effect_key, signed_value]


func _copy_run_stats() -> Dictionary:
	var copy = {}
	for key in run_stats.keys():
		var value = run_stats[key]
		if typeof(value) == TYPE_DICTIONARY:
			var value_dictionary: Dictionary = value
			copy[key] = value_dictionary.duplicate(true)
		else:
			copy[key] = value
	return copy


func _stat_delta(stat_key: String) -> int:
	return int(run_stats.get(stat_key, 0)) - int(round_start_stats.get(stat_key, 0))


func _bucket_delta(stat_key: String) -> Dictionary:
	var current_bucket: Dictionary = run_stats.get(stat_key, {})
	var start_bucket: Dictionary = round_start_stats.get(stat_key, {})
	var delta = {}
	for key in current_bucket.keys():
		var key_text = str(key)
		var value = int(current_bucket.get(key_text, 0)) - int(start_bucket.get(key_text, 0))
		if value > 0:
			delta[key_text] = value
	return delta


func _top_bucket_delta(stat_key: String, allowed_keys: Array) -> Dictionary:
	var delta = _bucket_delta(stat_key)
	var best_key = ""
	var best_value = 0

	for key in allowed_keys:
		var key_text = str(key)
		var value = int(delta.get(key_text, 0))
		if value > best_value:
			best_key = key_text
			best_value = value

	return {
		"key": best_key,
		"value": best_value,
	}


func _all_configured_directions() -> Array:
	var directions: Array = []
	var by_count: Dictionary = data.get("activeDirectionsByPlayerCount", {})
	for direction_list in by_count.values():
		for direction in direction_list:
			var direction_text = str(direction)
			if not directions.has(direction_text):
				directions.append(direction_text)
	return directions


func _format_completed_round_label(round_numbers: Array) -> String:
	if round_numbers.is_empty():
		return "round"

	if round_numbers.size() == 1:
		return "round %s" % round_numbers[0]

	var joined_rounds = "+".join(_string_values(round_numbers))
	return "rounds %s" % joined_rounds


func _increment_bucket_stat(stat_key: String, bucket_key: String, amount: int) -> void:
	if amount <= 0:
		return

	var resolved_key = "unknown" if bucket_key.is_empty() else bucket_key
	var bucket: Dictionary = run_stats.get(stat_key, {})
	bucket[resolved_key] = int(bucket.get(resolved_key, 0)) + amount
	run_stats[stat_key] = bucket


func _top_bucket_value(stat_key: String, allowed_keys: Array) -> Dictionary:
	var bucket: Dictionary = run_stats.get(stat_key, {})
	var best_key = ""
	var best_value = 0

	for key in allowed_keys:
		var key_text = str(key)
		var value = int(bucket.get(key_text, 0))
		if value > best_value:
			best_key = key_text
			best_value = value

	return {
		"key": best_key,
		"value": best_value,
	}


func _total_bucket_value(stat_key: String, allowed_keys: Array) -> int:
	var bucket: Dictionary = run_stats.get(stat_key, {})
	var total = 0

	for key in allowed_keys:
		total += int(bucket.get(str(key), 0))

	return total


func _direction_label(direction: String) -> String:
	if direction.is_empty():
		return "the active front"

	return direction


func _starting_deck() -> Array:
	var cards: Array = []
	for card_id in data.get("deck", {}).get("startingCards", []):
		cards.append(str(card_id))
	return cards


func _draw_cards(count: int) -> void:
	for _index in range(count):
		var result = draw_card()
		if not bool(result["ok"]):
			return


func _draw_round_seed_cards(player_count: int) -> int:
	var drawn = 0
	for _index in range(get_seed_draw_count_for_player_count(player_count)):
		var result = draw_card()
		if not bool(result["ok"]):
			break

		drawn += 1

	return drawn


func _current_deck_card_ids() -> Array[String]:
	var ids: Array[String] = []
	for source in [hand, draw_pile, discard_pile]:
		for value in source:
			var card_id = str(value)
			if not ids.has(card_id):
				ids.append(card_id)

	ids.sort_custom(func(left: String, right: String) -> bool:
		var left_label = get_card_label(left)
		var right_label = get_card_label(right)
		if left_label == right_label:
			return left < right
		return left_label < right_label
	)
	return ids


func _remove_card_from_deck_zones(card_id: String) -> String:
	for index in range(discard_pile.size()):
		if str(discard_pile[index]) == card_id:
			discard_pile.remove_at(index)
			return "discard"

	for index in range(draw_pile.size()):
		if str(draw_pile[index]) == card_id:
			draw_pile.remove_at(index)
			return "draw"

	for index in range(hand.size()):
		if str(hand[index]) == card_id:
			hand.remove_at(index)
			return "hand"

	return ""


func _count_card_in_array(values: Array, card_id: String) -> int:
	var count = 0
	for value in values:
		if str(value) == card_id:
			count += 1
	return count


func _format_card_zone_summary(counts: Dictionary) -> String:
	return "hand %s / draw %s / discard %s" % [
		counts.get("hand_count", 0),
		counts.get("draw_count", 0),
		counts.get("discard_count", 0),
	]


func _format_deck_zone_summary(counts: Dictionary) -> String:
	return "Deck hand=%s draw=%s discard=%s total=%s" % [
		counts.get("hand_count", 0),
		counts.get("draw_count", 0),
		counts.get("discard_count", 0),
		counts.get("total_count", 0),
	]


func _format_round_preparation_summary(report: Dictionary) -> String:
	var direction_text = ", ".join(_string_values(report.get("active_directions", [])))
	if direction_text.is_empty():
		direction_text = "-"

	var mode = str(report.get("mode", "planned"))
	var seed_draw = int(report.get("seed_draw", 0))
	var draw_text = "seed draw up to %s" % seed_draw
	if mode == "actual":
		draw_text = "seed draw %s/%s" % [
			report.get("drawn", 0),
			seed_draw,
		]

	var front_mana_text = ""
	var front_seed_mana = int(report.get("front_seed_mana", 0))
	if front_seed_mana > 0:
		front_mana_text = " (+%s from fronts)" % front_seed_mana

	var front_draw_text = ""
	var front_seed_draw = int(report.get("front_seed_draw", 0))
	if front_seed_draw > 0:
		front_draw_text = " (+%s from fronts)" % front_seed_draw

	return "Round prep: mana %s%s, %s%s, discard uses %s, fronts %s [%s], hand %s/%s" % [
		report.get("seed_mana", 0),
		front_mana_text,
		draw_text,
		front_draw_text,
		report.get("discard_charges", 0),
		report.get("active_fronts", 0),
		direction_text,
		report.get("hand_count", 0),
		report.get("max_hand_size", 0),
	]


func _array_string_values(values: Array) -> Array:
	var strings: Array = []
	for value in values:
		strings.append(str(value))
	return strings


func _string_values(values: Array) -> PackedStringArray:
	var strings = PackedStringArray()
	for value in values:
		strings.append(str(value))
	return strings


func _reject(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}


func _fail_load(message: String) -> bool:
	last_error = message
	data.clear()
	wave_spawn_plan_cache.clear()
	wave_preview_card_cache.clear()
	reset_run()
	return false


func _tile_key(tile: Vector2i) -> String:
	return "%s,%s" % [tile.x, tile.y]


func _tile_text(tile: Vector2i) -> String:
	return "(%s, %s)" % [tile.x, tile.y]


func _card_labels(card_ids: Array) -> String:
	var parts = PackedStringArray()
	for card_id in card_ids:
		var card = get_card_data(str(card_id))
		parts.append(str(card.get("label", card_id)))
	return ", ".join(parts)


func _artifact_labels(artifact_ids: Array) -> String:
	var parts = PackedStringArray()
	for artifact_id in artifact_ids:
		parts.append(get_artifact_label(str(artifact_id)))
	return ", ".join(parts)


func _shop_service_labels(service_ids: Array) -> String:
	var parts = PackedStringArray()
	for service_id in service_ids:
		parts.append(get_shop_service_label(str(service_id)))
	return ", ".join(parts)


func _join_values(values: Array) -> String:
	var parts = PackedStringArray()
	for value in values:
		parts.append(str(value))
	return ", ".join(parts)
