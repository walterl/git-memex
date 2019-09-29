# This file is originally from Unmind, and adapted for use in git-memex.

import logging

import requests

log = logging.getLogger(__name__)


def fetch_url(url):
    """Return contents from URL."""
    try:
        response = requests.get(url)
    except Exception as exc:
        log.debug('Failed to fetch title for URL %r:', exc, exc_info=True)
        return None

    return response.text
