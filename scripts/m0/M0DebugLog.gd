class_name M0DebugLog
extends RefCounted

const MAX_ENTRIES = 16
const CATEGORY_ALL = "all"
const CATEGORY_COMBAT = "combat"
const CATEGORY_REWARD = "reward"
const CATEGORY_SETUP = "setup"
const CATEGORY_SYSTEM = "system"

var entries: Array = []


func push(message: String, category: String = "") -> void:
	var timestamp = Time.get_time_string_from_system()
	var resolved_category = _resolve_category(message, category)
	var label = get_category_label(resolved_category)
	entries.push_front({
		"timestamp": timestamp,
		"message": message,
		"category": resolved_category,
		"important": _is_important_message(message, resolved_category),
		"text": "[%s] [%s] %s" % [timestamp, label, message]
	})

	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)


func clear() -> void:
	entries.clear()


func to_text(category: String = CATEGORY_ALL, important_only: bool = false) -> String:
	return to_text_filtered(category, important_only)


func to_text_filtered(category: String = CATEGORY_ALL, important_only: bool = false) -> String:
	var lines = PackedStringArray()
	for entry in entries:
		if _entry_matches(entry, category, important_only):
			lines.append(_entry_text(entry))
	return "\n".join(lines)


func get_categories() -> Array:
	return [
		CATEGORY_ALL,
		CATEGORY_COMBAT,
		CATEGORY_REWARD,
		CATEGORY_SETUP,
		CATEGORY_SYSTEM
	]


func get_category_label(category: String) -> String:
	match _normalize_category(category):
		CATEGORY_COMBAT:
			return "Combat"
		CATEGORY_REWARD:
			return "Reward"
		CATEGORY_SETUP:
			return "Setup"
		CATEGORY_SYSTEM:
			return "System"
		_:
			return "All"


func _entry_matches(entry, category: String, important_only: bool) -> bool:
	var normalized_category = _normalize_category(category)
	if normalized_category != CATEGORY_ALL:
		if typeof(entry) != TYPE_DICTIONARY:
			return false
		if str(entry.get("category", CATEGORY_SYSTEM)) != normalized_category:
			return false

	if important_only:
		if typeof(entry) != TYPE_DICTIONARY:
			return false
		if not bool(entry.get("important", false)):
			return false

	return true


func _entry_text(entry) -> String:
	if typeof(entry) == TYPE_DICTIONARY:
		return str(entry.get("text", ""))

	return str(entry)


func _resolve_category(message: String, category: String) -> String:
	var normalized_category = _normalize_category(category)
	if normalized_category != CATEGORY_ALL:
		return normalized_category

	var lowered = message.to_lower()
	if _contains_any(lowered, [
		"wave",
		"spawn",
		"hit",
		"kill",
		"base damage",
		"boss",
		"enemy",
		"structure",
		"tower",
		"barricade",
		"taunt",
		"thorns",
		"explosion",
		"repair"
	]):
		return CATEGORY_COMBAT

	if _contains_any(lowered, [
		"reward",
		"artifact",
		"shop",
		"gold",
		"deck change",
		"removed"
	]):
		return CATEGORY_REWARD

	if _contains_any(lowered, [
		"run started",
		"opening hand",
		"player count",
		"autoplay class",
		"lead class",
		"build mode",
		"m0_test_data",
		"active front seed",
		"data is not loaded"
	]):
		return CATEGORY_SETUP

	return CATEGORY_SYSTEM


func _normalize_category(category: String) -> String:
	match category.to_lower():
		CATEGORY_COMBAT:
			return CATEGORY_COMBAT
		CATEGORY_REWARD:
			return CATEGORY_REWARD
		CATEGORY_SETUP:
			return CATEGORY_SETUP
		CATEGORY_SYSTEM:
			return CATEGORY_SYSTEM
		_:
			return CATEGORY_ALL


func _is_important_message(message: String, category: String) -> bool:
	var lowered = message.to_lower()
	if category == CATEGORY_REWARD and _contains_any(lowered, ["claimed", "equipped", "removed", "skipped"]):
		return true

	return _contains_any(lowered, [
		"failed",
		"failure",
		"rejected",
		"locked",
		"cannot",
		"destroyed",
		"base damage",
		"leak",
		"boss",
		"reward waiting",
		"artifact",
		"shop",
		"risk ping",
		"alpha focus",
		"outcome",
		"run complete"
	])


func _contains_any(text: String, fragments: Array) -> bool:
	for fragment in fragments:
		if text.contains(str(fragment)):
			return true

	return false
