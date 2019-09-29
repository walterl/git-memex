#!/usr/bin/env python3

import re
import sys

from unmind.data.core import determine_cell_title


def filename_from_contents(contents):
    filename = determine_cell_title(contents)
    filename.replace('/', '-')
    filename = re.sub(r'[\#\!]', '', filename)
    filename = re.sub(r'\s+', ' ', filename)
    return f'{filename}.md'


def main():
    if len(sys.argv) != 2:
        print('Usage: {script} <filename>'.format(script=sys.argv[0]))
        sys.exit(1)

    filename = sys.argv[1]

    print(filename_from_contents(open(filename).read()))


if __name__ == "__main__":
    main()
