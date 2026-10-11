"""Build only the new world-asset prefabs. Never writes campaign level scenes."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = json.loads((ROOT / 'assets/environment/worlds/manifest.json').read_text())
ANCHORS = json.loads((ROOT / 'docs/assets/worlds/socket_anchors.json').read_text())
OUT = ROOT / 'scenes/world_assets'
BIO = ['forest', 'village', 'sky', 'castle', 'garden', 'memory', 'stars', 'heart']

def vec(x, y):
    return f'Vector2({x:.5f}, {y:.5f})'

def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + '\n')

def sprite(a, factor, anchor, parent='.', name='Visual'):
    return (f'\n[node name="{name}" type="Sprite2D" parent="{parent}"]\n'
            'texture = ExtResource("tex")\ncentered = false\n'
            f'position = {vec(-anchor[0]*factor, -anchor[1]*factor)}\n'
            f'scale = {vec(factor, factor)}\n')

for a in MANIFEST['assets']:
    key, name = a['biome'], a['name']
    w, h = a['size']
    title = ''.join(p.title() for p in name.split('_'))
    declarations = f'[ext_resource type="Texture2D" path="res://{a["path"]}" id="tex"]\n'
    script = ''
    props = ''
    node_type = 'Node2D'
    children = ''
    resource = ''
    anchor = a['anchor_bottom']
    factor = min(210 / w, 230 / h) if a['kind'] == 'decor' else min(100/w, 110/h)
    if name in ('platform_long', 'ledge', 'lift_deck', 'crumble_platform'):
        target_width = {'platform_long': 300, 'ledge': 160, 'lift_deck': 210, 'crumble_platform': 225}[name]
        factor = target_width / w
        anchor = a['anchor_top']
        node_type = 'AnimatableBody2D' if name == 'lift_deck' else 'StaticBody2D'
        props += 'collision_layer = 1\ncollision_mask = 0\n'
        if name == 'lift_deck':
            script = 'moving_platform'
            props += 'travel = Vector2(160, 0)\n'
        elif name == 'crumble_platform':
            script = 'crumble_platform'
        resource = f'[sub_resource type="RectangleShape2D" id="shape"]\nsize = {vec(target_width-16*factor, 14)}\n'
        children += '\n[node name="Collision" type="CollisionShape2D" parent="."]\nposition = Vector2(0, 7)\nshape = SubResource("shape")\n'
    elif name == 'lift_header':
        factor = 210 / w
    elif name == 'gate':
        factor = 165 / h
        node_type = 'AnimatableBody2D'
        script = 'moving_platform'
        props += 'collision_layer = 1\ncollision_mask = 0\nmotion_kind = 1\npowered = false\nperiod = 1.0\ntravel = Vector2(0, -190)\n'
        resource = f'[sub_resource type="RectangleShape2D" id="shape"]\nsize = {vec((w-16)*factor, (h-16)*factor)}\n'
        children += f'\n[node name="Collision" type="CollisionShape2D" parent="."]\nposition = {vec(0, -(h-16)*factor/2)}\nshape = SubResource("shape")\n'
    elif name == 'hazard':
        factor = min(140/w, 115/h)
        node_type = 'Area2D'
        script = 'hazard'
        props += 'collision_layer = 0\ncollision_mask = 2\n'
        points = [(x-anchor[0], y-anchor[1]) for x,y in a['collision_hull']]
        polygon = ', '.join(f'{v*factor:.4f}' for xy in points for v in xy)
        children += f'\n[node name="Collision" type="CollisionPolygon2D" parent="."]\npolygon = PackedVector2Array({polygon})\n'
    elif name == 'pressure_plate':
        factor = 85 / w
        node_type = 'Area2D'
        script = 'pressure_plate'
        props += 'collision_layer = 0\ncollision_mask = 6\n'
        resource = '[sub_resource type="RectangleShape2D" id="shape"]\nsize = Vector2(72, 20)\n'
        children += '\n[node name="Collision" type="CollisionShape2D" parent="."]\nposition = Vector2(0, -9)\nshape = SubResource("shape")\n'
    elif name == 'repair_socket' or key == 'story' or (key == 'common' and name == 'gear'):
        # Existing interaction API supports Bit's repair/pickup animation and inventory.
        script_path = 'scripts/world_assets/repair.gd' if name == 'repair_socket' else 'scripts/story_interaction.gd'
        declarations += f'[ext_resource type="Script" path="res://{script_path}" id="behavior"]\n'
        props += 'script = ExtResource("behavior")\npicture = ExtResource("tex")\n'
        if name == 'repair_socket':
            data = ANCHORS[key]
            props += ('action = "repair"\nrequired_item = "repair_gear"\npicture_height = 130.0\nduration = 1.4\n'
                      'caption = "Opravit mechanismus"\nlocked_caption = "Nejdřív najdi součástku"\n'
                      f'repair_socket_uv = {vec(*data["socket_uv"])}\nrepair_gear_width = {data["gear_width"]}\n')
        else:
            item = 'repair_gear' if name == 'gear' else name
            props += f'action = "pickup"\nitem_id = "{item}"\npicture_height = 48.0\ncaption = "Sebrat předmět"\nduration = 0.65\n'
        text = f'[gd_scene load_steps=3 format=3]\n\n{declarations}\n[node name="{title}" type="Node2D"]\n{props}'
        write(OUT / key / (name+'.tscn'), text)
        continue
    if script:
        declarations += f'[ext_resource type="Script" path="res://scripts/world_assets/{script}.gd" id="behavior"]\n'
        props = 'script = ExtResource("behavior")\n' + props
    count = 2 + bool(script) + bool(resource)
    text = f'[gd_scene load_steps={count} format=3]\n\n{declarations}\n{resource}\n[node name="{title}" type="{node_type}"]\n{props}'
    text += sprite(a, factor, anchor) + children
    write(OUT / key / (name+'.tscn'), text)

for biome in BIO:
    header = next(a for a in MANIFEST['assets'] if a['id']==biome+'/lift_header')
    w,h = header['size']; factor = 210/w
    text = f'''[gd_scene load_steps=4 format=3]
[ext_resource type="Script" path="res://scripts/world_assets/lift.gd" id="lift"]
[ext_resource type="PackedScene" path="res://scenes/world_assets/{biome}/lift_deck.tscn" id="deck"]
[ext_resource type="Texture2D" path="res://{header['path']}" id="header"]

[node name="Lift" type="Node2D"]
script = ExtResource("lift")

[node name="RopeLeft" type="Line2D" parent="."]
points = PackedVector2Array(-70, -233, -70, 8)
width = 4.0
default_color = Color(0.55, 0.38, 0.2, 1)
antialiased = true

[node name="RopeRight" type="Line2D" parent="."]
points = PackedVector2Array(70, -233, 70, 8)
width = 4.0
default_color = Color(0.55, 0.38, 0.2, 1)
antialiased = true

[node name="Header" type="Sprite2D" parent="."]
position = Vector2(0, -245)
texture = ExtResource("header")
scale = {vec(factor,factor)}

[node name="Deck" parent="." instance=ExtResource("deck")]
travel = Vector2(0, -180)
period = 4.5
'''
    write(OUT / biome / 'Lift.tscn',text)

write(OUT / 'common/Lever.tscn', '''[gd_scene load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/world_assets/lever.gd" id="script"]
[ext_resource type="Texture2D" path="res://assets/environment/worlds/common/lever_base.png" id="tex"]
[node name="Lever" type="Node2D"]
script = ExtResource("script")
action = "activate"
picture = ExtResource("tex")
picture_height = 95.0
duration = 0.8
caption = "Aktivovat páku"
''')
print(f'Built {len(list(OUT.rglob("*.tscn")))} new asset prefabs; no campaign scenes changed.')
