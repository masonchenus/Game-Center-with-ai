#!/usr/bin/env python3
import re
from pathlib import Path

root = Path('/Users/mason/Game Center Project')
file = root / 'src' / 'core' / 'index.html'
text = file.read_text(encoding='utf-8')

games = re.findall(r'data-game="([^"]+)"', text)
init_funcs = re.findall(r'function\s+(init[A-Za-z0-9_]*)', text)
init_set = set(init_funcs)

# helper to camelize
def camelize(name):
    parts = re.split(r'[^A-Za-z0-9]', name)
    return ''.join(p.capitalize() for p in parts if p)

missing = []
for g in sorted(set(games)):
    candidates = [f'init{camelize(g)}', f'init{g.capitalize()}', f'init{g.upper()}', f'init{g}']
    found = any(c in init_set for c in candidates)
    # also check known alternate names in file
    # check if any init function contains the game name lowercased
    if not found:
        found = any(g.lower() in f.lower() for f in init_set)
    if not found:
        missing.append(g)

print('Total games found:', len(set(games)))
print('Total init-like functions found:', len(init_set))
print('\nMissing games (no obvious init found):')
for m in missing:
    print('-', m)
