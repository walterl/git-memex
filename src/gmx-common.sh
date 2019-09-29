#!/usr/bin/env bash

### BOOTSTRAP ###
set -e
### /BOOTSTRAP ###

### UTILITY FUNCTIONS ###
e_header()   { echo -e "\n\033[1m$@\033[0m"; }
e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@"; }
e_info()     { echo -e " \033[1;34mⓘ\033[0m  $@"; }
e_debug()    { [ -n "${GMX_DEBUG}" ] && echo -e " \033[1;33mﴫ\033[0m  $@"; }

check_gmx_dir_initialized() {
	[ -d ${GMX_DIR:-${PWD}}/.git ] && return 0
	return 1
}

get_temp_dir() {
	tmpdir=$TMPDIR

	[[ -z ${tmpdir} && -n ${XDG_RUNTIME_DIR} ]] && tmpdir=${XDG_RUNTIME_DIR}
	[ -z ${tmpdir} ] && tmpdir=/tmp

	tmpdir="${tmpdir}/gmx"
	[ ! -d ${tmpdir} ] && mkdir -p ${tmpdir} && chown ${USER}: ${tmpdir} && chmod 700 ${tmpdir}

	echo ${tmpdir}
}

make_temp_file() {
	mktemp --suffix=$1 --tmpdir=$(get_temp_dir) "gmx-add.XXXXXXXXXX"
}
### /UTILITY FUNCTIONS ###

### ENV ###
GMX_DIR=$PWD
GIT="git -C ${GMX_DIR}"
ITEM_EDITOR=$(
	editor=${FCEDIT:-${VISUAL:-${EDITOR}}}
	[ -n "${editor}" ] && echo ${editor} && return

	for editor in sensible-editor vim vi nano; do
		command -v ${editor} > /dev/null && echo ${editor} && return
	done

	e_error "Unable to find a text editor. Set \$EDITOR to your editor command."
	exit 1
)
HAS_PYGMENTIZE=$(command -v pygmentize > /dev/null && echo 1)
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
RES_DIR=$(readlink -f "${SCRIPT_DIR}/../res")
### /ENV ###

e_debug "Running from ${SCRIPT_DIR}"
e_debug "Initializing git-memex in ${GMX_DIR}"
e_debug "Using editor: ${ITEM_EDITOR}"

rungit() {
	git -C ${GMX_DIR} "$@"
}

hilight() {
	arg=$1
	if [[ $arg == "-" ]]; then
		arg=""
	fi

	if [ -n ${HAS_PYGMENTIZE} ]; then
		pygmentize -f console16m -l md ${arg}
	else
		cat ${arg}
	fi
}
