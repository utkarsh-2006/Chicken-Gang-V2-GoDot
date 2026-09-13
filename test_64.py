from PIL import Image
img = Image.open('character reference/!$farmer_plowing_32x32.png')
for r in range(4):
    for c in range(3):
        box = (c * 64, r * 64, (c + 1) * 64, (r + 1) * 64)
        bbox = img.crop(box).getbbox()
        if bbox: print(f'Row {r}, Col {c}: bbox {bbox} (w: {bbox[2]-bbox[0]}, h: {bbox[3]-bbox[1]})')
