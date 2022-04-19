#!/usr/bin/env bash

### BOOTSTRAP ###
set -e
### /BOOTSTRAP ###

### UTILITY FUNCTIONS ###
e_header()   { echo -e "\n\033[1m$*\033[0m"; }
e_success()  { echo -e " \033[1;32m✔\033[0m  $*"; }
e_error()    { echo -e " \033[1;31m✖\033[0m  $*"; }
e_arrow()    { echo -e " \033[1;33m➜\033[0m  $*"; }
e_info()     { echo -e " \033[1;34mⓘ\033[0m  $*"; }
e_debug() {
	if [ -n "${GMX_DEBUG}" ]; then
		echo -e " \033[1;33mﴫ\033[0m  $*"
	fi
}

find_text_editor() {
	editor=${FCEDIT:-${VISUAL:-${EDITOR}}}
	[ -n "${editor}" ] && echo "${editor}" && return

	for editor in sensible-editor vim vi nano; do
		command -v ${editor} > /dev/null && echo "${editor}" && return
	done

	e_error "Unable to find a text editor. Set \$EDITOR to your editor command."
	exit 1
}
### /UTILITY FUNCTIONS ###

### ENV ###
GMX_DIR=$PWD
GMX_VERSION="0.1.0"
TEXT_EDITOR=$(find_text_editor)
HAS_FZF=$(command -v fzf > /dev/null && echo 1)
HAS_PYGMENTIZE=$(command -v pygmentize > /dev/null && echo 1)
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
PY_SCRIPT_DIR="${SCRIPT_DIR}/pygmx"
PYTHON_CMD="${SCRIPT_DIR}/python"
RES_DIR=$(readlink -f "${SCRIPT_DIR}/../res")

export GMX_DIR GMX_VERSION TEXT_EDITOR HAS_FZF HAS_PYGMENTIZE SCRIPT_DIR PY_SCRIPT_DIR PYTHON_CMD RES_DIR
### /ENV ###

### MAIN LIBRARY ###
e_debug "Running from ${SCRIPT_DIR}"
e_debug "Using git-memex repository in ${GMX_DIR}"
e_debug "Using editor: ${TEXT_EDITOR}"

if ! ${PYTHON_CMD} --version &> /dev/null; then
	e_error "Python environment not configured. See ${PYTHON_CMD} for further instructions."
	exit 127
fi

# Usage: check_file_exists "${filename}" || exit 1
check_file_exists() {
	filename="$1"
	if [ ! -f "${filename}" ]; then
		e_error "No such file: ${filename}";
		return 1
	fi
}

# Usage: check_dir_exists "${dirname}" || exit 1
check_dir_exists() {
	dirname="$1"
	if [ ! -d "${dirname}" ]; then
		e_error "No such directory: ${dirname}";
		return 1
	fi
}

check_gmx_dir_initialized() {
	[ -d "${GMX_DIR:-${PWD}}/.git" ] && return 0
	return 1
}

expand_file_content() {
	${PYTHON_CMD} "${PY_SCRIPT_DIR}/expand_content.py" "$@"
}

compute_filename() {
	${PYTHON_CMD} "${PY_SCRIPT_DIR}/filename_from_content.py" "$@"
}

ensure_dir_exists() {
	dir=$1

	[ -d "${dir}" ] || mkdir -p "${dir}"
}

get_unique_filename() {
	filename=$1

	if [ -f "${filename}" ]; then
		extension="${filename##*.}"
		base_filename="${filename%.*}"
		i=1
		while [ -f "${base_filename}__${i}.${extension}" ]; do
			i=$((i+1))
		done
		filename="${base_filename}__${i}.${extension}"
	fi

	echo "${filename}"
}

hilight() {
	arg=$1
	if [[ $arg == "-" ]]; then
		arg=""
	fi

	if [ -n "${HAS_PYGMENTIZE}" ]; then
		pygmentize -f console256 -l md ${arg}
	else
		cat ${arg}
	fi
}

make_temp_file() {
	mktemp --suffix="$1" --tmpdir="${GMX_DIR}/$2" "new-file.XXXXXXXXXX"
}

rungit() {
	git -C "${GMX_DIR}" "$@"
}
