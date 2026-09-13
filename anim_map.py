import re

with open('assets/hunter_frames.tres', 'r') as f:
    content = f.read()

anim_blocks = re.findall(r'"name": &"(.*?)".*?"frames": \[(.*?)\]', content, re.DOTALL)
for name, frames in anim_blocks:
    if "walk_" in name or "idle_" in name:
        textures = re.findall(r'"texture": SubResource\("(.*?)"\)', frames)
        print(f"Animation: {name}, Textures: {textures}")
