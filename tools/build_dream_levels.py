from pathlib import Path
import json,random
root=Path(__file__).resolve().parents[1]
(root/'design').mkdir(exist_ok=True)
titles=['Lesní probuzení','Mezi kořeny','Světélka vesničky','Nad střechami','Brúčounova svatyně','První ostrovy','Vodopády v oblacích','Hrad na dosah','Královské zahrady','Nebeské nádvoří']
themes=['forest','forest','village','village','guardian','distant_castle','distant_castle','near_castle','near_castle','castle_court']
profiles=[
[550,550,480,400,400,480,570,650,650,560,470,380,300,300,390,480,550,550,460,380,460,550],
[550,470,390,470,570,670,770,870,870,780,690,600,510,420,330,240,150,150,240,330,420,510,550],
[550,550,470,390,310,390,480,570,660,660,570,480,390,300,210,210,300,390,480,550,550,470,550],
[550,460,370,280,190,100,100,190,280,370,460,550,640,730,730,640,550,460,370,280,370,460,550],
[550,470,390,390,480,570,660,660,570,480,390,300,300,390,480,550,550,550],
[550,450,350,250,150,50,-50,-50,50,150,250,250,150,50,-50,-150,-250,-350,-350,-250,-150,-50,50],
[550,450,350,250,250,350,450,550,650,650,550,450,350,250,150,50,-50,-150,-250,-250,-150,-50,50],
[550,450,350,250,150,50,-50,-150,-250,-350,-350,-250,-150,-50,50,50,-50,-150,-250,-350,-450,-550,-550],
[550,450,350,250,150,150,250,350,450,550,650,650,550,450,350,250,150,50,-50,-150,-250,-350,-450,-450],
[550,450,350,250,150,50,-50,-150,-150,-50,50,150,150,50,-50,-150,-250,-350,-450,-450,-450]]
all_data=[]
for n,original_ys in enumerate(profiles,1):
 ys=list(original_ys)
 # Additional distinct terrain chapters; preserve the opening and final elevation.
 patterns={2:[80,80,-80,-80],3:[-70,-70,70,70],4:[-100,-100,100,100],5:[80,-80,80,-80],6:[-110,-110,110,110],7:[100,100,-100,-100],8:[-120,-120,120,120],9:[110,110,-110,-110],10:[-125,-125,125,125]}
 if n>1:
  target_count=24+n*2
  while len(ys)<target_count:
   at=len(ys)-2;anchor=ys[at-1];chapter=[]
   for dy in patterns[n]:anchor+=dy;chapter.append(anchor)
   ys[at:at]=chapter
 gap_choices=[(80,100,120),(100,120),(110,140),(130,150),(140,160),(150,175),(160,185),(175,195),(185,210),(195,225)][n-1]
 rng=random.Random(910+n); platforms=[];objects=[];enemies=[];x=0
 def platform(x,y,w,style='ground',name=None):
  p=dict(x=x,y=y,w=w,style=style,name=name or 'Platform_%d'%(len(platforms)+1));platforms.append(p);return p
 def obj(kind,x,y,message=''):objects.append(dict(kind=kind,x=x,y=y,message=message))
 main=[]
 for i,y in enumerate(ys):
  w=720 if i==0 else rng.choice([340,430,510,590] if n<4 else ([320,400,480,560] if n<7 else [280,350,430,510]));style='ground' if n<=5 else ('ground' if n>=8 else 'island')
  p=platform(x,y,w,style);main.append(p)
  if i>0 and i%2==0:obj('crystal',x+w*.48,y-55)
  x+=w+(rng.choice(gap_choices) if i else 100)
 # High branch: steps above a stretch of main path, joins back after a short loop.
 for route_id,start,end,offset in [('high',(8 if n>=6 else 3)+(n%3),(12 if n>=6 else 7)+(n%3),-280),('low',len(main)//2,len(main)//2+4,300)]:
  if end>=len(main)-1:continue
  a,b=main[start],main[end];startx=a['x']+100;endx=b['x']+80
  count=max(11,int((endx-startx)/170))
  for j in range(1,count):
   t=j/count;xx=startx+(endx-startx)*t
   base=a['y']+(b['y']-a['y'])*t
   # Smooth ramp gives <=100px rises. Thin platforms keep branch tunnels open.
   yy=round(base+offset*min(1,j/5,(count-j)/5))
   p=platform(round(xx),yy,185,'island' if n<8 else 'stone','%s_%02d'%(route_id,j));p['thin']=True
   if j%2==0:obj('crystal',xx+90,yy-48)
 # End: wide safe approach, arena on 5 and courtyard on 10.
 last=main[-1];floor=last['y'];endx=last['x']+last['w']
 finish=platform(endx,floor,1700 if n in [5,10] else 850,'ground','Finish');main.append(finish)
 width=finish['x']+finish['w'];goalx=width-220
 if n!=5:obj('star_key',goalx-340,floor-82)
 obj('goal',goalx,floor)
 if n==1:
  obj('mole',330,550,'Ahoj, Bite! Šipkami se rozběhneš. Podrž skok, když chceš vyskočit výš.\n\nNajdi zlatou hvězdu. Rozsvítí bránu na konci stezky. Projdi portálem a pokračuj dál.\n\nPod cestou i nad ní se skrývají diamanty. Prozkoumej odbočky a zase se vrať na hlavní stezku.')
 if n==3:
  a=main[2];obj('mole',a['x']+70,a['y'],'Tady odpočívá rozbitý Fouk. Přijdi blíž a Bit ho opraví. Potom můžeš ve vzduchu stisknout skok ještě jednou.');obj('fouk',a['x']+230,a['y']-25)
 if n==6:
  a=main[0];obj('mole',350,550,'Jsme nad mraky! Tyhle mraky jezdí doleva a doprava. Počkej, až přijedou blíž, a naskoč. Fouk ti pomůže druhým skokem. Míříme ke stejnému hradu, který jsme viděli z vesničky!')
 checkpoints=[]
 if n==5:
  left=endx+280;right=endx+1200
  checkpoints=[(endx+70,floor),(right+240,floor)]
  obj('mole',endx-120,floor,'Dej si pozor! Brúčouna, strážce brány, ovládla temnota. Vyhni se jeho rozběhu. Až se mu nad hlavou zatočí hvězdy, skoč mu na hlavu a pomoz mu.')
 else:
  for i in [int(len(main)*0.34),int(len(main)*0.69)]:a=main[i];checkpoints.append((a['x']+90,a['y']))
 for xx,yy in checkpoints:obj('checkpoint',xx,yy)
 # Each region has a different traversal focus; movement vectors are editable.
 moving_sets={6:[(4,(130,0)),(18,(100,0)),(29,(150,0))],7:[(4,(0,-110)),(17,(0,-130)),(29,(0,-100))],8:[(5,(85,-90)),(18,(110,-100)),(29,(90,-110))],9:[(4,(120,0)),(18,(0,-120)),(30,(95,-90))],10:[(4,(140,0)),(19,(0,-130)),(32,(100,-110))]}
 for idx,travel in moving_sets.get(n,[]):
  a=main[idx];a['style']='cloud';a['travel']=travel;a['period']=8.0+(idx%3)
  for o in objects:
   if o['kind']=='crystal' and a['x']<=o['x']<=a['x']+a['w'] and abs(o['y']-a['y'])<100:o['parent']=a['name'];o['local']=(o['x']-a['x'],o['y']-a['y'])
 if n in [2,3,4]:
  for idx in ({2:[7,8,9],3:[5,6,14,15,23],4:[4,8,12,18,24,28]}[n]):main[idx]['style']='bridge'
 if n==7:obj('mole',350,550,'Tyhle mraky jezdí nahoru a dolů. Počkej na nižší polohu, naskoč a nech se vyvézt. Fouk ti pomůže doskočit na další ostrov.')
 if n==8:obj('mole',350,550,'Tady mraky putují šikmo. Sleduj je chvilku a skoč, až budou blíž. Na pevném ostrůvku si můžeš odpočinout.')
 water=[]
 water_indices={1:[10],2:[6,8,16,22],3:[5,14,23],4:[8,24],5:[7],6:[10,22],7:[6,19,31],8:[10,24],9:[8,21,33],10:[12,26]}
 for j,idx in enumerate(water_indices[n]):
  a=main[idx];b=main[idx+1]
  water.append(dict(kind='pool',x=a['x']-40,y=max(a['y'],b['y'])+155,w=a['w']+b['w']+300,h=110))
  if n in [2,3,6,7,8,9,10]:water.append(dict(kind='waterfall',x=a['x']+a['w']-50,y=a['y']+50,w=100,h=360+(j%2)*120))
 # Increasing enemy count, with safe approach/landing space and checkpoint refuges.
 enemy_count=[0,3,4,5,6,7,9,10,12,14][n-1]
 candidates=[p for p in main[3:-1] if p['w']>=320 and not p.get('travel') and not any(abs(p['x']+90-c[0])<100 for c in checkpoints)]
 for i in range(min(enemy_count,len(candidates))):
  a=candidates[int(i*len(candidates)/enemy_count)]
  kinds=['rock_enemy'] if n<6 else (['cloud_enemy','rock_enemy'] if n==6 else ['cloud_enemy','rock_enemy','stinko'])
  enemies.append(dict(x=a['x']+125,y=a['y'],kind=kinds[i%len(kinds)],patrol=max(30,a['w']-235),speed=60+n*4))
 zones=[]
 for i,a in enumerate(main[:-1]):
  b=main[i+1]
  if b['y']>a['y']+155:zones.append(dict(x=a['x']+a['w']-90,y=a['y']-50))
 # Soft preview only for the deeper optional lower route, not every small step.
 a=main[len(main)//2]
 zones.append(dict(x=a['x']+a['w']-120,y=a['y']-45))
 # Each platform is an editable native node with its own collision.
 resources=['[ext_resource type="Script" path="res://scripts/level.gd" id="level"]','[ext_resource type="Script" path="res://scripts/platform.gd" id="platform"]','[ext_resource type="Script" path="res://scripts/object.gd" id="object"]','[ext_resource type="PackedScene" path="res://scenes/environments/%s.tscn" id="bg"]'%themes[n-1],'[ext_resource type="PackedScene" path="res://scenes/mole.tscn" id="mole"]','[ext_resource type="PackedScene" path="res://scenes/Boss.tscn" id="boss"]']
 for k in ['rock_enemy','cloud_enemy','stinko']:resources.append('[ext_resource type="PackedScene" path="res://scenes/Enemy_%s.tscn" id="%s"]'%(k,k))
 resources.append('[ext_resource type="Script" path="res://scripts/camera_zone.gd" id="camera_zone"]')
 resources.append('[ext_resource type="Script" path="res://scripts/water_feature.gd" id="water"]')
 s=['[gd_scene load_steps=%d format=3]'%(len(resources)+len(platforms)+1)]+resources
 for i,p in enumerate(platforms):s+=['[sub_resource type="RectangleShape2D" id="shape%d"]'%i,'size=Vector2(%s,%s)'%(p['w'],27 if p.get('thin') else 100)]
 s+=['[node name="Level_%02d" type="Node2D"]'%n,'script=ExtResource("level")','number=%d'%n,'title='+json.dumps(titles[n-1],ensure_ascii=False),'width=%s'%width,'spawn=Vector2(140,550)','camera_top=-1800','camera_bottom=2000','fall_limit=%s'%(max(p['y'] for p in platforms)+450),'fouk_at_start='+('true' if n>=4 else 'false'),'[node name="Background" parent="." instance=ExtResource("bg")]']
 for i,p in enumerate(platforms):
  s+=['[node name="%s" type="AnimatableBody2D" parent="."]'%p['name'],'script=ExtResource("platform")','position=Vector2(%s,%s)'%(p['x'],p['y']),'width=%s'%p['w'],'depth=%s'%(75 if p.get('travel') else (42 if p.get('thin') else 115)),'style="%s"'%p['style'],'travel=Vector2(%s,%s)'%tuple(p.get('travel',(0,0))),'period=%s'%p.get('period',4.0),'[node name="CollisionShape2D" type="CollisionShape2D" parent="%s"]'%p['name'],'position=Vector2(%s,%s)'%(p['w']/2,13.5 if p.get('thin') else 50),'shape=SubResource("shape%d")'%i,'one_way_collision=true']
 for i,o in enumerate(objects):
  s+=['[node name="%s_%d" %s parent="%s"%s]'%(o['kind'],i,'' if o['kind']=='mole' else 'type="Node2D"',o.get('parent','.'),' instance=ExtResource("mole")' if o['kind']=='mole' else ''),'position=Vector2(%s,%s)'%tuple(o.get('local',(o['x'],o['y'])))]
  if o['kind']!='mole':s+=['script=ExtResource("object")','kind="%s"'%o['kind']]
  if o['message']:s+=['message='+json.dumps(o['message'],ensure_ascii=False)]
 for i,e in enumerate(enemies):s+=['[node name="Enemy_%d" parent="." instance=ExtResource("%s")]'%(i,e['kind']),'position=Vector2(%s,%s)'%(e['x'],e['y']),'patrol=%s'%e['patrol'],'speed=%s'%e['speed']]
 for i,z in enumerate(zones):s+=['[node name="CameraDescent_%02d" type="Node2D" parent="."]'%i,'script=ExtResource("camera_zone")','position=Vector2(%s,%s)'%(z['x'],z['y'])]
 for i,w in enumerate(water):s+=['[node name="Water_%d" type="Node2D" parent="."]'%i,'script=ExtResource("water")','kind="%s"'%w['kind'],'position=Vector2(%s,%s)'%(w['x'],w['y']),'size=Vector2(%s,%s)'%(w['w'],w['h'])]
 if n==5:s+=['[node name="Boss" parent="." instance=ExtResource("boss")]','position=Vector2(%s,%s)'%(right-100,floor),'left=%s'%left,'right=%s'%right,'hp=3']
 (root/'levels'/('Level_%02d.tscn'%n)).write_text('\n'.join(s)+'\n')
 all_data.append(dict(n=n,title=titles[n-1],theme=themes[n-1],width=width,main=main,platforms=platforms,objects=objects,checkpoints=checkpoints,enemies=enemies,camera_zones=zones,water=water))
(root/'design/routes.json').write_text(json.dumps(all_data,ensure_ascii=False,indent=2))
print([(a['n'],a['width'],len(a['platforms'])) for a in all_data])
