#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
# shellcheck source=gmx_common.sh
source "$(dirname "$(readlink -f "$0")")"/gmx_common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename "$0") [options]"
	e_info
	e_info "Fuzzy find a file (with fzf) and open it in gmx-edit."
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
		v)	e_info "git-memex version ${GMX_VERSION} -- $(basename "$0")"
			exit 0
			;;
		*)	usage
			e_error "Option does not exist: $OPTARG"
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

if [ $# -gt 0 ]; then
	usage
	e_error "Unexpected arguments: $*"
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
if [ -z "${HAS_FZF}" ]; then
	e_error "fzf is required but not found."
fi

filename=$(fzf --preview="gmx-preview {}")
[ -n "$filename" ] && gmx-edit -r "$filename"
