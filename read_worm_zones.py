import xml.etree.ElementTree as ET
tree = ET.parse('assets/maps/ChickenGangMap.tmx')
root = tree.getroot()

for og in root.findall('objectgroup'):
    name = og.get('name')
    if name and 'worm' in name.lower():
        print(f"Found objectgroup: {name}")
        for obj in og.findall('object'):
            print(f"Object: id={obj.get('id')} x={obj.get('x')} y={obj.get('y')} width={obj.get('width')} height={obj.get('height')}")
