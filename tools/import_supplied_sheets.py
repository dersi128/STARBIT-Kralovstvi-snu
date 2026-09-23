from pathlib import Path
from PIL import Image
import numpy as np
from scipy import ndimage as ndi
import json,shutil,re
root=Path(__file__).resolve().parents[1];upload=root.parent/'upload'
base=root/'assets/supplied';pieces=base/'pieces';frames=base/'stinko_frames';scenes=root/'scenes/supplied'
for p in [base,pieces,frames,scenes]:p.mkdir(parents=True,exist_ok=True)
files={'crate':'Bedna.png','stinko':'Stinko – animovaný sprite pro Godot(1).png','terrain':'Ashhetty zeme.png','water':'Vodopady.png','props':'Asheety.png','falls':'Vodopady asheety.png'}
images={}
for key,name in files.items():
 source=upload/name if (upload/name).exists() else base/(key+'.png')
 if source.resolve()!=(base/(key+'.png')).resolve():shutil.copyfile(source,base/(key+'.png'))
 images[key]=Image.open(source).convert('RGBA')
# Isolate a supplied piece; only discard tiny disconnected cutout debris.
def cut(im,rect,name):
 c=im.crop(rect);a=np.array(c);labels,n=ndi.label(a[:,:,3]>32);sizes=np.bincount(labels.ravel());sizes[0]=0
 keep=np.zeros_like(sizes,dtype=bool)
 keep[sizes.argmax()]=True
 # Pebbles and mist intentionally contain several disconnected parts.
 if name in ['IslandPebbles','IslandTall','FallsMist']:
  keep=(sizes>=max(80,sizes.max()*.03));keep[0]=False
 if name=='LanternHook':
  # This piece contains one post and a hanging lamp, not the crate below it.
  a[228:,:105,3]=0
  labels,n=ndi.label(a[:,:,3]>32);sizes=np.bincount(labels.ravel());sizes[0]=0
  keep=sizes>=max(100,sizes.max()*.15);keep[0]=False
 mask=ndi.binary_dilation(keep[labels],iterations=3)
 a[:,:,3]=np.where(mask,a[:,:,3],0)
 out=Image.fromarray(a);bb=out.getbbox()
 return out.crop(bb) if bb else out
# Each frame has a stable torso pivot and foot baseline. The tail stays to the left.
for i in range(16):
 if i in [3,10]:continue
 x,y=i%4,i//4;rect=(round(x*313.5),round(y*313.5),round((x+1)*313.5),round((y+1)*313.5))
 raw=images['stinko'].crop(rect);a=np.array(raw);l,n=ndi.label(a[:,:,3]>100);sizes=np.bincount(l.ravel());sizes[0]=0
 main=l==sizes.argmax();ys,xs=np.where(main)
 # Keep the adjacent soft outline, but no cutout speckles / neighboring pose.
 support=ndi.binary_dilation(main,iterations=7);a[:,:,3]=np.where(support,a[:,:,3],0)
 # Idle wink/defeat stars are separate readable effects within their own cell.
 if i==13:
  support[:44,45:285]=True;a[:,:,3]=np.where(support,np.array(raw)[:,:,3],0)
 c=Image.fromarray(a);canvas=Image.new('RGBA',(400,360))
 # Heads/torso are centered around source X 202; align every foot at Y 348.
 canvas.paste(c,(-2,348-int(ys.max())-1));canvas.save(frames/f'{i:02d}.png')
animations={'idle':([0,0,0,0,0,0,1,0,2,0],4,True),'walk':([4,5,6,7],9,True),'attack':([8,9,11],8,False),'warn':([8,9],3,False),'charge':([9,11,4,6],10,True),'rest':([13],1,True),'hit':([12],8,False),'defeat':([13,14,15],8,False)}
s='[gd_resource type="SpriteFrames" load_steps=15 format=3]\n\n'
for i in [v for v in range(16) if v not in [3,10]]:s+=f'[ext_resource type="Texture2D" path="res://assets/supplied/stinko_frames/{i:02d}.png" id="F{i}"]\n'
s+='\n[resource]\nanimations = [\n'+',\n'.join('{"name": &"'+name+'", "speed": '+str(speed)+', "loop": '+str(loop).lower()+', "frames": ['+', '.join('{"duration": 1.0, "texture": ExtResource("F'+str(i)+'")}' for i in ids)+']}' for name,(ids,speed,loop) in animations.items())+'\n]\n'
(base/'stinko.tres').write_text(s)
# Coordinates select complete standalone pieces, never entire atlases.
specs=[]
def add(sheet,kind,entries):
 for name,rect,*extra in entries:specs.append({'name':name,'sheet':sheet,'kind':kind,'rect':rect,'extra':extra})
