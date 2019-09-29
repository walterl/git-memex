#!/usr/bin/env python3

import sys

from markdown_proc import preprocess as md_preproc


def expand_file_contents(contents):
    return md_preproc(contents)


def main():
    if len(sys.argv) != 2:
        print('Usage: {script} <filename>'.format(script=sys.argv[0]))
        sys.exit(1)

    filename = sys.argv[1]
    expanded_content = expand_file_contents(open(filename).read())
    if expanded_content:
        with open(filename, 'w') as out_file:
            out_file.write(expanded_content)


if __name__ == "__main__":
    main()
