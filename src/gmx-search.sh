#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
# shellcheck source=gmx_common.sh
source "$(dirname "$(readlink -f "$0")")"/gmx_common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename "$0") [options] [<search terms>]"
	e_info
	e_info "Update or query the database's full-text index."
	e_info
	e_info "Options:"
	e_info "-u    Create/update full-text index. Index is not queried."
	e_info "-h    Display this message"
	e_info "-v    Display script version"
}

### PARSE COMMAND-LINE ARGS ###
update_index=
search_terms=

while getopts ":uhv" opt
do
	case $opt in
		u)  update_index=1
			;;
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
	search_terms=$*
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
if [ -z "${HAS_WASHER}" ]; then
	e_error "washer is required but not found:"
	e_error "$ pip install --user washer"
	exit 1
fi

if [ -n "$update_index" ]; then
	find "${GMX_DIR}" -type f -iname '*.md' -print0 | xargs -0 washer --indexdir "$WASHER_INDEX" index --lang en --overwrite -- 

	if ! grep .dbindex .gitignore &> /dev/null; then
		echo .dbindex >> .gitignore
		git add .gitignore
		git commit -m 'Git-ignore full-text search index'
	fi
else
	washer --indexdir "$WASHER_INDEX" search "$search_terms"
fi
