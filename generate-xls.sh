#!/usr/bin/env bash

# Absolute path to TR file
TR_FILE=./traceRouteOfTop.tr

# Generate XLS spreadsheets by running all Awk files in the given directory against the TR file defined in the TR_FILE
generate-xls() {
	local awk_dir="$(realpath "$1")"
	local tr_file="$(realpath "$2")"
	# cd into directory temporarily
	pushd "$awk_dir" > /dev/null
	# Remove all XLS files first
	rm -f ./*.xls
	# Run each awk file against TR file
	for awk_filename in $(ls "$awk_dir"); do
		awk -f "$awk_dir"/"$awk_filename" "$tr_file"
	done
	# cd into previous directory
	popd > /dev/null
}

# Generate XLS spreadsheets for all
generate-xls ./Folder10 "$TR_FILE"
generate-xls ./Folder16 "$TR_FILE"
generate-xls ./Folder13 "$TR_FILE"
generate-xls ./Folder9 "$TR_FILE"
zip -q ./xls-files.zip ./Folder*/*.xls
