extends Node
const LEVEL_COUNT := 10
var unlocked := 1
var muted := false
var level_stars: Dictionary = {}
var tones: Array[AudioStreamPlayer] = []
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 var c := ConfigFile.new()
 if c.load("user://dreambit.cfg") == OK:
  unlocked = clampi(int(c.get_value("save", "unlocked", 1)), 1, 10)
  muted = bool(c.get_value("save", "muted", false))
  var stored = c.get_value("save", "level_stars", {})
  var legacy := not c.has_section_key("save", "level_stars")
  for n in range(1, LEVEL_COUNT + 1):
   var value = stored.get(str(n), 0) if stored is Dictionary else 0
   if legacy and n < unlocked:value = 1
   level_stars[str(n)] = clampi(value, 0, 3) if value is int else 0
func save() -> void:
 var c := ConfigFile.new()
 c.load("user://dreambit.cfg")
 c.set_value("save", "unlocked", unlocked)
 c.set_value("save", "muted", muted)
 c.set_value("save", "level_stars", level_stars)
 c.save("user://dreambit.cfg")
func stars_for_run(diamonds:int,total:int) -> int:
 # A level without diamonds awards completion only. Half must be exceeded.
 if total <= 0:return 1
 if diamonds >= total:return 3
 return 2 if diamonds * 2 > total else 1
func best_stars(n:int) -> int:
 return clampi(int(level_stars.get(str(n),0)),0,3)
func total_stars() -> int:
 var total := 0
 for n in range(1,LEVEL_COUNT+1):total += best_stars(n)
 return total
func record_level_result(n:int,diamonds:int,total:int) -> Dictionary:
 if n < 1 or n > LEVEL_COUNT:return {}
 var earned := stars_for_run(diamonds,total)
 var previous := best_stars(n)
 var best := maxi(previous,earned)
 level_stars[str(n)] = best
 unlocked = maxi(unlocked,mini(LEVEL_COUNT,n+1))
 save()
 return {"earned":earned,"best":best,"added":best-previous,"total":total_stars()}
func sound(freq: float, length: float = 0.12) -> void:
 if muted or tones.size() > 6: return
 var stream := AudioStreamWAV.new()
 stream.format = AudioStreamWAV.FORMAT_16_BITS
 stream.mix_rate = 22050
 var bytes := PackedByteArray()
 bytes.resize(int(length*22050)*2)
 for i in range(bytes.size()/2):
  var t := float(i)/22050.0
  var env := sin(PI*t/length)*0.12
  var v := int(32767*env*(sin(TAU*freq*t)+0.25*sin(TAU*freq*2*t)))
  bytes.encode_s16(i*2,v)
 stream.data = bytes
 var p := AudioStreamPlayer.new()
 p.stream = stream
 p.volume_db = -8
 add_child(p)
 tones.append(p)
 p.finished.connect(func(): tones.erase(p);p.queue_free())
 p.play()
func silence() -> void:
 if is_instance_valid(music):music.stream_paused=true
 for old in fading_music:
  if is_instance_valid(old):old.stop();old.queue_free()
 fading_music.clear()
 for p in tones: p.queue_free()
 tones.clear()

var clip_cache:Dictionary = {}
func sfx(event:String) -> void:
 if muted or tones.size()>=9:return
 if event=="boss_push":
  var p:=AudioStreamPlayer.new();p.stream=load("res://assets/audio/bear_push.ogg");p.volume_db=-10;add_child(p);tones.append(p)
  p.finished.connect(func():tones.erase(p);p.queue_free());p.play();return
 var profiles={
  "step":[95.0,65.0,0.055,-26.0],
  "jump":[350.0,780.0,0.14,-17.0],
  "land":[150.0,65.0,0.085,-23.0],
  "boost":[450.0,1100.0,0.28,-20.0],
  "collect":[880.0,1320.0,0.16,-17.0],
  "gold":[1050.0,1760.0,0.28,-16.0],
  "hurt":[290.0,115.0,0.23,-17.0],
  "enemy":[410.0,720.0,0.17,-20.0],
  "turn":[180.0,240.0,0.075,-30.0],
  "boss_warn":[150.0,210.0,0.3,-18.0],
  "boss_push":[150.0,65.0,0.26,-15.0],
  "boss_hit":[310.0,640.0,0.22,-16.0],
  "voice_mole":[220.0,290.0,0.07,-23.0],
  "voice_star":[640.0,780.0,0.06,-26.0],
  "repair":[530.0,1060.0,0.35,-18.0],
  "ui":[570.0,760.0,0.055,-28.0],
  "checkpoint":[660.0,990.0,0.22,-19.0],
  "victory":[660.0,1320.0,0.95,-15.0]
 }
 if not profiles.has(event):return
 var spec:Array=profiles[event]
 if not clip_cache.has(event):
  var stream:=AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=22050
  var count:=int(float(spec[2])*22050)
  var data:=PackedByteArray();data.resize(count*2)
  var phase:=0.0
  for i in count:
   var t:=float(i)/22050.0
   var u:=float(i)/count
   var frequency:=lerpf(spec[0],spec[1],u)
   if event.begins_with("voice"):frequency*=1+0.12*sin(t*130)
   if event=="victory":frequency=[523.25,659.25,783.99,1046.5][mini(3,int(u*4))]
   phase+=TAU*frequency/22050.0
   var env:=minf(1.0,t/0.012)*pow(1.0-u,1.6)
   var v:=0.55*env*(sin(phase)+0.18*sin(phase*2.0)+0.08*sin(phase*3.0))
   data.encode_s16(i*2,int(clampf(v,-0.9,0.9)*32767))
  stream.data=data;clip_cache[event]=stream
 var p:=AudioStreamPlayer.new();p.stream=clip_cache[event];p.volume_db=spec[3];add_child(p);tones.append(p)
 p.finished.connect(func():tones.erase(p);p.queue_free());p.play()

var music:AudioStreamPlayer
var music_track:=""
var fading_music:Array[AudioStreamPlayer]=[]
func play_music(track:String) -> void:
 if muted:
  silence()
  return
 if music_track==track and is_instance_valid(music):
  music.stream_paused=false
  return
 var path:="res://assets/audio/"+track+".ogg"
 if not ResourceLoader.exists(path):
  push_warning("Music resource missing or not imported: "+path)
  return
 var stream:=load(path) as AudioStreamOggVorbis
 if stream==null:
  push_warning("Music could not be loaded: "+path)
  return
 stream.loop=track!="victory"
 var old:=music
 music=AudioStreamPlayer.new()
 music.stream=stream;music.volume_db=-50;add_child(music);music.play()
 music_track=track
 create_tween().tween_property(music,"volume_db",-12.0 if track=="menu_adventure" else -15.0,0.65)
 if is_instance_valid(old):
  fading_music.append(old)
  var tween:=create_tween().bind_node(old)
  tween.tween_property(old,"volume_db",-50.0,0.65)
  tween.tween_callback(func():
   fading_music.erase(old)
   if is_instance_valid(old):old.stop();old.queue_free()
  )
