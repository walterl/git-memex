#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $(readlink -f $0))/gmx_common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename $0) [options]"
	e_info
	e_info "Initialize the current directory for use with git-memex."
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

if [ $# -gt 0 ]; then
	usage
	e_error "Unexpected arguments: $@"
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
if check_gmx_dir_initialized; then
	e_error "Already a git repository: ${GMX_DIR}"
	exit 1
fi

rungit init
cp ${RES_DIR}/defaults/{README.md,.ignore} ${GMX_DIR}/
rungit add -f ${GMX_DIR}/{README.md,.ignore}
rungit commit -m 'Initial commit with default README'
echo
e_success "Done."
echo
cat "${GMX_DIR}/README.md" | hilight
