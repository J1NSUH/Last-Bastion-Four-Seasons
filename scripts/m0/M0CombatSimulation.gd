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
]
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
var draw_gauge = 0
var discard_charges = 0
var hand: Array = []
var draw_pile: Array = []
var discard_pile: Array = []
var reward_offer: Array = []
var artifact_offer: Array = []
var shop_offer: Array = []
var equipped_artifacts: Array = []
var reward_queue: Array[Dictionary] = []
var active_reward_packet: Dictionary = {}
var wave_stack_vote: Dictionary = {}
var round_start_stats: Dictionary = {}
var last_round_report: Dictionary = {}
var last_reward_claim_report: Dictionary = {}
var last_shop_report: Dictionary = {}
var shop_removals_remaining = 0
var boss_reward_pending = false


func load_data() -> bool:
	last_error = ""

	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return _fail_load("Cannot open %s: %s" % [DATA_PATH, error_string(FileAccess.get_open_error())])

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return _fail_load("M0 data must be a JSON object.")

	data = parsed
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
	equipped_artifacts.clear()
	reward_queue.clear()
	active_reward_packet.clear()
	wave_stack_vote.clear()
	round_start_stats.clear()
	last_round_report.clear()
	last_reward_claim_report.clear()
	last_shop_report.clear()
	shop_removals_remaining = 0
	boss_reward_pending = false
	mana = get_seed_mana()
	gold = get_starting_gold()
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
		"structures_destroyed": 0,
		"structures_destroyed_by_direction": {},
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
		"card_damage_dealt": 0,
		"card_repairs": 0,
		"card_effect_draws": 0,
		"kill_mana_gained": 0,
		"draw_gauge_gained": 0,
		"reward_cards_drawn": 0,
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
		"card_rewards_skipped": 0,
		"artifact_rewards_offered": 0,
		"artifact_rewards_taken": 0,
		"artifact_rewards_skipped": 0,
		"shop_offers_opened": 0,
		"shop_cards_removed": 0,
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
		"round_mana_refills": 0,
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
	return {
		"ok": true,
		"reason": "ok",
		"player_count": normalized_player_count,
		"class_id": resolved_class_id,
		"class_label": class_label,
		"active_directions": active_directions.duplicate(),
		"first_wave": describe_wave(normalized_player_count, current_round),
		"summary": "%sP | fronts: %s | lead class: %s | %s" % [
			normalized_player_count,
			", ".join(_string_values(active_directions)),
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


func get_seed_mana() -> int:
	return int(data.get("resources", {}).get("seedMana", 0)) + _artifact_effect_total("seedManaBonus")


func get_max_hand_size() -> int:
	return int(data.get("resources", {}).get("maxHandSize", 5)) + _artifact_effect_total("maxHandBonus")


func get_opening_draw_count() -> int:
	return int(data.get("resources", {}).get("openingDraw", 5))


func get_discard_charges_per_run() -> int:
	return int(data.get("resources", {}).get("discardCharges", 0))


func get_discard_charge_cap() -> int:
	return int(data.get("resources", {}).get("discardChargeCap", get_discard_charges_per_run()))


func get_discard_mana_gain() -> int:
	return int(data.get("resources", {}).get("discardManaGain", 0))


func get_starting_gold() -> int:
	return int(data.get("resources", {}).get("startingGold", 0))


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


func get_artifact_offer_count() -> int:
	return int(data.get("rewards", {}).get("artifactOfferCount", 0))


func get_boss_shop_round_interval() -> int:
	return int(data.get("shop", {}).get("bossShopEveryRounds", 0))


func get_shop_deck_removal_offer_count() -> int:
	return int(data.get("shop", {}).get("deckRemovalOfferCount", 0))


func get_shop_deck_removal_limit() -> int:
	return int(data.get("shop", {}).get("deckRemovalLimit", 0))


func get_shop_deck_removal_gold_cost() -> int:
	return int(data.get("shop", {}).get("deckRemovalGoldCost", 0))


func get_mana() -> int:
	return mana


func get_gold() -> int:
	return gold


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
	return {
		"ok": true,
		"reason": "ok",
		"artifact_id": artifact_id,
		"label": str(artifact.get("label", artifact_id)),
		"effect": get_artifact_effect_summary(artifact_id),
		"equipped": equipped,
		"equipped_count": equipped_artifacts.size(),
		"summary": "%s | %s%s" % [
			artifact.get("label", artifact_id),
			get_artifact_effect_summary(artifact_id),
			" | already equipped" if equipped else "",
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

	return "Artifact: choose 1 of %s | %s" % [
		artifact_offer.size(),
		" | ".join(parts),
	]


func get_shop_offer() -> Array:
	return shop_offer.duplicate()


func get_shop_removals_remaining() -> int:
	return shop_removals_remaining


func get_card_removal_report(card_id: String) -> Dictionary:
	var card = get_card_data(card_id)
	if card.is_empty():
		return _reject("unknown_card")

	var zone_counts = get_deck_zone_counts(card_id)
	var deck_count = int(zone_counts.get("total_count", 0))
	var gold_cost = get_shop_deck_removal_gold_cost()
	var can_afford = gold >= gold_cost
	var block_reason = "ok"
	if shop_offer.is_empty():
		block_reason = "no_shop_offer"
	elif not shop_offer.has(card_id):
		block_reason = "shop_card_not_offered"
	elif shop_removals_remaining <= 0:
		block_reason = "shop_removal_unavailable"
	elif deck_count <= 0:
		block_reason = "card_not_in_deck"
	elif not can_afford:
		block_reason = "not_enough_gold"
	var can_remove = block_reason == "ok"
	return {
		"ok": true,
		"reason": block_reason,
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


func get_shop_offer_summary() -> String:
	if shop_offer.is_empty():
		return get_last_shop_summary()

	var parts = PackedStringArray()
	for report in get_shop_offer_reports():
		parts.append("%s %sg copies %s -> %s" % [
			report.get("label", report.get("card_id", "?")),
			report.get("gold_cost", 0),
			report.get("deck_count", 0),
			report.get("deck_count_after", 0),
		])

	return "Shop: gold %s | remove %s card(s) | %s" % [
		gold,
		shop_removals_remaining,
		" | ".join(parts),
	]


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
		return "Shop: last deck trim skipped."

	return "Shop: last trim %s removed from %s | gold %s -> %s | copies %s -> %s | %s" % [
		last_shop_report.get("card_label", "?"),
		last_shop_report.get("removed_from", "?"),
		last_shop_report.get("gold_before", 0),
		last_shop_report.get("gold_after", 0),
		last_shop_report.get("deck_count_before", 0),
		last_shop_report.get("deck_count_after", 0),
		last_shop_report.get("deck_after_summary", get_deck_cycle_summary()),
	]


func can_remove_shop_card(card_id: String) -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if shop_offer.is_empty():
		return _reject("no_shop_offer")

	if not shop_offer.has(card_id):
		return _reject("shop_card_not_offered")

	if shop_removals_remaining <= 0:
		return _reject("shop_removal_unavailable")

	var report = get_card_removal_report(card_id)
	if not bool(report.get("ok", false)):
		return report

	if int(report.get("deck_count", 0)) <= 0:
		return _reject("card_not_in_deck")

	if gold < get_shop_deck_removal_gold_cost():
		return _reject("not_enough_gold")

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


func get_wave_preview_rows(player_count: int, count = -1) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if not is_loaded():
		return rows

	var preview_count = get_wave_preview_round_count() if int(count) <= 0 else int(count)
	var start_round = _next_preview_round()
	if start_round > get_max_rounds():
		return rows

	var active_directions = get_active_directions(player_count)
	for offset in range(preview_count):
		var round_number = start_round + offset
		if round_number > get_max_rounds():
			break

		var boss_enemy_id = _boss_enemy_id() if _is_boss_round(round_number) else ""
		rows.append({
			"round": round_number,
			"spawn_count": _get_normal_spawn_count(round_number),
			"total_spawn_count": _get_spawn_count(round_number),
			"enemy_ids": get_enemy_mix_ids(round_number),
			"enemy_mix": get_enemy_mix_summary(round_number),
			"enemy_traits": get_enemy_mix_trait_summary(round_number),
			"boss_enemy_id": boss_enemy_id,
			"boss_label": get_enemy_label(boss_enemy_id) if not boss_enemy_id.is_empty() else "",
			"active_directions": active_directions.duplicate(),
			"summary": _format_wave_preview_row(round_number, player_count),
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


func get_reward_offer_summary() -> String:
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

	return "Reward: choose 1 of %s | %s" % [
		reward_offer.size(),
		" | ".join(parts),
	]


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


func get_equipped_artifact_summary() -> String:
	if equipped_artifacts.is_empty():
		return "none"

	var labels = PackedStringArray()
	for artifact_id in equipped_artifacts:
		labels.append(get_artifact_label(str(artifact_id)))
	return ", ".join(labels)


func has_pending_reward() -> bool:
	return (
		not reward_offer.is_empty()
		or not artifact_offer.is_empty()
		or not shop_offer.is_empty()
		or not reward_queue.is_empty()
		or not active_reward_packet.is_empty()
	)


func get_resource_summary() -> String:
	return "mana=%s gold=%s hand=%s/%s draw=%s discard=%s discard_uses=%s gauge=%s/%s artifacts=%s reward_packets=%s shop=%s" % [
		mana,
		gold,
		hand.size(),
		get_max_hand_size(),
		draw_pile.size(),
		discard_pile.size(),
		discard_charges,
		draw_gauge,
		get_draw_gauge_per_card(),
		equipped_artifacts.size(),
		get_pending_reward_packet_count(),
		shop_removals_remaining if not shop_offer.is_empty() else 0,
	]


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


func get_front_pressure_summary(player_count: int) -> String:
	if not is_loaded():
		return "Fronts: -"

	var parts = PackedStringArray()
	for front in get_front_pressure(player_count):
		parts.append(str(front.get("summary", "")))

	if parts.size() == 0:
		return "Fronts: none"

	return "Fronts: %s" % " | ".join(parts)


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
	var total_leaks = _total_bucket_value("base_hits_by_direction", active_directions)
	var total_collapses = _total_bucket_value("structures_destroyed_by_direction", active_directions)
	var enemies_data: Dictionary = data.get("enemies", {})
	var top_enemy = _top_bucket_value("base_hits_by_enemy_id", enemies_data.keys())
	var primary_direction = str(leak.get("key", ""))
	var headline = "Stable: no leaks yet."
	var focus = "stable"
	var state = "stable"
	var next_suggestion = "Keep comparing front pressure before calling the next wave."
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
			"Choose one card reward.",
			"Rewards enter the discard pile, so they become part of the next deck cycle.",
			"Pick the card that solves your weakest front.",
			"reward"
		)

	if not shop_offer.is_empty():
		return _tutorial_hint(
			true,
			"shop",
			min(tutorial_rounds, max(1, completed_rounds)),
			"Trim one deck card.",
			"Removing a weak or duplicated card makes future draws more reliable.",
			"Remove one offered card or skip the shop.",
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
		"Check Stack risk; if it is stable, try Call next. If not, repair first.",
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
		return "Stack: idle limit=%s" % get_wave_stack_limit()

	var packet_parts = PackedStringArray()
	for packet in active_wave_packets:
		packet_parts.append("%s:%s/%s" % [
			packet.get("round", 0),
			packet.get("spawned", 0),
			packet.get("total", 0),
		])

	return "Stack: %s/%s [%s] next=%s" % [
		get_active_wave_stack_depth(),
		get_wave_stack_limit(),
		", ".join(packet_parts),
		_next_stack_round(),
	]


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
			"suggestion": "Start a wave before calling the next one.",
			"details": [],
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
	return {
		"can_call": true,
		"severity": severity,
		"score": score,
		"round": next_round,
		"planned_depth": planned_depth,
		"incoming_count": incoming_count,
		"headline": "Call next risk: %s for round %s." % [severity, next_round],
		"suggestion": _wave_stack_risk_suggestion(severity),
		"details": details,
	}


func get_wave_stack_risk_summary(player_count: int) -> String:
	var report = get_wave_stack_risk_report(player_count)
	var details = PackedStringArray()
	for detail in report.get("details", []):
		details.append(str(detail))

	var detail_text = ", ".join(details) if not details.is_empty() else "no extra risk"
	return "%s %s | %s" % [
		report.get("headline", "Call next risk unavailable."),
		detail_text,
		report.get("suggestion", "-"),
	]


func has_active_wave_stack_vote() -> bool:
	return not wave_stack_vote.is_empty()


func get_wave_stack_required_votes(player_count: int) -> int:
	var normalized_count = clamp(player_count, 1, 4)
	if normalized_count <= 1:
		return 1

	if _is_base_critical_for_stack_vote():
		return normalized_count

	return int(floor(float(normalized_count) / 2.0)) + 1


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
			"events": ["Wave stack vote already active. %s" % get_wave_stack_vote_summary(player_count)],
		}

	var next_round = int(result.get("round", _next_stack_round()))
	var required_votes = get_wave_stack_required_votes(player_count)
	var risk_report = get_wave_stack_risk_report(player_count)
	wave_stack_vote = {
		"round": next_round,
		"player_count": clamp(player_count, 1, 4),
		"approvals": 1,
		"required": required_votes,
		"rule": _wave_stack_vote_rule_label(player_count),
		"risk_severity": str(risk_report.get("severity", "unknown")),
		"risk_score": int(risk_report.get("score", 0)),
	}
	run_stats["wave_stack_votes_started"] = int(run_stats.get("wave_stack_votes_started", 0)) + 1
	run_stats["wave_stack_votes_approved"] = int(run_stats.get("wave_stack_votes_approved", 0)) + 1

	var events: Array[String] = [
		"Wave stack vote started for round %s: 1/%s %s." % [
			next_round,
			required_votes,
			wave_stack_vote.get("rule", "majority"),
		],
		"Risk: %s" % get_wave_stack_risk_summary(player_count),
		"No bonus reward added; this only compresses waiting time.",
	]
	if str(wave_stack_vote.get("rule", "")) == "unanimous":
		events.append("Base is critical; all players must approve.")

	return {
		"ok": true,
		"reason": "vote_started",
		"round": next_round,
		"approvals": 1,
		"required": required_votes,
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
	run_stats["wave_stack_votes_approved"] = int(run_stats.get("wave_stack_votes_approved", 0)) + 1

	if approvals < required_votes:
		return {
			"ok": true,
			"reason": "vote_waiting",
			"round": vote_round,
			"approvals": approvals,
			"required": required_votes,
			"events": [
				"Wave stack vote waiting for round %s: %s/%s %s." % [
					vote_round,
					approvals,
					required_votes,
					wave_stack_vote.get("rule", "majority"),
				],
			],
		}

	run_stats["wave_stack_votes_passed"] = int(run_stats.get("wave_stack_votes_passed", 0)) + 1
	var pass_events: Array[String] = [
		"Wave stack vote passed for round %s: %s/%s." % [vote_round, approvals, required_votes],
	]
	var stack_result = _execute_wave_stack(player_count)
	var combined_events = pass_events
	for event in stack_result.get("events", []):
		combined_events.append(str(event))
	stack_result["events"] = combined_events
	return stack_result


func hold_wave_stack_vote() -> Dictionary:
	if not has_active_wave_stack_vote():
		return _reject("no_stack_vote")

	var vote_round = int(wave_stack_vote.get("round", 0))
	var approvals = int(wave_stack_vote.get("approvals", 0))
	var required_votes = int(wave_stack_vote.get("required", 0))
	wave_stack_vote.clear()
	run_stats["wave_stack_votes_held"] = int(run_stats.get("wave_stack_votes_held", 0)) + 1

	return {
		"ok": true,
		"reason": "vote_held",
		"events": [
			"Wave stack vote held for round %s: %s/%s approvals." % [
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

	var next_round = int(result.get("round", _next_stack_round()))
	wave_stack_vote.clear()
	_add_active_wave_packet(next_round, true)
	run_stats["rounds_started"] = int(run_stats.get("rounds_started", 0)) + 1
	run_stats["wave_stacks"] = int(run_stats.get("wave_stacks", 0)) + 1
	run_stats["stacked_rounds"] = int(run_stats.get("stacked_rounds", 0)) + 1
	_update_max_wave_stack_depth()
	_add_stacked_discard_charge()

	return {
		"ok": true,
		"reason": "wave_stacked",
		"round": next_round,
		"stack_depth": get_active_wave_stack_depth(),
		"events": [
			"Next wave called early. %s" % describe_wave(player_count, next_round),
			"No bonus reward added; this only compresses waiting time.",
			"Discard uses available: %s/%s." % [discard_charges, get_discard_charge_cap()],
		],
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


func debug_generate_artifact_offer() -> Array[String]:
	var events: Array[String] = []
	if not is_loaded():
		events.append("Artifact debug rejected: data not loaded.")
		return events

	_generate_artifact_offer(events)
	return events


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


func debug_refill_round_resources() -> Array[String]:
	var events: Array[String] = []
	_refill_round_resources(events)
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
	var lines: Array[String] = [
		str(last_round_report.get("scoreline", "")),
		reward_line,
		"Next: %s" % str(last_round_report.get("suggestion", "-")),
		next_line,
	]
	for detail_line in detail_lines:
		lines.append(str(detail_line))

	return {
		"ok": true,
		"reason": "ok",
		"title": "%s recap" % str(last_round_report.get("round_label", "Round")),
		"focus": str(last_round_report.get("focus", "stable")),
		"headline": str(last_round_report.get("headline", "-")),
		"scoreline": str(last_round_report.get("scoreline", "")),
		"suggestion": str(last_round_report.get("suggestion", "")),
		"reward_line": reward_line,
		"next_line": next_line,
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
	return "rounds=%s/%s steps=%s spawned=%s boss=%s/%s phase=%s pulse=%s siege=%s/%s killed=%s base_hits=%s boss_base=%s base_damage=%s tower_hits=%s structure_hits=%s destroyed=%s break=%s/%s enemy_fx=%s/%s/%s stacks=%s depth=%s votes=%s/%s/%s cards=%s/%s discards=%s card_fx=%s/%s/%s reward_draws=%s rewards=%s/%s artifacts=%s/%s shop=%s/%s gold=%s/%s mana_spent=%s kill_mana=%s discard_mana=%s class_fx=%s/%s/%s/%s taunt=%s repairs=%s" % [
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
		run_stats.get("killed", 0),
		run_stats.get("base_hits", 0),
		run_stats.get("boss_base_hits", 0),
		run_stats.get("base_damage", 0),
		run_stats.get("tower_hits", 0),
		run_stats.get("structure_hits", 0),
		run_stats.get("structures_destroyed", 0),
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
		run_stats.get("card_rewards_taken", 0),
		run_stats.get("card_rewards_offered", 0),
		run_stats.get("artifact_rewards_taken", 0),
		run_stats.get("artifact_rewards_offered", 0),
		run_stats.get("shop_cards_removed", 0),
		run_stats.get("shop_offers_opened", 0),
		run_stats.get("gold_gained", 0),
		run_stats.get("gold_spent", 0),
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
	var blocked = _blocked_tiles()
	for direction in get_active_directions(player_count):
		var path = _find_path(_entrance_tile(direction), blocked)
		for tile in path:
			cells[_tile_key(tile)] = true
	return cells


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
	var active_directions = get_active_directions(player_count)
	var target_round = current_round if round_number <= 0 else round_number
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
		_join_values(active_directions),
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

			tiles[_tile_key(tile)] = {
				"valid": target_ok,
				"reason": reason,
				"kind": kind,
				"show_invalid": not target_ok and _should_show_invalid_card_target(kind, reason),
			}

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
		var damage = int(card.get("damage", 0))
		_damage_enemy_at_index(
			_find_enemy_index_at_tile(tile),
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
	reward_offer.clear()
	run_stats["card_rewards_taken"] = int(run_stats.get("card_rewards_taken", 0)) + 1
	last_reward_claim_report = {
		"ok": true,
		"reason": "ok",
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

	var reward_report = get_artifact_reward_report(artifact_id)
	var equipped_count_before = equipped_artifacts.size()
	equipped_artifacts.append(artifact_id)
	artifact_offer.clear()
	run_stats["artifact_rewards_taken"] = int(run_stats.get("artifact_rewards_taken", 0)) + 1
	_finish_active_reward_packet_if_ready()

	return {
		"ok": true,
		"reason": "claimed_%s" % artifact_id,
		"artifact_id": artifact_id,
		"artifact_label": get_artifact_label(artifact_id),
		"effect": str(reward_report.get("effect", get_artifact_effect_summary(artifact_id))),
		"equipped_count_before": equipped_count_before,
		"equipped_count_after": equipped_artifacts.size(),
		"equipped_summary": get_equipped_artifact_summary(),
	}


func skip_reward_offer() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if reward_offer.is_empty():
		return _reject("no_reward_offer")

	reward_offer.clear()
	run_stats["card_rewards_skipped"] = int(run_stats.get("card_rewards_skipped", 0)) + 1
	_finish_active_reward_packet_if_ready()
	return {"ok": true, "reason": "reward_skipped"}


func skip_artifact_offer() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if artifact_offer.is_empty():
		return _reject("no_artifact_offer")

	artifact_offer.clear()
	run_stats["artifact_rewards_skipped"] = int(run_stats.get("artifact_rewards_skipped", 0)) + 1
	_finish_active_reward_packet_if_ready()
	return {"ok": true, "reason": "artifact_skipped"}


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
	if shop_removals_remaining <= 0:
		shop_offer.clear()

	run_stats["shop_cards_removed"] = int(run_stats.get("shop_cards_removed", 0)) + 1
	run_stats["gold_spent"] = int(run_stats.get("gold_spent", 0)) + gold_cost
	run_stats["shop_gold_spent"] = int(run_stats.get("shop_gold_spent", 0)) + gold_cost
	last_shop_report = {
		"ok": true,
		"reason": "ok",
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


func skip_shop_offer() -> Dictionary:
	if not is_loaded():
		return _reject("data_not_loaded")

	if shop_offer.is_empty():
		return _reject("no_shop_offer")

	var skipped_count = shop_offer.size()
	shop_offer.clear()
	shop_removals_remaining = 0
	run_stats["shop_skips"] = int(run_stats.get("shop_skips", 0)) + 1
	last_shop_report = {
		"ok": true,
		"reason": "shop_skipped",
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
	if wave_active:
		return _reject("wave_already_active")

	if has_pending_reward():
		return _reject("reward_pending")

	if run_complete:
		return _reject("run_complete")

	if base_hp <= 0:
		return _reject("base_destroyed")

	for direction in get_active_directions(player_count):
		var path = _find_path(_entrance_tile(direction), _blocked_tiles())
		if path.is_empty():
			return _reject("no_path_from_%s" % direction)

	var events: Array[String] = []
	_refill_round_resources(events)
	wave_active = true
	active_round = current_round
	spawned_count = 0
	active_wave_packets.clear()
	wave_stack_vote.clear()
	_add_active_wave_packet(active_round, false)
	enemies.clear()
	run_stats["rounds_started"] = int(run_stats.get("rounds_started", 0)) + 1
	_update_max_wave_stack_depth()
	events.push_front("Wave started. %s" % describe_wave(player_count, active_round))
	return {"ok": true, "events": events}


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
		events.append("Base destroyed. M0 run failed.")
		events.append("Outcome: %s" % get_run_outcome_summary(player_count))

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

	var active_directions = get_active_directions(player_count)
	if active_directions.is_empty():
		wave_active = false
		events.append("No active direction. Wave stopped.")
		return

	var packet: Dictionary = active_wave_packets[packet_index]
	var packet_spawned = int(packet.get("spawned", 0))
	var packet_round = int(packet.get("round", active_round))
	var direction: String = active_directions[packet_spawned % active_directions.size()]
	var tile = _entrance_tile(direction)
	var enemy_id = _enemy_id_for_spawn(packet_spawned, packet_round)
	var enemy_data = _enemy_data_by_id(enemy_id)
	var enemy = {
		"id": next_enemy_id,
		"enemy_id": enemy_id,
		"tile": tile,
		"hp": int(enemy_data.get("hp", 6)),
		"direction": direction,
		"round": packet_round,
		"stacked": bool(packet.get("stacked", false)),
		"boss": bool(enemy_data.get("boss", false)),
		"phase_triggered": false,
		"siege_gaze_charge": 0,
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
	events.append("%s spawned at %s from round %s." % [_enemy_display_name(enemy), direction, packet_round])


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
		if _enemy_attack_adjacent_structure(index, events):
			index -= 1
			continue

		if _try_boss_siege_gaze(index, events):
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
		_apply_architect_explosion(structure, target_tile, events)
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
	_grant_kill_rewards(events)
	enemies.remove_at(enemy_index)
	return true


func _damage_enemy_by_id(enemy_id: int, damage: int, events: Array[String], source_label: String, stat_key: String = "", event_type: String = "hit") -> bool:
	var enemy_index = _find_enemy_index_by_id(enemy_id)
	if enemy_index < 0:
		return false

	return _damage_enemy_at_index(enemy_index, damage, events, source_label, stat_key, event_type)


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
	var interval = int(enemy_data.get("siegeGazeIntervalSteps", 0))
	var damage = int(enemy_data.get("siegeGazeDamage", 0))
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
	var interval = int(enemy_data.get("siegeGazeIntervalSteps", 0))
	var damage = int(enemy_data.get("siegeGazeDamage", 0))
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


func _apply_architect_explosion(structure: Dictionary, target_tile: Vector2i, events: Array[String]) -> void:
	if str(structure.get("type", "")) != "barricade":
		return

	var effects = get_class_effects(str(structure.get("class_id", "")))
	var explosion_damage = int(effects.get("barricadeDeathDamage", 0))
	var explosion_radius = int(effects.get("barricadeDeathRadius", 0))
	if explosion_damage <= 0 or explosion_radius <= 0:
		return

	recent_event_tiles[_tile_key(target_tile)] = "explosion"
	events.append("Architect barricade at %s exploded." % _tile_text(target_tile))
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


func _grant_kill_rewards(events: Array[String]) -> void:
	var mana_gain = get_mana_per_kill()
	if mana_gain > 0:
		mana += mana_gain
		run_stats["kill_mana_gained"] = int(run_stats.get("kill_mana_gained", 0)) + mana_gain
		events.append("Kill reward: +%s mana." % mana_gain)

	var gold_gain = get_gold_per_kill()
	if gold_gain > 0:
		gold += gold_gain
		run_stats["gold_gained"] = int(run_stats.get("gold_gained", 0)) + gold_gain
		events.append("Kill reward: +%s gold." % gold_gain)

	var gauge_gain = get_draw_gauge_per_kill()
	if gauge_gain <= 0:
		return

	draw_gauge += gauge_gain
	run_stats["draw_gauge_gained"] = int(run_stats.get("draw_gauge_gained", 0)) + gauge_gain
	events.append("Kill reward: +%s draw gauge." % gauge_gain)
	_try_draw_from_gauge(events)


func _try_draw_from_gauge(events: Array[String]) -> void:
	var threshold = get_draw_gauge_per_card()
	if threshold <= 0:
		return

	while draw_gauge >= threshold:
		var draw_result = draw_card()
		if not bool(draw_result["ok"]):
			events.append("Reward draw held: %s." % draw_result["reason"])
			return

		draw_gauge -= threshold
		run_stats["reward_cards_drawn"] = int(run_stats.get("reward_cards_drawn", 0)) + 1
		var card_id = str(draw_result["card_id"])
		var card = get_card_data(card_id)
		events.append("Reward draw: %s." % card.get("label", card_id))


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
		if not equipped_artifacts.has(artifact_id) and not artifact_offer.has(artifact_id):
			artifact_offer.append(artifact_id)

		index += 1
		attempts += 1

	if artifact_offer.is_empty():
		events.append("No new artifact reward available.")
		return

	run_stats["artifact_rewards_offered"] = int(run_stats.get("artifact_rewards_offered", 0)) + artifact_offer.size()
	events.append("Artifact reward offered: %s." % _artifact_labels(artifact_offer))


func _generate_shop_offer(events: Array[String], reward_round: int) -> void:
	shop_offer.clear()
	shop_removals_remaining = 0
	last_shop_report.clear()
	if not _is_shop_round(reward_round):
		return

	var removal_limit = get_shop_deck_removal_limit()
	var offer_count = get_shop_deck_removal_offer_count()
	if removal_limit <= 0 or offer_count <= 0:
		events.append("Shop unavailable: deck removal is disabled.")
		return

	var candidates = _current_deck_card_ids()
	if candidates.is_empty():
		events.append("Shop skipped: no cards in deck to remove.")
		return

	for index in range(min(offer_count, candidates.size())):
		shop_offer.append(str(candidates[index]))

	shop_removals_remaining = min(removal_limit, shop_offer.size())
	run_stats["shop_offers_opened"] = int(run_stats.get("shop_offers_opened", 0)) + 1
	events.append("Shop opened: remove %s card(s) for %s gold each from %s." % [
		shop_removals_remaining,
		get_shop_deck_removal_gold_cost(),
		_card_labels(shop_offer),
	])


func _present_next_reward_packet(events: Array[String]) -> void:
	if not reward_offer.is_empty() or not artifact_offer.is_empty() or not shop_offer.is_empty() or not active_reward_packet.is_empty():
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

	if reward_offer.is_empty() and artifact_offer.is_empty() and shop_offer.is_empty():
		active_reward_packet.clear()
		_present_next_reward_packet(events)


func _finish_active_reward_packet_if_ready() -> void:
	if active_reward_packet.is_empty():
		return

	if not reward_offer.is_empty() or not artifact_offer.is_empty() or not shop_offer.is_empty():
		return

	active_reward_packet.clear()
	var ignored_events: Array[String] = []
	_present_next_reward_packet(ignored_events)


func _complete_active_rounds(events: Array[String]) -> void:
	if active_wave_packets.is_empty():
		return

	var completed_packet_rounds = _active_wave_rounds()
	var boss_artifact_queued = false
	var boss_shop_queued = false
	for round_number in completed_packet_rounds:
		completed_rounds = max(completed_rounds, round_number)
		run_stats["rounds_completed"] = int(run_stats.get("rounds_completed", 0)) + 1
		var reward_packet = {
			"round": round_number,
			"artifact": false,
			"shop": false,
		}
		if boss_reward_pending and _is_boss_round(round_number) and not boss_artifact_queued:
			reward_packet["artifact"] = true
			reward_packet["shop"] = _is_shop_round(round_number)
			boss_artifact_queued = true
			boss_shop_queued = bool(reward_packet["shop"])
		reward_queue.append(reward_packet)

	last_round_report = _build_last_round_report(completed_packet_rounds, boss_artifact_queued, boss_shop_queued)
	round_start_stats = _copy_run_stats()
	events.append("Round report: %s" % get_last_round_summary())

	boss_reward_pending = false
	active_wave_packets.clear()
	wave_stack_vote.clear()

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


func _refill_round_resources(events: Array[String]) -> void:
	mana = get_seed_mana()
	discard_charges = get_discard_charges_per_run()
	run_stats["round_mana_refills"] = int(run_stats.get("round_mana_refills", 0)) + 1
	run_stats["discard_refills"] = int(run_stats.get("discard_refills", 0)) + 1
	events.append("Round resources refilled: mana %s, discard uses %s." % [
		mana,
		discard_charges,
	])
	_repair_tinkerer_structures(events)


func _build_last_round_report(completed_packet_rounds: Array[int], artifact_queued: bool, shop_queued: bool) -> Dictionary:
	var active_directions = _all_configured_directions()
	var base_hits = _stat_delta("base_hits")
	var boss_base_hits = _stat_delta("boss_base_hits")
	var base_damage = _stat_delta("base_damage")
	var destroyed = _stat_delta("structures_destroyed")
	var killed = _stat_delta("killed")
	var spawned = _stat_delta("spawned")
	var cards_played = _stat_delta("cards_played")
	var mana_spent_delta = _stat_delta("mana_spent")
	var leak = _top_bucket_delta("base_hits_by_direction", active_directions)
	var collapse = _top_bucket_delta("structures_destroyed_by_direction", active_directions)
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
		focus = "collapse"
		headline = "%s structure(s) broke." % destroyed
		suggestion = "Repair or rebuild the weakest point on %s." % _direction_label(str(collapse.get("key", "")))
	elif completed_packet_rounds.size() > 1:
		focus = "stack_clear"
		headline = "Stacked waves cleared."
		suggestion = "Spend the reward spike before calling another wave."
	elif _stat_delta("bosses_killed") > 0:
		focus = "boss_clear"
		headline = "Boss cleared."
		suggestion = "Choose the artifact that fixes the run's weakest resource."
	elif killed > 0:
		headline = "Clean clear."

	details.append("spawned %s / killed %s" % [spawned, killed])
	details.append("base hits %s / damage %s" % [base_hits, base_damage])
	details.append("structures lost %s" % destroyed)
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
		"cards_played": cards_played,
		"mana_spent": mana_spent_delta,
		"stack_depth": completed_packet_rounds.size(),
		"artifact_queued": artifact_queued,
		"shop_queued": shop_queued,
		"primary_leak_direction": str(leak.get("key", "")),
		"primary_collapse_direction": str(collapse.get("key", "")),
		"reward_packets_queued": reward_queue.size(),
	}


func _last_round_reward_line() -> String:
	var waiting_parts = PackedStringArray()
	if not reward_offer.is_empty():
		waiting_parts.append("card choice")
	if not artifact_offer.is_empty():
		waiting_parts.append("artifact choice")
	if not shop_offer.is_empty():
		waiting_parts.append("shop deck trim")
	if waiting_parts.size() > 0:
		return "Reward waiting: %s." % ", ".join(waiting_parts)
	if reward_queue.size() > 0:
		return "Reward queued: %s packet(s)." % reward_queue.size()
	return "Reward waiting: none."


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
	var starting_gold = int(resources_data.get("startingGold", -1))
	var max_hand_size = int(resources_data.get("maxHandSize", 0))
	var opening_draw = int(resources_data.get("openingDraw", 0))
	var discard_charges_data = int(resources_data.get("discardCharges", -1))
	var discard_charge_cap = int(resources_data.get("discardChargeCap", discard_charges_data))
	var discard_mana_gain = int(resources_data.get("discardManaGain", -1))
	if seed_mana < 0:
		last_error = "M0 seedMana cannot be negative."
		return false

	if starting_gold < 0:
		last_error = "M0 startingGold cannot be negative."
		return false

	if max_hand_size <= 0:
		last_error = "M0 maxHandSize must be positive."
		return false

	if opening_draw <= 0 or opening_draw > max_hand_size:
		last_error = "M0 openingDraw must be between 1 and maxHandSize."
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

	if int(rewards_data.get("artifactOfferCount", 0)) < 0:
		last_error = "M0 artifactOfferCount cannot be negative."
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


func _add_active_wave_packet(round_number: int, stacked: bool) -> void:
	active_wave_packets.append({
		"round": round_number,
		"spawned": 0,
		"total": _get_spawn_count(round_number),
		"stacked": stacked,
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
			"Try Call next if everyone agrees, or keep stepping to finish safely.",
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
	return {
		"can_call": false,
		"severity": "blocked",
		"score": 0,
		"round": _next_stack_round(),
		"headline": "Call next blocked: %s." % reason,
		"suggestion": _wave_stack_blocked_suggestion(reason),
		"details": [reason],
	}


func _wave_stack_risk_severity(score: int) -> String:
	if score >= 5:
		return "critical"
	if score >= 2:
		return "risky"
	return "stable"


func _wave_stack_risk_suggestion(severity: String) -> String:
	match severity:
		"critical":
			return "Hold the call; repair, rebuild, or spend the current hand first."
		"risky":
			return "Call only if the group has a repair or discard plan ready."
		_:
			return "Calling is reasonable if the group wants less waiting."


func _wave_stack_blocked_suggestion(reason: String) -> String:
	match reason:
		"wave_not_active":
			return "Start the current wave first."
		"reward_pending":
			return "Resolve pending rewards before calling another wave."
		"stack_limit_reached":
			return "The current stack is already at its limit."
		"no_next_round":
			return "There is no next wave to call."
		_:
			return "Resolve the blocked state before calling another wave."


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
		_join_values(get_active_directions(player_count)),
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


func _join_values(values: Array) -> String:
	var parts = PackedStringArray()
	for value in values:
		parts.append(str(value))
	return ", ".join(parts)
