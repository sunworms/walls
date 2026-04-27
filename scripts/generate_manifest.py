import os
import json

# File extensions to include
IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp', '.gif'}

# Folders to skip
SKIP_FOLDERS = {'docs', 'scripts', '.github', '.git'}

manifest = {}

for folder in sorted(os.listdir('.')):
    if folder in SKIP_FOLDERS or folder.startswith('.'):
        continue
    if not os.path.isdir(folder):
        continue

    images = []
    for file in sorted(os.listdir(folder)):
        ext = os.path.splitext(file)[1].lower()
        if ext in IMAGE_EXTENSIONS:
            images.append(file)

    if images:
        manifest[folder] = images

print(json.dumps(manifest, indent=2))
