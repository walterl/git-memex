#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
# shellcheck source=gmx_common.sh
source "$(dirname "$(readlink -f "$0")")"/gmx_common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename "$0") [<options...>]"
	e_info
	e_info "Reverts the last action. Really just 'git reset --hard HEAD^'."
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

if [ $# -gt 1 ]; then
	usage
	e_error "Unexpected arguments: $*"
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###

rungit reset --hard HEAD^
e_success "OK"
