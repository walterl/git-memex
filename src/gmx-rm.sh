#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename $0) <filename> [<filename> ...]"
	e_info
	e_info "Deletes specified files from the git-memex database."
	e_info
	e_info "Options:"
	e_info "-h    Display this message"
	e_info "-v    Display script version"
}

### PARSE COMMAND-LINE ARGS ###
while getopts ":hv" opt
do
	case $opt in
		h)	usage
			exit 0
			;;
		v)	e_info "git-memex version ${GMX_VERSION} -- $(basename $0)"
			exit 0
			;;
		*)	usage
			e_error "Option does not exist: $OPTARG"
			exit 1
			;;
	esac
done
shift $(($OPTIND-1))

if [ $# -lt 1 ]; then
	usage
	e_error "No files specified."
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### FUNCTIONS ###
delete_file() {
	filename=$1
	set +e
	gitrm_output=$(rungit rm --quiet "${GMX_DIR}/${filename}" 2>&1)
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
for filename in "$@"; do
	filename="${GMX_DIR}/${filename#"${GMX_DIR}/"}"
	check_file_exists "${filename}" || exit 1
done

for filename in "$@"; do
	delete_file "${filename#"${GMX_DIR}/"}"
done

rungit commit --quiet -m "Deleted $# files"
e_success "Deleted $# file(s)"
