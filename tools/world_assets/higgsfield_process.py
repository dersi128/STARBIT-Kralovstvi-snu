import os,json,statistics,zipfile,shutil,hashlib
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np, cv2
CFG=json.loads("{\"atlases\":[{\"index\":0,\"key\":\"forest_mechanics\",\"biome\":\"forest\",\"title\":\"Les a kořeny\",\"levels\":[1,2],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":1,\"key\":\"forest_decor\",\"biome\":\"forest\",\"title\":\"Les a kořeny\",\"levels\":[1,2],\"kind\":\"decor\",\"objects\":[{\"id\":\"root_workshop\"},{\"id\":\"root_arch\"},{\"id\":\"signpost\"},{\"id\":\"fern_cluster\"},{\"id\":\"mushroom_cluster\"},{\"id\":\"boulder\"},{\"id\":\"lantern_post\"},{\"id\":\"supply_crate\"},{\"id\":\"root_vine\"}]},{\"index\":2,\"key\":\"village_mechanics\",\"biome\":\"village\",\"title\":\"Vesnice a strážci\",\"levels\":[3,4,5],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":3,\"key\":\"village_decor\",\"biome\":\"village\",\"title\":\"Vesnice a strážci\",\"levels\":[3,4,5],\"kind\":\"decor\",\"objects\":[{\"id\":\"cottage\"},{\"id\":\"guardian_arch\"},{\"id\":\"watchtower\"},{\"id\":\"lantern_post\"},{\"id\":\"well\"},{\"id\":\"fence\"},{\"id\":\"barrels\"},{\"id\":\"noticeboard\"},{\"id\":\"guardian_marker\"}]},{\"index\":4,\"key\":\"sky_mechanics\",\"biome\":\"sky\",\"title\":\"Oblačné ostrovy\",\"levels\":[6,7,8],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":5,\"key\":\"sky_decor\",\"biome\":\"sky\",\"title\":\"Oblačné ostrovy\",\"levels\":[6,7,8],\"kind\":\"decor\",\"objects\":[{\"id\":\"wind_arch\"},{\"id\":\"windmill\"},{\"id\":\"cloud_island\"},{\"id\":\"bell_tower\"},{\"id\":\"windsock\"},{\"id\":\"sky_cottage\"},{\"id\":\"anchor\"},{\"id\":\"cloud_cluster\"},{\"id\":\"wind_crystal\"}]},{\"index\":6,\"key\":\"castle_mechanics\",\"biome\":\"castle\",\"title\":\"Hrad a vězení\",\"levels\":[9,10],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":7,\"key\":\"castle_decor\",\"biome\":\"castle\",\"title\":\"Hrad a vězení\",\"levels\":[9,10],\"kind\":\"decor\",\"objects\":[{\"id\":\"royal_arch\"},{\"id\":\"prison_cage\"},{\"id\":\"column\"},{\"id\":\"banner\"},{\"id\":\"chandelier\"},{\"id\":\"mirror\"},{\"id\":\"chest\"},{\"id\":\"ivy\"},{\"id\":\"portal_frame\"}]},{\"index\":8,\"key\":\"garden_mechanics\",\"biome\":\"garden\",\"title\":\"Zahrady obrů\",\"levels\":[11,12,13,14,15],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":9,\"key\":\"garden_decor\",\"biome\":\"garden\",\"title\":\"Zahrady obrů\",\"levels\":[11,12,13,14,15],\"kind\":\"decor\",\"objects\":[{\"id\":\"giant_flower\"},{\"id\":\"leaf_arch\"},{\"id\":\"irrigation_pipe\"},{\"id\":\"reservoir\"},{\"id\":\"seed_bed\"},{\"id\":\"dew_leaf\"},{\"id\":\"root_bundle\"},{\"id\":\"thorn_vine\"},{\"id\":\"garden_shrine\"}]},{\"index\":10,\"key\":\"memory_mechanics\",\"biome\":\"memory\",\"title\":\"Řeka vzpomínek\",\"levels\":[16,17,18,19,20],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":11,\"key\":\"memory_decor\",\"biome\":\"memory\",\"title\":\"Řeka vzpomínek\",\"levels\":[16,17,18,19,20],\"kind\":\"decor\",\"objects\":[{\"id\":\"mirror_gate\"},{\"id\":\"crystal_cluster\"},{\"id\":\"river_stone\"},{\"id\":\"memory_obelisk\"},{\"id\":\"ruined_arch\"},{\"id\":\"glowing_reeds\"},{\"id\":\"memory_fountain\"},{\"id\":\"reflection_frame\"},{\"id\":\"water_lily\"}]},{\"index\":12,\"key\":\"stars_mechanics\",\"biome\":\"stars\",\"title\":\"Hvězdné hory\",\"levels\":[21,22,23,24,25],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":13,\"key\":\"stars_decor\",\"biome\":\"stars\",\"title\":\"Hvězdné hory\",\"levels\":[21,22,23,24,25],\"kind\":\"decor\",\"objects\":[{\"id\":\"observatory\"},{\"id\":\"telescope\"},{\"id\":\"lantern_house\"},{\"id\":\"star_lamp\"},{\"id\":\"alpine_rock\"},{\"id\":\"pine\"},{\"id\":\"constellation_table\"},{\"id\":\"empty_lanterns\"},{\"id\":\"star_shrine\"}]},{\"index\":14,\"key\":\"heart_mechanics\",\"biome\":\"heart\",\"title\":\"Temnota a Srdce\",\"levels\":[26,27,28,29,30],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"platform_long\"},{\"id\":\"ledge\"},{\"id\":\"lift_deck\"},{\"id\":\"lift_header\"},{\"id\":\"pressure_plate\"},{\"id\":\"gate\"},{\"id\":\"hazard\"},{\"id\":\"crumble_platform\"},{\"id\":\"repair_socket\"}]},{\"index\":15,\"key\":\"heart_decor\",\"biome\":\"heart\",\"title\":\"Temnota a Srdce\",\"levels\":[26,27,28,29,30],\"kind\":\"decor\",\"objects\":[{\"id\":\"heart_altar\"},{\"id\":\"root_arch\"},{\"id\":\"magic_conduit\"},{\"id\":\"shadow_root\"},{\"id\":\"royal_ruin\"},{\"id\":\"heart_pedestal\"},{\"id\":\"service_hatch\"},{\"id\":\"light_beacon\"},{\"id\":\"root_knot\"}]},{\"index\":16,\"key\":\"common_mechanisms\",\"biome\":\"common\",\"title\":\"Společné mechanismy\",\"levels\":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30],\"kind\":\"mechanics\",\"objects\":[{\"id\":\"lever_base\"},{\"id\":\"lever_handle\"},{\"id\":\"gear\"},{\"id\":\"chain_link\"},{\"id\":\"wind_rotor\"},{\"id\":\"spring_pad\"},{\"id\":\"valve_wheel\"},{\"id\":\"shadow_lock\"},{\"id\":\"checkpoint_lantern\"}]},{\"index\":17,\"key\":\"story_items\",\"biome\":\"story\",\"title\":\"Příběhové předměty\",\"levels\":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30],\"kind\":\"items\",\"objects\":[{\"id\":\"life_drop\"},{\"id\":\"memory_pearl\"},{\"id\":\"hope_star\"},{\"id\":\"essence_lantern\"},{\"id\":\"last_seed\"},{\"id\":\"wind_core\"},{\"id\":\"mirror_shard\"},{\"id\":\"star_shard\"},{\"id\":\"heart_core\"}]}],\"backgrounds\":[{\"index\":18,\"key\":\"giant_garden\",\"title\":\"Zahrady obrů\"},{\"index\":19,\"key\":\"root_depths\",\"title\":\"Kořeny v zajetí\"},{\"index\":20,\"key\":\"memory_lakes\",\"title\":\"Zrcadlová jezera\"},{\"index\":21,\"key\":\"star_mountains\",\"title\":\"Hory zhaslých hvězd\"},{\"index\":22,\"key\":\"shadow_kingdom\",\"title\":\"Návrat do temnoty\"},{\"index\":23,\"key\":\"kingdom_heart\",\"title\":\"Srdce království\"}]}")
root=Path('/home/user/starbit_world_assets');out=root/'export';ar=out/'assets/environment/worlds';dr=out/'docs/assets/worlds'
ar.mkdir(parents=True,exist_ok=True);(dr/'previews').mkdir(parents=True,exist_ok=True)
manifest={'format':1,'processor':'Higgsfield sandbox / Pillow','atlas_grid':[3,3],'segmentation':'whole-silhouette connected components; grid used only for object identity, never clipping','transparent_padding':8,'assets':[],'backgrounds':[]}
def hull(points):
 pts=sorted(set(points))
 def cross(o,a,b):return (a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
 lo=[]
 for p in pts:
  while len(lo)>=2 and cross(lo[-2],lo[-1],p)<=0:lo.pop()
  lo.append(p)
 hi=[]
 for p in reversed(pts):
  while len(hi)>=2 and cross(hi[-2],hi[-1],p)<=0:hi.pop()
  hi.append(p)
 return lo[:-1]+hi[:-1]
warnings=[]
for s in CFG['atlases']:
 im=Image.open(root/'sources'/('%02d.png'%s['index'])).convert('RGBA');W,H=im.size
 rgba=np.array(im);aa=rgba[:,:,3];count,labels,stats,centers=cv2.connectedComponentsWithStats((aa>8).astype(np.uint8),8)
 groups={i:[] for i in range(9)}
 for lab in range(1,count):
  if stats[lab,cv2.CC_STAT_AREA]<5:continue
  cx,cy=centers[lab];idx=min(2,int(cy*3/H))*3+min(2,int(cx*3/W));groups[idx].append(lab)
 for n,obj in enumerate(s['objects']):
  x0=round(n%3*W/3);y0=round(n//3*H/3);x1=round((n%3+1)*W/3);y1=round((n//3+1)*H/3)
  selected=np.isin(labels,groups[n]);mask=np.where(selected,aa,0).astype(np.uint8)
  alpha=Image.fromarray(mask).point(lambda a:0 if a<=8 else 255 if a>=250 else a)
  bound=alpha.getbbox();assert bound,(s['index'],n,'empty')
  l,t,r,b=bound
  if min(l,t,W-r,H-b)<3:warnings.append([s['index'],n,'near full atlas edge',bound])
  isolated=im.copy();isolated.putalpha(alpha)
  sprite=Image.new('RGBA',(r-l+16,b-t+16));sprite.paste(isolated.crop(bound),(8,8))
  folder=ar/s['biome'];folder.mkdir(exist_ok=True);p=folder/(obj['id']+'.png');sprite.save(p,optimize=True)
  a=sprite.getchannel('A');pix=a.load();tops=[]
  for x in range(int(sprite.width*.25),int(sprite.width*.75)):
   for y in range(sprite.height):
    if pix[x,y]>180:tops.append(y);break
  top=round(statistics.median(tops)) if tops else 8
  points=[]
  if obj['id']=='hazard':
   for y in range(0,sprite.height,5):
    for x in range(0,sprite.width,5):
     if pix[x,y]>128:points.append((x,y))
  entry={'id':s['biome']+'/'+obj['id'],'biome':s['biome'],'name':obj['id'],'kind':s['kind'],'levels':s['levels'],'path':str(p.relative_to(out)),'size':list(sprite.size),'anchor_bottom':[sprite.width/2,sprite.height-8],'anchor_top':[sprite.width/2,top],'source_atlas':s['index'],'source_rect':[l,t,r-l,b-t],'component_count':len(groups[n]),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
  if points:entry['collision_hull']=hull(points)
  manifest['assets'].append(entry)
for b in CFG['backgrounds']:
 folder=ar/'backgrounds';folder.mkdir(exist_ok=True);p=folder/(b['key']+'.png');shutil.copy2(root/'sources'/('%02d.png'%b['index']),p)
 manifest['backgrounds'].append({'key':b['key'],'title':b['title'],'path':str(p.relative_to(out)),'size':list(Image.open(p).size),'source_atlas':b['index'],'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
assert len(manifest['assets'])==162
manifest['qa']={'sprite_count':162,'new_background_count':6,'near_cell_edge_warnings':warnings}
(ar/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
# Actual asset contact sheets. Review on a solid game-colored surface.
for s in CFG['atlases']:
 page=Image.new('RGB',(1200,1260),'#1c3440');d=ImageDraw.Draw(page)
 for n,obj in enumerate(s['objects']):
  p=ar/s['biome']/(obj['id']+'.png');im=Image.open(p);im.thumbnail((365,335))
  x=n%3*400+(400-im.width)//2;y=n//3*420+36+(335-im.height)//2;page.paste(im,(x,y),im)
  d.text((n%3*400+16,n//3*420+390),s['biome']+'/'+obj['id'],fill='#e1eddc')
 page.save(dr/'previews'/(s['key']+'.jpg'),quality=79)
shutil.copy2(root/'qa/backgrounds.jpg',dr/'previews/backgrounds.jpg')
# Production-scale visual checks: foreground items and original Bit over the actual target backdrop.
import urllib.request,io
bit=Image.open(io.BytesIO(urllib.request.urlopen('https://raw.githubusercontent.com/dersi128/STARBIT-Kralovstvi-snu/6b4d4f37aab920ad86d0069710cfe1763693d56d/assets/shared/pieces/idle.png').read())).convert('RGBA')
bit=bit.crop(bit.getchannel('A').getbbox())
biomes=['forest','village','sky','castle','garden','memory','stars','heart'];envs=[1,3,6,10,18,20,21,23]
for key,env in zip(biomes,envs):
 bg=Image.open(root/('refs/env_%02d.png'%env if env<18 else 'sources/%02d.png'%env)).convert('RGB').resize((1280,720),Image.Resampling.LANCZOS)
 def place(name,x,y,w=None,h=None,top=False):
  it=next(a for a in manifest['assets'] if a['id']==key+'/'+name);im=Image.open(out/it['path']);factor=w/im.width if w else h/im.height;im=im.resize((round(im.width*factor),round(im.height*factor)),Image.Resampling.LANCZOS)
  yy=round(y-it['anchor_top'][1]*factor) if top else y-im.height
  bg.paste(im,(round(x-im.width/2),round(yy)),im)
 place('platform_long',280,560,w=480,top=True);place('ledge',840,410,w=235,top=True);place('lift_deck',600,520,w=230,top=True);place('lift_header',600,210,w=220)
 d=ImageDraw.Draw(bg);d.line((515,210,515,520),fill='#8b6134',width=4);d.line((685,210,685,520),fill='#8b6134',width=4)
 # Put pulleys and deck in front of rope ends.
 place('lift_header',600,210,w=220);place('lift_deck',600,520,w=230,top=True)
 place('repair_socket',365,560,h=135);place('hazard',895,600,h=105)
 dec=next(s for s in CFG['atlases'] if s['biome']==key and s['kind']=='decor')
 place(dec['objects'][0]['id'],1100,565,h=265);place(dec['objects'][6]['id'],100,560,h=145)
 it=bit.copy();it.thumbnail((90,100));bg.paste(it,(205,560-it.height),it)
 bg.save(dr/'previews'/('scale_'+key+'.jpg'),quality=86)
overview=Image.new('RGB',(1600,1952),'#112a38');d=ImageDraw.Draw(overview)
for n,key in enumerate(biomes):
 im=Image.open(dr/'previews'/('scale_'+key+'.jpg')).resize((784,441),Image.Resampling.LANCZOS);x=n%2*800+8;y=n//2*488+36;overview.paste(im,(x,y));d.text((x,y-23),key.upper(),fill='white')
overview.save(dr/'previews/worlds_overview.jpg',quality=84)
pack=root/'STARBIT-World-Assets-Ready.zip'
with zipfile.ZipFile(pack,'w',zipfile.ZIP_DEFLATED,compresslevel=5) as z:
 for p in out.rglob('*'):
  if p.is_file():z.write(p,p.relative_to(out))
print(json.dumps({'sprites':162,'backgrounds':6,'warnings':warnings,'zip_bytes':pack.stat().st_size}))
