# This file is originally from Unmind, and adapted for use in git-memex.

import re
from urllib.parse import unquote, urlparse

from html_proc import get_title
from net import fetch_url


RFC3986_PCT_ENCODED = r'%'
RFC3986_GEN_DELIMS = r':/\?#\[\]@'
# Opening and closing parentheses (`(` and `)`) were removed from
# `RFC3986_SUB_DELIMS` below, since it causes the closing parenthesis in
# Markdown links to be matched as part of the URL.
RFC3986_SUB_DELIMS = r'\!\$\&\'\*\+\,\;\='
RFC3986_UNRESERVED = r'a-zA-Z0-9\-\.\_\~'
RX_WEBURL_STR = r'\b(https?://[\w-][\.\w-]+\b/?([{}{}{}{}]*)?)'.format(
    RFC3986_PCT_ENCODED, RFC3986_GEN_DELIMS, RFC3986_SUB_DELIMS,
    RFC3986_UNRESERVED
)
RX_WEBURL = re.compile(RX_WEBURL_STR)


def strip(content):
    return content.strip() + '\n'


def urls_to_markdown_links(content):
    lines = []
    for line in content.split('\n'):
        finalize_line = lambda l: l
        if line.startswith('> '):
            line = line[2:]
            finalize_line = lambda l: '> {}'.format(l)

        if line.startswith('    '):
            # Skip blockquoted lines
            lines.append(finalize_line(line))
            continue

        for match in reversed(list(RX_WEBURL.finditer(line))):
            start, end = match.span()

            try:
                # Skip URLs that are probably Markdown links already.
                if line[start - 1] == '(' and line[end] == ')' and \
                        line[start - 2] == ']' and '[' in line[:start - 2]:
                    continue
            except IndexError:
                pass

            url = match.group()
            before, after = line[:match.start()], line[match.end():]
            line = '{}{}{}'.format(before, make_link(url), after)

        lines.append(finalize_line(line))
    return '\n'.join(lines)


preprocessors = [strip, urls_to_markdown_links]


def preprocess(content):
    """Run `content` through all Markdown pre-processors."""
    for proc in preprocessors:
        content = proc(content)
    return content


def make_link(url):
    """Creates a Markdown link from the given URL.

    The page's title is looked up and used as the link text. If that
    fails, the link itself is used.
    """
    title = get_title(fetch_url(url))

    if not title:
        parsed = urlparse(url)
        title = unquote(
            '{}{}{}'.format(parsed.netloc, parsed.path, parsed.query)
        )

        if title.endswith('/') and not parsed.query:
            title = title.rstrip('/')

    return '[{}]({})'.format(title, url)
