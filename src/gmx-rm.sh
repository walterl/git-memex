#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

### FUNCTIONS ###
delete_file() {
	set +e
	gitrm_output=$(rungit rm --quiet "${filename}" 2>&1)
	err_code=$?
	if [[ "0" != "${err_code}" ]]; then
		e_error "Failed to delete ${filename}: ${gitrm_output}"
		exit ${err_code}
	fi
	set -e

	e_success "Deleted: ${filename}"
}
### /FUNCTIONS ###

### MAIN ###
if [[ $# == 0 || $1 == "-h" || $1 == "--help" ]]; then
	e_info "Usage: $(basename $0) <filename> [<filename> ...]"
	e_info
	e_info "Deletes specified files from the git-memex database."
	exit 0
fi

for filename in "$@"; do
	check_file_exists "${filename}" || exit 1
done

for filename in "$@"; do
	delete_file "${filename}"
done

rungit commit --quiet -m "Deleted $# files"
e_success "Deleted $# file(s)"
