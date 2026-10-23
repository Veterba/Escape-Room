#!/bin/sh
# Builds the Windows and macOS releases into builds/: EscapeBoom-windows.zip and EscapeBoom-macos.zip.
# Needs the Godot export templates for the exact Godot version (see README.md).
# Set GODOT to use a Godot binary that is not on the PATH as "godot".
set -eu

cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"

rm -rf builds
mkdir -p builds/windows

# A fresh clone needs one import so Godot knows the script class names.
"$GODOT" --headless --path . --import

"$GODOT" --headless --path . --export-release "Windows Desktop" builds/windows/EscapeBoom.exe
"$GODOT" --headless --path . --export-release "macOS" builds/EscapeBoom-macos.zip

# Godot does not always exit with an error when an export fails, so check the files.
for file in builds/windows/EscapeBoom.exe builds/EscapeBoom-macos.zip; do
	if [ ! -s "$file" ]; then
		echo "Export failed: $file is missing." >&2
		exit 1
	fi
done

# The .exe has the game data embedded, so the Windows zip holds that one file.
(cd builds/windows && zip -q ../EscapeBoom-windows.zip EscapeBoom.exe)
rm -rf builds/windows

echo "Built builds/EscapeBoom-windows.zip and builds/EscapeBoom-macos.zip"
