#!/usr/bin/env python3
"""packaging/discord_release.py TAG [NOTES]: posts a release to the Discord server's #releases
channel. DISCORD_RELEASES_WEBHOOK is the channel's webhook URL (a repository secret; the release
workflow calls this after `gh release create`). NOTES defaults to docs/releases/TAG.md: its heading
is the title, its "What's new" list the post, with the download, the requirements and a link to
the full notes. DRY_RUN=1 prints the message instead of sending it."""
import json
import os
import pathlib
import re
import sys
import urllib.request

REPO = 'bloodborne-native/bloodborne-mac'
ICON = 'https://raw.githubusercontent.com/bloodborne-native/bloodborne-launcher/main/src-tauri/icons/128x128%402x.png'
COLOR = 0x8B1A1A


def unwrap(lines):
    """The notes are wrapped at 100 columns; Discord would keep those breaks. Joins each list item
    and paragraph into one line."""
    out = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            out.append('')
        elif out and out[-1] and not re.match(r'([-*] |\d+\. |#)', stripped):
            out[-1] += ' ' + stripped
        else:
            out.append(stripped)
    return '\n'.join(out).strip()


def section(text, title):
    """The lines under a '## title' heading (or, for the summary, between the heading and the
    first '## ')."""
    lines = text.splitlines()
    if title is None:
        body = []
        for line in lines[1:]:
            if line.startswith('## '):
                break
            body.append(line)
        return body
    for i, line in enumerate(lines):
        if line.strip() == f'## {title}':
            body = []
            for rest in lines[i + 1:]:
                if rest.startswith('## '):
                    break
                body.append(rest)
            return body
    return []


def message(tag, notes):
    text = notes.read_text()
    heading = text.splitlines()[0].lstrip('# ').strip()
    summary = unwrap(section(text, None))
    summary = re.sub(r"^What's new:\s*", '', summary)
    if len(summary) > 3800:
        summary = summary[:3800].rsplit('\n', 1)[0] + '\n…'
    release = f'https://github.com/{REPO}/releases/tag/{tag}'
    dmg = os.path.basename(os.environ.get('PACKAGE') or f'bloodborne_mac-{tag}-arm64.dmg')
    fields = [
        {'name': 'Download', 'value': f'[{dmg}](https://github.com/{REPO}/releases/download/{tag}/{dmg})',
         'inline': False},
        {'name': 'Requirements', 'value': 'A Mac with Apple Silicon (M1 or newer), macOS 13 or newer. '
         'Your own Bloodborne dump with update 1.09.', 'inline': False},
    ]
    known = unwrap(section(text, 'Known issues'))
    if known:
        fields.append({'name': 'Known issues', 'value': known[:1024], 'inline': False})
    fields.append({'name': 'Full notes', 'value': f'[{tag} on GitHub]({release})', 'inline': False})
    return {
        'username': 'bloodborne-native',
        'avatar_url': ICON,
        'embeds': [{
            'title': heading,
            'url': release,
            'color': COLOR,
            'description': summary,
            'fields': fields,
            'thumbnail': {'url': ICON},
            'footer': {'text': 'Update: replace Bloodborne.app; saves and settings stay.'},
        }],
    }


def main():
    tag = sys.argv[1]
    notes = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else f'docs/releases/{tag}.md')
    body = message(tag, notes)
    if os.environ.get('DRY_RUN') == '1':
        print(json.dumps(body, indent=1, ensure_ascii=False))
        return
    url = os.environ.get('DISCORD_RELEASES_WEBHOOK')
    if not url:
        print('DISCORD_RELEASES_WEBHOOK is not set: not posted')
        return
    request = urllib.request.Request(url + '?wait=true', data=json.dumps(body).encode(), method='POST',
                                     headers={'Content-Type': 'application/json',
                                              'User-Agent': 'bloodborne-native release'})
    with urllib.request.urlopen(request) as reply:
        print(f'Posted to Discord ({reply.status})')


if __name__ == '__main__':
    main()
