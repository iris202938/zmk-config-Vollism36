from pathlib import Path
import re

path = Path(r'c:\Users\iris2\github\zmk-config-Vollism36\boards\shields\Vollism36\Vollism36.keymap')
text = path.read_text(encoding='utf-8')
lines = text.splitlines()
changed = []

for idx, line in enumerate(lines):
    stripped = line.rstrip('\n')
    leading = re.match(r'^(\s*)', stripped).group(1)
    content = stripped[len(leading):]
    if not content or content.lstrip().startswith('//'):
        continue
    if '//' in content:
        content_part, comment = content.split('//', 1)
        comment = '//' + comment
    else:
        content_part = content
        comment = ''
    cells = [c for c in re.split(r'\s{2,}', content_part.strip()) if c]
    if len(cells) != 6 or not all(c.strip().startswith('&') for c in cells):
        continue
    permuted = [cells[1], cells[2], cells[0], cells[5], cells[3], cells[4]]
    if cells == permuted:
        continue
    # Only apply if the current arrangement appears to be an original row, not an unexpected layout.
    # We assume any 6-cell row in the current file should be permuted once.
    new_line = leading + '   '.join(permuted)
    if comment:
        new_line += ' ' + comment
    lines[idx] = new_line
    changed.append((idx + 1, content_part.strip(), '   '.join(permuted)))

if not changed:
    print('No changes needed.')
else:
    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print('Updated', len(changed), 'lines:')
    for line_no, old, new in changed:
        print(line_no, old, '=>', new)