add('terrain','platform',[
('GrassLeft',(22,22,200,199)),('GrassMiddle',(206,38,473,200)),('GrassMiddleB',(480,36,701,200)),('GrassRight',(703,26,970,223)),
('StoneGrassLeft',(23,205,198,415)),('StoneGrassMiddle',(207,210,475,415)),('StoneGrassMiddleB',(481,214,701,414)),('StoneGrassRight',(701,211,967,414)),
('IslandTiny',(988,74,1090,187)),('IslandRound',(1102,39,1263,205)),('IslandVines',(1263,40,1426,222)),('IslandStar',(990,211,1248,429)),('IslandStone',(1248,216,1430,395)),
('IslandWide',(25,430,327,592)),('IslandPoint',(342,431,590,606)),('IslandLow',(596,449,790,568)),('IslandSmall',(790,435,956,586)),
('StarBlock',(965,432,1103,596)),('StarBlockWide',(1105,436,1414,591)),
('SlopeDown',(30,582,371,761),[(.05,.19),(.26,.23),(.92,.86)],.5),('SlopeUp',(367,639,589,760),[(.04,.88),(.93,.18)],.5),
('CliffLeft',(590,602,832,824)),('CliffRight',(838,594,1045,827)),('CliffVines',(1046,627,1204,821)),('CliffEnd',(1235,600,1430,818)),
('BridgeLeft',(35,789,214,972)),('BridgeMiddle',(266,789,494,923)),('BridgeRight',(511,790,726,971)),('BridgeSmall',(742,836,911,971)),
('IslandPebbles',(940,849,1059,1010)),('IslandTall',(1164,820,1340,1044))])
add('props','decor',[
('SignArrow',(18,36,223,307)),('SignDouble',(220,9,404,322)),('Banner',(377,5,591,324)),('FlagRope',(597,5,910,329)),('BannerStar',(910,7,1041,335)),
('Fence',(1041,70,1440,221)),('RopeFence',(1070,220,1443,341)),('Bush',(19,323,252,485)),('BushFlowers',(249,327,493,492)),('LeavesWide',(488,345,680,483)),('LeavesSmall',(681,343,805,469)),('LeavesTall',(802,339,958,483)),
('VinesShort',(943,334,1173,566)),('VinesLong',(1178,328,1447,640)),
('StoneColumn',(323,483,472,704)),('BrokenColumn',(463,534,613,703)),('Ruins',(607,482,825,703)),('StoneSlab',(828,507,986,704)),('FallenRocks',(990,548,1240,704)),
('LanternPost',(1065,708,1227,915)),('LanternHook',(1239,672,1444,909)),('MushroomRed',(1108,987,1218,1078)),('MushroomSmall',(1208,1007,1297,1082)),('MushroomBlue',(1294,1009,1373,1085)),('Barrel',(1349,912,1448,1031))])
add('props','platform',[
('CloudWide',(19,710,330,869)),('CloudLong',(310,702,598,812)),('CloudSmall',(320,815,455,896)),('CloudPair',(780,710,1075,881))])
add('water','water',[
('WaterfallWide',(16,216,309,592)),('WaterfallMedium',(312,214,497,595)),('WaterfallSlim',(506,217,641,594)),('WaterfallThin',(646,214,754,594)),
('SplashWide',(858,226,1086,407)),('SplashSmall',(1090,257,1260,406)),('Foam',(866,518,1025,608)),
('RiverSurface',(17,600,471,709)),('RiverLeft',(6,707,286,1022)),('RiverMiddle',(294,735,651,1027)),('RiverRight',(656,705,968,1025))])
add('falls','water',[
('FallsLongThin',(14,280,146,823)),('FallsLongA',(154,280,250,823)),('FallsLongWide',(252,280,444,831)),('FallsLongB',(446,280,598,826)),('FallsLongLarge',(591,280,791,827)),
('FallsBodyA',(796,283,913,659)),('FallsBodyB',(923,283,1059,659)),('FallsBodyC',(1063,283,1153,659)),('FallsMist',(1100,658,1447,835))])
add('water','platform',[
('WaterIslandLeft',(0,0,302,219)),('WaterIslandWide',(310,17,565,215)),('WaterIslandRight',(565,21,805,217)),('WaterIslandSlim',(808,5,1008,222))])
add('falls','platform',[
('FallsIsland',(17,21,167,249)),('FallsTwinIsland',(171,19,548,280)),('FallsWideIsland',(552,18,855,285)),('FallsMossIsland',(1036,25,1226,293)),('FallsStoneIsland',(1231,47,1448,326)),
('FallsRock',(18,853,177,1067)),('FallsStarRock',(381,851,573,1066)),('FallsSteps',(954,850,1151,1064))])
manifest=[]
for spec in specs:
 name=spec['name'];im=cut(images[spec['sheet']],spec['rect'],name);im.save(pieces/(name+'.png'));w,h=im.size
 kind=spec['kind'];texture=f'res://assets/supplied/pieces/{name}.png'
 if kind=='platform':
  width=min(360,max(90,w*.85));height=h*width/w
  top=.20
  if name.startswith('Bridge'):top=.19
  if name.startswith('Cloud'):top=.36
  if name in ['StarBlock','StarBlockWide']:top=.24
  if name.startswith('Falls') or name.startswith('WaterIsland'):top=.20
  points=[(.12,top),(.88,top)]
  if name.startswith('GrassMiddle') or name.startswith('StoneGrassMiddle'):points=[(0,top),(1,top)]
  if spec['extra']:points,top=spec['extra']
  poly=', '.join(str(v) for xy in points for v in xy)
  text=f'''[gd_scene load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/sheet_platform.gd" id="script"]
[ext_resource type="Texture2D" path="{texture}" id="texture"]
[node name="{name}" type="AnimatableBody2D"]
script=ExtResource("script")
texture=ExtResource("texture")
width={width}
height={height}
anchor_y={top}
surface=PackedVector2Array({poly})
[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="."]
one_way_collision=true
'''
 else:
  scale=min(1.0,(400 if kind=='water' else 135)/h)
  effect='[ext_resource type="Script" path="res://scripts/sheet_water.gd" id="effect"]\n' if kind=='water' else ''
  text=f'''[gd_scene load_steps={3 if effect else 2} format=3]
[ext_resource type="Texture2D" path="{texture}" id="texture"]
{effect}[node name="{name}" type="Sprite2D"]
texture=ExtResource("texture")
centered=false
scale=Vector2({scale},{scale})
offset=Vector2({-w/2},{0 if kind=='water' else -h})
'''
  if effect:text+='script=ExtResource("effect")\nz_index=-2\n'
 (scenes/(name+'.tscn')).write_text(text)
 manifest.append({'scene':name,'source':spec['sheet']+'.png','rect':spec['rect'],'kind':kind,'size':[w,h]})
