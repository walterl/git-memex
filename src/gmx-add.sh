#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

### FUNCTIONS ###
expand_content() {
	${PYTHON_CMD} ${PY_SCRIPT_DIR}/expand_content.py $@
}

extrapolate_filename() {
	filename=$(${PYTHON_CMD} ${PY_SCRIPT_DIR}/filename_from_content.py $@)

	if [ -f "${filename}" ]; then
		extension="${filename##*.}"
		base_filename="${filename%.*}"
		i=1
		while [ -f "${base_filename}__${i}.${extension}" ]; do
			i=$((i+1))
		done
		filename="${base_filename}__${i}.${extension}"
	fi

	echo ${filename}
}
### /FUNCTIONS ###

### MAIN ###
if ! check_gmx_dir_initialized; then
	e_error "git-memex not initialized. Run gmx-init first."
	exit 1
fi

tmp_file=$(make_temp_file ".md")
e_debug "Temp add file: ${tmp_file}"

$ITEM_EDITOR "${tmp_file}"
if [[ $(wc -c "${tmp_file}" | cut -d' ' -f 1) == "0" ]]; then
	e_error "Nothing to add. Aborting."
	exit 1
fi

expand_content "${tmp_file}"

filename=$(extrapolate_filename "${tmp_file}")

e_debug "Adding item: ${filename}"

[ -z "${filename}" ] && e_error "Unable to determine file name for new item. Aborting." && exit 1

cp "${tmp_file}" "${GMX_DIR}/${filename}"
rm "${tmp_file}"
rungit add "${GMX_DIR}/${filename}"
rungit commit --quiet -m "Added file: ${filename}"

e_success "New file: ${filename}"
