#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

### MAIN ###
if [[ $# -ne 2 || $1 == "-h" || $1 == "--help" ]]; then
	e_info "Usage: $(basename $0) <src> <dest>"
	e_info
	e_info "Rename <src> to <dest>."
	e_info "Essentially just \`git mv <src> <dest> && git commit...\`"
	exit 0
fi

src=$1
dest=$2

check_file_exists "${src}" || exit 1

rungit mv "${src}" "${dest}"
rungit commit --quiet -m "Rename: ${src} → ${dest}"

e_success "Renamed ${src} → ${dest}"
