extends SceneTree

const M0AlphaCoverageRunnerScript = preload("res://scripts/m0/M0AlphaCoverageRunner.gd")

var failed = false


func _init() -> void:
	var runner = M0AlphaCoverageRunnerScript.new()
	var result = runner.run_all()
	var aggregate: Dictionary = result.get("aggregate", {})
	var cases: Array = result.get("cases", [])
	var human_review_queue: Array = result.get("human_review_queue", [])
	var alpha_focus_queue: Array = result.get("alpha_focus_queue", [])
	var next_action_queue: Array = result.get("next_action_queue", [])
	var reject_reason_ids: Array = aggregate.get("reject_reason_ids", [])
	var by_class: Dictionary = aggregate.get("by_class", {})
	var recommendation_by_choice_type: Dictionary = aggregate.get("recommendation_by_choice_type", {})
	var recommendation_by_class: Dictionary = aggregate.get("recommendation_by_class", {})
	var recommendation_by_player_count: Dictionary = aggregate.get("recommendation_by_player_count", {})
	var recommendation_by_front: Dictionary = aggregate.get("recommendation_by_front", {})
	var recommendation_focus: Dictionary = aggregate.get("recommendation_focus", {})
	var recommendation_contrast_samples: Array = aggregate.get("recommendation_contrast_samples", [])
	var top_level_recommendation_contrast_samples: Array = result.get("recommendation_contrast_samples", [])

	_assert(bool(result.get("ok", false)), "alpha coverage runner passes all fixed cases")
	_assert(int(aggregate.get("case_count", 0)) == 16, "alpha coverage runner checks four classes across 1p to 4p")
	_assert(int(aggregate.get("fail_count", 0)) == 0, "alpha coverage runner has no failed cases")
	_assert(int(aggregate.get("required_signal_count", 0)) == 48, "alpha coverage runner tracks all required class signals")
	_assert(int(aggregate.get("observed_signal_count", 0)) == 48, "alpha coverage runner observes every required class signal")
	_assert(aggregate.get("missing_signal_ids", []).is_empty(), "alpha coverage runner reports no missing signals")
	_assert(reject_reason_ids.has("no_enemy_at_tile"), "alpha coverage runner records elementalist invalid target reason")
	_assert(reject_reason_ids.has("no_structure"), "alpha coverage runner records tinkerer invalid target reason")
	_assert(_has_prefix(reject_reason_ids, "would_fully_block"), "alpha coverage runner records full block rejection")
	_assert(by_class.keys().size() == 4, "alpha coverage runner summarizes every class")
	_assert(recommendation_by_choice_type.has("card"), "alpha coverage runner samples reward card recommendations")
	_assert(recommendation_by_choice_type.has("artifact"), "alpha coverage runner samples artifact recommendations")
	_assert(recommendation_by_choice_type.has("shop"), "alpha coverage runner samples shop recommendations")
	_assert(str(aggregate.get("recommendation_choice_summary", "")).contains("card"), "alpha coverage runner summarizes recommendation choices")
	_assert(str(aggregate.get("recommendation_choice_summary", "")).contains("artifact"), "alpha coverage runner summarizes artifact choices")
	_assert(str(aggregate.get("recommendation_choice_summary", "")).contains("shop"), "alpha coverage runner summarizes shop choices")
	_assert(recommendation_by_class.has("guardian"), "alpha coverage runner groups recommendation choices by class")
	_assert(recommendation_by_player_count.has("1P"), "alpha coverage runner groups recommendation choices by player count")
	_assert(recommendation_by_player_count.has("4P"), "alpha coverage runner groups recommendation choices through 4p")
	_assert(recommendation_by_front.has("east"), "alpha coverage runner groups recommendation choices by front")
	_assert(recommendation_by_front.has("west/north/east"), "alpha coverage runner groups 3p front recommendations")
	_assert(recommendation_by_front.has("west/north/east/south"), "alpha coverage runner groups 4p front recommendations")
	_assert(str(aggregate.get("recommendation_class_summary", "")).contains("Guardian card"), "alpha coverage runner summarizes recommendation choices by class")
	_assert(str(aggregate.get("recommendation_party_summary", "")).contains("1P card"), "alpha coverage runner summarizes recommendation choices by party")
	_assert(str(aggregate.get("recommendation_front_summary", "")).contains("east card"), "alpha coverage runner summarizes recommendation choices by front")
	_assert(bool(recommendation_focus.get("ok", false)), "alpha coverage runner builds recommendation focus report")
	_assert(str(recommendation_focus.get("choice_type", "")) == "card", "alpha coverage recommendation focus records top choice type")
	_assert(str(aggregate.get("recommendation_focus_summary", "")).contains("choice card"), "alpha coverage runner summarizes recommendation focus")
	_assert(str(aggregate.get("recommendation_focus_summary", "")).contains("human check: choice ownership"), "alpha coverage recommendation focus keeps human ownership gate")
	_assert(not recommendation_contrast_samples.is_empty(), "alpha coverage runner emits recommendation contrast samples")
	_assert(int(aggregate.get("recommendation_contrast_sample_count", 0)) == recommendation_contrast_samples.size(), "alpha coverage runner counts recommendation contrast samples")
	_assert(top_level_recommendation_contrast_samples.size() == recommendation_contrast_samples.size(), "alpha coverage exposes top-level recommendation contrast samples")
	if not recommendation_contrast_samples.is_empty():
		var first_sample: Dictionary = recommendation_contrast_samples[0]
		_assert(str(first_sample.get("class_id", "")) == "guardian", "alpha coverage contrast sample records class id")
		_assert(int(first_sample.get("player_count", 0)) == 1, "alpha coverage contrast sample records party size")
		_assert(str(first_sample.get("choice_key", "")) == "reward", "alpha coverage contrast sample starts from reward choice")
		_assert(str(first_sample.get("prompt", "")).contains("Run A:"), "alpha coverage contrast sample has a Run A prompt")
		_assert(str(first_sample.get("prompt", "")).contains("Run B:"), "alpha coverage contrast sample has a Run B prompt")
		_assert(str(first_sample.get("prompt", "")).contains("not an auto-pick"), "alpha coverage contrast sample preserves choice ownership wording")
		_assert(not str(first_sample.get("recommendation_reason", "")).is_empty(), "alpha coverage contrast sample keeps recommendation reason")
		var guardian_solo_samples = _samples_for_case(recommendation_contrast_samples, "guardian", 1)
		_assert(guardian_solo_samples.size() >= 3, "alpha coverage contrast samples cover the first focus choice set")
		_assert(_samples_contain_choice_key(guardian_solo_samples, "reward"), "alpha coverage contrast samples include reward choice")
		_assert(_samples_contain_choice_key(guardian_solo_samples, "artifact"), "alpha coverage contrast samples include artifact choice")
		_assert(_samples_contain_choice_key(guardian_solo_samples, "shop"), "alpha coverage contrast samples include shop choice")
		var tinkerer_full_party_samples = _samples_for_case(recommendation_contrast_samples, "tinkerer", 4)
		_assert(tinkerer_full_party_samples.size() >= 3, "alpha coverage contrast samples cover the 4p final class choice set")
	_assert(human_review_queue.size() == 16, "alpha coverage runner emits human review queue")
	_assert(alpha_focus_queue.size() == human_review_queue.size(), "alpha coverage runner mirrors review queue for alpha focus")
	_assert(next_action_queue.size() == human_review_queue.size(), "alpha coverage runner emits next action queue")
	if not human_review_queue.is_empty():
		var first_review: Dictionary = human_review_queue[0]
		_assert(str(first_review.get("class_id", "")) == "guardian", "human review queue starts from guardian")
		_assert(int(first_review.get("player_count", 0)) == 1, "human review queue starts from solo case")
		_assert(str(first_review.get("direction", "")) == "east", "human review queue preserves focus direction")
		_assert(str(first_review.get("primary_signal", "")) == "human_alpha_review", "human review queue keeps functional-pass cases as human review")
		_assert(str(first_review.get("next_probe", "")).contains("taunt"), "human review queue names class-specific probe")
		_assert(int(first_review.get("review_priority_score", 0)) > 0, "human review queue records review priority score")
		_assert(str(first_review.get("review_priority_reason", "")).contains("human readability check"), "human review queue records review priority reason")
		_assert(str(first_review.get("recommendation_choice_type", "")) == "card", "human review queue keeps reward recommendation choice type")
		_assert(str(first_review.get("recommendation_set_summary", "")).contains("Artifact:"), "human review queue summarizes artifact recommendation")
		_assert(str(first_review.get("recommendation_set_summary", "")).contains("Shop:"), "human review queue summarizes shop recommendation")
		_assert(str(first_review.get("artifact_preparation_summary", "")).contains("Artifact memo"), "human review queue carries artifact preparation memo")
		var first_recommendations: Dictionary = first_review.get("recommendations", {})
		_assert(first_recommendations.has("reward"), "human review queue keeps reward recommendation set entry")
		_assert(first_recommendations.has("artifact"), "human review queue keeps artifact recommendation set entry")
		_assert(first_recommendations.has("shop"), "human review queue keeps shop recommendation set entry")
		var first_artifact_recommendation: Dictionary = first_recommendations.get("artifact", {})
		_assert(bool(first_artifact_recommendation.get("claim_ok", false)), "human review queue records artifact claim sample")
		_assert(str(first_artifact_recommendation.get("preparation_summary", "")).contains("Next R"), "human review queue records artifact next-wave prep summary")
		_assert(str(first_review.get("recommendation_focus_summary", "")).contains("Human check: choice ownership"), "human review queue keeps recommendation ownership focus")
		_assert(str(first_review.get("recommendation_contrast_probe", "")).contains("Run A:"), "human review queue keeps recommendation contrast probe")
		_assert(str(first_review.get("recommendation_contrast_probe", "")).contains("Run B:"), "human review queue keeps recommendation contrast alternate")
		var analysis_cards: Array = first_review.get("analysis_cards", [])
		_assert(analysis_cards.size() >= 8, "human review queue includes panel analysis cards")
		_assert(_analysis_cards_contain(analysis_cards, "Review Reason"), "human review queue includes review reason card")
		_assert(_analysis_cards_contain(analysis_cards, "Reward Lens"), "human review queue includes reward lens card")
		_assert(_analysis_cards_contain(analysis_cards, "Choice Set"), "human review queue includes full choice-set card")
		_assert(_analysis_cards_contain(analysis_cards, "Artifact Prep"), "human review queue includes artifact prep card")
		_assert(_analysis_cards_contain(analysis_cards, "Recommendation Focus"), "human review queue includes recommendation focus card")
		_assert(_analysis_cards_contain(analysis_cards, "Recommendation Contrast"), "human review queue includes recommendation contrast card")
	if next_action_queue.size() > 1:
		var first_action: Dictionary = next_action_queue[0]
		_assert(str(first_action.get("source", "")) == "alpha_coverage_runner", "alpha coverage next action records its source")
		_assert(str(first_action.get("document", "")) == "docs/PLAYTEST_AND_BALANCE.md", "alpha coverage next action points to playtest doc")
		_assert(int(first_action.get("review_priority_score", 0)) > 0, "alpha coverage next action carries review priority score")
		_assert(str(first_action.get("review_priority_reason", "")).contains("human readability check"), "alpha coverage next action carries review priority reason")
		_assert(str(first_action.get("recommendation_choice_type", "")) == "card", "alpha coverage next action carries reward recommendation choice type")
		_assert(str(first_action.get("recommendation_set_summary", "")).contains("Shop:"), "alpha coverage next action carries full choice-set summary")
		_assert(str(first_action.get("artifact_preparation_summary", "")).contains("Artifact memo"), "alpha coverage next action carries artifact prep memo")

	for case_value in cases:
		if typeof(case_value) != TYPE_DICTIONARY:
			continue

		var case_result: Dictionary = case_value
		var class_id = str(case_result.get("classId", ""))
		var player_count = int(case_result.get("playerCount", 0))
		var required_signals: Array = case_result.get("requiredSignalIds", [])
		var observed_signals: Array = case_result.get("observedSignalIds", [])
		var active_directions: Array = case_result.get("activeDirections", [])
		var reward_recommendation: Dictionary = case_result.get("rewardRecommendation", {})
		var artifact_recommendation: Dictionary = case_result.get("artifactRecommendation", {})
		var shop_recommendation: Dictionary = case_result.get("shopRecommendation", {})
		var recommendations: Dictionary = case_result.get("recommendations", {})
		_assert(bool(case_result.get("passed", false)), "coverage case passes: %s %sP" % [class_id, player_count])
		_assert(required_signals.size() == 3, "coverage case has three required signals: %s" % class_id)
		_assert(observed_signals.size() == 3, "coverage case observes three signals: %s %sP" % [class_id, player_count])
		_assert(str(case_result.get("judgementScope", "")) == "functionality_only", "coverage case avoids balance judgement")
		_assert(not reward_recommendation.is_empty(), "coverage case records reward recommendation: %s %sP" % [class_id, player_count])
		_assert(int(reward_recommendation.get("offer_count", 0)) > 0, "coverage case records reward offer sample: %s %sP" % [class_id, player_count])
		_assert(not artifact_recommendation.is_empty(), "coverage case records artifact recommendation: %s %sP" % [class_id, player_count])
		_assert(int(artifact_recommendation.get("offer_count", 0)) > 0, "coverage case records artifact offer sample: %s %sP" % [class_id, player_count])
		_assert(bool(artifact_recommendation.get("claim_ok", false)), "coverage case claims artifact sample: %s %sP" % [class_id, player_count])
		_assert(str(artifact_recommendation.get("preparation_summary", "")).contains("Artifact memo"), "coverage case records artifact prep memo: %s %sP" % [class_id, player_count])
		_assert(not shop_recommendation.is_empty(), "coverage case records shop recommendation: %s %sP" % [class_id, player_count])
		_assert(int(shop_recommendation.get("offer_count", 0)) > 0, "coverage case records shop offer sample: %s %sP" % [class_id, player_count])
		_assert(recommendations.has("reward") and recommendations.has("artifact") and recommendations.has("shop"), "coverage case keeps combined recommendation set: %s %sP" % [class_id, player_count])
		if player_count == 1:
			_assert(active_directions == ["east"], "solo coverage keeps east-only direction")
		elif player_count == 2:
			_assert(active_directions == ["north", "east"], "2p coverage keeps north/east directions")
		elif player_count == 3:
			_assert(active_directions == ["west", "north", "east"], "3p coverage keeps west/north/east directions")
		elif player_count == 4:
			_assert(active_directions == ["west", "north", "east", "south"], "4p coverage keeps all directions")

		match class_id:
			"guardian":
				_assert(observed_signals.has("taunt_applied"), "guardian coverage observes taunt")
				_assert(observed_signals.has("guardian_hit_received"), "guardian coverage observes hit intake")
				_assert(observed_signals.has("thorns_or_guard_log"), "guardian coverage observes thorns or guard log")
			"architect":
				_assert(observed_signals.has("path_changed"), "architect coverage observes path change")
				_assert(observed_signals.has("full_block_rejected"), "architect coverage observes full block rejection")
				_assert(observed_signals.has("barricade_break_or_debris_log"), "architect coverage observes debris damage")
			"elementalist":
				_assert(observed_signals.has("splash_damage_applied"), "elementalist coverage observes splash")
				_assert(observed_signals.has("control_effect_applied"), "elementalist coverage observes control stand-in")
				_assert(observed_signals.has("invalid_target_rejected"), "elementalist coverage observes invalid target rejection")
			"tinkerer":
				_assert(observed_signals.has("aura_applied"), "tinkerer coverage observes aura")
				_assert(observed_signals.has("repair_or_boost_applied"), "tinkerer coverage observes repair or boost")
				_assert(observed_signals.has("invalid_target_rejected"), "tinkerer coverage observes invalid target rejection")

	for line in result.get("lines", []):
		print(line)

	print("[REPORT] alpha coverage cases=%s pass=%s fail=%s signals=%s/%s" % [
		aggregate.get("case_count", 0),
		aggregate.get("pass_count", 0),
		aggregate.get("fail_count", 0),
		aggregate.get("observed_signal_count", 0),
		aggregate.get("required_signal_count", 0),
	])

	quit(1 if failed else 0)


func _has_prefix(values: Array, prefix: String) -> bool:
	for value in values:
		if str(value).begins_with(prefix):
			return true

	return false


func _analysis_cards_contain(cards: Array, title: String) -> bool:
	for card_value in cards:
		if typeof(card_value) != TYPE_DICTIONARY:
			continue

		var card: Dictionary = card_value
		if str(card.get("title", "")) == title:
			return true

	return false


func _samples_for_case(samples: Array, class_id: String, player_count: int) -> Array:
	var result = []
	for sample_value in samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue

		var sample: Dictionary = sample_value
		if str(sample.get("class_id", "")) == class_id and int(sample.get("player_count", 0)) == player_count:
			result.append(sample)

	return result


func _samples_contain_choice_key(samples: Array, choice_key: String) -> bool:
	for sample_value in samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue

		var sample: Dictionary = sample_value
		if str(sample.get("choice_key", "")) == choice_key:
			return true

	return false


func _assert(condition: bool, label: String) -> void:
	if condition:
		print("[PASS] %s" % label)
	else:
		failed = true
		push_error("[FAIL] %s" % label)
