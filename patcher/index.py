#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import re
import requests


def get_page():
    return BeautifulSoup(
        requests.get('https://www.teamspeak.com/en/downloads/').text,
        'html.parser',
    )


def filter_file(tag):
    # We are searching for div.file
    if not tag.has_attr('class') or 'file' not in tag['class']:
        return False

    # We only care for the 64-bit server version
    if 'Server 64-bit' not in tag.find('h3').text:
        return False

    # We only care for the linux version
    if 'linux_amd64' not in tag.find('a')['href']:
        return False

    return True


def latest_version():
    page = get_page()
    fd = page.body.find(filter_file)

    version = fd.find('span', 'version').text.strip()
    checksum = fd.find('pre', 'checksum').text.split(' ')[1]

    return (version, checksum)


def main():
    (version, checksum) = latest_version()

    lines = []

    with open('Dockerfile', 'r') as f:
        for line in f:
            lines.append(substitute(line, {
                'TEAMSPEAK_VERSION': version,
                'TEAMSPEAK_SHA256': checksum,
            }).strip('\n'))

    lines.append('')

    with open('Dockerfile', 'w') as f:
        f.write('\n'.join(lines))


def substitute(line, attrs):
    for k, v in attrs.items():
        if k not in line:
            continue
        line = re.sub(
            r'({})=[^ ]+'.format(k),
            r'\1={}'.format(v),
            line
        )
    return line


if __name__ == '__main__':
    main()
