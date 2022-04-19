#!/usr/bin/env python3

import logging
import re
import sys

from bs4 import BeautifulSoup
from html2text import HTML2Text
from markdown import Markdown as OrigMarkdown
from markdown.serializers import to_xhtml_string

from libgmx import get_title as get_html_title

log = logging.getLogger(__name__)


class Markdown(OrigMarkdown):

    def __init__(self, *args, **kwargs):
        kwargs['output_format'] = 'xhtml_with_stored_tree'
        self.output_formats['xhtml_with_stored_tree'] = self.store_tree

        super(self.__class__, self).__init__(*args, **kwargs)

    def store_tree(self, root):
        self.tree_root = root
        return to_xhtml_string(root)


def clean_title(s):
    return s.strip(' \t\r\n!@#$%^&*(){{}}[]_+|-=`~;:,<>/')


def title_from_content(content):
    if not content:
        return 'Untitled'

    title = ''
    md = Markdown()
    html = md.convert(content)
    soup = BeautifulSoup(html, 'lxml')

    # Try and find Markdown title in HTML
    if soup is not None:
        title = get_html_title(soup)

    # Use the text from the first paragraph
    if not title and soup is not None:
        paragraph = soup.find('p')
        if paragraph is not None:
            h = HTML2Text()
            h.ignore_links = True
            html = h.handle(str(paragraph))
            lines = [l for l in html.split('\n') if l]
            if lines:
                title = lines[0]

    if not title:
        lines = content.split('\n')
        while lines and not title:
            title = clean_title(lines.pop(0))

    log.debug('Title: {}'.format(title))
    return title


def filename_from_content(content):
    filename = title_from_content(content)
    filename = filename.replace('/', '-').replace('|', '-')
    filename = re.sub(r'[\#\!]', '', filename)
    filename = re.sub(r'\s+', ' ', filename)
    filename = filename.rstrip('.')
    return f'{filename}.md'


def main():
    if len(sys.argv) != 2:
        print('Usage: {script} <filename>'.format(script=sys.argv[0]))
        sys.exit(1)

    filename = sys.argv[1]

    print(filename_from_content(open(filename).read()))


if __name__ == "__main__":
    main()