(base/'pieces.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
# New Stinko begins at level 7. Earlier patrols keep equivalent existing enemies.
f=root/'scenes/Enemy_stinko.tscn';s=f.read_text().replace('res://assets/animations/stinko.tres','res://assets/supplied/stinko.tres');f.write_text(s)
for n in range(1,7):
 f=root/f'levels/Level_{n:02d}.tscn';s=f.read_text().replace('instance=ExtResource("stinko")','instance=ExtResource("rock_enemy")');f.write_text(s)
f=root/'tools/build_dream_levels.py';s=f.read_text().replace("kinds=['rock_enemy'] if n<4 else (['rock_enemy','stinko'] if n<6 else ['cloud_enemy','rock_enemy','stinko'])","kinds=['rock_enemy'] if n<6 else (['cloud_enemy','rock_enemy'] if n==6 else ['cloud_enemy','rock_enemy','stinko'])");f.write_text(s)
f=root/'design/routes.json';data=json.loads(f.read_text())
for item in data:
 if item['n']<7:
  for e in item.get('enemies',[]):
   if e.get('kind')=='stinko':e['kind']='rock_enemy'
f.write_text(json.dumps(data,ensure_ascii=False,indent=2))
# Preserve all crate physics; use the delivered sprite.
f=root/'scenes/worldkit/PushCrate.tscn';s=f.read_text().replace('res://assets/worldkit/Crate.tres','res://assets/supplied/crate.png').replace('Vector2(0.506667,0.580153)',f'Vector2({76/142},{76/110})');f.write_text(s)
f=root/'scenes/worldkit/Crate.tscn';s=f.read_text().replace('res://assets/worldkit/Crate.tres','res://assets/supplied/crate.png').replace('Vector2(0.5333333333333333, 0.5333333333333333)',f'Vector2({76/142}, {76/110})').replace('position = Vector2(0, 26.93333333333333)','position = Vector2(0, 38)');f.write_text(s)
# Existing island waterfalls use the new supplied narrow waterfall, same geometry.
f=root/'scripts/water_feature.gd';s=f.read_text().replace('preload("res://assets/worldkit/Waterfall.tres")','preload("res://assets/supplied/pieces/FallsLongThin.png")');f.write_text(s)
print('Prepared',len(manifest),'pieces and 14 clean aligned Stinko frames.')
