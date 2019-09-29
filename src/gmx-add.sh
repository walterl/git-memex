#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $0)/gmx-common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename $0) [options] [--]"
	e_info
	e_info "Add a new file to your git-memex database."
	e_info
	e_info "Options:"
	e_info "-d <dir>   Directory in which to create the new file."
	e_info "-r         Review expanded content before committing."
	e_info "-h         Display this message"
	e_info "-v         Display script version"
}

### PARSE COMMAND-LINE ARGS ###
output_dir=
review_changes=

while getopts ":hvrd:" opt
do
  case $opt in
	d)
		output_dir=$OPTARG
		;;
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
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
if ! check_gmx_dir_initialized; then
	e_error "git-memex not initialized. Run gmx-init first."
	exit 1
fi

if [ -n "${output_dir}" ]; then
	e_debug "Creating output directory: ${GMX_DIR}/${output_dir}"
	mkdir -p "${GMX_DIR}/${output_dir}" || true
fi

tmp_file=$(make_temp_file ".md")
e_debug "Temp add file: ${tmp_file}"

${TEXT_EDITOR} "${tmp_file}"
if [[ $(wc -c "${tmp_file}" | cut -d' ' -f 1) == "0" ]]; then
	e_error "Nothing to add. Aborting."
	exit 1
fi

expand_file_content "${tmp_file}"

if [ -n "${review_changes}" ]; then
	${TEXT_EDITOR} "${tmp_file}"
fi

filename=$(compute_filename "${tmp_file}")
if [ -n "${output_dir}" ]; then
	filename="${output_dir}/${filename}"
fi
filename=$(get_unique_filename "${filename}" "${output_dir}")

e_debug "Adding item: ${filename}"

[ -z "${filename}" ] && e_error "Unable to determine file name for new item. Aborting." && exit 1

cp "${tmp_file}" "${GMX_DIR}/${filename}"
rm "${tmp_file}"
rungit add "${GMX_DIR}/${filename}"
rungit commit --quiet -m "Added file: ${filename}"

e_success "New file: ${filename}"
