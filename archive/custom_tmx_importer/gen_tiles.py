import os
from PIL import Image, ImageDraw

os.makedirs('assets', exist_ok=True)
img = Image.new('RGB', (128, 64), (122, 179, 77)) # Grass
draw = ImageDraw.Draw(img)
draw.rectangle([32, 0, 63, 31], fill=(164, 124, 72)) # Dirt
draw.rectangle([64, 0, 95, 31], fill=(65, 166, 246)) # Water
draw.rectangle([96, 0, 127, 31], fill=(34, 139, 34)) # Bush
draw.rectangle([0, 32, 31, 63], fill=(255, 215, 0)) # Corn
draw.rectangle([32, 32, 63, 63], fill=(139, 69, 19)) # Wood
draw.rectangle([64, 32, 95, 63], fill=(128, 128, 128)) # Stone
img.save('assets/tiles.png')
print("Generated tiles.png")
