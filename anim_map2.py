import re

with open('assets/hunter_frames.tres', 'r') as f:
    content = f.read()

# Extract all SubResources of type AtlasTexture
atlas_textures = {}
atlas_blocks = re.findall(r'\[sub_resource type="AtlasTexture" id="(.*?)"\]\n.*?region = Rect2\((.*?)\)', content, re.DOTALL)
for tex_id, region in atlas_blocks:
    atlas_textures[tex_id] = region

# Extract animations
anim_blocks = re.findall(r'{\s*"frames": \[(.*?)\],\s*"loop": (true|false),\s*"name": &"(.*?)",\s*"speed":', content, re.DOTALL)

for frames_str, loop, name in anim_blocks:
    if "attack" not in name:
        textures = re.findall(r'"texture": SubResource\("(.*?)"\)', frames_str)
        regions = [atlas_textures.get(t, "Unknown") for t in textures]
        print(f"Animation: {name}")
        for i, r in enumerate(regions):
            print(f"  Frame {i}: {r}")
