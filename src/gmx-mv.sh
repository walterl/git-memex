#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $(readlink -f $0))/gmx-common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename $0) <src> <dest>"
	e_info
	e_info "Rename <src> to <dest>."
	e_info "Essentially just \`git mv <src> <dest> && git commit...\`"
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

if [ $# -ne 2 ]; then
	usage
	e_error "Exactly two file names are required."
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
src=$1
dest=$2

check_file_exists "${src}" || exit 1

ensure_dir_exists $(dirname ${dest})

rungit mv "${GMX_DIR}/${src}" "${GMX_DIR}/${dest}"
rungit commit --quiet -m "Rename: ${src} → ${dest}"

e_success "Renamed ${src} → ${dest}"
