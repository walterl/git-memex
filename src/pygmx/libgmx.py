# The code in this file is originally from Unmind, and adapted for use in
# git-memex.

import logging
import re
from urllib.parse import unquote, urlparse

from bs4 import BeautifulSoup
import requests


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

log = logging.getLogger(__name__)


### [networking]
def fetch_url(url):
    """Return contents from URL."""
    try:
        response = requests.get(url)
    except Exception as exc:
        log.debug('Failed to fetch title for URL %r:', exc, exc_info=True)
        return None

    return response.text


### [html processing]
def get_title(html):
    if not html:
        return None

    if isinstance(html, BeautifulSoup):
        soup = html
    else:
        try:
            soup = BeautifulSoup(html, 'lxml')
        except Exception as exc:
            log.debug(
                'Failed to parse HTML response from URL %r:',
                exc, exc_info=True
            )
            return None

    title = soup.find('title')
    if title:
        return title.text.strip()

    for heading in ('h1', 'h2', 'h3'):
        title = soup.find(heading)
        if title:
            return title.text.strip()

    return None


### [markdown processing]
def line_url_is_link(line, start, end):
    """Tests if the URL in `line` (from index `start` to `end`) is already a
    Markdown link. Defaults to `False`.
    """
    try:
        return (line[start - 1], line[end]) == ('(', ')') and \
                line[start - 2] == ']' and '[' in line[:start - 2]
    except IndexError:
        return False


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
            if line_url_is_link(line, start, end):
                continue
            url = match.group()
            before, after = line[:match.start()], line[match.end():]
            line = '{}{}{}'.format(before, make_link(url), after)

        lines.append(finalize_line(line))
    return '\n'.join(lines)


def strip(content):
    return content.strip() + '\n'


preprocessors = [strip, urls_to_markdown_links]


def preprocess(content):
    """Run `content` through all Markdown pre-processors."""
    for proc in preprocessors:
        content = proc(content)
    return content


def url_as_title(url):
    """Tries to parse `url` in order to make a nicer looking representation of
    it, as a title. Returns `url` if it cannot be parsed as a URL.
    """
    try:
        parsed = urlparse(url)
        title = unquote(
            '{}{}{}'.format(parsed.netloc, parsed.path, parsed.query)
        )

        if title.endswith('/') and not parsed.query:
            title = title.rstrip('/')
    except ValueError:
        # assume url parsing failed
        title = url
    return title


def make_link(url):
    """Creates a Markdown link from the given URL.

    The page's title is looked up and used as the link text. If that
    fails, the link itself is used.
    """
    title = get_title(fetch_url(url)) or url_as_title(url)
    return '[{}]({})'.format(title, url)
