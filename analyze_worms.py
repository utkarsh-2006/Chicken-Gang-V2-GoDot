from PIL import Image

def analyze_worm_sheet(img_path):
    try:
        img = Image.open(img_path).convert("RGBA")
        print(f"Image loaded: {img.size}")
        width, height = img.size
        
        frame_w = 30
        frame_h = 34
        rows = 4
        cols = 3
        
        # Analyze average color per row to see if they are different colored worms
        for r in range(rows):
            print(f"\nRow {r}:")
            for c in range(cols):
                box = (c * frame_w, r * frame_h, (c+1) * frame_w, (r+1) * frame_h)
                frame = img.crop(box)
                
                # Calculate average color ignoring transparent pixels
                r_sum = g_sum = b_sum = count = 0
                for x in range(frame_w):
                    for y in range(frame_h):
                        pix = frame.getpixel((x, y))
                        if pix[3] > 0: # not fully transparent
                            r_sum += pix[0]
                            g_sum += pix[1]
                            b_sum += pix[2]
                            count += 1
                            
                if count > 0:
                    avg_color = (r_sum // count, g_sum // count, b_sum // count)
                    print(f"  Frame {c}: average color {avg_color}, non-transparent pixels: {count}")
                else:
                    print(f"  Frame {c}: completely transparent")
    except Exception as e:
        print(f"Error: {e}")

analyze_worm_sheet("assets/worm.png")
