#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $(readlink -f $0))/gmx_common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename $0) [options]"
	e_info
	e_info "Commit all outstanding changes."
	e_info
	e_info "Options:"
	e_info "-r         Review changes before committing."
	e_info "-h         Display this message"
	e_info "-v         Display script version"
}

### PARSE COMMAND-LINE ARGS ###
review_changes=

while getopts ":rhv" opt
do
	case $opt in
		r)	review_changes=1
			;;
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

if [ $# -gt 0 ]; then
	usage
	e_error "Unexpected arguments: $@"
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
rungit add "${GMX_DIR}"

if [ -z "$(rungit status -s)" ]; then
	e_success "No changes to commit."
	exit 0
fi

rungit status -s  # Run it again to get git's colorful goodness :)

if [ -n "${review_changes}" ]; then
	e_header "Is the above changes OK? (type \"yes\")"
	read answer

	if [[ "${answer}" != "yes" ]]; then
		e_arrow "Unstaging changes and aborting."
		rungit reset --quiet HEAD .
		e_success "Done."
		exit 0
	fi

	e_arrow "Committing staged changes..."
fi

commit_msg="External changes"
if [ -n "$1" ]; then
	commit_msg="${commit_msg}: $1"
fi
rungit commit --quiet -m "${commit_msg}"
e_success "Done."
