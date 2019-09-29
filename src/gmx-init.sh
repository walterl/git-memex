#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

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
cat README.md | hilight
