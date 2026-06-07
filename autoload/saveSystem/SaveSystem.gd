extends Node

const DEFAULT_SAVE_PATH = "user://save.json"

var savePath: String = DEFAULT_SAVE_PATH

func init(path: String = DEFAULT_SAVE_PATH) -> void:
	savePath = path

func save(data: Dictionary) -> void:
	if OS.get_name() == "Web":
		_saveToLocalStorage(data)
	else:
		_saveToFile(data)

func load() -> Dictionary:
	if OS.get_name() == "Web":
		return _loadFromLocalStorage()
	else:
		return _loadFromFile()

func _saveToFile(data: Dictionary) -> void:
	var file := FileAccess.open(savePath, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: cannot open file for writing: %s" % savePath)
		return
	file.store_string(JSON.stringify(data))
	file.close()

func _loadFromFile() -> Dictionary:
	if not FileAccess.file_exists(savePath):
		return {}
	var file := FileAccess.open(savePath, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: cannot open file for reading: %s" % savePath)
		return {}
	var raw := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if parsed is Dictionary:
		return parsed
	return {}

func _saveToLocalStorage(data: Dictionary) -> void:
	JavaScriptBridge.eval(
		"localStorage.setItem('save', JSON.stringify(%s));" % JSON.stringify(data)
	)

func _loadFromLocalStorage() -> Dictionary:
	var raw: Variant = JavaScriptBridge.eval(
		"localStorage.getItem('save') ?? 'null';"
	)
	if raw == null or raw == "null":
		return {}
	var parsed: Variant = JSON.parse_string(str(raw))
	if parsed is Dictionary:
		return parsed
	return {}
