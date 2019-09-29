#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

### USAGE ###
if [[ $# != 1 || $1 == "-h" || $1 == "--help" ]]; then
	e_info "Usage: $(basename $0) <filename>"
	e_info
	e_info "Edit an existing file."
	e_info "The file's changed content will be automatically be expanded, and the file name updated based on the expanded content."
	exit 0
fi
### /USAGE ###

### MAIN ###
filename=$1

check_file_exists "${filename}" || exit 1
${TEXT_EDITOR} "${filename}"

expand_file_content "${filename}"

if [ -z "$(rungit status -s "${filename}")" ]; then
	e_arrow "Nothing changed."
	exit 0
fi

new_filename=$(compute_filename "${filename}")

extended_commit_msg=
output_old_filename=
if [[ "${new_filename}" != "${filename}" ]]; then
	cp "${filename}" "${new_filename}"
	rungit rm --quiet --force "${filename}"
	extended_commit_msg="\n\nOld file name: ${filename}"
	output_old_filename=" (was ${filename})"

	filename=${new_filename}
fi

rungit add "${filename}"
rungit commit --quiet -m "Changed file: ${filename}$(echo -e ${extended_commit_msg})"

e_success "Updated file: ${filename}${output_old_filename}"
