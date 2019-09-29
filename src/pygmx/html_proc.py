# This file is originally from Unmind, and adapted for use in git-memex.

import logging

from bs4 import BeautifulSoup

log = logging.getLogger(__name__)


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
