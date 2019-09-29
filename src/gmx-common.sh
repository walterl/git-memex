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
e_debug() {
	if [ -n "${GMX_DEBUG}" ]; then
		echo -e " \033[1;33mﴫ\033[0m  $@"
	fi
}

# Usage: check_file_exists "${filename}" || exit 1
check_file_exists() {
	filename="$1"
	if [ ! -f "${filename}" ]; then
		e_error "No such file: ${filename}";
		return 1
	fi
}

check_gmx_dir_initialized() {
	[ -d ${GMX_DIR:-${PWD}}/.git ] && return 0
	return 1
}

find_text_editor() {
	editor=${FCEDIT:-${VISUAL:-${EDITOR}}}
	[ -n "${editor}" ] && echo ${editor} && return

	for editor in sensible-editor vim vi nano; do
		command -v ${editor} > /dev/null && echo ${editor} && return
	done

	e_error "Unable to find a text editor. Set \$EDITOR to your editor command."
	exit 1
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
TEXT_EDITOR=$(find_text_editor)
HAS_PYGMENTIZE=$(command -v pygmentize > /dev/null && echo 1)
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
PY_SCRIPT_DIR="${SCRIPT_DIR}/pygmx"
PYTHON_CMD="${SCRIPT_DIR}/python"
RES_DIR=$(readlink -f "${SCRIPT_DIR}/../res")
### /ENV ###

e_debug "Running from ${SCRIPT_DIR}"
e_debug "Initializing git-memex in ${GMX_DIR}"
e_debug "Using editor: ${TEXT_EDITOR}"

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

if ! ${PYTHON_CMD} --version &> /dev/null; then
	e_error "Python environment not configured. See ${PYTHON_CMD} for further instructions."
	exit 127
fi
