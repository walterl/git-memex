#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
# shellcheck source=gmx_common.sh
source "$(dirname "$(readlink -f "$0")")"/gmx_common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename "$0") [options] <filename>"
	e_info
	e_info "Edit an existing git-memex database file."
	e_info "The file's changed content will be automatically be expanded, and the file name updated based on the expanded content."
	e_info
	e_info "Options:"
	e_info "-r    Don't review expanded content before committing."
	e_info "-h    Display this message"
	e_info "-v    Display script version"
}

### PARSE COMMAND-LINE ARGS ###
review_changes=1

while getopts ":rhv" opt
do
	case $opt in
		r)	review_changes=
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

if [ $# -ne 1 ]; then
	usage
	e_error "Exactly one file name is required."
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
rel_filename=${1#"${GMX_DIR}/"}
filename="${GMX_DIR}/${rel_filename}"

check_file_exists "${filename}" || exit 1
${TEXT_EDITOR} "${filename}"

expand_file_content "${filename}"

if [ -z "$(rungit status -s "${filename}")" ]; then
	e_arrow "Nothing changed."
	exit 0
fi

if [ -n "${review_changes}" ]; then
	${TEXT_EDITOR} "${filename}"
fi

new_rel_filename=$(compute_filename "${rel_filename}")
containing_dir=$(dirname "${rel_filename}")
if [[ -n "${containing_dir}" && "${containing_dir}" != "." ]]; then
	new_rel_filename="${containing_dir}/${new_rel_filename}"
fi
new_filename="${GMX_DIR}/${new_rel_filename}"

extended_commit_msg=
output_old_filename=
if [[ "${new_filename}" != "${filename}" ]]; then
	e_debug "Renaming \"${rel_filename}\" → \"${new_rel_filename}\""
	cp "${filename}" "${new_filename}"
	rungit rm --quiet --force "${filename}"
	extended_commit_msg="\n\nOld file name: ${rel_filename}"
	output_old_filename=" (was ${rel_filename})"

	filename=${new_filename}
	rel_filename=${new_rel_filename}
fi

rungit add "${filename}"
rungit commit --quiet -m "Changed file: ${rel_filename}$(echo -e "${extended_commit_msg}")"

e_success "Updated file: ${rel_filename}${output_old_filename}"
