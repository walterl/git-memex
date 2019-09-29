#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename $0) [options] [--] <filename>"
	e_info
	e_info "Edit an existing git-memex database file."
	e_info "The file's changed content will be automatically be expanded, and the file name updated based on the expanded content."
	e_info
	e_info "Options:"
	e_info "-r    Review expanded content before committing."
	e_info "-h    Display this message"
	e_info "-v    Display script version"
}

### PARSE COMMAND-LINE ARGS ###
review_changes=

while getopts ":hvr" opt
do
  case $opt in
	r)
		review_changes=1
		;;
	h)
		usage
		exit 0
		;;
	v)
		e_info "git-memex version ${GMX_VERSION} -- $(basename $0)"
		exit 0
		;;
	*)
		e_error "Option does not exist: $OPTARG";
		usage
		exit 1
		;;
  esac
done
shift $(($OPTIND-1))

if [ $# -ne 1 ]; then
	usage
	e_error "Exactly one file name is required."
	exit 1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
filename=$1

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
