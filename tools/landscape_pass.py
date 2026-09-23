from pathlib import Path
import json,re
root=Path(__file__).resolve().parents[1]
levels=json.loads((root/'design/routes.json').read_text())
for data in levels:
 n=data['n'];path=root/'levels'/f'Level_{n:02d}.tscn';s=path.read_text()
 if 'id="earth"' in s:raise SystemExit('Landscape already applied; use a clean map backup before rerunning.')
 blocks=re.split(r'(?=\[node )',s);blocks=[b for b in blocks if not re.match(r'\[node name="Water_\d+"',b)]
 s=''.join(blocks)
 # Sky levels keep waterfalls attached to islands, without floating rectangular pools.
 if n>=6:
  for i,w in enumerate(data.get('water',[])):
   if w['kind']!='waterfall':continue
   source=min(data['main'],key=lambda p:abs(p['x']+p['w']-50-w['x']))
   y=source['y']+100
   s+=f'\n[node name="IslandFall_{i}" type="Node2D" parent="."]\nscript=ExtResource("water")\nkind="waterfall"\nposition=Vector2({w["x"]},{y})\nsize=Vector2(95,600)\n'
  path.write_text(s);continue
 resources='''[ext_resource type="Script" path="res://scripts/terrain_body.gd" id="earth"]
[ext_resource type="Script" path="res://scripts/footbridge.gd" id="footbridge"]
[ext_resource type="Script" path="res://scripts/river.gd" id="river"]
[ext_resource type="Script" path="res://scripts/bridge_rails.gd" id="rails"]
[ext_resource type="Script" path="res://scripts/cave_back.gd" id="cave"]
[ext_resource type="PackedScene" path="res://scenes/worldkit/PushCrate.tscn" id="push_box"]
[ext_resource type="PackedScene" path="res://scenes/worldkit/SpringPad.tscn" id="spring"]
[ext_resource type="PackedScene" path="res://scenes/worldkit/BushFlowers.tscn" id="flowers"]
[ext_resource type="PackedScene" path="res://scenes/worldkit/Lantern.tscn" id="lantern"]
[ext_resource type="PackedScene" path="res://scenes/worldkit/StoneBlock.tscn" id="stone_obj"]
'''
 s=s.replace('[sub_resource',resources+'[sub_resource',1)
 main=data['main'];low=[p for p in data['platforms'] if p['name'].startswith('low_')]
 cx=min(p['x'] for p in low)-100;cy=min(p['y'] for p in low)-115
 cw=max(p['x']+p['w'] for p in low)-cx+100;ch=max(p['y'] for p in low)-cy+150
 bottom=max(1800,max(p['y'] for p in main)+800)
 # One long river crossing per map, instead of scattered floating puddles.
 crossing=8 if n in [1,3,5] else 10
 crossing_names={main[crossing]['name']}
 if n in [2,4]:crossing_names.add(main[crossing+1]['name'])
 # Existing bridges are consolidated into the purposeful crossing.
 blocks=re.split(r'(?=\[node )',s)
 for i,b in enumerate(blocks):
  for p in main:
   if b.startswith('[node name="'+p['name']+'" '):
    b=re.sub(r'style="[^"]+"','style="'+('bridge' if p['name'] in crossing_names else 'ground')+'"',b)
  if re.match(r'\[node name="high_',b):b=re.sub(r'style="[^"]+"','style="bridge"',b)
  blocks[i]=b
 s=''.join(blocks)
 s+=f'\n[node name="CaveBackdrop" type="Node2D" parent="."]\nscript=ExtResource("cave")\nposition=Vector2({cx},{cy})\nsize=Vector2({cw},{ch})\n'
 for i,p in enumerate(main):
  if p['name'] in crossing_names:continue
  s+=f'\n[node name="Earth_{i}" type="Node2D" parent="."]\nscript=ExtResource("earth")\nposition=Vector2({p["x"]},{p["y"]})\nwidth={p["w"]}\nbottom={bottom}\ncave=Rect2({cx},{cy},{cw},{ch})\n'
 left=main[crossing-1];right=main[crossing+(2 if n in [2,4] else 1)]
 rx=left['x']+left['w']-4;rw=right['x']-rx+4;ry=max(left['y'],right['y'])+190
 s+=f'\n[node name="RiverBetweenBanks" type="Node2D" parent="."]\nscript=ExtResource("river")\nposition=Vector2({rx},{ry})\nwidth={rw}\ndepth={bottom-ry}\n'
 sx=left['x']+left['w']-15
 s+=f'\n[node name="RiverBridgeRails" type="Node2D" parent="."]\nscript=ExtResource("rails")\nposition=Vector2({sx},{left["y"]})\nend_offset=Vector2({right["x"]+15-sx},{right["y"]-left["y"]})\n'
 # Bridge both river banks and selected short ravines; all deck pieces have collision.
 joins=set([crossing-1,crossing])
 if n in [2,4]:joins.add(crossing+1)
 joins.update([1,4,13,18,23])
 for i in sorted(joins):
  if i>=len(main)-1:continue
  a,b=main[i],main[i+1];start=a['x']+a['w']-8
  if b['x']-start<10:continue
  s+=f'\n[node name="BankBridge_{i}" type="AnimatableBody2D" parent="."]\nscript=ExtResource("footbridge")\nposition=Vector2({start},{a["y"]})\nend_offset=Vector2({b["x"]-start+8},{b["y"]-a["y"]})\n'
 # Useful objects on safe, wide banks; springs are optional, never required.
 a=main[2]
 s+=f'\n[node name="PushCrateBank" parent="." instance=ExtResource("push_box")]\nposition=Vector2({a["x"]+a["w"]*0.52},{a["y"]})\n'
 a=main[5]
 s+=f'\n[node name="OptionalSpring" parent="." instance=ExtResource("spring")]\nposition=Vector2({a["x"]+a["w"]*0.7},{a["y"]})\n'
 for i in [0,3,7,12,17,22]:
  if i>=len(main):continue
  a=main[i]
  s+=f'\n[node name="BankFlowers_{i}" parent="." instance=ExtResource("flowers")]\nposition=Vector2({a["x"]+35},{a["y"]+2})\nz_index=-1\nscale=Vector2(0.65,0.65)\n'
 for i in [0,len(low)//2,len(low)-1]:
  a=low[i]
  s+=f'\n[node name="CaveLantern_{i}" parent="." instance=ExtResource("lantern")]\nposition=Vector2({a["x"]+20},{a["y"]})\nscale=Vector2(0.7,0.7)\n'
 # Small optional stone on a late safe bank, outside the patrol lane.
 a=main[-3]
 s+=f'\n[node name="BankStone" parent="." instance=ExtResource("stone_obj")]\nposition=Vector2({a["x"]+45},{a["y"]})\nscale=Vector2(0.55,0.55)\n'
 if n==1:
  s=s.replace('Pod cestou i nad ní se skrývají diamanty. Prozkoumej odbočky a zase se vrať na hlavní stezku.','Přes řeku vede most. Bednu můžeš tlačit chůzí. Pružinu můžeš vyzkoušet, nebo ji přeskočit. Dole se skrývá jeskyně s diamanty; lucerny ti ukážou cestu.')
 count=s.count('[ext_resource')+s.count('[sub_resource')+1
 s=re.sub(r'load_steps=\d+',f'load_steps={count}',s,1);path.write_text(s)
print('Landscape applied: five grounded levels, bank-to-bank bridges, bounded rivers, caves and interactive objects; sky pools removed.')
