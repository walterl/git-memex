#!/usr/bin/env bash
### BOOTSTRAP ###
set -e
source $(dirname $(readlink -f $0))/gmx_common.sh
### /BOOTSTRAP ###

usage() {
	e_info "Usage: $(basename $0) [options] <filename>"
	e_info
	e_info "Preview first lines of specified file."
	e_info
	e_info "Options:"
	e_info "-h    Display this message"
	e_info "-v    Display script version"
}

### PARSE COMMAND-LINE ARGS ###
while getopts ":hv" opt
do
	case $opt in
		h)	usage
			exit 0
			;;
		v)	e_info "git-memex version ${GMX_VERSION} -- $(basename $0)"
			exit 0
			;;
		*)	usage
			e_error "Option does not exist: $OPTARG"
			exit 1
			;;
	esac
done
shift $(($OPTIND-1))

if [ $# -gt 0 ]; then
	filename=$1
fi
### /PARSE COMMAND-LINE ARGS ###

### MAIN ###
mime_type=$(file -b --mime-type "$filename")
if [[ $mime_type =~ ^text/ ]]; then
	sed 30q "$filename" | hilight -
else
	echo "[Binary content]"
fi
