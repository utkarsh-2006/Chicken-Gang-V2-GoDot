from PIL import Image

def analyze_grid(filepath, frame_w, frame_h):
    img = Image.open(filepath).convert("RGBA")
    w, h = img.size
    cols = w // frame_w
    rows = h // frame_h
    print(f"File: {filepath}, Size: {w}x{h}")
    print(f"Testing Grid: {frame_w}x{frame_h} -> {cols} cols, {rows} rows")
    
    for r in range(rows):
        for c in range(cols):
            box = (c * frame_w, r * frame_h, (c + 1) * frame_w, (r + 1) * frame_h)
            region = img.crop(box)
            bbox = region.getbbox()
            if bbox:
                print(f"Row {r}, Col {c}: Content bbox {bbox} (w: {bbox[2]-bbox[0]}, h: {bbox[3]-bbox[1]})")
            else:
                print(f"Row {r}, Col {c}: EMPTY")

print("--- Walking PNG (assuming 32x64) ---")
analyze_grid('assets/farmer.png', 32, 64)

print("\n--- Plowing PNG (assuming 32x64) ---")
analyze_grid('character reference/!$farmer_plowing_32x32.png', 32, 64)

print("\n--- Plowing PNG (assuming 32x32) ---")
analyze_grid('character reference/!$farmer_plowing_32x32.png', 32, 32)

print('\n--- Plowing PNG (assuming 64x64) ---')
analyze_grid('character reference/!.png', 64, 64)
