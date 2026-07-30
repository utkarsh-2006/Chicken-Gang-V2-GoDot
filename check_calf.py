from PIL import Image

def analyze(img_path):
    try:
        img = Image.open(img_path)
        print(f"Dimensions: {img.size[0]} x {img.size[1]}")
    except Exception as e:
        print(f"Error: {e}")

analyze("assets/entities/animals/calf_white_32x32.png")
