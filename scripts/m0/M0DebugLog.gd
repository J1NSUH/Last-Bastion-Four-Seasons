class_name M0DebugLog
extends RefCounted

const MAX_ENTRIES = 16

var entries: Array[String] = []


func push(message: String) -> void:
	var timestamp = Time.get_time_string_from_system()
	entries.push_front("[%s] %s" % [timestamp, message])

	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)


func clear() -> void:
	entries.clear()


func to_text() -> String:
	var lines = PackedStringArray()
	for entry in entries:
		lines.append(entry)
	return "\n".join(lines)
