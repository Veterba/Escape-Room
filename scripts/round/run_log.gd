## Appends one line per finished round to a CSV file, used to tune the game after playtests.
class_name RunLog

const DEFAULT_PATH := "user://runs.csv"
const HEADER: PackedStringArray = [
	"date", "map", "result", "seconds_used", "hearts_lost", "times_trapped", "gun_used_most",
]


static func append(path: String, row: PackedStringArray) -> void:
	var is_new := not FileAccess.file_exists(path)
	var file := FileAccess.open(path, FileAccess.WRITE if is_new else FileAccess.READ_WRITE)
	if file == null:
		push_error("Cannot write the run log at %s" % path)
		return
	if is_new:
		file.store_csv_line(HEADER)
	else:
		file.seek_end()
	file.store_csv_line(row)
